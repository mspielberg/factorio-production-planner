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

local function model_from_line(line)
  local nsteps = #line.steps
  local components = component_rates(line)
  local coefficients = {}
  local constants = {}
  local out = { components = {} }

  for component, info in pairs(components) do
    out.components[#out.components+1] = component
    local row = {}
    for i = 1, #line.steps do
      row[i] = -(info.rates[i] or 0)
    end
    coefficients[#coefficients+1] = row

    constants[#constants+1] = -(line.constraints[component] or 0)
  end

  local costs = {}
  for i = 1, nsteps do
    costs[i] = -1
  end

  out.simplex = MySimplex.new(costs, coefficients, constants)
  return out
end

local function solve(line)
  local model = model_from_line(line)
  return MySimplex.solve(model.simplex)
end

return {
  model_from_line = model_from_line,
  solve = solve,
}