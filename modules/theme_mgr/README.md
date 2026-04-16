# Theme Manager Module

To truly change themes with the system in Textadept [is a bit complicated if you don't want to override the default theme files](https://github.com/orbitalquark/textadept/issues/602#issuecomment-2758753214).  
Theme manager is a module for setting themes that switch with the system in the GUI version, and carefully applies theme aspects depending on system limitations, such as:

- If a requested font is missing, it will opt to use Textadept's default font instead of the OS default font. The matching is very simple so if you've put 'Comic Sans' instead of 'Comic Sans MS' it can still fail to fallback properly.
- When changing themes, it resets styles to Textadept's defaults to avoid spurious behaviours like current line backgrounds persisting on themes that don't have them.
- Since 12.7, Textadept supports arbitrary RGB colours in the terminal version, which means many GUI themes also work in terminals with true-colour support. The module will attempt to detect if a terminal has true-colour support and fallback to the default terminal theme if necessary.
- I've added [@kbarni's theme selector](https://github.com/orbitalquark/textadept/pull/690#issue-3996335774) too just for fun!
- Theme manager allows for per lexer theming, see the example usage.
- If using a GTK2 build, it attempts to detect if the system GTK theme is a dark one so it can apply your chosen dark theme. There is no mode changed support for GTK2 (but I don't think any GTK2 DEs had such capability anyway). NB: The check relies on `textadept-gtk` being in your PATH.

By default, Theme Manager uses Textadept's default themes and settings.
Example usage:

```lua
local theme_mgr = require('theme_mgr')
theme_mgr.theme.light = 'xed-light'
theme_mgr.theme.dark = 'ayu-evolve'
theme_mgr.theme.term = 'catppuccin-latte'
theme_mgr.font.family= 'Comic Sans MS'
theme_mgr.font.size = 14
theme_mgr.theme.python = 'xed-dark' -- Set a lexer specific theme
theme_mgr.theme.markdown = {'ayu-mirage', 'catppuccin-macchiato'}  -- Light then dark
-- theme_mgr() -- Call the module if you need themes set before events.INITIALIZED
```
By default, theme_mgr connects to `events.INITIALISED` to set your themes after your *init.lua* finishes, however if you're using a module that needs the themes set upfront (e.g. Textredux) you may call the module `theme_mgr()` to do it right away.
