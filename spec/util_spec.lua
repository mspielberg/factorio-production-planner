if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require "lldebugger".start()
end
local util = require "src.util"

describe("memoize should", function()
  local memoize = util.memoize
  describe("support functions of 1 argument", function()
    it("for an integer argument", function()
      local invocations = 0
      local f = memoize(function(x)
        invocations = invocations + 1
        return x * 2
      end)
      assert.are.equal(8, f(4))
      assert.are.equal(1, invocations)
      assert.are.equal(8, f(4))
      assert.are.equal(1, invocations)
    end)
  end)

  describe("support functions of 3 arguments", function()
    it("for an integer argument", function()
      local invocations = 0
      local f = memoize(function(x, y, z)
        invocations = invocations + 1
        return x + y + z
      end)
      assert.are.equal(6, f(1,2,3))
      assert.are.equal(1, invocations)
      assert.are.equal(6, f(1,2,3))
      assert.are.equal(1, invocations)
    end)

    it("for arguments including nil", function()
      local invocations = 0
      local f = memoize(function(x, y, z)
        invocations = invocations + 1
        return x + (y or 10) + z
      end)
      assert.are.equal(14, f(1,nil,3))
      assert.are.equal(1, invocations)
      assert.are.equal(14, f(1,nil,3))
      assert.are.equal(1, invocations)
    end)

    it("where nil is the last argument", function()
      local invocations = 0
      local f = memoize(function(x, y, z)
        invocations = invocations + 1
        return x + y + (z or 10)
      end)
      assert.are.equal(13, f(1,2,nil))
      assert.are.equal(1, invocations)
      assert.are.equal(13, f(1,2,nil))
      assert.are.equal(1, invocations)
    end)
  end)

  describe("support vararg functions", function()
    it("for integer arguments", function()
      local invocations = 0
      local f = memoize(function(...)
        invocations = invocations + 1
        local total = 0
        for i=1,select('#', ...) do
          total = total + select(i, ...)
        end
        return total
      end)
      assert.are.equal(6, f(1,2,3))
      assert.are.equal(1, invocations)
      assert.are.equal(6, f(1,2,3))
      assert.are.equal(1, invocations)
    end)

    it("when argument lists are proper prefixes of each other", function()
      local invocations = 0
      local f = memoize(function(...)
        invocations = invocations + 1
        local total = 0
        for i=1,select('#', ...) do
          total = total + (select(i, ...) or 0)
        end
        return total
      end)
      assert.are.equal(6, f(1,2,3))
      assert.are.equal(1, invocations)
      assert.are.equal(3, f(1,2))
      assert.are.equal(2, invocations)
      assert.are.equal(3, f(1,2,nil))
      assert.are.equal(3, invocations)
    end)
  end)
end)