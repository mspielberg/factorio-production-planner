local inspect = require "inspect"

local VirtualRecipe = {}
local meta = { __index = VirtualRecipe }

function VirtualRecipe:get_prototype_rates()
  return self.items
end

function VirtualRecipe:get_current_rates()
  return self.items
end

function VirtualRecipe:get_constrained_by()
  return {}
end

function VirtualRecipe:get_constrains(item_name)
  local out = {}
  for _, constraint in pairs(self.constrains) do
    if constraint.item == item_name then
      out[#out+1] = constraint.recipe
    end
  end
  return out
end

function VirtualRecipe:get_links()
  return {}
end

function VirtualRecipe:update_rate()
end

local M = {}

function M.new(name, rate)
  local self = {
    name = name,
    localised_name = game.item_prototypes[name].localised_name,
    rate = rate,
    constrains = {},
    constrained_by = {},
    items = { [name] = rate },
    is_virtual = true,
  }
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
