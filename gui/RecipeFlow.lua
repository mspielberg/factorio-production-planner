local inspect = require "inspect"
local Recipe = require "Recipe"
local style = require "gui.style"

local function add_item_button(self, parent, type, name)
  local button = parent.add{
    name = name,
    type = "sprite-button",
    style = "slot_button",
    sprite = type.."/"..name,
  }
end

local function remove_buttons(parent)
  parent.clear()
end

local function disable_all_buttons(self)
  for _, parent in pairs{self.arrow_flow, self.ingredients_table, self.products_table} do
    for _, button in pairs(parent.children) do
      button.enabled = false
    end
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
  local crafting_machine = self.crafting_machine
  if recipe.is_virtual then
    self.crafting_machine_button.sprite = "item/infinity-chest"
    self.crafting_machine_button.enabled = false
  elseif crafting_machine then
    self.crafting_machine_button.sprite = "entity/"..crafting_machine.name
    self.crafting_machine_button.tooltip = crafting_machine:tooltip()
    self.crafting_machine_button.enabled = true
  end
end

local function update_item_buttons(self, recipe)
  local ingredients_table = self.ingredients_table
  local products_table = self.products_table
  remove_buttons(ingredients_table)
  remove_buttons(products_table)
  for item_name, delta in pairs(recipe.items) do
    local type = "item"
    if game.fluid_prototypes[item_name] then type = "fluid" end
    if delta < 0 then
      add_item_button(self, ingredients_table, type, item_name)
    else
      add_item_button(self, products_table, type, item_name)
    end
  end
end

local function update_links(self, recipe)
  for _, table in pairs{self.ingredients_table, self.products_table} do
    for _, button in pairs(table.children) do
      local item_name = button.name
      local style
      for _, constraint in pairs(recipe.constrains) do
        if constraint.item == item_name then
          style = "green_slot_button"
        end
      end
      for _, constraint in pairs(recipe.constrained_by) do
        if constraint.item == item_name then
          style = "slot_with_filter_button"
        end
      end
      if style then
        button.style = style
      end
    end
  end
end

local function update_counts(self, recipe)
  local rates = recipe:get_item_rates()
  for name, amount in pairs(rates) do
    local proto = game.item_prototypes[name] or game.fluid_prototypes[name]
    local button = self.ingredients_table[name] or self.products_table[name]
    if amount < 0 then
      amount = -amount
    end
    button.number = amount
    --[[
    button.tooltip = {
      "planner-gui.item-button-tooltip",
      proto.localised_name,
      amount,
    }
    ]]
  end
end

local function update_tooltip(self, recipe, button)
  local item_name = button.name
  local proto =
    game.item_prototypes[item_name] or game.fluid_prototypes[item_name]

  local components = {
    "",
    {
      "planner-gui.item-button-tooltip",
      proto.localised_name,
      math.abs(recipe:get_item_rates()[item_name]),
    },
  }
  local constrained_by = recipe:get_constrained_by(item_name)
  if next(constrained_by) then
    components[#components+1] = {"planner-gui.constrained-by-header"}
    for _, constraining_recipe in pairs(constrained_by) do
      components[#components+1] = {
        "planner-gui.item-rate-line",
        constraining_recipe.localised_name,
        math.abs(constraining_recipe:get_item_rates()[item_name]),
      }
    end
  end
  local constrains = recipe:get_constrains(item_name)
  if next(constrains) then
    components[#components+1] = {"planner-gui.constrains-header"}
    for _, constrained_recipe in pairs(constrains) do
      components[#components+1] = {
        "planner-gui.item-rate-line",
        constrained_recipe.localised_name,
        math.abs(constrained_recipe:get_item_rates()[item_name]),
      }
    end
  end

  button.tooltip = components
end

local function update_tooltips(self, recipe)
  for _, t in pairs{self.ingredients_table, self.products_table} do
    for _, button in pairs(t.children) do
      update_tooltip(self, recipe, button)
    end
  end
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
  self.arrow_flow = arrow_flow
  arrow_flow.add{
    name = "move_recipe_up_button",
    type = "button",
    style = "column_ordering_ascending_button_style",
    tooltip = "planner-gui.move-recipe-tooltip",
  }
  arrow_flow.add{
    name = "move_recipe_down_button",
    type = "button",
    style = "column_ordering_descending_button_style",
    tooltip = "planner-gui.move-recipe-tooltip",
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

  self.ingredients_table = flow.add{
    name = "ingredients",
    type = "table",
    column_count = 5,
  }
  self.ingredients_table.style.width = style.dimensions.ingredients_column_width

  self.products_table = flow.add{
    name = "products",
    type = "table",
    column_count = 5,
  }
  self.products_table.style.width = style.dimensions.products_column_width

  return flow
end

local RecipeFlow = {}

function RecipeFlow:enable_buttons_for_link(is_product, item_name)
  disable_all_buttons(self)
  local item_table = is_product and self.products_table or self.ingredients_table
  local button = item_table[item_name]
  if button then
    button.enabled = true
  end
end

function RecipeFlow:complete_link()
  self:update()
end

function RecipeFlow:update()
  local recipe = self.production_line.recipes[self.index]
  self.remove_button.enabled = true
  update_move_recipe_buttons(self)
  update_recipe_button(self, recipe)
  update_crafting_machine_button(self, recipe)
  update_item_buttons(self, recipe)
  update_links(self, recipe)
  update_counts(self, recipe)
  update_tooltips(self, recipe)
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
    ingredients_table = nil,
    products_table = nil,

    production_line = nil,
    index = index,
    crafting_machine = nil,
  }
  self.gui = create(self, parent)
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
