local inspect = require "inspect"
require "busted"
local CraftingMachine = require "CraftingMachine"

local function setup_mocks()
  _G.game = {
    entity_prototypes = {
      ["assembling-machine-3"] = {
        allowed_effects = {
          consumption = true,
          pollution = true,
          productivity = true,
          speed = true,
        },
        crafting_speed = 1.25,
      },
      ["beacon"] = {
        allowed_effects = {
          consumption = true,
          pollution = true,
          productivity = false,
          speed = true,
        },
        distribution_effectivity = 0.5,
      },
    },
    item_prototypes = {
      ["iron-plate"] = {
        limitations = nil,
      },
      ["productivity-module-3"] = {
        limitations = {
          "iron-plate",
        },
        module_effects = {
          productivity = {bonus = 0.1},
          speed = {bonus = -0.15},
        },
        type = "module",
      },
      ["speed-module-3"] = {
        limitations = {},
        module_effects = {
          speed = {bonus = 0.5},
        },
        type = "module",
      },
    },
  }
end

describe("A CraftingMachine should", function()
  before_each(function()
    setup_mocks()
  end)

  describe("know what modules it can accept", function()
    it("with no beacon", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      assert.are.same(
        {
          allowed_by_crafting_machine = {"productivity-module-3", "speed-module-3"},
        },
        uut:allowed_modules("iron-plate"))

      assert.are.same(
        {
          allowed_by_crafting_machine = {"speed-module-3"},
        },
        uut:allowed_modules("speed-module-3"))
    end)
    
    it("with a beacon", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      assert.are.same(
        {
          allowed_by_crafting_machine = {"productivity-module-3", "speed-module-3"},
          allowed_by_beacon           = {"speed-module-3"},
        },
        uut:allowed_modules("iron-plate", "beacon"))

      assert.are.same(
        {
          allowed_by_crafting_machine = {"speed-module-3"},
          allowed_by_beacon           = {"speed-module-3"},
        },
        uut:allowed_modules("speed-module-3", "beacon"))
    end)
  end)

  describe("calculate effective crafting rate", function()
    it("without modules", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      assert.are.equal(1.25, uut:effective_speed())
    end)

    it("with productivity in beacon sandwich", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("productivity-module-3", 4)
      uut:set_beacon_count("beacon", 8, "speed-module-3", 2)
      assert.are.equal(5.5 * 1.4, uut:effective_speed())
    end)

    it("with productivity and full beacons", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("productivity-module-3", 4)
      uut:set_beacon_count("beacon", 12, "speed-module-3", 2)
      assert.are.equal(8 * 1.4, uut:effective_speed())
    end)

    it("with maximum beaconed speed", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("speed-module-3", 4)
      uut:set_beacon_count("beacon", 12, "speed-module-3", 2)
      assert.are.equal(11.25, uut:effective_speed())
    end)
  end)
end)
