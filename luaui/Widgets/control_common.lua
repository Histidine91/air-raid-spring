function widget:GetInfo()
	return {
		name = "Controls (common)",
		desc = "Common control functions (DO NOT DISABLE)",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 0,
		enabled = true
	}
end

include("keysym.h.lua")
VFS.Include("LuaRules/Configs/globalConstants.h.lua")

local B_Gun = 0
local B_Missile = 1
local B_NextWeapon = 2
local B_PrevWeapon = 3

local vsx=0
local vsy=0
local deadzone=.05

local KEY_RudderLeft=97	--A
local KEY_RudderRight=100	--D
local KEY_SpeedUp=119 --W
local KEY_SpeedDown=115	--S
local KEY_SpeedDown2=121 --Y
local KEY_CamMove = KEYSYMS.C

local state={
	pitch=0,
	yaw=0,
	roll=0,
	throttle=0.5,
	buttons={[0]=0,[1]=0,[2]=0,[3]=0},
	target=nil,
	cam = {0, 0},
}
WG.controlstate = state

local THROTTLE_INCREMENT = 0.05
local camMoveSpeed = 0.5

function widget:UnitCreated(u,ud,team)
	if u == WG.teamplane then
		Spring.WarpMouse(vsx/2,vsy/2)
	end
end


local function ResetState()
	state = {
		pitch=0,
		yaw=0,
		roll=0,
		throttle=0.5,
		buttons={[0]=0,[1]=0,[2]=0,[3]=0},
		target=nil,
		cam = {0, 0},
	}
	WG.controlstate = state
	
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
WG.ResetState = ResetState

--[[
function widget:UnitDestroyed(u,ud,team)
	if u == WG.teamplane then
		WG.teamplane=nil
		ResetState()
	end
end
]]

function widget:Initialize()
	if (Spring.GetSpectatingState() or Spring.IsReplay()) then
		widgetHandler:RemoveWidget()
	end
	Spring.AssignMouseCursor("Normal","bitmaps/cursor.png")
	vsx,vsy=Spring.GetViewGeometry()
	
	local myTeam = Spring.GetMyTeamID()
	local units = Spring.GetTeamUnits(myTeam)
	for i=1, #units do
		widget:UnitCreated(units[i], Spring.GetUnitDefID(units[i]),myTeam)
	end
end

function widget:Shutdown()
	WG.ChangeControls = nil
end

local rudderstate=0
local throttleState=0
local camMoveState=false

function widget:KeyPress(key)
	if not WG.teamplane then
		return false
	end
	if key == KEY_RudderLeft then
		--Spring.SendLuaRulesMsg("z:1")
		state.yaw=1
		rudderstate=1
		return true
	elseif key==KEY_RudderRight then
		--Spring.SendLuaRulesMsg("z:-1")
		state.yaw=-1
		rudderstate=-1
		return true
	elseif key==KEY_SpeedUp then
		throttleState=1
		return true
	elseif key==KEY_SpeedDown then
		throttleState=-1
		return true
	elseif key==KEY_CamMove then
		camMoveState = true
		return true
	end
end

function widget:IsAbove(x,y)
	if WG.teamplane and camMoveState then
                local x = (x/vsx*2-1)
                local y = (y/vsy*2-1)
                --if x > -deadzone and x < deadzone then
		--	x = 0
		--end
                --if y > -deadzone and y < deadzone then
		--	y = 0
		--end
		state.cam[1] = state.cam[1] + x*camMoveSpeed
		state.cam[2] = state.cam[2] + y*camMoveSpeed
		return true
	end
	return false
end

function widget:KeyRelease(key)
	if not WG.teamplane then
		return false
	end
	if (key == KEY_RudderLeft and rudderstate== 1) or (key==KEY_RudderRight and rudderstate== -1) then
		--Spring.SendLuaRulesMsg("z:0")
		state.yaw=0
		rudderstate=0
		return true
	elseif key == KEY_SpeedUp or key == KEY_SpeedDown then
		throttleState = 0
		return true
	elseif key==KEY_CamMove then
		camMoveState = false
		return true
	end
end

function widget:GameFrame()
	if WG.teamplane then
		if throttleState ~= 0 then
			local throttle = state.throttle+THROTTLE_INCREMENT*throttleState
			if throttle > 1 then throttle = 1
			elseif throttle < 0 then throttle = 0
			end
                        state.throttle = throttle
		end	
	
		local data = VFS.PackS8(state.pitch*127, state.roll*127, state.yaw*127, state.throttle*100, state.buttons[0], state.buttons[1], state.buttons[2], state.buttons[3])
		if state.target then
			data = data .. VFS.PackU32(state.target)
		end
		state.downs=0
		state.ups=0
		state.buttons={[0]=0,[1]=0,[2]=0,[3]=0}
		state.target=nil
		Spring.SendLuaRulesMsg("control:"..data)
	end
end

local baseDelta = 1.1
local deltaMult = 0.5
--local baseDeltaAlt = 0
local camDist=0
local camDistPaused=8
local camHeight=0

function widget:Update()
	if camMoveState then
		Spring.WarpMouse(vsx/2,vsy/2)
	end
	local p = WG.planestatus
	local paused = select(3, Spring.GetGameSpeed())
	local velPredict = paused and 0 or 2
	if WG.teamplane and p then
		local cam=Spring.GetCameraState()
		local oldcam = cam
		local x,y,z=Spring.GetUnitViewPosition(WG.teamplane, true)
		--x = x + p.velocity[1]*Game.gameSpeed
		--y = y + p.velocity[2]*Game.gameSpeed
		--z = z + p.velocity[3]*Game.gameSpeed
		
		local dist = paused and camDistPaused or camDist		
		local pitch = p.pitch + WG.controlstate.cam[2]
		local yaw = p.yaw + WG.controlstate.cam[1]
		
		local targetPos = {
			x - math.sin(yaw) * math.cos(pitch)*dist + p.velocity[1]*velPredict,
			y + math.sin(pitch) * dist + p.velocity[2]*velPredict,
			z - math.cos(yaw) * math.cos(pitch)*dist + p.velocity[3]*velPredict,
		}
		local deltaPos = {
			targetPos[1] - cam.px,
			targetPos[2] - cam.py,
			targetPos[3] - cam.pz,
		}
		cam.px = targetPos[1]
		cam.py = targetPos[2]
		cam.pz = targetPos[3]
		--cam.vx = p.velocity[1]*Game.gameSpeed
		--cam.vy = p.velocity[2]*Game.gameSpeed
		--cam.vz = p.velocity[3]*Game.gameSpeed
		cam.rx=0-pitch
		cam.ry=yaw
		cam.rz= p.roll
		cam.mode=4
		
		local delta = ((cam.px - oldcam.px)^2 + (cam.py - oldcam.py)^2 + (cam.pz - oldcam.pz)^2)^0.5
		if delta <= 0 then delta = 1 end
		Spring.SetCameraState(cam, baseDelta/delta)
	end
end