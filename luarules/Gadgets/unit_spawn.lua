function gadget:GetInfo()
  return {
    name      = "Unit Spawn",
    desc      = "Makes your planes",
    author    = "KingRaptor; with help from Licho, CarRepairer, Google Frog, SirMaverick",
    date      = "2008-2010",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end


-- partially based on Spring's unit spawn gadget
include "LuaRules/Configs/start_setup.lua"

--[[
if VFS.FileExists("mission.lua") then -- this is a mission, don't mess around with stuff
  if not gadgetHandler:IsSyncedCode() then
    return false -- no unsynced code
  end
  -- do nothing
  return
end
]]--

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetTeamInfo 		= Spring.GetTeamInfo
local spGetPlayerInfo 		= Spring.GetPlayerInfo
local spGetSpectatingState 	= Spring.GetSpectatingState

local modOptions = Spring.GetModOptions()

local shuffleMode = "off"
local numLives = tonumber(modOptions.numlives) or 3
local limitless = (numLives == 0)

local gaiateam = Spring.GetGaiaTeamID()
local gaiaally = select(6, spGetTeamInfo(gaiateam))

local SAVE_FILE = "Gadgets/start_unit_setup.lua"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local gamestart = false
local createBeforeGameStart = {}
local scheduledSpawn = {}
local startPosition = {} -- [teamID] = {x, y, z}
local shuffledStartPosition = {}
local planeChoice = {} -- sides selected ingame from widgets - per teams

local customPlanes = {}
local planeChoiceCustom = {}
local customKeys = {}	-- [playerID] = {}

local waitingForPlane = {}
GG.waitingForPlane = waitingForPlane

-- allow gadget:Save (unsynced) to reach them
_G.facplops = facplops
_G.waitingForPlane = waitingForPlane
--_G.scheduledSpawn = scheduledSpawn
--_G.playerSides = playerSides
--_G.planeChoice = planeChoice

local loadGame = false	-- was this loaded from a savegame?

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:UnitCreated(unitID, unitDefID, teamID, builderID)
	--[[
	if not gamestart then
		createBeforeGameStart[#createBeforeGameStart + 1] = unitID

		-- make units blind, so that you don't see shuffled units
		Spring.SetUnitSensorRadius(unitID,"los",0)
		Spring.SetUnitSensorRadius(unitID,"airLos",0)
		Spring.SetUnitCloak(unitID, 4)
		Spring.SetUnitStealth(unitID, true)
		Spring.SetUnitNoDraw(unitID, true)
		Spring.SetUnitNoSelect(unitID, true)
		Spring.SetUnitNoMinimap(unitID, true)
		return
	end
	]]--
	--CheckForShutdown()
end

function gadget:UnitDestroyed(unitID)
end

function gadget:UnitFinished(unitID, unitDefID)
end

--local function InitUnsafe()
--	-- for name, id in pairs(playerIDsByName) do
--	for index, id in pairs(Spring.GetPlayerList()) do	
--		-- copied from PlanetWars
--		local planeData, success
--		customKeys[id] = select(10, spGetPlayerInfo(id))
--		local planeDataRaw = customKeys[id] and customKeys[id].planes
--		if not (planeDataRaw and type(planeDataRaw) == 'string') then
--			err = "Plane data entry for player "..id.." is empty or in invalid format"
--			planeData = {}
--		else
--			planeDataRaw = string.gsub(planeDataRaw, '_', '=')
--			planeDataRaw = Spring.Utilities.Base64Decode(planeDataRaw)
--			--Spring.Echo(planeDataRaw)
--			local planeDataFunc, err = loadstring("return "..planeDataRaw)
--			if planeDataFunc then 
--				success, planeData = pcall(planeDataFunc)
--				if not success then
--					err = planeData
--					planeData = {}
--				end
--			end
--		end
--		if err then 
--			Spring.Echo('Unit Spawn error: ' .. err)
--		end
--
--		-- record the player's first-level plane def for each chassis
--		for planeSeries, subdata in pairs(planeData) do
--			customPlanes[id] = customPlanes[id] or {}
--			custom{lanes[id][planeSeries] = subdata[1]
--			--Spring.Echo(id,"plane"..chassis, subdata[1])
--		end
--	end
--end


function gadget:Initialize()
  -- needed if you reload luarules
  local frame = Spring.GetGameFrame()
  if frame and frame > 0 then
    gamestart = true
	Shuffle()
  end
  
  --InitUnsafe()
  local allUnits = Spring.GetAllUnits()
  for _, unitID in pairs(allUnits) do
	local udid = Spring.GetUnitDefID(unitID)
	if udid then
		gadget:UnitCreated(unitID, udid, Spring.GetUnitTeam(unitID))
	end
  end
end


local function GetStartUnit(teamID, playerID, isAI)
	--return DEFAULT_UNIT
  local startUnit, startUnitAlt

  if (teamID and planeChoice[teamID]) then 
	startUnit = startUnits[planeChoice[teamID]]
  end
  
  --[[
  if (playerID and playerSides[playerID]) then 
	startUnit = startUnits[playerSides[playerID] ]
  end
  
  -- if a replacement def is available, use it  
  playerID = playerID or (teamID and select(2, spGetTeamInfo(teamID)) )
  if (playerID and planeChoiceCustom[playerID]) then
	--Spring.Echo("Attempting to load alternate plane")
	local altPlane = customPlanes[playerID][(planeChoiceCustom[playerID])]
	startUnit = (altPlane and UnitDefNames[altPlane] and altPlane) or startUnit
  end
  ]]--
  
  --if didn't pick a plane, wait for user to pick
  return startUnit or nil	-- startUnit or DEFAULT_UNIT
end


local function GetFacingDirection(x, z, teamID)
	local facing = "south"

	local allyCount = #Spring.GetAllyTeamList()
	if (allyCount ~= 2+1) then -- +1 cause of gaia
		-- face to map center
		facing = (math.abs(Game.mapSizeX/2 - x) > math.abs(Game.mapSizeZ/2 - z))
			and ((x>Game.mapSizeX/2) and "west" or "east")
			or ((z>Game.mapSizeZ/2) and "north" or "south")
	else
		local allyID = select(6, spGetTeamInfo(teamID))
		local enemyAllyID = gaiaally

		-- detect enemy allyid
		local allyList = Spring.GetAllyTeamList()
		for i=1,#allyList do
			if (allyList[i] ~= allyID)and(allyList[i] ~= gaiaally) then
				enemyAllyID = allyList[i]
				break
			end
		end
		assert(enemyAllyID ~= gaiaally, "couldn't detect enemy ally id!")

		-- face to enemy
		local enemyStartbox = {Spring.GetAllyTeamStartBox(enemyAllyID)}
		local midPosX = (enemyStartbox[1] + enemyStartbox[3]) * 0.5
		local midPosZ = (enemyStartbox[2] + enemyStartbox[4]) * 0.5

		local dirX = x - midPosX
		local dirZ = z - midPosZ

		if (math.abs(dirX) > math.abs(dirZ)) then
			facing = (dirX < 0)and("west")or("east")
		else
			facing = (dirZ < 0)and("south")or("north")
		end
	end

	return facing
end


local function SpawnStartUnit(teamID, playerID, isAI)
  if (not limitless) and Spring.GetTeamRulesParam(teamID, "numlives") == 0 then
	return 
  end
  if GG.teamplane[teamID] then
	return	-- already spawned
  end
  -- get start unit
  
  local startUnit = GetStartUnit(teamID, playerID, isAI)
  
  if startUnit then
    -- replace with shuffled position
    local x,y,z = unpack(shuffledStartPosition[teamID])

    -- get facing direction
    local facing = GetFacingDirection(x, z, teamID)

    -- CREATE UNIT
	local unitID = Spring.CreateUnit(startUnit, x, Spring.GetGroundHeight(x,z) + SPAWN_ALT, z, facing, teamID)
	local lives = Spring.GetTeamRulesParam(teamID, "numlives")
	if not limitless then Spring.SetTeamRulesParam(teamID, "numlives", lives - 1) end

	-- stuff
	--[[
    local teamLuaAI = Spring.GetTeamLuaAI(teamID)
    local udef = UnitDefs[Spring.GetUnitDefID(unitID)]

	local planeCost = (udef.metalCost or BASE_PLANE_COST) - BASE_PLANE_COST			
	]]--
  end
end

-- {[1] = 1, [2] = 3, [3] = 4} -> {[3] = 1, [1] = 4, [4] = 3}
local function ShuffleSequence(nums)
  local seq, shufseq = {}, {}
  for i = 1, #nums do
    seq[i] = {nums[i], math.random()}
  end
  table.sort(seq, function(a,b) return a[2] < b[2] end)
  for i = 1, #nums do
    shufseq[nums[i]] = seq[i][1]
  end
  return shufseq
end

function GetAllTeamsList()
  teamList = {}
  -- create list with all teams
  for _, alliance in ipairs(Spring.GetAllyTeamList()) do
    if alliance ~= gaiaally then
      local teams = Spring.GetTeamList(alliance)
      for _, team in ipairs(teams) do
        teamList[#teamList + 1] = team
      end
    end
  end
  return teamList
end

function Shuffle()
  -- setup startpos
  local teamIDs = Spring.GetTeamList()
  for i=1,#teamIDs do
    teamID = teamIDs[i]
    if teamID ~= gaiateam then
      startPosition[teamID] = {Spring.GetTeamStartPosition(teamID)}
      shuffledStartPosition[teamID] = startPosition[teamID]
    end
  end

  if (not shuffleMode) or (shuffleMode and shuffleMode == "off") then
    -- nothing to do

  elseif shuffleMode then

    if shuffleMode == "box" then
 
     -- shuffle for each alliance
      for _, alliance in ipairs(Spring.GetAllyTeamList()) do
        if alliance ~= gaiaally then
          local teamList = Spring.GetTeamList(alliance)
          local shuffled = ShuffleSequence(teamList)
          for _, team in ipairs(teamList) do
            shuffledStartPosition[team] = startPosition[shuffled[team]]
          end
        end

      end

    elseif shuffleMode == "all" then

      teamList = GetAllTeamsList()
      -- shuffle
      local shuffled = ShuffleSequence(teamList)
      for _, team in ipairs(teamList) do
        shuffledStartPosition[team] = startPosition[shuffled[team]]
      end      

    elseif shuffleMode == "allboxes" then

      teamList = GetAllTeamsList()
      boxPosition = {}
      --[[ Spring will replace a missing box by adding one covering the whole map.
           So if two or more boxes are missing, several planes will be placed
           in the middle of the map. ]]
      -- get box middle positions
      for _,a in ipairs(Spring.GetAllyTeamList()) do
        if a ~= gaiaally then
          local xmin, zmin, xmax, zmax = Spring.GetAllyTeamStartBox(a)
          local xmid = (xmax + xmin) / 2
          local zmid = (zmax + zmin) / 2
          local ymid = Spring.GetGroundHeight(xmid, zmid)
          local i = #boxPosition + 1
          boxPosition[i] = {xmid, ymid, zmid}
          --teamList[i] = i - 1 -- team number starts at 0
        end
      end

      if #boxPosition >= #teamList then
        -- shuffle all positions, use first #teamList positions to shuffle teams
        local nums = {}
        for i=1,#boxPosition do
          nums[#nums + 1] = i
        end
        local shuffledNums = ShuffleSequence(nums)
        for i=1,#teamList do
          startPosition[teamList[i]] = boxPosition[shuffledNums[nums[i]]]
        end

        -- shuffle
        local shuffled = ShuffleSequence(teamList)
        teamList = GetAllTeamsList()
        for _, team in ipairs(teamList) do
          shuffledStartPosition[team] = startPosition[shuffled[team]]
        end
      else
        Spring.Echo("Not enough boxes. Teams not shuffled.")
      end

    end
  end
end

--[[
   spring puts all specs on team 0, so we have to check if team 0 is
   a team with players or a ai team with specs
   if team 0 is ai team with only specs, nil is returned else
   this functions returns the playerlist unchanged
--]]
local function workAroundSpecsInTeamZero(playerlist, team)
  if team == 0 then
    local players = #playerlist
    local specs = 0
    -- count specs
    for i=1,#playerlist do
      local _,_,spec = spGetPlayerInfo(playerlist[i])
      if spec then specs = specs + 1 end
    end
    if players == specs then
      return nil
    end
  end
  return playerlist
end

function gadget:GameStart()
  gamestart = true

  -- shuffle start unit positions
  Shuffle()

  -- spawn units
  for i,team in ipairs(Spring.GetTeamList()) do

    -- clear resources
    -- actual resources are set depending on spawned unit and setup
	if not loadGame then
		Spring.SetTeamResource(team, "es", START_STORAGE)
		Spring.SetTeamResource(team, "ms", START_STORAGE)
		Spring.SetTeamResource(team, "energy", 0)
		Spring.SetTeamResource(team, "metal", 0)
	end
	

    if team ~= gaiateam then
	  if not limitless then
		Spring.SetTeamRulesParam(team, "numlives", numLives)
	  end
      SpawnStartUnit(team)
    end
  end
  
  -- kill units if engine spawned
  --[[
  for i,u in ipairs(createBeforeGameStart) do
    Spring.DestroyUnit(u, false, true) -- selfd = false, reclaim = true
  end
  ]]--
end

function gadget:RecvLuaMsg(msg, playerID)
	if msg:find("plane:",1,true) then
		local side = msg:sub(7)
		local _,_,spec,teamID = spGetPlayerInfo(playerID)
		if spec then return end
		planeChoice[teamID] = side
		if gamestart then
			-- picked plane after game start, prep for spawn
			-- can't do it directly because that's an unsafe change
			local frame = Spring.GetGameFrame() + 3
			if not scheduledSpawn[frame] then scheduledSpawn[frame] = {} end
			scheduledSpawn[frame][#scheduledSpawn[frame] + 1] = {teamID, playerID}
		end
	elseif msg:find("customplane:",1,true) then
		local name = msg:sub(13)
		planeChoiceCustom[playerID] = name
		local _,_,spec,teamID = spGetPlayerInfo(playerID)
		if spec then return end
		if gamestart then
			local frame = Spring.GetGameFrame() + 3
			if not scheduledSpawn[frame] then scheduledSpawn[frame] = {} end
			scheduledSpawn[frame][#scheduledSpawn[frame] + 1] = {teamID, playerID}
		end
	end	
end

-- used by CAI
--[[
local function SetFaction(side, playerID, teamID)
	teamSides[teamID] = side
end
GG.SetFaction = SetFaction
]]--

function gadget:GameFrame(n)
  if scheduledSpawn[n] then
	for _, spawnData in pairs(scheduledSpawn[n]) do
		SpawnStartUnit(spawnData[1], spawnData[2])
	end
	scheduledSpawn[n] = nil
  end
end

function gadget:Shutdown()
	--Spring.Echo("<Unit Spawn> Going to sleep...")
end

function gadget:Load(zip)
	if not GG.SaveLoad then
		Spring.Echo("ERROR: Unit Spawn failed to access save/load API")
		return
	end
	loadGame = true
	local data = GG.SaveLoad.ReadFile(zip, "Unit Spawn", SAVE_FILE) or {}

	-- load data wholesale
	waitingForPlane = data.waitingForPlane or {}
	scheduledSpawn = data.scheduledSpawn or {}
	planeChoice = data.planeChoice or {}
	
	-- these require special handling because they involve unitIDs
	for oldID in pairs(data.boost) do
		newID = GG.SaveLoad.GetNewUnitID(oldID)
		boost[newID] = true
	end
	for oldID in pairs(data.facplops) do
		newID = GG.SaveLoad.GetNewUnitID(oldID)
		facplops[newID] = true
	end	
end

--------------------------------------------------------------------
-- unsynced code
--------------------------------------------------------------------
else

local teamID 			= Spring.GetLocalTeamID()
local spGetUnitDefID 	= Spring.GetUnitDefID
local spGetUnitLosState = Spring.GetUnitLosState
local spValidUnitID 	= Spring.ValidUnitID
local spAreTeamsAllied 	= Spring.AreTeamsAllied
local spGetUnitTeam 	= Spring.GetUnitTeam

-- need this because SYNCED.tables are merely proxies, not real tables
local function MakeRealTable(proxy)
	local ret = {}
	for i,v in spairs(proxy) do
		ret[i] = v
	end
	return ret
end

function gadget:Save(zip)
	if not GG.SaveLoad then
		Spring.Echo("ERROR: Unit Spawn failed to access save/load API")
		return
	end
	local toSave = {
		boost = boost,
		facplops = MakeRealTable(SYNCED.facplops),
		waitingForPlane = MakeRealTable(SYNCED.waitingForPlane),
		--scheduledSpawn = MakeRealTable(SYNCED.scheduledSpawn),
		--planeChoice = MakeRealTable(SYNCED.planeChoice),	
	}
	GG.SaveLoad.WriteSaveData(zip, SAVE_FILE, toSave)
end

end
