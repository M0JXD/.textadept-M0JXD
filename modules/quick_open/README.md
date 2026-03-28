# Quick Open Module

Quickly open a Terminal or File Browser at the currently opened file's path.
It's based on https://github.com/orbitalquark/textadept/wiki/TerminalHere

By default, it will use:

- `explorer.exe` and `cmd.exe` on Windows (I'm unsure how well it will work for different explorers and terminals on Windows).
- xdg-open to open a file browser on Linux and BSD.
- The suspected default terminal for the currently detected desktop environment.
- There is a viewer option that will open the file with xdg-open/start. For Markdown and LaTeX, a PDF is generated with pandoc first (they are not automatically deleted).
- There's also an option to launch a TUI Git client with a fullscreen terminal. The default is Lazygit.

I don't have any Apple devices so I'm unable to implement for macOS.
If setting a custom terminal, as the directory argument are sometimes like `--working-directory=` you might need to add the trailing whitespace.

Example usage:

```lua
local quick_open = require('quick_open')
quick_open.terminal = 'cool-retro-term'
quick_open.term_dir_arg = '--workdir '
quick_open.term_max_arg = '--fullscreen'
quick_open.explorer = 'nautilus'
quick_open.git_client = 'gitui'
quick_open.bindings.terminal = 'alt+T'
```
