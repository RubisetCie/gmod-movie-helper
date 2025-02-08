
MOD.Name = "Eye target"

function MOD:HasEyes(entity)

    local Eyes = entity:LookupAttachment("eyes")

    if Eyes == 0 then return false end
    return true

end

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    if not self:HasEyes(entity) then return nil end

    local data = {}

    data.EyeTarget = entity:GetEyeTarget()

    return data

end

function MOD:Load(entity, data)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    entity:SetEyeTarget(data.EyeTarget)

end

local LerpLinearVector = SMH.LerpLinearVector

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    entity:SetEyeTarget(LerpLinearVector(data1.EyeTarget, data2.EyeTarget, percentage))

end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    entity:SetEyeTarget(Spline(befdata1.EyeTarget, data1.EyeTarget, data2.EyeTarget, aftdata2.EyeTarget, percentage))

end
