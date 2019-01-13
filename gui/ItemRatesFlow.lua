local inspect = require "inspect"
local style = require "gui.style"

local function add_item_button(self, parent, item_name, rate)
  local type = game.fluid_prototypes[item_name] and "fluid" or "item"
  local button = parent.add{
    name = item_name,
    type = "sprite-button",
    style = "slot_button",
    sprite = type.."/"..item_name,
  }
  button.number = rate
end

local function create(self, parent)
  local flow = parent.add{
    name = "rates",
    type = "flow",
    direction = "horizontal",
  }
  self.gui = flow
  self.ingredients_table = flow.add{
    name = "ingredients",
    type = "table",
    column_count = style.item_buttons_in_column,
  }
  self.ingredients_table.style.width = style.dimensions.ingredients_column_width

  self.products_table = flow.add{
    name = "products",
    type = "table",
    column_count = style.item_buttons_in_column,
  }
  self.products_table.style.width = style.dimensions.products_column_width
end

local function sorted_keys(t)
  local out = {}
  for k in pairs(t) do
    out[#out+1] = k
  end
  table.sort(out)
  return out
end

local function update_item_tables(self)
  self.ingredients_table.clear()
  self.products_table.clear()

  local prototype_rates = self.prototype_rates
  local current_rates = self.current_rates
  for _, item_name in ipairs(sorted_keys(self.prototype_rates)) do
    local prototype_rate = prototype_rates[item_name]
    local current_rate = current_rates[item_name]
    if prototype_rate < 0 then
      add_item_button(self, self.ingredients_table, item_name, -current_rate)
    else
      add_item_button(self, self.products_table, item_name, current_rate)
    end
  end
end

local function update_styles(self)
  for item_name, link in pairs(self.links) do
    local button = self.ingredients_table[item_name] or self.products_table[item_name]
    local style = "slot_button"
    if link.constrains then style = "green_slot_button" end
    if link.constrained_by then style = "slot_with_filter_button" end
    button.style = style
  end
end

local function update_tooltip(self, button)
  local item_name = button.name
  local proto =
    game.item_prototypes[item_name] or game.fluid_prototypes[item_name]

  local components = {
    "",
    {
      "planner-gui.item-button-tooltip",
      proto.localised_name,
      math.abs(self.current_rates[item_name]),
    },
  }

  local constrained_by = self.links[item_name] and self.links[item_name].constrained_by
  if constrained_by then
    components[#components+1] = {"planner-gui.constrained-by-header"}
    for _, constraint in pairs(constrained_by) do
      components[#components+1] = {
        "planner-gui.item-rate-line",
        constraint.localised_name,
        math.abs(constraint.rate),
      }
    end
  end

  local constrains = self.links[item_name] and self.links[item_name].constrains
  if constrains then
    components[#components+1] = {"planner-gui.constrains-header"}
    for _, constraint in pairs(constrains) do
      components[#components+1] = {
        "planner-gui.item-rate-line",
        constraint.localised_name,
        math.abs(self.current_rates[item_name]),
      }
    end
  end

  button.tooltip = components
end

local function update_tooltips(self)
  for _, t in pairs{self.ingredients_table, self.products_table} do
    for _, button in pairs(t.children) do
      update_tooltip(self, button)
    end
  end
end

local M = {}
local meta = { __index = M }

function M:disable_all_buttons()
  for _, parent in pairs{self.ingredients_table, self.products_table} do
    for _, button in pairs(parent.children) do
      button.enabled = false
    end
  end
end

function M:enable_all_buttons()
  for _, parent in pairs{self.ingredients_table, self.products_table} do
    for _, button in pairs(parent.children) do
      button.enabled = true
    end
  end
end

function M:enable_buttons_for_link(item_name)
  self:disable_all_buttons()
  local button = self.ingredients_table[item_name] or self.products_table[item_name]
  if button then
    button.enabled = true
  end
end

--- @param links {
---   [item_name] = {
---     constrains = {
---       {
---         localised_name = localised_name,
---       },
---     },
---     constrained_by = {
---       {
---         localised_name = localised_name,
---         rate = rate,
---       },
---       ...
---     },
---   },
---   ...
--- }
function M:set_links(links)
  self.links = links
end

function M:update()
  update_item_tables(self)
  update_styles(self)
  update_tooltips(self)
end

-- exports

local function restore(self)
  return setmetatable(self, meta)
end

local function new(parent)
  local self = {
    gui = nil,
    ingredients_table = nil,
    products_table = nil,

    prototype_rates = {},
    current_rates = {},
    links = {},
  }
  create(self, parent)
  return restore(self)
end

return {
  new = new,
  restore = restore,
}
