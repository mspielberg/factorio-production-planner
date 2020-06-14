local function new(type, name)
  if type ~= "item" and type ~= "fluid" then error("invalid component type: "..type) end
  return type .. "/" .. name
end

local match = string.match
local function get_type(self)
  return match(self, "^([^/]*)")
end

local sub = string.sub
local function get_name(self)
  if sub(self, 1, 1) == "i" then
    return sub(self, 5)
  end
  return sub(self, 6)
end

return {
  new = new,
  get_type = get_type,
  get_name = get_name,
}