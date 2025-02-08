---
-- Lerp methods
---

local Lerp = Lerp
local LerpVector = LerpVector
local LerpQuaternion = LerpQuaternion

-- Interpolate according to the cubic hermite spline
local function CubicHermite(sm, s, e, em, p)

    local p2 = p * p
    local p3 = p2 * p

    local a = -sm / 2.0 + (s * 3.0) / 2.0 - (e * 3.0) / 2.0 + em / 2.0
    local b = sm - (s * 5.0) / 2.0 + e * 2.0 - em / 2.0
    local c = -sm / 2.0 + e / 2.0
    local d = s

    return a * p3 + b * p2 + c * p + d

end

function SMH.LerpLinear(s, e, p)

    return Lerp(p, s, e)

end

function SMH.LerpLinearVector(s, e, p)

    return LerpVector(p, s, e)

end

function SMH.LerpLinearAngle(s, e, p)

    return LerpQuaternion(s, e, p)

end

function SMH.Spline(sm, s, e, em, p)

    return CubicHermite(sm, s, e, em, p)

end

function SMH.SplineAngle(sm, s, e, em, p)

    local sr = s
    local er = e
    local emr = em

    -- Invert quaternions if the delta if too far
    if sm:Dot(sr) < 0.0 then
        sr = s:Negated()
    end
    if sr:Dot(er) < 0.0 then
        er = e:Negated()
    end
    if er:Dot(emr) < 0.0 then
        emr = em:Negated()
    end

    return CubicHermite(sm, sr, er, emr, p)

end
