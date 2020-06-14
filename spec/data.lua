local data = {}

data.petro_gas_line = {
  id = 1,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/crude-oil"] = 100 },
    },
    {
      id = 2,
      recipe = "advanced-oil-processing",
      constraints = { ["fluid/crude-oil"] = {1} },
    },
    {
      id = 3,
      recipe = "heavy-oil-cracking",
      constraints = { ["fluid/heavy-oil"] = {2} },
    },
    {
      id = 4,
      recipe = "light-oil-cracking",
      constraints = { ["fluid/light-oil"] = {2,3} },
    },
  },
}

data.plastic_line_demand_driven = {
  id = 2,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["item/plastic-bar"] = -15, }
    },
    {
      id = 2,
      type = "line",
      line_id = 1,
      constraints = { ["fluid/petroleum-gas"] = {3} }
    },
    {
      id = 3,
      recipe = "plastic-bar",
      constraints = { ["item/plastic-bar"] = {1} }
    },
  },
}

data.plastic_line_supply_driven = {
  id = 2,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/crude-oil"] = 100, }
    },
    {
      id = 2,
      type = "line",
      line_id = 1,
      constraints = { ["fluid/crude-oil"] = {1} }
    },
    {
      id = 3,
      recipe = "plastic-bar",
      constraints = { ["fluid/petroleum-gas"] = {2} }
    },
  },
}

return data