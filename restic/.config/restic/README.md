# restic backup setup

Daily backup of `$HOME` to a `restic/rest-server` instance on the LAN, scheduled
via a user systemd timer. Retention: 7 daily / 4 weekly / 6 monthly.

## What this package installs

After `cd ~/dotfiles && stow restic` you get:

| Stow source                                         | Target                                        |
| --------------------------------------------------- | --------------------------------------------- |
| `restic/.local/bin/home-backup`                     | `~/.local/bin/home-backup`                    |
| `restic/.config/systemd/user/home-backup.service`   | `~/.config/systemd/user/home-backup.service`  |
| `restic/.config/systemd/user/home-backup.timer`     | `~/.config/systemd/user/home-backup.timer`    |
| `restic/.config/restic/README.md`                   | `~/.config/restic/README.md` (this file)      |

The actual credentials (`env`, `password`, `excludes`) are **not** in the
dotfiles repo. You create them by hand on each machine — see below.

## One-time setup on a new machine

### 1. Install restic

```sh
sudo pacman -S restic         # Arch / CachyOS
# or: sudo apt install restic
```

### 2. Add an HTTP basic-auth user on the rest-server

The rest-server runs in Docker on the backup host. The htpasswd file is bind-mounted
read-only, so write to it from a throwaway container (run on the rest-server host):

```sh
cd ~/dockerfiles/rest-server
touch htpasswd   # only on first run, if the file doesn't exist yet
docker run --rm -it -u 0 --entrypoint htpasswd \
  -v "$PWD/htpasswd:/htpasswd" \
  restic/rest-server:latest -B -c /htpasswd <username>
```

Drop the `-c` flag when updating an existing user (or when the file already
contains other users — `-c` wipes it).

Pick a `<username>` that's unique per client machine (e.g. `thomas-linux`,
`thomas-laptop`). With `--private-repos` (the default), the URL path must equal
the username.

### 3. Create the local credential files

```sh
mkdir -p ~/.config/restic && chmod 700 ~/.config/restic
```

Then create these three files, all chmod 600:

**`~/.config/restic/env`**

```sh
export RESTIC_REPOSITORY='rest:http://<user>:<http-password>@192.168.0.222:8484/<user>/'
export RESTIC_PASSWORD_FILE="$HOME/.config/restic/password"
```

`<user>` and `<http-password>` are what you set in step 2. `<user>` appears
twice — once for HTTP basic auth, once as the private-repo path.

**`~/.config/restic/password`**

A single line: the repo encryption password. **Different from the HTTP password.**
Pick something strong and store it in a password manager — if you lose it,
the data is unrecoverable. Restic does not have a recovery mechanism.

**`~/.config/restic/excludes`**

Exclude patterns (caches, browser caches, Steam, dev build artifacts, VM images,
ISOs). See an existing machine for the current list, or copy from a recent
commit of this package's history.

Lock everything down:

```sh
chmod 600 ~/.config/restic/{env,password,excludes}
```

### 4. Initialize the repository

```sh
source ~/.config/restic/env
restic init
```

Should print `created restic repository <id> at rest:http://…`. If you get a
401, the HTTP password is wrong. If you get a 404, the URL path doesn't match
the htpasswd username (rest-server is in private-repos mode).

### 5. Stow the package and enable the timer

```sh
cd ~/dotfiles
stow restic

systemctl --user daemon-reload
systemctl --user enable --now home-backup.timer
```

`enable --now` starts the timer immediately. Because the unit uses
`OnStartupSec=15min` + `Persistent=true` and `systemd --user` has typically been
running since login, the first backup fires right away to "catch up" the
missed run.

## Day-to-day commands

```sh
# Check timer schedule
systemctl --user list-timers home-backup.timer

# Watch a running backup
journalctl --user -u home-backup.service -f

# Recent run history
journalctl --user -u home-backup.service -n 100 --no-pager

# Manual run (foreground, useful for debugging)
~/.local/bin/home-backup

# Snapshots
source ~/.config/restic/env
restic snapshots
restic stats latest

# Restore a single file
restic restore latest --target /tmp/restore --include "$HOME/path/to/file"
```

## Operational notes

- **First backup is slow.** All of `$HOME` (minus excludes) goes up. Subsequent
  runs upload only changed chunks and finish in seconds-to-minutes depending on
  churn.
- **`--one-file-system`** is set in the backup script. Mounted external drives
  under `$HOME` are skipped. Drop the flag if you want them included.
- **`--exclude-caches`** honors `CACHEDIR.TAG` markers, so a lot of tool caches
  get skipped automatically without listing them in `excludes`.
- **Retention runs every time.** `restic forget --keep-daily 7 --keep-weekly 4
  --keep-monthly 6 --prune` is part of the service. Prune is the slow/IO-heavy
  step; on small daily deltas it's still fast.
- **Plain HTTP on the LAN.** The repo URL is `http://`, not `https://`. Restic
  encrypts data client-side before upload, so the wire contents are safe — but
  the HTTP basic-auth password travels in cleartext. Acceptable on a trusted
  LAN; put rest-server behind a TLS reverse proxy if that changes.
- **Two passwords, kept separate.** The HTTP password gates the server; the
  encryption password protects the repo contents. Losing the encryption
  password = unrecoverable data.

## Verifying a restore actually works

```sh
restic restore latest --target /tmp/restore-test --include "$HOME/.zshrc"
diff "/tmp/restore-test$HOME/.zshrc" ~/.zshrc   # no output = identical
rm -rf /tmp/restore-test
```

Do this once after the first successful backup, and re-do it occasionally — a
backup you haven't tested restoring is a backup you don't have.
