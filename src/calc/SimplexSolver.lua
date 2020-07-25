local MySimplex = require "src.calc.MySimplex"
local Rational = require "src.calc.Rational"

---@param line Line
---@return table<Component,table<number,number>>
local function component_rates(line)
  local rates = {}
  for i, step in pairs(line.steps) do
    local flow_set = step:get_base_flow_set()
    for component, rate in pairs(flow_set) do
      if not rates[component] then
        rates[component] = {}
      end
      rates[component][i] = rate
    end
  end
  -- sort by name

  local out = {}
  for k,v in pairs(rates) do
    out[#out+1] = {k, v}
  end
  table.sort(out, function(a,b) return a[1] < b[1] end)
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

local function model_from_line(line, cost_overrides)
  cost_overrides = cost_overrides or {}

  local nsteps = #line.steps
  local components = component_rates(line)
  local coefficients = {}
  local constants = {}
  local descriptions = {}

  for i=1,nsteps do
    descriptions[i] = line.steps[i].recipe
  end

  local ncomponents = #components
  local nvars = ncomponents + nsteps - table_size(line.constraints)

  local costs = {}
  for i = 1, nsteps do
    costs[i] = -1
  end
  for i=nsteps, nvars do
    costs[i] = -100
  end

  local slack_index = nsteps
  for _, info in ipairs(components) do
    local component = info[1]
    local rates = info[2]
    local row = {}
    for i = 1, nsteps do
      row[i] = -(rates[i] or 0)
    end
    for i = nsteps + 1, nvars do
      row[i] = 0
    end
    if not line.constraints[component] then
      slack_index = slack_index + 1
      row[slack_index] = -1
      if cost_overrides[component] then
        costs[slack_index] = cost_overrides[component]
      elseif has_pos_and_neg(rates) then
        costs[slack_index] = -1e9
      end
      descriptions[slack_index] = "input_"..component
    end
    coefficients[#coefficients+1] = row

    constants[#constants+1] = -(line.constraints[component] or 0)
  end

  local component_index = slack_index
  for _, component in pairs(components) do
    component_index = component_index + 1
    descriptions[component_index] = "excess_"..component[1]
  end

  local out = MySimplex.new(costs, coefficients, constants)
  out.costs = costs
  out.descriptions = descriptions
  return out
end

local function solve(line, cost_overrides, trace)
  local model = model_from_line(line, cost_overrides)
  return MySimplex.solve(model, nil, trace), model
end

return {
  model_from_line = model_from_line,
  solve = solve,
}