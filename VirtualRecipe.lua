local inspect = require "inspect"

local VirtualRecipe = {}
local meta = { __index = VirtualRecipe }

function VirtualRecipe:get_item_rates()
  return { [self.name] = self.rate }
end

function VirtualRecipe:update_rate()
end

local M = {}

function M.new(name, rate)
  local self = {
    name = name,
    rate = rate,
    constrains = {},
  }
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
