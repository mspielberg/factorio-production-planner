local inspect = require "inspect"
require "busted"
local Recipe = require "Recipe"
local VirtualRecipe = require "VirtualRecipe"

local function setup_mocks()
  _G.game = {
    recipe_prototypes = {
      ["electronic-circuit"] = {
        energy = 0.5,
        ingredients = {{name = "iron-plate", amount = 1}, {name = "copper-cable", amount = 3}},
        products = {{name = "electronic-circuit", amount = 1}},
      },
      ["iron-gear-wheel"] = {
        energy = 0.5,
        ingredients = {{name = "iron-plate", amount = 2}},
        products = {{name = "iron-gear-wheel", amount = 1}},
      },
      ["iron-plate"] = {
        energy = 3.5,
        ingredients = {{name = "iron-ore", amount = 1}},
        products = {{name = "iron-plate", amount = 1}},
      },
      ["science-pack-1"] = {
        energy = 5,
        ingredients = {
          {name = "copper-plate", amount = 1},
          {name = "iron-gear-wheel", amount = 1}
        },
        products = {{name = "science-pack-1", amount = 1}},
      },
    },
  }
end

describe("A Recipe should", function()
  local plate_recipe, gear_recipe, sp1_recipe

  before_each(function()
    setup_mocks()
    plate_recipe = Recipe.new("iron-plate")
    gear_recipe = Recipe.new("iron-gear-wheel")
    plate_recipe:add_constraint(gear_recipe, "iron-plate")
    sp1_recipe = Recipe.new("science-pack-1")
    gear_recipe:add_constraint(sp1_recipe, "iron-gear-wheel")
  end)

  describe("adjust rates of constrained recipes", function()
    it("that are direct descendents", function()
      local constraint = VirtualRecipe.new("iron-gear-wheel", -1)
      gear_recipe:add_constraint(constraint, "iron-gear-wheel")
      assert.is_equal(2, plate_recipe.rate) 
    end)
    it("that are indirect descendents", function()
      local constraint = VirtualRecipe.new("science-pack-1", -1)
      sp1_recipe:add_constraint(constraint, "science-pack-1")
      assert.is_equal(2, plate_recipe.rate) 
    end)

    it("after removing a constraint", function()
      local constraint = VirtualRecipe.new("science-pack-1", -1)
      sp1_recipe:add_constraint(constraint, "science-pack-1")
      sp1_recipe:remove_constraint(constraint, "science-pack-1")
      assert.is_equal(0, plate_recipe.rate) 
    end)
  end)

  describe("detect transitive constraints", function()
    it("that are direct", function()
      assert.is_true(gear_recipe:is_constrained_by(sp1_recipe))
    end)

    it("that are transitive", function()
      assert.is_true(plate_recipe:is_constrained_by(sp1_recipe))
    end)
  end)

  describe("allow changing its recipe", function()
    it("preserves matching constraints", function()
      local constraint = VirtualRecipe.new("science-pack-1", -1)
      sp1_recipe:add_constraint(constraint, "science-pack-1")
      gear_recipe:set_recipe("electronic-circuit")
      assert.is_true(plate_recipe:is_constrained_by(gear_recipe))
      assert.is_equal(0, plate_recipe.rate)
    end)

    it("drops broken constraints", function()
      local constraint = VirtualRecipe.new("science-pack-1", -1)
      sp1_recipe:add_constraint(constraint, "science-pack-1")
      assert.is_true(plate_recipe:is_constrained_by(gear_recipe))
      gear_recipe:set_recipe("electronic-circuit")
      assert.is_false(plate_recipe:is_constrained_by(sp1_recipe))
      assert.is_equal(1, sp1_recipe.rate)
    end)
  end)
end)
