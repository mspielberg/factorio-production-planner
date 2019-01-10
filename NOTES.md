raw state (production lines, recipes) persisted in global
controllers not persisted in global

on player created:

create view
view creates gui
view registers event handlers in dispatcher
create controller
link controller to newly created view

on load:

restore view, linking to existing gui
create controller
controllers initialize state from global
link controllers to existing gui

views:
  hold references to GuiComponents
  do NOT hold references to controllers




VirtualRecipe
VirtualCraftingMachine

