local DefaultAPIAdapter = require "src.api.DefaultAPIAdapter"
local FAPI = setmetatable({}, { __index = DefaultAPIAdapter })
return FAPI