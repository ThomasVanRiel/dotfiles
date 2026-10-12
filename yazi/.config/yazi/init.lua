-- Git status signs in the file list; fetchers are registered in yazi.toml.
require("git"):setup({ order = 1500 })

-- Starship prompt as the header.
require("starship"):setup()

-- Branch and status next to repository directories.
require("repo-status"):setup({ order = 1400, align = true })
