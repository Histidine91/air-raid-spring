function gadget:GetInfo()
	return {
		name = "Missile physics",
		desc = "Controls missile movement",
		author = "KDR_11k (David Becker)",
		date = "2008-02-10",
		license = "Public Domain",
		layer = 1,
		enabled = false
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

local missiles={}
local launchDelay = 20
local friction = 0.9
local gravity = 0.1

function MissilePhysics(projectileID)
	local pvx,pvy,pvz=Spring.GetProjectileVelocity(projectileID)
	missiles[projectileID]={
		Spring.GetGameFrame()+launchDelay,
		pvx*friction,pvy*friction,pvz*friction,
	}
end

function gadget:GameFrame(f)
	for p,d in pairs (missiles) do
		Spring.SetProjectileVelocity(p,d[2],d[3],d[4])
		d[3] = d[3] - gravity
		if d[1] <= f then
			missiles[p]=nil
		end
	end
end

function gadget:Initialize()
	GG.MissilePhysics=MissilePhysics
end

else

--UNSYNCED

return false

end
