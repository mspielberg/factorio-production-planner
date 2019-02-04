local CraftingMachine = require "CraftingMachine"
local CraftingMachineConfigurationFlow = require "gui.CraftingMachineConfigurationFlow"
local Recipe = require "Recipe"

local function create(self, parent)
  local frame = parent.add{
    name = "crafting_machine_picker",
    type = "frame",
    direction = "vertical",
  }
  self.gui = frame

  frame.add{
    name = "recipe_label",
    type = "label",
    caption = {"planner-gui.recipe-picker-title", self.recipe_name},
  }

  self.library_table = frame.add{
    name = "library",
    type = "table",
    column_count = 10,
    style = "slot_table",
  }
  self.add_button = self.library_table.add{
    name = "add_crafting_machine_button",
    type = "sprite-button",
    sprite = "utility/add",
    style = "slot_button",
  }

  local buttons_flow = frame.add{
    name = "buttons",
    type = "flow",
    direction = "horizontal",
  }
  local filler = buttons_flow.add{
    type = "flow",
    direction = "horizontal",
  }
  filler.style.horizontally_stretchable = true
  buttons_flow.add{
    name = "close",
    type = "button",
    caption = {"gui.close"},
  }

  self.config_flow = CraftingMachineConfigurationFlow.new(frame)
  self.config_flow:set_crafting_machine(CraftingMachine.default_for(Recipe.new("advanced-circuit")))
end

local M = {}
local meta = { __index = M }

function M:set_recipe(recipe_name)
  local proto = game.recipe_prototypes[recipe_name]
  self.category = proto.category
  self.recipe_name = recipe_name
end

local function restore(self)
  CraftingMachineConfigurationFlow.restore(self.config_flow)
  return setmetatable(self, meta)
end

local function new(parent)
  local self = {
    recipe_name = "",
    index = 0,
    category_name = nil,
    crafting_machine = nil,

    gui = nil,
    library_table = nil,
    add_button = nil,

    config_flow = nil,
  }
  create(self, parent)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
