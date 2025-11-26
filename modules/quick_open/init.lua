-- Copyright 2025 Jamie Drinkell. MIT License.
-- Quick open module to open a terminal, file explorer etc. at the current file path
-- Windows currently untested

local M = {}
M.linux_term = 'gnome-terminal'
M.linux_explorer = 'nemo'
M.win_term = 'explorer.exe'
M.win_explorer = 'cmd.exe'

-- Open Terminal
function openTerminalHere()
    local pathString = "~"
    if LINUX or BSD then
        if buffer.filename then
            pathString = buffer.filename:match(".+/")
        end
        io.popen(M.linux_term.." --working-directory="..pathString.." &")
    elseif WIN32 then
        io.popen('Start-Process '..M.win_term)
    end
end

-- Open File Browser
function openFileBrowserHere()
    local pathString = "~"
    if LINUX or BSD then
        if buffer.filename then
            pathString = buffer.filename:match(".+/")
        end
        io.popen(M.linux_explorer.." "..pathString.." &")
    elseif WIN32 then
        io.popen('Start-Process '..M.win_explorer)
    end
end

-- Add them to the menu with keybindings
local quick_open = textadept.menu.menubar[_L['Tools/Quick Open']]
keys['ctrl+T'] = openTerminalHere
_L['Open Terminal Here...'] = 'Open _Terminal Here...'
table.insert(quick_open, 5, {
    _L['Open Terminal Here...'], openTerminalHere
})

keys['ctrl+E'] = openFileBrowserHere
_L['Open File Browser Here...'] = 'Open _File Browser Here...'
table.insert(quick_open, 6, {
    _L['Open File Browser Here...'], openFileBrowserHere
})

return M
