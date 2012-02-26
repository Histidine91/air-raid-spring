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
	green = "\255\0\255\0",
	purple = "\255\192\64\255",
	teal = "\255\0\192\192",
	blue = "\255\0\128\255",
}

weaponPacks = {
	JointStrike1 = {
		name = "Joint Strike I",
		image = nil,
		tooltip = 	"A strong loadout capable of engaging both air and ground threats."..
				"\nArmament:"..
				"\n\t"..color.blue.."Air-to-Air Missile\008 x 2"..
				"\n\t"..color.orange.."Multirole Missile\008 x 4",
	},
	GroundSupport1 = {
		name = "Close Support I",
		image = nil,
		tooltip = 	"This loadout sacrifices air-to-air capabilities for ground attack power. The Fuel Air Bomb is devastating against large formations."..
				"\nArmament:"..
				"\n\t"..color.blue.."Air-to-Air Missile\008 x 2"..
				"\n\t"..color.red.."Fuel Air Bomb\008 x 2",
	},
	AirDomination1 = {
		name = "Air Domination I",
		image = nil,
		tooltip = 	"A loadout that focuses on air-to-air capability while retaining some ground combat ability."..
				"\nArmament:"..
				"\n\t"..color.blue.."Air-to-Air Missile\008 x 4"..
				"\n\t"..color.orange.."Multirole Missile\008 x 2",
	},
	LongRangeInterception1 = {
		name = "Long Range Interception I",
		image = nil,
		tooltip = 	"The loadout of choice for long range kill ability."..
				"\nArmament:"..
				"\n\t"..color.blue.."Longshot Missile\008 x 4",
	},
	Dogfight1 = {
		name = "Dogfight I",
		image = nil,
		tooltip = 	"This loadout is ideal for close in knife fights with highly maneuverable bandits."..
				"\nArmament:"..
				"\n\t"..color.blue.."Air-to-Air Missile\008 x 2"..
				"\n\t"..color.purple.."All Aspect Missile\008 x 2"..
				"\n\t"..color.orange.."Multirole Missile\008 x 2",
	},
	
	NuclearStrike1 = {
		name = "Nuclear Strike I",
		image = nil,
		tooltip = 	"The preferred way to start world wars (it's the only way to be sure)."..
				"\nArmament:"..
				"\n\t"..color.orange.."Multirole Missile\008 x 6"..
				"\n\t"..color.red.."Tactical Nuclear Missile\008 x 1",
	},	
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

optionData = {
	f81 = {
		enabled = true,
		img = "LuaUI/Images/selector/f81.png",
		img2 = "LuaUI/Images/selector/background.png",
		name = "F-81 Arrowhead",
		tooltip =	"Multirole fighter with good performance."..
				"\nCannon: 25mm Vulcan x 1500"..
				"\nLoadouts:"..
				"\n\t"..color.green.."Joint Strike I\008"..
				"\n\t"..color.orange.."Ground Support I\008",
		packs = {JointStrike1 = "f-81", GroundSupport1 = "f-81_2"},
	},

	gyrfalcon = {
		enabled = true,
		img = "LuaUI/Images/selector/gyrfalcon.png",
		img2 = "LuaUI/Images/selector/background.png",
		name = "F-37 Gyrfalcon",
		tooltip =	"Air superiority fighter with superior mobility but light armor."..
					"\nCannon: 25mm Vulcan x 1200"..
					"\nLoadouts:"..
					"\n\t"..color.teal.."Air Domination I\008"..
					"\n\t"..color.blue.."Dogfight I\008",
		packs = {AirDomination1 = "gyrfalcon", Dogfight1 = "gyrfalcon_2"},
	},
	
	hawk = {
		enabled = true,
		img = "LuaUI/Images/selector/hawk.png",
		img2 = "LuaUI/Images/selector/background.png",
		name = "F-41 Hawk-P",
		tooltip =	"Fast interceptor retrofitted with guns."..
					"\nCannon: 25mm Vulcan x 1200"..
					"\nLoadouts:"..
					"\n\t"..color.purple.."Long Range Interception I\008",
		packs = {LongRangeInterception1 = "hawkp"},
	},
	
	destiny = {
		enabled = (Spring.GetModOptions().enabledestiny == "1"),
		img = "LuaUI/Images/selector/destiny.png",
		img2 = "LuaUI/Images/selector/background.png",
		name = "B-3 Destiny",
		tooltip =	"Heavy bomber with nuclear strike capability."..
					"\nLoadouts:"..
					"\n\t"..color.red.."Nuclear Strike I\008",
		packs = {NuclearStrike1 = "destiny"},
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
		img = chassisImages[UnitDefNames[comm1Name].customParams.statsname],
		img2 = "LuaUI/Images/startup_info_selector/customcomm"..num..".png",
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