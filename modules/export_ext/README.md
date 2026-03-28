## Export Extensions Module

This module extends the Export module's functionality by adding the ability to render Markdown to plain HTML, or Markdown/LaTeX to PDF.
For it to work right it must be added after the official Export module.

Exporting to PDF uses Pandoc, so it must be installed!

```lua
local export = require('export')  -- Official Module
require('export_ext')
```
