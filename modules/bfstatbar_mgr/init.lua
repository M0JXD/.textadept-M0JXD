-- Copyright 2026 Jamie Drinkell. MIT License.
-- Idea regarding a bufferstatusbar method for Textadept.

local M = {}

-- Default entries

-- Current line and amount
table.insert(M, { title = _L['Line:'], function ()
	local pos = buffer.current_pos
	local line, max = buffer:line_from_position(pos), buffer.line_count
	local str = line .. '/' .. max
	return str
end})

-- Current column
table.insert(M, { title = _L['Col:'], function ()
	return buffer.column[pos] + buffer.selection_n_caret_virtual_space[buffer.main_selection]
end})

-- Language
table.insert(M, { function () return buffer.lexer_language end})

-- EOL
table.insert(M, { function ()
					return buffer.eol_mode == buffer.EOL_CRLF and _L['CRLF'] or _L['LF'] end})

-- Tabs
table.insert(M, { title = function () return buffer.use_tabs and _L['Tabs:'] or _L['Spaces:'] end,
					function () return buffer.tab_width end})

-- Encoding
table.insert(M, { function () return buffer.encoding or '' end})

events.connect(events.UPDATE_UI, function (updated)
--	if not updated or updated & ui.CONTENT_OR_SELECTION == 0 then return end
	local spacing = CURSES and '  ' or '    '
	local text = ''

	for i,v in ipairs(M) do
		text = spacing .. text
		if (M[i].title) then
--			text = text .. ' ' .. (M[i].title)
		end
--		text = text .. ' ' .. (M[i][#M[i]])
	end
	ui.buffer_statusbar_text = text
end)

return M
