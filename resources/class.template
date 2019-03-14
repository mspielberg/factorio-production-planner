local M = {}
local meta = { __index = M }

local function restore(self)
  return setmetatable(self, meta)
end

local function new()
  local self = {
  }
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
