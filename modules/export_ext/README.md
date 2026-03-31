## Export Extensions Module

This module extends the Export module's functionality by adding the ability to render Markdown to plain HTML, or calling Pandoc to convert the current document.
For it to work right it must be added after the official Export module.

```lua
local export = require('export')  -- Official Module
require('export_ext')
```
