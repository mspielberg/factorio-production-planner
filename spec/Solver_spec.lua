if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
if not serpent then serpent = require "serpent" end
local Line = require "calc.Line"
local MySimplex = require "calc.MySimplex"
local Rational = require "calc.Rational"
local RecipeStep = require "calc.RecipeStep"
local Solver = require "calc.SimplexSolver"
local StubAPIAdapter = require "spec.StubAPIAdapter"
local test_lines = require "spec.test-lines"

local function round(n, p)
  return math.floor(n*p+0.5) / p
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
    local model = Solver.model_from_line(line)
    print(dump_model(model))
    model.trace = true
    local result = MySimplex.solve(model)
    print(serpent.line(result))
    for i=1,#model.descriptions do
      print(model.descriptions[i], result[i])
    end
  end)
end)