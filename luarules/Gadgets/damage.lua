function gadget:GetInfo()
	return {
		name = "Damage",
		desc = "Show damage to player planes",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 20,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

function gadget:UnitDamaged(u, ud, team)
	if GG.teamplane[team] and GG.teamplane[team].unit == u then
		SendToUnsynced("Damage",team)
	end
end

else

--UNSYNCED

local damaged={}
local duration=30

function Damage(_,team)
	damaged[team] = Spring.GetGameFrame()+duration
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("Damage",Damage)
end

function gadget:DrawScreenEffects(vsx,vsy)
	local team = Spring.GetMyTeamID()
	local p = SYNCED.teamplane[team]
	if p then
		if damaged[team] and (damaged[team] > Spring.GetGameFrame()) then
			gl.Color(1,0,0,.02*(damaged[team] - Spring.GetGameFrame()))
			gl.Texture("bitmaps/borderfade.png")
			gl.TexRect(0,0,vsx,vsy,false,false)
			gl.Texture(false)
			gl.Color(1,1,1,1)
		end
	end
end

function gadget:DrawScreen(vsx,vsy)
	local team = Spring.GetMyTeamID()
	local p = SYNCED.teamplane[team]
	if p then
		if damaged[team] and (damaged[team] > Spring.GetGameFrame()) then
			gl.Color(1,0,0,1)
		else
			gl.Color(0,1,0,1)
		end
		local hp, mhp = Spring.GetUnitHealth(p.unit)
		gl.Text(""..math.floor(100*hp/mhp).."%",vsx*.5,220,20,"c")
		gl.Color(1,1,1,1)
	end
end

end
