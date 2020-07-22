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

local function dump_model(model)
  local rows = {}
  for row=1, #model.row_starts-1 do
    local row_info = {}
    for term=model.row_starts[row], model.row_starts[row+1]-1 do
      row_info[#row_info+1] = ("%8.2f x%-2d"):format(model.elements[term], model.indexes[term])
    end
    local terms = table.concat(row_info, " + ")
    rows[#rows+1] = ("%-40s: %-90s = %d"):format(
      model.row_components[row],
      terms,
      model.b[row]
    )
  end
  rows[#rows+1] = serpent.line(model.c)
  return table.concat(rows, "\n")
end

describe("The Solver should", function()
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
end)