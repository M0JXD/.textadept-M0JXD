-- MIT License (this is 90% copy and paste of Mitchell's internal Textadept code)
-- Module to easily prepend or append the buffer_statusbar_text

M = {}
M.default_buff_statbar = ''
M.prependable_buff_statbar = ''
M.appendable_buff_statbar = ''
M.bothendable_buff_statbar = ''

events.connect(events.UPDATE_UI, function(updated)
	if not updated or updated & (buffer.UPDATE_CONTENT | buffer.UPDATE_SELECTION) == 0 then return end
	local text = not CURSES and '%s %d/%d    %s %d    %s    %s    %s    %s' or
		'%s %d/%d  %s %d  %s  %s  %s  %s'
	local selRow = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	local pos = buffer.current_pos
	local line, max = buffer:line_from_position(pos), buffer.line_count
	local col = buffer.column[pos] + buffer.selection_n_caret_virtual_space[buffer.main_selection]
	local lang = buffer.lexer_language
	local eol = buffer.eol_mode == buffer.EOL_CRLF and _L['CRLF'] or _L['LF']
	local tabs = string.format('%s %d', buffer.use_tabs and _L['Tabs:'] or _L['Spaces:'],
		buffer.tab_width)
	local encoding = buffer.encoding or ''
	M.default_buff_statbar = string.format(text, _L['Line:'], line, max,
										   _L['Col:'], col, lang, eol, tabs, encoding)

	if CURSES then
		M.prependable_buff_statbar = '  ' .. M.default_buff_statbar
		M.appendable_buff_statbar = M.default_buff_statbar .. '  '
		M.bothendable_buff_statbar = '  ' .. M.default_buff_statbar .. '  '
	else
		M.prependable_buff_statbar = '    ' .. M.default_buff_statbar
		M.appendable_buff_statbar = M.default_buff_statbar .. '    '
		M.bothendable_buff_statbar = '    ' .. M.default_buff_statbar .. '    '
	end
end)

return M
