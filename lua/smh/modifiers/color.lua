
MOD.Name = "Color"

function MOD:Save(entity)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local color = entity:GetColor()
    return { Color = color }

end

function MOD:Load(entity, data)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    entity:SetColor(data.Color)

end

local LerpLinear = SMH.LerpLinear

function MOD:LoadBetween(entity, data1, data2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local c1 = data1.Color
    local c2 = data2.Color

    local r = LerpLinear(c1.r, c2.r, percentage)
    local g = LerpLinear(c1.g, c2.g, percentage)
    local b = LerpLinear(c1.b, c2.b, percentage)
    local a = LerpLinear(c1.a, c2.a, percentage)

    entity:SetColor(Color(r, g, b, a))

end

local Spline = SMH.Spline

function MOD:LoadInterpolated(entity, befdata1, data1, data2, aftdata2, percentage)

    if self:IsEffect(entity) then
        entity = entity.AttachedEntity
    end

    local c0 = befdata1.Color
    local c1 = data1.Color
    local c2 = data2.Color
    local c3 = aftdata2.Color

    local r = Spline(c0.r, c1.r, c2.r, c3.r, percentage)
    local g = Spline(c0.g, c1.g, c2.g, c3.g, percentage)
    local b = Spline(c0.b, c1.b, c2.b, c3.b, percentage)
    local a = Spline(c0.a, c1.a, c2.a, c3.a, percentage)

    entity:SetColor(Color(r, g, b, a))

end
