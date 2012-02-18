local function ReturnFalse()
	return false
end

--local noCustomComms = ((Spring.GetModOptions().commandertypes == nil or Spring.GetModOptions().commandertypes == '') and true) or false
--local function ReturnNoCustomComms()
--	return noCustomComms
--end

local color = {
	red = "\255\255\32\32",
	orange = "\255\255\96\0",
	purple = "\255\255\0\255",
	teal = "\255\0\192\192",
	blue = "\255\0\128\255",
}

--[[
local weaponColors = {
	gun = "red",
	airtoair = "blue",
	multirole = "orange",
	longshot = "teal",
}

local MakeWeaponString(unitDefName)
	local str
	local unitDef = UnitDefs[unitDefName]
	if unitDef then
		local weapons = unitDef.weapons
		for i=1,#weapons do
			local weaponDef = WeaponDefs[weapons[i].id]
			if weaponDef then
				str = str + "\n\t" .. weaponColors[weaponDef.name] .. weaponColors[weaponDef.name] .. "\008"
				
			end
		end
		return str
	else
		Spring.Echo("<Plane Selector> Unable to find unitdef " .. unitDefName)
	end
end
]]--

local optionData = {
	f81 = {
		enabled = function() return true end,
		poster = "LuaUI/Images/selector/f81.png",
		poster2 = "LuaUI/Images/selector/background.png",
		selector = "F-81 Arrowhead",
		tooltip =	"Multirole fighter with good performance.\n"..
					"Armament:\n"..
					"\t"..color.red.."25mm Vulcan\008 x 1500\n"..
					"\t"..color.blue.."Air-to-Air Missile\008 x 2\n"..
					"\t"..color.orange.."Multirole Missile\008 x 4",
		button = function()
			Spring.SendLuaRulesMsg("plane:f-81")
			Close(true)
		end
	},

	gyrfalcon = {
		enabled = function() return true end,
		poster = "LuaUI/Images/selector/gyrfalcon.png",
		poster2 = "LuaUI/Images/selector/background.png",
		selector ="F-37 Gyrfalcon",
		tooltip =	"Air superiority fighter with superior mobility but light armor."..
					"\nArmament:\n"..
					"\t"..color.red.."25mm Vulcan\008 x 1200\n"..
					"\t"..color.blue.."Air-to-Air Missile\008 x 4\n"..
					"\t"..color.orange.."Multirole Missile\008 x 2",
		button = function() 
			Spring.SendLuaRulesMsg("plane:gyrfalcon")
			Close(true)
		end 
	},
	
	hawk = {
		enabled = function() return true end,
		poster = "LuaUI/Images/selector/hawk.png",
		poster2 = "LuaUI/Images/selector/background.png",
		selector = "F-41 Hawk-P",
		tooltip =	"Fast interceptor retrofitted with guns."..
					"\nArmament:\n"..
					"\t"..color.red.."25mm Vulcan\008 x 1200\n"..
					"\t"..color.teal.."Longshot Missile\008 x 4",
		button = function() 
			Spring.SendLuaRulesMsg("plane:hawkp")
			Close(true)
		end 
	},
	
	destiny = {
		enabled = function() return (Spring.GetModOptions().enabledestiny == "1") end,
		poster = "LuaUI/Images/selector/destiny.png",
		poster2 = "LuaUI/Images/selector/background.png",
		selector = "B-3 Destiny",
		tooltip =	"Heavy bomber with nuclear strike capability."..
					"\nArmament:\n"..
					"\t"..color.orange.."Multirole Missile\008 x 8\n"..
					"\t"..color.red.."Tactical Nuke\008 x 1",
		button = function() 
			Spring.SendLuaRulesMsg("plane:destiny")
			Close(true)
		end 
	},		
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- most of the data processing was moved to api_modularcomms.lua
--[[
local commDataOrdered = {}
local numComms = 0
for seriesName, comms in pairs(WG.commData) do
	numComms = numComms + 1
	commDataOrdered[numComms] = comms
	commDataOrdered[numComms].seriesName = seriesName
end
table.sort(commDataOrdered, function(a,b) return a[1] < b[1] end)

local chassisImages = {
	armcom1 = "LuaUI/Images/startup_info_selector/chassis_strike.png",
	corcom1 = "LuaUI/Images/startup_info_selector/chassis_battle.png",
	commrecon1 = "LuaUI/Images/startup_info_selector/chassis_recon.png",
	commsupport1 = "LuaUI/Images/startup_info_selector/chassis_support.png",
}

local colorWeapon = "\255\255\32\32"
local colorConversion = "\255\255\96\0"
local colorWeaponMod = "\255\255\0\255"
local colorModule = "\255\128\128\255"

local function WriteTooltip(seriesName)
	local data = WG.GetCommSeriesInfo(seriesName, true)
	local str = ''
	local upgrades = WG.GetCommUpgradeList()
	for i=1,#data do
		str = str .. "\nLEVEL "..i.. " ("..data[i].cost.." metal)\n\tModules:"
		for j, modulename in pairs(data[i].modules) do
			if upgrades[modulename] then
				local substr = upgrades[modulename].name
				-- assign color
				if (modulename):find("commweapon_") then
					substr = colorWeapon..substr
				elseif (modulename):find("conversion_") then
					substr = colorConversion..substr
				elseif (modulename):find("weaponmod_") then
					substr = colorWeaponMod..substr
				else
					substr = colorModule..substr
				end
				str = str.."\n\t\t"..substr.."\008"
			end
		end
	end
	return str
end

local function CommSelectTemplate(num, seriesName, comm1Name)
	local option = {
		enabled = function() return true end,
		poster = chassisImages[UnitDefNames[comm1Name].customParams.statsname],
		poster2 = "LuaUI/Images/startup_info_selector/customcomm"..num..".png",
		selector = seriesName,
		tooltip = "Select comm config number "..num.." ("..seriesName..")"..WriteTooltip(seriesName),
		button = function()
			Spring.SendLuaRulesMsg("customcomm:"..seriesName)
			Spring.SendCommands({'say a:I choose: '..seriesName..'!'})
			Close(true)
		end
	}
	
	return option
end	

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local i = 0
for i = 1, numComms do
	local option = CommSelectTemplate(i, commDataOrdered[i].seriesName, commDataOrdered[i][1])
	optionData[#optionData+1] = option
end
]]--

return optionData