function widget:GetInfo()
	return {
		name = "Controls (keyboard)",
		desc = "Keyboard based controls",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

local B_Gun = 0
local B_Missile = 1
local B_NextWeapon = 2
local B_PrevWeapon = 3

local vsx=0
local vsy=0
local deadzone=.05
local hasPlane

include("keysym.h.lua")

local KEY_RudderLeft=97	--A
local KEY_RudderRight=100	--D
local KEY_SpeedUp=119 --W
local KEY_SpeedDown=115	--S
local KEY_SpeedDown2=121 --Y

local KEY_PitchUp = 273	--up arrow
local KEY_PitchDown = 274	--down arrow
local KEY_RollLeft = 276	--left arrow
local KEY_RollRight = 275	--right arrow

local KEY_NextWeapon = 101	-- E
local KEY_PrevWeapon = 113	--Q
local KEY_Gun = 32	-- spacebar
local KEY_Missile = 306	-- leftctrl
local KEY_ChangeTarget = 114	--R

local KEY_SensitivityToggle = KEYSYMS.LALT

local state={
	pitch=0,
	yaw=0,
	roll=0,
	throttle=0.5,
	buttons={[0]=0,[1]=0,[2]=0,[3]=0},
	target=nil,
}
local pitch_increment = 0.45
local roll_increment = 0.025
local THROTTLE_INCREMENT = 0.05

function ChangeControls()
	widgetHandler:RemoveWidget("Controls (keyboard)")
end

function widget:UnitCreated(u,ud,team)
	if team==Spring.GetMyTeamID() then
		Spring.WarpMouse(vsx/2,vsy/2)
		hasPlane = u
	end
end

function widget:UnitDestroyed(u,ud,team)
	if u == hasPlane then
		hasPlane=nil
	end
end

function widget:Initialize()
	if (Spring.GetSpectatingState() or Spring.IsReplay()) then
		widgetHandler:RemoveWidget()
	end
	Spring.AssignMouseCursor("Normal","bitmaps/cursor.png")
	vsx,vsy=Spring.GetViewGeometry()
	hasPlane = Spring.GetTeamUnits(Spring.GetMyTeamID())[1]
	if WG.ChangeControls then
		WG.ChangeControls()
	end
	WG.ChangeControls = ChangeControls
end

function widget:Shutdown()
	WG.ChangeControls = nil
end

function widget:MousePress(x,y,button)
	if hasPlane then
		local maxdist=40000 --200^2
		local target=nil
		for _,u in ipairs(Spring.GetVisibleUnits()) do
			local team = Spring.GetUnitTeam(u)
			if team~=Spring.GetMyTeamID() then
				local ux,uy,uz=Spring.GetUnitPosition(u)
				local sx,sy=Spring.WorldToScreenCoords(ux,uy,uz)
				local dist = (sx-x)*(sx-x) + (sy-y)*(sy-y)
				if dist < maxdist then
					maxdist=dist
					target=u
				end
			end
		end
		if target then
			--Spring.SendLuaRulesMsg("changetarget"..target)
			state.target=target
		end
		return true
	end
	return false
end

local rudderState=0
local rollState=0
local pitchState=0
local throttleState=0
local sensitivityState=1

function widget:KeyPress(key)
	--Spring.Echo(key)
	if not hasPlane then
		return false
	end
	if key == KEY_PitchUp then
		pitchState = 1
		return true
	elseif key == KEY_PitchDown then
		pitchState = -1
		return true				
	elseif key == KEY_RollLeft then
		rollState = -1
		return true
	elseif key == KEY_RollRight then
		rollState = 1
		return true		
	elseif key == KEY_RudderLeft then
		--Spring.SendLuaRulesMsg("z:1")
		state.yaw=1
		rudderState=1
		return true
	elseif key==KEY_RudderRight then
		--Spring.SendLuaRulesMsg("z:-1")
		state.yaw=-1
		rudderState=-1
		return true
	elseif key==KEY_SpeedUp then
		throttleState=1
	elseif key==KEY_SpeedDown then
		throttleState=-1
	elseif key==KEY_Gun then
		state.buttons[B_Gun]=1
	elseif key==KEY_Missile then
		state.buttons[B_Missile]=1
	elseif key==KEY_ChangeTarget then
		local maxdist=40000 --200^2
		local target=nil
		for _,u in ipairs(Spring.GetVisibleUnits()) do
			local team = Spring.GetUnitTeam(u)
			if team~=Spring.GetMyTeamID() then
				local ux,uy,uz=Spring.GetUnitPosition(u)
				local sx,sy=Spring.WorldToScreenCoords(ux,uy,uz)
				local dist = (sx-vsx/2)*(sx-vsx/2) + (sy-vsy/2)*(sy-vsy/2)
				if dist < maxdist then
					maxdist=dist
					target=u
				end
			end
		end
		if target then
			--Spring.SendLuaRulesMsg("changetarget"..target)
			state.target=target
		end
	elseif key==KEY_NextWeapon then
		state.buttons[B_NextWeapon]=1
	elseif key==KEY_PrevWeapon then
		state.buttons[B_PrevWeapon]=1
	elseif key==KEY_SensitivityToggle then
		sensitivityState = 2
	end
end

function widget:KeyRelease(key)
	if (key == KEY_RudderLeft and rudderState== 1) or (key==KEY_RudderRight and rudderState== -1) then
		--Spring.SendLuaRulesMsg("z:0")
		state.yaw=0
		rudderState=0
		return true
	elseif (key == KEY_PitchUp) or (key == KEY_PitchDown) then
		pitchState=0
		return true
	elseif key == KEY_SpeedUp or key == KEY_SpeedDown then
		throttleState = 0
		return true		
	elseif key == KEY_RollLeft or key == KEY_RollRight then
		rollState = 0
		return true			
	elseif key == KEY_Gun then
		state.buttons[B_Gun]=-1
	elseif key == KEY_Missile then
		state.buttons[B_Missile]=-1
	elseif key==KEY_SensitivityToggle then
		sensitivityState = 1
	end
end

function widget:GameFrame(n)
	if hasPlane then
		if rollState ~= 0 then
			state.roll = state.roll + roll_increment*rollState*sensitivityState
			
			if state.roll > 1 then state.roll = -2+state.roll
			elseif state.roll < -1 then state.roll = 2+state.roll
			end
		end
		state.pitch = pitch_increment*pitchState*sensitivityState
		if throttleState ~= 0 then
			state.throttle = state.throttle+THROTTLE_INCREMENT*throttleState
			if state.throttle > 1 then state.throttle = 1
			elseif state.throttle < 0 then state.throttle = 0
			end
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
