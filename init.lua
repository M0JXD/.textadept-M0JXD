-- Copyright 2025-2026 Jamie Drinkell. MIT License.

-- Themeing
local theme_mgr = require('theme_mgr')
theme_mgr.theme.light = 'ayu-light'
theme_mgr.theme.dark = 'ayu-evolve'
theme_mgr.theme.term = 'ayu-evolve'
theme_mgr.font.family= 'Noto Mono'
--theme_mgr.font.family= 'FreeMono'
theme_mgr.font.size = 14
theme_mgr()
view.edge_column = 100

-- Modules (M0JXD)
require('bfstatbar_utils')
require('distraction_free')
require('quick_open')
ds = require('doc_stats')
ds.display.words = true
ds.display.lines = true

if not BSD then
	drpc = require('discord_rpc')
	drpc.private_mode = true
	drpc.init()
end

-- Modules (Official)
--require('debugger')
--require('export')
require('file_diff')

if not BSD then
	formatter = require('format')  -- format makes updater crash?
	local lsp = require('lsp')
	if QT then
		lsp.server_commands.dart = 'dart language-server'
		keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2]
	end
end
require('lua_repl')
keys[(CURSES and 'meta+O' or 'alt+O')] = require('open_file_mode')
--require('scratch')
local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false
local update_notifier = require('update_notifier')
update_notifier.check_on_startup = true

-- Modules (external)
--require('textredux').hijack()
-- Experimental features by @Fwirt (requires custom build)
--local textbar = require('textbar')
--minimap = require('minimap')
--keys['ctrl+@'] = function () minimap() end

-- Hide some folders from the quick open list
table.insert(lfs.default_filter, '!.xmake')
table.insert(lfs.default_filter, '!build_dir')
table.insert(lfs.default_filter, '!build')
table.insert(lfs.default_filter, '!assets')
table.insert(lfs.default_filter, '!.vs')
table.insert(lfs.default_filter, '!.vscode')

-- Match some VSCode bindings
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
lexer.detect_extensions.h = 'c'
lexer.detect_extensions.C = 'cpp'
lexer.detect_extensions.H = 'cpp'
lexer.detect_extensions.ino = 'cpp'
lexer.detect_extensions.njk = 'html'
lexer.detect_extensions.blp = 'blueprint'
textadept.editing.comment_string.c = '/*|*/'
-- Default settings
--ui.find.highlight_all_matches = true
textadept.run.run_in_background = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
local place = 0
local auto_pairs = textadept.editing.auto_pairs
events.connect('UPDATE_HANDLER', function (from)
	buffer.tab_width = 4
	buffer.use_tabs = false
	view.wrap_mode = view.WRAP_NONE
	textadept.editing.auto_pairs = auto_pairs
	textadept.editing.strip_trailing_spaces = true
	if formatter then formatter.on_save = true end

    name = buffer:get_lexer()
	if name == 'makefile' or name == 'lua' then
		buffer.use_tabs = true
	elseif name == 'dart' then
		buffer.tab_width = 2
		if formatter then formatter.on_save = true end
	elseif name == 'text' or name == 'markdown' then
		view.wrap_mode = view.WRAP_WHITESPACE
		textadept.editing.auto_pairs = nil
		textadept.editing.strip_trailing_spaces = false
	end

	-- We need to run lexer loaded handlers again now everything is set
	if from == 'LEXER_LOADED' then
		if place == 1 then
			events.emit(events.LEXER_LOADED)
		else
			place = 0
		end
	elseif from == 'BUFFER_SWITCH' then
		place = 1
		events.emit(events.LEXER_LOADED)
	end
end)
events.connect(events.LEXER_LOADED, function () place = place + 1 ; events.emit('UPDATE_HANDLER', 'LEXER_LOADED') end)
events.connect(events.BUFFER_AFTER_SWITCH, function () events.emit('UPDATE_HANDLER', 'BUFFER_SWITCH') end)

textadept.run.build_commands['CMakeLists.txt'] = 'cmake --build build'
textadept.run.build_commands['xmake.lua'] = 'xmake'

-- Extra Utilities
_L['Toggle Line Guide'] = 'Toggle _Line Guide'
table.insert(textadept.menu.menubar[_L['View']], 18, {_L['Toggle Line Guide'], function ()
	view.edge_mode = view.edge_mode == view.EDGE_LINE and view.EDGE_NONE or view.EDGE_LINE
end})

_L['Toggle Strip Trailing Whitespace'] = 'Toggle Strip _Trailing Whitespace'
table.insert(textadept.menu.menubar[_L['View']], 19, {_L['Toggle Strip Trailing Whitespace'], function ()
	textadept.editing.strip_trailing_spaces = not textadept.editing.strip_trailing_spaces
	events.emit(events.UPDATE_UI, 3)
end})

events.connect(events.UPDATE_UI, function (updated)
	if not updated or updated & 3 == 0 then return end
	local strip = 'Strip: ' .. (textadept.editing.strip_trailing_spaces and 'On' or 'Off')
	ui.buffer_statusbar_text = ui.buffer_statusbar_text:bst_insert(ui.buffer_statusbar_text:bst_count() - 1, strip)
end)

local tools = textadept.menu.menubar[_L['Tools']]
_L['Reset Lua State'] = 'Reset L_ua State'
tools[#tools + 1] = {''} -- separator
tools[#tools + 1] = {_L['Reset Lua State'], reset}

-- Platform Specific Adjustments
if CURSES then
	-- Add a suspend menu entry
	table.insert(textadept.menu.menubar[_L['View']], {'Suspend...', ui.suspend})
elseif WIN32 then
	-- Disable due to weird UK keyboard
	keys['ctrl+alt+|'] = nil
end
