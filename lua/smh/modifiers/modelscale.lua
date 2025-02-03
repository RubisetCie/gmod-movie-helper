MOD.Name = "Model scale";

function MOD:Save(entity)
    return {
        ModelScale = entity:GetModelScale();
    };
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data);
end

function MOD:LoadGhostBetween(entity, ghost, data1, data2, percentage)
    self:LoadBetween(ghost, data1, data2, percentage);
end

function MOD:Load(entity, data)
    entity:SetModelScale(data.ModelScale);
end

local LerpLinear = SMH.LerpLinear

function MOD:LoadBetween(entity, data1, data2, percentage)

    local lerpedModelScale = LerpLinear(data1.ModelScale, data2.ModelScale, percentage);
    entity:SetModelScale(lerpedModelScale);

end
