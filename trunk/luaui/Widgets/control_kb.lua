function widget:GetInfo()
	return {
		name = "Controls (keyboard)",
		desc = "Keyboard based controls",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = false
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

local pitch_increment = 0.45
local roll_increment = 0.025

function ChangeControls()
	Spring.SendCommands("luaui disablewidget Controls (keyboard)")
end

function widget:Initialize()
        vsx,vsy=Spring.GetViewGeometry()
	if WG.ChangeControls then
		WG.ChangeControls()
	end
	WG.ChangeControls = ChangeControls
end

function widget:Shutdown()
	WG.ChangeControls = nil
end

function widget:MousePress(x,y,button)
	if WG.teamplane then
		local maxdist=40000 --200^2
		local target=nil
		for _,u in ipairs(Spring.GetVisibleUnits()) do
			local team = Spring.GetUnitTeam(u)
			if team~=Spring.GetMyTeamID() then
				local ux,uy,uz=Spring.GetUnitPosition(u)
				local sx,sy=Spring.WorldToScreenCoords(ux,uy,uz)
				local dist = (sx-x)^2 + (sy-y)^2
                                local dist2 = Spring.GetUnitSeparation(WG.teamplane,u)
				if dist < maxdist and dist2 < MAX_TARGET_RANGE then
					maxdist=dist
					target=u
				end
			end
		end
		if target then
			--Spring.SendLuaRulesMsg("changetarget"..target)
			WG.controlstate.target=target
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
	if not WG.teamplane then
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
	elseif key==KEY_Gun then
		WG.controlstate.buttons[B_Gun]=1
	elseif key==KEY_Missile then
		WG.controlstate.buttons[B_Missile]=1
	elseif key==KEY_ChangeTarget then
		local maxdist=500^2
		local target=nil
		for _,u in ipairs(Spring.GetVisibleUnits()) do
			local team = Spring.GetUnitTeam(u)
			if team~=Spring.GetMyTeamID() then
				local ux,uy,uz=Spring.GetUnitPosition(u)
				local sx,sy=Spring.WorldToScreenCoords(ux,uy,uz)
				local dist = (sx-vsx/2)^2 + (sy-vsy/2)^2
                                local dist2 = Spring.GetUnitSeparation(WG.teamplane,u)
				if dist < maxdist and dist2 < MAX_TARGET_RANGE then
					maxdist=dist
					target=u
				end
			end
		end
		if target then
			--Spring.SendLuaRulesMsg("changetarget"..target)
			WG.controlstate.target=target
		end
	elseif key==KEY_NextWeapon then
		WG.controlstate.buttons[B_NextWeapon]=1
	elseif key==KEY_PrevWeapon then
		WG.controlstate.buttons[B_PrevWeapon]=1
	elseif key==KEY_SensitivityToggle then
		sensitivityState = 2
	end
end

function widget:KeyRelease(key)
	if not WG.teamplane then
		return false
	end
	if (key == KEY_PitchUp) or (key == KEY_PitchDown) then
		pitchState=0
		return true
	elseif key == KEY_SpeedUp or key == KEY_SpeedDown then
		throttleState = 0
		return true		
	elseif key == KEY_RollLeft or key == KEY_RollRight then
		rollState = 0
		return true			
	elseif key == KEY_Gun then
		WG.controlstate.buttons[B_Gun]=-1
	elseif key == KEY_Missile then
		WG.controlstate.buttons[B_Missile]=-1
	elseif key==KEY_SensitivityToggle then
		sensitivityState = 1
	end
end

function widget:GameFrame(n)
	if WG.teamplane then
		if rollState ~= 0 then
			local roll = WG.controlstate.roll + roll_increment*rollState*sensitivityState
			
			if roll > 1 then roll = -2+roll
			elseif roll < -1 then roll = 2+roll
			end
                        WG.controlstate.roll = roll
		end
		WG.controlstate.pitch = pitch_increment*pitchState*sensitivityState
	end
end
