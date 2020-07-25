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

out.py_slimed_iron = {
  steps = {
    { recipe = "hotair-iron-plate-1" },
    { recipe = "molten-iron-06" },
    { recipe = "unslimed-iron" },
    { recipe = "unslimed-iron-2" },
    { recipe = "classify-iron-ore-dust" },
    { recipe = "iron-ore-dust" },
    { recipe = "grade-2-crush" },
    { recipe = "grade-3-iron-processing" },
    { recipe = "grade-2-iron" },
  }
}

out.angels_refining = {
  steps = {
    { recipe = "angelsore1-crushed" },
    { recipe = "angelsore2-crushed" },
    { recipe = "angelsore3-crushed" },
    { recipe = "angelsore4-crushed" },
    { recipe = "angelsore5-crushed" },
    { recipe = "angelsore6-crushed" },
    { recipe = "angelsore1-chunk" },
    { recipe = "angelsore2-chunk" },
    { recipe = "angelsore3-chunk" },
    { recipe = "angelsore4-chunk" },
    { recipe = "angelsore5-chunk" },
    { recipe = "angelsore6-chunk" },
    { recipe = "angelsore1-crystal" },
    { recipe = "angelsore2-crystal" },
    { recipe = "angelsore3-crystal" },
    { recipe = "angelsore4-crystal" },
    { recipe = "angelsore5-crystal" },
    { recipe = "angelsore6-crystal" },
    { recipe = "angelsore1-pure" },
    { recipe = "angelsore2-pure" },
    { recipe = "angelsore3-pure" },
    { recipe = "angelsore4-pure" },
    { recipe = "angelsore5-pure" },
    { recipe = "angelsore6-pure" },
    { recipe = "angelsore1-crushed-processing" },
    { recipe = "angelsore2-crushed-processing" },
    { recipe = "angelsore3-crushed-processing" },
    { recipe = "angelsore4-crushed-processing" },
    { recipe = "angelsore5-crushed-processing" },
    { recipe = "angelsore6-crushed-processing" },
    { recipe = "angelsore1-chunk-processing" },
    { recipe = "angelsore2-chunk-processing" },
    { recipe = "angelsore3-chunk-processing" },
    { recipe = "angelsore4-chunk-processing" },
    { recipe = "angelsore5-chunk-processing" },
    { recipe = "angelsore6-chunk-processing" },
    { recipe = "angelsore1-crystal-processing" },
    { recipe = "angelsore2-crystal-processing" },
    { recipe = "angelsore3-crystal-processing" },
    { recipe = "angelsore4-crystal-processing" },
    { recipe = "angelsore5-crystal-processing" },
    { recipe = "angelsore6-crystal-processing" },
    { recipe = "angelsore1-pure-processing" },
    { recipe = "angelsore2-pure-processing" },
    { recipe = "angelsore3-pure-processing" },
    { recipe = "angelsore4-pure-processing" },
    { recipe = "angelsore5-pure-processing" },
    { recipe = "angelsore6-pure-processing" },
    { recipe = "angelsore-crushed-mix1-processing" },
    { recipe = "angelsore-crushed-mix2-processing" },
    { recipe = "angelsore-crushed-mix3-processing" },
    { recipe = "angelsore-crushed-mix4-processing" },
    { recipe = "angelsore-chunk-mix1-processing" },
    { recipe = "angelsore-chunk-mix2-processing" },
    { recipe = "angelsore-chunk-mix3-processing" },
    { recipe = "angelsore-chunk-mix4-processing" },
    { recipe = "angelsore-chunk-mix5-processing" },
    { recipe = "angelsore-chunk-mix6-processing" },
    { recipe = "angelsore-crystal-mix1-processing" },
    { recipe = "angelsore-crystal-mix2-processing" },
    { recipe = "angelsore-crystal-mix3-processing" },
    { recipe = "angelsore-crystal-mix4-processing" },
    { recipe = "angelsore-crystal-mix5-processing" },
    { recipe = "angelsore-crystal-mix6-processing" },
    { recipe = "angelsore-pure-mix1-processing" },
    { recipe = "angelsore-pure-mix2-processing" },
    { recipe = "angelsore-pure-mix3-processing" },
    { recipe = "slag-processing-dissolution" },
    { recipe = "slag-processing-filtering-1" },
    { recipe = "slag-processing-1" },
    { recipe = "slag-processing-2" },
    { recipe = "slag-processing-3" },
    { recipe = "slag-processing-4" },
    { recipe = "slag-processing-5" },
    { recipe = "slag-processing-6" },
    { recipe = "slag-processing-7" },
    { recipe = "slag-processing-8" },
  }
}

return out