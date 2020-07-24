local dump_name = arg[1]
local data = require(dump_name)
local out = {}

local function extract_recipe_data(recipe)
  return recipe.normal or recipe.expensive or recipe
end

local function extract_products(recipe)
  return recipe.results or { { type = "item", name = recipe.result, amount = recipe.result_count or 1 } }
end

for name, recipe in pairs(data.recipe) do
  out[name] = {}
  out[name].category = recipe.category or "crafting"
  recipe = extract_recipe_data(recipe)
  out[name].energy_required = recipe.energy_required
  out[name].ingredients = recipe.ingredients
  out[name].products = extract_products(recipe)
  out[name].hidden = recipe.hidden
end

print(require "serpent".block(out, {comment=false}))
