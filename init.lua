-- Modules
require('file_diff')
require('format')
require('lua_repl')
-- require('spellcheck')

-- Debugger setup (on Linux anyways)- can call reset command and should auto-setup
if not WIN32 or OSX then 
    events.connect(events.LEXER_LOADED, function(name)
        local project_dir = io.get_project_root()
        local project_bin

        if name == 'c' or name == 'cpp' and not CURSES then
            -- local debugger = require('debugger')
            
            -- Xmake hierachy
            --project_bin = io.get_project_root() .. '/build/linux/x86_64/debug/' .. io.get_project_root():match(".*/(.*)$")
            --debugger.project_commands[project_dir] = function()
            --    return 'c', project_bin
            --end
            
            -- TODO: implement CMake and actually check these paths exist before setting up the debugger
        end
    end)
end

-- LSP
local lsp = require('lsp')
lsp.server_commands.dart = 'dart language-server'
--lsp.server_commands.c = 'clangd'  -- TODO Setup to read compile_commands.json from vscode folder as per Xmake's usual thing'
--lsp.server_commands.cpp = 'clangd'

-- Use Textadept's basic autocompletion for ''ctrl+ ' in the terminal, LSP module seems unhappy with TUI Textadept
if CURSES then
    keys['ctrl+ '] = function() textadept.editing.autocomplete('word') end
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

-- Default Settings
buffer.use_tabs = false
buffer.tab_width = 4
--textadept.editing.highlight_words = textadept.editing.HIGHLIGHT_CURRENT  -- Esc not working

-- Set Lexers (Non projects use capital C for cpp)
lexer.detect_extensions.C = 'cpp'
lexer.detect_extensions.H = 'cpp'

-- Language specific overrides (currently uneeded)
events.connect(events.LEXER_LOADED, function(name)
    if (name == 'dart') and lsp then
        buffer.tab_width = 2
        buffer.use_tabs = false
        -- Trigger code actions for Flutter
        keys['ctrl+.'] = textadept.menu.menubar['Tools/Language Server/Code Action'][2]
    end
end)

-- Themes
if not CURSES then
    events.connect(events.VIEW_NEW, function() 
        if _THEME == 'dark' then
            view:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 12})
        else 
            view:set_theme('ayuesque-light', {font = 'Noto Mono', size = 12})
        end
    end)

    events.connect(events.MODE_CHANGED, function()
        if _THEME == 'dark' then
            for _, view in ipairs(_VIEWS) do view:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 12}) end
            pcall(function () ui.command_entry:set_theme('ayuesque-dark', {font = 'Noto Mono', size = 12}) end)
        else 
            for _, view in ipairs(_VIEWS) do view:set_theme('ayuesque-light', {font = 'Noto Mono', size = 12}) end
            pcall(function () ui.command_entry:set_theme('ayuesque-light', {font = 'Noto Mono', size = 12}) end)
        end
    end)
    events.emit(events.MODE_CHANGED)
end


-- Add a suspend menu entry for terminal
if CURSES then
    table.insert(textadept.menu.menubar[_L['View']], 18, {
    'Suspend...', ui.suspend
    })
end

-- Distraction free mode
if not CURSES then
    local distraction_free = false
    local menubar = textadept.menu.menubar
    local tab_bar = ui.tabs

    function clean_statusbar ()
        ui.statusbar_text = '' 
        ui.buffer_statusbar_text = ''
    end

    keys['ctrl+f12'] = function()
        if not distraction_free then
            textadept.menu.menubar = nil  -- Remove menu bar
            ui.tabs = false  -- Remove the tab bar
           -- Disable scroll bars
           view.h_scroll_bar = false
           view.v_scroll_bar = false
           -- Force the statusbar to always be blank
           events.connect(events.UPDATE_UI, clean_statusbar)
           events.emit(events.UPDATE_UI, 1)
        else  -- Restore old state.
            textadept.menu.menubar = menubar
            ui.tabs = tab_bar
            view.h_scroll_bar = true
            view.v_scroll_bar = true
            events.disconnect(events.UPDATE_UI, clean_statusbar)
            events.emit(events.UPDATE_UI, 1)
        end
        distraction_free = not distraction_free
    end
end
