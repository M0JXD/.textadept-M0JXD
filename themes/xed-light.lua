 --Copyright 2025 Jamie Drinkell. MIT License.
-- Xed Light theme for Textadept.

local view, colors, styles = view, view.colors, view.styles

-- Greyscale colors.
colors.black = 0x332E2E
colors.light_black = 0x7A7370
colors.dark_grey = 0x858A88
colors.grey = 0xB6BDBF
colors.white = 0xFFFFFF

colors.red = 0x0000A4
colors.orange = 0x02598F
colors.yellow = 0x00A0C4 -- 0x4FE9FC
colors.lime = 0x4FE9FC
colors.green = 0xA87FAD
colors.blue = 0x069A4E
colors.violet = 0xA87FAD
colors.purple = 0xA46534

-- Default font.
if not font then font = WIN32 and 'Consolas' or OSX and 'Monaco' or 'Monospace' end
if not size then size = not OSX and 10 or 12 end

-- Predefined styles.
styles[view.STYLE_DEFAULT] = {
	font = font, size = size, fore = colors.black, back = colors.white
}
styles[view.STYLE_LINENUMBER] = {fore = colors.dark_grey, back = colors.white}
styles[view.STYLE_BRACELIGHT] = {fore = colors.yellow, bold = true}
styles[view.STYLE_BRACEBAD] = {fore = colors.red}
-- styles[view.STYLE_CONTROLCHAR] = {}
styles[view.STYLE_INDENTGUIDE] = {fore = colors.dark_grey}
styles[view.STYLE_CALLTIP] = {fore = colors.black}
styles[view.STYLE_FOLDDISPLAYTEXT] = {fore = colors.dark_grey, back = colors.dark_grey}

-- Tag styles.
styles[lexer.ANNOTATION] = {fore = colors.red}
styles[lexer.ATTRIBUTE] = {fore = colors.red}
styles[lexer.BOLD] = {bold = true}
styles[lexer.CLASS] = {fore = colors.yellow}
styles[lexer.CODE] = {fore = colors.dark_grey, eol_filled = true}
styles[lexer.COMMENT] = {fore = colors.dark_grey}
-- styles[lexer.CONSTANT] = {}
styles[lexer.CONSTANT_BUILTIN] = {fore = colors.purple}
styles[lexer.EMBEDDED] = {fore = colors.purple}
styles[lexer.ERROR] = {fore = colors.red}
styles[lexer.FUNCTION] = {fore = colors.black}
styles[lexer.FUNCTION_BUILTIN] = {fore = colors.purple}
styles[lexer.FUNCTION_METHOD] = {fore = colors.black}
styles[lexer.HEADING] = {fore = colors.blue}
-- styles[lexer.IDENTIFIER] = {fore = colors.yellow}
styles[lexer.ITALIC] = {italic = true}
styles[lexer.KEYWORD] = {fore = colors.red}
styles[lexer.LABEL] = {fore = colors.blue}
styles[lexer.LINK] = {fore = colors.purple, underline = true}
styles[lexer.LIST] = {fore = colors.red}
styles[lexer.NUMBER] = {fore = colors.violet}
-- styles[lexer.OPERATOR] = {fore = colors.orange}
styles[lexer.PREPROCESSOR] = {fore = colors.orange}
styles[lexer.REFERENCE] = {underline = true}
styles[lexer.REGEX] = {fore = colors.lime}
styles[lexer.STRING] = {fore = colors.green}
styles[lexer.TAG] = {fore = colors.blue}
styles[lexer.TYPE] = {fore = colors.blue}
styles[lexer.UNDERLINE] = {underline = true}
-- styles[lexer.VARIABLE] = {}
styles[lexer.VARIABLE_BUILTIN] = {fore = colors.purple}
-- styles[lexer.WHITESPACE] = {}

