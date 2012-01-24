 --------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    game_end.lua
--  brief:   spawns start unit and sets storage levels
--  author:  Andrea Piras
--
--  Copyright (C) 2010,2011.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name      = "Game End",
		desc      = "Handles team/allyteam deaths and declares gameover",
		author    = "Andrea Piras",
		date      = "August, 2010",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- synced only
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

local modOptions = Spring.GetModOptions()

-- teamDeathMode possible values: "none", "teamzerounits" , "allyzerounits"
local teamDeathMode = modOptions.teamdeathmode or "teamzerounits"

-- sharedDynamicAllianceVictory is a C-like bool
local sharedDynamicAllianceVictory = tonumber(modOptions.shareddynamicalliancevictory) or 0

-- ignoreGaia is a C-like bool
local ignoreGaia = tonumber(modOptions.ignoregaiawinner) or 1

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local gaiaTeamID = Spring.GetGaiaTeamID()
local spKillTeam = Spring.KillTeam
local spGetAllyTeamList = Spring.GetAllyTeamList
local spGetTeamList = Spring.GetTeamList
local spGetTeamInfo = Spring.GetTeamInfo
local spGameOver = Spring.GameOver
local spAreTeamsAllied = Spring.AreTeamsAllied

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local gaiaAllyTeamID
local allyTeams = spGetAllyTeamList()
local teamsUnitCount = {}
local allyTeamUnitCount = {}
local allyTeamAliveTeamsCount = {}
local teamToAllyTeam = {}
local aliveAllyTeamCount = 0
local killedAllyTeams = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local allyTeamsToWin = 1
if Spring.GetModOptions().gamemode=="raid" or Spring.GetModOptions().gamemode=="intercept" then
	allyTeamsToWin = 0
end

function gadget:GameOver()
	-- remove ourself after successful game over
	--gadgetHandler:RemoveGadget()
end

local function IsCandidateWinner(allyTeamID)
	local isAlive = (killedAllyTeams[allyTeamID] ~= true)
	local gaiaCheck = (ignoreGaia == 0) or (allyTeamID ~= gaiaAllyTeamID)
	return isAlive and gaiaCheck
end

local function CheckSingleAllyVictoryEnd()
	if aliveAllyTeamCount ~= allyTeamsToWin then	-- FIXME: implement proper system
		return false
	end

	-- find the last remaining allyteam
	for _,candidateWinner in ipairs(allyTeams) do
		if IsCandidateWinner(candidateWinner) then
			return {candidateWinner}
		end
	end

	return {}
end

local function WinAllAllyTeams()
	local toWin = {}
	for _,candidateWinner in ipairs(allyTeams) do
		if IsCandidateWinner(candidateWinner) then
			toWin[#toWin+1] = candidateWinner
		end
	end	
	Spring.GameOver(toWin)
end
GG.WinAllAllyTeams = WinAllAllyTeams

local function CheckGameOver()
	local winners = CheckSingleAllyVictoryEnd()

	if winners then
		spGameOver(winners)
	end
end

local function KillResignedTeams()
	-- Check for teams w/o leaders -> all players resigned & no AIs left in the team
	-- Note: In the case a player drops he will still be the leader of the team!
	--       So he can reconnect and take his units.
	local teamList = Spring.GetTeamList()
	for i=1, #teamList do
		local teamID = teamList[i]
		local leaderID = select(2, spGetTeamInfo(teamID))
		if (leaderID < 0) then
			spKillTeam(teamID)
		end
	end
end

function gadget:GameFrame(frame)
	-- only do a check in slowupdate
	if (frame%16) == 0 then
		CheckGameOver()
		-- kill teams after checking for gameover to avoid to trigger instantly gameover
		KillResignedTeams()
	end
end

function gadget:TeamDied(teamID)
	teamsUnitCount[teamID] = nil
	local allyTeamID = teamToAllyTeam[teamID]
	local aliveTeamCount = allyTeamAliveTeamsCount[allyTeamID]
	if aliveTeamCount then
		aliveTeamCount = aliveTeamCount - 1
		allyTeamAliveTeamsCount[allyTeamID] = aliveTeamCount
		if aliveTeamCount <= 0 then
			-- one allyteam just died
			aliveAllyTeamCount = aliveAllyTeamCount - 1
			allyTeamUnitCount[allyTeamID] = nil
			killedAllyTeams[allyTeamID] = true
		end
	end
end


function gadget:Initialize()
	if teamDeathMode == "none" then
		gadgetHandler:RemoveGadget()
	end

	gaiaAllyTeamID = select(6, spGetTeamInfo(gaiaTeamID))

	-- at start, fill in the table of all alive allyteams
	for _,allyTeamID in ipairs(allyTeams) do
		local teamList = spGetTeamList(allyTeamID)
		local teamCount = 0
		for _,teamID in ipairs(teamList) do
			teamToAllyTeam[teamID] = allyTeamID
			if (ignoreGaia == 0) or (teamID ~= gaiaTeamID) then
				teamCount = teamCount + 1
			end
		end
		allyTeamAliveTeamsCount[allyTeamID] = teamCount
		if teamCount > 0 then
			 aliveAllyTeamCount = aliveAllyTeamCount + 1
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeamID)
	if unitTeamID == gaiaTeamID and ignoreGaia ~= 0 then
		-- skip gaia
		return
	end
	local numLives = Spring.GetTeamRulesParam(unitTeamID, "numlives")
	if numLives and tonumber(numLives) <= 0 then
		Spring.KillTeam(unitTeamID)
	end
end
