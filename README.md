# My (M0JXD's) ~/.textadept/

My collection of things I use/modified for Textadept. There's:
- Two Ayu-like themes, ayu-light and ayu-evolve, which are made to match VSCode's highlighting guide better than the base16 ones. The dark one uses a pure black background and works well in 256 color terminals for the CURSES version.
- My init.lua
- A module for handling themes
- A module for distraction free mode
- A modified file_browser module

Mainly here so I can grab them wherever I need them.

## Theme Manager Module

Theme manager is a handy module for setting themes that switch with the system in the GUI version, and carefully applying theme aspects depending on system limitations. E.g. often Windows doesn't have fonts so it can choose to use Textadept's default, and for the CURSES version it'll attempt to detect if a terminal has true-color support so it can apply a fallback theme if necessary.

Example usage:

```lua
local theme_mgr = require('theme_mgr')
theme_mgr.light_theme = 'ayu-light'
theme_mgr.dark_theme = 'ayu-evolve'
theme_mgr.term_theme = 'ayu-evolve'
theme_mgr.font_type = 'Noto Mono'
theme_mgr.font_size = 14
theme_mgr.win32_default_font = false
theme_mgr.term_fallback_theme = 'term'
```

## Distraction Free Module

Based on Mitchell's [Distraction Free mode](https://github.com/orbitalquark/textadept/wiki/DistractionFreeMode) but wrapped into a module. 
Also added the ability to hide the tab bar, and allows you to configure what you want to hide. Also works on CURSES and hides the title on that platform.
Defaults to my preferences, it uses `Ctrl+F12` as to allow F11 to be free for "Step Into" debugger commands. </br>

Example usage:

```lua
local distraction_free = require('distraction_free')
distraction_free.hide_menubar = false
distraction_free.hide_tabs = false
distraction_free.hide_scrollbars = true
distraction_free.clear_statusbar = false
distraction_free.hide_margins = true
distraction_free.maximise = true
```

## File Browser Module Modifications
Mitchell's Textadept file_browser module with some changes.

### About

This is mostly the same as the [original version](https://github.com/orbitalquark/textadept/wiki/ta-filebrowser) but adds some sorting options that refugees from other editors may find helpful. <br>
NOTE: At the moment this seems a bit broken on Windows. Want to fix... at some point.

1) The highlighting is improved for Textadept 12 and now uses multiple colours depending on expanded/folded state.
2) There are simple booleans that can be set to hide dot files/folders, sort without case sensitivity and force the folders to be listed first.

Example usage:

```lua
-- File Browser Module
local file_browser = require('file_browser')
-- Ctrl+Shift+o to open directory
keys['ctrl+O'] = file_browser.init
table.insert(textadept.menu.menubar[_L['File']], 3, {
    'Open Directory...', file_browser.init
})
file_browser.hide_dot_folders = true
file_browser.hide_dot_files = false
file_browser.force_folders_first = true
file_browser.case_insensitive_sort = true
```

### Colour customisation

The colours depend on keywords defined by Textadept's [lexer tags](https://orbitalquark.github.io/textadept/api.html#lexer).
You can modify them in the "highlight_folder" function.

### Use in the TUI version.

When using the "Open Directory" option in the terminal (you might need to use "Run Command" dialog as `ctrl-shift+o` might not be detected as different to `ctrl+o`) you have to append a '.' to folder name to make it open, e.g.
`/home/myuser/dev/myprojectfolder.`
