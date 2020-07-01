local FAPI = require "src.api.FAPI"
local util = require "src.util"

local function allowed_by_limitations(module_proto, recipe_name)
  local limitations = module_proto.limitations
  return not limitations or util.find(limitations, recipe_name) ~= nil
end

---@return table<string,LuaItemPrototype[]> a map from names to prototypes
local function modules_allowed_in_entity(entity_proto)
  if entity_proto.module_inventory_size == 0 then return {} end
  local allowed_effects = entity_proto.allowed_effects
  local out = {}
  for module_name, module_proto in pairs(FAPI.get_module_prototypes()) do
    for effect_type in pairs(module_proto.module_effects) do
      if not allowed_effects[effect_type] then
        goto continue
      end
    end
    out[module_name] = module_proto
    ::continue::
  end
  return out
end

---@return table<string,LuaItemPrototype[]> a map from names to prototypes
local function modules_allowed_by_recipe(entity_proto, recipe_name)
  local out = {}
  for module_name, module_proto in pairs(modules_allowed_in_entity(entity_proto)) do
    if allowed_by_limitations(module_proto, recipe_name) then
      out[module_name] = module_proto
    end
  end
  return out
end

---@return number, number speed_bonus, productivity_bonus
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

local CraftingMachine = {}

---@return string | "crafting-category" | 
function CraftingMachine:can_craft_recipe(recipe_name)
  local recipe_proto = FAPI.get_recipe_prototype(recipe_name)
  local crafting_machine_prototype = FAPI.get_entity_prototype(self.entity_name)
  if not crafting_machine_prototype.crafting_categories[recipe_proto.category] then return "crafting-category" end
  local allowed_in_crafting_machine = modules_allowed_by_recipe(crafting_machine_prototype, recipe_name)
  for module_name in pairs(self.modules) do
    if not allowed_in_crafting_machine[module_name] then return false end
  end
  if self.beacon_info then
    local beacon_proto = FAPI.get_entity_prototype(self.beacon_info.name)
    local allowed_in_beacons = modules_allowed_in_entity(beacon_proto)
    if self.beacon_info.module_name and not allowed_in_beacons[self.beacon_info.name] then return false end
  end
  return true
end

function CraftingMachine:allowed_modules(recipe_name)
  local allowed_by_crafting_machine =
    modules_allowed_by_recipe(FAPI.get_entity_prototype(self.entity_name), recipe_name)
  local allowed_in_beacon = self.beacon_info
      and modules_allowed_by_recipe(FAPI.get_entity_prototype(self.beacon_info.name), recipe_name)
  return {
    allowed_by_crafting_machine = allowed_by_crafting_machine,
    allowed_by_beacon           = allowed_in_beacon,
  }
end

function CraftingMachine:effective_speed()
  local total_beacon_speed_bonus, total_beacon_productivity_bonus = beacon_bonuses(self)
  local speed_multiplier = 1 + total_beacon_speed_bonus
  local productivity_multiplier = 1 + total_beacon_productivity_bonus
  local module_prototypes = FAPI.get_module_prototypes()
  for name, count in pairs(self.modules) do
    local proto = module_prototypes[name]
    if proto.effects.speed then
      speed_multiplier = speed_multiplier + (count * proto.effects.speed.bonus)
    end
    if proto.effects.productivity then
      productivity_multiplier = productivity_multiplier + (count * proto.effects.productivity.bonus)
    end
  end
  return FAPI.get_entity_prototype(self.entity_name).crafting_speed *
    speed_multiplier * productivity_multiplier
end

function CraftingMachine:set_entity_name(name)
  self.entity_name = name
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

local M = {}

local meta = { __index = CraftingMachine }

function meta.__eq(a, b)
  if getmetatable(a) ~= meta or getmetatable(b) ~= meta then return false end
  if a.entity_name ~= b.entity_name then return false end
  if (a.modules == nil) ~= (b.modules == nil) then return false end
  if a.modules and b.modules then
    for module_name, count in pairs(a.modules) do
      if b.modules[module_name] ~= count then return false end
    end
  end
  if (a.beacon_info == nil) ~= (b.beacon_info == nil) then return false end
  if a.beacon_info and b.beacon_info then
    if a.beacon_info.name ~= b.beacon_info.name
    or a.beacon_info.count ~= b.beacon_info.count
    or a.beacon_info.module_name ~= b.beacon_info.module_name
    or a.beacon_info.module_count ~= b.beacon_info.module_count then
      return false
    end
  end
  return true
end


function M.new(entity_name)
  local self = {
    entity_name = entity_name,
    modules = {}, -- = { [module_name] = count, ... }
    beacon_info = nil, -- = { name = "beacon", count = 1, module_name = "speed-module-1", module_count = 2 }
  }
  return M.restore(self)
end

function M.restore(self)
  return setmetatable(self, meta)
end

function M.default_for(recipe)
  local proto = FAPI.get_recipe_prototype(recipe.name)
  local category = proto.category
  for entity_name, entity_proto in pairs(FAPI.get_crafting_machine_prototypes()) do
    if entity_proto.crafting_categories[category] then
      return M.new(entity_name)
    end
  end
end

return M