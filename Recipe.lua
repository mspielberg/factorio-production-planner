local inspect = require "inspect"

local function normalize_items(proto)
  local out = {}
  for _, ingredient in pairs(proto.ingredients) do
    local name = ingredient.name
    out[name] = (out[name] or 0) - ingredient.amount
  end
  for _, product in pairs(proto.products) do
    local name = product.name
    local amount = product.amount or
      ((product.amount_max + product.amount_min) / 2 * product.probability)
    out[name] = (out[name] or 0) + amount
  end
  return out
end

local Recipe = {}

function Recipe:add_constraint(recipe, item_name)
  for k, constraint in pairs(self.constrains) do
    if constraint.recipe == recipe and constraint.item == item_name then
      return
    end
  end
  self.constrains[#self.constrains+1] = { recipe = recipe, item = item_name }
  recipe.constrained_by[#recipe.constrained_by] = { recipe = self, item = item_name }
end

function Recipe:remove_constraint(recipe, item_name)
  for i, constraint in pairs(self.constrains) do
    local constrained_recipe = constraint.recipe
    if constrained_recipe == recipe and constraint.item == item_name then
      for j, constrained_by in pairs(constrained_recipe.constrained_by) do
        if constrained_by.recipe == self and constrained_by.item == item_name then
          constrained_recipe.constrained_by[j] = nil
        end
      end
      constraints[i] = nil
      return
    end
  end
end

function Recipe:reset()
  self.rate = 0
end

function Recipe:is_constrained_by(other)
  for _, constrained in pairs(other.constrains) do
    if constrained.recipe == self then return true end
    if self:is_constrained_by(constrained.recipe) then return true end
  end
  return false
end

function Recipe:get_item_rates()
  local recipe_rate = self.rate
  local out = {}
  for item_name, amount in pairs(self.items) do
    out[item_name] = amount * recipe_rate
  end
  return out
end

function Recipe:set_recipe_rate(recipe_rate)
  assert(recipe_rate >= 0)
  if recipe_rate == self.rate then return end
  self.rate = recipe_rate
  for _, constraint in pairs(self.constrains) do
    local item_name = constraint.item
    local item_rate = recipe_rate * self.items[item_name]
    constraint.recipe:set_rate_by_item(item_name, -item_rate)
  end
end

function Recipe:set_rate_by_item(name, item_rate)
  self:set_recipe_rate(item_rate / self.items[name])
end

local M = {}

function M.new(name)
  local proto = game.recipe_prototypes[name]
  if not proto then return nil end

  local self = {
    name = name,
    rate = 0,
    energy = proto.energy,
    items = normalize_items(proto),
    constrains = {},
    constrained_by = {},
  }
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, { __index = Recipe })
end

return M