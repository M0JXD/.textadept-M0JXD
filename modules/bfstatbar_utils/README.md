# Buffer Statusbar Utilites Module

Buffer Statusbar Utilties is the very short awaited replacement for both bfstatbar_helper that was [removed](https://github.com/M0JXD/.textadept-M0JXD/commit/f97274743940cbb4150a379c7e6c2b7cf7a7536d)
and the [table idea introduced in Textadept's Discussions](https://github.com/orbitalquark/textadept/discussions/688).

It introduces some additional string functions to manage the buffer_statusbar more easily.

Example usage:

```lua
require('bfstatbar_utils')

-- Remove Line Endings from being displayed
events.connect(events.UPDATE_UI, function (updated)
	if not updated or updated & 3 == 0 then return end
	ui.buffer_statusbar_text = ui.buffer_statusbar_text:bst_remove(4)
end)

-- Display whether strip trailing whitespace is on
events.connect(events.UPDATE_UI, function (updated)
	if not updated or updated & 3 == 0 then return end
	local strip = 'Strip: ' .. (textadept.editing.strip_trailing_spaces and 'On' or 'Off')
	ui.buffer_statusbar_text = ui.buffer_statusbar_text:bst_insert(5, strip)
end)
```
