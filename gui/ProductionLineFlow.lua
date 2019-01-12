local RecipeFlow = require "gui.RecipeFlow"
local style = require "gui.style"

local function add_header_flow(parent)
  local flow = parent.add{
    name = "header",
    type = "flow",
    direction = "horizontal",
  }

  local padding = flow.add{
    name = "padding",
    type = "flow"
  }
  padding.style.width = style.dimensions.ingredients_column_offset

  local ingredients_header = flow.add{
    name = "ingredients_label",
    type = "label",
    caption = {"planner-gui.ingredients-header"},
  }
  ingredients_header.style.width = style.dimensions.ingredients_column_width

  local products_header = flow.add{
    name = "products_label",
    type = "label",
    caption = {"planner-gui.products-header"},
  }
  products_header.style.width = style.dimensions.products_column_width
end

local function add_recipes_flow(self, parent)
  local flow = parent.add{
    name = "recipes_flow",
    type = "flow",
    direction = "horizontal",
  }
  self.gui = flow
  local add_recipe_button = flow.add{
    name = "add_recipe_button",
    type = "sprite-button",
    sprite = "utility/add",
  }
  add_recipe_button.style.scaleable = false
  add_recipe_button.style.height = 36
  add_recipe_button.style.width = 36
  self.add_recipe_button = add_recipe_button

  local scroll_flow = flow.add{
    name = "right",
    type = "flow",
    direction = "vertical",
  }
  add_header_flow(scroll_flow)
  local scroll = scroll_flow.add{
    name = "scroll",
    type = "scroll-pane",
  }
  scroll.style.height = 800
  self.recipes_flow = scroll.add{
    name = "recipes",
    type = "flow",
    direction = "vertical",
  }
end

local ProductionLineFlow = {}
local meta = { __index = ProductionLineFlow }

function ProductionLineFlow:add_recipe()
  local index = #self.recipe_flows + 1
  local recipe_flow = RecipeFlow.new(self.recipes_flow)
  self.recipe_flows[index] = recipe_flow
  return recipe_flow
end

function ProductionLineFlow:set_recipe(index, recipe)
  self.recipe_flows[index]:set_recipe(recipe)
end

local M = {}

function M.new(parent)
  local self = {
    gui = nil,
    recipes_flow = nil,
    add_recipe_button = nil,
    recipe_flows = {},
  }
  add_recipes_flow(self, parent)
  return M.restore(self)
end

function M.restore(self)
  log(debug.traceback())
  return setmetatable(self, meta)
end

return M
