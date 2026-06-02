# Distraction Free Module

Based on Mitchell's [Distraction Free mode](https://github.com/orbitalquark/textadept/wiki/DistractionFreeMode) but wrapped into a module.
It has the additional ability to hide the tab bar, and allows you to configure what you want to hide.
Also works in the terminal version, hiding the title. Defaults to my preferences.

Example usage:

```lua
local distraction_free = require('distraction_free')
distraction_free.hide_menubar = true
distraction_free.hide_tabs = true
distraction_free.hide_scrollbars = true
distraction_free.hide_statusbar = true
distraction_free.hide_margins = false
distraction_free.hide_term_title = true
distraction_free.maximise = false
distraction_free.toggle_shortcut = 'ctrl+f12'
```
