local ComponentFlowSet = require "src.calc.ComponentFlowSet"
local Step = require "src.calc.Step"

local RecipeStep = setmetatable({}, { __index = Step.meta })

local meta = { __index = RecipeStep }

local function restore(self)
  return setmetatable(self, meta)
end

local function new(recipe_name)
  local self = {
    recipe = recipe_name,
    constraints = {},
  }
  return restore(self)
end

function RecipeStep:get_base_flow_set()
  return ComponentFlowSet.from_recipe_name(self.recipe)
end

Step.subclass_restore["recipe"] = restore
Step.subclass_restore.default = restore

return {
  new = new,
  restore = restore,
}