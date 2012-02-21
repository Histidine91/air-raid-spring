local base = piece 'base'

function script.BlockShot()
    return true
end

local anglesX = {0, 30, 60, 75, 90}
local anglesY = {0, 45, 135, 180, 225, 270, 315}

local vel = {0, 0, 0}

function SetVelocity(x,y,z)
    Spring.MoveCtrl.Enable(unitID, true)
    --Spring.MoveCtrl.SetVelocity(unitID, x/2,y/2,z/2)
    Spring.MoveCtrl.SetVelocity(unitID, 0, 0, 0)
    vel = {x, y, z}
end

local function deto()
    local rot
    for i=1,64 do
        --Spring.SetUnitVelocity(unitID, vel[1]/2, vel[2]/2, vel[3]/2)
        local rx = anglesX[math.random(1,#anglesX)]
        local ry = anglesY[math.random(1,#anglesY)]
        Turn(base, x_axis, math.rad(rx))
        Turn(base, y_axis, math.rad(ry))    
        GG.BombDrop(unitID, Spring.GetUnitDefID(unitID), Spring.GetUnitTeam(unitID), 1)
        EmitSfx(base, 2048)
        Sleep(33)
    end
    Spring.DestroyUnit(unitID, false, true)
end

function Detonate()
    StartThread(deto)
end