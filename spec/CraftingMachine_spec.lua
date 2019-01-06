local inspect = require "inspect"
require "busted"
local CraftingMachine = require "CraftingMachine"

local function setup_mocks()
  _G.game = {
    entity_prototypes = {
      ["assembling-machine-3"] = {
        crafting_speed = 1.25,
      },
      ["beacon"] = {
        distribution_effectivity = 0.5,
      },
    },
    item_prototypes = {
      ["productivity-module-3"] = {
        module_effects = {
          productivity = {bonus = 0.1},
          speed = {bonus = -0.15},
        },
      },
      ["speed-module-3"] = {
        module_effects = {
          speed = {bonus = 0.5},
        },
      },
    },
  }
end

describe("A CraftingMachine should", function()
  before_each(function()
    setup_mocks()
  end)

  describe("calculate effective crafting rate", function()
    it("without modules", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      assert.are_equal(1.25, uut:effective_speed())
    end)

    it("with productivity in beacon sandwich", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("productivity-module-3", 4)
      uut:set_beacon_count("beacon", 8, "speed-module-3", 2)
      assert.are_equal(5.5 * 1.4, uut:effective_speed())
    end)

    it("with productivity and full beacons", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("productivity-module-3", 4)
      uut:set_beacon_count("beacon", 12, "speed-module-3", 2)
      assert.are_equal(8 * 1.4, uut:effective_speed())
    end)

    it("with maximum beaconed speed", function()
      local uut = CraftingMachine.new("assembling-machine-3")
      uut:set_module_count("speed-module-3", 4)
      uut:set_beacon_count("beacon", 12, "speed-module-3", 2)
      assert.are_equal(11.25, uut:effective_speed())
    end)
  end)
end)
