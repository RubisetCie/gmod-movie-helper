
MOD.Name = "Advanced Cameras"

function MOD:IsAdvCamera(entity)

    if entity:GetClass() ~= "hl_camera" then return false end
    return true

end

function MOD:Save(entity)

    if not self:IsAdvCamera(entity) then return nil end

    local data = {}

    data.FOV = entity:GetFOV()
    data.Nearz = entity:GetNearZ()
    data.Farz = entity:GetFarZ()
    data.Roll = entity:GetRoll()
    data.Offset = entity:GetViewOffset()

    return data

end

function MOD:Load(entity, data)

    entity:SetFOV(data.FOV)
    entity:SetNearZ(data.Nearz)
    entity:SetFarZ(data.Farz)
    entity:SetRoll(data.Roll)
    entity:SetViewOffset(data.Offset)

end

local LerpLinear = SMH.LerpLinear
local LerpLinearVector = SMH.LerpLinearVector

function MOD:LoadBetween(entity, data1, data2, percentage)

    entity:SetFOV(LerpLinear(data1.FOV, data2.FOV, percentage))
    entity:SetNearZ(LerpLinear(data1.Nearz, data2.Nearz, percentage))
    entity:SetFarZ(LerpLinear(data1.Farz, data2.Farz, percentage))
    entity:SetRoll(LerpLinear(data1.Roll, data2.Roll, percentage))
    entity:SetViewOffset(LerpLinearVector(data1.Offset, data2.Offset, percentage))

end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    entity:SetFOV(Spline(befdata1.FOV, data1.FOV, data2.FOV, aftdata2.FOV, percentage))
    entity:SetNearZ(Spline(befdata1.Nearz, data1.Nearz, data2.Nearz, aftdata2.Nearz, percentage))
    entity:SetFarZ(Spline(befdata1.Farz, data1.Farz, data2.Farz, aftdata2.Farz, percentage))
    entity:SetRoll(Spline(befdata1.Roll, data1.Roll, data2.Roll, aftdata2.Roll, percentage))
    entity:SetViewOffset(Spline(befdata1.Offset, data1.Offset, data2.Offset, aftdata2.Offset, percentage))

end
