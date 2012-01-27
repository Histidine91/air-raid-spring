-- $Id: gui_idle_builders_new.lua 3797 2009-01-18 00:47:40Z licho $

function widget:GetInfo()
  return {
    name      = "Lives",
    desc      = "Number of lives left",
    author    = "KingRaptor",
    date      = "22 Jan 2012",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
include("colors.h.lua")

local vsx, vsy = widgetHandler:GetViewSizes()

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end

local MAX_ICONS = 5
local ICON_SIZE_X = 32
local ICON_SIZE_Y = 32
local POSITION_R = 0
local POSITION_Y = 0

local texture = "LuaUI/Images/selector/f81_icon.png"

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function DrawIcons(number)
	local rbound = vsx - POSITION_R
	local y1 = vsy - POSITION_Y
	local y2 = vsy - ICON_SIZE_Y - POSITION_Y 
	gl.Texture(texture)
	for i=1,number do
		gl.TexRect(rbound - (i+1)*(ICON_SIZE_X), y1, rbound - (i)*(ICON_SIZE_X), y2)	-- the icon is actually flipped vertically here but it don't really matter
	end
	gl.Texture(false)
end


------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
function widget:Initialize()
  local _, _, spec = Spring.GetPlayerInfo(Spring.GetMyPlayerID())
  if spec then
	--widgetHandler:RemoveWidget()
  end
end

function widget:DrawScreen()
	local teamID = Spring.GetMyTeamID()
	local numLives = Spring.GetTeamRulesParam(teamID, "numlives") or 0
	DrawIcons(numLives, vsx, vsy)
end

