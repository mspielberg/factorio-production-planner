local CraftingMachine = require "CraftingMachine"
local Dispatcher = require "gui/Dispatcher"
local inspect = require "inspect"

local M = {}
local meta = { __index = M }

function M:on_gui_click(event)
  local element = event.element
  if element.name == "add_crafting_machine_button" then
    self.view:add_crafting_machine_to_library(category)
  end
end

function M:set_category(category)
  self.crafting_machine = CraftingMachine
end

local function restore(self)
  return setmetatable(self, meta)
end

local function new(view)
  local self = {
    view = view,

    crafting_machine = nil,
  }
  Dispatcher.register(self, self.view.gui)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
