local mod_gui = require "mod-gui"
local Dispatcher = require "gui.Dispatcher"
local RecipeFlow = require "gui.RecipeFlow"

local function create_header_row(recipes_table)
  recipes_table.add{
    name = "recipe_label",
    type = "label",
    caption = {"planner-gui.recipe-header"},
  }
  recipes_table.add{
    name = "machine_label",
    type = "label",
    caption = {"planner-gui.machine-header"},
  }
  recipes_table.machine_label.style.align = "center"
  recipes_table.add{
    name = "ingredients_label",
    type = "label",
    caption = {"planner-gui.ingredients-header"},
  }
  recipes_table.add{
    name = "products_label",
    type = "label",
    caption = {"planner-gui.products-header"},
  }
end

local function add_recipes_table(self, parent)
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
  local scroll = flow.add{
    name = "scroll",
    type = "scroll-pane",
  }
  scroll.style.height = 800
  self.recipes_table = scroll.add{
    name = "recipes",
    type = "table",
    column_count = 4,
  }

  create_header_row(self.recipes_table)
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
  add_recipes_table(self, frame)
  return frame
end

local function register_event_handlers(self)
  Dispatcher.register(
    defines.events.on_gui_click,
    self.add_recipe_button,
    function(event)
      self.controller:on_add_recipe_button(event)
    end)
end

local PlannerView = {}

function PlannerView:set_controller(controller)
  self.controller = controller
end

function PlannerView:add_recipe(name)
  self.recipe_flows[#self.recipe_flows] = RecipeFlow.new(self.recipes)
end

function PlannerView:get_recipes_table()
  return self.recipes_table
end

local M = {}
local meta = { __index = PlannerView }

function M.new(parent)
  local self = {
    controller = nil,
    gui = nil,
    recipes_table = nil,
    add_recipe_button = nil,
    recipe_flows = {},
  }
  self.gui = create_frame(self, parent)
  return M.restore(self)
end

function M.restore(self)
  setmetatable(self, meta)
  register_event_handlers(self)
  return self
end

return M