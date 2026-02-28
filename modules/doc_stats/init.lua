-- Copyright 2025-2026 Jamie Drinkell. MIT License.
-- Simple document statistics module, providing additional details about the buffer and selections.

local M = {}

M.display = {
	menu = true,
	words = false,
	bytes = false,
	lines = false,  -- Replaces the line entry
	rows = false,
	chars = false,
	chars_ns = false,  -- No Spaces
	chars_nl = false   -- No Lines
}

-- Separators for the Word Count Algo
M.separators = {
	--'@',
	--'[',
	--']',
	--'}',
	--'{',
	--'(',
	--')',
	--'/',
	--'\\',
	--';',
	--':',
	--'-',
	--'.',
	--',',
	--'"',
	--"'",
	--'*',
	--'?',
	--'!',
	--'\f',
	'\t',
	'\n',
	'\r',
	' '
}

-- Constants for count_chars()
M.ALL_SPACES = 0
M.DISCARD_SPACES = 1
M.DISCARD_NEWLINES = 2

function M.count_rows()
	local sel_row = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	return buffer.selection_empty and 0 or sel_row
end

-- TODO: When there is no selection, have these return the value for the current line.

-- Algo adapted from https://www.countofwords.com/word-count-algorithms-and-how-you-can-use-them.html
local function checkMatchesSeparator(c)
	for _,v in ipairs(M.separators) do
		if (c == v) then
			return true
		end
	end
	return false
end

function M.count_words(all)
	local state = true
	local count = 0
	local contents = all and buffer:get_text() or buffer:get_sel_text()

	for i = 1, #contents do
		local c = contents:sub(i,i)
		if checkMatchesSeparator(c) then
			state = true
		elseif state then
			state = false
			count = count + 1
		end
	end
	return count
end

function M.count_bytes(all)
	local contents = all and buffer:get_text() or buffer:get_sel_text()
	return #contents
end

function M.count_spaces(all)
	local amount = 0
	local contents = all and buffer:get_text() or buffer.selection_empty and 0 or buffer:get_sel_text()
	if contents == 0 then return 0 end

	for i = 1, #contents do
		local c = contents:sub(i,i)
		if c == ' ' or c == '\t' or c == '\r' or c == '\n' then
			amount = amount + 1
		end
	end
	return amount
end

function M.count_newline(all)
	local amount = 0
	local contents = all and buffer:get_text() or buffer.selection_empty and 0 or buffer:get_sel_text()
	if contents == 0 then return 0 end

	if buffer.eol_mode == buffer.EOL_LF or buffer.eol_mode == buffer.EOL_CRLF then
		for i = 1, #contents do
			local c = contents:sub(i,i)
			if c == '\n' then
				amount = amount + 1
			end
		end
	end

	if buffer.eol_mode == buffer.EOL_CR or buffer.eol_mode == buffer.EOL_CRLF then
		for i = 1, #contents do
			local c = contents:sub(i,i)
			if c == '\r' then
				amount = amount + 1
			end
		end
	end
	return amount
end

function M.count_chars(spaces, all)
	local start_pos = all and 0 or buffer.selection_empty and 0 or buffer.selection_start
	local end_pos = all and buffer.line_end_position[buffer.line_count] or buffer.selection_empty and 0 or buffer.selection_end
	-- Textadept doth provide
	local amount = buffer:count_characters(start_pos, end_pos)
	if spaces == M.DISCARD_SPACES then
		amount = amount - M.count_spaces(all)
	elseif spaces == M.DISCARD_NEWLINES then
		amount = amount - M.count_newline(all)
	end
	return amount
end

local function stats_dialog()
	ui.dialogs.message{
		title = 'Document Statistics',
		text = 	'Details are shown as "Selected/Total":\n\n' ..
		'Rows:  ' .. (M.count_rows() or 0) .. '/' .. buffer.line_count .. '\n' ..
		'Words:  ' .. (M.count_words(false) or 0) .. '/' .. (M.count_words(true) or 0) .. '\n' ..
		'Bytes:  ' .. (M.count_bytes(false) or 0) .. '/' .. (M.count_bytes(true) or 0) .. '\n' ..
		'Characters (inc. spaces):  ' .. (M.count_chars(M.ALL_SPACES, false) or 0) .. '/' .. (M.count_chars(M.ALL_SPACES, true) or 0) .. '\n' ..
		'Characters (No spaces):  ' .. (M.count_chars(M.DISCARD_SPACES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_SPACES, true) or 0)  .. '\n' ..
		'Characters (No newlines):  ' .. (M.count_chars(M.DISCARD_NEWLINES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_NEWLINES, true) or 0)
	}
