local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local Planner = require "Planner"
local PlannerFrame = require "gui.PlannerFrame"
local Recipe = require "Recipe"
local RecipeFlowController = require "gui.RecipeFlowController"

local function on_remove_recipe_button(self, recipe_index)
  self.planner:remove_recipe(recipe_index)

  local recipe_controllers = self.recipe_controllers
  recipe_controllers[recipe_index]:destroy()

  local num_controllers = #recipe_controllers
  for i=num_controllers-1, recipe_index, -1 do
    recipe_controllers[i] = recipe_controllers[i+1]
    recipe_controllers[i]:set_index(i)
  end
  recipe_controllers[num_controllers] = nil
end

local PlannerFrameController = {}

function PlannerFrameController:on_gui_click(event)
  local element = event.element
  if element.name == "remove_recipe_button" then
    on_remove_recipe_button(self, event.context.recipe_index)
    return true
  end
end

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

function PlannerFrameController:add_recipe(recipe_name)
  local recipe = Recipe.new(recipe_name)
  self.planner:change_recipe(nil, recipe)
  log(inspect(self.planner))

  local recipe_flow = self.view:add_recipe()
  local index = #self.recipe_controllers + 1
  local recipe_controller = RecipeFlowController.new(recipe_flow, index)
  recipe_controller:set_production_line(self.planner.current_line, index)
  self.recipe_controllers[index] = recipe_controller
end

function PlannerFrameController:change_recipe(index, recipe_name)
  local recipe = Recipe.new(recipe_name)
  self.planner:change_recipe(index, recipe)
  self.recipe_controllers[index]:update()
end

local M = {}
local meta = { __index = PlannerFrameController }

function M.new(view, recipe_picker)
  local self = {
    planner = Planner.new(),
    view = view,

    recipe_picker = recipe_picker,
    recipe_controllers = {},
  }
  return M.restore(self)
end

function M.restore(self)
  PlannerFrame.restore(self.view)
  Planner.restore(self.planner)
  for _, recipe_controller in pairs(self.recipe_controllers) do
    RecipeFlowController.restore(recipe_controller)
  end
  Dispatcher.register(self, self.view.gui)
  return setmetatable(self, meta)
end

return M
