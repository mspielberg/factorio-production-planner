local M = {}
local meta = { __index = M }

local function restore(self)
  return setmetatable(self, meta)
end

local function new(view)
  local self = {
    view = view,
  }
  Dispatcher.register(self, self.view.gui)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
