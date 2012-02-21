--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Weapons",
		desc = "Weapon controls and HUD",
		author = "KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 5,
		enabled = true
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	HOW IT WORKS:
--	Each missile/bomb/gunpod has a corresponding unitdef.
--	At plane creation, the weapon "units" are created and glued to the unit,
--	Imperator style.
--		Weapon units are hold fire.
--	When fire order is given at a target, pass the target to the weapon unit.
--	Weapon unit is given an attack order to the target.
--	Upon weapon release, weapon unit notifies gadget.
--	Weapon unit is made invisible until reloading is complete.
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------

local planedata
local teamplane

local planeWeapons = {}
GG.Weapon = {}

function HasAmmo(u, ud, team, wep)
	return teamplane[team].ammo[wep].ammo
end
GG.Weapon.HasAmmo = HasAmmo

function UseAmmo(u, ud, team, wep)
	teamplane[team].ammo[wep].ammo = math.max(0,teamplane[team].ammo[wep].ammo - 1)
	return 1
end
GG.Weapon.UseAmmo = UseAmmo

function UseGun(u, ud, team, amount)
	teamplane[team].gunammo = math.max(0,teamplane[team].gunammo -amount)
	SendToUnsynced("GunShot",team)
	return teamplane[team].gunammo
end
GG.Weapon.UseGun = UseGun

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
	gadgetHandler:RegisterGlobal("HasAmmo",HasAmmo)
	gadgetHandler:RegisterGlobal("UseAmmo",UseAmmo)
	gadgetHandler:RegisterGlobal("UseGun",UseGun)
	planedata=GG.planedata
	teamplane=GG.teamplane
end


function gadget:GameFrame(f)
	for team,p in pairs(teamplane) do
		p.gunammo = math.min(p.gunammo +.2,planedata[p.ud].gunammo)
		for i,d in pairs(p.ammo) do
			d.ammo = math.min(d.ammo + 1/d.reload,planedata[p.ud].ammo[i].ammo)
		end
	end
end

else

--UNSYNCED

local bottomdist=70
local rightdist=80
local namedist=50
local entrydist=30
local leftdist=80
local textsize=20
local listwidth=150

local lastGunUse={}
local gunUseDelay=8

function Rectangle(x1,y1,x2,y2)
	gl.Vertex(x1,y1,0)
	gl.Vertex(x2,y1,0)
	gl.Vertex(x2,y2,0)
	gl.Vertex(x1,y2,0)
end

function GunShot(_,team)
	if lastGunUse[team] < Spring.GetGameFrame() - gunUseDelay then
		local x,y,z=Spring.GetUnitPosition(SYNCED.teamplane[team].unit)
		Spring.PlaySoundFile("sounds/tgunshipfire.wav",.4,x,y,z)
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("GunShot",GunShot)
	for _,t in ipairs(Spring.GetTeamList()) do
		lastGunUse[t]=0
	end
end

function gadget:DrawScreen(vsx,vsy)
	local p=SYNCED.teamplane[Spring.GetMyTeamID()]
	if p then
		for i,d in spairs(p.ammo) do
			gl.Color(0,.5,0,.4)
			gl.Rect(vsx - rightdist + 10 - (listwidth+10)*(1-math.fmod(d.ammo,1)), bottomdist + i*entrydist-6,vsx - rightdist - listwidth, bottomdist + (i+1)*entrydist -10)
			gl.Color(0,1,0,1)
			gl.Text(math.floor(d.ammo), vsx - rightdist, bottomdist + i*entrydist, textsize, "r")
			gl.Text(d.name, vsx - rightdist - namedist, bottomdist + i*entrydist, textsize, "r")
		end
		gl.BeginEnd(GL.LINE_LOOP,Rectangle,vsx - rightdist + 10, bottomdist + p.currentweapon*entrydist-6,vsx - rightdist - listwidth, bottomdist + (p.currentweapon+1)*entrydist -10)
		gl.Text("Gun "..math.floor(p.gunammo),leftdist,bottomdist+entrydist, textsize, "l")
		gl.Color(1,1,1,1)
	end
end

end
