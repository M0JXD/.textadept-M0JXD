# Distraction Free Module

Based on Mitchell's [Distraction Free mode](https://github.com/orbitalquark/textadept/wiki/DistractionFreeMode) but wrapped into a module.
Also added the ability to hide the tab bar, and allows you to configure what you want to hide.
Also works on CURSES and hides the title. Defaults to my preferences.

Example usage:

```lua
local distraction_free = require('distraction_free')
distraction_free.hide_menubar = false
distraction_free.hide_tabs = false
distraction_free.hide_scrollbars = true
distraction_free.clear_statusbar = false
distraction_free.hide_margins = true
distraction_free.maximise = true
distraction_free.toggle_shortcut = 'ctrl+f12'
```
