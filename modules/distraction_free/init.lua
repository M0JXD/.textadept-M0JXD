-- Based on code by Mitchell
-- Copyright 2020 Mitchell. See LICENSE.
-- Copyright 2025 Jamie Drinkell. MIT License.
local M = {}

M.hide_menubar = true
M.hide_tabs = true
M.hide_scrollbars = true
M.clear_statusbar = true
M.hide_margins = false
M.hide_curses_title = true
M.maximise = false
M.toggle_shortcut = 'ctrl+f12'

-- NB: This is carefully connected to the right events instead of generic UPDATE_UI
-- Otherwise it just flickers all the time.
local function clear_title()
	ui.title = nil
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
		ui.statusbar = false
		-- Hide margins/line numbers
		if M.hide_margins then
			for i = 1, view.margins do
				margin_widths[i] = view.margin_width_n[i]
				view.margin_width_n[i] = 0
			end
		end

		-- Remove the "Title" in curses
		if CURSES and M.hide_curses_title then
			events.connect(events.BUFFER_AFTER_SWITCH, clear_title)
			events.connect(events.BUFFER_NEW, clear_title)
			events.connect(events.SAVE_POINT_REACHED, clear_title)
			events.connect(events.SAVE_POINT_LEFT, clear_title)
			events.connect(events.VIEW_AFTER_SWITCH, clear_title)
			events.emit(events.BUFFER_AFTER_SWITCH, 1)
		end
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
			ui.statusbar = true
		end
		if M.hide_margins then
			for i = 1, view.margins do
				view.margin_width_n[i] = margin_widths[i]
			end
		end
		-- Restore the title by switching to the same buffer
		if CURSES and M.hide_curses_title then
			events.disconnect(events.BUFFER_AFTER_SWITCH, clear_title)
			events.disconnect(events.BUFFER_NEW, clear_title)
			events.disconnect(events.SAVE_POINT_REACHED, clear_title)
			events.disconnect(events.SAVE_POINT_LEFT, clear_title)
			events.disconnect(events.VIEW_AFTER_SWITCH, clear_title)
			view:goto_buffer(0)
		end
	end
	distraction_free = not distraction_free
end

return M
