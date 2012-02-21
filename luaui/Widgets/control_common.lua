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

local state={
	pitch=0,
	yaw=0,
	roll=0,
	throttle=0.5,
	buttons={[0]=0,[1]=0,[2]=0,[3]=0},
	target=nil,
}
WG.controlstate = state

local THROTTLE_INCREMENT = 0.05

function widget:UnitCreated(u,ud,team)
	if (team==Spring.GetMyTeamID() and UnitDefs[ud].customParams.playable) then
		Spring.WarpMouse(vsx/2,vsy/2)
		WG.hasPlane = u
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
	}
	WG.controlstate = state
end

function widget:UnitDestroyed(u,ud,team)
	if u == WG.hasPlane then
		WG.hasPlane=nil
		ResetState()
	end
end

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

function widget:KeyPress(key)
	if not WG.hasPlane then
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
	elseif key==KEY_SpeedDown then
		throttleState=-1
	end
end

function widget:KeyRelease(key)
	if not WG.hasPlane then
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
	end
end

function widget:GameFrame()
	if WG.hasPlane then
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
