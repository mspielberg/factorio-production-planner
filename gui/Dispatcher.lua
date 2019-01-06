local inspect = require "inspect"

local M = {}

local handlers = {}

function M.register(event_name, elem, handler)
  if not handlers[event_name] then
    handlers[event_name] = {}
  end
  handlers[event_name][elem] = handler
end

function M.dispatch(event)
  local target = event.element
  local event_handlers = handlers[event.name]
  if event_handlers then
    for elem, handler in pairs(event_handlers) do
      if elem == target then
        local success, err = pcall(function ()
          handler(event)
        end)
        if not success then
          game.print(err)
        end
        return
      end
    end
  end
end

local event_names = {}
for name, id in pairs(defines.events) do
  event_names[id] = name
end

local delegates = {}

function M.register_delegate(gui, controller)
  delegates[gui] = controller
end

function M.dispatch2(event)
  local element = event.element
  local event_name = event_names[event.name]
  local handled = false

  while element and not handled do
    local delegate = delegates[element]
    if delegate then
      local handler = delegate[event_name]
      if handler then
        success, result = pcall(function () handler(event) end)
        if not success then
          game.print(result)
          return
        else
          handled = result
        end
      end
    end
    element = element.parent
  end
end

return M
