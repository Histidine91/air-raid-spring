local versionNumber = "1.2"

function widget:GetInfo()
	return {
	name	= "Aircraft Selector",
	desc	= "[v" .. string.format("%s", versionNumber ) .. "] Shows plane choices and information.",
	author	= "SirMaverick",
	date	= "2009,2010",
	license	= "GNU GPL, v2 or later",
	layer	= 1,
	enabled	= true,
	}
end

----------------------------------------------
if (VFS.FileExists("mission.lua")) then
	return
end

include("Configs/plane_selector.lua")

local debug	= false --generates debug message
local Echo	= Spring.Echo

local Chili
local Window
local screen0
local Image
local Button
local StackPanel

local vsx, vsy = 1280, 1024
local posterx, postery, buttonSpace
local windowCreated = false

local modoptions = Spring.GetModOptions()

local mainWindow
local buttonWindow
local button
local buttonImg

---------------------------------------------
local function PlaySound(filename, ...)
	local path = filename..".WAV"
	if (VFS.FileExists(path)) then
		Spring.PlaySoundFile(path, ...)
	else
	--Spring.Echo(filename)
		Spring.Echo("<Aircraft Selector>: Error - file "..path.." doesn't exist.")
	end
end

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end

--local gameDate = os.date(t)
--if (gameDate.month == 4) and (gameDate.day == 1) then optionData.communism.sound = "LuaUI/Sounds/communism/tetris.wav" end

-- set poster size (3/4 ratio)
local function posterSize(num)
	if num < 2 then
		local a,b = 450, 450
	-- for those who play with 800x600; but consider card upgrade!
			if b > 0.8*vsy then
				local scale = 0.8*vsy/b
				a = scale * a
				b = scale * b
			end
			return a, b, 60
	else
	-- scale to 80% of screen width
		local spacex = vsx * 0.8 / num
		if spacex < 300 then
			return spacex, spacex, 60
		else
			return 300, 300, 60
		end
	end
end

-- needs to be a global so chili can reach out and call it?
function printDebug( value )
	if ( debug ) then Echo( value )
	end
end

function Close(selectionMade)
	--Spring_SendCommands("say: a:I chose " .. option.button})
	screen0:AddChild(buttonWindow)
end

local function CreateLoadoutSelection(option)
	screen0:RemoveChild(mainWindow)
	local window, image, stack
	window = Window:New{
		parent = screen0,
		resizable = false,
		draggable = false,
		clientWidth  = posterx + 400,
		clientHeight = postery + buttonspace +12 ,--there is a title (caption below), height is not just poster+buttons
		x = (vsx - posterx - 400)/2,
		y = ((vsy - postery - buttonspace)/2),
		caption = "LOADOUT SELECTION",
	}
	image = Image:New{
		parent = window,
		file = option.img,--lookup Configs/startup_info_selector.lua to get optiondata
		file2 = option.img2,
		tooltip = option.tooltip,
		width = posterx,
		height = postery,
		x = 0,
		padding = {1,1,1,1},
		y = 9
	}
	stack =  StackPanel:New{
		parent = window,
		autosize = true,
		resizeItems = false;
		orientation   = "vertical";
		height = postery,
		width = 396,
		x = posterx + 4,
		y = 9,
		padding = {0, 0, 0, 0},
		itemMargin  = {0, 0, 0, 0},
	}
	for name, unit in pairs(option.packs) do
		local pack = weaponPacks[name]
		local button = Button:New {
			parent = stack,
			caption = pack.name,
			tooltip = pack.tooltip, --added comm name under cursor on tooltip too, like for posters
			width = "100%",
			height = 40,
			padding = {1,1,1,1},
			OnMouseUp = {function()
					Spring.SendLuaRulesMsg("plane:"..unit)
					Close()
					window:Dispose()
				end
			},
		}
		if pack.image then
			local buttonImage = Image:New{
				parent = button,
				file = pack.image,
				width = 32,
				height = 32,
				x = 0,
				padding = {1,1,1,1},
				y = 0,	
			}
		end
	end
	local backButton = Button:New{
		parent = window,
		caption = "Back",
		tooltip = "Return to aircraft selection",
		width = (posterx+400)*0.75,
		height = 30,
		x = ((posterx+400)*0.25)/2,
		y = postery+12,
		--OnMouseUp = {Close}
		OnClick = {function()
				ShowWindow()
				window:Dispose()
			end
		}
	}	
	local closeButton = Button:New{
		parent = window,
		caption = "CLOSE",
		tooltip = "CLOSE\nNo selection made",
		width = (posterx+400)*0.75,
		height = 30,
		x = ((posterx+400)*0.25)/2,
		y = postery + (buttonspace)/2+14,
		--OnMouseUp = {Close}
		OnClick = {function()
				Close()
				window:Dispose()
			end
		}
	}	
