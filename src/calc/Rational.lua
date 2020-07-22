local Rational = {}

local function gcd(a, b)
  if b == 0 then return a end
  return gcd(b, a % b)
end

local function simplify(self)
  local div = gcd(self[1], self[2] or 1)
  return { self[1] / div, (self[2] or 1) / div }
end

local meta = {}
function meta.__add(a, b)
  return Rational(a[1]*b[2] + b[1]*a[2], a[2]*b[2])
end

function meta.__sub(a, b)
  return a + b * -1
end

function meta.__mul(a, b)
  if type(a) == "number" then
    return Rational(b[1]*a, b[2])
  end
  if type(b) == "number" then
    return Rational(a[1]*b, a[2])
  end
  return Rational(a[1]*b[1], a[2]*b[2])
end

function meta.__div(a, b)
  if type(a) == "number" then
    return Rational(a * b[2], b[1])
  end
  return Rational(a[1]*b[2], a[2]*b[1])
end

function meta.__unm(a)
  return Rational(-a[1], a[2])
end

function meta.__eq(a, b)
  return a[1] == b[1] and a[2] == b[2]
end

function meta.__lt(a, b)
  if type(a) == "number" then
    return a < b[1] / b[2]
  end
  if type(b) == "number" then
    return b > a[1] / a[2]
  end
  return a[1]*b[2] < b[1]*a[2]
end

function meta.__call(self, num, denom)
  if type(num) == "number" then
    return setmetatable(simplify{num, denom}, meta)
  end
  if type(num) == "table" and denom == nil then
    if getmetatable(num) == meta then return num end
    local out = {}
    for k,v in pairs(num) do
      out[k] = Rational(v)
    end
    return out
  end
end

return setmetatable(Rational, meta)
