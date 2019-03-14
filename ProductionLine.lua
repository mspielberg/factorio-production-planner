local Recipe = require "Recipe"

local ProductionLine = {}

local function get_recipe_index(self, recipe)
  for i, r in ipairs(self.recipes) do
    if r == recipe then
      return i
    end
  end
end

function ProductionLine:change_recipe(args)
  local index = args.index
  local recipe = self.recipes[index]
  local recipe_name = args.recipe_name
  if recipe then
    recipe:set_recipe(recipe_name)
  elseif recipe_name then
    local recipe = Recipe.new(recipe_name)
    local category = game.recipe_prototypes[recipe_name].category
    recipe.crafting_machine = self.planner.default_crafting_machines[category]
    self.recipes[index] = recipe
  else
    self.recipes[index] =
      Recipe.new_virtual(args.virtual_recipe_name, args.virtual_recipe_rate)
  end
end

function ProductionLine:get_current_rates()
  local out = {}
  for _, recipe in pairs(self.recipes) do
    if not recipe.is_virtual then
      local rates = recipe:get_current_rates()
      for item, rate in pairs(rates) do
        out[item] = (out[item] or 0) + rate
      end
    end
  end
  for item, rate in pairs(out) do
    if rate == 0 then
      out[item] = nil
    end
  end
  return out
end

function ProductionLine:remove_recipe(index)
  self.recipes[index]:clear_constraints()
  table.remove(self.recipes, index)
end

function ProductionLine:reorder_recipes(from, to)
  if to < 1 then to = 1 end
  if to > #self.recipes then to = #self.recipes end
  local recipe = self.recipes[from]
  table.remove(self.recipes, from)
  table.insert(self.recipes, to, recipe)
end

function ProductionLine:add_constraint(recipe, item, amount)
  self.constraints[#self.constraints] = {
    recipe = recipe,
    item = item,
    amount = amount,
  }
end

function ProductionLine:link_recipes(r1, r2, item_name)
  self.recipes[r1]:add_constraint(self.recipes[r2], item_name)
end

function ProductionLine:recompute()
  for _, recipe in pairs(self.recipes) do
    recipe:reset()
  end
  for _, constraint in pairs(self.constraints) do
    constraint.recipe:set_rate_by_item(constraint.item, constraint.amount)
  end
end

local M = {}
local meta = { __index = ProductionLine }

function M.new(planner)
  local self = {
    planner = planner,
    crafting_machines = {},
    recipes = {},
    constraints = {},
  }
  return M.restore(self)
end

function M.restore(self)
  for _, recipe in pairs(self.recipes) do
    Recipe.restore(recipe)
  end
  return setmetatable(self, meta)
end

return M
