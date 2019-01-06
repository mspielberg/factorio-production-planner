local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local Recipe = require "Recipe"
local style = require "gui.style"

local on_gui_click = defines.events.on_gui_click

local function add_item_button(self, parent, type, name)
  local button = parent.add{
    name = name,
    type = "sprite-button",
    style = "slot_button",
    sprite = type.."/"..name,
  }
  Dispatcher.register(on_gui_click, button, function(event)
    self.controller:on_item_button(name)
  end)
end

local function remove_buttons(parent)
  for _, child in ipairs(parent.children) do
    Dispatcher.register(on_gui_click, child, nil)
  end
  parent.clear()
end

local function update_ingredient_buttons(self, recipe)
  local ingredients_table = self.ingredients_table
  remove_buttons(ingredients_table)
  if not recipe then return end

  local proto = game.recipe_prototypes[recipe.name]
  for _, ingredient in ipairs(proto.ingredients) do
    local name = ingredient.name
    if recipe.items[name] and recipe.items[name] < 0 then
      add_item_button(self, ingredients_table, ingredient.type, name)
    end
  end
end

local function update_product_buttons(self, recipe)
  local products_table = self.products_table
  remove_buttons(products_table)
  if not recipe then return end

  local proto = game.recipe_prototypes[recipe.name]
  for _, product in ipairs(proto.products) do
    local name = product.name
    if recipe.items[name] and recipe.items[name] > 0 then
      add_item_button(self, products_table, product.type, name)
    end
  end
end

local function update_counts(self, recipe)
  local rates = recipe:get_item_rates()
  for name, amount in pairs(rates) do
    local proto = game.item_prototypes[name] or game.fluid_prototypes[name]
    local button
    if amount < 0 then
      button = self.ingredients_table[name]
      amount = -amount
    else
      button = self.products_table[name]
    end
    button.number = amount
    button.tooltip = {
      "planner-gui.item-button-tooltip",
      proto.localised_name,
      amount,
    }
  end
end

local RecipeFlow = {}

--- @param parent LuaViewElement table of 4 columns
local function add_to_parent(self, parent)
  local flow = parent.add{
    type = "flow",
    direction = "horizontal",
  }
  self.recipe_button = flow.add{
    type = "choose-elem-button",
    elem_type = "recipe",
  }
  Dispatcher.register(
    defines.events.on_gui_elem_changed,
    self.recipe_button,
    function()
      self.controller:on_recipe_button_changed(event)
    end)
  self.crafting_machine_button = flow.add{
    type = "sprite-button",
    style = "slot_button",
  }
  self.ingredients_table = flow.add{
    type = "table",
    column_count = 5,
  }
  self.ingredients_table.style.width = style.dimensions.ingredients_column_width
  self.products_table = flow.add{
    type = "table",
    column_count = 5,
  }
  self.products_table.style.width = style.dimensions.products_column_width
end

local function unregister_event_handlers(self)
  Dispatcher.register(
    defines.events.on_gui_elem_changed,
    self.recipe_button,
    nil)
end

function RecipeFlow:set_controller(controller)
  self.controller = controller
end

function RecipeFlow:set_recipe(recipe)
  update_ingredient_buttons(self, recipe)
  update_product_buttons(self, recipe)
end

function RecipeFlow:set_crafting_machine(crafting_machine)
  self.crafting_machine_button.sprite = "entity/"..crafting_machine.name
  local tooltip = crafting_machine:tooltip()
  self.crafting_machine_button.tooltip = crafting_machine:tooltip()
end

function RecipeFlow:destroy()
  unregister_event_handlers(self)
  self.recipe_button.destroy()
  self.crafting_machine_button.destroy()
  self.crafting_machine_button.destroy()
  self.ingredients_table.destroy()
  self.products_table.destroy()
end

local M = {}
local meta = { __index = RecipeFlow }

function M.new(parent)
  local self = {
    controller = nil,
    recipe_button = nil,
    crafting_machine_button = nil,
    ingredients_table = nil,
    products_table = nil,
  }
  setmetatable(self, meta)
  add_to_parent(self, parent)
  return M.restore(self)
end

function M.restore(self)
  register_event_handlers(self)
  return setmetatable(self, meta)
end

return M
