-- Copyright 2025 Jamie Drinkell. MIT License.
-- Quick open module to open a terminal, file explorer etc. at the current file path

local M = {}

local desktop = os.getenv('XDG_CURRENT_DESKTOP')
if desktop == nil then desktop = '' end

-- Most GTK terminals use these
M.term_dir_arg = '--working-directory='
M.term_max_arg = '--maximize'

if desktop:match('Cinnamon') then
	M.terminal = 'gnome-terminal'
elseif desktop:match('XFCE') then
	M.terminal = 'xfce4-terminal'
elseif desktop:match('MATE') then
	M.terminal = 'mate-terminal'
elseif desktop:match('LXDE') then
	M.terminal = 'lxterminal'
elseif desktop:match('GNOME') then
	M.terminal = 'kgx'
elseif desktop:match('KDE') then
	M.terminal = 'konsole'
	M.term_dir_arg = '--workdir '
	M.term_max_arg = '--fullscreen'
elseif desktop:match('ENLIGHTENMENT') then
	M.terminal = 'terminology'
	M.term_dir_arg = '-d='
	M.term_max_arg = '-M'
elseif desktop:match('LXQt') then
	M.terminal = 'qterminal'
	-- Presumably the same as lxterminal?
else
	-- xterm doesn't really support giving a directory at startup?
	M.terminal = 'xterm -hold'
	M.term_max_arg = '-fullscreen'
end

M.explorer = 'xdg-open'
M.git_client = 'lazygit'

if WIN32 then
	M.terminal = 'cmd.exe'
	M.explorer = 'explorer.exe'
	M.git_client = 'lazygit.exe'
end

local function openTerminalHere(arg)
	local argString = '~'
	if LINUX or BSD then
		if buffer.filename then
			argString = buffer.filename:match('.+/')
			argString = M.term_dir_arg .. argString
		end
		if arg then
			argString = argString .. ' ' .. M.term_max_arg .. ' -e ' .. arg
		else
			argString = argString .. ' &'
		end
		io.popen(M.terminal .. ' ' .. argString)
	elseif WIN32 then
		local prePath = buffer.filename:match('.+\\')
		argString = ' /K "cd /d ' .. prePath .. '"'
		if arg then argString = ' /C "cd /d ' .. prePath .. ' & ' .. arg .. '"' end
		io.popen('start ' .. M.terminal .. ' ' .. argString)
	end
end

local function openFileBrowserHere()
	local pathString = '~'
	if LINUX or BSD then
		if buffer.filename then pathString = buffer.filename:match('.+/') end
		io.popen(M.explorer .. ' ' .. pathString .. ' &')
	elseif WIN32 then
		local prePath = buffer.filename:match('.+\\')
		pathString = ' /e,' .. prePath
		io.popen('start ' .. M.explorer .. pathString)
	end
end

local function openGitClientHere()
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
