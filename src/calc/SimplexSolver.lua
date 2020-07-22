local luasimplex = require "lualib.luasimplex.lua.luasimplex"
local rsm  = require "lualib.luasimplex.lua.luasimplex.rsm"

---Creates a table that always returns the same value for every index
local function const_table(const)
  local meta = {
    __index = function(self, index) return const end,
    __newindex = function(self, index, value) error("attempt to set value on const table") end,
  }
  return setmetatable({}, meta)
end

local zero_table = const_table(0)
local one_table = const_table(1)
local huge_table = const_table(math.huge)
local minushuge_table = const_table(-math.huge)

---@param line Line
---@return table<Component,table<number,number>>
local function component_rates(line)
  local out = {}
  for i, step in pairs(line.steps) do
    local flow_set = step:get_base_flow_set()
    for component, rate in pairs(flow_set) do
      if not out[component] then
        out[component] = {rates = {}}
      end
      out[component].rates[i] = rate
    end
  end
  return out
end

local function has_pos_and_neg(t)
  local pos = false
  local neg = false
  for _, v in pairs(t) do
    if v > 0 then pos = true end
    if v < 0 then neg = true end
    if pos and neg then return true end
  end
  return false
end

local function cost_for_input_flow(component, component_info)
  if has_pos_and_neg(component_info.rates) then
    if component:find("^fluid/") then return 100 end
    return 100
  end
  return 1
end

local function cost_for_output_flow(component, component_info)
  --[[
  if has_pos_and_neg(component_info.rates) then
    if component:find("^fluid/") then return 10 end
    return 1
  end
  --]]
  return 0
end

local function model_from_line(line)
  local components = component_rates(line)
  local slack_variable_index = #line.steps + 1
  local variable_indexes = {}
  local coefficients = {}
  local row_starts = {}
  local row_constraints = {}
  local costs = {}

  local row_components = {}

  -- one row per component
  local row_index = 1
  for component, component_info in pairs(components) do
    row_components[#row_components+1] = component
    component_info.row = row_index
    row_starts[#row_starts+1] = #variable_indexes + 1
    row_constraints[#row_constraints+1] = line.constraints[component] or 0
    costs[row_index] = 1

    -- one term per recipe with this component
    for step_index, rate in pairs(component_info.rates) do
      variable_indexes[#variable_indexes+1] = step_index
      coefficients[#coefficients+1] = rate
    end

    if not line.constraints[component] then
      -- slack terms for component
      variable_indexes[#variable_indexes+1] = slack_variable_index
      coefficients[#coefficients+1] = 1
      component_info.input_flow = slack_variable_index
      costs[slack_variable_index] = cost_for_input_flow(component, component_info)
      slack_variable_index = slack_variable_index + 1

      variable_indexes[#variable_indexes+1] = slack_variable_index
      coefficients[#coefficients+1] = -1
      component_info.output_flow = slack_variable_index
      costs[slack_variable_index] = cost_for_output_flow(component, component_info)
      slack_variable_index = slack_variable_index + 1
    end

    row_index = row_index + 1
  end
  row_starts[#row_starts+1] = #variable_indexes + 1

  assert(#variable_indexes == #coefficients)
  --assert(#row_starts == component_count + 1)
  --assert(slack_variable_index == #line.steps + component_count + 1)

  return {
    nvars = slack_variable_index - 1,
    nrows = #row_starts - 1,
    indexes = variable_indexes,
    elements = coefficients,
    row_starts = row_starts,
    c = costs,
    xl = zero_table,
    xu = huge_table,
    b = row_constraints,

    components = components,
    row_components = row_components,
  }
end

local function solve(line)
  local model = model_from_line(line)
  local instance = luasimplex.new_instance(model.nrows, model.nvars)
  rsm.initialise(model, instance, {})
  local objective, recipe_rates = rsm.solve(model, instance, {})
  print(objective)
  return recipe_rates, model
end

return {
  solve = solve,
}