local copy = {
	["f-81"] = {
		["f-81_2"] = {
			weapons = {
				[2] = {name = "fuelairbomb", maxangledif = false,}
			},
			customparams = {
				ammo1=2,
				reload1=30,
				cone1=64,
				dist1=300,
				name1="Fuel-Air",
				isbomb1=1,
				dumbfire1=1,
			},
		},
	},
	gyrfalcon = {
		gyrfalcon_2 = {
			weapons = {
				[4] = {name = "allaspect"}
			},
			script = "gyrfalcon.cob",
			customparams = {
				ammo2 = 2,
				
				ammo3=2,
				reload3=20,
				cone3=20,
				dist3=500,
				name3="A-Aspect";
			},
		},
	},
}

local function MergeTable(base, into)
	for i,v in pairs(into) do
		if type(v) == "table" then
			base[i] = base[i] or {}
			MergeTable(base[i], v)
		else
			--Spring.Echo(i, v)
			base[i] = v
		end
	end
end

for sourceName, copyTable in pairs(copy) do
	for cloneName, stats in pairs(copyTable) do
		UnitDefs[cloneName] = CopyTable(UnitDefs[sourceName], true)
		UnitDefs[cloneName].unitname = cloneName

		--[[
		Spring.Echo(cloneName)
		for i=1,#UnitDefs[cloneName].weapons do
			local table = UnitDefs[cloneName].weapons[i]
			Spring.Echo(i)
			for i,v in pairs(table) do
				Spring.Echo(i,v)
			end
		end
		]]
		MergeTable(UnitDefs[cloneName], stats)
		

	end
end