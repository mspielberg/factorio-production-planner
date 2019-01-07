local RecipeFlow = require "gui.RecipeFlow"
local style = require "gui.style"

local function create_header_flow(parent)
  local flow = parent.add{
    name = "header",
    type = "flow",
    direction = "horizontal",
  }

  local recipe_header = flow.add{
    name = "recipe_label",
    type = "label",
    --caption = {"planner-gui.recipe-header"},
  }
  recipe_header.style.width = style.dimensions.recipe_column_width

  local assembling_machine_header = flow.add{
    name = "machine_label",
    type = "label",
    --caption = {"planner-gui.machine-header"},
  }
  assembling_machine_header.style.width =
    style.dimensions.assembling_machine_column_width

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
  self.add_recipe_button = flow.add{
    name = "add_recipe_button",
    type = "sprite-button",
    sprite = "utility/add",
  }
  local scroll_flow = flow.add{
    name = "right",
    type = "flow",
    direction = "vertical",
  }
  create_header_flow(scroll_flow)
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

local function create_frame(self, parent)
  local frame = parent.add{
    name = "planner_frame",
    type = "frame",
    direction = "vertical",
  }
  frame.style.visible = false
  local title = frame.add{
    name = "title",
    type = "label",
    caption = "Production Planner",
  }
  add_recipes_flow(self, frame)
  return frame
end

local PlannerFrame = {}

function PlannerFrame:add_recipe()
  local index = #self.recipe_flows + 1
  local recipe_flow = RecipeFlow.new(self.recipes_flow)
  self.recipe_flows[index] = recipe_flow
  return recipe_flow
end

function PlannerFrame:set_recipe(index, recipe)
  self.recipe_flows[index]:set_recipe(recipe)
end

local M = {}
local meta = { __index = PlannerFrame }

function M.new(parent)
  local self = {
    gui = nil,
    recipes_flow = nil,
    add_recipe_button = nil,
    recipe_flows = {},
  }
  self.gui = create_frame(self, parent)
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M