if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
local Rational = require "src.calc.Rational"
if not serpent then serpent = require "serpent" end

describe("A Rational should", function()
  it("be constructable", function()
    local r = Rational(1, 4)
    assert.are.same({1, 4}, r)
  end)

  it("be addable", function()
    local r = Rational(1, 3) + Rational(1, 2)
    assert.are.same({5, 6}, r)
  end)

  it("be subtractable", function()
    assert.are.same({1, 6}, Rational(1, 2) - Rational(1, 3))
  end)

  it("be dividable", function()
    assert.are.same({6, 1}, Rational(3, 1) / Rational(1, 2))
  end)

  it("reduce itself automatically", function()
    local r = Rational(12, 3)
    assert.are.same({4, 1}, r)
  end)

  it("convert from decimal", function()
    assert.are.same({1, 10}, Rational(0.1))
    assert.are.same({3, 2}, Rational(1.5))
    assert.are.same({3, 4}, Rational(1.5, 2))
    assert.are.same({400, 1}, Rational(100, 0.25))
  end)

  it("compare for equality", function()
    assert.are.same(Rational(0.1), Rational(1, 10))
    assert.are.same(Rational(0.1), 0.1)
  end)

  it("compare for ordering", function()
    assert.is.True(Rational(0.1) < Rational(1, 2))
    assert.is.True(Rational(2) > Rational(3, 4))
  end)
end)