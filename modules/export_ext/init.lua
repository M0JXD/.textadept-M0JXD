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

function M.markdown_to_html()
	if buffer:get_lexer() == 'markdown' then
		-- Prompt the user for the HTML file to export to, if necessary.
		filename = filename or buffer.filename or ''
		local dir, name = filename:match('^(.-)[/\\]?([^/\\]-)%.?[^.]*$')
		local out_filename = ui.dialogs.save{title = _L['Save File'], dir = dir, file = name .. '.html'}
		if not out_filename then return end
		local htmlout = require('export_ext/markdown')(buffer:get_text())
		io.open(out_filename, 'w'):write(htmlout):close()
		os.spawn(string.format('%s "%s"', M.browser, out_filename))
	else
		ui.statusbar_text = 'Not a Markdown file!'
	end
end

function M.to_pdf()
	local lex = buffer:get_lexer()
	local file = '"' .. buffer.filename .. '"'
	if not (lex == 'markdown' or lex == 'latex') then
		ui.statusbar_text = "Can't convert " .. buffer:get_lexer() .. ' to PDF!'
		return
	end

	-- Prompt the user for the PDF file to export to, if necessary.
	filename = filename or buffer.filename or ''
	local dir, name = filename:match('^(.-)[/\\]?([^/\\]-)%.?[^.]*$')
	local out_filename = ui.dialogs.save{title = _L['Save File'], dir = dir, file = name .. '.pdf'}
	if not out_filename then return end
	os.remove('"'.. out_filename .. '"')
	os.execute(
		'pandoc --pdf-engine=xelatex -V geometry:margin=1.5cm -V mainfont="DejaVu Sans" -s -o "' ..
			out_filename .. '" ' .. file)
	os.execute(M.browser .. ' "' .. out_filename .. '"')
end

-- Add a sub-menu.
_L['Export Markdown to HTML...'] = 'Export _Markdown to HTML...'
_L['Export to PDF...'] = 'Export to _PDF...'
local m_export = textadept.menu.menubar['File/Export']
table.insert(m_export, {_L['Export Markdown to HTML...'], M.markdown_to_html})
table.insert(m_export, {_L['Export to PDF...'], M.to_pdf})

return M
