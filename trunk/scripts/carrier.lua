include "constants.lua"

local base, hull, radar, wake1, wake2, wake3, wake4 = piece("base", "hull", "radar", "wake1", "wake2", "wake3", "wake4")
local elevatora, elevatorb, elevatorc, pad1, pad2, pad3 = piece("elevatora", "elevatorb", "elevatorc", "pad1", "pad2", "pad3")
local wall1, wall2, wall3, cat1, cat2, cat3 = piece("wall1", "wall2", "wall3", "cat1", "cat2", "cat3")
local helo1, helo2 = piece("helo1", "helo2")

local gunPieces = {}
for i=1,6 do
	gunPieces[i] = {}
	gunPieces[i].turret = piece("turret"..i)
	gunPieces[i].barrel = piece("bar"..i)
	gunPieces[i].flare = piece("fp"..i)
	gunPieces[i].mbox = piece("mbox"..i)
	gunPieces[i].miss1 = piece("m"..i.."a")
	gunPieces[i].miss2 = piece("m"..i.."b")
end

local weaponPieceMap = {}
for i=1,12 do
	weaponPieceMap[i] = {}
	local num = math.ceil(i/2)
	weaponPieceMap[i].yaw = gunPieces[num].turret
	if i%2 == 1 then
		weaponPieceMap[i].pitch = gunPieces[num].barrel
		weaponPieceMap[i].fire = gunPieces[num].flare
	else
		weaponPieceMap[i].pitch = gunPieces[num].mbox
		weaponPieceMap[i].fire = {gunPieces[num].miss1, gunPieces[num].miss2}
	end
end

smokePiece = {base, elevatora, elevatorb, elevatorc}
----------------------------------------------------------
----------------------------------------------------------

local gun_num = {}
for i=2,12,2 do
	gun_num[i] = 1
end
local SIG_MOVE = 1
local SIG_RESTORE = 2

local unitDefID = Spring.GetUnitDefID(unitID)
----------------------------------------------------------
----------------------------------------------------------

local function Wake()
	Signal(SIG_MOVE)
	SetSignalMask(SIG_MOVE)
	while true do
		EmitSfx( wake1,  2 )
		EmitSfx( wake2,  2 )
		EmitSfx( wake3,  2 )
		EmitSfx( wake4,  2 )		
		Sleep( 200)
	end
end

function script.StartMoving()
	--StartThread(Wake)
end

function script.StopMoving()
	--Signal(SIG_MOVE)
end

function script.Create()
	StartThread(SmokeUnit)
	Spin(radar, y_axis, math.rad(120))
end

function script.QueryWeapon(num) 
	if num%2 == 1 then
		return weaponPieceMap[num].fire
	else
		return weaponPieceMap[num].fire[gun_num[num]]
	end
end

function script.AimFromWeapon(num)	
	return weaponPieceMap[num].yaw
end

local function RestoreAfterDelay()
end

function script.AimWeapon( num, heading, pitch )
	Signal(2^(num+1))
	SetSignalMask(2^(num+1))
	Turn(weaponPieceMap[num].yaw, y_axis, heading, math.rad(180))
	Turn(weaponPieceMap[num].pitch, x_axis, -pitch, math.rad(180))
	WaitForTurn(weaponPieceMap[num].yaw, y_axis)
	WaitForTurn(weaponPieceMap[num].pitch, x_axis)
	return true
end

function script.Shot(num)
	if num%2 == 0 then
		GG.MissileLaunch(unitID, unitDefID, Spring.GetUnitTeam(unitID), GetUnitValue(COB.TARGET_ID, num))
		gun_num[num] = gun_num[num] + 1
		if gun_num[num] == 2 then gun_num[num] = 1 end
	end
end


function script.Killed(recentDamage, maxHealth)
	local severity = recentDamage / maxHealth
	--[[
	if (severity <= .25) then
		Explode(base, sfxNone)
		Explode(turret, sfxNone)
		Explode(sleeves, sfxNone)
		Explode(barrel1, sfxFall)
		Explode(barrel2, sfxFall)
		return 1 -- corpsetype
	elseif (severity <= .5) then
		Explode(base, sfxNone)
		Explode(turret, sfxNone)
		Explode(sleeves, sfxShatter)
		Explode(barrel1, sfxSmoke)
		Explode(barrel2, sfxSmoke)
		return 1 -- corpsetype
	elseif (severity <= 1) then
		Explode(base, sfxShatter)
		Explode(turret, sfxShatter)
		Explode(sleeves, sfxShatter)
		Explode(barrel1, sfxSmoke + sfxFire)
		Explode(barrel2, sfxSmoke + sfxFire)
		return 2 -- corpsetype
	else
		Explode(base, sfxShatter)
		Explode(turret, sfxShatter)
		Explode(sleeves, sfxShatter)
		Explode(barrel1, sfxSmoke + sfxFire + sfxExplode)
		Explode(barrel2, sfxSmoke + sfxFire + sfxExplode)
		return 2 -- corpsetype
	end
	]]--
end
