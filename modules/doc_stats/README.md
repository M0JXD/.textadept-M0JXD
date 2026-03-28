## Document Statistics Module

Document Statistics is inspired by the plugin of the same name in the Xed editor and the Summary feature in Notepad++.
It will add a menu under Tools which will show a dialog with statistics for the current selection and the whole document.

You can also optionally add these details in the buffer status bar with the `doc_stats.display` table.
Set each field as true to use the default placement or use a number to insert it to a position of your choice.

Note the field called `doc_stats.display.lines` will replace Textadept's line counter so that it shows the amount of lines when a selection exists, but is otherwise the same when there is no selection.

The internal utilities functions are exposed, e.g. you may call `doc_stats.count_words(false)` to get the words for the current selection (true would get the whole document). They work on the currently active buffer.

The word count feature is based on https://www.countofwords.com/word-count-algorithms-and-how-you-can-use-them.html
The separators are configurable in the doc_stats.separators array. By default, it only matches whitespace, which provides the same results as MS Office.

Example usage:

```lua
doc_stats = require('doc_stats')
doc_stats.display.menu = false
doc_stats.display.lines = true
doc_stats.display.words = true
doc_stats.display.bytes = true
doc_stats.display.chars = 5
doc_stats.display.chars_ns = 1

local all_spaces = doc_stats.count_spaces(true)
```