end

local function CreateWindow()
	windowCreated = true
	vsx, vsy = widgetHandler:GetViewSizes()
	-- count options
	local active = 0
	for name,option in pairs(optionData) do
		if option.enabled then
			active = active + 1
		end
	end

	posterx, postery, buttonspace = posterSize(active)

	-- create window
	mainWindow = Window:New{
		resizable = false,
		draggable = false,
		clientWidth  = posterx*active,
		clientHeight = postery + buttonspace +12 ,--there is a title (caption below), height is not just poster+buttons
		x = (vsx - posterx*active)/2,
		y = ((vsy - postery - buttonspace)/2),
		caption = "AIRCRAFT SELECTION",
	}
	
	-- add posters
	local i = 0
	for name,option in pairs(optionData) do
		if option.enabled then
			local image = Image:New{
				parent = mainWindow,
				file = option.img,
				file2 = option.img2,
				tooltip = option.tooltip,
				caption = option.name,
				width = posterx,
				height = postery,
				x = (i*posterx),
				padding = {1,1,1,1},
				OnClick = {function() CreateLoadoutSelection(option) end},
				y = 9 
			}
			local buttonWidth = posterx*2/3
				local button = Button:New {
					parent = mainWindow,
					x = i*posterx + (posterx - buttonWidth)/2, --placement of comms names' buttons @ the middle of each poster
					y = postery+12,
					caption = option.name,
					tooltip = option.tooltip,
					width = buttonWidth,
					height = 30,
					padding={1,1,1,1},
					OnMouseUp = {function() CreateLoadoutSelection(option) end},
				}
			i = i + 1
		end
	end
	local cbWidth = posterx*active*0.75-- calculate width of close button depending of number or posters
	local closeButton = Button:New{
		parent = mainWindow,
		caption = "CLOSE",
		tooltip = "CLOSE\nNo selection made",
		width = cbWidth,
		height = 30,
		x = (posterx*active - cbWidth)/2,
		y = postery + (buttonspace)/2+14,
		--OnMouseUp = {Close}
		OnClick = {function()
			screen0:RemoveChild(mainWindow)
			Close(false)
		end}
	}
end

function ShowWindow()
	if not windowCreated then
		CreateWindow()
	end
	screen0:AddChild(mainWindow)
	screen0:RemoveChild(buttonWindow)
end

function widget:Initialize()
	if not (WG.Chili) then
		widgetHandler:RemoveWidget()
	end
	if (Spring.GetSpectatingState() or Spring.IsReplay()) then
		Spring.Echo("<Plane Selector> Spectator mode or replay. Widget removed.")
		widgetHandler:RemoveWidget()
	end
	-- chili setup
	Chili = WG.Chili
	Window = Chili.Window
	screen0 = Chili.Screen0
	Image = Chili.Image
	Button = Chili.Button
	StackPanel = Chili.StackPanel

	vsx, vsy = widgetHandler:GetViewSizes()
	if vsx == 1 then vsx = 1024 end
	if vsy == 1 then vsy = 768 end
	
	buttonWindow = Window:New{
		resizable = false,
		draggable = false,
		width = 64,
		height = 64,
		right = 0,
		y = 128,
		parent = screen0,
		tweakDraggable = true,
		color = {0, 0, 0, 0},
		padding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0}
	}	
	
	button = Button:New{
		parent = buttonWindow,
		caption = '',
		tooltip = "Open plane selection screen",
		width = "100%",
		height = "100%",
		x = 0,
		y = 0,
		--OnMouseUp = {Close}
		OnClick = {ShowWindow}	
	}
	
	buttonImage = Image:New{
		parent = button,
		width="100%";
		height="100%";
		x=0;
		y=0;
		file = "LuaUI/Images/selector/f81_icon.png",
		keepAspect = false,
	}	
end

 
function widget:Shutdown()
end