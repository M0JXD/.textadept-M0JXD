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
M.win32_default_font = true

-- GUI Themeing
if not CURSES then

    -- Windows fonts are not always available, so force override to the default type
    if WIN32 then
        events.connect(events.INITIALIZED, function()
            if M.win32_default_font then M.font_type = 'Consolas' end
        end)
    end

    events.connect(events.VIEW_NEW, function()
        if _THEME == 'dark' then
            view:set_theme(M.dark_theme, {font = M.font_type, size = M.font_size})
        else
            view:set_theme(M.light_theme, {font = M.font_type, size = M.font_size})
        end
    end)

    events.connect(events.MODE_CHANGED, function()
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
        elseif (terminal == 'xterm') or (terminal == 'linux') then
            view:set_theme(M.term_fallback_theme)
        end
    end)
end

return M
