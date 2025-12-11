-- Copyright 2025 Jamie Drinkell. MIT License.

-- Themeing
local theme_mgr = require('theme_mgr')
theme_mgr.light_theme = 'ayu-light'
theme_mgr.dark_theme = 'ayu-evolve'
theme_mgr.term_theme = 'ayu-evolve'
theme_mgr.font_type = 'Dejavu Sans Mono' -- FreeMono
theme_mgr.font_size = 14
view.edge_column = 100

-- Modules (M0JXD)
require('distraction_free')
require('quick_open')
require('doc_stats')

-- Modules (Official)
--require('debugger')
--require('export')
require('file_diff')
local format = require('format')
format.on_save = false
format.commands.dart = 'dart format'
local lsp = require('lsp')
if QT then
	lsp.server_commands.dart = 'dart language-server'
	keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2]
end
require('lua_repl')
--require('open_file_mode')
--require('scratch')
local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false
local update_notifier = require('update_notifier')
update_notifier.check_on_startup = true

-- Modules (external)
--require('textredux').hijack()
-- Experimental features by @Fwirt (requires custom build)
--local textbar = require('textbar')
--local minimap = require('minimap')

-- Default Settings, Keybindings
buffer.tab_width = 4
textadept.editing.strip_trailing_spaces = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
--buffer.use_tabs = false
--ui.find.highlight_all_matches = true
-- Match some VSCode bindings
keys['ctrl+K'] = function() buffer:line_delete() end
keys['ctrl+,'] = textadept.menu.menubar['Edit/Preferences'][2]
if not CURSES then
	keys['alt+up'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Up'][2]
	keys['alt+down'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Down'][2]
end

-- Language Specific
lexer.detect_extensions.h = 'c'
textadept.editing.comment_string.c = '/*|*/'
lexer.detect_extensions.ino = 'cpp'  -- For Arduino sketches
lexer.detect_extensions.blp = 'blueprint'
local auto_pairs = textadept.editing.auto_pairs
events.connect(events.LEXER_LOADED, function(name)
	if (name == 'makefile') then
		buffer.use_tabs = true
	end

	if (name == 'dart') then
		buffer.tab_width = 2
		buffer.use_tabs = false
		format.on_save = true
	end

	if (name == 'text') then
		textadept.editing.auto_pairs = nil
		view.wrap_mode = view.WRAP_WHITESPACE
		--buffer.use_tabs = true
	else
		textadept.editing.auto_pairs = auto_pairs
		view.wrap_mode = view.WRAP_NONE
	end
end)

-- Extras

-- Line Guide
_L["Toggle Line Guide"] = 'Toggle _Line Guide'
table.insert(textadept.menu.menubar[_L['View']], 18, {_L['Toggle Line Guide'], function ()
	view.edge_mode = view.edge_mode == view.EDGE_LINE and view.EDGE_NONE or view.EDGE_LINE
end})

-- Lua Reset
local tools = textadept.menu.menubar[_L['Tools']]
_L['Reset Lua State'] = 'Reset L_ua State'
tools[#tools + 1] = {''} -- separator
tools[#tools + 1] = {_L['Reset Lua State'], reset}

-- TUI Adjustments
if CURSES then
	-- Add a suspend menu entry
	table.insert(textadept.menu.menubar[_L['View']], {'Suspend...', ui.suspend})
end

-- Windows Adjustments
if WIN32 then
	-- Disable due to weird UK keyboard
	keys['ctrl+alt+|'] = nil
end

-- Old File Browser usage (Might revisit awaiting possible merged changes by @Fwirt)
--_L['Open Directory'] = 'Open _Directory...'
--local file_browser = require('file_browser')
--keys['ctrl+O'] = file_browser.init
--table.insert(textadept.menu.menubar[_L['File']], 3, {
--	_L['Open Directory'], file_browser.init
--})
--file_browser.hide_dot_folders = true
--file_browser.hide_dot_files = false
--file_browser.force_folders_first = true
--file_browser.case_insensitive_sort = true
