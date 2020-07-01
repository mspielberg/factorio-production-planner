if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
local StubAPIAdapter = require "spec.StubAPIAdapter"

local Component = require "src.calc.Component"
local FixedStep = require "src.calc.FixedStep"
local RecipeStep = require "src.calc.RecipeStep"
local Line = require "src.calc.Line"
local Planner = require "src.calc.Planner"
local test_lines = require "spec.test-lines"
local serpent = require "serpent"

local function round_off(t, places)
  local factor = 10 ^ places
  local out = {}
  for k,v in pairs(t) do
    out[k] = math.floor(v * factor + 0.5) / factor
  end
  return out
end

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
    step2:add_constraint(step1, ecComponent)
    local step3 = RecipeStep.new("copper-cable")
    line:add_step(step3)
    step3:add_constraint(step2, Component.new("item", "copper-cable"))
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
    local line = Line.restore(test_lines.petro_gas_line)
    assert.are.same(
      line:get_scaled_flow_set(),
      {
        ["fluid/crude-oil"] = -100.0,
        ["fluid/petroleum-gas"] = 97.5,
        ["fluid/water"] = -132.5,
      }
    )
  end)

  it("handle internal loops", function()
    local line = Line.restore(test_lines.seablock_mineral_sludge_line)
    assert.are.same(
      round_off(line:get_scaled_flow_set(), 2),
      {
        ["fluid/gas-oxygen"] = -33.75,
        ["fluid/mineral-sludge"] = 75.0,
        ["fluid/water-mineralized"] = 12.0,
        ["fluid/water-purified"] = -48.0,
        ["item/slag"] = -7.5,
        ["item/sulfur"] = 0.04,
        ["item/wood-charcoal"] = -0.3
      }
    )
  end)
end)

describe("Multiple lines should", function()
  describe("be able to work together", function()
    it("when driven from demand", function()
      local planner = Planner.new()
      planner:add_line(Line.restore(test_lines.petro_gas_line))
      local plastic_line = Line.restore(test_lines.plastic_line_demand_driven)
      planner:add_line(plastic_line)
      assert.are.same(
        round_off(plastic_line:get_scaled_flow_set(), 2),
        {
          ["fluid/crude-oil"] = -153.85,
          ["fluid/water"] = -203.85,
          ["item/coal"] = -7.5,
          ["item/plastic-bar"] = 15.0
        }
      )
    end)

    it("when driven from supply", function()
      local planner = Planner.new()
      planner:add_line(Line.restore(test_lines.petro_gas_line))
      local plastic_line = Line.restore(test_lines.plastic_line_supply_driven)
      planner:add_line(plastic_line)
      assert.are.same(
        round_off(plastic_line:get_scaled_flow_set(), 2),
        {
          ["fluid/crude-oil"] = -100.0,
          ["fluid/water"] = -132.5,
          ["item/coal"] = -4.87,
          ["item/plastic-bar"] = 9.75
        }
      )
    end)

    it("in multiple levels", function()
      local planner = Planner.new()
      planner:add_line(Line.restore(test_lines.geode_loop.sludge))
      planner:add_line(Line.restore(test_lines.geode_loop.blue_processing))
      planner:add_line(Line.restore(test_lines.geode_loop.cyan_processing))
      planner:add_line(Line.restore(test_lines.geode_loop.red_processing))
      planner:add_line(Line.restore(test_lines.geode_loop.blue_sludge))
      planner:add_line(Line.restore(test_lines.geode_loop.cyan_sludge))
      planner:add_line(Line.restore(test_lines.geode_loop.red_sludge))
      planner:add_line(Line.restore(test_lines.geode_loop.blue_slurry))
      planner:add_line(Line.restore(test_lines.geode_loop.cyan_slurry))
      planner:add_line(Line.restore(test_lines.geode_loop.red_slurry))
      planner:add_line(Line.restore(test_lines.geode_loop.overall))
      assert.are.same(
        {},
        planner.lines[11]:get_scaled_flow_set()
      )
    end)
  end)
end)