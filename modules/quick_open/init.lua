-- Copyright 2025 Jamie Drinkell. MIT License.
-- Quick open module to open a terminal, file explorer etc. at the current file path
-- Windows currently untested

local M = {}

-- TODO: I should really use xdg-open
M.git_client = 'lazygit'
if LINUX then
	M.terminal = 'gnome-terminal'
	M.explorer = 'nemo'
elseif BSD then
	M.terminal = 'xfce4-terminal'
	M.explorer = 'thunar'
elseif WIN32 then
	M.terminal = 'cmd.exe'
	M.explorer = 'explorer.exe'
	M.git_client = 'lazygit.exe'
end

-- Open Terminal
function openTerminalHere(arg)
	local argString = '~'
	if LINUX or BSD then
		if buffer.filename then
			argString = buffer.filename:match('.+/')
			argString = '--working-directory='..argString
		end
		if arg then
			argString = argString .. ' -e '..arg
		else
			argString = argString .. ' &'
		end
		io.popen(M.terminal..' '..argString)
	elseif WIN32 then
        local prePath = buffer.filename:match('.+\\')
        argString = ' /K "cd /d '..prePath..'"'
		if arg then
			argString = ' /C "cd /d '..prePath..' & '.. arg .. '"'
			ui.print(argString)
		end
		io.popen('start '..M.terminal..' '..argString)
	end
end

-- Open File Browser
function openFileBrowserHere()
	local pathString = '~'
	if LINUX or BSD then
		if buffer.filename then
			pathString = buffer.filename:match('.+/')
		end
		io.popen(M.explorer..' '..pathString..' &')
	elseif WIN32 then
        local prePath = buffer.filename:match('.+\\')
        pathString = ' /e,\''..prePath..'\''
		io.popen('start '..M.explorer..pathString)
	end
end

function openGitClientHere()
	openTerminalHere(M.git_client)
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

keys['ctrl+G'] = openGitClientHere
_L['Open Git Client Here...'] = 'Open _Git Client Here...'
table.insert(quick_open, 7, {
	_L['Open Git Client Here...'], openGitClientHere
})

return M
