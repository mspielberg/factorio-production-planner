local CraftingMachine = require "CraftingMachine"

local function create(self, parent)
  local flow = parent.add{
    name = "configuration",
    type = "flow",
    direction = "horizontal",
  }
  self.gui = flow

  self.crafting_machine_dropdown = flow.add{
    name = "crafting_machine_dropdown",
    type = "drop-down",
  }
  self.module_count_dropdown = flow.add{
    name = "module_count_dropdown",
    type = "drop-down",
  }
  self.module_dropdown = flow.add{
    name = "module_dropdown",
    type = "drop-down",
  }
  self.beacon_count_dropdown = flow.add{
    name = "beacon_count_dropdown",
    type = "drop-down",
  }
  self.beacon_dropdown = flow.add{
    name = "beacon_dropdown",
    type = "drop-down",
  }
  self.beacon_module_count_dropdown = flow.add{
    name = "beacon_module_count_dropdown",
    type = "drop-down",
  }
  self.beacon_module_dropdown = flow.add{
    name = "beacon_module_dropdown",
    type = "drop-down",
  }
end

local function update_crafting_machine_dropdown(self)
  local names = CraftingMachine.entity_names_for_category(self.crafting_machine.category)
  table.sort(names)
  self.crafting_machine_dropdown.clear_items()
  for _, name in ipairs(names) do
    self.crafting_machine_dropdown.add_item(game.entity_prototypes[name].localised_name)
  end
end

local function update_module_count_dropdown(self)
  local max_module_slots = self.crafting_machine.module_inventory_size or 0
  local dropdown = self.module_count_dropdown
  for i=max_module_slots+1,#dropdown.items do
    dropdown.remove_item(max_module_slots+1)
  end
  for i=#dropdown.items,max_module_slots do
    dropdown.add_item(tostring(i))
  end
end

local M = {}
local meta = { __index = M }

function M:set_crafting_machine(crafting_machine)
  log(serpent.block(crafting_machine))
  self.crafting_machine = crafting_machine
  self:update()
end

function M:update()
  update_crafting_machine_dropdown(self)
  update_module_count_dropdown(self)
end

local function restore(self)
  return setmetatable(self, meta)
end

local function new(parent)
  local self = {
    gui = nil,
    crafting_machine_dropdown = nil,
    module_count_dropdown = nil,
    module_dropdown = nil,
    beacon_count_dropdown = nil,
    beacon_dropdown = nil,
    beacon_module_count_dropdown = nil,
    beacon_module_dropdown = nil,

    crafting_machine = nil,
  }
  create(self, parent)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
