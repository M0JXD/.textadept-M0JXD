-- Based on code by Mitchell
-- Copyright 2020 Mitchell. See LICENSE.
-- Copyright 2025 Jamie Drinkell. MIT License.
local M = {}

M.hide_menubar = true
M.hide_tabs = true
M.hide_scrollbars = true
M.clear_statusbar = true
M.hide_margins = false
M.maximise = false
M.toggle_shortcut = 'ctrl+f12'

local function clean_statusbar ()
    ui.statusbar_text = ''
    ui.buffer_statusbar_text = ''
end

-- Distraction free mode
local distraction_free = false
local menubar = textadept.menu.menubar
local tab_bar = ui.tabs
local margin_widths = {}
local maximized = ui.maximized

keys[M.toggle_shortcut] = function()
    if not distraction_free then
        if M.hide_menubar then textadept.menu.menubar = nil end -- Remove menu bar
        if M.hide_tabs then ui.tabs = false end -- Remove the tab bar
        if M.maximise then ui.maximized = true end  -- maximise
        -- Disable scroll bars
        if M.hide_scrollbars then
            view.h_scroll_bar = false
            view.v_scroll_bar = false
        end
        -- Force the statusbar to always be blank
        if M.clear_statusbar then
            events.connect(events.UPDATE_UI, clean_statusbar)
            events.emit(events.UPDATE_UI, 1)
        end
        -- Hide margins/line numbers
        if M.hide_margins then
            for i = 1, view.margins do
                margin_widths[i] = view.margin_width_n[i]
                view.margin_width_n[i] = 0
            end
        end
        -- Remove the "Title" in curses mode
        if CURSES then ui.title = nil end

    -- Restore old state.
    else
        if M.hide_menubar then textadept.menu.menubar = menubar end
        if M.hide_tabs then ui.tabs = tab_bar end
        if M.maximise then ui.maximized = maximized end
        if M.hide_scrollbars then
            view.h_scroll_bar = true
            view.v_scroll_bar = true
        end
        if M.clear_statusbar then
            events.disconnect(events.UPDATE_UI, clean_statusbar)
            events.emit(events.UPDATE_UI, 1)
        end
        if M.hide_margins then
            for i = 1, view.margins do
                view.margin_width_n[i] = margin_widths[i]
            end
        end
        -- Restore the title by switching to the same buffer
        if CURSES then view:goto_buffer(0) end
    end
    distraction_free = not distraction_free
end

return M
