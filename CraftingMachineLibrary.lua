local CraftingMachine = require "CraftingMachine"

local M = {}
local meta = { __index = M }

function M:add_crafting_machine(category)
  local crafting_machine_names =
    CraftingMachine.entity_names_for_category(category)
  local crafting_machines = self.crafting_machines[category]
  local crafting_machine
  if crafting_machines then
    crafting_machine = crafting_machines[1]:clone()
  else
    crafting_machines = {}
    self.crafting_machines[category] = crafting_machines
    crafting_machine =
      CraftingMachine.new(crafting_machine_names[1])
  end

  crafting_machines[#crafting_machines+1] = crafting_machine
  return crafting_machine
end

function M:get_default_crafting_machine(category)
  if self.crafting_machines[category] then
    return self.crafting_machines[category][1]
  end
  return self:add_crafting_machine(category)
end

function M:get_crafting_machines_for_category(category)
  return self.crafting_machines[category]
end

local function restore(self)
  return setmetatable(self, meta)
end

local function new()
  local self = {
    crafting_machines = {},
  }
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
