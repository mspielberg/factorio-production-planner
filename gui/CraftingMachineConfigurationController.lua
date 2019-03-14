local M = {}
local meta = { __index = M }

function M:on_gui_selection_state_changed(event)
  local element = event.element
  if element == self.view.crafting_machine_dropdown then
    self.
end

function M:hide()
  self.view.gui.style.hidden = true
end

function M:set_recipe(recipe)
  self.recipe = recipe
  self.crafting_machine = recipe.crafting_machine
  self.view:set_crafting_machine(recipe.crafting_machine)
end

function M:show()
  self.view.gui.style.hidden = false
end

local function restore(self)
  return setmetatable(self, meta)
end

local function new(view)
  local self = {
    view = view,

    crafting_machine = nil,
    recipe = nil,
  }
  Dispatcher.register(self, self.view.gui)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
