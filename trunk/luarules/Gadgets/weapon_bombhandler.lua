--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Bomb Handler",
		desc = "bomb stuff",
		author = "KDR_11k (David Becker), KingRaptor (L.J. Lim)",
		date = "2009-09-08",
		license = "Public Domain",
		layer = 20,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--SYNCED
local bombing={}
local bombPhysics = {}
local scheduleSpawnCEG = {}

local bombSpeedMult = 2
local submunitions = {}

local gaia = Spring.GetGaiaTeamID()

for i=1,#WeaponDefs do
	if WeaponDefs[i]["type"] == "AircraftBomb" then
		Script.SetWatchWeapon(i, true)
	end
end

function BombDrop(u, ud, team, weaponNum)
	bombing[u] = {team = team}
	
	if not weaponNum then
		return
	end
	local weaponID = UnitDefs[ud].weapons[weaponNum].weaponDef or -1
	local wd = WeaponDefs[weaponID]
	if wd and wd.customParams and wd.customParams.submunitions then
		--Spring.Echo("Submunitions detected")
		bombing[u].submunitions = wd.customParams.submunitions
		bombing[u].height = tonumber(wd.customParams.submunitionsheight) or 100
	end	
end
GG.BombDrop = BombDrop

-- makes sound + fx
--[[
function ClusterBomb(u, ud, team, target)
	local x,y,z = Spring.GetUnitPosition(u)
	Spring.PlaySoundFile("sounds/bomb_drop.wav", 1, x, y, z, nil, nil, nil, "sfx")
	
	local vx, vy, vz = 0,0,0
	
	local plane = GG.teamplane[team]
	if plane then
		vx, vy, vz = unpack(plane.velocity)
	end
	local frame = Spring.GetGameFrame() + 5
	scheduleSpawnCEG[frame] = scheduleSpawnCEG[frame] or {}
	local toSpawn = scheduleSpawnCEG[frame] 
	toSpawn[#toSpawn+1] = {ceg = "blast_explo", pos = {x+vx/6, y+vy/6-30, z+vz/6}}
end
GG.ClusterBomb = ClusterBomb
]]

local function ActivateSubmunitions(p, x, y, z)
	--Spring.Echo("Submunitions active")
	local data = submunitions[p]
	local unitID = Spring.CreateUnit(data.def, x,y,z, 0, data.team)
	local env = Spring.UnitScript.GetScriptEnv(unitID)
	Spring.UnitScript.CallAsUnit(unitID, env.SetVelocity, unpack(data.velocity))
	Spring.UnitScript.CallAsUnit(unitID, env.Detonate)
	submunitions[p] = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:ProjectileCreated(p,owner)
	if bombing[owner] then
		local plane = GG.teamplane[bombing[owner].team]
		local x1,y1,z1 = Spring.GetProjectileVelocity(p)
		local x2,y2,z2 = 0, 0, 0
		if plane and owner == plane.unit then
			x2,y2,z2 = unpack(plane.velocity)
		elseif Spring.ValidUnitID(owner) then
			x2,y2,z2 = Spring.GetUnitVelocity(owner)
			x2,y2,z2 = x2/30, y2/30, z2/30
		end
		--Spring.SetProjectileMoveControl(p, true)
		Spring.SetProjectileVelocity(p,x1+x2+x2, y1+y2+y2, z1+z2+z2)	-- add plane velocity twice to "toss" bombs forward a bit
		--Spring.SetProjectileGravity(p, 5)
		
		if bombing[owner].submunitions then
			--Spring.Echo("Submunitions deployed")
			submunitions[p] = {
				def = bombing[owner].submunitions,
				height = bombing[owner].height,
				team = bombing[owner].team,
				velocity = {x1+x2+x2, y1+y2+y2, z1+z2+z2},
			}
			
		end
		
		bombing[owner] = nil
	end
end

function gadget:ProjectileDestroyed(p)
	if submunitions[p] then
		ActivateSubmunitions(p, Spring.GetProjectilePosition(p))
	end
end

function gadget:Initialize()
	gadgetHandler:RegisterGlobal("BombDrop",BombDrop)
	--gadgetHandler:RegisterGlobal("ClusterBomb",ClusterBomb)
end

function gadget:Shutdown()
	gadgetHandler:DeregisterGlobal("BombDrop")
end

function gadget:GameFrame(f)
	if scheduleSpawnCEG[f] then
		local toSpawn = scheduleSpawnCEG[f]
		for i=1,#toSpawn do
			Spring.SpawnCEG(toSpawn[i].ceg, unpack(toSpawn[i].pos), 0,1,0,20,100)
		end
		scheduleSpawnCEG[f] = nil
	end
	
	for projID,data in pairs(submunitions) do
		local x,y,z = Spring.GetProjectilePosition(projID)
		if y - Spring.GetGroundHeight(x,z) < data.height then
			Spring.SetProjectileCollision(projID)
		end
	end
end

else

--UNSYNCED

end
