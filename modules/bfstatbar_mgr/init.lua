-- Copyright 2026 Jamie Drinkell. MIT License.
-- Idea regarding a buffer_statusbar table for Textadept.

local M = {}

-- Default entries

-- Current line and amount
table.insert(M, function ()
	local line, max = buffer:line_from_position(buffer.current_pos), buffer.line_count
	return _L['Line: '] .. line .. '/' .. max
end)

-- Current column
table.insert(M, function ()
	return _L['Col: '] .. (buffer.column[buffer.current_pos] +
							buffer.selection_n_caret_virtual_space[buffer.main_selection])
end)

-- Language
table.insert(M, function () return buffer.lexer_language end)

-- EOL
table.insert(M, function ()
				return buffer.eol_mode == buffer.EOL_CRLF and _L['CRLF'] or _L['LF'] end)

-- Tabs
table.insert(M, function ()
	return (buffer.use_tabs and _L['Tabs: '] or _L['Spaces: ']) .. buffer.tab_width
end)

-- Encoding
table.insert(M, function () return buffer.encoding or '' end)

events.connect(events.UPDATE_UI, function (updated)
	--if not updated or updated & (buffer.UPDATE_CONTENT or buffer.UPDATE_SELECTION) == 0 then return end
	local text = ''
	local spacing = CURSES and '  ' or '    '

	for i,v in ipairs(M) do
		text = text .. spacing
		val = M[i]()
		text = text .. ' ' .. val
	end
	ui.buffer_statusbar_text = text
end)

return M

-- Example use

--bfstatbar = require('bfstatbar_mgr')
--
--table.remove(bfstatbar, 4)  -- Remove line endings
--
--table.insert(bfstatbar, 5, function ()
--	return 'Strip: ' .. (textadept.editing.strip_trailing_spaces and "On" or "Off")
--end)
--
--_L['Toggle Strip Trailing Whitespace'] = 'Toggle Strip _Trailing Whitespace'
--table.insert(textadept.menu.menubar[_L['View']], 19, {_L['Toggle Strip Trailing Whitespace'], function ()
--	textadept.editing.strip_trailing_spaces = not textadept.editing.strip_trailing_spaces
--	events.emit(events.UPDATE_UI)
--end})
