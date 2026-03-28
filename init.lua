-- Copyright 2025-2026 Jamie Drinkell. MIT License.

-- Themeing
local theme_mgr = require('theme_mgr')
theme_mgr.theme.light = 'ayu-light'
theme_mgr.theme.dark = 'ayu-evolve'
theme_mgr.theme.term = 'ayu-evolve'
theme_mgr.font.family = 'Noto Mono'
-- theme_mgr.font.family= 'FreeMono'
theme_mgr.font.size = 12
theme_mgr()

-- Modules (Official)
-- require('debugger')
require('export')
require('file_diff')
local format = require('format')
local function prettier_formatter()
	-- Most parsers are the same as the lexer name
	local parser = buffer:get_lexer()
	if parser == 'javascript' then parser = 'babel' end
	return format.config_file_contains('package.json', 'prettier') and 'npx prettier --parser ' ..
		parser or nil
end
format.commands.html = prettier_formatter
format.commands.css = prettier_formatter
format.commands.javascript = prettier_formatter
format.commands.typescript = prettier_formatter
format.commands.markdown = prettier_formatter
format.commands.yaml = prettier_formatter
format.commands.python = WIN32 and 'py' or 'python' .. ' -m black -'
local lsp = false
if not BSD then
	lsp = require('lsp')
	if QT then
		lsp.server_commands.dart = 'dart language-server'
		keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2]
	end
end
require('lua_repl')
keys[(CURSES and 'meta+O' or 'alt+O')] = require('open_file_mode')
-- require('scratch')
local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false
local update_notifier = require('update_notifier')
update_notifier.check_on_startup = true

-- Modules (M0JXD)
require('bfstatbar_utils')
require('distraction_free')
require('quick_open')
require('export_ext')
local ds = require('doc_stats')
ds.display.lines = true
local drpc = false
if not BSD then
	drpc = require('discord_rpc')
	drpc.private_mode = true
	drpc.init()
end

-- Modules (External)
-- require('textredux').hijack()
-- Experimental features by @Fwirt (requires custom build)
-- local textbar = require('textbar')
-- minimap = require('minimap')
-- keys['ctrl+@'] = function () minimap() end

