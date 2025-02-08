
MOD.Name = "Model Scale"

function MOD:Save(entity)
    return {
        ModelScale = entity:GetModelScale()
    }
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
    entity:SetModelScale(data.ModelScale)
end

local LerpLinear = SMH.LerpLinear

function MOD:LoadBetween(entity, data1, data2, percentage)
    entity:SetModelScale(LerpLinear(data1.ModelScale, data2.ModelScale, percentage))
end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)
    entity:SetModelScale(Spline(befdata1.ModelScale, data1.ModelScale, data2.ModelScale, aftdata2.ModelScale, percentage))
end
