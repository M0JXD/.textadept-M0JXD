-- Copyright 2026 Jamie Drinkell. MIT License.
-- buffer_statusbar_text string manipulation utilites

local M = {}

local spacing = CURSES and '  ' or '    '

function string.bst_count(str)
	local _, count = str:gsub(spacing, spacing)
	return count + 1
end

function string.bst_insert(str, ...)
	local text, pos, value
	local count = str:bst_count()

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

function string.bst_remove(str, pos)
	local text
	local entry_pat = '%S*%s?%S*' .. spacing
	local count = str:bst_count()
	pos = pos and pos or count + 1

	if pos <= 1 then
		text = str:gsub(entry_pat, '', 1)
	elseif pos >= count then
		entry_pat = spacing..'%S*%s?%S*$'
		text = str:gsub(entry_pat, '', 1)
	else
		local c = 0
		text = str:gsub(entry_pat, function (match)
			c = c + 1
			if c == pos then
				return ''
			end
			return match
		end)
	end
	return text
end

function string.bst_replace(str, pos, value)
	local text
	local entry_pat = '%S*%s?%S*' .. spacing
	local count = str:bst_count()

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

return M
