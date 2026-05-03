-- mechanicist-factorio/data.lua
-- Safe loader: do not hard-crash when old inherited prototype files are absent.
-- Missing files will be reported in factorio-current.log instead.

local function safe_require(module_name)
  local ok, err = pcall(require, module_name)
  if not ok then
    log("[mechanicist-factorio] Skipped missing/failed module: " .. module_name .. " :: " .. tostring(err))
  end
end

-- Core prototype files inherited from the original fork.
-- These are optional here because this mod folder may not contain the old tank prototype tree.
safe_require("prototypes.categories.recipe-category")
safe_require("prototypes.categories.ammo-category")
safe_require("prototypes.entity.entities")
safe_require("prototypes.entity.vehicles")
safe_require("prototypes.entity.explosionsa")
safe_require("prototypes.entity.projectiles")
safe_require("prototypes.item.ammo")
safe_require("prototypes.item.item")
safe_require("prototypes.item.item-groups")
safe_require("prototypes.item.gun")
safe_require("prototypes.item.vehicles")
safe_require("prototypes.item.capsule")
safe_require("prototypes.item.equipment")
safe_require("prototypes.recipe.ammo")
safe_require("prototypes.recipe.recipe")
safe_require("prototypes.recipe.vehicles")
safe_require("prototypes.technology.technology")
safe_require("prototypes.equipment.equipment")
safe_require("prototypes.fluid.fluid")

-- Optional compatibility/localization patches.
-- Space Age compatibility is not implemented unless this file exists.
if mods["space-age"] then
  safe_require("prototypes.compatibility.space-age")
end

safe_require("prototypes.compatibility.mechanicus-locale")
