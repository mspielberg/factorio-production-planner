local CraftingMachine = require "CraftingMachine"
local Recipe = require "Recipe"
local RecipeFlow = require "gui.RecipeFlow"

local IDLE = 0
local LINKING = 1

local RecipeController = {}

function RecipeController:on_recipe_button_changed()
  local old_recipe = self.recipe
  local new_recipe_name = self.view.recipe_button.elem_value

  local recipe = Recipe.new(new_recipe_name)
  self.recipe = recipe
  recipe:set_recipe_rate(10)
  self.view:set_recipe(recipe)

  local crafting_machine = CraftingMachine.default_for(recipe)
  self.crafting_machine = crafting_machine
  self.view:set_crafting_machine(crafting_machine)

  self.planner_controller:on_recipe_changed(old_recipe, recipe)
end

function RecipeController:on_item_button(item_name)
  if self.state == IDLE then
    self.planner_controller:setup_linking(self, item_name)
  elseif self.state == LINKING then
    self.planner_controller:complete_linking(self)
  end
end

function RecipeController:destroy()
  self.view:destroy()
end

local M = {}
local meta = { __index = RecipeController }

function M.new(planner_controller, view, recipe)
  local self = {
    planner_controller = planner_controller,
    view = view,
    recipe = recipe,
    crafting_machine = nil,
    state = IDLE,
  }
  self.view:set_recipe(recipe)
  return M.restore(self)
end

function M.restore(self)
  RecipeView.restore(self.view)
  return setmetatable(self, meta)
end

return M
