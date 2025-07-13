-- Modules
require('file_diff')
require('format')
require('lua_repl')
local spellcheck = require('spellcheck')
spellcheck.check_spelling_on_save = false
local autoupdate = require('autoupdate')
autoupdate.check_on_startup = true
autoupdate.copy_link = false
local distraction_free = require('distraction_free')

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

-- LSP
local lsp = require('lsp')
lsp.server_commands.dart = 'dart language-server'
-- TODO Setup LSP for C, Python etc.
--lsp.server_commands.c = 'clangd'

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

-- Default Settings
buffer.use_tabs = false
buffer.tab_width = 4
--textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_CURRENT  -- Esc not working

-- Language specific overrides (currently uneeded)
events.connect(events.LEXER_LOADED, function(name)
    if (name == 'dart') and lsp then
        buffer.tab_width = 2
        buffer.use_tabs = false
        -- Trigger code actions for Flutter
        keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2]
    end
    
    if (name == 'text') then
        textadept.editing.auto_pairs = nil
    end
end)

--Keybindings
keys['ctrl+K'] = function() buffer:line_delete() end

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

-- TUI Version
if CURSES then
    view:set_theme('ayuesque-term')
    -- Add a suspend menu entry for terminal version
    table.insert(textadept.menu.menubar[_L['View']], 18, {
    'Suspend...', ui.suspend
    })
    -- Use Textadept's basic autocompletion for ''ctrl+ ' in the terminal,
    -- LSP module seems unhappy with TUI Textadept
    keys['ctrl+ '] = function() textadept.editing.autocomplete('word') end
end

-- Platform Specific Adjustments
if WIN32 then
    -- Disable due to weird UK keyboard
    keys['ctrl+alt+|'] = function() textadept.editing.autocomplete('word') end
end
