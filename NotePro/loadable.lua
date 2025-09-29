---------------------------------------------------------------------------
-- NotePro - loadable.lua
-- Displays up to 6 lines of text, with optional fullscreen mode (FS Mode).
-- In normal mode: all lines (1–6) are drawn in the widget zone.
-- In FS Mode: only Line1 shows in the zone, and in fullscreen Line1
-- appears in the header while Lines2–6 are shown in the body.
---------------------------------------------------------------------------

local zone, options = ...

local widget = { zone = zone, options = options or {} }

-- Alignment flag
-- 1=Left, 2=Center, 3=Right
local function alignFlag(idx)
  if idx == 1 then return LEFT end
  if idx == 3 then return RIGHT end
  return CENTER -- default
end

-- Font selection
-- 1=Small, 2=Medium, 3=Large, 4=XLarge
local function fontFromChoice(idx)
  if idx == 1 then return SMLSIZE end
  if idx == 3 then return DBLSIZE end
  if idx == 4 then return XXLSIZE end
  return MIDSIZE -- default
end

-- Normalize a string: returns nil if empty or nil
local function norm(s)
  return (s and s ~= "") and s or nil
end

-- Collect lines 1–6 from options (for normal mode)
local function collectLines(opts)
  local t = {}
  if norm(opts.Line1) then t[#t+1] = opts.Line1 end
  if norm(opts.Line2) then t[#t+1] = opts.Line2 end
  if norm(opts.Line3) then t[#t+1] = opts.Line3 end
  if norm(opts.Line4) then t[#t+1] = opts.Line4 end
  if norm(opts.Line5) then t[#t+1] = opts.Line5 end
  if norm(opts.Line6) then t[#t+1] = opts.Line6 end
  return t
end

-- Collect lines 2–6 from options (for FS Mode body only)
local function collectBodyFS(opts)
  local t = {}
  if norm(opts.Line2) then t[#t+1] = opts.Line2 end
  if norm(opts.Line3) then t[#t+1] = opts.Line3 end
  if norm(opts.Line4) then t[#t+1] = opts.Line4 end
  if norm(opts.Line5) then t[#t+1] = opts.Line5 end
  if norm(opts.Line6) then t[#t+1] = opts.Line6 end
  return t
end

-- Draw multiple lines
local function drawLines(x, y, w, h, lines, color, font, aflag)
  if #lines == 0 then return end

  lcd.setColor(CUSTOM_COLOR, color or (COLOR_THEME_PRIMARY1 or WHITE))
  local flags = (font or MIDSIZE) + CUSTOM_COLOR + aflag + SHADOWED

  -- Line height: measure with "A" + padding
  local lh = select(2, lcd.sizeText("A", flags)) + 2
  local blockH = #lines * lh
  local cy = y + (h - blockH) // 2 -- vertical centering

  for i = 1, #lines do
    local ax = (aflag == RIGHT)  and (x + w)
             or (aflag == CENTER and (x + w // 2) or x)
    lcd.drawText(ax, cy + (i-1)*lh, lines[i], flags)
  end
end

---------------------------------------------------------------------------
-- Renderers
---------------------------------------------------------------------------

-- Fullscreen rendering
local function render_fullscreen()
  local align  = widget.options.Align
  local color  = widget.options.TextColor or (COLOR_THEME_PRIMARY1 or WHITE)
  local aflag  = alignFlag(align)
  local fsOn   = (widget.options["FS Mode"] == 1) or (widget.options["FS Mode"] == true)

  -- Header bar
  lcd.drawFilledRectangle(0, 0, LCD_W, 40, COLOR_THEME_SECONDARY1 or GREY)
  lcd.setColor(CUSTOM_COLOR, COLOR_THEME_PRIMARY2 or WHITE)
  local headerText = norm(widget.options.Line1) or " "
  lcd.drawText(10, 20, headerText, VCENTER + DBLSIZE + CUSTOM_COLOR + SHADOWED)

  -- Body content
  local bodyLines, bodyFont
  if fsOn then
    -- FS Mode: show Lines 2–6, force Large font
    bodyLines = collectBodyFS(widget.options)
    bodyFont  = DBLSIZE
    if #bodyLines == 0 then bodyLines = {" "} end
  else
    -- Normal fullscreen: show Lines 1–6, with selected TextSize
    bodyLines = collectLines(widget.options)
    if #bodyLines == 0 then bodyLines = {" "} end
    bodyFont = fontFromChoice(widget.options.TextSize)
  end

  drawLines(10, 40, LCD_W - 20, LCD_H - 40, bodyLines, color, bodyFont, aflag)
end

-- Zone (dashboard) rendering
local function render_zone()
  local x, y, w, h = widget.zone.x, widget.zone.y, widget.zone.w, widget.zone.h
  local align  = widget.options.Align
  local color  = widget.options.TextColor or (COLOR_THEME_PRIMARY1 or WHITE)
  local aflag  = alignFlag(align)
  local fsOn   = (widget.options["FS Mode"] == 1) or (widget.options["FS Mode"] == true)

  local lines, font = {}, fontFromChoice(widget.options.TextSize)

  if fsOn then
    -- FS Mode in zone: show only Line1
    if norm(widget.options.Line1) then lines[1] = widget.options.Line1 end
  else
    -- Normal mode: show Lines 1–6
    lines = collectLines(widget.options)
  end

  if #lines == 0 then return end
  drawLines(x + 2, y + 2, w - 4, h - 4, lines, color, font, aflag)
end

---------------------------------------------------------------------------
-- Lifecycle functions
---------------------------------------------------------------------------

function widget.create(zone_, options_)
  widget.zone    = zone_    or widget.zone
  widget.options = options_ or widget.options
  return widget
end

function widget.update(options_)
  widget.options = options_ or widget.options
end

function widget.background()
  -- Nothing needed for background updates
end

function widget.refresh(event, touchState)
  if event ~= nil then
    render_fullscreen()
  else
    render_zone()
  end
end

return widget
