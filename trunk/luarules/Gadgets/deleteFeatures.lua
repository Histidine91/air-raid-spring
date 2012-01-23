function gadget:GetInfo()
	return {
		name = "kill all features",
		desc = "just that",
		author = "KDR_11k (David Becker)",
		date = "2008-12-21",
		license = "Public Domain",
		layer = 0,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

function gadget:PreGameStart()
	if Spring.GetModOptions().removefeatures == "1" then
		for _,f in ipairs (Spring.GetAllFeatures()) do
			Spring.DestroyFeature(f)
		end
		gadgetHandler:RemoveGadget()
	end
end

else

--UNSYNCED

return false

end
