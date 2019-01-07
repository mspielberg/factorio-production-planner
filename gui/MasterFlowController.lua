local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local PlannerFrameController = require "gui.PlannerFrameController"
local RecipePickerController = require "gui.RecipePickerController"

local IDLE = 0
local ADDING_RECIPE = 1
local CHANGING_RECIPE = 2

local function on_add_recipe_button(self)
  self.state = { name = ADDING_RECIPE }
  self.recipe_picker:set_filter(
    RecipePickerController.enabled_and_not_hidden_filter())
  self.recipe_picker:show()
end

local function on_change_recipe_button(self, event)
  self.state = { name = CHANGING_RECIPE, recipe_index = event.context.recipe_index }
  self.recipe_picker:set_filter(
    RecipePickerController.enabled_and_not_hidden_filter())
  self.recipe_picker:show()
end

local function on_recipe_picked(self, recipe_name)
  local state = self.state
  if state.name == ADDING_RECIPE then
    self.recipe_picker:hide()
    self.planner:add_recipe(recipe_name)
    self.state = IDLE
  elseif state.name == CHANGING_RECIPE then
    self.recipe_picker:hide()
    self.planner:change_recipe(self.state.recipe_index, recipe_name)
    self.state = IDLE
  else
    error("on_recipe_picked in invalid state "..inspect(self.state))
  end
end

local MasterFlowController = {}

function MasterFlowController:on_gui_click(event)
  local element = event.element
  if element == self.view.show_hide_button then
    self.planner:toggle_show_hide()
    return true
  elseif element.name == "add_recipe_button" then
    on_add_recipe_button(self, event)
    return true
  elseif element.name == "change_recipe_button" then
    on_change_recipe_button(self, event)
    return true
  elseif event.context and event.context.type == "RecipePicker" then
    on_recipe_picked(self, event.context.recipe_name)
    return true
  end
end

local M = {}
local meta = { __index = MasterFlowController }

function M.new(view)
  local player = game.players[view.gui.player_index]
  local recipe_picker = RecipePickerController.new(
    view.recipe_picker_frame,
    view.recipe_picker_frame.picker_flow,
    player)

  local self = {
    state = { name = IDLE },
    view = view,
    planner = PlannerFrameController.new(view.planner_frame, recipe_picker),
    recipe_picker = recipe_picker,
  }

  return M.restore(self)
end

function M.restore(self)
  setmetatable(self, meta)
  Dispatcher.register(self, self.view.show_hide_button)
  Dispatcher.register(self, self.view.gui)
  PlannerFrameController.restore(self.planner)
  RecipePickerController.restore(self.recipe_picker)
  return self
end

return M
