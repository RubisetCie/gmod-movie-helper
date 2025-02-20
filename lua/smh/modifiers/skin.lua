
MOD.Name = "Skin"

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    return entity:GetSkin()
end

function MOD:LoadGhost(entity, ghost, data)
    self:Load(ghost, data)
end

function MOD:LoadGhostBetween(entity, ghost, data1, data2, percentage)
    self:LoadBetween(ghost, data1, data2, percentage)
end

function MOD:LoadGhostInterpolated(entity, ghost, _, data1, data2, _, percentage)
    self:LoadBetween(ghost, data1, data2, percentage)
end

function MOD:Load(entity, data)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    entity:SetSkin(data)
end

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    self:Load(entity, data1)

end

function MOD:LoadInterpolated(entity, _, data1, data2, _, percentage)
    self:LoadBetween(entity, data1, data2, percentage)
end
