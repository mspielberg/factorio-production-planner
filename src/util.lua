local function find(haystack, needle)
  for k, v in pairs(haystack) do
    if v == needle then
      return k
    end
  end
  return nil
end

local memoize_meta = { __mode = "k" }
local NIL = {}
local function memoize(f)
  local cache = setmetatable({}, memoize_meta)
  return function(...)
    local count = select('#', ...)
    if not cache[count] then
      cache[count] = {}
    end
    local t = cache[count]
    for i=1, count - 1 do
      local k = select(i, ...)
      if k == nil then
        k = NIL
      end
      if not t[k] then
        t[k] = setmetatable({}, memoize_meta)
      end
      t = t[k]
    end
    local k = select(-1, ...)
    if k == nil then
      k = NIL
    end
    local result = t[k]
    if not result then
      result = f(...)
      t[k] = result
    end
    return result
  end
end

return {
  find = find,
  memoize = memoize,
}