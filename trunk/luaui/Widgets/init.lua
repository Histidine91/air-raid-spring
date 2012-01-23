function widget:GetInfo()
	return {
		name = "Initialization",
		desc = "Startup stuff",
		author = "",
		date = "22/1/2012",
		license = "Public Domain",
		layer = 0,
		enabled = true
	}
end

function widget:Initialize()
	Spring.SendCommands({"resbar 0", "info 0", "showhealthbars 0", "disticon 100000"})
	widgetHandler:RemoveWidget()
end
