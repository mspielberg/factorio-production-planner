local Dispatcher = require "gui.Dispatcher"
local MasterFlowController = require "gui.MasterFlowController"
local MasterFlow = require "gui.MasterFlow"

local function on_init()
  global.master_flows = {}
end

local function on_load()
  for _, master_flow in pairs(global.master_flows) do
    MasterFlowController.restore(master_flow)
  end
end

local function on_player_created(event)
  local player_index = event.player_index
  local player = game.players[player_index]
  local master_flow = MasterFlow.new(player)
  global.master_flows[player_index] = MasterFlowController.new(master_flow)
end

local event_handlers = {
  on_gui_click = Dispatcher.dispatch,
  on_gui_elem_changed = Dispatcher.dispatch,
  on_player_created = on_player_created,
}

script.on_init(on_init)
script.on_load(on_load)
for name, handler in pairs(event_handlers) do
  script.on_event(defines.events[name], handler)
end
