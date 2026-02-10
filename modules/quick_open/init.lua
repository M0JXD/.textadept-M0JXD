-- Copyright 2025 Jamie Drinkell. MIT License.
-- Quick open module to open a terminal, file explorer etc. at the current file path
-- Windows currently untested

local M = {}

-- TODO: I should really use xdg-open
if LINUX then
	M.terminal = 'gnome-terminal'
	M.explorer = 'nemo'
elseif BSD then
	M.terminal = 'xfce4-terminal'
	M.explorer = 'thunar'
elseif WIN32 then
	M.terminal = 'cmd.exe'
	M.explorer = 'explorer.exe'
end

-- Open Terminal
function openTerminalHere()
	local pathString = "~"
	if LINUX or BSD then
		if buffer.filename then
			pathString = buffer.filename:match(".+/")
		end
		io.popen(M.terminal.." --working-directory="..pathString.." &")
	elseif WIN32 then
        local prePath = buffer.filename:match(".+\\")
        pathString = " /K \"cd /d "..prePath.."\""
		io.popen('start '..M.terminal..pathString)
	end
end

-- Open File Browser
function openFileBrowserHere()
	local pathString = "~"
	if LINUX or BSD then
		if buffer.filename then
			pathString = buffer.filename:match(".+/")
		end
		io.popen(M.explorer.." "..pathString.." &")
	elseif WIN32 then
        local prePath = buffer.filename:match(".+\\")
        pathString = " /e,\""..prePath.."\""
		io.popen('start '..M.explorer..pathString)
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
