
local dir = {}

local require = nil
--------------------------------------------------------------------------------

dir.separator = "/"

--- Describe a path in a cross-platform way.
-- Use this function to avoid platform-specific directory
-- separators in other modules. Removes trailing slashes from
-- each component given, to avoid repeated separators.
-- Separators inside strings are kept, to handle URLs containing
-- protocols.
-- @param ... strings representing directories
-- @return string: a string with a platform-specific representation
-- of the path.
function dir.path(...)
   local t = {...}
   while t[1] == "" do
      table.remove(t, 1)
   end
   return (table.concat(t, "/"):gsub("([^:])/+", "%1/"):gsub("^/+", "/"):gsub("/*$", ""))
end

return dir

