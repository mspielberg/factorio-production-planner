local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"
local Planner = require "Planner"
local PlannerFrame = require "gui.PlannerFrame"
local ProductionLineController = require "gui.ProductionLineController"

local PlannerFrameController = {}

function PlannerFrameController:add_recipe(recipe_name)
  self.production_line:add_recipe(recipe_name)
  return #self.planner.current_line.recipes
end

function PlannerFrameController:change_recipe(index, recipe_name)
  self.production_line:change_recipe(index, recipe_name)
end

function PlannerFrameController:update()
  self.production_line:update()
end

function PlannerFrameController:prepare_for_link(recipe_index, item_name)
  self.production_line:prepare_for_link(recipe_index, item_name)
end

function PlannerFrameController:complete_link(constrained_index, constraining_index, item_name)
  self.production_line:complete_link(constrained_index, constraining_index, item_name)
end

local M = {}
local meta = { __index = PlannerFrameController }

function M.new(view, recipe_picker)
  local self = {
    planner = Planner.new(),
    view = view,

    production_line = nil,
  }
  self.production_line =
    ProductionLineController.new(view.production_line_flow, recipe_picker)
  self.production_line:set_production_line(self.planner.current_line)
  return M.restore(self)
end

function M.restore(self)
  Planner.restore(self.planner)
  PlannerFrame.restore(self.view)
  ProductionLineController.restore(self.production_line)
  Dispatcher.register(self, self.view.gui)
  return setmetatable(self, meta)
end

return M
