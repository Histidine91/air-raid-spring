function widget:GetInfo()
	return {
		name = "Synced Plane Info",
		desc = "Receives info about player planes from gadget",
		author = "",
		date = "24/1/2012",
		license = "Public Domain",
		layer = -math.huge,
		enabled = true
	}
end

function TeamPlaneStatusUpdate(data)
	WG.planestatus = data
end

function PlaneCreated(unitID, team)
	WG.teamplane = unitID
end

function PlaneDestroyed(unitID, team)
	WG.teamplane = nil
	WG.planestatus = nil
	WG.ResetState()
end

function widget:Initialize()
	widgetHandler:RegisterGlobal("TeamPlaneStatusUpdate", TeamPlaneStatusUpdate)
	widgetHandler:RegisterGlobal("PlaneCreated", PlaneCreated)
	widgetHandler:RegisterGlobal("PlaneDestroyed", PlaneDestroyed)
	
	-- luaui reload compatiblity
	local teamRulesParam = Spring.GetTeamRulesParam(Spring.GetLocalTeamID(), "teamplane")
	if teamRulesParam and teamRulesParam ~= -1 then
		WG.teamplane = teamRulesParam
	end
end

function widget:Shutdown()
	widgetHandler:DeregisterGlobal("PlaneCreated")
	widgetHandler:DeregisterGlobal("PlaneDestroyed")
	widgetHandler:DeregisterGlobal("TeamPlaneStatusUpdate")
end