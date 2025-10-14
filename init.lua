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
--format.on_save = false
format.commands.dart = 'dart format'

local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false

local update_notifier = require('update_notifier')
update_notifier.check_on_startup = true

-- LSP
local lsp = require('lsp')
if QT then
    -- Most language servers behave better on QT, so only activate there
    lsp.server_commands.dart = 'dart language-server'
    -- TODO: Setup LSP for other languages
    -- lsp.server_commands.c = 'clangd'
    -- lsp.server_commands.cpp = 'clangd'
    -- lsp.server_commands.python = ''
end

-- File Browser
local file_browser = require('file_browser')
keys['ctrl+O'] = file_browser.init
table.insert(textadept.menu.menubar[_L['File']], 3, {
    'Open Directory...', file_browser.init
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

-- Language specific
lexer.detect_extensions.ino = 'cpp'  -- For Arduino sketches
textadept.editing.comment_string.c = '/*|*/'
local auto_pairs = textadept.editing.auto_pairs
events.connect(events.LEXER_LOADED, function(name)
    if (name == 'dart') then
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
local tools = textadept.menu.menubar[_L['Tools']]
tools[#tools + 1] = {''} -- separator
tools[#tools + 1] = {'Reset L_ua State', reset} -- mark 'u' as the mnemonic

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
    table.insert(tools, 12, {
        'Open Terminal Here...', openTerminalHere
    })
end
