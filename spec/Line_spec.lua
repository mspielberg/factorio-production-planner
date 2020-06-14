require "lldebugger".start()
local Component = require "src.calc.Component"
local FAPI = require "src.api.FAPI"
local FixedStep = require "src.calc.FixedStep"
local RecipeStep = require "src.calc.RecipeStep"
local Line = require "src.calc.Line"
local Planner = require "src.calc.Planner"
local data = require "spec.data"
local serpent = require "serpent"

FAPI.activate_debug_api()

describe("A Planner should", function()
  it("add a line", function()
    local planner = Planner.new()
    local line = Line.new(planner)
    assert.is_not_nil(line)
  end)
end)

describe("A Line should", function()
  it("add steps", function()
    local line = Line.new()
    local ecComponent = Component.new("item", "electronic-circuit")
    local step1 = FixedStep.new(ecComponent, -5)
    line:add_step(step1)
    local step2 = RecipeStep.new("electronic-circuit")
    line:add_step(step2)
    step2:add_constraint(step1.id, ecComponent)
    local step3 = RecipeStep.new("copper-cable")
    line:add_step(step3)
    step3:add_constraint(step2.id, Component.new("item", "copper-cable"))
    assert.are.same(
      line:get_scaled_flow_set(),
      {
        ["item/copper-plate"] = -7.5,
        ["item/iron-plate"] = -5,
        ["item/electronic-circuit"] = 5,
      }
    )
  end)

  it("be deserializable", function()
    local line = Line.restore{
      steps = {
        {
          id = 1,
          type = "fixed",
          flow_set = { ["item/electronic-circuit"] = -5 },
        },
        {
          id = 2,
          recipe = "electronic-circuit",
          constraints = {
            ["item/electronic-circuit"] = { 1 },
          }
        },
        {
          id = 3,
          recipe = "copper-cable",
          constraints = {
            ["item/copper-cable"] = { 2 },
          }
        },
      }
    }
    assert.are.same(
      line:get_scaled_flow_set(),
      {
        ["item/copper-plate"] = -7.5,
        ["item/iron-plate"] = -5,
        ["item/electronic-circuit"] = 5,
      }
    )
  end)

  it("be drivable from supply side", function()
    local line = Line.restore(data.petro_gas_line)
    assert.are.same(
      line:get_scaled_flow_set(),
      {
        ["fluid/crude-oil"] = -100.0,
        ["fluid/petroleum-gas"] = 97.5,
        ["fluid/water"] = -132.5,
      }
    )
  end)
end)

describe("Multiple lines should", function()
  describe("be able to work together", function()
    it("when driven from demand", function()
      local planner = Planner.new()
      planner:add_line(Line.restore(data.petro_gas_line))
      local plastic_line = Line.restore(data.plastic_line_demand_driven)
      planner:add_line(plastic_line)
      assert.are.same(
        plastic_line:get_scaled_flow_set(),
        {
          ["fluid/crude-oil"] = -153.84615384615,
          ["fluid/water"] = -203.84615384615,
          ["item/coal"] = -7.5,
          ["item/plastic-bar"] = 15.0
        }
      )
    end)

    it("when driven from supply", function()
      local planner = Planner.new()
      planner:add_line(Line.restore(data.petro_gas_line))
      local plastic_line = Line.restore(data.plastic_line_supply_driven)
      planner:add_line(plastic_line)
      assert.are.same(
        plastic_line:get_scaled_flow_set(),
        {
          ["fluid/crude-oil"] = -100.0,
          ["fluid/water"] = -132.5,
          ["item/coal"] = -4.875,
          ["item/plastic-bar"] = 9.75
        }
      )
    end)
  end)
end)