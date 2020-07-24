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
  ["solid-geodes"]={
    ingredients={
      { amount=40, name="water-heavy-mud", type="fluid" },
      { amount=25, name="water", type="fluid" }
    },
    products={
      { amount=2, name="geode-blue", probability=0.75, type="item" },
      { amount=1, name="geode-cyan", probability=0.6, type="item" },
      { amount=1, name="geode-lightgreen", probability=0.6, type="item" },
      { amount=1, name="geode-purple", probability=0.75, type="item" },
      { amount=2, name="geode-red", probability=0.75, type="item" },
      { amount=1, name="geode-yellow", probability=1, type="item" }
    }
  },
  ["geode-blue-liquify"]={
    ingredients={
      { amount=5, name="geode-blue", type="item" },
      { amount=15, name="sulfuric-acid", type="fluid" }
    },
    products={ { amount=20, name="crystal-slurry", type="fluid" } },
  },
  ["geode-cyan-liquify"]={
    ingredients={
      { amount=5, name="geode-cyan", type="item" },
      { amount=15, name="sulfuric-acid", type="fluid" }
    },
    products={ { amount=50, name="crystal-slurry", type="fluid" } }
  },
  ["geode-red-liquify"]={
    ingredients={
      { amount=5, name="geode-red", type="item" },
      { amount=15, name="sulfuric-acid", type="fluid" }
    },
    products={ { amount=20, name="crystal-slurry", type="fluid" } }
  },
  ["crystal-slurry-filtering-conversion-1"]={
    ingredients={
      { amount=50, name="crystal-slurry", type="fluid" },
      { amount=100, name="water-mineralized", type="fluid" },
      { amount=1, name="filter-coal", type="item" }
    },
    products={
      { amount=50, name="mineral-sludge", type="fluid" },
      { amount=40, name="water-yellow-waste", type="fluid" },
      { amount=1, name="filter-frame", type="item" }
    }
  },
  ["geode-blue-processing"]={
    ingredients={
      { amount=2, name="geode-blue", type="item" } },
    products={
      { amount=1, name="crystal-dust", type="item" },
      { amount=2, name="stone-crushed", type="item" }
    }
  },
  ["geode-cyan-processing"]={
    ingredients={ { amount=2, name="geode-cyan", type="item" } },
    products={
      { amount=3, name="crystal-dust", type="item" },
      { amount=2, name="stone-crushed", type="item" }
    }
  },
  ["geode-red-processing"]={
    ingredients={ { amount=2, name="geode-red", type="item" } },
    products={
      { amount=1, name="crystal-dust", type="item" },
      { amount=2, name="stone-crushed", type="item" }
    }
  },
  ["water-mineralized"]={
    ingredients={
      { amount=100, name="water", type="fluid" },
      { amount=10, name="stone-crushed", type="item" }
    },
    products={ { amount=100, name="water-mineralized", type="fluid" } }
  },
  ["crystal-dust-liquify"]={
    ingredients={
      { amount=10, name="crystal-dust", type="item" },
      { amount=15, name="sulfuric-acid", type="fluid" }
    },
    products={ { amount=50, name="crystal-slurry", type="fluid" } }
  },
  ["hotair-iron-plate-1"] = {
    ingredients = {
      { amount = 100, name = "molten-iron", type = "fluid" },
      { amount = 3, name = "borax", type = "item" },
      { amount = 1, name = "sand-casting", type = "item" },
      { amount = 50, name = "hot-air", type = "fluid" }
    },
    products = {
      { amount = 75, name = "iron-plate", type = "item" }
    }
  },
  ["molten-iron-06"] = {
    ingredients = {
      { amount = 1, name = "unslimed-iron", type = "item" },
      { amount = 3, name = "borax", type = "item" },
      { amount = 60, name = "oxygen", type = "fluid" }
    },
    products = {
      { amount = 40, name = "molten-iron", type = "fluid" }
    }
  },
  ["unslimed-iron"] = {
    ingredients = {
      { amount = 100, name = "iron-slime", type = "fluid" },
      { amount = 200, name = "water", type = "fluid" }
    },
    products = {
      { amount = 100, name = "dirty-water", type = "fluid" },
      { amount = 1, name = "unslimed-iron", type = "item" }
    }
  },
  ["unslimed-iron-2"] = {
    ingredients = {
      { amount = 300, name = "iron-pulp-01", type = "fluid" },
      { amount = 200, name = "water", type = "fluid" }
    },
    products = {
      { amount = 100, name = "dirty-water", type = "fluid" },
      { amount = 1, name = "unslimed-iron", type = "item" }
    }
  },
  ["classify-iron-ore-dust"] = {
    ingredients = {
      { amount = 3, name = "iron-ore-dust", type = "item" },
      { amount = 300, name = "water", type = "fluid" }
    },
    products = {
      { amount = 50, name = "iron-pulp-01", type = "fluid" },
      { amount = 50, name = "iron-slime", type = "fluid" }
    }
  },
  ["iron-ore-dust"] = {
    ingredients = { { amount = 1, name = "grade-1-iron", type = "item" } },
    products = { { amount = 1, name = "iron-ore-dust", type = "item" } }
  },
  ["grade-2-crush"] = {
    ingredients = { { amount = 1, name = "grade-2-iron", type = "item" } },
    products = {
      { amount = 1, name = "gravel", probability = 0.5, type = "item" },
      { amount = 1, name = "grade-1-iron", type = "item" }
    }
  },
  ["grade-3-iron-processing"] = {
    ingredients = { { amount = 1, name = "grade-3-iron", type = "item" } },
    products = { { amount = 1, name = "grade-2-iron", type = "item" } }
  },
  ["grade-2-iron"] = {
    ingredients = { { amount = 5, name = "processed-iron-ore", type = "item" } },
    products = {
      { amount = 1, name = "grade-1-iron", type = "item" },
      { amount = 1, name = "grade-2-iron", probability = 0.5, type = "item" },
      { amount = 1, name = "grade-3-iron", probability = 0.5, type = "item" }
    }
  },
}

local StubAPIAdapter = {}

function StubAPIAdapter.get_recipe_prototype(recipe_name)
  return stub_recipes[recipe_name]
end

local FAPI = require "src.api.FAPI"
getmetatable(FAPI).__index = StubAPIAdapter

return StubAPIAdapter