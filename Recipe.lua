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

local function item_constraints(self)
  local out = {}
  for _, constraint in pairs(self.constrained_by) do
    local constraining_recipe = constraint.recipe
    local item_name = constraint.item
    out[item_name] = (out[item_name] or 0) -
      constraining_recipe:get_item_rates()[item_name]
  end
  return out
end

local function update_rate(self)
  local item_constraints = item_constraints(self)
  local new_rate = 0
  for item_name, required_rate in pairs(item_constraints) do
    local required_recipe_rate = required_rate / self.items[item_name]
    if required_recipe_rate > new_rate then
      new_rate = required_recipe_rate
    end
  end
  self:set_recipe_rate(new_rate)
end


local Recipe = {}

function Recipe:add_constraint(recipe, item_name)
  for k, constraint in pairs(self.constrains) do
    if constraint.recipe == recipe and constraint.item == item_name then
      return
    end
  end
  self.constrained_by[#self.constrained_by+1] = { recipe = recipe, item = item_name }
  recipe.constrains[#recipe.constrains] = { recipe = self, item = item_name }
  update_rate(self)
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
  update_rate(self)
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
    constraint.recipe:update_rate()
  end
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