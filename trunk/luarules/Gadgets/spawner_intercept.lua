function gadget:GetInfo()
	return {
		name = "Intercept Spawner",
		desc = "Spawns enemies for Intercept mode",
		author = "KingRaptor (L.J. Lim)",
		date = "24 Jan 2012",
		license = "Public Domain",
		layer = 8,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

if not (Spring.GetModOptions().gamemode == "intercept") then
	return
end

local SPAWN_ALT = 100

local currentEnemies = {}
local waveNum = 0
local gracePeriod = 5*30	-- gameframes
local nextWave = gracePeriod

local teams

local gaiaTeamID = Spring.GetGaiaTeamID()

local waves={
	{
		enemies = {	{"wasp", "wasp"}, },
		time = 45
	},
	{
		enemies = {	{"wasp", "wasp", "python", "python"}, },
		time = 75
	},
	{
		enemies = {	{"hawk", "hawk"}, },
		time = 90
	},
	{
		enemies = {	{"hawk", "hawk", "wasp", "wasp"}, },
		time = 120
	},
	{
		enemies = {	{"hawk", "wasp", "wasp", "python", "python"}, },
		time = 150
	},
	{
		enemies = {	{"hawk", "python", "python"}, {"wasp", "wasp", "wasp"}, },
		time = 150
	},
	{
		enemies = {	{"hawk", "wasp", "wasp"}, {"hawk", "wasp", "wasp"}, },
		time = 180
	},
	{
		enemies = {	{"wasp", "wasp", "wasp", "wasp"}, {"wasp", "wasp", "wasp", "wasp"}, },
		time = 180
	},
	{
		enemies = {	{"hawk", "hawk", "hawk"}, {"hawk", "hawk", "hawk"}, },
		time = 240
	},
	{
		enemies = {	{"hawk", "wasp", "wasp", "python", "python"}, {"hawk", "wasp", "wasp", "python", "python"}, {"hawk", "wasp", "wasp", "python", "python"},},
		time = 300
	},		
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function SetCount(set)
	local count = 0
	for k in pairs(set) do
		count = count + 1
	end
	return count
end

local function GetRandomEnemyPosition()
	local teamplaneList = {}
	local x, y, z
	for i,v in pairs(GG.teamplane) do
		teamplaneList[#teamplaneList+1] = v.unit
	end
	if #teamplaneList > 0 then
		local target = teamplaneList[math.random(#teamplaneList)]
		--Spring.Echo("targeting ".. target)
		x, y, z = Spring.GetUnitPosition(target)
	else
		-- all players not airborne? spawncamp the noobs
		Spring.Echo("spawncamping")
		local team = gaiaTeamID
		while team == gaiaTeamID do
			team = teams[math.random(#teams)]
		end
		local startPos = GG.shuffledStartPosition[team]
		x, y, z = unpack(startPos)
	end
	return x+math.random(-1500, 1500), z+math.random(-1500, 1500)
end

local function AttackNearestEnemy(unitID)
	local targetID = Spring.GetUnitNearestEnemy(unitID)
	if (targetID) then
		Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, {})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GameFrame(f)
	if f == nextWave then
		waveNum = waveNum + 1
		local data = waves[waveNum]
		if not data then return end
		--land/air
		for a=1,#teams-1 do
			for b=1,#data.enemies do
				local cx, cz = GetRandomEnemyPosition()
				for c=1,#data.enemies[b] do
					local name = data.enemies[b][c]
					local x,z=cx+math.random(-60,60),cz+math.random(-60,60)
					local y=Spring.GetGroundHeight(x,z)
					local nu=Spring.CreateUnit(name,x,y+SPAWN_ALT,z,math.random(0,3),gaiaTeamID)
					currentEnemies[nu] = true
					AttackNearestEnemy(nu)
				end
			end
		end
		Spring.Echo("Wave ".. waveNum .. " incoming!")
		nextWave = f + (data.time)*30		
	end
	if f%90 == 0 then
		for unitID in pairs(currentEnemies) do
			local cmdQueue = Spring.GetUnitCommands(unitID)
			if (not (cmdQueue and cmdQueue[1])) then
				AttackNearestEnemy(unitID)
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if currentEnemies[unitID] then
		currentEnemies[unitID] = nil
		local enemiesLeft = SetCount(currentEnemies)
		if enemiesLeft == 0 then
			Spring.Echo("Wave ".. waveNum .. " complete!")
			if waves[waveNum+1] then
				nextWave = Spring.GetGameFrame() + 5*30
			else
				GG.WinAllAllyTeams()
			end
		end
	end
end

function gadget:Initialize()
	teams = Spring.GetTeamList()
end

else

--UNSYNCED

return false

end
