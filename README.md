# My Textadept stuff

A collection of things I use/modified for Textadept. There's:
- Three Ayu-like themes, light, dark and term, which are made to match VSCode's highlighting guide better than the base16 ones. The dark one uses a pure black background.
- My init.lua
- A modified file_browser module
  
Mainly here so I can grab them wherever I need them.

## File Browser modifications
Mitchell's Textadept file_browser module with some changes.

### About

This is mostly the same as the [original version](https://github.com/orbitalquark/textadept/wiki/ta-filebrowser) but adds some sorting options that refugees from other editors may find helpful. <br>
NOTE: At the moment this seems a bit broken on Windows. Want to fix... at some point.

1) The highlighting is improved for Textadept 12 and now uses multiple colours depending on expanded/folded state.
2) There are simple booleans that can be set to hide dot files/folders, sort without case sensitivity and force the folders to be listed first.

### Installation

Add this module's init.lua under the "file_browser" folder the same way as is detailed in the Textadept wiki.
You can then initialise it in your Textadept's init.lua. Here's an example:

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
