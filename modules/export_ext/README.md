## Export Extensions Module

This module extends the Export module's functionality by adding the ability to render Markdown to plain HTML, or calling Pandoc to convert the current document.
For it to work right it must be added after the official Export module.

```lua
local export = require('export')  -- Official Module
require('export_ext')
```

Markdown to HTML conversion checks to see if your system has a `markdown` command, such as Discount or the original Perl implementation, and falls back on the bundled *markdown.lua* from LDoc if not.
