local Component = require "src.calc.Component"
local FAPI = require "src.api.FAPI"
local util = require "src.util"

---@class ComponentFlowSet
local ComponentFlowSet = {}

local new

function ComponentFlowSet:get_rate(component)
  return self[component] or 0
end

function ComponentFlowSet:add(component, rate)
  local new_rate = self:get_rate(component) + rate
  if new_rate == 0 then
    self[component] = nil
  else
    self[component] = new_rate
  end
end

-- @treturn ComponentFlowSet A new ComponentFlowSet with all rates multiplied by scalar.
function ComponentFlowSet:scale(scalar)
  local out = new()
  for component, rate in pairs(self) do
    out:add(component, rate * scalar)
  end
  return out
end

function ComponentFlowSet:has_ingredient(component)
  return self:get_rate(component) < 0
end

function ComponentFlowSet:has_product(component)
  return self:get_rate(component) > 0
end

function ComponentFlowSet:get_ingredients()
  local out = {}
  for component, rate in pairs(self) do
    if rate < 0 then out[component] = -rate end
  end
  return out
end

function ComponentFlowSet:get_products()
  local out = {}
  for component, rate in pairs(self) do
    if rate > 0 then out[component] = rate end
  end
  return out
end

local meta = { __index = ComponentFlowSet }

local function restore(self)
  return setmetatable(self, meta)
end

new = function()
  return restore({})
end

local function new_from_recipe_name(recipe_name)
  local proto = FAPI.get_recipe_prototype(recipe_name)
  if not proto then error ("unknown recipe name "..recipe_name) end
  local out = new()
  for _, ingredient in pairs(proto.ingredients) do
    out:add(Component.new(ingredient.type, ingredient.name), -ingredient.amount)
  end
  for _, product in pairs(proto.products) do
    local amount = (product.amount or (product.amount_max + product.amount_min) / 2)
      * (product.probability or 1)
    out:add(Component.new(product.type, product.name), amount)
  end
  return out
end


local function sum(flow_sets)
  local out = new()
  for _, flow_set in ipairs(flow_sets) do
    for component, rate in pairs(flow_set) do
      out:add(component, rate)
    end
  end
  return out
end

return {
  new = new,
  restore = restore,
  from_recipe_name = util.memoize(new_from_recipe_name),
  sum = sum,
}