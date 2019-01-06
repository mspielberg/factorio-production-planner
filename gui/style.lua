local item_buttons_in_column = 5
local item_button_width = 36
local item_button_spacing = 2
local item_column_width = item_buttons_in_column * item_button_width + item_button_spacing * (item_buttons_in_column - 1)

return {
  dimensions = {
    recipe_column_width = item_button_width,
    assembling_machine_column_width = item_button_width,
    ingredients_column_width = item_column_width,
    products_column_width = item_column_width,
  },
}
