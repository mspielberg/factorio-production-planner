local DefaultAPIAdapter = {}

function DefaultAPIAdapter.get_recipe_prototype(recipe_name)
  return game.recipe_prototypes[recipe_name]
end

return DefaultAPIAdapter