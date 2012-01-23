function widget:GetInfo()
	return {
		name = "Actions",
		desc = "Enables key actions",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = false
	}
end

function ChangeTarget()
--	Spring.SendLuaRulesMsg("changetarget")
end

function widget:Initialize()
	widgetHandler:AddAction("changetarget",ChangeTarget,nil,"pt")
	Spring.SendCommands({"unbindkeyset any+tab", "bind any+tab changetarget"})
end

function widget:Shutdown()
	widgetHandler:RemoveAction("changetarget")
end

