function gadget:GetInfo()
	return {
		name = "Raid Spawner",
		desc = "spawns convoys for the player to shoot at",
		author = "KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 8,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

local modOptions = Spring.GetModOptions()
local gamemode = modOptions.gamemode or "raid"
if not (gamemode=="raid" or gamemode =="dogfightplus") then
	return
end

local rate = (tonumber(modOptions.spawnrate) or 60)*30
local mult = tonumber(modOptions.spawnmult) or 1

local maxTries = 51

local counts={
	truck={start=3,increase=.3,random=.3,limit=100},
	flaktank={start=.1,increase=.1,random=1,limit=20},
	wasp={start=-.4,increase=.1,random=2,limit=10},
	sam={start=-1,increase=.2,random=1,limit=15},
	hawk={start=.05,increase=0,random=1,limit=2},
	condor={start=0.3,increase=.2,random=1,limit=20},	
	python={start=0,increase=.1,random=1,limit=10},
	--gunboat={start=-1,increase=.1,random=.5,limit=5, isSea=true},
	--cruiser={start=-4,increase=.05,random=.2,limit=2, isSea=true},
}

function gadget:GameFrame(f)
	if (f%rate) < .1 then
		--land/air
		for i=1,3 do
			local cx=math.random(Game.mapSizeX)
			local cz=math.random(Game.mapSizeZ)
			local i=1
			while Spring.GetGroundHeight(cx,cz) < 0 and i < 50 do
				cx=math.random(Game.mapSizeX)
				cz=math.random(Game.mapSizeZ)
				i=i+1
			end
			local gx=math.random(Game.mapSizeX)
			local gz=math.random(Game.mapSizeZ)
			local progress=(f/rate)
			local ucount=Spring.GetTeamUnitsCounts(Spring.GetGaiaTeamID())
			for name,d in pairs(counts) do
				for i=1,math.min(d.limit - (ucount[UnitDefNames[name].id] or 0),d.start + d.increase*progress + d.random*math.random())*mult do
					if d.isSea then
						break
					end
					local x,z=cx+math.random(-60,60),cz+math.random(-60,60)
					local y=Spring.GetGroundHeight(x,z)
					local j=1
					while (y < 0) and j < maxTries do
						x,z=cx+math.random(-60,60),cz+math.random(-60,60)
						j=j+1
						y=Spring.GetGroundHeight(x,z)
					end
					if j < maxTries then
						local nu=Spring.CreateUnit(name,x,y,z,math.random(0,3),Spring.GetGaiaTeamID())
						Spring.GiveOrderArrayToUnitArray({nu},{{CMD.PATROL,{gx,0,gz},{}}}) --,{CMD.SELFD,{},{"shift"}}})
					end
				end
			end
		end
		--ships
		for i=1,1 do
			local cx=math.random(Game.mapSizeX)
			local cz=math.random(Game.mapSizeZ)
			local i=1
			while Spring.GetGroundHeight(cx,cz) >= 0 and i < 50 do
				cx=math.random(Game.mapSizeX)
				cz=math.random(Game.mapSizeZ)
				i=i+1
			end
			local gx=math.random(Game.mapSizeX)
			local gz=math.random(Game.mapSizeZ)
			local progress=(f/rate)
			local ucount=Spring.GetTeamUnitsCounts(Spring.GetGaiaTeamID())
			for name,d in pairs(counts) do
				for i=1,math.min(d.limit - (ucount[UnitDefNames[name].id] or 0),d.start + d.increase*progress + d.random*math.random())*mult do
					if not d.isSea then
						break
					end
					local x,y,z=cx+math.random(-60,60),0,cz+math.random(-60,60)
					local j=1
					while (Spring.GetGroundHeight(x,z) >= 0) and j < maxTries do
						x,z=cx+math.random(-60,60),cz+math.random(-60,60)
						j=j+1
					end
					if j < maxTries then
						local nu=Spring.CreateUnit(name,x,y,z,math.random(0,3),Spring.GetGaiaTeamID())
						Spring.GiveOrderArrayToUnitArray({nu},{{CMD.PATROL,{gx,0,gz},{}}}) --,{CMD.SELFD,{},{"shift"}}})
					end
				end
			end
		end		
		Spring.Echo("Spawned convoy")
	end
end

else

--UNSYNCED

return false

end
