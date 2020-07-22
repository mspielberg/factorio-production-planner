if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
local MySimplex = require "src.calc.MySimplex"
local Rational = require "src.calc.Rational"
if not serpent then serpent = require "serpent" end

describe("MySimplex should", function()
  local function init()
    return MySimplex.new(
      {1, 2, -1},
      {
        {2,1,1},
        {4,2,3},
        {2,5,5},
      },
      {14,28,30}
    )
  end

  it("initialize properly", function()
    local s = init()
    assert.are.same({1,2,3}, s.nonbasic_vars)
    assert.are.same({4,5,6}, s.basic_vars)
    assert.are.same(
      Rational{
        {-2,-1,-1},
        {-4,-2,-3},
        {-2,-5,-5},
        {1,2,-1},
      },
      s.coefficients
    )
    assert.are.same(Rational{14, 28, 30, 0}, s.constants)
  end)

  it("select entering variable correctly", function()
    local s = init()
    assert.are.same(2, MySimplex.select_entering_variable(s))
  end)

  it("select exiting variable correctly", function()
    local s = init()
    assert.are.same(3, MySimplex.select_exiting_variable(s, 2))
  end)

  it("pivot", function()
    local s = init()
    MySimplex.pivot(s, 2, 3)
    assert.are.same({4,5,2}, s.basic_vars)
    assert.are.same({1,6,3}, s.nonbasic_vars)
    assert.are.same(Rational{8,16,6,12}, s.constants)
  end)

  it("solve the super simple case", function()
    local s = init()
    local solution, objective = MySimplex.solve(s)
    assert.are.same(Rational(13), objective)
    assert.are.same(Rational{5,4,0,0,0,0}, solution)
  end)

  it("presolve infeasible starting states", function()
    local s = MySimplex.new(
      {1,-1,1},
      {
        {2,-1,2},
        {2,-3,1},
        {-1,1,-2},
      },
      {4,-5,-1}
    )
    local result, obj = MySimplex.solve(s)
    assert.are.same(Rational(3, 5), obj)
    assert.are.same(Rational{0, Rational(14,5), Rational(17,5), 0, 0, 3}, result)
  end)

  it("discover truly infeasible LPs", function()
    local s = MySimplex.new(
      {1,-1,1},
      {
        {2,-1,2},
        {2,-3,1},
        {-1,1,1},
      },
      {4,-5,-1}
    )
    local status, err = pcall(MySimplex.solve, s)
    assert.is.False(status)
    assert.is.truthy(err:find("infeasible"))
  end)

  it("handle degenerate pivots", function()
    local s = MySimplex.new(
      {2,2,1},
      {
        {2,0,1},
        {1,1,0},
        {1,0,1},
      },
      {4,1,1}
    )
    local result, obj = MySimplex.solve(s)
    assert.are.same(Rational{0,1,1,3,0,0}, result)
    assert.are.same(Rational(3), obj)
  end)

  it("handle cycling", function()
    local s = MySimplex.new(
      {10,-57,-9,-24},
      {
        {1/2,-11/2,-5/2,9},
        {1/2,-3/2,-1/2,1},
        {1,0,0,0},
      },
      {0,0,1}
    )
    assert.has_no.errors(function() MySimplex.solve(s) end)
  end)
end)