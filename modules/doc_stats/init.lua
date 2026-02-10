-- Copyright 2025 Jamie Drinkell. MIT License.
-- Simple document statistics module, showing word count and selection characteristics

local M = {}

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
	for i, v in ipairs(M.separators) do
		if (c == v) then
			return true
		end
	end
	return false
end

local function count_words_selection()
	local state = true
	local count = 0
	local contents = buffer:get_sel_text()

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

local function count_words_all()
	local state = true
	local count = 0
	local contents = buffer:get_text()

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
local function count_rows()
	local sel_row = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	return sel_row
end

local function stats_dialog()
	ui.dialogs.message{
		title = 'Document Statistics',
		text = 	'Stats are shown as "Selected/Total".\n' ..
				'Word Count: ' .. (count_words_selection() or 0) .. '/' .. (count_words_all() or 0) .. '\n' ..
				'Row Count: ' .. (count_rows() or 0) .. '/' .. buffer.line_count
	}
end

-- Insert into tools menu (code adapted from spellcheck module)
--table.insert(textadept.menu.menubar[_L['Tools']], 20, doc_stats_menu)
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

return M
