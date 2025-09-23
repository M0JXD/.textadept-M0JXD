-- Copyright 2025 Jamie Drinkell. MIT License.

-- Themes, when on Windows remove the fonts, for Ctrl-D: font = 'Noto Mono',
if not CURSES then
    events.connect(events.VIEW_NEW, function()
        if _THEME == 'dark' then
            view:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 14})
        else
            view:set_theme('ayuesque-light', {font = 'Noto Mono', size = 14})
        end
    end)

    events.connect(events.MODE_CHANGED, function()
        if _THEME == 'dark' then
            for _, view in ipairs(_VIEWS) do view:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 14}) end
            pcall(function () ui.command_entry:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 14}) end)
        else
            for _, view in ipairs(_VIEWS) do view:set_theme('ayuesque-light', {font = 'Noto Mono', size = 14}) end
            pcall(function () ui.command_entry:set_theme('ayuesque-light', {font = 'Noto Mono', size = 14}) end)
        end
    end)
    events.emit(events.MODE_CHANGED)
end

-- Modules
require('file_diff')
require('format')
require('lua_repl')
require('distraction_free')

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
keys['ctrl+O'] = file_browser.init  -- Ctrl+Shift+o to open directory
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
-- Match VSCode
keys['ctrl+K'] = function() buffer:line_delete() end
keys['alt+up'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Up'][2]
keys['alt+down'] = textadept.menu.menubar['Edit/Selection/Move Selected Lines Down'][2]
--keys['ctrl+shift+down'] =
--keys['ctrl+shift+up'] =

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
        view.wrap_mode = view.WRAP_NONE
    end

    if (name == 'makefile') then
        buffer.use_tabs = true
    end
end)

-- TUI Adjustments
if CURSES then
    -- view:set_theme('ayuesque-term')  -- TODO: find a way of detecting if a term can handle this.
    -- Add a suspend menu entry
    table.insert(textadept.menu.menubar[_L['View']], 18, {'Suspend...', ui.suspend})
end

-- Windows Adjustments
if WIN32 then
    -- Disable due to weird UK keyboard
    keys['ctrl+alt+|'] = nil
end

-- Utils to quickly setup dev environment for various systems
function setup_xmake()
    local project_dir = io.get_project_root()
    local project_bin = io.get_project_root() .. '/build/linux/x86_64/debug/' .. io.get_project_root():match(".*/(.*)$")
    if name == 'c' or name == 'cpp' then
        local debugger = require('debugger')
        debugger.project_commands[project_dir] = function()
            return 'c', project_bin
        end
    end
end
