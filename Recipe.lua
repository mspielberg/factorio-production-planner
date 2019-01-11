local inspect = require "inspect"

--- returns true if both a and b are item production (+ive) or item consumption (-ive)
local function same_rate_type(a, b)
  return (a or 0) * (b or 0) > 0
end

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
    local item_rates = constraining_recipe:get_current_rates()
    local item_name = constraint.item
    local constraining_rate = item_rates[item_name]
    out[item_name] = (out[item_name] or 0) - constraining_rate
  end
  return out
end

local function add_constraint(self, recipe, item_name)
  for k, constraint in pairs(self.constrained_by) do
    if constraint.recipe == recipe and constraint.item == item_name then
      return
    end
  end
  self.constrained_by[#self.constrained_by+1] = { recipe = recipe, item = item_name }
  recipe.constrains[#recipe.constrains+1] = { recipe = self, item = item_name}
end

local function remove_constraint(self, recipe, item_name)
  for i, constraint in pairs(self.constrained_by) do
    if constraint.recipe == recipe and constraint.item == item_name then
      table.remove(self.constrained_by, i)
      break
    end
  end

  for i, constraint in pairs(recipe.constrains) do
    if constraint.recipe == self and constraint.item == item_name then
      table.remove(recipe.constrains, i)
      break
    end
  end
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

  assert(new_rate >= 0)
  if new_rate ~= self.rate then
    self.rate = new_rate
    for _, constraint in pairs(self.constrains) do
      update_rate(constraint.recipe)
    end
  end
end

local Recipe = {}

function Recipe:add_constraint(recipe, item_name)
  add_constraint(self, recipe, item_name)
  update_rate(self)
end

function Recipe:remove_constraint(recipe, item_name)
  remove_constraint(self, recipe, item_name)
  update_rate(self)
end

function Recipe:is_constrained_by(other)
  for _, constrained in pairs(other.constrains) do
    if constrained.recipe == self or self:is_constrained_by(constrained.recipe) then
      return true
    end
  end
  return false
end

function Recipe:can_link(other, item_name)
  local my_count = self.items[item_name]
  local other_count = other.items[item_name]
  return my_count and other_count and my_count * other_count < 0 or false
end

function Recipe:get_constrained_by(item_name)
  local out = {}
  for _, constraint in pairs(self.constrained_by) do
    if constraint.item == item_name then
      out[#out+1] = constraint.recipe
    end
  end
  return out
end

function Recipe:get_constrains(item_name)
  local out = {}
  for _, constraint in pairs(self.constrains) do
    if constraint.item == item_name then
      out[#out+1] = constraint.recipe
    end
  end
  return out
end

function Recipe:get_prototype_rates()
  return self.items
end

function Recipe:get_current_rates()
  local recipe_rate = self.rate
  local out = {}
  for item_name, amount in pairs(self.items) do
    out[item_name] = amount * recipe_rate
  end
  return out
end

function Recipe:get_links()
  local out = {}
  for _, constraint in pairs(self.constrains) do
    out[constraint.item] = { localised_name = constraint.recipe.localised_name }
  end
  for _, constraint in pairs(self.constrained_by) do
    local item_name = constraint.item
    if not out[item_name] then out[item_name] = { constrained_by = {} } end
    table.insert(
      out[item_name].constrained_by,
      {
        localised_name = constraint.recipe.localised_name,
        rate = constraint.recipe.rate,
      }
    )
  end
  return out
end

function Recipe:set_recipe(recipe_name)
  local old_items = self.items
  self.name = recipe_name
  local proto = game.recipe_prototypes[recipe_name]
  self.localised_name = proto.localised_name
  self.energy = proto.energy
  self.items = normalize_items(proto)

  for _, constraint in pairs(self.constrained_by) do
    local item_name = constraint.item
    if not same_rate_type(self.items[item_name], old_items[item_name]) then
      remove_constraint(self, constraint.recipe, item_name)
    end
  end

  for _, constraint in pairs(self.constrains) do
    local item_name = constraint.item_name
    if not same_rate_type(self.items[item_name], old_items[item_name]) then
      remove_constraint(constraint.recipe, self, item_name)
    end
  end

  update_rate(self)
end

local M = {}

function M.new(name)
  local self = {
    name = "",
    localised_name = "",
    rate = 0, -- crafts/s
    energy = 0, -- only used to calculate number of needed crafting machines
    items = {},
    constrains = {},
    constrained_by = {},
  }
  M.restore(self)
  self:set_recipe(name)
  return self
end

function M.restore(self)
  return setmetatable(self, { __index = Recipe })
end

return M