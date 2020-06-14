local DefaultAPIAdapter = require "src.api.DefaultAPIAdapter"
local StubAPIAdapter = require "src.api.StubAPIAdapter"
local FAPI = setmetatable({}, { __index = DefaultAPIAdapter })

function FAPI.activate_debug_api()
  getmetatable(FAPI).__index = StubAPIAdapter
end

return FAPI