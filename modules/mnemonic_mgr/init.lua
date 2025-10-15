-- Copyright 2025 Jamie Drinkell. MIT License.
-- A simple module that helps manage mnemonics
-- between QT and GTK versions of Textadept

local M = {}

function M:add_entry(key, entry)
    if QT then
        -- Look for any underscores and change to ampersands
        entry = entry:gsub('_', '&')
    elseif GTK then
        -- Look for any ampersands and change to underscores
        entry = entry:gsub('&', '_')
    else
        -- Remove any ampersands or underscores
        entry = entry:gsub('_', '')
        entry = entry:gsub('&', '')
    end

    self[key] = entry
end

return M
