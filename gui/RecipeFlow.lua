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

local function update_recipe_button(self, recipe)
  self.recipe_button.sprite = "recipe/"..recipe.name
end

local function update_crafting_machine_button(self)
  local crafting_machine = self.crafting_machine
  if crafting_machine then
    self.crafting_machine_button.sprite = "entity/"..crafting_machine.name
    self.crafting_machine_button.tooltip = crafting_machine:tooltip()
  end
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
    log(inspect{name, amount})
    log(inspect(self))
    local proto = game.item_prototypes[name] or game.fluid_prototypes[name]
    local button = self.ingredients_table[name] or self.products_table[name]
    if amount < 0 then
      amount = -amount
    end
    button.number = amount
    button.tooltip = {
      "planner-gui.item-button-tooltip",
      proto.localised_name,
      amount,
    }
  end
end

local function create(self, parent)
  local flow = parent.add{
    type = "flow",
    direction = "horizontal",
  }
  self.remove_button = flow.add{
    name = "remove_recipe_button",
    type = "sprite-button",
    sprite = "utility/remove",
  }
  self.recipe_button = flow.add{
    name = "change_recipe_button",
    type = "sprite-button",
    style = "slot_button",
  }
  self.crafting_machine_button = flow.add{
    name = "crafting_machine",
    type = "sprite-button",
    style = "slot_button",
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

function RecipeFlow:set_recipe(production_line, recipe_index)
  log("RecipeFlow:set_recipe")
  self.production_line, self.index = production_line, recipe_index
  self:update()
end

function RecipeFlow:update()
  local recipe = self.production_line.recipes[self.index]
  update_recipe_button(self, recipe)
  update_crafting_machine_button(self)
  update_ingredient_buttons(self, recipe)
  update_product_buttons(self, recipe)
  update_counts(self, recipe)
end

function RecipeFlow:destroy()
  self.gui.destroy()
end

local M = {}
local meta = { __index = RecipeFlow }

function M.new(parent, index)
  local self = {
    gui = nil,

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
