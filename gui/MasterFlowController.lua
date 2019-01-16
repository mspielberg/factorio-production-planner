local CraftingMachinePickerController = require "gui.CraftingMachinePickerController"
local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local MasterFlow = require "gui.MasterFlow"
local PlannerFrameController = require "gui.PlannerFrameController"
local RecipePickerController = require "gui.RecipePickerController"

local IDLE = 0
local ADDING_RECIPE = 1
local CHANGING_RECIPE = 2
local LINKING = 3

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

local function on_item_button(self, event)
  local state = self.state
  local context = event.context
  local recipe_index = context.recipe_index
  local element = event.element
  local item_name = element.name

  if state.name == LINKING then
    self.planner_frame:complete_link(recipe_index, state.recipe_index, state.item_name)
    self.recipe_picker:hide()
    self.state = { name = IDLE }
  else
    self.planner_frame:prepare_for_link(recipe_index, item_name)

    local item_filter = element.parent.name == "ingredients"
      and RecipePickerController.has_product_filter(item_name)
      or  RecipePickerController.has_ingredient_filter(item_name)
    self.recipe_picker:set_filter(RecipePickerController.and_filters{
      item_filter,
      RecipePickerController.enabled_and_not_hidden_filter()})
    self.recipe_picker:show()

    self.state = {
      name = LINKING,
      recipe_index = recipe_index,
      item_name = item_name,
    }
  end
end

local function on_recipe_picked(self, event)
  local state = self.state
  if state.name == ADDING_RECIPE or state.name == LINKING then
    local new_recipe_index = self.planner_frame:add_recipe(event.context)
    if state.name == LINKING then
      self.planner_frame:complete_link(new_recipe_index, state.recipe_index, state.item_name)
    end
    self.recipe_picker:hide()
    self.state = { name = IDLE }
  elseif state.name == CHANGING_RECIPE then
    self.planner_frame:change_recipe(self.state.recipe_index, event.context.recipe_name)
    self.recipe_picker:hide()
    self.state = { name = IDLE }
  else
    error("on_recipe_picked in invalid state "..inspect(self.state))
  end
end

local function on_recipe_picker_cancelled(self, event)
  local state = self.state
  if state.name == LINKING then
    self.planner_frame:complete_link(nil, nil, nil)
  end
  self.recipe_picker:hide()
  self.state = { name = IDLE }
end

local MasterFlowController = {}

-- event handlers

function MasterFlowController:on_gui_click(event)
  local element = event.element
  if element == self.view.show_hide_button then
    self.view:toggle_show_hide()
    return true
  elseif element.name == "add_recipe_button" then
    on_add_recipe_button(self, event)
    return true
  elseif element.name == "change_recipe_button" then
    on_change_recipe_button(self, event)
    return true
  elseif element.parent.name == "ingredients" or element.parent.name == "products" then
    on_item_button(self, event)
    return true
  elseif element.name == "cancel_recipe_picker_button" then
    on_recipe_picker_cancelled(self, event)
    return true
  elseif event.context.type == "RecipePicker" then
    on_recipe_picked(self, event)
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
  local crafting_machine_picker =
    CraftingMachinePickerController.new(view.crafting_machine_picker)

  local self = {
    state = { name = IDLE },
    view = view,
    planner_frame = PlannerFrameController.new(view.planner_frame, recipe_picker),
    recipe_picker = recipe_picker,
    crafting_machine_picker = crafting_machine_picker,
  }

  return M.restore(self)
end

function M.restore(self)
  setmetatable(self, meta)
  MasterFlow.restore(self.view)
  PlannerFrameController.restore(self.planner_frame)
  RecipePickerController.restore(self.recipe_picker)
  Dispatcher.register(self, self.view.show_hide_button)
  Dispatcher.register(self, self.view.gui)
  return self
end

return M
