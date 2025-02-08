
MOD.Name = "Position and Rotation"

local ToQuatern = ToQuatern

function MOD:Save(entity)

    local data = {}
    data.Pos = entity:GetPos()
    data.Ang = ToQuatern(entity:GetAngles())
    return data

end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data)
end

function MOD:LoadGhostBetween(entity, ghost, data1, data2, percentage)
    self:LoadBetween(ghost, data1, data2, percentage)
end

function MOD:LoadGhostInterpolated(entity, ghost, befdata1, data1, data2, aftdata2, percentage)
    self:LoadInterpolated(ghost, befdata1, data1, data2, aftdata2, percentage)
end

function MOD:Load(entity, data)

    entity:SetPos(data.Pos)
    entity:SetAngles(data.Ang:Angle())

end

local LerpLinearAngle = SMH.LerpLinearAngle
local LerpLinearVector = SMH.LerpLinearVector

function MOD:LoadBetween(entity, data1, data2, percentage)

    local Pos = LerpLinearVector(data1.Pos, data2.Pos, percentage)
    local Ang = LerpLinearAngle(data1.Ang, data2.Ang, percentage)

    entity:SetPos(Pos)
    entity:SetAngles(Ang:Angle())

end

local Spline = SMH.Spline
local SplineAngle = SMH.SplineAngle

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    local Pos = Spline(befdata1.Pos, data1.Pos, data2.Pos, aftdata2.Pos, percentage)
    local Ang = SplineAngle(befdata1.Ang, data1.Ang, data2.Ang, aftdata2.Ang, percentage)

    entity:SetPos(Pos)
    entity:SetAngles(Ang:Angle())

end

function MOD:Offset(data, origindata, worldvector, worldangle, hitpos)

    if not hitpos then
        hitpos = origindata.Pos
    end

    local datanew = {}
    local Pos, Ang = WorldToLocal(data.Pos, data.Ang:Angle(), origindata.Pos, angle_zero)
    Pos, Ang = LocalToWorld(Pos, Ang, worldvector, worldangle)
    datanew.Pos = Pos + hitpos
    datanew.Ang = ToQuatern(Ang)
    return datanew

end

function MOD:OffsetDupe(entity, data, origindata)

    local entPos, entAng = entity:GetPos(), entity:GetAngles()
    local datanew = {}
    local Pos, Ang = WorldToLocal(data.Pos, data.Ang:Angle(), origindata.Pos, origindata.Ang)
    Pos, Ang = LocalToWorld(Pos, Ang, entPos, entAng)
    datanew.Pos = Pos
    datanew.Ang = ToQuatern(Ang)

    return datanew

end
