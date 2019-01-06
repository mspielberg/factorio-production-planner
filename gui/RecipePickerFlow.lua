local Dispatcher = require "gui.Dispatcher"
local inspect = require "inspect"

local function create(self, parent)
  self.picker_flow = parent.add{
    name = "recipe_picker",
    type = "flow",
    direction = "vertical",
  }
end

local function reindex_by_name(t)
  local new = {}
  for i, elem in pairs(t) do
    new[elem.name] = elem
    t[i] = nil
  end
  for k,v in pairs(new) do
    t[k] = v
  end
end

local function item_amount(item)
  if item.amount then
    return item.amount
  end
  return (item.amount_min + item.amount_max) / 2 * item.probability
end

local function items_localised_string(items)
  local out = {""}
  for i, item in ipairs(items) do
    local item_name = item.name
    out[#out+1] = {
      "planner-gui.recipe-item-line",
      item_amount(item),
      game[item.type.."_prototypes"][item.name].localised_name
    }
    out[#out+1] = "\n"
  end
  out[#out] = nil
  return out
end

local function recipe_button_tooltip(recipe)
  local tooltip = {
    "planner-gui.recipe-button-tooltip",
    recipe.localised_name,
    items_localised_string(recipe.products),
    items_localised_string(recipe.ingredients),
  }
  log(inspect(tooltip))
  return tooltip
end

local function add_subgroup_flow(self, parent, subgroup)
  local flow = parent.add{
    name = subgroup.name,
    type = "table",
    column_count = 10,
    style = "slot_table",
  }
  for _, recipe in ipairs(subgroup.recipes) do
    local recipe_name = recipe.name
    local recipe_button = flow.add{
      name = recipe_name,
      type = "sprite-button",
      style = "recipe_slot_button",
      sprite = "recipe/"..recipe_name,
      tooltip = recipe_button_tooltip(recipe.lua_recipe),
    }
    Dispatcher.register(
      defines.events.on_gui_click,
      recipe_button,
      function(event)
        self.controller:on_recipe_button(recipe_name)
      end)
  end
end

local function add_group_flow(self, group)
  local scroll = self.picker_flow.add{
    name = group.name,
    type = "scroll-pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "auto-and-reserve-space",
  }
  scroll.style.width = 383
  self.group_flow = scroll
  local group_flow = scroll.add{
    type = "flow",
    direction = "vertical",
    style = "slot_table_spacing_vertical_flow",
  }

  for _, subgroup in ipairs(group.subgroups) do
    add_subgroup_flow(self, group_flow, subgroup)
  end
end

local function remove_group_flow(self)
  for _, subgroup_flow in ipairs(self.group_flow.children) do
    for _, recipe_button in ipairs(subgroup_flow.children) do
      Dispatcher.register(
        defines.events.on_gui_click,
        recipe_button,
        nil)
    end
  end
  self.group_flow.destroy()
  self.group_flow = nil
end

local function select_group(self, group_name)
  local current_group_flow = self.group_flow
  if current_group_flow and current_group_flow.name == group_name then return end

  if current_group_flow then
    self.groups_flow[current_group_flow.name].style = "image_tab_slot"
    remove_group_flow(self)
  end
  self.groups_flow[group_name].style = "image_tab_selected_slot"
  add_group_flow(self, self.groups[group_name])
end

local function add_groups_flow(self, groups)
  local flow = self.picker_flow.add{
    name = "groups",
    type = "flow",
    direction = "horizontal",
    style = "slot_table_spacing_horizontal_flow",
  }
  self.groups_flow = flow

  for _, group in ipairs(groups) do
    local group_name = group.name
    local group_button = flow.add{
      name = group_name,
      type = "sprite-button",
      style = "image_tab_slot",
      sprite = "item-group/"..group_name,
      tooltip = {"item-group-name."..group_name},
    }
    Dispatcher.register(
      defines.events.on_gui_click,
      group_button,
      function(event)
        select_group(self, group_name)
      end)
  end
end

local function remove_groups_flow(self)
  local groups_flow = self.picker_flow.groups
  for _, group_button in ipairs(groups_flow.children) do
    Dispatcher.register(
      defines.events.on_gui_click,
      group_button,
      nil)
  end
  groups_flow.destroy()
  self.groups_flow = nil
end

local comparator = function(a,b) return a.order < b.order end
local function flatten_and_sort_by_order(t)
  local i = 1
  for k,v in pairs(t) do
    t[i] = v
    t[k] = nil
    i = i + 1
  end
  table.sort(t, comparator)
end

local function group_recipes(recipes)
  local groups = {}
  for _, recipe in pairs(recipes) do
    local lua_group = recipe.group
    local group_name = lua_group.name
    local group = groups[group_name]
    if not group then
      group = {
        name = group_name,
        lua_group = lua_group,
        order = lua_group.order,
        subgroups = {},
      }
      groups[group_name] = group
    end

    local lua_subgroup = recipe.subgroup
    local subgroup_name = lua_subgroup.name
    local subgroups = group.subgroups
    local subgroup = subgroups[subgroup_name]
    if not subgroup then
      subgroup = {
        name = subgroup_name,
        lua_group = lua_subgroup,
        order = lua_subgroup.order,
        recipes = {},
      }
      subgroups[subgroup_name] = subgroup
    end

    local recipes = subgroup.recipes
    local recipe_name = recipe.name
    recipes[recipe_name] = {
      name = recipe_name,
      lua_recipe = recipe,
      order = recipe.order,
    }
  end

  for _, group in pairs(groups) do
    for _, subgroup in pairs(group.subgroups) do
      flatten_and_sort_by_order(subgroup.recipes)
    end
    flatten_and_sort_by_order(group.subgroups)
  end
  flatten_and_sort_by_order(groups)

  return groups
end

local RecipePickerView = {}

function RecipePickerView:set_controller(controller)
  self.controller = controller
end

function RecipePickerView:set_recipes(recipes)
  if self.group_flow then
    remove_group_flow(self)
  end
  if self.groups_flow then
    remove_groups_flow(self)
  end


  local groups = group_recipes(recipes)
  self.groups = groups
  if next(groups) then
    local initial_group_name = groups[1].name
    add_groups_flow(self, groups)
    reindex_by_name(groups)
    select_group(self, initial_group_name)
  end
end

local M = {}
local meta = { __index = RecipePickerView }

function M.new(parent)
  local self = {
    controller = nil,
    active_group = nil,
    picker_flow = nil,
    groups_flow = nil,
    group_flow = nil,
    groups = {},
  }
  create(self, parent)
  M.restore(self)
  return self
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
