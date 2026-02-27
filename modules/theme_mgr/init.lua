-- Copyright 2025 Jamie Drinkell. MIT License.

-- This is a simple theme manager for Textadept.
-- Allow system switching and automatic detection/application of what's best in some environments.
-- Handy if you don't want to override the default themes to acheive this
-- (Leaving a handy fallback for when you edit your themes and crash everything...)

-- TODO: GTK2 version doesn't detect system colours?

local M = {}
M.light_theme = 'light'
M.dark_theme = 'dark'
M.term_theme = 'term'
M.term_fallback_theme = 'term'
M.font_type = WIN32 and 'Consolas' or OSX and 'Monaco' or 'Monospace'
M.font_size = 12
M.win32_default_font = true  -- Windows fonts are not always available, so force override to the default type

-- GUI Themeing
if not CURSES then
	events.connect(events.VIEW_NEW, function()
		if WIN32 and M.win32_default_font then M.font_type = 'Consolas' end
		if _THEME == 'dark' then
			view:set_theme(M.dark_theme, {font = M.font_type, size = M.font_size})
		else
			view:set_theme(M.light_theme, {font = M.font_type, size = M.font_size})
		end
	end)

	events.connect(events.MODE_CHANGED, function()
		if WIN32 and M.win32_default_font then M.font_type = 'Consolas' end
		if _THEME == 'dark' then
			for _, view in ipairs(_VIEWS) do view:set_theme(M.dark_theme, {font = M.font_type, size = M.font_size}) end
			pcall(function () ui.command_entry:set_theme(M.dark_theme, {font = M.font_type, size = M.font_size}) end)
		else
			for _, view in ipairs(_VIEWS) do view:set_theme(M.light_theme, {font = M.font_type, size = M.font_size}) end
			pcall(function () ui.command_entry:set_theme(M.light_theme, {font = M.font_type, size = M.font_size}) end)
		end
	end)
	events.emit(events.MODE_CHANGED)

-- CURSES Theming
elseif not WIN32 then
	-- GNOME Terminal, Tilix, Konsole, XFCE, LXDE etc. all report xterm-256color
	local terminal = os.getenv("TERM")
	events.connect(events.INITIALIZED, function()
		if (terminal == 'xterm-256color') or (terminal == 'alacritty') then
			view:set_theme(M.term_theme)
		elseif (terminal == 'xterm') or (terminal == 'linux') or BSD then
			view:set_theme(M.term_fallback_theme)
		end
	end)
end

-- Theme selector thanks to @kbarni! https://github.com/orbitalquark/textadept/pull/690#issue-3996335774
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
    if i then
		view:set_theme(themes[i], {font = (M.win32_default_font and 'Consolas' or M.font_type), size = M.font_size})
	end
end

local view = textadept.menu.menubar[_L['View']]
table.insert(view, #view - 2, {_L['Select Theme'] , M.select_theme})
table.insert(view, #view - 2, {''})


return M
