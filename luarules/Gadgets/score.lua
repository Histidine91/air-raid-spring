function gadget:GetInfo()
	return {
		name = "Score",
		desc = "keeps track of a player's score",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

local score={}
local nextBonus={}
local chain={}
local chainTime=300

function gadget:Initialize()
	for _,team in ipairs(Spring.GetTeamList()) do
		score[team]=0
		chain[team]={mult=1,expire=0}
		nextBonus[team]=100
	end
	_G.score=score
	_G.chain=chain
end

function gadget:UnitDestroyed(u, ud, team, attacker, aud, ateam)
	if ateam then
		if chain[ateam].expire < Spring.GetGameFrame() then
			chain[ateam].mult=0
		end
		chain[ateam].expire = Spring.GetGameFrame() + chainTime
		chain[ateam].mult = chain[ateam].mult + 1
		local value=chain[ateam].mult * tonumber(UnitDefs[ud].customParams.score or 0)
		score[ateam] = score[ateam] + value
		if score[ateam]>=nextBonus[ateam] then
			if nextBonus[ateam]>=400 then
				nextBonus[ateam]=nextBonus[ateam]+500
			elseif nextBonus[ateam]==100 then
				nextBonus[ateam]=400
			else
				nextBonus[ateam]=200
			end
			local _,mhp = Spring.GetUnitHealth(GG.teamplane[ateam].unit)
			--Spring.SetUnitHealth(GG.teamplane[ateam].unit,{health=mhp})
			local lives = Spring.GetTeamRulesParam(ateam, "numlives")
			if lives then
				Spring.SetTeamRulesParam(ateam, "numlives", lives + 1)
			end
			SendToUnsynced("ExtraLife",ateam)
		end
		SendToUnsynced("scored",ateam,value)
	end
end

else

--UNSYNCED

local scoreAdd=0
local scoreAddExpiry=0
local scoreAddDuration = 150

function scored(_,team,value)
	if team == Spring.GetMyTeamID() then
		scoreAdd=value
		scoreAddExpiry=Spring.GetGameFrame() + scoreAddDuration
	end
end

function ExtraLife(_,team)
	if team == Spring.GetMyTeamID() then
		Spring.PlaySoundFile("sounds/extralife.wav")
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("scored",scored)
	gadgetHandler:AddSyncAction("ExtraLife",ExtraLife)
end

local scoreRight=80
local scoreTop=60

function gadget:DrawScreen(vsx,vsy)
	local team = Spring.GetMyTeamID()
	gl.Color(0,1,0,1)
	gl.Text("SCORE",vsx-scoreRight,vsy-scoreTop,20,"r")
	gl.Text(tostring(SYNCED.score[team]),vsx-scoreRight,vsy-scoreTop-25,20,"r")
	local f = Spring.GetGameFrame()
	if scoreAddExpiry > f then
		gl.Color(0,1,0,(scoreAddExpiry - f)/scoreAddDuration)
		gl.Text("+"..scoreAdd,vsx-scoreRight,vsy-scoreTop-50,16,"r")
	end
	if SYNCED.chain[team].expire > Spring.GetGameFrame() then
		gl.Color(0,1,0,1)
		gl.Text(""..SYNCED.chain[team].mult.." CHAIN",vsx-scoreRight,vsy-scoreTop-75,16,"r")
	end
	gl.Color(1,1,1,1)
end

end
