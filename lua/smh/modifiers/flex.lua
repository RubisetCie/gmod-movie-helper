
MOD.Name = "Facial flexes"

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetFlexNum()
    if count <= 0 then return nil end

    local data = {}

    data.Scale = entity:GetFlexScale()

    data.Weights = {}

    for i = 0, count - 1 do
        data.Weights[i] = entity:GetFlexWeight(i)
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

    entity:SetFlexScale(data.Scale)

    for i, f in pairs(data.Weights) do
        entity:SetFlexWeight(i, f)
    end

end

local LerpLinear = SMH.LerpLinear

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetFlexNum()
    local scale = LerpLinear(data1.Scale, data2.Scale, percentage)
    entity:SetFlexScale(scale)

    for i = 0, count - 1 do

        local w1 = data1.Weights[i]
        local w2 = data2.Weights[i]
        local w = LerpLinear(w1, w2, percentage)

        entity:SetFlexWeight(i, w)

    end

end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local count = entity:GetFlexNum()
    local scale = Spline(befdata1.Scale, data1.Scale, data2.Scale, aftdata2.Scale, percentage)
    entity:SetFlexScale(scale)

    for i = 0, count - 1 do

        local w0 = befdata1.Weights[i]
        local w1 = data1.Weights[i]
        local w2 = data2.Weights[i]
        local w3 = aftdata2.Weights[i]
        local w = Spline(w0, w1, w2, w3, percentage)

        entity:SetFlexWeight(i, w)

    end

end
