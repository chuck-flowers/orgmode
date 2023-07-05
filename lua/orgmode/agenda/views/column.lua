--- @class ColumnView
local ColumnView = {}
ColumnView.__index = ColumnView

--- Column View constructor
--- @return ColumnView
function ColumnView:new()
  --- @type ColumnView
  local instance = {}
  setmetatable(instance, ColumnView)

  return instance
end

return ColumnView
