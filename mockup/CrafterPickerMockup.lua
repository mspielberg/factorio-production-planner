if game.player.gui.screen["planner-crafter-picker"] then
  game.player.gui.screen["planner-crafter-picker"].destroy()
end

local column_width = 10*40+8
local column_separator = 40

picker_frame = game.player.gui.screen.add{type="frame", caption="Select crafter", name="planner-crafter-picker"}
inner_frame = picker_frame.add{type="frame", style="inside_shallow_frame_with_padding", direction="vertical", name="inner"}
recipe_flow = inner_frame.add{type="flow",direction="horizontal",name="recipe_bar"}
recipe_flow.style.vertical_align="center"
recipe_icon = recipe_flow.add{type="choose-elem-button", elem_type="recipe", recipe="iron-plate", name="icon", style="transparent_slot"}
recipe_icon.ignored_by_interaction = false
recipe_icon.locked = true
recipe_name = recipe_flow.add{type="label", caption=game.recipe_prototypes["iron-plate"].localised_name, name="recipe_name", style="heading_2_label"}

main_scroll = inner_frame.add{type="scroll-pane",name = "main_scroll"}
entity_panes = main_scroll.add{name="entity_panes", type="flow", direction="horizontal"}

crafting_machine_flow = entity_panes.add{type="flow",name="crafting_machine_flow", direction="vertical"}
crafting_machine_flow.style.width=column_width
crafting_machine_flow.add{type="label", caption="Select crafting machine:",style="heading_3_label"}
machines_frame = crafting_machine_flow.add{type="frame",style="slot_button_deep_frame"}
machines = machines_frame.add{type="table",style="slot_table", column_count=10, name="machines"}
machines.style.width = 400
machines.add{type="choose-elem-button", name="set-machine_assembling-machine-1", elem_type="entity", entity="assembling-machine-1"}
machines.add{type="choose-elem-button", name="set-machine_assembling-machine-2", elem_type="entity", entity="assembling-machine-2"}
machines.add{type="choose-elem-button", name="set-machine_assembling-machine-3", elem_type="entity", entity="assembling-machine-3"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="empty-widget"}
machines.add{type="choose-elem-button", name="assembling-machine-4", elem_type="entity", entity="assembling-machine-3"}
for _, gui in pairs(machines.children) do if gui.type == "choose-elem-button" then gui.locked=true end end

entity_panes.add{type="flow"}.style.width=column_separator

beacon_flow = entity_panes.add{type="flow",name="beacon_flow",direction="vertical"}
beacon_flow.style.width=column_width
beacon_flow.add{type="label", caption="Select beacon type:",style="heading_3_label"}
beacons_frame = beacon_flow.add{type="frame",style="slot_button_deep_frame"}
beacons = beacons_frame.add{type="table",style="slot_table", column_count=10, name="beacons"}
beacons.style.width = 400
beacons.add{type="choose-elem-button", name="set-beacon_beacon", elem_type="entity", entity="beacon"}
beacons.add{type="choose-elem-button", name="set-beacon_beacon-2", elem_type="entity", entity="beacon-2"}
beacons.add{type="choose-elem-button", name="set-beacon_beacon-3", elem_type="entity", entity="beacon-3"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="empty-widget"}
beacons.add{type="choose-elem-button", name="assembling-machine-4", elem_type="entity", entity="beacon-3"}
for _, gui in pairs(beacons.children) do if gui.type == "choose-elem-button" then gui.locked=true end end
beacon_count_flow = beacon_flow.add{type="flow", direction="horizontal"}
beacon_count_flow.style.vertical_align = "center"
beacon_count_flow.add{type="label",caption="Beacons per crafting machine"}
beacon_count = beacon_count_flow.add{type="textfield",name="beacon_count", numeric=true, allow_negative=false,allow_decimal=false,lose_focus_on_confirm=true,clear_and_focus_on_right_click=true}
beacon_count.style.width=40

module_panes = main_scroll.add{name="module_panes", type="flow", direction="horizontal"}

crafting_machine_modules_flow = module_panes.add{type="flow",name="crafting_machine_flow", direction="vertical"}
crafting_machine_modules_flow.style.width=column_width
crafting_machine_modules_flow.add{type="label", caption="Crafting machine modules:",style="heading_3_label",tooltip="Click to remove"}
machine_current_modules_table = crafting_machine_modules_flow.add{type="table",style="slot_table", column_count=10, name="machines"}
machine_current_modules_table.style.width = 4*40
machine_current_modules_table.add{type="choose-elem-button", name="remove-machine-module-1", elem_type="item", item="productivity-module", style="slot"}
machine_current_modules_table.add{type="choose-elem-button", name="remove-machine-module-2", elem_type="item", item="productivity-module", style="slot"}
machine_current_modules_table.add{type="choose-elem-button", name="remove-machine-module-3", elem_type="item", style="slot"}
machine_current_modules_table.add{type="choose-elem-button", name="remove-machine-module-4", elem_type="item", style="slot"}
for _, gui in pairs(machine_current_modules_table.children) do if gui.type == "choose-elem-button" then gui.locked=true end end

module_panes.add{type="flow"}.style.width=column_separator

beacon_modules_flow = module_panes.add{type="flow",name="beacon_flow",direction="vertical"}
beacon_modules_flow.style.width=column_width
beacon_modules_flow.add{type="label", caption="Beacon modules:",style="heading_3_label",tooltip="Click to remove"}
beacon_current_modules_table = beacon_modules_flow.add{type="table",style="slot_table", column_count=10, name="beacons"}
beacon_current_modules_table.style.width = 2*40
beacon_current_modules_table.add{type="choose-elem-button", name="remove-beacon-module-1", elem_type="item", item="speed-module", style="slot"}
beacon_current_modules_table.add{type="choose-elem-button", name="remove-beacon-module-2", elem_type="item", item="speed-module", style="slot"}
for _, gui in pairs(beacon_current_modules_table.children) do if gui.type == "choose-elem-button" then gui.locked=true end end
