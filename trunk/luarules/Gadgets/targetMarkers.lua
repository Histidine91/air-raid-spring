function gadget:GetInfo()
	return {
		name = "Target Markers",
		desc = "highlights targets",
		author = "KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 10,
		enabled = true
	}
end

include("LuaRules/Configs/globalConstants.h.lua")

if (gadgetHandler:IsSyncedCode()) then

--SYNCED
function gadget:GameFrame()
	for _,d in pairs(GG.teamplane) do
		if d.wantedtarget then
			Spring.GetUnitCOBValue(d.unit, 106,d.currentweapon+1,d.wantedtarget)
		end
		d.target=Spring.GetUnitCOBValue(d.unit,83,d.currentweapon+1)
	end
end

else

--UNSYNCED
local scaleMult = 5	--elmos -> meter

local dsize=36
local ssize=30;
local targetCutoff=MAX_TARGET_RANGE;
local rangeInfoRange=2000;
local nameRange=1500;
local trackRange=800;
local gunRange=350;
local reticleSize=10;
local arrowSize=10;

local baseDistance = 500^0.5

local minidiamond, diamond, square, reticle

local colors = {
	blue = {0, 0, 1, 1},
	green = {0, 1, 0, 1},
	red = {1, 0, 0, 1},
}

local function GetQuadrant(x, y)
	if x > 0 then
		return y > 0 and 1 or 4
	elseif x < 0 then
		return y > 0 and 2 or 3
	else	-- x == 0
		return y > 0 and 1 or 3
	end
end

local function GetAngleFromVector(x, y)
	local quadrant = GetQuadrant(x, y)
	local theta = math.atan(math.abs(y)/math.abs(x))
	if quadrant == 2 then
		theta = math.pi - theta
	elseif quadrant == 3 then
		theta = math.pi + theta
	elseif quadrant == 4 then
		theta = 2*math.pi - theta
	end
	return theta
end

function Reticle()
	gl.Vertex(reticleSize,0,gunRange)
	gl.Vertex(reticleSize*.25,0,gunRange)

	gl.Vertex(-reticleSize,0,gunRange)
	gl.Vertex(-reticleSize*.25,0,gunRange)

	gl.Vertex(0,reticleSize*.8,gunRange)
	gl.Vertex(0,reticleSize*.25,gunRange)

	gl.Vertex(reticleSize*.25,0,gunRange)
	gl.Vertex(0,reticleSize*.25,gunRange)

	gl.Vertex(-reticleSize*.25,0,gunRange)
	gl.Vertex(0,reticleSize*.25,gunRange)

	gl.Vertex(reticleSize*.25,0,gunRange)
	gl.Vertex(reticleSize*.125,-reticleSize*.125,gunRange)

	gl.Vertex(-reticleSize*.25,0,gunRange)
	gl.Vertex(-reticleSize*.125,-reticleSize*.125,gunRange)
end

function Arrowhead(theta, dist)
	local size = arrowSize*(2000-dist)/1000
	local c = math.cos(theta)
	local s = math.sin(theta)
	gl.Vertex(c*size, s*size, 0)
	theta = theta + math.rad(135)
	c = math.cos(theta)
	s = math.sin(theta)	
	gl.Vertex(c*size, s*size, 0)
	gl.Vertex(0, 0, 0)
	theta = theta + math.rad(90)
	c = math.cos(theta)
	s = math.sin(theta)
	gl.Vertex(c*size, s*size, 0)	
end

function ConeEnd(dist,angle)
	scale=dist * math.sin(angle)
	dist=dist * math.cos(angle)
	for i=1,4 do
		for j=0,4 do
			local phi=.5*i-.325+.025*j
			gl.Vertex(math.cos(phi*3.1415)*scale,math.sin(phi*3.1415)*scale,dist)
			gl.Vertex(math.cos((phi+.025)*3.1415)*scale,math.sin((phi+.025)*3.1415)*scale,dist)
		end
	end
end

function LaserSight(dist)
		gl.Vertex(0,0,10)
		gl.Vertex(0,0,dist)
end

function Diamond(size)
	gl.Vertex(0,dsize*size,0)
	gl.Vertex(dsize*size,0,0)
	gl.Vertex(0,-dsize*size,0)
	gl.Vertex(-dsize*size,0,0)
