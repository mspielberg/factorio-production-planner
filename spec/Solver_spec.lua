require 'busted.runner'()
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
if not serpent then serpent = require "serpent" end
local Line = require "src.calc.Line"
local _ = require "src.calc.RecipeStep"
local Solver = require "src.calc.SimplexSolver"
local _ = require "spec.StubAPIAdapter"
local test_lines = require "spec.test-lines"

local function round(n, p)
  return math.floor(n*10^p+0.5) / 10^p
end

local function dump_model(model)
  local components = model.descriptions
  local rows = {}
  for i, row in ipairs(model.coefficients) do
    local row_info = {("%6s"):format(tostring(model.constants[i]))}
    for j, term in ipairs(row) do
      row_info[#row_info+1] = ("%8s x%-2d"):format(tostring(term), model.nonbasic_vars[j])
    end
    local terms = table.concat(row_info, " + ")
    rows[#rows+1] = ("%-40s: %3s = %-90s"):format(
      components[i] or "Objective",
      tostring(model.basic_vars[i] and "x"..model.basic_vars[i] or ""),
      terms
    )
  end
  return table.concat(rows, "\n")
end

local function dump_costs(model)
  local out = {}
  for i=1, #model.costs do
    out[#out+1] = model.descriptions[i].."\t"..model.costs[i]
  end
  return table.concat(out, "\n")
end

local function dump_result(result, model)
  local out = {}
  for i=1, #result do
    out[#out+1] = model.descriptions[i].."\t"..result[i]
  end
  return table.concat(out, "\n")
end


describe("The Solver should", function()
  it("handle simple green circuits", function()
    local line = Line.restore(test_lines.green_circuits)
    table.remove(line.steps, 1)
    line.constraints = { ["item/electronic-circuit"] = 5 }
    local result = Solver.solve(line)
    assert.are.same(5, result[1])
    assert.are.same(7.5, result[2])
  end)

  it("handle the Seablock geode loop", function()
    local line = Line.restore(test_lines.geode_loop.full)
    line.constraints = {["fluid/mineral-sludge"] = 100}
    local result, model = Solver.solve(line)
    local expected = {
      ["solid-geodes"] = 7.089,
      ["geode-blue-liquify"] = 0.573,
      ["geode-cyan-liquify"] = 0.851,
      ["geode-red-liquify"] = 0,
      ["crystal-slurry-filtering-conversion-1"] = 2.0,
      ["geode-blue-processing"] = 3.883,
      ["geode-cyan-processing"] = 0,
      ["geode-red-processing"] = 5.317,
      ["water-mineralized"] = 1.84,
      ["crystal-dust-liquify"] = 0.92,
      ["yellow-waste-water-purification"] = 0.8,
    }
    for i=1,#result do
      if expected[model.descriptions[i]] then
        assert.are.same(expected[model.descriptions[i]], round(result[i], 3))
      end
    end
  end)

  it("handle Py slimed iron smelting", function()
    local line = Line.restore(test_lines.py_slimed_iron)
    line.constraints = {["item/iron-plate"] = 15}
    local result, model = Solver.solve(line)
    local expected = {
      ["hotair-iron-plate-1"] = 0.2,
      ["molten-iron-06"] = 0.5,
      ["unslimed-iron"] = 0.375,
      ["unslimed-iron-2"] = 0.125,
      ["classify-iron-ore-dust"] = 0.75,
      ["iron-ore-dust"] = 2.25,
      ["grade-2-crush"] = 1.125,
      ["grade-3-iron-processing"] = 0.563,
      ["grade-2-iron"] = 1.125,
    }
    for i=1,#result do
      if expected[model.descriptions[i]] then
        assert.are.same(expected[model.descriptions[i]], round(result[i], 3))
      end
    end
  end)

  describe("Optimize Angel's Refining", function()
    it("handle Py slimed iron smelting", function()
      local line = Line.restore(test_lines.angels_refining)
      line.constraints = {
        ["item/iron-ore"] = 15,
        ["item/copper-ore"] = 15,
        ["item/tin-ore"] = 15,
        ["item/nickel-ore"] = 15,
        ["item/quartz"] = 15,
        ["item/gold-ore"] = 15,
        ["item/silver-ore"] = 15,
        --[[
        ["item/cobalt-ore"] = 0,
        ["item/rutile-ore"] = 0,
        ["item/bauxite-ore"] = 0,
        ["item/zinc-ore"] = 0,
        ["item/fluorite-ore"] = 0,
        ["item/tungsten-ore"] = 0,
        ["item/platinum-ore"] = 0,
        ["item/uranium-ore"] = 0,
        ["item/thorium-ore"] = 0,
        --]]
      }
      local cost_overrides = {
        ["item/angels-ore1"] = -0,
        ["item/angels-ore2"] = -0,
        ["item/angels-ore3"] = -0,
        ["item/angels-ore4"] = -0,
        ["item/angels-ore5"] = -0,
        ["item/angels-ore6"] = -0,
      }
      local result, model = Solver.solve(line, cost_overrides)
      print(dump_costs(model))
      print(dump_result(result, model))
      local expected = {
      }
      for i=1,#result do
        if expected[model.descriptions[i]] then
          assert.are.same(expected[model.descriptions[i]], round(result[i], 3))
        end
      end
    end)
  end)
end)

