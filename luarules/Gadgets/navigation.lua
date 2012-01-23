function gadget:GetInfo()
	return {
		name = "Navigation",
		desc = "Nav GUI elements",
		author = "KDR_11k (David Becker), KingRaptor (L.J. Lim)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 5,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

local planedata
local teamplane

function gadget:Initialize()
	planedata=GG.planedata
	teamplane=GG.teamplane
end

else

--UNSYNCED

local throttleWidth = 16	--absolute
local throttleX = 0.1
local throttleHeight = 0.5
local throttleY = 0.25

local textsize = 16

local scaleMult = 10	--elmos -> meter
local mpsToKnots = 3600/1000/1.8

function Rectangle(x1,y1,x2,y2)
	gl.Vertex(x1,y1,0)
	gl.Vertex(x2,y1,0)
	gl.Vertex(x2,y2,0)
	gl.Vertex(x1,y2,0)
end

function gadget:Initialize()
end

function gadget:DrawScreen(vsx,vsy)
	local planedata=SYNCED.planedata
	local p=SYNCED.teamplane[Spring.GetMyTeamID()]
	if p then
		--for i,d in spairs(p.ammo) do
		--	gl.Color(0,.5,0,.4)
		--	gl.Rect(vsx - rightdist + 10 - (listwidth+10)*(1-math.fmod(d.ammo,1)), bottomdist + i*entrydist-6,vsx - rightdist - listwidth, bottomdist + (i+1)*entrydist -10)
		--	gl.Color(0,1,0,1)
		--	gl.Text(math.floor(d.ammo), vsx - rightdist, bottomdist + i*entrydist, textsize, "r")
		--	gl.Text(d.name, vsx - rightdist - namedist, bottomdist + i*entrydist, textsize, "r")
		--end
		local speed = math.max(p.currentspeed)
		local x,y,z = Spring.GetUnitPosition(p.unit)
		local alt = math.floor(y - math.max(Spring.GetGroundHeight(x,z),0))
		gl.Color(0,.5,0,.4)
		gl.Rect(vsx*throttleX, vsy*throttleY, vsx*throttleX + throttleWidth, vsy*(throttleY + throttleHeight*speed/planedata[p.ud].speed))
		gl.Color(0,1,0,1)
		gl.BeginEnd(GL.LINE_LOOP,Rectangle, vsx*throttleX, vsy*throttleY, vsx*throttleX + throttleWidth, vsy*(throttleY + throttleHeight))
		gl.Text("SPD  "..math.floor(speed*Game.gameSpeed*scaleMult*mpsToKnots).." KTS",vsx*throttleX,vsy*throttleY-32, textsize, "l")
		gl.Text("ALT  "..alt*scaleMult*0.5 .." m" ,vsx*throttleX,vsy*throttleY-64, textsize, "l")
		gl.Color(1,1,1,1)
	end
end

end
