-- see https://www.matem.unam.mx/~omar/math340/simplex-intro.html
local Rational = require "src.calc.Rational"

local function new(costs, coefficients, constants)
  --[[
    bv === basic_vars
    nb === nonbasic_vars

    bv[1] = constants[1] + coefficients[1][1] * nb[1] + coefficients[1][2] * nb[2] + ...
    bv[2] = constants[2] + coefficients[2][1] * nb[1] + coefficients[2][2] * nb[2] + ...
    ...
    obj   = constants[n] + coefficients[n][1] * nb[1] + coefficients[n][2] * nb[2] + ...
  --]]
  local self = {
    basic_vars = {},    -- row i of coefficients and constants matches to x_basic_vars[i]
    nonbasic_vars = {}, -- column i of coefficients matches to x_nonbasic_vars[i]
    constants = {},
    coefficients = {},
  }

  local nconstraints = #coefficients
  local nvars = #coefficients[1]
  for i = 2, nconstraints do
    assert(#coefficients[i] == nvars)
  end

  for i=1, nconstraints+1 do
    self.basic_vars[i] = nvars + i
    self.coefficients[i] = {}
  end
  self.basic_vars[nconstraints+1] = nil

  for i=1,nvars do
    self.nonbasic_vars[i] = i
  end

  for i, cost_coeff in ipairs(costs) do
    self.coefficients[#self.coefficients][i] = Rational(cost_coeff)
  end
  for row_index, row in ipairs(coefficients) do
    self.coefficients[row_index] = {}
    for i, coeff in ipairs(row) do
      self.coefficients[row_index][i] = Rational(-coeff)
    end
  end
  for i, constant in ipairs(constants) do
    self.constants[i] = Rational(constant)
  end
  self.constants[#self.constants+1] = Rational(0)

  return self
end

local function is_feasible(self)
  local t = self.constants
  for i = 1,#t - 1 do
    if t[i] < 0 then
      return false
    end
  end
  return true
end

local function select_entering_variable_anstee(self)
  local z_row = self.coefficients[#self.coefficients]
  local current_column_index
  local current_var_index
  local current_coeff = 0
  for i, candidate_coeff in ipairs(z_row) do
    local var_index = self.nonbasic_vars[i]
    if candidate_coeff > 0 and (
    current_coeff < candidate_coeff or
    current_coeff == candidate_coeff and var_index < current_var_index) then
      current_column_index = i
      current_var_index = var_index
      current_coeff = candidate_coeff
    end
  end
  return current_column_index
end

local function select_entering_variable_bland(self)
  local z_row = self.coefficients[#self.coefficients]
  local current_column_index
  local current_var_index = math.huge
  for i, candidate_coeff in ipairs(z_row) do
    local var_index = self.nonbasic_vars[i]
    if candidate_coeff > 0 and current_var_index > var_index then
      current_column_index = i
      current_var_index = var_index
    end
  end
  return current_column_index
end

local function select_exiting_variable(self, entering_column_index)
  local most_pessimistic = math.huge
  local exiting_row_index
  local exiting_variable_index
  for i=1, #self.coefficients-1 do
    if self.coefficients[i][entering_column_index] ~= 0 then
      local can_increase_by = self.constants[i] / -self.coefficients[i][entering_column_index]
      local candidate_variable_index = self.basic_vars[i]
      if can_increase_by > 0 and
      (can_increase_by < most_pessimistic or
        can_increase_by == most_pessimistic and candidate_variable_index < exiting_variable_index) then
        exiting_row_index = i
        most_pessimistic = can_increase_by
        exiting_variable_index = candidate_variable_index
      end
    end
  end
  return exiting_row_index
end

local function pivot(self, entering_column_index, exiting_row_index)
  -- solve for entering variable
  local entering_coeff = self.coefficients[exiting_row_index][entering_column_index]
  self.constants[exiting_row_index] = self.constants[exiting_row_index] / -entering_coeff
  for i=1,#self.nonbasic_vars do
    self.coefficients[exiting_row_index][i] = self.coefficients[exiting_row_index][i] / -entering_coeff
  end
  self.coefficients[exiting_row_index][entering_column_index] = 1 / entering_coeff

  -- substitute in
  for row_index = 1, #self.coefficients do
    if row_index ~= exiting_row_index then
      local scalar = self.coefficients[row_index][entering_column_index]
      self.constants[row_index] = self.constants[row_index] +
        self.constants[exiting_row_index] * scalar
      for col_index = 1, #self.nonbasic_vars do
        if col_index == entering_column_index then
          self.coefficients[row_index][col_index] =
            self.coefficients[exiting_row_index][entering_column_index] * scalar
        else
          self.coefficients[row_index][col_index] = self.coefficients[row_index][col_index] +
            self.coefficients[exiting_row_index][col_index] * scalar
        end
      end
    end
  end

  -- rename variables
  self.basic_vars[exiting_row_index], self.nonbasic_vars[entering_column_index] =
    self.nonbasic_vars[entering_column_index], self.basic_vars[exiting_row_index]
end

local function extract_results(self)
  local out = {}
  for i=1, #self.basic_vars do
    out[self.basic_vars[i]] = self.constants[i]
  end
  for i=1, #self.nonbasic_vars do
    out[self.nonbasic_vars[i]] = Rational(0)
  end
  return out, self.constants[#self.constants]
end

local function find_min(t)
  local min = math.huge
  local index
  for i=1,#t do
    if t[i] < min then
      min = t[i]
      index = i
    end
  end
  return index
end

local solve
local function phase1(self)
  if is_feasible(self) then return end

  local original_costs = self.coefficients[#self.coefficients]
  local nvars = #self.nonbasic_vars

  -- augment with x0
  self.nonbasic_vars[nvars+1] = 0
  for i=1,#self.coefficients do
    self.coefficients[i][nvars+1] = Rational(1)
  end

  -- adjust objective function
  local temp_objective = {}
  for i=1,nvars do temp_objective[i] = Rational(0) end
  temp_objective[nvars+1] = Rational(-1)
  self.coefficients[#self.coefficients] = temp_objective

  -- special pivot
  pivot(self, nvars+1, find_min(self.constants))
  assert(is_feasible(self))
  solve(self)
end

solve = function(self)
  phase1(self)
  local entering_column_index = select_entering_variable_anstee(self)
  while entering_column_index do
    local exiting_row_index = select_exiting_variable(self, entering_column_index)
    if not exiting_row_index then error("unbounded") end
    pivot(self, entering_column_index, exiting_row_index)
    entering_column_index = select_entering_variable_anstee(self)
  end
  return extract_results(self)
end

return {
  new = new,
  pivot = pivot,
  select_entering_variable = select_entering_variable_anstee,
  select_exiting_variable = select_exiting_variable,
  solve = solve,
}