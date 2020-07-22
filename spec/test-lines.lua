local out = {}

out.green_circuits = {
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["item/electronic-circuit"] = -5 },
    },
    {
      id = 2,
      recipe = "electronic-circuit",
      constraints = {
        ["item/electronic-circuit"] = { 1 },
      }
    },
    {
      id = 3,
      recipe = "copper-cable",
      constraints = {
        ["item/copper-cable"] = { 2 },
      }
    },
  }
}

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

out.geode_loop = {}

out.geode_loop.full = {
  id = 1,
  steps = {
    { id = 1, recipe = "solid-geodes", },
    { id = 8, recipe = "geode-blue-liquify", },
    { id = 9, recipe = "geode-cyan-liquify", },
    { id = 10, recipe = "geode-red-liquify", },
    { id = 2, recipe = "crystal-slurry-filtering-conversion-1", },
    { id = 5, recipe = "geode-blue-processing", },
    { id = 6, recipe = "geode-cyan-processing", },
    { id = 7, recipe = "geode-red-processing", },
    { id = 4, recipe = "water-mineralized", },
    { id = 11, recipe = "crystal-dust-liquify", },
    { id = 3, recipe = "yellow-waste-water-purification", },
  }
}

out.geode_loop.sludge = {
  id = 1,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 6,
      recipe = "crystal-slurry-filtering-conversion-1",
      constraints = { ["fluid/mineral-sludge"] = { 1 }, },
    },
    {
      id = 7,
      recipe = "yellow-waste-water-purification",
      constraints = { ["fluid/water-yellow-waste"] = { 6 }},
    },
  },
}

out.geode_loop.blue_processing = {
  id = 2,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/water-mineralized"] = -100 },
    },
    {
      id = 2,
      recipe = "water-mineralized",
      constraints = { ["fluid/water-mineralized"] = { 1 }},
    },
    {
      id = 3,
      recipe = "geode-blue-processing",
      constraints = { ["item/stone-crushed"] = { 2 }},
    },
    {
      id = 4,
      recipe = "crystal-dust-liquify",
      constraints = { ["item/crystal-dust"] = { 3 }},
    },
  }
}

out.geode_loop.cyan_processing = {
  id = 3,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/water-mineralized"] = -100 },
    },
    {
      id = 2,
      recipe = "water-mineralized",
      constraints = { ["fluid/water-mineralized"] = { 1 }},
    },
    {
      id = 3,
      recipe = "geode-cyan-processing",
      constraints = { ["item/stone-crushed"] = { 2 }},
    },
    {
      id = 4,
      recipe = "crystal-dust-liquify",
      constraints = { ["item/crystal-dust"] = { 3 }},
    },
  }
}

out.geode_loop.red_processing = {
  id = 4,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/water-mineralized"] = -100 },
    },
    {
      id = 2,
      recipe = "water-mineralized",
      constraints = { ["fluid/water-mineralized"] = { 1 }},
    },
    {
      id = 3,
      recipe = "geode-red-processing",
      constraints = { ["item/stone-crushed"] = { 2 }},
    },
    {
      id = 4,
      recipe = "crystal-dust-liquify",
      constraints = { ["item/crystal-dust"] = { 3 }},
    },
  }
}

out.geode_loop.blue_sludge = {
  id = 5,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 1,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      type = "line",
      line_id = 2,
      constraints = { ["fluid/water-mineralized"] = {2} }
    },
  }
}

out.geode_loop.cyan_sludge = {
  id = 6,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 1,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      type = "line",
      line_id = 3,
      constraints = { ["fluid/water-mineralized"] = {2} }
    },
  }
}

out.geode_loop.red_sludge = {
  id = 7,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 1,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      type = "line",
      line_id = 4,
      constraints = { ["fluid/water-mineralized"] = {2} }
    },
  }
}

out.geode_loop.blue_slurry = {
  id = 8,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 5,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      recipe = "geode-blue-liquify",
      constraints = { ["fluid/crystal-slurry"] = {2}}
    }
  }
}

out.geode_loop.cyan_slurry = {
  id = 9,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 6,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      recipe = "geode-cyan-liquify",
      constraints = { ["fluid/crystal-slurry"] = {2}}
    }
  }
}

out.geode_loop.red_slurry = {
  id = 10,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/mineral-sludge"] = -100 },
    },
    {
      id = 2,
      type = "line",
      line_id = 7,
      constraints = { ["fluid/mineral-sludge"] = {1}}
    },
    {
      id = 3,
      recipe = "geode-red-liquify",
      constraints = { ["fluid/crystal-slurry"] = {2}}
    }
  }
}

out.geode_loop.overall = {
  id = 11,
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/water-heavy-mud"] = 100 },
    },
    {
      id = 2,
      recipe = "solid-geodes",
      constraints = { ["fluid/water-heavy-mud"] = { 1 }},
    },
    {
      id = 3,
      type = "line",
      line_id = 8,
      constraints = { ["item/geode-blue"] = {2}},
    },
    {
      id = 4,
      type = "line",
      line_id = 9,
      constraints = { ["item/geode-cyan"] = {2}},
    },
    {
      id = 5,
      type = "line",
      line_id = 10,
      constraints = { ["item/geode-red"] = {2}},
    },
  },
}

out.geode_loop_supply_driven = {
  steps = {
    {
      id = 1,
      type = "fixed",
      flow_set = { ["fluid/water-heavy-mud"] = 100 },
    },
    {
      id = 2,
      recipe = "solid-geodes",
      constraints = { ["fluid/water-heavy-mud"] = { 1 }},
    },
    {
      id = 3,
      recipe = "geode-blue-liquify",
      constraints = { ["item/geode-blue"] = { 2 }},
    },
    {
      id = 4,
      recipe = "geode-cyan-liquify",
      constraints = { ["item/geode-cyan"] = { 2 }},
    },
    {
      id = 5,
      recipe = "geode-red-liquify",
      constraints = { ["item/geode-red"] = { 2 }},
    },
    {
      id = 6,
      recipe = "crystal-slurry-filtering-conversion-1",
      constraints = { ["fluid/crystal-slurry"] = { 3, 4, 5 }},
    },
    {
      id = 7,
      recipe = "yellow-waste-water-purification",
      constraints = { ["fluid/water-yellow-waste"] = { 6 }},
    },
  },
}

return out