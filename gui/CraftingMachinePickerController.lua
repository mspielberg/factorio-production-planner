local CraftingMachine = require "CraftingMachine"
local CraftingMachineConfigurationController =
  require "gui.CraftingMachineConfigurationController"
local Dispatcher = require "gui/Dispatcher"

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

function M:set_recipe(recipe)
  self.config_flow_controller:set_recipe(recipe)
end

local function restore(self)
  return setmetatable(self, meta)
end

local function new(view)
  local self = {
    view = view,

    crafting_machine = nil,

    config_flow_controller =
      CraftingMachineConfigurationController.new(view.config_flow),
  }
  Dispatcher.register(self, self.view.gui)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
