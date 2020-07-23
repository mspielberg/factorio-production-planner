-- see https://www.matem.unam.mx/~omar/math340/simplex-intro.html
local Rational = require "src.calc.Rational"
if not serpent then serpent = require "serpent" end

local function dump_model(model)
  local rows = {}
  for i, row in ipairs(model.coefficients) do
    local row_info = {("%6s"):format(tostring(model.constants[i]))}
    for j, term in ipairs(row) do
      row_info[#row_info+1] = ("%8s x%-2d"):format(tostring(term), model.nonbasic_vars[j])
    end
    local terms = table.concat(row_info, " + ")
    rows[#rows+1] = ("%4s = %-90s"):format(
      tostring(model.basic_vars[i] and "x"..model.basic_vars[i] or "Obj"),
      terms
    )
  end
  return table.concat(rows, "\n")
end


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
    basic_vars          = {}, -- row i of coefficients and constants contains var i
    basic_vars_index    = {}, -- var i is found in row basic_vars_index[i]
    nonbasic_vars       = {}, -- column i of coefficients contains var i
    nonbasic_vars_index = {}, -- var i is found in column nonbasic_vars_index[i]
    constants           = {},
    coefficients        = {},
  }

  local nconstraints = #coefficients
  local nvars = #coefficients[1]

  for i = 1, nconstraints do
    self.basic_vars[i] = nvars + i
    self.basic_vars_index[nvars + i] = i
  end
  for i = 1, nvars do
    self.nonbasic_vars[i] = i
    self.nonbasic_vars_index[i] = i
  end

  for row_index, row in ipairs(coefficients) do
    assert(#row == nvars)
    self.coefficients[row_index] = {}
    for i, coeff in ipairs(row) do
      self.coefficients[row_index][i] = Rational(-coeff)
    end
  end

  for i, constant in ipairs(constants) do
    self.constants[i] = Rational(constant)
  end

  local objective_row = {}
  for i, cost_coeff in ipairs(costs) do
    objective_row[i] = Rational(cost_coeff)
  end
  self.coefficients[nconstraints+1] = objective_row
  self.constants[nconstraints+1] = Rational(0)

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

local zero = Rational(0)
local function select_exiting_variable(self, entering_column_index)
  local most_pessimistic = math.huge
  local exiting_row_index
  local exiting_variable_index

  local function is_improvement_on(candidate, candidate_index)
    return candidate >= zero and
    (most_pessimistic == nil or
      candidate < most_pessimistic or
      candidate == most_pessimistic and candidate_index < exiting_variable_index)
  end

  for i=1, #self.coefficients-1 do
    local coeff = self.coefficients[i][entering_column_index]
    if coeff < Rational(0) then
      local can_increase_by = self.constants[i] / -coeff
      local candidate_variable_index = self.basic_vars[i]
      if is_improvement_on(can_increase_by, candidate_variable_index) then
        exiting_row_index = i
        most_pessimistic = can_increase_by
        exiting_variable_index = candidate_variable_index
      end
    end
  end
  return exiting_row_index
end

local function invert_table(t)
  local out = {}
  for k,v in pairs(t) do
    out[v] = k
  end
  return out
end

local function swap_variables(self, entering_var_index, exiting_var_index)
  local exiting_row_index = self.basic_vars_index[exiting_var_index]
  local entering_column_index = self.nonbasic_vars_index[entering_var_index]

  self.basic_vars_index[entering_var_index] = exiting_row_index
  self.basic_vars_index[exiting_var_index] = nil

  self.nonbasic_vars_index[entering_var_index] = nil
  self.nonbasic_vars_index[exiting_var_index] = entering_column_index

  self.basic_vars[exiting_row_index], self.nonbasic_vars[entering_column_index] =
    self.nonbasic_vars[entering_column_index], self.basic_vars[exiting_row_index]
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
  for row_index, row in ipairs(self.coefficients)do
    if row_index ~= exiting_row_index then
      local scalar = row[entering_column_index]
      self.constants[row_index] = self.constants[row_index] +
        self.constants[exiting_row_index] * scalar
      for col_index = 1, #self.nonbasic_vars do
        if col_index == entering_column_index then
          row[col_index] =
            self.coefficients[exiting_row_index][entering_column_index] * scalar
        else
          row[col_index] = row[col_index] +
            self.coefficients[exiting_row_index][col_index] * scalar
        end
      end
    end
  end

  local old_nonbasic_vars = {}
  for i = 1, #self.nonbasic_vars do
    old_nonbasic_vars[i] = self.nonbasic_vars[i]
  end

  -- rename variables
  local entering_var_index = self.nonbasic_vars[entering_column_index]
  local exiting_var_index = self.basic_vars[exiting_row_index]
  swap_variables(self, entering_var_index, exiting_var_index)
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

local function regenerate_objective(self, original_costs)
  local new_objective_constant = Rational(0)
  local new_objective_coefficients = {}
  for original_var_index, original_coefficient in ipairs(original_costs) do
    local row_index = self.basic_vars_index[original_var_index]
    if row_index then
      -- now basic, need to substitute
      new_objective_constant = new_objective_constant + self.constants[row_index] * original_coefficient
      for col_index, coeff in ipairs(self.coefficients[row_index]) do
        new_objective_coefficients[col_index] = (new_objective_coefficients[col_index] or Rational(0)) +
          coeff * original_coefficient
      end
    else
      -- still nonbasic, copy over
      local new_col_index = self.nonbasic_vars_index[original_var_index]
      new_objective_coefficients[new_col_index] =
        new_objective_coefficients[new_col_index] + original_coefficient
    end
  end

  self.constants[#self.constants] = new_objective_constant
  self.coefficients[#self.coefficients] = new_objective_coefficients
end

local solve
local function phase1(self)
  if is_feasible(self) then return end

  -- save original objective function based on nonbasic vars nvars+1, nvars+2, ...
  local original_costs = self.coefficients[#self.coefficients]
  local nvars = #self.nonbasic_vars

  -- setup temporary objective function
  local temp_objective = {}
  for i=1,nvars do temp_objective[i] = Rational(0) end
  temp_objective[nvars+1] = Rational(-1)
  self.coefficients[#self.coefficients] = temp_objective

  -- augment with x0
  self.nonbasic_vars[nvars+1] = 0
  self.nonbasic_vars_index[0] = nvars+1
  for i=1,#self.coefficients-1 do
    self.coefficients[i][nvars+1] = Rational(1)
  end

  if self.trace then
    print("\nAugmented:")
    print(dump_model(self))
  end

  -- special pivot
  if self.trace then
    local exiting = find_min(self.constants)
    print(string.format("\npivot to feasibility: entering: x0, exiting: x%d",
      self.basic_vars[exiting]))
  end
  pivot(self, nvars+1, find_min(self.constants))
  if self.trace then
    print(dump_model(self))
  end
  assert(is_feasible(self))
  solve(self)

  if self.constants[#self.constants] < Rational(0) then
    error("infeasible")
  end

  -- strip x0
  local col_index = self.nonbasic_vars_index[0]
  for _, row in pairs(self.coefficients) do
    table.remove(row, col_index)
  end
  for i = col_index, #self.nonbasic_vars do
    self.nonbasic_vars[i] = self.nonbasic_vars[i+1]
  end
  self.nonbasic_vars_index = invert_table(self.nonbasic_vars)

  regenerate_objective(self, original_costs)

  if self.trace then
    print("\nAfter phase 1")
    print(dump_model(self))
  end
end

solve = function(self, max_iterations)
  max_iterations = max_iterations or 1000

  phase1(self)

  local iterations = 0
  local entering_column_index = select_entering_variable_bland(self)
  while entering_column_index do
    local exiting_row_index = select_exiting_variable(self, entering_column_index)
    iterations = iterations + 1
    if not exiting_row_index then error("unbounded") end
    if self.trace then
      print(string.format("iteration %d: entering: x%d, exiting: x%d",
        iterations,
        self.nonbasic_vars[entering_column_index],
        self.basic_vars[exiting_row_index]))
    end
    pivot(self, entering_column_index, exiting_row_index)
    if self.trace then
      print(dump_model(self))
    end
    if iterations >= max_iterations then error("too many iterations") end
    entering_column_index = select_entering_variable_bland(self)
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