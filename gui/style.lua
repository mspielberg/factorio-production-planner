local arrow_button_width = 22
local default_container_padding = 8
local delete_recipe_button_width = 38
local item_buttons_in_column = 5
local item_button_width = 36
local item_button_spacing = 2
local item_column_width = item_buttons_in_column * item_button_width + item_button_spacing * (item_buttons_in_column - 1)
local ingredients_column_offset = arrow_button_width + delete_recipe_button_width + item_button_width * 2 + default_container_padding * 3

return {
  dimensions = {
    arrow_button_width = arrow_button_width,
    delete_recipe_button_width = delete_recipe_button_width,
    recipe_column_width = item_button_width,
    assembling_machine_column_width = item_button_width,
    ingredients_column_width = item_column_width,
    products_column_width = item_column_width,

    ingredients_column_offset = ingredients_column_offset,
  },
  item_buttons_in_column = item_buttons_in_column,
}
