return
{
  recipe = {
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
  }
}