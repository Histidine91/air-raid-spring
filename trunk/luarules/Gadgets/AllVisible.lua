function gadget:GetInfo()
	return {
		name = "All Visible",
		desc = "shows all units",
		author = "KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

function gadget:UnitCreated(u)
	Spring.SetUnitAlwaysVisible(u,true)
	--Spring.SetUnitNoSelect(u,true)
end

function gadget:AllowCommand(u, ud)
	local cp = UnitDefs[ud].customParams
	if cp.playable then
		return false
	end
	return true
end

else

--UNSYNCED

return false

end
