function widget:GetInfo()
	return {
		name = "Controls (pointer-based)",
		desc = "Pointer based control set, fly to where you point the mouse, exactly one control set must be enabled",
		author = "KDR_11k (David Becker)",
		date = "2009-09-07",
		license = "Public Domain",
		layer = 1,
		enabled = false
	}
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

function widget:IsAbove(x,y)
	if hasPlane then
		local dx = x - vsx/2
		local dy = y - vsy/2
		if dx==0 then
			dx = 0.00000001
		end
		local dist = math.min(math.sqrt((dx*dx)+(dy*dy))/vsy,1)
		if dist > deadzone then
			local phi = .5 * math.pi - math.atan(dy/dx)
			if dx < 0 then
				phi = phi - math.pi
			end
			state.roll = phi / math.pi
			state.pitch = -dist
		else
			state.pitch=0
		end
		return true
	end
	return false
end

function widget:MousePress(x,y,button)
	if hasPlane then
		if button ~=2 then
			--Spring.SendLuaRulesMsg("down:"..button)
			if button == 1 then
				state.buttons[B_Gun]=1
			elseif button == 3 then
				state.buttons[B_Missile]=1
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
		end
		return true
	end
	return false
end

function widget:MouseRelease(x,y,button)
	if hasPlane then
		--Spring.SendLuaRulesMsg("up:"..button)
		if button == 1 then
			state.buttons[B_Gun]=-1
		elseif button == 3 then
			state.buttons[B_Missile]=-1
		end
		return true
	end
	return false
end

function widget:MouseWheel(_,dir)
	if dir==-1 then
		--Spring.SendLuaRulesMsg("prevweapon")
		state.buttons[B_PrevWeapon]=1
	else
		--Spring.SendLuaRulesMsg("nextweapon")
		state.buttons[B_NextWeapon]=1
	end
	return true
end

local rudderstate=0

function widget:KeyPress(key)
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
		state.throttle=math.min(state.throttle+THROTTLE_INCREMENT, 1)
	elseif key==KEY_SpeedDown then
		state.throttle=math.max(state.throttle-THROTTLE_INCREMENT, 0)
	end
end

function widget:KeyRelease(key)
	if (key == KEY_RudderLeft and rudderstate== 1) or (key==KEY_RudderRight and rudderstate== -1) then
		--Spring.SendLuaRulesMsg("z:0")
		state.yaw=0
		rudderstate=0
		return true
	end
end

function widget:GameFrame()
	if hasPlane then
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
