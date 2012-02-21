function gadget:GetInfo()
	return {
		name = "Controls",
		desc = "controls for the player plane",
		author = "KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

local B_Gun = 0
local B_Missile = 1
local B_NextWeapon = 2
local B_PrevWeapon = 3

local pi = math.pi

if (gadgetHandler:IsSyncedCode()) then

--SYNCED
local inertiaFactor = 0.96

local planedata={}
local teamplane={}

function gadget:Initialize()
	for ud, d in ipairs(UnitDefs) do
		local c = d.customParams
		if c.playable then
			local i=1
			local ammo={}
			while c["ammo"..i] do
				ammo[i]={
					ammo = tonumber(c["ammo"..i]),
					reload = c["reload"..i]*30,
					cone=c["cone"..i]/360*pi,
					range=tonumber(c["dist"..i]),
					name=c["name"..i],
                                        isbomb=c["isbomb"..i],
				}
				i=i+1
			end
			planedata[ud]={
				speed = tonumber(c.speed),
				minSpeed = tonumber(c.minspeed),
				climb=tonumber(c.climbrate)/30/180*pi,
				roll=tonumber(c.rollrate)/30/180*pi,
				rudder=tonumber(c.rudderrate)/30/180*pi,
				gunammo=tonumber(c.gunammo),
				ammo=ammo,
			}
		end
	end
	GG.planedata=planedata
	_G.planedata=planedata
	GG.teamplane=teamplane
	_G.teamplane=teamplane
end

function gadget:UnitCreated(u, ud, team)
	if team ~= Spring.GetGaiaTeamID() then
		if planedata[ud] then
			local ammo={}
			for i,v in pairs(planedata[ud].ammo) do
				local c={lastuse=0}
				for a,b in pairs(v) do
					c[a]=b
				end
				ammo[i]=c
			end
			teamplane[team]={
				unit=u,
				ud=ud,
				roll=0,
				pitch=0,
				yaw=0,
				throttle=0.5,
				controlpitch=0,
				controlroll=0,
				controlyaw=0,
				gunammo=planedata[ud].gunammo,
				ammo=ammo,
				currentweapon=1,
				currentspeed=0,
				wantedspeed=0,
				velocity={0,0,0},
                                target=nil, -- set by targetmarker gadget for some reason
                                wantedtarget=nil,
				
				env = Spring.UnitScript.GetScriptEnv(u)
			}
			Spring.MoveCtrl.Enable(u)
			local x,y,z=Spring.GetUnitPosition(u)
			Spring.MoveCtrl.SetPosition(u,x,y+30,z)
			SendToUnsynced("PlaneCreated", u, team)
		else
			--Spring.Echo("ERROR: Non-playable plane assigned to player team!")
		end
	end
end

function gadget:UnitDestroyed(u,ud,team)
	if teamplane[team] and teamplane[team].unit == u then
		SendToUnsynced("PlaneDestroyed", u, team)
		teamplane[team]=nil
	end
        for team,data in pairs(teamplane) do
            if data.wantedtarget == u then
                data.wantedtarget = nil
            end
        end
end

function gadget:RecvLuaMsg(msg,player)
	local _,_,spec,team = Spring.GetPlayerInfo(player)
	if not spec and teamplane[team] then
		local p = teamplane[team]
		if msg:sub(1,8) == "control:" then
			local data = msg:sub(9,#msg)
			local interpret = VFS.UnpackS8(data,1,8)
			p.controlpitch=interpret[1]/127
			p.controlroll=interpret[2]/127
			p.controlyaw=interpret[3]/127
			p.throttle=interpret[4]/100
			if interpret[5+B_Gun]==1 then
				if p.env then
					Spring.UnitScript.CallAsUnit(p.unit, p.env.StartGun)
				else
					Spring.CallCOBScript(p.unit,"StartGun",0)
				end
			elseif interpret[5+B_Gun]==-1 then
				if p.env then
					Spring.UnitScript.CallAsUnit(p.unit, p.env.StopGun)
				else
					Spring.CallCOBScript(p.unit,"StopGun",0)
				end
			end
			if interpret[5+B_Missile]==1 then
                                if p.wantedtarget == p.target then
                                    if p.env then
                                            Spring.UnitScript.CallAsUnit(p.unit, p.env.UnlockWeapon,p.currentweapon)
                                    else
                                            Spring.CallCOBScript(p.unit,"UnlockWeapon",0,p.currentweapon)
                                    end
                                end
			end
			if interpret[5+B_NextWeapon]==1 then
				teamplane[team].currentweapon = teamplane[team].currentweapon +1
				if teamplane[team].currentweapon > #teamplane[team].ammo then
					teamplane[team].currentweapon = 1
				end
			end
			if interpret[5+B_PrevWeapon]==1 then
				teamplane[team].currentweapon = teamplane[team].currentweapon -1
				if teamplane[team].currentweapon < 1 then
					teamplane[team].currentweapon = #teamplane[team].ammo
				end
			end
			if #data>8 then
				local target = VFS.UnpackU32(data:sub(9,#data))
                                teamplane[team].wantedtarget = target
				Spring.GetUnitCOBValue(teamplane[team].unit, 106,teamplane[team].currentweapon+1,target)
			end

		end
--[[		if msg:sub(1,2) == "x:" then
			teamplane[team].controlroll=math.min(1,math.max(-1,tonumber(msg:sub(3))))
		elseif msg:sub(1,2) == "y:" then
			teamplane[team].controlpitch=math.min(1,math.max(-1,tonumber(msg:sub(3))))
		elseif msg:sub(1,2) == "z:" then
			teamplane[team].controlyaw=math.min(1,math.max(-1,tonumber(msg:sub(3))))
		elseif msg=="prevweapon" then
			teamplane[team].currentweapon = teamplane[team].currentweapon -1
			if teamplane[team].currentweapon < 1 then
				teamplane[team].currentweapon = #teamplane[team].ammo
			end
		elseif msg=="nextweapon" then
			teamplane[team].currentweapon = teamplane[team].currentweapon +1
			if teamplane[team].currentweapon > #teamplane[team].ammo then
				teamplane[team].currentweapon = 1
			end
		elseif msg:sub(1,12)=="changetarget" then
			Spring.GetUnitCOBValue(teamplane[team].unit, 106,teamplane[team].currentweapon+1,tonumber(msg:sub(13)) or -1)
		end--]]
	end
end

--[[
function gadget:RecvLuaMsg(msg,player)
	local _,_,spec,team = Spring.GetPlayerInfo(player)
	local p = teamplane[team]
	if not spec and p then
		if msg:sub(1,5) == "down:" then
			if msg:sub(6) == "1" then
				Spring.CallCOBScript(p.unit,"StartGun",0)
			elseif msg:sub(6) == "3" then
				Spring.CallCOBScript(p.unit,"UnlockWeapon",0,p.currentweapon)
			end
		elseif msg:sub(1,3) == "up:" then
			if msg:sub(4) == "1" then
				Spring.CallCOBScript(p.unit,"StopGun",0)
			end
		end
	end
end
--]]

function gadget:GameFrame(f)
	for team,p in pairs(teamplane) do
		local roll = pi * p.controlroll
		local pitch = p.pitch + math.cos(roll)*planedata[p.ud].climb*p.controlpitch - math.sin(roll)*planedata[p.ud].rudder*p.controlyaw
		
		-- fixes wrong-way banking with pitch after an Immelmann/split-S
		local correction = 1
		local numTurns = math.floor(math.abs(pitch)/(pi/2))%4
		if numTurns == 1 or numTurns == 2 then		
			correction = -1
		end
		
		local yaw = p.yaw + math.sin(roll)*planedata[p.ud].climb*p.controlpitch*correction + math.cos(roll)*planedata[p.ud].rudder*p.controlyaw*correction
		
		--if f%120 == 0 then Spring.Echo(pitch, yaw, roll) end
		
		Spring.MoveCtrl.SetRotation(p.unit,pitch,yaw,roll)
		p.pitch=pitch
		p.yaw=yaw
		p.roll=roll

		local speed = planedata[p.ud].speed*p.throttle
		if speed < planedata[p.ud].minSpeed then
			speed = planedata[p.ud].minSpeed
		end
		p.wantedspeed = speed
		
		-- calculate velocity
		--Spring.MoveCtrl.SetRelativeVelocity(p.unit,0,0,speed)
		local vx = math.sin(p.yaw) *(math.cos(p.pitch))*speed
		local vy = -math.sin(p.pitch)*speed
		local vz = math.cos(p.yaw) *(math.cos(p.pitch))*speed
		
		local gravity = -0.5*math.abs(vy/speed)	-- "gravity" here is really gravity + lift; lift is assumed to be linearly proportional to (1-|sin|)		
		vy = vy + gravity			-- and yes gravity is a velocity rather than an acceleration as it should be
		
		local vx1, vy1, vz1 = unpack(p.velocity)
		
		vx = vx*(1-inertiaFactor) + vx1*inertiaFactor
		vy = vy*(1-inertiaFactor) + vy1*inertiaFactor
		vz = vz*(1-inertiaFactor) + vz1*inertiaFactor
		
		p.velocity = {vx, vy, vz}
		
		Spring.MoveCtrl.SetVelocity(p.unit, vx, vy, vz)
		
		local trueSpeed = math.sqrt(vx^2 + vy^2 + vz^2)
		p.currentspeed = trueSpeed
		
		local x,y,z=Spring.GetUnitPosition(p.unit)
		--Spring.MoveCtrl.SetPosition(p.unit,
		--	x + math.sin(p.yaw) *(math.cos(p.pitch))*planedata[p.ud].speed[p.speed],
		--	y,-- + math.sin(p.pitch)*planedata[p.ud].speed[p.speed],
		--	z + math.cos(p.yaw) *(math.cos(p.pitch))*planedata[p.ud].speed[p.speed]
		--)

		SendToUnsynced("controls_GameFrame")
		
		local height = Spring.GetGroundHeight(x,z)
		if y < height or y < 0 then --impacted the ground
			Spring.SendMessageToTeam(team,"That wasn't so clever, now was it?")
			Spring.DestroyUnit(p.unit)
		end
	end
end

else

--UNSYNCED
local baseDelta = 1.05
local camDist=5
local camHeight=1
local jetSoundLength = 14

local gameFrame = 0

local function ResetCamera()
	local cam=Spring.GetCameraState()
	--cam.px = Game.mapSizeX/2
	--cam.pz = Spring.GetGroundHeight(Game.mapSizeX/2, Game.mapSizeZ/2) + 100
	--cam.py = Game.mapSizeZ/2
	cam.rx=0
	cam.ry=0
	cam.rz=0
	cam.vx=0
	cam.vy=0
	cam.vz=0
	Spring.SetCameraState(cam,0.2)
	lastUpdate = 0
end

function PlaneDestroyed(_,unitID, team)
	if team == Spring.GetMyTeamID() then
		ResetCamera()
		if (Script.LuaUI('PlaneDestroyed')) then
			Script.LuaUI.PlaneDestroyed(unitID, team)
		end
	end
end

function PlaneCreated(_,unitID, team)
	if team == Spring.GetMyTeamID() then
		if (Script.LuaUI('PlaneCreated')) then
			Script.LuaUI.PlaneCreated(unitID, team)
		end
	end
end

function GameFrame()
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("controls_GameFrame", GameFrame)
	gadgetHandler:AddSyncAction("PlaneCreated", PlaneCreated)
	gadgetHandler:AddSyncAction("PlaneDestroyed", PlaneDestroyed)
end

function gadget:Shutdown()
	gadgetHandler:RemoveSyncAction("controls_GameFrame")
	gadgetHandler:RemoveSyncAction("PlaneCreated")
	gadgetHandler:RemoveSyncAction("PlaneDestroyed")
end

function gadget:Update()
	local p=SYNCED.teamplane[Spring.GetMyTeamID()]
	if p then
		local cam=Spring.GetCameraState()
		local oldcam = cam
		local x,y,z=Spring.GetUnitPosition(p.unit)
		cam.px = x - math.sin(p.yaw) *(math.cos(p.pitch))*camDist
		cam.pz = z - math.cos(p.yaw) *(math.cos(p.pitch))*camDist
		cam.py = y + math.cos(p.pitch)*camHeight - math.sin(p.pitch)*camDist
		cam.rx=0-p.pitch
		cam.ry=p.yaw
		cam.rz=p.roll
		cam.mode=4
		
		local delta = ((cam.px - oldcam.px)^2 + (cam.py - oldcam.py)^2 + (cam.pz - oldcam.pz)^2)^0.5
		if delta <= 0 then delta = 1 end
		Spring.SetCameraState(cam,baseDelta/delta)
	end
end



end
