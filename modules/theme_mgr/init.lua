-- Copyright 2025-2026 Jamie Drinkell. MIT License.

-- A simple theme manager for Textadept.
-- Allow system switching and automatic detection/application of what's best in some environments.
-- Handy if you don't want to override the default themes to achieve this.
-- (Leaving a fallback for when you edit your themes and crash everything...)

-- TODO: GTK2 version doesn't know the system colour scheme. Maybe we can obtain in manually?

local M = {theme = {}, font = {}, mt = {}}
M.theme.light = 'light'
M.theme.dark = 'dark'
M.theme.term = 'term'
M.font.size = 12
M.font.family = WIN32 and 'Consolas' or OSX and 'Monaco' or 'Monospace'

function M.check_platform_limits()
	if not CURSES then
		local font_check_cmd
		if WIN32 then
			-- Source - https://superuser.com/a/1534136
			-- Posted by phuclv, modified by community. See post 'Timeline' for change history
			-- Retrieved 2026-02-27, License - CC BY-SA 4.0
			font_check_cmd = 'reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" /s'
			-- Source - https://superuser.com/a/1534136
			-- Posted by phuclv, modified by community. See post 'Timeline' for change history
			-- Retrieved 2026-02-27, License - CC BY-SA 4.0
			-- font_check_cmd= 'Get-ItemProperty \'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts\\\''
		else
			font_check_cmd = 'fc-list' -- Linux/BSD
		end
		local proc = os.spawn(font_check_cmd)
		local list = proc:read('a')
		local font_exists = list:match(M.font.family)
		if not font_exists then
			M.font.family = WIN32 and 'Consolas' or OSX and 'Monaco' or 'Monospace'
		end
	else
		-- GNOME Terminal, Tilix, Konsole, XFCE, LXDE etc. all report 'xterm-256color'
		-- Alacritty reports 'alacritty'
		local terminal = os.getenv("TERM")
		if terminal == nil then terminal = 'WIN' end
		if terminal == 'xterm' or terminal == 'linux' or terminal == 'cons25' or terminal == 'WIN' then
			M.theme.term = 'term'
		end
	end
end

function M.set_themes(view)
	if CURSES then
		view:set_theme(M.theme.term)
	else
		if _THEME == 'dark' then
			view:set_theme(M.theme.dark, {font = M.font.family, size = M.font.size})
		else
			view:set_theme(M.theme.light, {font = M.font.family, size = M.font.size})
		end
	end
end

if not CURSES then
	events.connect(events.VIEW_NEW, function() M.set_themes(view) end)
	events.connect(events.MODE_CHANGED, function()
		if _THEME == 'dark' then
			for _, view in ipairs(_VIEWS) do M.set_themes(view) end
			pcall(function()
				ui.command_entry:set_theme(M.theme.dark, {font = M.font.family, size = M.font.size})
			end)
		else
			for _, view in ipairs(_VIEWS) do M.set_themes(view) end
			pcall(function()
				ui.command_entry:set_theme(M.theme.light, {font = M.font.family, size = M.font.size})
			end)
		end
	end)
end

M.mt.__call = function()
	M.check_platform_limits();
	M.set_themes(_G.view)
end
M.mt.__metatable = 'Don\'t change Theme Manager Metatable'
setmetatable(M, M.mt)

-- Theme selector by @kbarni! https://github.com/orbitalquark/textadept/pull/690#issue-3996335774
function M.select_theme()
	local themes = {}
	for _, dir in ipairs{_USERHOME .. '/themes', _HOME .. '/themes'} do
		if lfs.attributes(dir, 'mode') == 'directory' then
			for file in lfs.dir(dir) do
				local name = file:match('^(.+)%.lua$')
				if name then themes[#themes + 1] = name end
			end
		end
	end
	table.sort(themes)
	-- Remove duplicates.
	local i = 1
	while i < #themes do
		if themes[i] == themes[i + 1] then
			table.remove(themes, i + 1)
		else
			i = i + 1
		end
	end
	local i = ui.dialogs.list{title = _L['Select Theme'], items = themes}
	if i then view:set_theme(themes[i], {font = M.font.family, size = M.font.size}) end
end

local view_menu = textadept.menu.menubar[_L['View']]
table.insert(view_menu, #view_menu - 2, {_L['Select Theme'], M.select_theme})
table.insert(view_menu, #view_menu - 2, {''})

return M
