local inspect = require "inspect"

local function allowed_by_limitations(item_proto, recipe_name)
  if item_proto.type ~= "module" then return false end
  local limitations = item_proto.limitations

  if not next(limitations) then return true end
  for _, allowed in pairs(limitations) do
    if recipe_name == allowed then
      return true
    end
  end

  return false
end

local function allowed_in_machine(self, recipe_name)
  local out = {}
  local allowed_effects = game.entity_prototypes[self.name].allowed_effects
  for item_name, proto in pairs(game.item_prototypes) do
    if allowed_by_limitations(proto, recipe_name) then
      local all_effects_allowed = true
      for effect_type in pairs(proto.module_effects) do
        if not allowed_effects[effect_type] then
          all_effects_allowed = false
        end
      end
      if all_effects_allowed then
        out[#out+1] = item_name
      end
    end
  end
  table.sort(out)
  return out
end

local function allowed_in_beacon(allowed_by_crafting_machine, beacon_name)
  local allowed_effects = game.entity_prototypes[beacon_name].allowed_effects
  local allowed_by_beacon = {}
  for _, module_name in ipairs(allowed_by_crafting_machine) do
    local proto = game.item_prototypes[module_name]
    local all_effects_allowed = true
    for effect_type in pairs(proto.module_effects) do
      if not allowed_effects[effect_type] then
        all_effects_allowed = false
      end
    end
    if all_effects_allowed then
      allowed_by_beacon[#allowed_by_beacon+1] = module_name
    end
  end
  return allowed_by_beacon
end

local function beacon_bonuses(self)
  local beacon_info = self.beacon_info
  if not beacon_info then
    return 0, 0
  end

  local multiplier = beacon_info.count * beacon_info.module_count *
    game.entity_prototypes[beacon_info.name].distribution_effectivity
  local effects = game.item_prototypes[beacon_info.module_name].module_effects

  local total_beacon_speed_bonus =
    effects.speed and effects.speed.bonus * multiplier or 0
  local total_beacon_productivity_bonus =
    effects.productivity and effects.productivity.bonus * multiplier or 0

  return total_beacon_speed_bonus, total_beacon_productivity_bonus
end

local function module_tooltip(self)
  local out = {""}
  for name, info in pairs(self.modules) do
    out[#out+1] = {
      "planner-gui.module-line",
      info.count,
      game.item_prototypes[name].localised_name,
    }
    out[#out+1] = "\n"
  end
  return out
end

local function beacon_tooltip(self)
  local beacon_info = self.beacon_info
  if beacon_info then
    return {
      "planner-gui.beacon-line",
      beacon_info.count,
      game.entity_prototypes[beacon_info.name].localised_name,
      beacon_info.module_count,
      game.item_prototypes[beacon_info.module_name].localised_name,
    }
  end
  return ""
end

local CraftingMachine = {}

function CraftingMachine:allowed_modules(recipe_name, beacon_name)
  local allowed_by_crafting_machine = allowed_in_machine(self, recipe_name)
  local allowed_in_beacon =
    beacon_name and allowed_in_beacon(allowed_by_crafting_machine, beacon_name)
  return {
    allowed_by_crafting_machine = allowed_by_crafting_machine,
    allowed_by_beacon           = allowed_in_beacon,
  }
end

function CraftingMachine:effective_speed()
  local total_beacon_speed_bonus, total_beacon_productivity_bonus = beacon_bonuses(self)
  local speed_multiplier = 1 + total_beacon_speed_bonus
  local productivity_multiplier = 1 + total_beacon_productivity_bonus
  for _, module in pairs(self.modules) do
    speed_multiplier = speed_multiplier +
      (module.count * module.speed_bonus)
    productivity_multiplier = productivity_multiplier +
      (module.count * module.productivity_bonus)
  end
  return self.base_speed * speed_multiplier * productivity_multiplier
end

function CraftingMachine:set_module_count(name, count)
  if count == 0 then
    self.modules[name] = nil
  elseif self.modules[name] then
    self.modules[name].count = count
  else
    local proto = game.item_prototypes[name]
    local effects = proto.module_effects
    self.modules[name] = {
      speed_bonus = effects.speed and effects.speed.bonus or 0,
      productivity_bonus = effects.productivity and effects.productivity.bonus or 0,
      count = count,
    }
  end
end

function CraftingMachine:set_beacon_count(beacon_name, beacon_count, module_name, module_count)
  if beacon_count and beacon_count > 0 and module_count and module_count > 0 then
    self.beacon_info = {
      name = beacon_name,
      count = beacon_count,
      module_name = module_name,
      module_count = module_count,
    }
  else
    self.beacon_info = nil
  end
end

function CraftingMachine:tooltip()
  local proto = game.entity_prototypes[self.name]
  return {
    "planner-gui.crafting-machine-tooltip",
    proto.localised_name,
    proto.crafting_speed,
    self:effective_speed(),
    module_tooltip(self),
    beacon_tooltip(self),
  }
end

local M = {}
local meta = { __index = CraftingMachine }

function M.new(name)
  local self = {
    name = name,
    base_speed = game.entity_prototypes[name].crafting_speed,
    modules = {}, -- = { [module_name] = count, ... }
    beacon_info = nil, -- = { name = "beacon", count = 1, module_name = "speed-module-1", module_count = 2 }
    beacon_speed_bonus = 0,
    beacon_productivity_bonus = 0,
  }
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

function M.default_for(recipe)
  local proto = game.recipe_prototypes[recipe.name]
  local category = proto.category
  for _, entity_proto in pairs(game.entity_prototypes) do
    if entity_proto.crafting_categories
    and entity_proto.crafting_categories[category] then
      return M.new(entity_proto.name)
    end
  end
end

local entity_names_for_category_cache = {}
function M.entity_names_for_category(category_name)
  local entity_names = entity_names_for_category_cache[category_name]
  if not entity_names then
    entity_names = {}
    for entity_name, entity_proto in pairs(game.entity_prototypes) do
      if entity_proto.crafting_categories
      and entity_proto.crafting_categories[category] then
        entity_names[#entity_names+1] = entity_name
      end
    end
    entity_names_for_category_cache[category_name] = entity_names
  end

  return entity_names
end

return M