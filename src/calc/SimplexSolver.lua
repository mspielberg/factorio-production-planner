local MySimplex = require "src.calc.MySimplex"
local Rational = require "src.calc.Rational"

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

local function table_size(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
  end
  return i
end

local function model_from_line(line)
  local nsteps = #line.steps
  local components = component_rates(line)
  local coefficients = {}
  local constants = {}
  local descriptions = {}

  for i=1,#line.steps do
    descriptions[i] = line.steps[i].recipe
  end

  local ncomponents = table_size(components)
  local nvars = ncomponents + #line.steps - table_size(line.constraints)

  local costs = {}
  for i = 1, #line.steps do
    costs[i] = -1
  end
  for i=#line.steps, nvars do
    costs[i] = -10
  end

  local slack_index = #line.steps
  for component, info in pairs(components) do
    local row = {}
    for i = 1, #line.steps do
      row[i] = -(info.rates[i] or 0)
    end
    for i = #line.steps + 1, nvars do
      row[i] = 0
    end
    if not line.constraints[component] then
      slack_index = slack_index + 1
      row[slack_index] = -1
      if has_pos_and_neg(info.rates) then
        costs[slack_index] = -1e3
      end
      descriptions[slack_index] = "input_"..component
    end
    coefficients[#coefficients+1] = row

    constants[#constants+1] = -(line.constraints[component] or 0)
  end

  component_index = slack_index
  for component in pairs(components) do
    component_index = component_index + 1
    descriptions[component_index] = "excess_"..component
  end

  local out = MySimplex.new(costs, coefficients, constants)
  out.descriptions = descriptions
  return out
end

local function solve(line, trace)
  local model = model_from_line(line)
  return MySimplex.solve(model, nil, trace)
end

return {
  model_from_line = model_from_line,
  solve = solve,
}