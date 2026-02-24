-- Copyright 2026 Jamie Drinkell. MIT License.
-- Idea regarding a buffer_statusbar table for Textadept.

local M = {}

M.spacing = CURSES and '  ' or '    '

-- Default entries
-- Current line and amount
table.insert(M, function ()
	local line, max = buffer:line_from_position(buffer.current_pos), buffer.line_count
	return _L['Line:'] .. ' ' .. line .. '/' .. max
end)

-- Current column
table.insert(M, function ()
	return _L['Col:'] .. ' ' ..
	(buffer.column[buffer.current_pos] + buffer.selection_n_caret_virtual_space[buffer.main_selection])
end)

-- Language
table.insert(M, function () return buffer.lexer_language end)

-- EOL
table.insert(M, function ()
	return buffer.eol_mode == buffer.EOL_CRLF and _L['CRLF'] or _L['LF']
end)

-- Tabs
table.insert(M, function ()
	return (buffer.use_tabs and _L['Tabs:'] or _L['Spaces:']) .. ' ' .. buffer.tab_width
end)

-- Encoding
table.insert(M, function () return buffer.encoding or '' end)

events.connect(events.UPDATE_UI, function (updated)
	--if not updated or updated & (buffer.UPDATE_CONTENT or buffer.UPDATE_SELECTION) == 0 then return end
	local text = ''
	for i,v in ipairs(M) do
		if text ~= '' then
			text = text .. M.spacing
		end
		text = text .. (v())
	end
	ui.buffer_statusbar_text = text
end)

return M
