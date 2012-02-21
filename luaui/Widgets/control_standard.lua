function widget:GetInfo()
	return {
		name = "Controls (default)",
		desc = "Default control set, exactly one control set must be enabled",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

VFS.Include("LuaRules/Configs/globalConstants.h.lua")

local B_Gun = 0
local B_Missile = 1
local B_NextWeapon = 2
local B_PrevWeapon = 3

local vsx=0
local vsy=0
local deadzone=.05

local THROTTLE_INCREMENT = 0.05

function ChangeControls()
	Spring.SendCommands("luaui disablewidget Controls (default)")
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

function widget:IsAbove(x,y)
	if WG.hasPlane then
		--Spring.SendLuaRulesMsg("x:"..(x/vsx*2-1))
		WG.controlstate.roll=(x/vsx*2-1)
		local pitch = (y/vsy*2-1)
		if pitch > -deadzone and pitch < deadzone then
			pitch = 0
		end
		--Spring.SendLuaRulesMsg("y:"..pitch)
		WG.controlstate.pitch=pitch	
		return true
	end
	return false
end

function widget:MousePress(x,y,button)
	if WG.hasPlane then
		if button ~=2 then
			--Spring.SendLuaRulesMsg("down:"..button)
			if button == 1 then
				WG.controlstate.buttons[B_Gun]=1
			elseif button == 3 then
				WG.controlstate.buttons[B_Missile]=1
			end
		else
			local maxdist=40000 --200^2
			local target=nil
			for _,u in ipairs(Spring.GetVisibleUnits()) do
				local team = Spring.GetUnitTeam(u)
				if team~=Spring.GetMyTeamID() then
					local ux,uy,uz=Spring.GetUnitPosition(u)
					local sx,sy=Spring.WorldToScreenCoords(ux,uy,uz)
					local dist = (sx-x)*(sx-x) + (sy-y)*(sy-y)
					local dist2 = Spring.GetUnitSeparation(WG.hasPlane,u)
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
		return true
	end
	return false
end

function widget:MouseRelease(x,y,button)
	if WG.hasPlane then
		--Spring.SendLuaRulesMsg("up:"..button)
		if button == 1 then
			WG.controlstate.buttons[B_Gun]=-1
		elseif button == 3 then
			WG.controlstate.buttons[B_Missile]=-1
		end
		return true
	end
	return false
end

function widget:MouseWheel(_,dir)
	if not WG.hasPlane then
		return false
	end
	if dir==-1 then
		--Spring.SendLuaRulesMsg("prevweapon")
		WG.controlstate.buttons[B_PrevWeapon]=1
	else
		--Spring.SendLuaRulesMsg("nextweapon")
		WG.controlstate.buttons[B_NextWeapon]=1
	end
	return true
end
