if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
if not serpent then serpent = require "serpent" end
local Line = require "calc.Line"
local RecipeStep = require "calc.RecipeStep"
local Solver = require "calc.SimplexSolver"
local StubAPIAdapter = require "spec.StubAPIAdapter"
local test_lines = require "spec.test-lines"

local function round(n, p)
  return math.floor(n*p+0.5) / p
end

local function dump_rational(r)
  if r[2] == 1 then
    return tostring(r[1])
  end
  return ("%d/%d"):format(r[1], r[2])
end

local function dump_model(model)
  local components = model.components
  model = model.simplex
  local rows = {}
  for i, row in ipairs(model.coefficients) do
    local row_info = {("%3s"):format(dump_rational(model.constants[i]))}
    for j, term in ipairs(row) do
      row_info[#row_info+1] = ("%8s x%-2d"):format(dump_rational(term), model.nonbasic_vars[j])
    end
    local terms = table.concat(row_info, " + ")
    rows[#rows+1] = ("%-40s: x%d = %-90s"):format(
      components[i],
      model.basic_vars[i] or 0,
      terms
    )
  end
  rows[#rows+1] = serpent.line(model.c)
  return table.concat(rows, "\n")
end

describe("The Solver should", function()
  it("handle simple green circuits", function()
    local line = Line.restore(test_lines.green_circuits)
    table.remove(line.steps, 1)
    line.constraints = { ["item/electronic-circuit"] = 5 }
    local model = Solver.model_from_line(line)
    print(dump_model(model))
    print(serpent.block(Solver.solve(line)))
  end)
  --[[
  it("handle the Seablock geode loop", function()
    local line = Line.restore(test_lines.geode_loop.full)
    line.constraints = {["fluid/mineral-sludge"] = 100}
    local result, model = Solver.solve(line)
    print(dump_model(model))
    for i=1,#line.steps do
      print(
        line.steps[i].recipe,
        round(result[i], 10000))
    end
    local components = model.components
    for component, info in pairs(components) do
      if info.input_flow then
        --print(serpent.block(info))
        print(
          component,
          round(result[info.input_flow], 10000),
          round(result[info.output_flow], 10000)
        )
      end
    end
  end)
  --]]
end)