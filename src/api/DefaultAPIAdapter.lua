local DefaultAPIAdapter = {}

local crafting_machine_prototypes
function DefaultAPIAdapter.get_crafting_machine_prototypes()
  crafting_machine_protypes = crafting_machine_protypes or
    game.get_filtered_entity_prototypes{{filter = "crafting-machine"}}
  return crafting_machine_prototypes
end

local entity_prototypes
function DefaultAPIAdapter.get_entity_prototype(entity_name)
  entity_prototypes = entity_prototypes or game.entity_prototypes
  return entity_prototypes[entity_name]
end

local recipe_prototypes
function DefaultAPIAdapter.get_recipe_prototype(recipe_name)
  recipe_prototypes = recipe_prototypes or game.recipe_prototypes
  return recipe_prototypes[recipe_name]
end

local module_prototypes
function DefaultAPIAdapter.get_module_prototypes()
  module_prototypes = module_prototypes or
    game.get_filtered_entity_prototypes{{filter = "type", type = "module"}}
  return module_prototypes
end

return DefaultAPIAdapter