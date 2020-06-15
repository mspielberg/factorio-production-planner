local dr = require "data-raw"
local serpent = require "serpent"

local out = {}
for name, recipe in pairs(dr.recipe) do
  out[name] = {}
  local root = recipe.normal or recipe.expensive or recipe
  out[name].ingredients = root.ingredients
  out[name].products = root.results or {{type = "item", name = root.result, count = root.result_count or 1}}
end

print(serpent.block(out, {comment=false,}))