end

function MiniDiamond(size)
	gl.Vertex(0,dsize*size/4,0)
	gl.Vertex(dsize*size/4,0,0)
	gl.Vertex(0,-dsize*size/4,0)
	gl.Vertex(-dsize*size/4,0,0)
end

function Square(size)
	gl.Vertex(ssize*size,ssize*size,0)
	gl.Vertex(-ssize*size,ssize*size,0)
	gl.Vertex(-ssize*size,-ssize*size,0)
	gl.Vertex(ssize*size,-ssize*size,0)
end

function Line(x1,y1,z1,x2,y2,z2)
	gl.Vertex(x1, y1, z1)
	gl.Vertex(x2, y2, z2)
end

function gadget:Initialize()
	--diamond=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,Diamond)
	--minidiamond=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,MiniDiamond)
	--square=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,Square)
	reticle=gl.CreateList(gl.BeginEnd,GL.LINES, Reticle)
end

function gadget:Shutdown()
	gl.DeleteList(diamond)
	gl.DeleteList(minidiamond)
	gl.DeleteList(square)
	gl.DeleteList(reticle)
end

--local echoFreq = 0
function gadget:DrawScreenEffects(vsx,vsy)
	--echoFreq = echoFreq+1
	local team = Spring.GetMyTeamID()
	local p = SYNCED.teamplane[team]
	if p then
		-- draw target boxes and information
		--gl.Color(0,1,0,1)
		local cx,cy,cz=Spring.GetUnitPosition(p.unit)
		for _,u in ipairs(Spring.GetUnitsInSphere(cx,cy,cz,targetCutoff)) do
			local uteam = Spring.GetUnitTeam(u)
			local ud = Spring.GetUnitDefID(u)
			if u ~= p.unit and not UnitDefs[ud].customParams.isweapon then
				local dist = Spring.GetUnitSeparation(p.unit,u)
				local size = (baseDistance/(dist^0.5)) or 1
				local isTarget = (p.target ~= -1 and p.target == u)
				local isWantedTarget = (p.wantedtarget == u)
				local color = colors.green
				if dist < targetCutoff then
					local x,y,z = Spring.GetUnitPosition(u)
					local sx,sy,sz=Spring.WorldToScreenCoords(x,y,z)
					--if echoFreq > 120 then
					--	Spring.Echo(sx,sy,sz)
					--	echoFreq = 0
					--end
					local isAllied = false
					if sz<1 then	-- in front of us
						-- team coloration
						if Spring.AreTeamsAllied(team, uteam) then
							color = colors.blue
							isAllied = true
						end
						gl.Color(color)
						gl.PushMatrix()
						gl.Translate(sx,sy,0)
						
						-- target square
						--gl.CallList(diamond)
						if isTarget and isWantedTarget then
							gl.Color(colors.red)
						end
						gl.BeginEnd(GL.LINE_LOOP,Square,size)
						gl.Color(color)
						
						-- "in gun range" marker
						if (dist < gunRange) and not isAllied then
							--gl.CallList(minidiamond)
							gl.BeginEnd(GL.LINE_LOOP,MiniDiamond,size)
						end
						
						-- range display
						if ((dist < rangeInfoRange) or isWantedTarget) and not isAllied then
							local str
							if dist > 400 then
								str = ("%.1f"):format(dist/(1000/scaleMult)).." km"
							else
								str = math.ceil(dist*scaleMult).." m"
							end
							gl.Text(str, ssize*size + 2, -ssize*size, 14)
						end
						
						-- health display
						local hp,mhp= Spring.GetUnitHealth(u)
						if hp < mhp then
							gl.Text(math.floor(100*hp/mhp).."%",0,0,14,"c")
						end
						
						--name display
						if ((dist < nameRange) or isWantedTarget) and UnitDefs[ud].customParams.label then
							gl.Text(UnitDefs[ud].customParams.label,0,ssize*size + 2,16,"c")
						end
						gl.PopMatrix()
					end
					
					-- mark directions of nearby enemy aircraft out of our line of sight
					if not isAllied then
						local udef = UnitDefs[ud]
						if dist < trackRange and (udef.canFly or udef.customParams.playable) and not Spring.IsUnitInView(u) then
							local midx, midy = vsx/2, vsy/2
							local dx, dy = sx-midx, sy-midy	
							if sz >= 1 then
								dx = midx-sx
								dy = midy-sy	-- note that this is the opposite of what is expected (and required for a target in front)
							end
							local theta = GetAngleFromVector(dx, dy)
							local radius = vsy/4
							local finalX, finalY = math.cos(theta)*radius + midx, math.sin(theta)*radius + midy
							
							if isWantedTarget then
								gl.Color(1,0,0,1)
							else
								gl.Color(1,1,0,1)
							end
							gl.PushMatrix()
							gl.Translate(finalX, finalY, 0)
							gl.BeginEnd(GL.POLYGON, Arrowhead, theta, dist)
							gl.PopMatrix()
							gl.Color(0,1,0,1)
						end
					end
				end
			end
		end
		if p.wantedtarget and Spring.ValidUnitID(p.wantedtarget) then
			local dist = Spring.GetUnitSeparation(p.wantedtarget,p.unit)
			local size = (baseDistance/(dist^0.5)) or 1			
			local x,y,z = Spring.GetUnitPosition(p.wantedtarget)
			local sx,sy=Spring.WorldToScreenCoords(x,y,z)
			if p.target == p.wantedtarget then
				gl.Color(1,0,0,1)
			end
			gl.PushMatrix()
			gl.Translate(sx,sy,0)
			--gl.CallList(square)
			gl.BeginEnd(GL.LINE_LOOP,Diamond,size)
			gl.PopMatrix()
		end
	end
	gl.Color(1,1,1,1)
