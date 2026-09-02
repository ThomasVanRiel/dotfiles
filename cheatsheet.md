# Command cheatsheet

Rare commands that are easy to forget. Use one entry per task and write the
heading in the words you would search for later.

## rsync — copy or mirror a directory

```sh
# Preview a local copy; remove --dry-run when satisfied
rsync -avhP --update --exclude='.git/' --dry-run <source>/ <destination>/

# Copy to a remote host over SSH
rsync -avhP --update --exclude='.git/' <source>/ <user>@<host>:<destination>/

# Preview an exact mirror; --delete removes destination-only files
rsync -avhP --delete --dry-run <source>/ <destination>/
```

### Flags

- `-a`, `--archive` (`-rlptgoD`): recurse and preserve links, permissions,
  times, owner, group, devices, and special files. Add `-HAX` for hard links,
  ACLs, and xattrs.
- `-v`, `--verbose`: show transferred files.
- `-h`, `--human-readable`: make sizes easier to read.
- `-P`: keep partial files and show per-file progress (`--partial --progress`).
- `-u`, `--update`: skip files that are newer at the destination.
- `-n`, `--dry-run`: preview without changing anything.
- `--exclude='<pattern>'`: skip matching paths; repeat for multiple patterns.
- `--delete`: remove destination-only files; preview this with `--dry-run`.
- `-e 'ssh -p <port>'`: use a custom SSH command or port.

A trailing `/` on the source copies its contents; without it, rsync copies the
source directory itself.

## grep — search recursively

```sh
# Find literal text recursively, ignoring common generated directories
grep -rniF --exclude-dir={.git,node_modules} '<text>' .

# Search selected file types with a regular expression
grep -rniE --include='*.js' --include='*.ts' '<regex>' .

# Show a match with three lines of surrounding context
grep -FnC 3 '<literal text>' <file>

# Print only names of files containing a match
grep -rlF '<text>' <path>
```

### Flags

- `-r`, `--recursive`: search directories recursively; `-R` also follows
  symlinks.
- `-n`, `--line-number`: print line numbers.
- `-i`, `--ignore-case`: ignore letter case.
- `-F`, `--fixed-strings`: treat the pattern as literal text.
- `-E`, `--extended-regexp`: use extended regular expressions.
- `-w`, `--word-regexp`: match whole words only.
- `-v`, `--invert-match`: print lines that do not match.
- `-l`, `--files-with-matches`: print matching file names only.
- `-C <n>`: show context; use `-A <n>` or `-B <n>` for only after or before.
- `--include='<glob>'`, `--exclude='<glob>'`: filter file names.
- `--exclude-dir='<glob>'`: skip matching directories.

## eza — detailed listings

```sh
e <path>                         # detailed view with Git information
ea <path>                        # include hidden files
etree <path>                     # tree, two levels deep
e --tree --level=<depth> <path>  # tree with a custom depth
e --sort=size --reverse <path>   # largest entries first
e --only-dirs <path>             # directories only
e --git-ignore <path>            # hide Git-ignored files
```

### Flags

The `e` alias expands to
`eza --long --links --group --color=auto --git --git-repos`.

- `-l`, `--long`: show the detailed table view.
- `-a`, `--all`: include hidden files; used by `ea`.
- `-H`, `--links`: show the number of hard links.
- `-g`, `--group`: show each file's group.
- `--git`: show per-file Git status.
- `--git-repos`: show Git repository status for directories.
- `-T`, `--tree`: display a tree; used by `etree` with `--level=2`.
- `-L <depth>`, `--level=<depth>`: limit recursion depth.
- `-s <field>`, `--sort=<field>`: sort by `name`, `date`, `size`, `type`, etc.
- `-r`, `--reverse`: reverse the sort order.
- `-D`, `--only-dirs`: list directories only; `-f` lists files only.
- `--git-ignore`: hide files ignored by Git.
- `-I '<globs>'`, `--ignore-glob='<globs>'`: hide pipe-separated globs.

## Fuzzy selection in Zsh

The fzf integration adds fuzzy selection directly to the command line:

- `**<Tab>`: complete whatever the command expects, such as files with
  `nvim **<Tab>`, directories with `cd **<Tab>`, hosts with `ssh **<Tab>`, or
  processes with `kill **<Tab>`.
- `Ctrl-T`: select files or directories and paste their paths at the cursor.
- `Ctrl-R`: search shell history and paste the selected command.
- `Alt-C`: select a directory and change to it.
