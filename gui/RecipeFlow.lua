local inspect = require "inspect"
local ItemRatesFlow = require "gui.ItemRatesFlow"
local Recipe = require "Recipe"
local style = require "gui.style"

local function disable_all_buttons(self)
  for _, button in pairs(self.arrow_flow.children) do
    button.enabled = false
  end
  self.remove_button.enabled = false
  self.recipe_button.enabled = false
  self.crafting_machine_button.enabled = false
end

local function update_move_recipe_buttons(self)
  local arrow_flow = self.arrow_flow
  local up_button = arrow_flow.move_recipe_up_button
  local down_button = arrow_flow.move_recipe_down_button
  local index = self.index
  up_button.enabled = index > 1
  down_button.enabled = index < #self.production_line.recipes
end

local function update_recipe_button(self, recipe)
  if recipe.is_virtual then
    self.recipe_button.sprite = ""
    self.recipe_button.enabled = false
  else
    self.recipe_button.sprite = "recipe/"..recipe.name
    self.recipe_button.enabled = true
  end
end

local function update_crafting_machine_button(self, recipe)
  local crafting_machine = recipe.crafting_machine
  if recipe.is_virtual then
    self.crafting_machine_button.sprite = "item/infinity-chest"
    self.crafting_machine_button.tooltip = {"planner-gui.fixed-rate-recipe"}
    self.crafting_machine_button.number = 0
    self.crafting_machine_button.enabled = false
  elseif crafting_machine then
    self.crafting_machine_button.sprite = "entity/"..crafting_machine.name
    self.crafting_machine_button.tooltip = crafting_machine:tooltip()
    self.crafting_machine_button.number =
      recipe.energy * recipe.rate / crafting_machine:effective_speed()
    self.crafting_machine_button.enabled = true
  end
end

local function update_item_rates(self, recipe)
  local item_rates_flow = self.item_rates_flow
  item_rates_flow.prototype_rates = recipe:get_prototype_rates()
  item_rates_flow.current_rates = recipe:get_current_rates()
  item_rates_flow:set_links(recipe:get_links())
  item_rates_flow:update()
end

local function create(self, parent)
  local flow = parent.add{
    type = "flow",
    direction = "horizontal",
  }
  flow.style.vertical_align = "center"

  local arrow_flow = flow.add{
    name = "arrows",
    type = "flow",
    direction = "vertical",
  }
  arrow_flow.style.width = 22
  arrow_flow.style.height = 36
  self.arrow_flow = arrow_flow

  arrow_flow.add{
    name = "move_recipe_up_button",
    type = "button",
    style = "column_ordering_ascending_button_style",
    tooltip = {"planner-gui.move-recipe-tooltip"},
  }
  arrow_flow.add{
    name = "move_recipe_down_button",
    type = "button",
    style = "column_ordering_descending_button_style",
    tooltip = {"planner-gui.move-recipe-tooltip"},
  }

  self.remove_button = flow.add{
    name = "remove_recipe_button",
    type = "sprite-button",
    sprite = "utility/remove",
  }
  self.remove_button.style.scaleable = false
  self.remove_button.style.height = 36
  self.remove_button.style.width = 36

  self.recipe_button = flow.add{
    name = "change_recipe_button",
    type = "sprite-button",
    style = "recipe_slot_button",
  }

  self.crafting_machine_button = flow.add{
    name = "crafting_machine",
    type = "sprite-button",
    style = "recipe_slot_button",
  }

  self.item_rates_flow = ItemRatesFlow.new(flow)

  return flow
end

local RecipeFlow = {}

function RecipeFlow:complete_link()
  self:update()
end

function RecipeFlow:enable_buttons_for_link(is_product, item_name)
  disable_all_buttons(self)
  self.item_rates_flow:enable_buttons_for_link(item_name)
end

function RecipeFlow:set_production_line(production_line)
  self.production_line = production_line
  self:update()
end

function RecipeFlow:update()
  local recipe = self.production_line.recipes[self.index]
  self.remove_button.enabled = true
  update_move_recipe_buttons(self)
  update_recipe_button(self, recipe)
  update_crafting_machine_button(self, recipe)
  update_item_rates(self, recipe)
end

function RecipeFlow:destroy()
  self.gui.destroy()
end

local M = {}
local meta = { __index = RecipeFlow }

function M.new(parent, index)
  local self = {
    gui = nil,

    arrow_flow = nil,
    remove_button = nil,
    recipe_button = nil,
    crafting_machine_button = nil,
    item_rates_flow = nil,

    production_line = nil,
    index = index,
    crafting_machine = nil,
  }
  self.gui = create(self, parent)
  M.restore(self)
  return self
end

function M.restore(self)
  ItemRatesFlow.restore(self.item_rates_flow)
  return setmetatable(self, meta)
end

return M