end

local function DrawBombTarget(p, radius)
	gl.PushMatrix()
	local x,y,z = Spring.GetUnitPosition(p.unit)
	local tx,ty,tz
	
	-- estimate bomb impact point
	-- trace the bomb path out, figure out where it intersects the ground
	local gravity = Game.gravity
		
	local vx, vy, vz = p.velocity[1]*30*2, p.velocity[2]*30*2, p.velocity[3]*30*2
	
	local function CalculateDisplacement(p0, v, a, t)
		return p0 + v*t + 0.5*a*(t^2)
	end
	
	local function CalculatePosition(x0, y0, z0, vx, vy, vz, ax, ay, az, t)
		local x = CalculateDisplacement(x0, vx, ax, t)
		local y = CalculateDisplacement(y0, vy, ay, t)
		local z = CalculateDisplacement(z0, vz, az, t)
		return x,y,z
	end
	
	--test where bomb will be every 0.1 seconds
	for i=0,10,0.1 do
		local bp = {CalculatePosition(x,y,z,vx,vy,vz,0,-gravity,0,i)}
		local gh = Spring.GetGroundHeight(bp[1], bp[3])
		if gh >= bp[2] then
			tx,ty,tz = bp[1], gh, bp[3]
			break
		end
	end
	
	if tx and ty and tz then
		gl.DrawGroundCircle(tx,ty,tz,radius,64)
		gl.LineStipple('')
		gl.BeginEnd(GL.LINE_STRIP, Line, x, y-2, z, tx, ty, tz)
		gl.LineStipple(false)		
	end
	gl.PopMatrix()
end

local distScale = 2
function gadget:DrawWorld()
	local team = Spring.GetMyTeamID()
	local p = SYNCED.teamplane[team]
	if p then
		-- draw aiming cone
		gl.Color(0,1,0,1)
		gl.PushMatrix()
		gl.UnitMultMatrix(p.unit)
		gl.CallList(reticle)
		if p.ammo[p.currentweapon].ammo < 1 then
			gl.Color(1,0,0,1)
		end
		local wData = SYNCED.planedata[p.ud].ammo[p.currentweapon]
		if not wData.isbomb then
			gl.BeginEnd(GL.LINES,ConeEnd,wData.range,wData.cone)
		else
			gl.BeginEnd(GL.LINES,ConeEnd,600,math.rad(10))
		end
		gl.PopMatrix()
		
		if wData.isbomb then
			DrawBombTarget(p, wData.cone*360/math.pi)
		end	
		--gl.Color(1,0,0,0.5)
		--gl.BeginEnd(GL.LINES,LaserSight,gunRange)
		
		gl.Color(1,1,1,1)
		
		
	end
end

end
