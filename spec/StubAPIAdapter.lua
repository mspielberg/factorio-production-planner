local stub_recipes = {
  ["copper-cable"] = {
    ingredients = {{type = "item", name = "copper-plate", amount = 1}},
    products = {{type = "item", name = "copper-cable", amount = 2}},
  },
  ["electronic-circuit"] = {
    ingredients = {
      {type = "item", name = "iron-plate", amount = 1},
      {type = "item", name = "copper-cable", amount = 3},
    },
    products = {{type = "item", name = "electronic-circuit", amount = 1}},
  },
  ["plastic-bar"] = {
    ingredients = {
      {type = "fluid", name = "petroleum-gas", amount = 20},
      {type = "item", name = "coal", amount = 1},
    },
    products = {{type = "item", name = "plastic-bar", amount = 2}},
  },
  ["advanced-oil-processing"] = {
    ingredients = {
      {type = "fluid", name = "crude-oil", amount = 100},
      {type = "fluid", name = "water", amount = 50},
    },
    products = {
      {type = "fluid", name = "heavy-oil", amount = 25},
      {type = "fluid", name = "light-oil", amount = 45},
      {type = "fluid", name = "petroleum-gas", amount = 55},
    },
  },
  ["heavy-oil-cracking"] = {
    ingredients = {
      {type = "fluid", name = "heavy-oil", amount = 40},
      {type = "fluid", name = "water", amount = 30},
    },
    products = {
      {type = "fluid", name = "light-oil", amount = 30},
    },
  },
  ["light-oil-cracking"] = {
    ingredients = {
      {type = "fluid", name = "light-oil", amount = 30},
      {type = "fluid", name = "water", amount = 30},
    },
    products = {
      {type = "fluid", name = "petroleum-gas", amount = 20},
    },
  },

  -- Seablock
  ["slag-processing-dissolution"] = {
    ingredients = {
      { amount = 5, name = "slag", type = "item" },
      { amount = 15, name = "liquid-sulfuric-acid", type = "fluid" }
    },
    products = { { amount = 50, name = "slag-slurry", type = "fluid" } }
  },
  ["liquid-sulfuric-acid"] = {
    ingredients = {
      { amount = 90, name = "gas-sulfur-dioxide", type = "fluid" },
      { amount = 40, name = "water-purified", type = "fluid" }
    },
    products = {
      { amount = 60, name = "liquid-sulfuric-acid", type = "fluid" }
    }
  },
  ["gas-sulfur-dioxide"] = {
    ingredients = {
      { amount = 1, name = "sulfur", type = "item" },
      { amount = 60, name = "gas-oxygen", type = "fluid" }
    },
    products = { { amount = 60, name = "gas-sulfur-dioxide", type = "fluid" } }
  },
  ["yellow-waste-water-purification"] = {
    ingredients = { { amount = 100, name = "water-yellow-waste", type = "fluid" } },
    products = {
      { amount = 20, name = "water-mineralized", type = "fluid" },
      { amount = 70, name = "water-purified", type = "fluid" },
      { amount = 1, name = "sulfur", type = "item" }
    }
  },
  ["slag-processing-filtering-1"] = {
    ingredients = {
      { amount = 50, name = "slag-slurry", type = "fluid" },
      { amount = 50, name = "water-purified", type = "fluid" },
      { amount = 1, name = "filter-charcoal", type = "item" }
    },
    products = {
      { amount = 50, name = "mineral-sludge", type = "fluid" },
      { amount = 40, name = "water-yellow-waste", type = "fluid" },
      { amount = 1, name = "filter-frame", type = "item" }
    }
  },
  ["filter-coal"] = {
    ingredients = {
      { amount = 1, name = "wood-charcoal", type = "item" },
      { amount = 5, name = "filter-frame", type = "item" }
    },
    products = { { amount = 5, name = "filter-charcoal", type = "item" } }
  },
}

local StubAPIAdapter = {}

function StubAPIAdapter.get_recipe_prototype(recipe_name)
  return stub_recipes[recipe_name]
end

local FAPI = require "src.api.FAPI"
getmetatable(FAPI).__index = StubAPIAdapter

return StubAPIAdapter