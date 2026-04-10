-- Copyright 2016-2026 Mitchell. See LICENSE.
-- Copyright 2026 Jamie Drinkell. See LICENSE.
-- Extensions to the Export menu for PDFs and Markdown
-- ```lua
-- local export = require('export')
-- require('export_ext')
-- ```
-- @module export
local M = {}

--- Command used to open exported HTML files in the user's default web browser.
M.browser = WIN32 and 'start ""' or OSX and 'open' or LINUX and 'xdg-open'

function check(type)
	if not (buffer:get_lexer() == 'markdown' or buffer:get_lexer() == 'latex') then
		ui.statusbar_text = "Can't convert " .. buffer:get_lexer() .. ' to ' .. type .. '!'
		return false
	end
	return true
end

function M.markdown_to_html()
	if check('HTML') then
		-- Prompt the user for the HTML file to export to
		local filename = buffer.filename or ''
		local dir, name = filename:match('^(.-)[/\\]?([^/\\]-)%.?[^.]*$')
		local out_filename = ui.dialogs.save{
			title = _L['Save File'], dir = dir, file = name .. '.html'
		}
		if not out_filename then return end

		-- Check if a "markdown" command exists (Perl, Discount etc.)
		local htmlout
		local mdproc = os.spawn('markdown')
		if mdproc == nil then
			-- Fallback to bundled Lua implementation
			htmlout = require('export_ext/markdown')(buffer:get_text())
		else
			mdproc:write(buffer:get_text())
			mdproc:close()
			htmlout = mdproc:read('a')
		end
		io.open(out_filename, 'w'):write(htmlout):close()
		os.spawn(string.format('%s "%s"', M.browser, out_filename))
	end
end

function M.pandoc(type)
	if check(type:upper()) then
		-- Prompt the user for the file to export to
		local filename = buffer.filename or ''
		local dir, name = filename:match('^(.-)[/\\]?([^/\\]-)%.?[^.]*$')
		local out_filename = ui.dialogs.save{
			title = _L['Save File'], dir = dir, file = name .. '.' .. type
		}
		if not out_filename then return end

		local pandoc_str = 'pandoc '
		if type == 'html' then
			-- TODO: Apply some default CSS for tables?
			-- pandoc_str = pandoc_str
		elseif type == 'pdf' then
			pandoc_str = pandoc_str .. '-V geometry:margin=1.5cm'
		elseif type == 'odt' then
			pandoc_str = pandoc_str .. '--reference-doc ' .. _USERHOME ..
				(WIN32 and '\\modules\\export_ext\\reference.odt' or
					'/modules/export_ext/reference.odt')
		end
		pandoc_str = pandoc_str .. ' -s -o "' .. out_filename .. '" "' .. filename .. '"'
		os.remove('"' .. out_filename .. '"')
		os.execute(pandoc_str)
		os.execute(M.browser .. ' "' .. out_filename .. '"')
	end
end

-- Add a sub-menu.
_L['Convert Markdown to HTML...'] = 'Convert _Markdown to HTML...'
_L['Convert to PDF...'] = 'Convert to _PDF...'
local m_export = textadept.menu.menubar['File/Export']
table.insert(m_export, {_L['Convert Markdown to HTML...'], M.markdown_to_html})
table.insert(m_export, {_L['Pandoc to HTML...'], function() M.pandoc('html') end})
table.insert(m_export, {_L['Pandoc to ODT...'], function() M.pandoc('odt') end})
table.insert(m_export, {_L['Pandoc to PDF...'], function() M.pandoc('pdf') end})

return M
