-- Copyright 2025-2026 Jamie Drinkell. MIT License.
-- A simple theme manager for Textadept.
-- Allow system switching and automatic detection/application of what's best in some environments.
-- Handy if you don't want to override the default themes to achieve this.
-- (Leaving a fallback for when you edit your themes and crash everything...)

-- TODO: GTK2 version doesn't know the system colour scheme. Maybe we can obtain in manually?

local M = {theme = {}, font = {}, mt = {}, defaults = {}}
M.theme.light = 'light'
M.theme.dark = 'dark'
M.font.size = 12
-- Metatable provided defaults
M.defaults.term = 'term'
M.defaults.family = WIN32 and 'Consolas' or OSX and 'Monaco' or 'Monospace'

local function check_font(font)
	local font_check_cmd
	if WIN32 then
		-- Source - https://superuser.com/a/1534136
		-- Posted by phuclv, modified by community. See post 'Timeline' for change history
		-- Retrieved 2026-02-27, License - CC BY-SA 4.0
		font_check_cmd =
			'reg query "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts" /s'
		-- Source - https://superuser.com/a/1534136
		-- Posted by phuclv, modified by community. See post 'Timeline' for change history
		-- Retrieved 2026-02-27, License - CC BY-SA 4.0
		-- font_check_cmd = 'Get-ItemProperty \'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts\\\''
	else
		font_check_cmd = 'fc-list' -- Linux/BSD
	end
	local proc = os.spawn(font_check_cmd)
	local list = proc:read('a')
	local font_exists = list:match(font)
	if font_exists then return true end
end

local function check_term()
	-- GNOME Terminal, Tilix, Konsole, XFCE, LXDE etc. all report 'xterm-256color'
	-- Alacritty reports 'alacritty'
	local terminal = os.getenv("TERM")
	if terminal == nil then terminal = 'WIN' end
	if terminal == 'xterm' or terminal == 'linux' or terminal == 'cons25' or terminal == 'WIN' then
		return false
	end
	return true
end

-- Reset some commonly adjusted things that cause problems when switching themes
local function reset_view(view)
	view.caret_style = view.CARETSTYLE_LINE
	view.caret_line_layer = view.LAYER_BASE
	view.selection_layer = view.LAYER_BASE
	view:style_reset_default()
	view:style_clear_all()
	-- Reset all the element colours
	view:reset_element_color(view.ELEMENT_SELECTION_TEXT)
	view:reset_element_color(view.ELEMENT_SELECTION_BACK)
	view:reset_element_color(view.ELEMENT_SELECTION_ADDITIONAL_TEXT)
	view:reset_element_color(view.ELEMENT_SELECTION_ADDITIONAL_BACK)
	view:reset_element_color(view.ELEMENT_SELECTION_SECONDARY_TEXT)
	view:reset_element_color(view.ELEMENT_SELECTION_SECONDARY_BACK)
	view:reset_element_color(view.ELEMENT_SELECTION_INACTIVE_TEXT)
	view:reset_element_color(view.ELEMENT_SELECTION_INACTIVE_BACK)
	view:reset_element_color(view.ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT)
	view:reset_element_color(view.ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK)
	view:reset_element_color(view.ELEMENT_CARET)
	view:reset_element_color(view.ELEMENT_CARET_ADDITIONAL)
	view:reset_element_color(view.ELEMENT_CARET_LINE_BACK)
	view:reset_element_color(view.ELEMENT_WHITE_SPACE)
	view:reset_element_color(view.ELEMENT_WHITE_SPACE_BACK)
	view:reset_element_color(view.ELEMENT_FOLD_LINE)
	view:reset_element_color(view.ELEMENT_HIDDEN_LINE)
end

local function theme_mode(view)
	if _THEME == 'dark' then
		view:set_theme(M.theme.dark, {font = M.font.family, size = M.font.size})
	else
		view:set_theme(M.theme.light, {font = M.font.family, size = M.font.size})
	end
end

function M.theme_command_entry()
	if _THEME == 'dark' then
		pcall(function()
			ui.command_entry:set_theme(M.theme.dark, {font = M.font.family, size = M.font.size})
		end)
	else
		pcall(function()
			ui.command_entry:set_theme(M.theme.light, {font = M.font.family, size = M.font.size})
		end)
	end
end

function M.set_themes(reset)
	for _, view in ipairs(_VIEWS) do
		if CURSES then
			view:set_theme(M.theme.term)
		else
			if reset then reset_view(view) end
			theme_mode(view)
		end
	end
end

if not CURSES then
	events.connect(events.VIEW_NEW, function()
		reset_view(view)
		theme_mode(view)
	end)
	events.connect(events.MODE_CHANGED, function()
		M.theme_command_entry()
		M.set_themes(true)
	end)
end
local init = function() M.set_themes(false) end
events.connect(events.INITIALIZED, init)

-- Theme selector by @kbarni! https://github.com/orbitalquark/textadept/pull/690#issue-3996335774
function M.select_theme(mode)
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
	if i then
		if mode == 'light' then
			M.theme.light = themes[i]
		elseif mode == 'dark' then
			M.theme.dark = themes[i]
		elseif mode == 'term' then
			M.theme.term = themes[i]
		end
		M.theme_command_entry()
		M.set_themes(true)
	end
end

M.mt.__call = function()
	events.disconnect(events.INITIALIZED, init)
	init()
end

M.mt.__index = M.defaults
M.mt.__newindex = function(t, k, v)
	if k == 'family' and check_font(v) then
		rawset(t, k, v)
	elseif k == 'term' and CURSES and check_term() then
		rawset(t, k, v)
	end
end
M.mt.__metatable = 'Don\'t change Theme Manager Metatable'

setmetatable(M, M.mt)
setmetatable(M.font, M.mt)
setmetatable(M.theme, M.mt)

_L['Change Theme...'] = 'Change _Theme...'
_L['Select Light Theme'] = 'Select _Light Theme'
_L['Select Dark Theme'] = 'Select _Dark Theme'
local view_menu = textadept.menu.menubar[_L['View']]
if not CURSES then
	table.insert(view_menu, #view_menu - 2, {
		title = _L['Change Theme...'],
		{_L['Select Light Theme'], function() M.select_theme('light') end},
		{_L['Select Dark Theme'], function() M.select_theme('dark') end}
	})
else
	table.insert(view_menu, #view_menu - 2,
		{_L['Change Theme...'], function() M.select_theme('term') end})
end
table.insert(view_menu, #view_menu - 2, {''})

return M
