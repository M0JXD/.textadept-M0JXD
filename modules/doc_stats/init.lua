-- Copyright 2025-2026 Jamie Drinkell. MIT License.
-- Simple document statistics module, showing word count and selection characteristics

local M = {}

M.menu_entry = true
M.display_words = false
M.display_bytes = false
M.display_rows = false
M.display_chars = false
M.display_chars_ns = false
M.display_chars_nl = false

M.ALL_SPACES = 0
M.DISCARD_SPACES = 1
M.DISCARD_NEWLINES = 2

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

-- Algo adapted from https://www.countofwords.com/word-count-algorithms-and-how-you-can-use-them.html
local function checkMatchesSeparator(c)
	for i,v in ipairs(M.separators) do
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

-- Selected Rows
function M.count_rows()
	local sel_row = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	return buffer.selection_empty and 0 or sel_row
end

-- Bytes (not strictly the same as characters)
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
--table.insert(textadept.menu.menubar[_L['Tools']], 20, doc_stats_menu)

if M.menu_entry then
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

-- This depends on bfstatbar_mgr to be used as bfstatbar
events.connect(events.INITIALIZED, function ()

	if M.display_rows then
		table.insert(bfstatbar, type(M.display_rows) == 'boolean' and 3 or M.display_rows, function ()
			return 'Rows: ' .. (M.count_rows() or 0)
		end)
	end

	if M.display_words then
		table.insert(bfstatbar, type(M.display_words) == 'boolean' and 1 or M.display_words, function ()
			return 'Words: ' .. (M.count_words(false) or 0) .. '/' .. (M.count_words(true) or 0)
		end)
	end

	if M.display_chars_nl then
		table.insert(bfstatbar, type(M.display_chars_nl) == 'boolean' and 1 or M.display_chars_nl, function ()
			return 'Chars (NL): ' .. (M.count_chars(M.DISCARD_NEWLINES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_NEWLINES, true) or 0)
		end)
	end

	if M.display_chars_ns then
		table.insert(bfstatbar, type(M.display_chars_ns) == 'boolean' and 1 or M.display_chars_ns, function ()
			return 'Chars (NS): ' .. (M.count_chars(M.DISCARD_SPACES, false) or 0) .. '/' .. (M.count_chars(M.DISCARD_SPACES, true) or 0)
		end)
	end

	if M.display_chars then
		table.insert(bfstatbar, type(M.display_chars) == 'boolean' and 1 or M.display_chars, function ()
			return 'Chars: ' .. (M.count_chars(M.ALL_SPACES, false) or 0) .. '/' .. (M.count_chars(M.ALL_SPACES, true) or 0)
		end)
	end

	if M.display_bytes then
		table.insert(bfstatbar, type(M.display_bytes) == 'boolean' and 1 or M.display_bytes, function ()
			return 'Bytes: ' .. (M.count_bytes(false) or 0) .. '/' .. (M.count_bytes(true) or 0)
		end)
	end
end)

return M
