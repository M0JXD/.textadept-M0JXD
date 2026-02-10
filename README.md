# My (M0JXD's) ~/.textadept/

My collection of things I use/modified for Textadept. There's:
- My init.lua
- Various simple utility modules (detailed below)
- Four themes
    - Two Ayu-like themes, ayu-light and ayu-evolve, which are made to match VSCode's highlighting better than the base16 ones. The dark one uses a pure black background and works well in 256 color terminals with textadept-curses.
    - Two Xed themes to match the default highlighting in Linux Mint's default editor.

Mainly here so I can grab them wherever I need them.

## Theme Manager Module

To truly change themes with the system in Textadept [is a bit complicated if you don't want to override the default theme files](https://github.com/orbitalquark/textadept/issues/602#issuecomment-2758753214).
Theme manager is a handy module for setting themes that switch with the system in the GUI version, and carefully applies theme aspects depending on system limitations, such as:
- On Windows, many fonts are often missing, so it can opt to use Textadept's default font.
- Since 12.7, Textadept supports arbitrary RGB colours in the terminal version, which means many GUI themes also work in terminals with true-color support. The module will attempt to detect if a terminal has true-color support so it can apply a fallback theme if necessary.

By default it uses Textadept's default themes and settings.
Example usage:

```lua
local theme_mgr = require('theme_mgr')
theme_mgr.light_theme = 'ayu-light'
theme_mgr.dark_theme = 'ayu-evolve'
theme_mgr.term_theme = 'base16-catppuccin-latte'
theme_mgr.font_type = 'Noto Mono'
theme_mgr.font_size = 14
theme_mgr.win32_default_font = false
theme_mgr.term_fallback_theme = 'term'
```

## Distraction Free Module

Based on Mitchell's [Distraction Free mode](https://github.com/orbitalquark/textadept/wiki/DistractionFreeMode) but wrapped into a module.
Also added the ability to hide the tab bar, and allows you to configure what you want to hide.
Also works on CURSES and hides the title. Defaults to my preferences, I use `Ctrl+F12` as to allow F11 to be free for "Step Into" debugger commands.

Example usage:

```lua
local distraction_free = require('distraction_free')
distraction_free.hide_menubar = false
distraction_free.hide_tabs = false
distraction_free.hide_scrollbars = true
distraction_free.clear_statusbar = false
distraction_free.hide_margins = true
distraction_free.maximise = true
distraction_free.toggle_shortcut = 'ctrl+f11'
```

## Quick Open Module

Quickly open a Terminal or File Browser at the currently opened file's path.
It's based on https://github.com/orbitalquark/textadept/wiki/TerminalHere

By default, it will use:

- Nemo and GNOME Terminal on Linux
- Thunar and XFCE4 Terminal on BSD
- explorer.exe and cmd.exe on Windows

I'm unsure how well the Windows implementation will work for different explorers and terminals.
I don't have any Apple devices so I'm 'unable to implement for macOS.

Example usage:

```lua
local quick_open = require('quick_open')
quick_open.terminal = 'cool-retro-term'
quick_open.explorer = 'nautilus'
```

I'm unsure if the Windows implementations will work for other explorers/terminals.

## Document Statistics Module

Document Statistics is inspired by the same feature in the Xed editor.
It will add a menu under Tools which will show a dialog with statistics for the current selection and the whole document.
Currently there are only three: Lines, Words and Byte count.

The word count feature is based on https://www.countofwords.com/word-count-algorithms-and-how-you-can-use-them.html
The separators are configurable in the doc_stats.separators array. By default, it will only match whitespace, which will provide the same results as MS Office.

Example usage:
```lua
require('doc_stats')
```

## Modified File Browser Module

I now very rarely use the file_browser, instead I prefer to open the system browser (hence the Quick Open module). As such it should be considered unmaintained.
This is mostly the same as the [original version](https://github.com/orbitalquark/textadept/wiki/ta-filebrowser) but adds some sorting options that refugees from other editors may find helpful. <br>

NOTE: At the moment this seems a bit broken on Windows.

1) The highlighting is improved for Textadept 12 and now uses multiple colours depending on expanded/folded state.
2) There are simple booleans that can be set to hide dot files/folders, sort without case sensitivity and force the folders to be listed first.

Example usage:

```lua
-- File Browser Module
local file_browser = require('file_browser')
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
