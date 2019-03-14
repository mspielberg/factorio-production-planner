local function create(self, parent)
  self.gui = parent.add{
    name = "recipe_picker",
    type = "scroll-pane",
    horizontal_scroll_policy = "never",
    vertical_scroll_policy = "auto-and-reserve-space",
  }
  self.gui.style = "scroll_pane_under_subheader"
  self.gui.style.horizontally_squashable = false
  self.gui.style.vertically_squashable = false

  local groups_table = self.gui.add{
    name = "groups",
    type = "table",
    column_count = 6,
    style = "slot_table",
  }
  groups_table.enabled = false

  local group_flow = self.gui.add{
    name = "subgroups",
    type = "flow",
    direction = "vertical",
    style = "slot_table_spacing_vertical_flow",
  }
  group_flow.style.minimal_width = 378
  group_flow.enabled = false
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
  end
end

local function fill_subgroups_flow(self, group)
  local subgroups_flow = self.gui.subgroups
  subgroups_flow.clear()
  for _, subgroup in ipairs(group.subgroups) do
    add_subgroup_flow(self, subgroups_flow, subgroup)
  end
end

local function fill_groups_table(self, groups)
  local groups_table = self.gui.groups
  groups_table.clear()
  for _, group in ipairs(groups) do
    local group_name = group.name
    local group_button = groups_table.add{
      name = group_name,
      type = "sprite-button",
      style = "image_tab_slot",
      sprite = "item-group/"..group_name,
      tooltip = {"item-group-name."..group_name},
    }
  end
end

local function compare_by_order(a, b) return a.order < b.order end
local function flatten_and_sort_by_order(t)
  local i = 1
  for k,v in pairs(t) do
    t[i] = v
    t[k] = nil
    i = i + 1
  end
  table.sort(t, compare_by_order)
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
        order = lua_subgroup.order,
        recipes = {},
      }
      subgroups[subgroup_name] = subgroup
    end

    local recipe_name = recipe.name
    subgroup.recipes[recipe_name] = {
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

local RecipePickerFlow = {}

function RecipePickerFlow:set_recipes(recipes)
  local groups = group_recipes(recipes)
  self.groups = groups
  local initial_group = groups[1]
  fill_groups_table(self, groups)
  reindex_by_name(groups)
  if initial_group then
    self:select_group(initial_group.name)
  else
    -- no recipes
    self.gui.subgroups.clear()
  end
end

function RecipePickerFlow:select_group(group_name)
  for _, button in pairs(self.gui.groups.children) do
    button.style = "image_tab_slot"
  end
  self.gui.groups[group_name].style = "image_tab_selected_slot"
  fill_subgroups_flow(self, self.groups[group_name])
end


local M = {}
local meta = { __index = RecipePickerFlow }

function M.new(parent)
  local self = {
    gui = nil,
    groups = {},
  }
  create(self, parent)
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

return M
