function gadget:GetInfo()
	return {
		name = "Plane FX",
		desc = "stuff",
		author = "KingRaptor (L.J. Lim)",
		date = "24 Jan 2012",
		license = "Public Domain",
		layer = 25,
		enabled = true
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local maxThrottleDelta = 0.02	-- per gameframe
local minSpeedForThruster = 0.6

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local fxNames = {
	["f-81"] = {
		engine = "missiletrailred",
	},
}

local fxMap = {}
for plane, data in pairs(fxNames) do
	local unitDefID = UnitDefNames[plane].id
	fxMap[unitDefID] = data
end

local planedata, teamplane
local power = {}

local pieceMap = {}

function gadget:GameFrame(n)
	SendToUnsynced("PlaneFX_GameFrame")
	for team,p in pairs(teamplane) do
		if fxMap[p.ud] then
			local speed = p.currentspeed/planedata[p.ud].speed
			if speed < minSpeedForThruster then
				speed = 0
			end
			local powerThisFrame = power[team] or speed
			if (speed - powerThisFrame) > maxThrottleDelta then
				powerThisFrame = speed - maxThrottleDelta
			elseif (speed - powerThisFrame) < -maxThrottleDelta then
				powerThisFrame = speed + maxThrottleDelta
			else
				powerThisFrame = speed
			end
			
			-- find the piece
			for pieceName, ceg in pairs(fxMap[p.ud]) do
				local pieceNum = pieceMap[p.unit][pieceName]
				local x,y,z,dx,dy,dz = Spring.GetUnitPiecePosDir(p.unit, pieceNum)		
				Spring.SpawnCEG(ceg, x,y,z,dx,dy,dz,20,powerThisFrame)
			end
			
			power[team] = powerThisFrame
		end
	end
end


function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	pieceMap[unitID] = Spring.GetUnitPieceMap(unitID)
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	pieceMap[unitID] = nil
end

function gadget:Initialize()
	planedata = GG.planedata
	teamplane = GG.teamplane
end

else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------


function gadget:Initialize()
	gadgetHandler:AddSyncAction("PlaneFX_GameFrame", GameFrame)
end

function gadget:Shutdown()
	gadgetHandler:RemoveSyncAction("PlaneFX_GameFrame")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local jetSoundLength = 14
local gameFrame = 0

function GameFrame()
	gameFrame = gameFrame + 1
	local p=SYNCED.teamplane[Spring.GetMyTeamID()]
	if p and gameFrame >= jetSoundLength then
		local planedata=SYNCED.planedata
		local x,y,z=Spring.GetUnitPosition(p.unit)
		Spring.PlaySoundFile("sounds/jet.wav", (p.currentspeed/planedata[p.ud].speed)*0.4 + 0.3, x, y, z,
				math.sin(p.yaw) *(math.cos(p.pitch))*p.currentspeed,
				-math.sin(p.pitch)*p.currentspeed,
				math.cos(p.yaw) *(math.cos(p.pitch))*p.currentspeed,
				"sfx"
			)
		gameFrame = 0
	end	
end

end
