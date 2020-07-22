local luasimplex = require("luasimplex")
local rsm = require("luasimplex.rsm")
local huge = math.huge


--[[
  Variables:

  1. solid-geodes = -40 water-heavy-mud -25 water +2 blue +1 cyan +1 lightgreen +1 purple +2 red +1 yellow
  2. blue-liquify = -5 blue -15 sulfuric +20 slurry
  3. cyan-liquify = -5 cyan -15 sulfuric +50 slurry
  4. red-liquify = -5 red -15 sulfuric +20 slurry
  5. filtering = -50 slurry -100 mineralized +50 sludge +40 waste
  6. blue-processing = -2 blue +1 dust +2 crushed
  7. cyan-processing = -2 cyan +3 dust +2 crushed
  8. red-processing = -2 red +1 dust +2 crushed
  9. mineralized = -100 water -10 crushed +100 mineralized
  10. dust-liquify = -10 dust -15 sulfuric +50 slurry
  11. purification = -100 waste +20 mineralized +70 purified +1 sulfur

  Constraints

  blue = 2*x1 + -5*x2 + -2*x6
  cyan = 1*x1 + -5*x3 + -2*x7
  red  = 2*x1 + -5*x4 + -2*x8
  slurry = 20*x2 + 50*x3 + 20*x4 + -50*x5 + 50*x10
  mineralized = -100*x5 + 100*x9 + 20*x11
  sludge = 50*x5
  waste = 40*x5 + -100*x11
  dust = 1*x6 + 3*x7 + 1*x8 + -10*x10
  crushed = 2*x6 + 2*x7 + 2*x8 + -10*x9


]]

local recipes = {
  {
    name = "solid-geodes",
    ["fluid/water-heavy-mud"] = -40,
    ["fluid/water"] = -25,
    ["item/geode-blue"] = 2,
    ["item/geode-cyan"] = 1,
    ["item/geode-lightgreen"] = 1,
    ["item/geode-purple"] = 1,
    ["item/geode-red"] = 2,
    ["item/geode-yellow"] = 1,
  },
  {
    name = "geode-blue-liquify",
    ["item/geode-blue"] = -5,
    ["fluid/sulfuric-acid"] = -15,
    ["fluid/crystal-slurry"] = 20,
  },
  {
    name = "geode-cyan-liquify",
    ["item/geode-cyan"] = -5,
    ["fluid/sulfuric-acid"] = -15,
    ["fluid/crystal-slurry"] = 50,
  },
  {
    name = "geode-red-liquify",
    ["item/geode-red"] = -5,
    ["fluid/sulfuric-acid"] = -15,
    ["fluid/crystal-slurry"] = 20,
  },
  {
    name = "crystal-slurry-filtering-conversion",
    ["fluid/crystal-slurry"] = -50,
    ["fluid/water-mineralized"] = -100,
    ["item/filter-coal"] = -1,
    ["fluid/mineral-sludge"] = 50,
    ["fluid/water-yellow-waste"] = 40,
    ["item/filter-frame"] = 1,
  },
  {
    name = "geode-blue-processing",
    ["item/geode-blue"] = -2,
    ["item/crystal-dust"] = 1,
    ["item/stone-crushed"] = 2,
  },
  {
    name = "geode-cyan-processing",
    ["item/geode-cyan"] = -2,
    ["item/crystal-dust"] = 3,
    ["item/stone-crushed"] = 2,
  },
  {
    name = "geode-red-processing",
    ["item/geode-red"] = -2,
    ["item/crystal-dust"] = 1,
    ["item/stone-crushed"] = 2,
  },
  {
    name = "water-mineralized",
    ["fluid/water"] = -100,
    ["item/stone-crushed"] = -10,
    ["fluid/water-mineralized"] = 100,
  },
  {
    name = "dust-liquify",
    ["item/crystal-dust"] = -10,
    ["fluid/sulfuric-acid"] = -15,
    ["fluid/crystal-slurry"] = 50,
  },
  {
    name = "yellow-waste-water-purification",
    ["fluid/water-yellow-waste"] = -100,
    ["fluid/water-mineralized"] = 20,
    ["fluid/water-purified"] = 70,
    ["item/sulfur"] = 1,
  }
}

local M =
{
  -- number of variables
  nvars = 20,
  -- number of constraints
  nrows = 9,
  indexes = {
    1,2,6,                  12,
    1,3,7,                  13,
    1,4,8,                  14,
    2,3,4,5,10,             15,
    5,9,11,                 16,
    5,                      17,
    5,11,                   18,
    6,7,8,10,               19,
    6,7,8,9,                20,
  },
  elements = {
    2,-5,-2,                -1,
    1,-5,-2,                -1,
    2,-5,-2,                -1,
    20,50,20,-50,50,        -1,
    -100,100,20,            -1,
    50,                     -1,
    40,-100,                -1,
    1,3,1,-10,              -1,
    2,2,2,-10,              -1,
  },
  row_starts = {
    1,
    5,
    9,
    13,
    19,
    23,
    25,
    28,
    33,
    38,
  },
  c = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  xl = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
  xu = {huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge, huge},
  b = {0,0,0,0,0,100,0,0,0},
}

local I = luasimplex.new_instance(M.nrows, M.nvars)
rsm.initialise(M, I, {})

objective, x = rsm.solve(M, I, 
{
  monitor = require "luasimplex.monitor".display,
  TOLERANCE = 1e-6,
})

io.stderr:write(("Objective: %g\n"):format(objective))
io.stderr:write("  x:")
for i = 1, M.nvars do io.stderr:write((" %g"):format(x[i])) end
io.stderr:write("\n")

local item_rates = {}
for i=1,#recipes do
  for k,v in pairs(recipes[i]) do
    if k ~= "name" then
      item_rates[k] = (item_rates[k] or 0) + (v * x[i])
    end
  end
end

print("\nRecipe rates:\n")
for i=1,#recipes do
  print(("%-40s: %8.2f crafts/s"):format(recipes[i].name, x[i]))
end

local function round(x, o)
  return math.floor(x * (10^o) + 0.5)/10^o
end

print("\nNet item rates:\n")
for k,v in pairs(item_rates) do
  print(("%-40s: %8.2f /s"):format(k,round(v, 3)))
end