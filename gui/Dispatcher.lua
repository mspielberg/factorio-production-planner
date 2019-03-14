local function debugp(x)
  log(serpent.block(x))
end

local event_names = {}
for name, id in pairs(defines.events) do
  event_names[id] = name
end

local ignorable_types = {
  flow = true,
  frame = true,
  label = true,
  table = true,
}

local delegates = {}

local function cleanup()
  for k, v in pairs(delegates) do
    if not v.gui.valid then
      debugp{name="GUI invalid", index=k}
      delegates[k] = nil
    end
  end
end

local function extract_path(gui)
  local components = {}
  while gui do
    table.insert(components, 1, gui.name)
    gui = gui.parent
  end
  return table.concat(components, ".")
end

local M = {}

function M.register(delegate, gui)
  debugp{name="register_delegate", index=gui.index}
  delegates[gui.index] = {
    gui = gui,
    delegate = delegate,
  }
end

function M.dispatch(event)
  cleanup()
  event.context = {}
  local element = event.element
  local element_type = element.type
  local event_name = event_names[event.name] or event.name
  local handled = false

  debugp{name="dispatch_start",event_name=event_name,index=element.index}
  while element and not handled do
    local record = delegates[element.index]
    if record then
      local delegate = record.delegate
      local handler = delegate[event_name]
      if handler then
        debugp{name="handler_start", delegate=delegate, event=event}
        local success, result = pcall(handler, delegate, event)
        if not success then
          game.print("error running event handler: "..tostring(result))
          return
        else
          handled = result
          debugp{name = "handler_end", event=event, handled = handled}
        end
      end
    else
      debugp{name="no_delegate", element=element.index}
    end
    element = element.parent
  end
  debugp{name="dispatch_end"}

  if not handled and not ignorable_types[element_type] then
    game.print("no delegate found for event "..event_name.." on element "..extract_path(event.element))
  end
end

return M
