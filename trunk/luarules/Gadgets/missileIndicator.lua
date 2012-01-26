function gadget:GetInfo()
	return {
		name = "Missile Indicator",
		desc = "tracks and marks incoming missiles",
		author = "KDR_11k (David Becker)",
		date = "2009-09-08",
		license = "Public Domain",
		layer = 20,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED
local toTrack={}
local gaia = Spring.GetGaiaTeamID()

for i=1,#WeaponDefs do
	if WeaponDefs[i]["type"] == "MissileLauncher" then
		Script.SetWatchWeapon(i, true)
	end
end

function MissileLaunch(u, ud, team, target)
	toTrack[u]=target
end
GG.MissileLaunch = MissileLaunch

function gadget:ProjectileCreated(p,owner)
	if toTrack[owner] then
		SendToUnsynced("IncomingMissile",toTrack[owner],p)
		--if Spring.GetUnitTeam(owner) ~= gaia then
		--	GG.MissilePhysics(p)
		--end
		toTrack[owner]=nil
	end
end

function gadget:ProjectileDestroyed(p)
	SendToUnsynced("ProjDestroyed",p)
end

function gadget:Initialize()
	gadgetHandler:RegisterGlobal("MissileLaunch",MissileLaunch)
end

else

--UNSYNCED
local trackedMissiles={}

function IncomingMissile(_,target,projectile)
	if SYNCED.teamplane[Spring.GetMyTeamID()] and target == SYNCED.teamplane[Spring.GetMyTeamID()].unit then
		Spring.PlaySoundFile("sounds/missilealert.wav")
		trackedMissiles[projectile]=true
	end
end

function ProjDestroyed(_,p)
	trackedMissiles[p]=nil
end

local indSize=.5
local indicator

function Indicator()
	for i=0,61 do
		gl.Vertex(math.cos(i/10),math.sin(i/10),0)
	end
--[[	gl.Vertex(0,0,0)
	gl.Vertex(0,0,2*indSize)

	gl.Vertex(0,0,0)
	gl.Vertex(0,indSize,-.5*indSize)

	gl.Vertex(0,0,0)
	gl.Vertex(indSize*.8,-indSize*.3,-.5*indSize)

	gl.Vertex(0,0,0)
	gl.Vertex(-indSize*.8,-indSize*.3,-.5*indSize)--]]
end

function Line(x1,y1,z1,x2,y2,z2)
	gl.Vertex(x1,y1,z1)
	gl.Vertex(x2,y2,z2)
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("IncomingMissile",IncomingMissile)
	gadgetHandler:AddSyncAction("ProjDestroyed",ProjDestroyed)
	indicator=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,Indicator)
end

function gadget:Shutdown()
	gl.DeleteList(indicator)
end

local distScale=1

function gadget:DrawWorld()
	local team = Spring.GetMyTeamID()
	local p = SYNCED.teamplane[team]
	if p then
		gl.Color(1,0,0,1)
		local x,y,z=Spring.GetUnitPosition(p.unit)
		for m,_ in pairs(trackedMissiles) do
			local px,py,pz=Spring.GetProjectilePosition(m)
			local vx,vy,vz=Spring.GetProjectileVelocity(m)
			local dist = math.sqrt((px-x)*(px-x) + (py-y)*(py-y) + (pz-z)*(pz-z))
			local speed= math.sqrt(vx*vx+vy*vy+vz*vz)
			local dx=(px-x)/dist
			local dy=(py-y)/dist
			local dz=(pz-z)/dist
			local sx=vx/speed
			local sy=vy/speed
			local sz=vz/speed
			local ndist=dist/100

			gl.BeginEnd(GL.LINES,Line,x+dx*distScale,y+dy*distScale,z+dz*distScale,
				x+dx*(1+ndist)*distScale,y+dy*(1+ndist)*distScale,z+dz*(1+ndist)*distScale)
			--gl.PushMatrix()
			--gl.Translate(x+dx*(1+ndist)*distScale,y+dy*(1+ndist)*distScale,z+dz*(1+ndist)*distScale)
			--gl.CallList(indicator)
			--gl.PopMatrix()
		end
		gl.Color(1,1,1,1)
	end
end

end
