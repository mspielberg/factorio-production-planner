local function create(self, parent)
  local flow = parent.add{
    name = "virtual_recipe",
    type = "flow",
    direction = "vertical",
  }
  self.gui = flow

  local virtual_recipe_definition_flow = flow.add{
    name = "virtual_recipe_definition",
    type = "flow",
    direction = "horizontal",
  }

  local choose_item_button = virtual_recipe_definition_flow.add{
    name = "choose_virtual_recipe_item",
    type = "choose-elem-button",
    elem_type = "item",
  }
  self.choose_item_button = choose_item_button

  local rate_field = virtual_recipe_definition_flow.add{
    name = "virtual_recipe_rate",
    type = "textfield",
  }
  -- rate_field.style.width = 80
  self.rate_field = rate_field

  local button_flow = flow.add{
    name = "buttons",
    type = "flow",
    direction = "horizontal",
  }

  button_flow.add{
    name = "create_virtual_demand_recipe_button",
    type = "button",
    caption = "Add Demand",
  }
  button_flow.add{
    name = "create_virtual_supply_recipe_button",
    type = "button",
    caption = "Add Supply",
  }

  local filler_flow = button_flow.add{
    type = "flow",
    direction = "horizontal",
  }
  filler_flow.style.horizontally_stretchable = true

  button_flow.add{
    name = "cancel_recipe_picker_button",
    type = "button",
    caption = "Cancel",
  }
end

local VirtualRecipeFlow = {}
local meta = { __index = VirtualRecipeFlow }

function VirtualRecipeFlow:reset()
  self.choose_item_button.elem_value = nil
  self.rate_field.text = ""
end

local M = {}

function M.new(parent)
  local self = {
    gui = nil,
    choose_item_button = nil,
    rate_field = nil,
  }
  create(self, parent)
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
