
MOD.Name = "Pose Parameters"

function MOD:Save(entity)

    local data = {}

    local count = entity:GetNumPoseParameters()
    for i = 0, count - 1 do
        local name = entity:GetPoseParameterName(i)
        data[name] = entity:GetPoseParameter(name)
    end

    return data

end

function MOD:Load(entity, data)

    for name, value in pairs(data) do
        entity:SetPoseParameter(name, value)
    end

end

local LerpLinear = SMH.LerpLinear

function MOD:LoadBetween(entity, data1, data2, percentage)

    for name, value1 in pairs(data1) do

        local value2 = data2[name]
        if value1 and value2 then
            entity:SetPoseParameter(name, LerpLinear(value1, value2, percentage))
        elseif value1 then
            entity:SetPoseParameter(name, value1)
        end

    end

end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    for name, value1 in pairs(data1) do

        local value2 = data2[name]
        local value3 = aftdata2[name]
        local value0 = befdata1[name]
        if value1 and value2 then
            entity:SetPoseParameter(name, Spline(value0, value1, value2, value3, percentage))
        elseif value1 then
            entity:SetPoseParameter(name, value1)
        end

    end

end
