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

if (gadgetHandler:IsSyncedCode()) then

--SYNCED
function gadget:GameFrame()
	for _,d in pairs(GG.teamplane) do
		d.target=Spring.GetUnitCOBValue(d.unit,83,d.currentweapon+1)
	end
end

else

--UNSYNCED

local dsize=36
local ssize=30;
local targetCutoff=1500;
local rangeInfo=1000;
local gunRange=350;
local reticleSize=10;
local arrowSize=10;

local minidiamond,diamond, square, reticle

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

function Diamond()
	gl.Vertex(0,dsize,0)
	gl.Vertex(dsize,0,0)
	gl.Vertex(0,-dsize,0)
	gl.Vertex(-dsize,0,0)
end

function MiniDiamond()
	gl.Vertex(0,dsize/4,0)
	gl.Vertex(dsize/4,0,0)
	gl.Vertex(0,-dsize/4,0)
	gl.Vertex(-dsize/4,0,0)
end

function Square()
	gl.Vertex(ssize,ssize,0)
	gl.Vertex(-ssize,ssize,0)
	gl.Vertex(-ssize,-ssize,0)
	gl.Vertex(ssize,-ssize,0)
end

function gadget:Initialize()
	diamond=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,Diamond)
	minidiamond=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,MiniDiamond)
	square=gl.CreateList(gl.BeginEnd,GL.LINE_LOOP,Square)
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
		gl.Color(0,1,0,1)
		local cx,cy,cz=Spring.GetUnitPosition(p.unit)
		for _,u in ipairs(Spring.GetUnitsInSphere(cx,cy,cz,targetCutoff)) do
			if Spring.GetUnitTeam(u) ~= team then
				local dist = Spring.GetUnitSeparation(p.unit,u)
				if dist < targetCutoff then
					local x,y,z = Spring.GetUnitPosition(u)
					local sx,sy,sz=Spring.WorldToScreenCoords(x,y,z)
					--if echoFreq > 120 then
					--	Spring.Echo(sx,sy,sz)
					--	echoFreq = 0
					--end
					if sz<1 then	-- in front of us
						gl.PushMatrix()
						gl.Translate(sx,sy,0)
						gl.CallList(diamond)
						if dist < gunRange then
							gl.CallList(minidiamond)
						end
						if dist < rangeInfo then
							local str
							if dist > 200 then
								str = ("%.1f"):format(dist/100).." km"
							else
								str = math.ceil(dist*10).." m"
							end
							gl.Text(str, ssize/2, -ssize/2, 14)
						end
						local hp,mhp= Spring.GetUnitHealth(u)
						if hp < mhp then
							gl.Text(math.floor(100*hp/mhp).."%",0,0,14,"c")
						end
						local ud = Spring.GetUnitDefID(u)
						if UnitDefs[ud].customParams.label then
							gl.Text(UnitDefs[ud].customParams.label,0,dsize,17,"c")
						end
						gl.PopMatrix()
					end
					-- mark target directions
					local visible
					local udef = UnitDefs[Spring.GetUnitDefID(u)]
					if dist < rangeInfo and (udef.canFly or udef.customParams.playable) and not Spring.IsUnitInView(u) then
						gl.Color(1,1,0,1)
						local midx, midy = vsx/2, vsy/2
						local dx, dy = sx-midx, sy-midy	
						if sz >= 1 then
							dx = midx-sx
							dy = midy-sy	-- note that this is the opposite of what is expected (and required for a target in front)
						end
						local theta = GetAngleFromVector(dx, dy)
						local radius = vsy/4
						local finalX, finalY = math.cos(theta)*radius + midx, math.sin(theta)*radius + midy
						
						gl.PushMatrix()
						gl.Translate(finalX, finalY, 0)
						gl.BeginEnd(GL.POLYGON, Arrowhead, theta, dist)
						gl.PopMatrix()
					end	
				end
			end
		end
		if p.target ~= -1 and Spring.ValidUnitID(p.target) then
			gl.Color(1,0,0,1)
			local x,y,z = Spring.GetUnitPosition(p.target)
			local sx,sy=Spring.WorldToScreenCoords(x,y,z)
			gl.PushMatrix()
			gl.Translate(sx,sy,0)
			gl.CallList(square)
			gl.PopMatrix()
		end
		gl.Color(1,1,1,1)
	end
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
		gl.BeginEnd(GL.LINES,ConeEnd,SYNCED.planedata[p.ud].ammo[p.currentweapon].range,SYNCED.planedata[p.ud].ammo[p.currentweapon].cone)
		gl.PopMatrix()
		
		gl.Color(1,1,1,1)
	end
end

end
