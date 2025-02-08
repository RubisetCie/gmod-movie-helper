local QUATERNION = {
    __epsl = 0.0001,
    __lerp = 0.9995
}
QUATERNION.__index = QUATERNION

local metatable = setmetatable
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local rad = math.rad
local deg = math.deg
local abs = math.abs
local acos = math.acos
local asin = math.asin
local atan2 = math.atan2

local function Quatern(obj)
    return metatable({ w = obj.w, x = obj.x, y = obj.y, z = obj.z }, QUATERNION)
end

function ToQuatern(ang)

    local p = rad(ang.p) * 0.5
    local y = rad(ang.y) * 0.5
    local r = rad(ang.r) * 0.5
    local sinp = sin(p)
    local cosp = cos(p)
    local siny = sin(y)
    local cosy = cos(y)
    local sinr = sin(r)
    local cosr = cos(r)

    return metatable({
        w = cosr * cosp * cosy + sinr * sinp * siny,
        x = sinr * cosp * cosy - cosr * sinp * siny,
        y = cosr * sinp * cosy + sinr * cosp * siny,
        z = cosr * cosp * siny - sinr * sinp * cosy
    }, QUATERNION)
end

function LerpQuaternion(q, p, alpha)
    return Quatern(q):SLerp(p, alpha)
end

function QUATERNION:Length()
    return sqrt(self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z)
end

function QUATERNION:Normalize()
    local len = self:Length()
    return len > 0 && self:DivScalar(len) || self
end

function QUATERNION:Negated()
    return Quatern(self):MulScalar(-1.0)
end

function QUATERNION:__unm()
    return self:Negated()
end

function QUATERNION:Dot(q)
    return self.w * q.w + self.x * q.x + self.y * q.y + self.z * q.z
end

function QUATERNION:Add(q)
    self.w, self.x, self.y, self.z = self.w + q.w, self.x + q.x, self.y + q.y, self.z + q.z
    return self
end

function QUATERNION:__add(q)
    return Quatern(self):Add(q)
end

function QUATERNION:Sub(q)
    return self:Add(-q)
end

function QUATERNION:__sub(q)
    return Quatern(self):Sub(q)
end

function QUATERNION:MulScalar(scalar)
    self.w, self.x, self.y, self.z = self.w * scalar, self.x * scalar, self.y * scalar, self.z * scalar
    return self
end

function QUATERNION:__mul(q)
    return Quatern(self):MulScalar(q)
end

function QUATERNION:DivScalar(scalar)
    return self:MulScalar(1.0 / scalar)
end

function QUATERNION:__div(q)
    return Quatern(self):DivScalar(q)
end

function QUATERNION:LerpDomain(q, alphaStart, alphaEnd)
    return self:MulScalar(alphaStart):Add(Quatern(q):MulScalar(alphaEnd)):Normalize()
end

function QUATERNION:SLerp(q, alpha)

    local ref = q
    local dot = self:Dot(ref)

    local alphaStart = 1.0 - alpha
    local alphaEnd = alpha

    if (dot < 0.0) then
        ref = -q
        dot = -dot
    end

    if (dot < self.__lerp) then

        local theta = acos(dot)
        local thetaInv = abs(theta) < self.__epsl && 1.0 || (1.0 / sin(theta))

        alphaStart = sin((1.0 - alpha) * theta) * thetaInv
        alphaEnd = sin(alpha * theta) * thetaInv
    end

    return self:LerpDomain(ref, alphaStart, alphaEnd)
end

function QUATERNION:Angle()

    local qx = self.x * self.x
    local qy = self.y * self.y
    local qz = self.z * self.z

    return Angle(
        deg(asin(2.0 * (self.w * self.y - self.z * self.x))),
        deg(atan2(2.0 * (self.w * self.z + self.x * self.y), 1.0 - 2.0 * (qy + qz))),
        deg(atan2(2.0 * (self.w * self.x + self.y * self.z), 1.0 - 2.0 * (qx + qy))))
end
