---------------------------------------------------------------------------
-- NotePro - main.lua                                                    --
---------------------------------------------------------------------------

local name = "NotePro"
local version = "v1.0"

local function create(zone, options)
  local widget = loadScript("/WIDGETS/" .. name .. "/loadable.lua")(zone, options)
  widget.create(zone, options)
  return widget
end

local function refresh(widget, event, touchState)
  widget.refresh(event, touchState)
end

local function background(widget)
  widget.background()
end

local options = {
  { "Line1",     STRING, "" },
  { "Line2",     STRING, "" },
  { "Line3",     STRING, "" },
  { "Line4",     STRING, "" },
  { "Line5",     STRING, "" },
  { "Line6",     STRING, "" },
  { "TextSize",  CHOICE, 2, {"Small", "Medium", "Large", "XLarge"} },
  { "Align",     CHOICE, 2, {"Left", "Center", "Right"} },
  { "TextColor", COLOR,  COLOR_THEME_PRIMARY1 },
  { "FS Mode",   BOOL,   0 },
}

local function update(widget, newOptions)
  widget.update(newOptions)
end

return {
  name       = name,
  create     = create,
  refresh    = refresh,
  background = background,
  options    = options,
  update     = update
}
