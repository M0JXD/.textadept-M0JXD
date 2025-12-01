-- Copyright 2025 Jamie Drinkell. MIT License.
-- Simple document statistics module, showing word count and selection characteristics

local M = {}

_L['Document Statistics'] = '_Document Statistics'
_L['Count Rows'] = 'Count _Rows'
_L['Count Words'] = 'Count _Words'

-- Selected Rows Tool
local function count_rows()
	local sel_row = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	return sel_row
end

local function count_rows_dialog()
	local sel_row = count_rows()
	str = sel_row > 1 and ' rows.' or ' row.'
	ui.dialogs.message{
		title = 'Rows Selected', text = 'Current selection is '..sel_row..str
	}
end

-- Count blank lines for word count
local function count_blank_lines(start_pos, end_pos)
	local blank_lines = 0
	buffer:goto_pos(start_pos)

	repeat
		if (buffer:line_length(buffer:line_from_position(buffer.current_pos)) == 1) then
			blank_lines = blank_lines + 1
		end
		buffer:line_down()
	until (buffer.current_pos == end_pos + 1)
	return blank_lines
end

-- Primitive word count
local function count_words(start_pos, end_pos)
	-- The only delimiter should be spaces
	local old_word_char = buffer.word_chars
	buffer.word_chars = buffer.word_chars .. '@[]{}.,-()/":;?!*\n\f'
	local current_pos = buffer.current_pos

	buffer:goto_pos(start_pos)
	local word_count = 0
	repeat
		buffer:word_right_end()
		word_count = word_count + 1
	until (buffer.current_pos == buffer.length + 1)

	word_count = word_count + (end_pos) - 2
	word_count = word_count - count_blank_lines(start_pos, end_pos)

	buffer:goto_pos(current_pos)
	buffer.word_chars = old_word_char
	return word_count
end

local function count_words_dialog()
	-- if there's no selection run without
	local word_count = count_words(0, buffer.length)
	ui.dialogs.message {
		title = 'Word Count', text = 'Word Count is '..word_count
	}
end

doc_stats_menu = {
	title = _L['Document Statistics'],
	{_L['Count Rows'],  count_rows_dialog},
	{_L['Count Words'], count_words_dialog}
}


-- Insert into tools menu (code adapted from spellcheck module)
--table.insert(textadept.menu.menubar[_L['Tools']], 20, doc_stats_menu)
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
