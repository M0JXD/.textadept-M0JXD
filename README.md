# My (M0JXD's) ~/.textadept/

My collection of things I use/modified for Textadept. There's:
- My init.lua
- Various simple utility modules (detailed below)
- Four themes
    - Two Ayu-like themes, ayu-light and ayu-evolve, which are made to match VSCode's highlighting better than the base16 ones. The dark one uses a pure black background and works well in 256 colour terminals with textadept-curses.
    - Two Xed themes to match the default highlighting in Linux Mint's default editor.

Mainly here so I can grab them wherever I need them.

## Theme Manager Module

To truly change themes with the system in Textadept [is a bit complicated if you don't want to override the default theme files](https://github.com/orbitalquark/textadept/issues/602#issuecomment-2758753214).
Theme manager is a handy module for setting themes that switch with the system in the GUI version, and carefully applies theme aspects depending on system limitations, such as:
- On Windows, many fonts are often missing, so it can opt to use Textadept's default font.
- Since 12.7, Textadept supports arbitrary RGB colours in the terminal version, which means many GUI themes also work in terminals with true-colour support. The module will attempt to detect if a terminal has true-colour support so it can apply a fallback theme if necessary.

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
Also works on CURSES and hides the title. Defaults to my preferences, as I prefer `Ctrl+F12`.

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

- `explorer.exe` and `cmd.exe` on Windows (I'm unsure how well it will work for different explorers and terminals).
- xdg-open to open a file browser on Linux and BSD.
- The suspected default terminal for the currently detected desktop environment.
- There's also an option to launch a TUI Git client with a fullscreen terminal. The default is Lazygit.

I don't have any Apple devices so I'm unable to implement for macOS.

Example usage:

```lua
local quick_open = require('quick_open')
quick_open.terminal = 'cool-retro-term'
quick_open.term_dir_arg = '--workdir '
quick_open.term_max_arg = ' --fullscreen'
quick_open.explorer = 'nautilus'
quick_open.git_client = 'gitui'
```

I'm unsure if the Windows implementations will work for other explorers/terminals.

## Buffer Statusbar Manager

Buffer Statusbar Manager is the short awaited version two of bfstatbar_helper that was removed in 8d5ef307d5f7.
It represents the items in the buffer statusbar as a array of getter functions.
By default it provides the same defaults that Textadept displays in the buffer statusbar.

Example usage:

```lua
bfstatbar = require('bfstatbar_mgr')

table.remove(bfstatbar, 4)  -- Remove line endings

-- Display whether strip trailing whitespace is on
table.insert(bfstatbar, 5, function ()
	return 'Strip: ' .. (textadept.editing.strip_trailing_spaces and 'On' or 'Off')
end)
```

## Document Statistics Module

Document Statistics is inspired by the plugin of the same name in the Xed editor and the Summary feature in Notepad++.
It will add a menu under Tools which will show a dialog with statistics for the current selection and the whole document.

You can also optionally add these details in the buffer status bar (this requires `bfstatbar_mgr` be imported as bfstatbar).
You may set each `display_` field as true to use the default placement or use a number to insert it to a position of your choice.

There is a boolean field called `replace_lines` that will change the behaviour of Textadept's current line counter so that it shows the amount of lines when a selection exists, but is otherwise the same when there is no selection.

The internal utilities functions are exposed, e.g. you may call `doc_stats.count_words(false)` to get the words for the current selection (true would get the whole document). They work on the currently active buffer.

The word count feature is based on https://www.countofwords.com/word-count-algorithms-and-how-you-can-use-them.html
The separators are configurable in the doc_stats.separators array. By default, it only matches whitespace, which provides the same results as MS Office.

Example usage:

```lua
doc_stats = require('doc_stats')
doc_stats.menu_entry = false
doc_stats.display_words = true
doc_stats.display_bytes = true
doc_stats.replace_lines = true
doc_stats.display_chars = 5
doc_stats.display_chars_ns = 1

local all_spaces = doc_stats.count_spaces(true)
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