-- CSS.
styles.property = styles[lexer.ATTRIBUTE]
-- styles.pseudoclass = {}
-- styles.pseudoelement = {}
-- Diff.
styles.addition = {fore = colors.green}
styles.deletion = {fore = colors.red}
styles.change = {fore = colors.yellow}
-- HTML.
styles.tag_unknown = styles.tag .. {italic = true}
styles.attribute_unknown = styles.attribute .. {italic = true}
-- Latex, TeX, and Texinfo.
styles.command = styles[lexer.KEYWORD]
styles.command_section = styles[lexer.HEADING]
styles.environment = styles[lexer.TYPE]
styles.environment_math = styles[lexer.NUMBER]
-- Makefile.
-- styles.target = {}
-- Markdown.
-- styles.hr = {}
-- Python.
styles.keyword_soft = {}
-- XML.
-- styles.cdata = {}
-- YAML.
styles.error_indent = {back = colors.red}

-- Element colors.
-- view.element_color[view.ELEMENT_SELECTION_TEXT] = colors.black
view.element_color[view.ELEMENT_SELECTION_BACK] = colors.light_black
-- view.element_color[view.ELEMENT_SELECTION_ADDITIONAL_TEXT] = colors.black
view.element_color[view.ELEMENT_SELECTION_ADDITIONAL_BACK] = colors.light_black
-- view.element_color[view.ELEMENT_SELECTION_SECONDARY_TEXT] = colors.black
view.element_color[view.ELEMENT_SELECTION_SECONDARY_BACK] = colors.light_black
-- view.element_color[view.ELEMENT_SELECTION_INACTIVE_TEXT] = colors.black
view.element_color[view.ELEMENT_SELECTION_INACTIVE_BACK] = colors.light_black
-- view.element_color[view.ELEMENT_SELECTION_INACTIVE_ADDITIONAL_TEXT] = colors.black
view.element_color[view.ELEMENT_SELECTION_INACTIVE_ADDITIONAL_BACK] = colors.light_black
view.element_color[view.ELEMENT_CARET] = colors.dark_grey
-- view.element_color[view.ELEMENT_CARET_ADDITIONAL] =
if view ~= ui.command_entry then
	view.element_color[view.ELEMENT_CARET_LINE_BACK] = colors.dark_grey | 0x60000000
end
view.caret_line_layer = view.LAYER_UNDER_TEXT

-- Fold Margin.
view:set_fold_margin_color(true, colors.white)
view:set_fold_margin_hi_color(true, colors.white)

-- Markers.
-- view.marker_fore[textadept.bookmarks.MARK_BOOKMARK] = colors.white
view.marker_back[textadept.bookmarks.MARK_BOOKMARK] = colors.blue
-- view.marker_fore[textadept.run.MARK_WARNING] = colors.white
view.marker_back[textadept.run.MARK_WARNING] = colors.yellow
-- view.marker_fore[textadept.run.MARK_ERROR] = colors.white
view.marker_back[textadept.run.MARK_ERROR] = colors.red
for i = view.MARKNUM_FOLDEREND, view.MARKNUM_FOLDEROPEN do -- fold margin
	view.marker_fore[i] = colors.white
	view.marker_back[i] = colors.dark_grey
	view.marker_back_selected[i] = colors.black
end

-- Indicators.
view.indic_fore[ui.find.INDIC_FIND] = colors.yellow
view.indic_alpha[ui.find.INDIC_FIND] = 0x80
view.indic_fore[textadept.editing.INDIC_HIGHLIGHT] = colors.yellow
view.indic_alpha[textadept.editing.INDIC_HIGHLIGHT] = 0x80
view.indic_fore[textadept.snippets.INDIC_PLACEHOLDER] = colors.black
view.indic_fore[textadept.run.INDIC_WARNING] = colors.yellow
view.indic_fore[textadept.run.INDIC_ERROR] = colors.red

-- Call tips.
view.call_tip_fore_hlt = colors.blue

-- Long Lines.
view.edge_color = colors.dark_grey

-- Find & replace pane entries.
ui.find.entry_font = font .. ' ' .. size
