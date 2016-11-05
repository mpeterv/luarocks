--- Module for handling rock manifest files and tables.
-- Rock manifests list files installed by a rock.
local rock_manif = {}

local dir = require("luarocks.dir")
local fs = require("luarocks.fs")
local path = require("luarocks.path")
local persist = require("luarocks.persist")

local rock_manifest_cache = {}

function rock_manif.load_rock_manifest(name, version, root)
   assert(type(name) == "string")
   assert(type(version) == "string")

   local name_version = name.."/"..version
   if rock_manifest_cache[name_version] then
      return rock_manifest_cache[name_version].rock_manifest
   end

   local pathname = path.rock_manifest_file(name, version, root)
   local rock_manifest = persist.load_into_table(pathname)
   if not rock_manifest then
      return nil, "rock_manifest file not found for "..name.." "..version.." - not a LuaRocks tree?"
   end
   rock_manifest_cache[name_version] = rock_manifest
   return rock_manifest.rock_manifest
end

--- Write a rock manifest file listing files
-- installed for given package.
-- Search for files is performed in install directory
-- for the package and the rock manifest is written
-- in the same directory, named "rock_manifest".
function rock_manif.make_rock_manifest(name, version)
   local install_dir = path.install_dir(name, version)
   local tree = {}

   for _, file in ipairs(fs.find(install_dir)) do
      local full_path = dir.path(install_dir, file)
      local walk = tree
      local last
      local last_name
      for filename in file:gmatch("[^/]+") do
         local next = walk[filename]
         if not next then
            next = {}
            walk[filename] = next
         end
         last = walk
         last_name = filename
         walk = next
      end
      if fs.is_file(full_path) then
         local sum, err = fs.get_md5(full_path)
         if not sum then
            return nil, "Failed producing checksum: "..tostring(err)
         end
         last[last_name] = sum
      end
   end
   local rock_manifest = { rock_manifest=tree }
   rock_manifest_cache[name.."/"..version] = rock_manifest
   persist.replace_from_table(path.rock_manifest_file(name, version), rock_manifest)
end

return rock_manif
