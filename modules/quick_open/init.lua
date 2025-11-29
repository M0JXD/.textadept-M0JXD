-- Copyright 2025 Jamie Drinkell. MIT License.
-- Quick open module to open a terminal, file explorer etc. at the current file path
-- Windows currently untested

local M = {}
M.linux_term = 'gnome-terminal'
M.linux_explorer = 'nemo'
M.win_term = 'cmd.exe'
M.win_explorer = 'explorer.exe'

-- Open Terminal
function openTerminalHere()
	local pathString = "~"
	if LINUX or BSD then
		if buffer.filename then
			pathString = buffer.filename:match(".+/")
		end
		io.popen(M.linux_term.." --working-directory="..pathString.." &")
	elseif WIN32 then
        local prePath = buffer.filename:match(".+\\")
        pathString = " /K \"cd /d "..prePath.."\""
		io.popen('start '..M.win_term..pathString)
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
        local prePath = buffer.filename:match(".+\\")
        pathString = " /e,\""..prePath.."\""
		io.popen('start '..M.win_explorer..pathString)
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
