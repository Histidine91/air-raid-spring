--deep not safe with circular tables! defaults To false
local function CopyTable(tableToCopy, deep)
  local copy = {}
  for key, value in pairs(tableToCopy) do
    if (deep and type(value) == "table") then
      copy[key] = CopyTable(value, true)
    else
      copy[key] = value
    end
  end
  return copy
end

blinkyLightWhite = {
  life        = 60,
  lifeSpread  = 0,
  size        = 1,
  sizeSpread  = 0,
  colormap    = { {1, 1, 1, 0.02}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} },
  texture     = 'bitmaps/GPL/smallflare.tga',
  count       = 1,
  repeatEffect = true,
}

local blinkyLightColors = {
	Red = {1, 0.1, 0.1, 0.02},
	Blue = {0.1, 0.1, 1, 0.02},
	Green = {0, 1, 0.2, 0.02},
	Orange = {0.8, 0.2, 0., 0.02},
	Violet = {0.5, 0, 0.6, 0.02},
}

for name, color in pairs(blinkyLightColors) do
	local key = "blinkyLight"..name
	widget[key] = CopyTable(blinkyLightWhite, true)
	widget[key]["colormap"][1] = color
end