-- Keybindings
if not CURSES then
	keys['ctrl+,'] = textadept.menu.menubar['Edit/Preferences'][2]
	keys['ctrl+K'] = function() buffer:line_delete() end
	keys['alt+up'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Up'][2]
	keys['alt+down'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Down'][2]
else
	keys['meta+,'] = textadept.menu.menubar['Edit/Preferences'][2]
	keys['ctrl+k'] = function() buffer:line_delete() end
	keys['meta+up'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Up'][2]
	keys['meta+down'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Down'][2]
end

-- Buffer/Language Settings
view.edge_column = 100
-- io.track_changes = true  -- This doesn't work?
lexer.detect_extensions.h = 'c'
lexer.detect_extensions.C = 'cpp'
lexer.detect_extensions.ino = 'arduino'
lexer.detect_extensions.njk = 'html'
lexer.detect_extensions.blp = 'blueprint'
textadept.editing.comment_string.c = '/* | */'
textadept.editing.comment_string.lua = '-- '
textadept.editing.comment_string.python = '# '
textadept.editing.comment_string.bash = '# '
textadept.editing.comment_string.cpp = '// '
textadept.editing.comment_string.dart = '// '
textadept.editing.comment_string.javascript = '// '
textadept.run.run_in_background = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
ui.find.highlight_all_matches = true
local lex_handler = 0
local auto_pairs = textadept.editing.auto_pairs
events.connect('SETTINGS_HANDLER', function(from)
	buffer.tab_width = 4
	buffer.use_tabs = false
	view.wrap_mode = view.WRAP_NONE
	textadept.editing.auto_pairs = auto_pairs
	textadept.editing.strip_trailing_spaces = true
	if format then format.on_save = false end
	ds.display.words = false
	ds.display.chars = false

	name = buffer:get_lexer()
	if name == 'makefile' or name == 'lua' then
		buffer.use_tabs = true
	elseif name == 'dart' then
		buffer.tab_width = 2
		if format then format.on_save = true end
	elseif name == 'text' or name == 'markdown' then
		view.wrap_mode = view.WRAP_WHITESPACE
		textadept.editing.auto_pairs = nil
		textadept.editing.strip_trailing_spaces = false
		ds.display.chars = 3
		ds.display.words = 3
	end

	-- We need to run lexer loaded handlers again now everything is set
	if from == 'LEXER_LOADED' then
		if lex_handler == 1 then
			events.emit(events.LEXER_LOADED)
		else
			lex_handler = 0
		end
	elseif from == 'SWITCH' then
		lex_handler = 1
		events.emit(events.LEXER_LOADED)
	end
end)
events.connect(events.LEXER_LOADED, function()
	lex_handler = lex_handler + 1;
	events.emit('SETTINGS_HANDLER', 'LEXER_LOADED')
end)
events.connect(events.BUFFER_AFTER_SWITCH, function() events.emit('SETTINGS_HANDLER', 'SWITCH') end)
events.connect(events.VIEW_AFTER_SWITCH, function() events.emit('SETTINGS_HANDLER', 'SWITCH') end)

-- Tools
textadept.run.build_commands['CMakeLists.txt'] = 'cmake --build build'
textadept.run.build_commands['xmake.lua'] = 'xmake'
textadept.run.compile_commands.python = (WIN32 and 'py' or 'python') .. ' -m flake8 %f' -- Run a linter
textadept.run.compile_commands.ino = 'arduino-cli compile -b arduino:avr:nano "%p"' -- Verify
textadept.run.run_commands.ino = 'arduino-cli upload "%p" -b arduino:avr:nano -p /dev/ttyACM0' -- Upload

-- Extra Utilities
_L['Rename'] = '_Rename'
table.insert(textadept.menu.menubar[_L['File']], 8, {
	_L['Rename'], function()
		local oldname = buffer.filename
		buffer:save_as()
		os.remove(oldname)
	end
})

-- Pandoc conversions are weird so this is handy
_L['Delete Blank Lines'] = 'Delete Blank _Lines'
table.insert(textadept.menu.menubar[_L['Edit']], 11, {
	_L['Delete Blank Lines'], function()
		local i = 1
		while i < buffer.line_count do
			local line = buffer:get_line(i)
			if line:match("^%s*$") then
				buffer:goto_line(i)
				buffer:line_delete()
			else
				i = i + 1
			end
		end
	end
})

local tools = textadept.menu.menubar[_L['Tools']]
_L['Reset Lua State'] = 'Reset L_ua State'
tools[#tools + 1] = {''}
tools[#tools + 1] = {_L['Reset Lua State'], reset}

_L['Toggle Line Guide'] = 'Toggle _Line Guide'
table.insert(textadept.menu.menubar[_L['View']], 18, {
	_L['Toggle Line Guide'], function()
		view.edge_mode = view.edge_mode == view.EDGE_LINE and view.EDGE_NONE or view.EDGE_LINE
	end
})

_L['Toggle Strip Trailing Whitespace'] = 'Toggle Strip _Trailing Whitespace'
table.insert(textadept.menu.menubar[_L['View']], 19, {
	_L['Toggle Strip Trailing Whitespace'], function()
		textadept.editing.strip_trailing_spaces = not textadept.editing.strip_trailing_spaces
		events.emit(events.UPDATE_UI, 3)
	end
})

-- UI Adjustments
events.connect(events.UPDATE_UI, function(updated)
	if not updated or updated & 3 == 0 then return end
	local strip = 'Strip: ' .. (textadept.editing.strip_trailing_spaces and 'On' or 'Off')
	ui.buffer_statusbar_text = ui.buffer_statusbar_text:bst_insert(
		ui.buffer_statusbar_text:bst_count() - 1, strip)
end)

-- Hide some folders from the quick open list
table.insert(lfs.default_filter, '!.xmake')
table.insert(lfs.default_filter, '!build_dir')
table.insert(lfs.default_filter, '!build')
table.insert(lfs.default_filter, '!assets')
table.insert(lfs.default_filter, '!.vs')
table.insert(lfs.default_filter, '!.vscode')

-- Platform Specific Adjustments
if CURSES then
	-- Add a suspend menu entry
	table.insert(textadept.menu.menubar[_L['View']], {'Suspend...', ui.suspend})
elseif WIN32 then
	-- Disable due to weird UK keyboard
	keys['ctrl+alt+|'] = nil
elseif GTK then
	-- Dirty fix for X11 focus
	local function get_display_names(buffer)
		local filename = buffer.filename or buffer._type or _L['Untitled']
		if buffer.filename then
			filename = select(2, pcall(string.iconv, filename, 'UTF-8', _CHARSET))
		end
		return filename, buffer.filename and filename:match('[^/\\]+$') or filename
	end

	events.connect(events.INITIALIZED, function()
		local filename, basename = get_display_names(buffer)
		local title = string.format('%s %s Textadept (%s)', basename, buffer.modify and '*' or '-',
			filename)
		os.execute('wmctrl -a "' .. title .. '"')
	end)
end
