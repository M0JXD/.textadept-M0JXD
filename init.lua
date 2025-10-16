-- Copyright 2025 Jamie Drinkell. MIT License.

-- Themeing
local theme_mgr = require('theme_mgr')
theme_mgr.light_theme = 'ayu-light'
theme_mgr.dark_theme = 'ayu-evolve'
theme_mgr.term_theme = 'ayu-evolve'
theme_mgr.font_type = 'Noto Mono'
theme_mgr.font_size = 14

-- Modules
require('distraction_free')
require('file_diff')
require('lua_repl')

local format = require('format')
format.on_save = false
format.commands.dart = 'dart format'  -- Can be removed next update

local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false

local update_notifier = require('update_notifier')
update_notifier.check_on_startup = true

-- LSP
if QT then
    -- Most language servers behave better on QT, so only activate there
	local lsp = require('lsp')
    lsp.server_commands.dart = 'dart language-server'
    -- TODO: Setup LSP for other languages
    -- lsp.server_commands.c = 'clangd'
    -- lsp.server_commands.cpp = 'clangd'
    -- lsp.server_commands.python = ''
end

-- File Browser
_L['Open Directory'] = 'Open _Directory...'
local file_browser = require('file_browser')
keys['ctrl+O'] = file_browser.init
table.insert(textadept.menu.menubar[_L['File']], 3, {
    _L['Open Directory'], file_browser.init
})
file_browser.hide_dot_folders = true
file_browser.hide_dot_files = false
file_browser.force_folders_first = true
file_browser.case_insensitive_sort = true

-- Default Settings, Keybindings
buffer.use_tabs = false
buffer.tab_width = 4
textadept.editing.strip_trailing_spaces = true
textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
--ui.find.highlight_all_matches = true
-- Match some VSCode bindings
keys['ctrl+K'] = function() buffer:line_delete() end
keys['alt+up'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Up'][2]
keys['alt+down'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Down'][2]

-- Language Specific
lexer.detect_extensions.ino = 'cpp'  -- For Arduino sketches
textadept.editing.comment_string.c = '/*|*/'
local auto_pairs = textadept.editing.auto_pairs
events.connect(events.LEXER_LOADED, function(name)
    if (name == 'dart') then
        format.on_save = true
        buffer.tab_width = 2
        buffer.use_tabs = false
        -- Trigger code actions for Flutter
        if lsp then keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2] end
    end

    if (name == 'text') then
        textadept.editing.auto_pairs = nil
        textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_NONE
        view.wrap_mode = view.WRAP_WHITESPACE
    else
        textadept.editing.auto_pairs = auto_pairs
        textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_SELECTED
        view.wrap_mode = view.WRAP_NONE
    end

    if (name == 'makefile') then
        buffer.use_tabs = true
    end
end)

-- TUI Adjustments
if CURSES then
    -- Add a suspend menu entry
    table.insert(textadept.menu.menubar[_L['View']], 18, {'Suspend...', ui.suspend})
end

-- Windows Adjustments
if WIN32 then
    -- Disable due to weird UK keyboard
    keys['ctrl+alt+|'] = nil
end

-- Lua Reset
_L['Reset Lua State'] = 'Reset L_ua State'
local tools = textadept.menu.menubar[_L['Tools']]
tools[#tools + 1] = {''} -- separator
tools[#tools + 1] = {_L['Reset Lua State'], reset}

if LINUX or BSD then
    -- Open Terminal
    function openTerminalHere()
            terminalString = "gnome-terminal"
            pathString = "~"
            if buffer.filename then
                    pathString = buffer.filename:match(".+/")
            end
            io.popen(terminalString.." --working-directory="..pathString.." &")
    end
    keys['ctrl+T'] = openTerminalHere
    _L['Open Terminal Here...'] = 'Open _Terminal Here...'
    table.insert(tools, 12, {
        _L['Open Terminal Here...'], openTerminalHere
    })
end

 --Display the amount of rows in the main selection
events.connect(events.UPDATE_UI, function(updated)
    if not updated or updated & (buffer.UPDATE_CONTENT | buffer.UPDATE_SELECTION) == 0 then return end
	local text = not CURSES and '%s %d    %s %d/%d    %s %d    %s    %s    %s    %s' or
		'%s %d  %s %d/%d  %s %d  %s  %s  %s  %s'
	local selRow = buffer:line_from_position(buffer.selection_n_end[buffer.main_selection]) -
		buffer:line_from_position(buffer.selection_n_start[buffer.main_selection]) + 1
	local pos = buffer.current_pos
	local line, max = buffer:line_from_position(pos), buffer.line_count
	local col = buffer.column[pos] + buffer.selection_n_caret_virtual_space[buffer.main_selection]
	local lang = buffer.lexer_language
	local eol = buffer.eol_mode == buffer.EOL_CRLF and _L['CRLF'] or _L['LF']
	local tabs = string.format('%s %d', buffer.use_tabs and _L['Tabs:'] or _L['Spaces:'],
		buffer.tab_width)
	local encoding = buffer.encoding or ''
	ui.buffer_statusbar_text = string.format(text, 'Rows:', selRow, _L['Line:'], line, max, _L['Col:'], col, lang, eol,
		tabs, encoding)
end)