end

-- Insert into tools menu (code adapted from spellcheck module)
if M.display.menu then
	_L['Document Statistics'] = '_Document Statistics'
	doc_stats_menu = { _L['Document Statistics'], stats_dialog }
	local m_tools = textadept.menu.menubar['Tools']
	local found_area
	local SEP = {''}
	for i = 1, #m_tools - 1 do
		if not found_area and m_tools[i + 1].title == _L['Bookmarks'] then
			found_area = true
		elseif found_area then
			local label = m_tools[i].title or m_tools[i][1]
			if 'Document Statistics' < label:gsub('^_', '') or m_tools[i][1] == '' then
				table.insert(m_tools, i, doc_stats_menu)
				break
			end
		end
	end
end

function string.bst_insert(str, ...)
	local text, pos, value
	local spacing = CURSES and '  ' or '    '
	local _, count = str:gsub(spacing, spacing)
	count = count + 1

	local arg = table.pack(...)
	if arg.n == 1 then
		pos = count + 1
		value = arg[1]
	elseif arg.n == 2 then
		pos = arg[1]
		value = arg[2]
	end

	if pos <= 1 then
		text = value .. spacing .. str
	elseif pos >= (count + 1) then
		text = str .. spacing .. value
	else
		local c = 0
		text, count = str:gsub(spacing, function (match)
			c = c + 1
			if c == pos - 1 then
				return match .. value .. match
			end
			return match
		end)
	end
	return text
end

function string.bst_replace(str, pos, value)
	local text
	local spacing = CURSES and '  ' or '    '
	local entry_pat = '%S*%s?%S*' .. spacing
	local _, count = str:gsub(spacing, spacing)
	count = count + 1

	if pos >= count then
		entry_pat = spacing..'%S*%s?%S*$'
		text = str:gsub(entry_pat, spacing .. value, 1)
	else
		pos = pos <= 1 and 1 or pos
		local c = 0
		text = str:gsub(entry_pat, function (match)
			c = c + 1
			if c == pos then
				return value .. spacing
			end
			return match
		end)
	end
	return text
end


-- TODO: Optimise this by running the checks on a buffer switch, and then connect/disconnect the UPDATE_UI event
events.connect(events.UPDATE_UI, function (updated)
	if not updated or updated & 3 == 0 then return end
	local bst_text = ui.buffer_statusbar_text
	if M.display.lines then
		local rows = M.count_rows()
		rows = 'Lines: ' .. (rows > 0 and rows or buffer:line_from_position(buffer.current_pos)) .. '/' .. buffer.line_count
		bst_text = bst_text:bst_replace(1, rows)
	end

	if M.display.rows then
		bst_text = bst_text:bst_insert(type(M.display.rows) == 'boolean' and 3 or M.display.rows,
			'Rows: ' .. (M.count_rows() or 0))
	end

	if M.display.words then
		bst_text = bst_text:bst_insert(type(M.display.words) == 'boolean' and 1 or M.display.words,
			'Words: ' .. (M.count_words(false) or 0) .. '/' .. (M.count_words(true) or 0))
	end

	if M.display.chars_nl then
		bst_text = bst_text:bst_insert(type(M.display.chars_nl) == 'boolean' and 1 or M.display.chars_nl,
			'Chars (NL): ' .. (M.count_chars(M.DISCARD_NEWLINES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_NEWLINES, true) or 0))
	end

	if M.display.chars_ns then
		bst_text = bst_text:bst_insert(type(M.display.chars_ns) == 'boolean' and 1 or M.display.chars_ns,
			'Chars (NS): ' .. (M.count_chars(M.DISCARD_SPACES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_SPACES, true) or 0))
	end

	if M.display.chars then
		bst_text = bst_text:bst_insert(type(M.display.chars) == 'boolean' and 1 or M.display.chars,
			'Chars: ' .. (M.count_chars(M.ALL_SPACES, false) or 0) .. '/' .. (M.count_chars(M.ALL_SPACES, true) or 0))
	end

	if M.display.bytes then
		bst_text = bst_text:bst_insert(type(M.display.bytes) == 'boolean' and 1 or M.display.bytes,
			'Bytes: ' .. (M.count_bytes(false) or 0) .. '/' .. (M.count_bytes(true) or 0))
	end
	ui.buffer_statusbar_text = bst_text
end)

return M
