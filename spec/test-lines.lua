local out = {}

out.petro_gas_line = {
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

out.plastic_line_demand_driven = {
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

out.plastic_line_supply_driven = {
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

out.seablock_mineral_sludge_line = {
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["item/slag"] = 7.5 },
    },
    {
      id = 2,
      recipe = "slag-processing-dissolution",
      constraints = { ["item/slag"] = {1} },
    },
    {
      id = 3,
      recipe = "liquid-sulfuric-acid",
      constraints = { ["fluid/liquid-sulfuric-acid"] = {2} },
    },
    {
      id = 4,
      recipe = "gas-sulfur-dioxide",
      constraints = { ["fluid/gas-sulfur-dioxide"] = {3} },
    },
    {
      id = 5,
      recipe = "yellow-waste-water-purification",
      constraints = { ["fluid/water-yellow-waste"] = {6} },
    },
    {
      id = 6,
      recipe = "slag-processing-filtering-1",
      constraints = { ["fluid/slag-slurry"] = {2} },
    },
    {
      id = 7,
      recipe = "filter-coal",
      constraints = { ["item/filter-charcoal"] = {6} },
    },
  }
}

return out