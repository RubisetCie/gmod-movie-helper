
MOD.Name = "Nonphysical Bones"

local ToQuatern = ToQuatern

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetBoneCount()

    local data = {}

    for b = 0, count - 1 do

        local d = {}
        d.Pos = entity:GetManipulateBonePosition(b)
        d.Ang = ToQuatern(entity:GetManipulateBoneAngles(b))
        d.Scale = entity:GetManipulateBoneScale(b)

        data[b] = d

    end

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

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetBoneCount()

    for b = 0, count - 1 do

        local d = data[b]
        entity:ManipulateBonePosition(b, d.Pos)
        entity:ManipulateBoneAngles(b, d.Ang:Angle())
        entity:ManipulateBoneScale(b, d.Scale)

    end

end

local LerpLinear = SMH.LerpLinear
local LerpLinearAngle = SMH.LerpLinearAngle
local LerpLinearVector = SMH.LerpLinearVector

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetBoneCount()

    for b = 0, count - 1 do

        local d1 = data1[b]
        local d2 = data2[b]

        local Pos = LerpLinearVector(d1.Pos, d2.Pos, percentage)
        local Ang = LerpLinearAngle(d1.Ang, d2.Ang, percentage)
        local Scale = LerpLinear(d1.Scale, d2.Scale, percentage)

        entity:ManipulateBonePosition(b, Pos)
        entity:ManipulateBoneAngles(b, Ang:Angle())
        entity:ManipulateBoneScale(b, Scale)

    end
end

local Spline = SMH.Spline
local SplineAngle = SMH.SplineAngle

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetBoneCount()

    for b = 0, count - 1 do

        local d0 = befdata1[b]
        local d1 = data1[b]
        local d2 = data2[b]
        local d3 = aftdata2[b]

        local Pos = Spline(d0.Pos, d1.Pos, d2.Pos, d3.Pos, percentage)
        local Ang = SplineAngle(d0.Ang, d1.Ang, d2.Ang, d3.Ang, percentage)
        local Scale = Spline(d0.Scale, d1.Scale, d2.Scale, d3.Scale, percentage)

        entity:ManipulateBonePosition(b, Pos)
        entity:ManipulateBoneAngles(b, Ang:Angle())
        entity:ManipulateBoneScale(b, Scale)

    end
end
