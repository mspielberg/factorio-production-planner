local function find(haystack, needle)
  for k, v in pairs(haystack) do
    if v == needle then
      return k
    end
  end
  return nil
end

local memoize_meta = { __mode = "k" }
local function memoize(f)
  local cache = setmetatable({}, memoize_meta)
  return function(x)
    local result = cache[x]
    if not result then
      result = f(x)
      cache[x] = result
    end
    return result
  end
end

return {
  find = find,
  memoize = memoize,
}