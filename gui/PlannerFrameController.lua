local Planner = require "Planner"
local PlannerFrame = require "gui.PlannerFrame"
local RecipeFlowController = require "gui.RecipeFlowController"

local PlannerFrameController = {}

function PlannerFrameController:toggle_show_hide()
  local style = self.view.gui.style
  style.visible = not style.visible
end

function PlannerFrameController:get_recipes_table()
  return self.view:get_recipes_table()
end

function PlannerFrameController:set_recipes(recipes)
  for i, recipe_controller in ipairs(self.recipe_controllers) do
    recipe_controller.destroy()
    self.recipe_controllers[i] = nil
  end
  for i, recipe in ipairs(recipes) do
    self.recipe_controllers[i] = RecipeController.new(self, i, recipe)
  end
end

function PlannerFrameController:on_add_recipe_button()
  local index = #self.recipe_controllers + 1
  self.recipe_controllers[index] =
    RecipeFlowController.new(self, nil)
end

function PlannerFrameController:on_recipe_changed(old_recipe, recipe)
  self.planner:change_recipe(old_recipe, recipe)
end

local M = {}
local meta = { __index = PlannerFrameController }

function M.new(view)
  local self = {
    planner = Planner.new(),
    view = view,
    recipe_controllers = {},
  }
  view:set_controller(self)
  return M.restore(self)
end

function M.restore(self)
  setmetatable(self, meta)
  PlannerFrame.restore(self.view)
  Planner.restore(self.planner)
  for _, recipe_controller in pairs(self.recipe_controllers) do
    RecipeController.restore(recipe_controller)
  end
  return self
end

return M
