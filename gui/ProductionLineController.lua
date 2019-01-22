local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local Planner = require "Planner"
local ProductionLineFlow = require "gui.ProductionLineFlow"
local Recipe = require "Recipe"
local RecipeFlowController = require "gui.RecipeFlowController"

local function on_move_recipe_button(self, event)
  local recipe_index = event.context.recipe_index
  local delta
  if event.control then
    delta = math.huge
  elseif event.shift then
    delta = 5
  else
    delta = 1
  end
  if event.element.name == "move_recipe_up_button" then
    delta = -delta
  end
  self.production_line:reorder_recipes(recipe_index, recipe_index + delta)
  self:update()
end

local function on_remove_recipe_button(self, recipe_index)
  self.production_line:remove_recipe(recipe_index)

  local recipe_controllers = self.recipe_controllers
  recipe_controllers[#recipe_controllers]:destroy()
  recipe_controllers[#recipe_controllers] = nil

  local num_controllers = #recipe_controllers
  for i=recipe_index,num_controllers do
    recipe_controllers[i]:update()
  end
  self:update()
end

local ProductionLineController = {}

function ProductionLineController:set_production_line(production_line)
  local num_recipes = #production_line.recipes
  self.production_line = production_line
  self.view:set_production_line(production_line)

  local recipe_controllers = self.recipe_controllers
  for i=num_recipes+1,#recipe_controllers do
    self.recipe_controllers[i].destroy()
    self.recipe_controllers[i] = nil
  end
  for i=#recipe_controllers+1,num_recipes do
    self.recipe_controllers[i] =
      RecipeFlowController.new(self.view.recipe_flows[i], i)
  end
  for _, recipe_controller in pairs(self.recipe_controllers) do
    recipe_controller:set_production_line(production_line)
  end
end

function ProductionLineController:add_recipe(args)
  local index = #self.recipe_controllers + 1
  args.index = index
  self.production_line:change_recipe(args)

  local recipe_flow = self.view:add_recipe()
  local recipe_controller = RecipeFlowController.new(recipe_flow, index)
  recipe_controller:set_production_line(self.production_line)
  self.recipe_controllers[index] = recipe_controller
  self:update()
end

function ProductionLineController:change_recipe(index, recipe_name)
  self.production_line:change_recipe(index, recipe_name)
  self:update()
end

function ProductionLineController:prepare_for_link(recipe_index, item_name)
  local recipe_controllers = self.recipe_controllers
  local item_delta = self.production_line.recipes[recipe_index].items[item_name]
  local look_for_product = item_delta < 0
  for i=1,#self.recipe_controllers do
    recipe_controllers[i]:prepare_for_link(look_for_product, item_name)
  end
end

function ProductionLineController:complete_link(constrained_index, constraining_index, item_name)
  if constraining_index and constrained_index then
    self.production_line:link_recipes(constrained_index, constraining_index, item_name)
    self.recipe_controllers[constrained_index]:update()
    self.recipe_controllers[constraining_index]:update()
  end
  for _, recipe_controller in pairs(self.recipe_controllers) do
    recipe_controller:complete_link()
  end
  self:update()
end

function ProductionLineController:update()
  self.view:update()
  for _, controller in pairs(self.recipe_controllers) do
    controller:update()
  end
end

-- event handlers

function ProductionLineController:on_gui_click(event)
  local element = event.element
  if element.name == "move_recipe_up_button" or element.name == "move_recipe_down_button" then
    on_move_recipe_button(self, event)
    return true
  elseif element.name == "remove_recipe_button" then
    on_remove_recipe_button(self, event.context.recipe_index)
    return true
  elseif event.context.recipe_index then
    event.context.recipe = self.production_line.recipes[event.context.recipe_index]
  end
end

local M = {}
local meta = { __index = ProductionLineController }

function M.new(view, recipe_picker)
  local self = {
    production_line = nil,

    view = view,

    recipe_picker = recipe_picker,
    recipe_controllers = {},
  }
  return M.restore(self)
end

function M.restore(self)
  ProductionLineFlow.restore(self.view)
  for _, recipe_controller in pairs(self.recipe_controllers) do
    RecipeFlowController.restore(recipe_controller)
  end
  Dispatcher.register(self, self.view.gui)
  return setmetatable(self, meta)
end

return M
