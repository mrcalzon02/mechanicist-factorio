-- Mechanicist Factorio
-- data-updates.lua
--
-- Applies startup-setting controlled visible localization to existing prototypes.
-- Internal prototype names remain unchanged for compatibility.

local MOD_PREFIX = "mechanicist-factorio"

local function startup_value(suffix, fallback)
  local full_name = MOD_PREFIX .. "-" .. suffix
  if settings and settings.startup and settings.startup[full_name] ~= nil then
    return settings.startup[full_name].value
  end
  return fallback
end

local function debug_log(message)
  if startup_value("debug-locale-audit", false) then
    log("[Mechanicist Factorio] " .. message)
  end
end

local function clear_locale(proto)
  if proto then
    proto.localised_name = nil
    proto.localised_description = nil
  end
end

local function apply_locale(proto, name_key, description_key)
  if proto then
    if name_key then
      proto.localised_name = {name_key}
    end
    if description_key then
      proto.localised_description = {description_key}
    end
  end
end

local item_types = {
  "item", "ammo", "armor", "capsule", "gun", "module", "tool", "repair-tool",
  "item-with-entity-data", "rail-planner", "space-platform-starter-pack",
  "blueprint", "blueprint-book", "deconstruction-item", "upgrade-item", "selection-tool"
}

local entity_types = {
  "accumulator", "ammo-turret", "arithmetic-combinator", "artillery-turret", "assembling-machine",
  "beacon", "boiler", "burner-generator", "car", "cargo-landing-pad", "constant-combinator",
  "container", "curved-rail-a", "curved-rail-b", "decider-combinator", "electric-energy-interface",
  "electric-pole", "electric-turret", "fluid-turret", "furnace", "fusion-generator", "fusion-reactor",
  "gate", "generator", "heat-interface", "heat-pipe", "infinity-container", "infinity-pipe",
  "inserter", "lab", "lamp", "land-mine", "legacy-curved-rail", "legacy-straight-rail",
  "linked-belt", "linked-container", "loader", "loader-1x1", "locomotive", "logistic-container",
  "market", "mining-drill", "offshore-pump", "pipe", "pipe-to-ground", "planet", "power-switch",
  "programmable-speaker", "pump", "radar", "rail-chain-signal", "rail-ramp", "rail-signal",
  "rail-support", "reactor", "roboport", "rocket-silo", "selector-combinator", "simple-entity",
  "simple-entity-with-force", "simple-entity-with-owner", "solar-panel", "space-platform-hub",
  "spider-vehicle", "splitter", "storage-tank", "straight-rail", "thruster", "train-stop",
  "transport-belt", "tree", "turret", "underground-belt", "wall"
}

-- Base-game retheme reference lists. These are intentionally additive:
-- entries here should correspond to locale keys in locale/en/base.cfg.
-- Adding a name here does not create or rename the prototype internally; it only
-- points an existing prototype at the selected Mechanist locale layer.

local vanilla_entities = {
  "assembling-machine-1",
  "assembling-machine-2",
  "assembling-machine-3",
  "burner-mining-drill",
  "electric-mining-drill",
  "stone-furnace",
  "steel-furnace",
  "electric-furnace",
  "lab",
  "boiler",
  "steam-engine",
  "chemical-plant",
  "oil-refinery",
  "radar",
  "roboport",
  "transport-belt",
  "fast-transport-belt",
  "express-transport-belt",
  "underground-belt",
  "fast-underground-belt",
  "express-underground-belt",
  "splitter",
  "fast-splitter",
  "express-splitter",
  "burner-inserter",
  "inserter",
  "long-handed-inserter",
  "fast-inserter",
  "bulk-inserter",
  "stack-inserter",
  "filter-inserter",
  "stack-filter-inserter",
  "small-electric-pole",
  "medium-electric-pole",
  "big-electric-pole",
  "substation",
  "pipe",
  "pipe-to-ground",
  "pump",
  "offshore-pump",
  "storage-tank",
  "wooden-chest",
  "iron-chest",
  "steel-chest",
  "storage-chest",
  "passive-provider-chest",
  "active-provider-chest",
  "requester-chest",
  "buffer-chest",
  "lamp",
  "constant-combinator",
  "arithmetic-combinator",
  "decider-combinator",
  "selector-combinator",
  "power-switch",
  "programmable-speaker",
  "rail",
  "straight-rail",
  "curved-rail",
  "rail-signal",
  "rail-chain-signal",
  "train-stop",
  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",
  "car",
  "tank",
  "spidertron",
  "stone-wall",
  "gate",
  "gun-turret",
  "laser-turret",
  "flamethrower-turret",
  "artillery-turret",
  "solar-panel",
  "accumulator",
  "nuclear-reactor",
  "heat-exchanger",
  "heat-pipe",
  "steam-turbine",
  "centrifuge",
  "beacon",
  "rocket-silo",
  "repair-pack",
  "construction-robot",
  "logistic-robot",
}

local vanilla_items = {
  "iron-plate",
  "copper-plate",
  "steel-plate",
  "stone-brick",
  "iron-gear-wheel",
  "copper-cable",
  "electronic-circuit",
  "advanced-circuit",
  "processing-unit",
  "engine-unit",
  "electric-engine-unit",
  "battery",
  "plastic-bar",
  "sulfur",
  "explosives",
  "automation-science-pack",
  "logistic-science-pack",
  "military-science-pack",
  "chemical-science-pack",
  "production-science-pack",
  "utility-science-pack",
  "space-science-pack",
  "transport-belt",
  "fast-transport-belt",
  "express-transport-belt",
  "underground-belt",
  "fast-underground-belt",
  "express-underground-belt",
  "splitter",
  "fast-splitter",
  "express-splitter",
  "burner-inserter",
  "inserter",
  "long-handed-inserter",
  "fast-inserter",
  "bulk-inserter",
  "stack-inserter",
  "filter-inserter",
  "stack-filter-inserter",
  "small-electric-pole",
  "medium-electric-pole",
  "big-electric-pole",
  "substation",
  "pipe",
  "pipe-to-ground",
  "pump",
  "offshore-pump",
  "storage-tank",
  "wooden-chest",
  "iron-chest",
  "steel-chest",
  "storage-chest",
  "passive-provider-chest",
  "active-provider-chest",
  "requester-chest",
  "buffer-chest",
  "lamp",
  "constant-combinator",
  "arithmetic-combinator",
  "decider-combinator",
  "selector-combinator",
  "power-switch",
  "programmable-speaker",
  "rail",
  "straight-rail",
  "curved-rail",
  "rail-signal",
  "rail-chain-signal",
  "train-stop",
  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",
  "car",
  "tank",
  "spidertron",
  "stone-wall",
  "gate",
  "gun-turret",
  "laser-turret",
  "flamethrower-turret",
  "artillery-turret",
  "solar-panel",
  "accumulator",
  "nuclear-reactor",
  "heat-exchanger",
  "heat-pipe",
  "steam-turbine",
  "centrifuge",
  "beacon",
  "rocket-silo",
  "repair-pack",
  "construction-robot",
  "logistic-robot",
  "wood",
  "coal",
  "stone",
  "iron-ore",
  "copper-ore",
  "uranium-ore",
  "raw-fish",
  "automation-core",
  "firearm-magazine",
  "piercing-rounds-magazine",
  "uranium-rounds-magazine",
  "shotgun-shell",
  "piercing-shotgun-shell",
  "cannon-shell",
  "explosive-cannon-shell",
  "uranium-cannon-shell",
  "explosive-uranium-cannon-shell",
  "artillery-shell",
  "rocket",
  "explosive-rocket",
  "atomic-bomb",
  "flamethrower-ammo",
  "grenade",
  "cluster-grenade",
  "poison-capsule",
  "slowdown-capsule",
  "defender-capsule",
  "distractor-capsule",
  "destroyer-capsule",
  "light-armor",
  "heavy-armor",
  "modular-armor",
  "power-armor",
  "power-armor-mk2",
  "portable-solar-panel",
  "portable-fusion-reactor",
  "energy-shield-equipment",
  "energy-shield-mk2-equipment",
  "battery-equipment",
  "battery-mk2-equipment",
  "personal-laser-defense-equipment",
  "exoskeleton-equipment",
  "personal-roboport-equipment",
  "night-vision-equipment",
  "belt-immunity-equipment",
  "speed-module",
  "speed-module-2",
  "speed-module-3",
  "efficiency-module",
  "efficiency-module-2",
  "efficiency-module-3",
  "productivity-module",
  "productivity-module-2",
  "productivity-module-3",
  "red-wire",
  "green-wire",
  "copper-wire",
  "blueprint",
  "deconstruction-planner",
  "upgrade-planner",
  "blueprint-book",
}

local vanilla_fluids = {
  "water",
  "steam",
  "crude-oil",
  "petroleum-gas",
  "light-oil",
  "heavy-oil",
  "lubricant",
  "sulfuric-acid",
}

local vanilla_recipes = {
  "iron-plate",
  "copper-plate",
  "steel-plate",
  "stone-brick",
  "iron-gear-wheel",
  "copper-cable",
  "electronic-circuit",
  "advanced-circuit",
  "processing-unit",
  "engine-unit",
  "electric-engine-unit",
  "battery",
  "plastic-bar",
  "sulfur",
  "explosives",
  "automation-science-pack",
  "logistic-science-pack",
  "military-science-pack",
  "chemical-science-pack",
  "production-science-pack",
  "utility-science-pack",
  "space-science-pack",
  "transport-belt",
  "fast-transport-belt",
  "express-transport-belt",
  "underground-belt",
  "fast-underground-belt",
  "express-underground-belt",
  "splitter",
  "fast-splitter",
  "express-splitter",
  "burner-inserter",
  "inserter",
  "long-handed-inserter",
  "fast-inserter",
  "bulk-inserter",
  "stack-inserter",
  "filter-inserter",
  "stack-filter-inserter",
  "small-electric-pole",
  "medium-electric-pole",
  "big-electric-pole",
  "substation",
  "pipe",
  "pipe-to-ground",
  "pump",
  "offshore-pump",
  "storage-tank",
  "wooden-chest",
  "iron-chest",
  "steel-chest",
  "storage-chest",
  "passive-provider-chest",
  "active-provider-chest",
  "requester-chest",
  "buffer-chest",
  "lamp",
  "constant-combinator",
  "arithmetic-combinator",
  "decider-combinator",
  "selector-combinator",
  "power-switch",
  "programmable-speaker",
  "rail",
  "straight-rail",
  "curved-rail",
  "rail-signal",
  "rail-chain-signal",
  "train-stop",
  "locomotive",
  "cargo-wagon",
  "fluid-wagon",
  "artillery-wagon",
  "car",
  "tank",
  "spidertron",
  "stone-wall",
  "gate",
  "gun-turret",
  "laser-turret",
  "flamethrower-turret",
  "artillery-turret",
  "solar-panel",
  "accumulator",
  "nuclear-reactor",
  "heat-exchanger",
  "heat-pipe",
  "steam-turbine",
  "centrifuge",
  "beacon",
  "rocket-silo",
  "repair-pack",
  "construction-robot",
  "logistic-robot",
  "wood",
  "coal",
  "stone",
  "iron-ore",
  "copper-ore",
  "uranium-ore",
  "raw-fish",
  "automation-core",
  "firearm-magazine",
  "piercing-rounds-magazine",
  "uranium-rounds-magazine",
  "shotgun-shell",
  "piercing-shotgun-shell",
  "cannon-shell",
  "explosive-cannon-shell",
  "uranium-cannon-shell",
  "explosive-uranium-cannon-shell",
  "artillery-shell",
  "rocket",
  "explosive-rocket",
  "atomic-bomb",
  "flamethrower-ammo",
  "grenade",
  "cluster-grenade",
  "poison-capsule",
  "slowdown-capsule",
  "defender-capsule",
  "distractor-capsule",
  "destroyer-capsule",
  "light-armor",
  "heavy-armor",
  "modular-armor",
  "power-armor",
  "power-armor-mk2",
  "portable-solar-panel",
  "portable-fusion-reactor",
  "energy-shield-equipment",
  "energy-shield-mk2-equipment",
  "battery-equipment",
  "battery-mk2-equipment",
  "personal-laser-defense-equipment",
  "exoskeleton-equipment",
  "personal-roboport-equipment",
  "night-vision-equipment",
  "belt-immunity-equipment",
  "speed-module",
  "speed-module-2",
  "speed-module-3",
  "efficiency-module",
  "efficiency-module-2",
  "efficiency-module-3",
  "productivity-module",
  "productivity-module-2",
  "productivity-module-3",
  "basic-oil-processing",
  "advanced-oil-processing",
  "coal-liquefaction",
  "heavy-oil-cracking",
  "light-oil-cracking",
  "solid-fuel-from-light-oil",
  "solid-fuel-from-petroleum-gas",
  "solid-fuel-from-heavy-oil",
  "uranium-processing",
  "kovarex-enrichment-process",
  "nuclear-fuel-reprocessing",
  "rocket-part",
  "low-density-structure",
  "rocket-fuel",
  "satellite",
}

local vanilla_technologies = {
  "automation",
  "logistics",
  "steel-processing",
  "electronics",
  "advanced-electronics",
  "oil-processing",
  "chemical-science-pack",
  "military",
  "advanced-material-processing",
  "robotics",
  "construction-robotics",
  "logistic-robotics",
  "rocket-silo",
  "space-science-pack",
  "automation-2",
  "automation-3",
  "logistics-2",
  "logistics-3",
  "fast-inserter",
  "bulk-inserter",
  "stack-inserter",
  "lamp",
  "circuit-network",
  "railway",
  "automated-rail-transportation",
  "rail-signals",
  "fluid-wagon",
  "braking-force-1",
  "braking-force-2",
  "braking-force-3",
  "braking-force-4",
  "braking-force-5",
  "braking-force-6",
  "braking-force-7",
  "automobilism",
  "tank",
  "spidertron",
  "flamethrower",
  "flammables",
  "explosives",
  "rocketry",
  "explosive-rocketry",
  "atomic-bomb",
  "artillery",
  "artillery-shell-range-1",
  "artillery-shell-speed-1",
  "laser",
  "laser-turret",
  "weapon-shooting-speed-1",
  "weapon-shooting-speed-2",
  "weapon-shooting-speed-3",
  "weapon-shooting-speed-4",
  "weapon-shooting-speed-5",
  "weapon-shooting-speed-6",
  "laser-shooting-speed-1",
  "laser-shooting-speed-2",
  "laser-shooting-speed-3",
  "laser-shooting-speed-4",
  "laser-shooting-speed-5",
  "laser-shooting-speed-6",
  "laser-shooting-speed-7",
  "physical-projectile-damage-1",
  "physical-projectile-damage-2",
  "physical-projectile-damage-3",
  "physical-projectile-damage-4",
  "physical-projectile-damage-5",
  "physical-projectile-damage-6",
  "physical-projectile-damage-7",
  "stronger-explosives-1",
  "stronger-explosives-2",
  "stronger-explosives-3",
  "stronger-explosives-4",
  "stronger-explosives-5",
  "stronger-explosives-6",
  "stronger-explosives-7",
  "refined-flammables-1",
  "refined-flammables-2",
  "refined-flammables-3",
  "refined-flammables-4",
  "refined-flammables-5",
  "refined-flammables-6",
  "refined-flammables-7",
  "modules",
  "speed-module",
  "speed-module-2",
  "speed-module-3",
  "efficiency-module",
  "efficiency-module-2",
  "efficiency-module-3",
  "productivity-module",
  "productivity-module-2",
  "productivity-module-3",
  "effect-transmission",
  "advanced-oil-processing",
  "coal-liquefaction",
  "sulfur-processing",
  "plastics",
  "battery",
  "fluid-handling",
  "lubricant",
  "electric-engine",
  "electric-energy-distribution-1",
  "electric-energy-distribution-2",
  "solar-energy",
  "electric-energy-accumulators",
  "nuclear-power",
  "uranium-processing",
  "kovarex-enrichment-process",
  "nuclear-fuel-reprocessing",
  "mining-productivity-1",
  "mining-productivity-2",
  "mining-productivity-3",
  "mining-productivity-4",
  "toolbelt",
  "night-vision-equipment",
  "energy-shield-equipment",
  "energy-shield-mk2-equipment",
  "battery-equipment",
  "battery-mk2-equipment",
  "portable-solar-panel-equipment",
  "personal-laser-defense-equipment",
  "exoskeleton-equipment",
  "personal-roboport-equipment",
  "personal-roboport-mk2-equipment",
  "belt-immunity-equipment",
  "follower-robot-count-1",
  "follower-robot-count-2",
  "follower-robot-count-3",
  "follower-robot-count-4",
  "follower-robot-count-5",
  "follower-robot-count-6",
  "follower-robot-count-7",
  "worker-robots-speed-1",
  "worker-robots-speed-2",
  "worker-robots-speed-3",
  "worker-robots-speed-4",
  "worker-robots-speed-5",
  "worker-robots-speed-6",
  "worker-robots-storage-1",
  "worker-robots-storage-2",
  "worker-robots-storage-3",
  "logistic-system",
}

local function apply_to_item_like(name, layer)
  local name_key = layer .. ".item-name." .. name
  local description_key = layer .. ".item-description." .. name
  for _, type_name in pairs(item_types) do
    if data.raw[type_name] and data.raw[type_name][name] then
      apply_locale(data.raw[type_name][name], name_key, description_key)
    end
  end
end

local function clear_item_like(name)
  for _, type_name in pairs(item_types) do
    if data.raw[type_name] and data.raw[type_name][name] then
      clear_locale(data.raw[type_name][name])
    end
  end
end

local function apply_to_entity_like(name, layer)
  local name_key = layer .. ".entity-name." .. name
  local description_key = layer .. ".entity-description." .. name
  for _, type_name in pairs(entity_types) do
    if data.raw[type_name] and data.raw[type_name][name] then
      apply_locale(data.raw[type_name][name], name_key, description_key)
    end
  end
end

local function clear_entity_like(name)
  for _, type_name in pairs(entity_types) do
    if data.raw[type_name] and data.raw[type_name][name] then
      clear_locale(data.raw[type_name][name])
    end
  end
end

local function apply_to_named_type(type_name, names, layer, locale_category)
  if not data.raw[type_name] then return end
  for _, name in pairs(names) do
    if data.raw[type_name][name] then
      apply_locale(
        data.raw[type_name][name],
        layer .. "." .. locale_category .. "-name." .. name,
        layer .. "." .. locale_category .. "-description." .. name
      )
    end
  end
end

local function clear_named_type(type_name, names)
  if not data.raw[type_name] then return end
  for _, name in pairs(names) do
    if data.raw[type_name][name] then
      clear_locale(data.raw[type_name][name])
    end
  end
end

local function patch_vanilla_locale(layer)
  for _, name in pairs(vanilla_entities) do
    apply_to_entity_like(name, layer)
  end
  for _, name in pairs(vanilla_items) do
    apply_to_item_like(name, layer)
  end
  apply_to_named_type("fluid", vanilla_fluids, layer, "fluid")
  apply_to_named_type("recipe", vanilla_recipes, layer, "recipe")
  apply_to_named_type("technology", vanilla_technologies, layer, "technology")
end

local function clear_vanilla_locale()
  for _, name in pairs(vanilla_entities) do
    clear_entity_like(name)
  end
  for _, name in pairs(vanilla_items) do
    clear_item_like(name)
  end
  clear_named_type("fluid", vanilla_fluids)
  clear_named_type("recipe", vanilla_recipes)
  clear_named_type("technology", vanilla_technologies)
end

local intensity = startup_value("language-intensity", "standard")
local rename_vanilla = startup_value("rename-vanilla", true)

if not rename_vanilla or intensity == "off" then
  -- A disabled retheme must not delete official or other mods' localised fields.
  debug_log("Vanilla retheme disabled; existing prototype localization preserved.")
else
  local layer = "mechanicist-standard"
  if intensity == "heresy" then
    layer = "mechanicist-heresy"
  end
  patch_vanilla_locale(layer)
  debug_log("Applied " .. layer .. " prototype localization layer.")
end


-- Quality names use private keys so the startup option genuinely controls
-- prototype retheming. Static GUI/tips remain standard locale overrides.
local quality_locale_definitions = {
  {proto_type = "quality", category = "quality-name",
    names = {"normal", "uncommon", "rare", "epic", "legendary"}},
  {proto_type = "technology", category = "technology-name", descriptions = true,
    names = {"quality-module", "epic-quality", "legendary-quality", "recycling"}},
  {proto_type = "module", category = "item-name", descriptions = true,
    names = {"quality-module", "quality-module-2", "quality-module-3"}},
  {proto_type = "furnace", category = "entity-name", descriptions = true,
    names = {"recycler"}},
  {proto_type = "recipe", category = "recipe-name", names = {"recycling"}},
  {proto_type = "virtual-signal", category = "virtual-signal-name",
    names = {"signal-any-quality"}},
}
local function patch_quality_locale()
  for _, spec in ipairs(quality_locale_definitions) do
    local prototypes = data.raw[spec.proto_type]
    if prototypes then
      for _, name in ipairs(spec.names) do
        local proto = prototypes[name]
        if proto then
          proto.localised_name = {"mechanicist-quality." .. spec.category .. "." .. name}
          if spec.descriptions then
            local description_section = string.gsub(spec.category, "%-name$", "-description")
            proto.localised_description = {
              "mechanicist-quality." .. description_section .. "." .. name
            }
          end
        end
      end
    end
  end
end
if mods and (mods["quality"] or mods["recycler"]) then
  if startup_value("rename-quality", true) then
    patch_quality_locale()
    debug_log("Applied Quality prototype localization layer.")
  else
    debug_log("Quality retheme disabled; existing prototype localization preserved.")
  end
end

-- -----------------------------------------------------------------------------
-- Space Age retheme layer. Unlike the base game layer, this is a single on/off
-- Red Priest of Mars conversion: if enabled, Space Age screams Mechanicus.

-- Only assign locale descriptions that exist in our Space Age locale file.
-- Otherwise keep the original Factorio description rather than showing an
-- "Unknown key" placeholder in-game. The manifest is checked by CI.
local space_age_description_keys = require("scripts.space_age_description_keys")

-- The names of Factorio prototypes are only unique WITHIN their type, not
-- across types. Never assign an item-name translation to a technology or entity
-- with the same internal name (big-mining-drill, railgun, scrap, etc.).
local item_type_lookup = {}
for _, prototype_type in ipairs(item_types) do item_type_lookup[prototype_type] = true end
for _, prototype_type in ipairs({
  "item-with-inventory", "item-with-label", "item-with-tags", "copy-paste-tool"
}) do item_type_lookup[prototype_type] = true end

local not_entity_type = {
  ["recipe"] = true, ["technology"] = true, ["fluid"] = true,
  ["tile"] = true, ["optimized-decorative"] = true, ["decorative"] = true,
  ["planet"] = true, ["space-location"] = true, ["asteroid-chunk"] = true,
  ["quality"] = true, ["ammo-category"] = true, ["fuel-category"] = true,
  ["airborne-pollutant"] = true, ["autoplace-control"] = true,
  ["virtual-signal"] = true, ["item-group"] = true, ["item-subgroup"] = true,
  ["recipe-category"] = true, ["noise-expression"] = true, ["noise-function"] = true,
  ["tips-and-tricks-item"] = true, ["tips-and-tricks-item-category"] = true,
  ["mod-data"] = true, ["custom-input"] = true
}
local function is_achievement_type(prototype_type)
  return prototype_type == "achievement" or
    string.sub(prototype_type, -12) == "-achievement"
end
local function is_equipment_type(prototype_type)
  return prototype_type == "equipment" or
    string.sub(prototype_type, -10) == "-equipment"
end
local function locale_type_matches(prototype_type, category)
  if category == "item-name" then return item_type_lookup[prototype_type] == true end
  if category == "fluid-name" then return prototype_type == "fluid" end
  if category == "recipe-name" then return prototype_type == "recipe" end
  if category == "technology-name" then return prototype_type == "technology" end
  if category == "tile-name" then return prototype_type == "tile" end
  if category == "decorative-name" then
    return prototype_type == "optimized-decorative" or prototype_type == "decorative"
  end
  if category == "equipment-name" then return is_equipment_type(prototype_type) end
  if category == "space-location-name" then
    return prototype_type == "planet" or prototype_type == "space-location"
  end
  if category == "asteroid-chunk-name" then return prototype_type == "asteroid-chunk" end
  if category == "ammo-category-name" then return prototype_type == "ammo-category" end
  if category == "fuel-category-name" then return prototype_type == "fuel-category" end
  if category == "achievement-name" then return is_achievement_type(prototype_type) end
  if category == "airborne-pollutant-name" then return prototype_type == "airborne-pollutant" end
  if category == "autoplace-control-names" then return prototype_type == "autoplace-control" end
  if category == "entity-name" then
    return not item_type_lookup[prototype_type] and
      not not_entity_type[prototype_type] and
      not is_equipment_type(prototype_type) and
      not is_achievement_type(prototype_type)
  end
  error("Unknown Space Age localization category: " .. tostring(category))
end

local function apply_locale_to_matching_prototype_type(name, name_section, description_section)
  for prototype_type, prototypes in pairs(data.raw) do
    if locale_type_matches(prototype_type, name_section) and prototypes[name] then
      local proto = prototypes[name]
      proto.localised_name = {"mechanicist-space-age." .. name_section .. "." .. name}
      if description_section and
          space_age_description_keys[description_section] and
          space_age_description_keys[description_section][name] then
        proto.localised_description = {
          "mechanicist-space-age." .. description_section .. "." .. name
        }
      end
    end
  end
end

local space_age_locale_sets = {
  {
    name_section = "entity-name",
    description_section = "entity-description",
    names = {
    "vulcanus-chimney",
    "vulcanus-chimney-faded",
    "vulcanus-chimney-cold",
    "vulcanus-chimney-short",
    "vulcanus-chimney-truncated",
    "huge-volcanic-rock",
    "big-volcanic-rock",
    "boompuff-explosion",
    "biochamber",
    "scrap",
    "fulgoran-ruin-attractor",
    "fulgoran-ruin-stonehenge",
    "fulgoran-ruin-vault",
    "fulgoran-ruin-colossal",
    "fulgoran-ruin-huge",
    "fulgoran-ruin-big",
    "fulgoran-ruin-medium",
    "fulgoran-ruin-small",
    "fulgurite",
    "fulgurite-small",
    "recycler",
    "turbo-loader",
    "space-platform-hub",
    "cargo-bay",
    "cargo-bay-remnants",
    "tungsten-ore",
    "calcite",
    "sulfuric-acid-geyser",
    "fluorine-vent",
    "lithium-brine",
    "big-mining-drill",
    "big-mining-drill-remnants",
    "agricultural-tower",
    "asteroid-collector",
    "huge-metallic-asteroid",
    "big-metallic-asteroid",
    "medium-metallic-asteroid",
    "small-metallic-asteroid",
    "huge-carbonic-asteroid",
    "big-carbonic-asteroid",
    "medium-carbonic-asteroid",
    "small-carbonic-asteroid",
    "huge-oxide-asteroid",
    "big-oxide-asteroid",
    "medium-oxide-asteroid",
    "small-oxide-asteroid",
    "huge-promethium-asteroid",
    "big-promethium-asteroid",
    "medium-promethium-asteroid",
    "small-promethium-asteroid",
    "captive-biter-spawner",
    "biolab",
    "capture-robot",
    "capture-robot-rocket",
    "crusher",
    "cryogenic-plant",
    "electromagnetic-plant",
    "foundry",
    "fusion-reactor",
    "heating-tower",
    "lightning",
    "lightning-collector",
    "lightning-rod",
    "railgun-turret",
    "thruster",
    "tesla-turret",
    "tesla-turret-stun",
    "tesla-turret-slow",
    "turbo-transport-belt",
    "turbo-underground-belt",
    "turbo-splitter",
    "crater-cliff",
    "cliff-vulcanus",
    "cliff-gleba",
    "cliff-fulgora",
    "slipstack",
    "cuttlepop",
    "sunnycomb",
    "teflilly",
    "yumako-tree",
    "boompuff",
    "funneltrunk",
    "hairyclubnub",
    "jellystem",
    "lickmaw",
    "stingfrond",
    "ashland-lichen-tree",
    "ashland-lichen-tree-flaming",
    "rocket-turret",
    "lithium-iceberg-huge",
    "lithium-iceberg-big",
    "gleba-spawner",
    "gleba-spawner-small",
    "gleba-spawner-corpse",
    "gleba-spawner-corpse-small",
    "small-stomper-pentapod",
    "small-strafer-pentapod",
    "small-wriggler-pentapod",
    "small-wriggler-pentapod-corpse",
    "small-wriggler-pentapod-premature",
    "medium-stomper-pentapod",
    "medium-strafer-pentapod",
    "medium-wriggler-pentapod",
    "medium-wriggler-pentapod-corpse",
    "medium-wriggler-pentapod-premature",
    "big-stomper-pentapod",
    "big-strafer-pentapod",
    "big-wriggler-pentapod",
    "big-wriggler-pentapod-corpse",
    "big-wriggler-pentapod-premature",
    "small-stomper-corpse",
    "medium-stomper-corpse",
    "big-stomper-corpse",
    "small-strafer-corpse",
    "medium-strafer-corpse",
    "big-strafer-corpse",
    "small-stomper-shell",
    "medium-stomper-shell",
    "big-stomper-shell",
    "leg",
    "fusion-generator",
    "stack-inserter",
    "big-fulgora-rock",
    "small-demolisher",
    "medium-demolisher",
    "big-demolisher",
    "demolisher-segment",
    "demolisher-tail",
    "demolisher-corpse",
    "demolisher-ash-cloud",
    "demolisher-expanding-ash-cloud",
    "demolisher-ash-cloud-visual-dummy",
    "demolisher-fissure",
    "demolisher-fissure-scorchmark",
    "demolisher-fissure-explosion",
    "demolisher-fissure-damage-explosion",
    "demolisher-ash-cloud-trail",
    "demolisher-trail-upper",
    "demolisher-trail-lower",
    "vulcanus-cliff-collapse",
    "iron-stromatolite",
    "copper-stromatolite",
    "water-cane",
    "wube-logo-space-platform"
  }
  },
  {
    name_section = "item-name",
    description_section = "item-description",
    names = {
    "yumako-mash",
    "jelly",
    "iron-bacteria",
    "copper-bacteria",
    "bioflux",
    "artificial-yumako-soil",
    "overgrowth-yumako-soil",
    "artificial-jellynut-soil",
    "overgrowth-jellynut-soil",
    "nutrients",
    "jellynut",
    "yumako-seed",
    "jellynut-seed",
    "tree-seed",
    "ice",
    "scrap",
    "space-platform-foundation",
    "space-platform-starter-pack",
    "agricultural-science-pack",
    "metallic-asteroid-chunk",
    "carbonic-asteroid-chunk",
    "oxide-asteroid-chunk",
    "promethium-asteroid-chunk",
    "big-mining-drill",
    "calcite",
    "captive-biter-spawner",
    "biolab",
    "capture-robot-rocket",
    "carbon",
    "crusher",
    "cryogenic-plant",
    "cryogenic-science-pack",
    "promethium-science-pack",
    "electromagnetic-science-pack",
    "fusion-power-cell",
    "holmium-ore",
    "holmium-plate",
    "lithium",
    "lithium-plate",
    "mech-armor",
    "metallurgic-science-pack",
    "quantum-processor",
    "railgun",
    "railgun-ammo",
    "supercapacitor",
    "superconductor",
    "tesla-ammo",
    "teslagun",
    "tungsten-carbide",
    "tungsten-ore",
    "tungsten-plate",
    "turbo-splitter",
    "turbo-transport-belt",
    "turbo-underground-belt",
    "yumako",
    "spoilage",
    "carbon-fiber",
    "biter-egg",
    "pentapod-egg",
    "ice-platform",
    "foundation"
  }
  },
  {
    name_section = "fluid-name",
    description_section = "fluid-description",
    names = {
    "lava",
    "ammoniacal-solution",
    "lithium-brine",
    "fluorine",
    "fluoroketone-cold",
    "fluoroketone-hot",
    "ammonia",
    "molten-copper",
    "molten-iron",
    "holmium-solution",
    "electrolyte",
    "thruster-fuel",
    "thruster-oxidizer",
    "fusion-plasma"
  }
  },
  {
    name_section = "recipe-name",
    description_section = "recipe-description",
    names = {
    "molten-iron-from-lava",
    "molten-copper-from-lava",
    "iron-ore-melting",
    "copper-ore-melting",
    "yumako-processing",
    "rocket-fuel-from-jelly",
    "jellynut-processing",
    "iron-bacteria",
    "iron-bacteria-cultivation",
    "copper-bacteria",
    "copper-bacteria-cultivation",
    "burnt-spoilage",
    "nutrients-from-spoilage",
    "nutrients-from-yumako-mash",
    "nutrients-from-bioflux",
    "nutrients-from-fish",
    "nutrients-from-biter-egg",
    "wood-processing",
    "biosulfur",
    "biolubricant",
    "fish-breeding",
    "simple-coal-liquefaction",
    "coal-synthesis",
    "advanced-metallic-asteroid-crushing",
    "advanced-carbonic-asteroid-crushing",
    "advanced-oxide-asteroid-crushing",
    "ice-melting",
    "metallic-asteroid-crushing",
    "metallic-asteroid-reprocessing",
    "carbonic-asteroid-crushing",
    "carbonic-asteroid-reprocessing",
    "oxide-asteroid-crushing",
    "oxide-asteroid-reprocessing",
    "fluoroketone",
    "fluoroketone-cooling",
    "bioplastic",
    "acid-neutralisation",
    "ammoniacal-solution-separation",
    "solid-fuel-from-ammonia",
    "advanced-thruster-fuel",
    "advanced-thruster-oxidizer",
    "concrete-from-molten-iron",
    "casting-low-density-structure",
    "casting-iron",
    "casting-steel",
    "casting-copper",
    "casting-iron-gear-wheel",
    "casting-iron-stick",
    "casting-pipe",
    "casting-pipe-to-ground",
    "casting-copper-cable",
    "steam-condensation",
    "scrap-recycling",
    "ammonia-rocket-fuel"
  }
  },
  {
    name_section = "technology-name",
    description_section = "technology-description",
    names = {
    "space-platform",
    "bioflux",
    "bacteria-cultivation",
    "artificial-soil",
    "stack-inserter",
    "transport-belt-capacity",
    "toolbelt-equipment",
    "biolab",
    "fish-breeding",
    "space-platform-thruster",
    "planet-discovery-vulcanus",
    "planet-discovery-gleba",
    "planet-discovery-fulgora",
    "planet-discovery-aquilo",
    "electric-weapons-damage",
    "scrap-recycling-productivity",
    "battery-mk3-equipment",
    "fusion-reactor-equipment",
    "artillery-shell-damage",
    "foundry",
    "tungsten-carbide",
    "tungsten-steel",
    "turbo-transport-belt",
    "big-mining-drill",
    "metallurgic-science-pack",
    "railgun",
    "laser-weapons-damage",
    "railgun-shooting-speed",
    "railgun-damage",
    "mech-armor",
    "agriculture",
    "tree-seeding",
    "captivity",
    "captive-biter-spawner",
    "jellynut",
    "bioflux-processing",
    "biochamber",
    "agricultural-science-pack",
    "biter-egg-handling",
    "overgrowth-soil",
    "health",
    "holmium-processing",
    "electromagnetic-plant",
    "electromagnetic-science-pack",
    "rail-support-foundations",
    "tesla-weapons",
    "heating-tower",
    "cryogenic-plant",
    "quantum-processor",
    "cryogenic-science-pack",
    "fusion-reactor",
    "research-productivity",
    "asteroid-productivity",
    "asteroid-reprocessing",
    "advanced-asteroid-processing",
    "lightning-collector",
    "processing-unit-productivity",
    "steel-plate-productivity",
    "low-density-structure-productivity",
    "plastic-bar-productivity",
    "rocket-fuel-productivity",
    "rocket-part-productivity",
    "yumako",
    "rocket-turret",
    "carbon-fiber",
    "calcite-processing",
    "lithium-processing",
    "promethium-science-pack",
    "foundation"
  }
  },
  {
    name_section = "equipment-name",
    description_section = nil,
    names = {
    "toolbelt-equipment",
    "battery-mk3-equipment",
    "fusion-reactor-equipment"
  }
  },
  {
    name_section = "tile-name",
    description_section = nil,
    names = {
    "lowland-olive-blubber-2",
    "lowland-olive-blubber-3",
    "lowland-brown-blubber",
    "lowland-pale-green",
    "lowland-cream-cauliflower-2",
    "lowland-cream-red",
    "lowland-dead-skin",
    "lowland-dead-skin-2",
    "lowland-red-vein-2",
    "lowland-red-vein-3",
    "lowland-red-vein-4",
    "lowland-red-vein-dead",
    "lowland-red-infection",
    "midland-cracked-lichen",
    "midland-cracked-lichen-dull",
    "midland-cracked-lichen-dark",
    "midland-turquoise-bark-2",
    "midland-yellow-crust",
    "midland-yellow-crust-2",
    "midland-yellow-crust-3",
    "midland-yellow-crust-4",
    "highland-dark-rock-2",
    "highland-yellow-rock",
    "pit-rock",
    "empty-space",
    "space-platform-foundation",
    "snow-flat",
    "snow-crests",
    "snow-lumpy",
    "snow-patchy",
    "dust-flat",
    "dust-crests",
    "dust-lumpy",
    "dust-patchy",
    "brash-ice",
    "ice-rough",
    "ice-smooth",
    "ice-platform",
    "frozen-stone-path",
    "frozen-concrete",
    "frozen-hazard-concrete-left",
    "frozen-hazard-concrete-right",
    "frozen-refined-concrete",
    "frozen-refined-hazard-concrete-left",
    "frozen-refined-hazard-concrete-right",
    "oil-ocean-shallow",
    "oil-ocean-deep",
    "wetland-yumako",
    "wetland-jellynut",
    "ammoniacal-ocean",
    "ammoniacal-ocean-2",
    "natural-yumako-soil",
    "natural-jellynut-soil",
    "artificial-yumako-soil",
    "artificial-jellynut-soil",
    "overgrowth-yumako-soil",
    "overgrowth-jellynut-soil",
    "wetland-light-green-slime",
    "wetland-green-slime",
    "wetland-light-dead-skin",
    "wetland-dead-skin",
    "wetland-pink-tentacle",
    "wetland-red-tentacle",
    "wetland-blue-slime",
    "gleba-deep-lake",
    "lowland-olive-blubber",
    "lowland-cream-cauliflower",
    "lowland-red-vein",
    "midland-turquoise-bark",
    "highland-dark-rock",
    "lava-hot",
    "lava",
    "volcanic-cracks-hot",
    "volcanic-cracks-warm",
    "volcanic-cracks",
    "volcanic-smooth-stone",
    "volcanic-smooth-stone-warm",
    "volcanic-folds-warm",
    "volcanic-folds",
    "volcanic-folds-flat",
    "volcanic-jagged-ground",
    "volcanic-pumice-stones",
    "volcanic-soil-dark",
    "volcanic-soil-light",
    "volcanic-ash-dark",
    "volcanic-ash-light",
    "volcanic-ash-flats",
    "volcanic-ash-soil",
    "volcanic-ash-cracks",
    "fulgoran-rock",
    "fulgoran-dust",
    "fulgoran-sand",
    "fulgoran-dunes",
    "fulgoran-paving",
    "fulgoran-walls",
    "fulgoran-conduit",
    "fulgoran-machinery",
    "foundation"
  }
  },
  {
    name_section = "decorative-name",
    description_section = nil,
    names = {
    "black-sceptre",
    "pink-phalanges",
    "green-cup",
    "coral-water",
    "coral-land",
    "coral-stunted",
    "coral-stunted-grey",
    "yellow-lettuce-lichen-1x1",
    "yellow-lettuce-lichen-3x3",
    "yellow-lettuce-lichen-6x6",
    "yellow-lettuce-lichen-cups-1x1",
    "yellow-lettuce-lichen-cups-3x3",
    "yellow-lettuce-lichen-cups-6x6",
    "honeycomb-fungus",
    "honeycomb-fungus-1x1",
    "honeycomb-fungus-decayed",
    "green-lettuce-lichen-1x1",
    "green-lettuce-lichen-3x3",
    "green-lettuce-lichen-6x6",
    "green-lettuce-lichen-water-1x1",
    "green-lettuce-lichen-water-3x3",
    "green-lettuce-lichen-water-6x6",
    "pale-lettuce-lichen-1x1",
    "pale-lettuce-lichen-3x3",
    "pale-lettuce-lichen-6x6",
    "pale-lettuce-lichen-water-1x1",
    "pale-lettuce-lichen-water-3x3",
    "pale-lettuce-lichen-water-6x6",
    "split-gill-1x1",
    "split-gill-2x2",
    "split-gill-dying-1x1",
    "split-gill-dying-2x2",
    "split-gill-red-1x1",
    "split-gill-red-2x2",
    "fuchsia-pita",
    "wispy-lichen",
    "mycelium",
    "veins",
    "veins-small",
    "fulgoran-gravewort",
    "urchin-cactus",
    "brambles",
    "blood-grape",
    "blood-grape-vibrant",
    "brown-cup",
    "polycephalum-slime",
    "polycephalum-balloon",
    "curly-roots-orange",
    "curly-roots-grey",
    "pale-lettuce-lichen-cups-1x1",
    "pale-lettuce-lichen-cups-3x3",
    "pale-lettuce-lichen-cups-6x6",
    "gleba-spawner-slime",
    "medium-volcanic-rock",
    "small-volcanic-rock",
    "tiny-volcanic-rock",
    "tiny-rock-cluster",
    "small-sulfur-rock",
    "tiny-sulfur-rock",
    "sulfur-rock-cluster",
    "v-green-hairy-grass",
    "v-brown-hairy-grass",
    "v-brown-carpet-grass",
    "v-red-pita",
    "vulcanus-rock-decal-large",
    "vulcanus-crack-decal",
    "vulcanus-crack-decal-large",
    "vulcanus-crack-decal-huge-warm",
    "vulcanus-crack-decal-warm",
    "calcite-stain",
    "calcite-stain-small",
    "sulfur-stain",
    "sulfur-stain-small",
    "sulfuric-acid-puddle",
    "sulfuric-acid-puddle-small",
    "crater-small",
    "crater-large",
    "pumice-relief-decal",
    "vulcanus-sand-decal",
    "vulcanus-dune-decal",
    "vulcanus-lava-fire",
    "waves-decal",
    "barnacles-decal",
    "grey-cracked-mud-decal",
    "pink-lichen-decal",
    "lithium-iceberg-medium",
    "lithium-iceberg-small",
    "lithium-iceberg-tiny",
    "space-platform-decorative-tiny",
    "space-platform-decorative-1x1",
    "space-platform-decorative-2x2",
    "space-platform-decorative-4x4",
    "space-platform-decorative-pipes-1x1",
    "space-platform-decorative-pipes-1x2",
    "space-platform-decorative-pipes-2x1",
    "medium-fulgora-rock",
    "small-fulgora-rock",
    "tiny-fulgora-rock",
    "fulgoran-ruin-tiny",
    "solo-barnacle",
    "yellow-coral",
    "matches-small",
    "white-carpet-grass",
    "nerve-roots-dense",
    "nerve-roots-sparse",
    "red-nerve-roots-veins-dense",
    "red-nerve-roots-veins-sparse",
    "purple-nerve-roots-veins-dense",
    "purple-nerve-roots-veins-sparse",
    "cream-nerve-roots-veins-dense",
    "cream-nerve-roots-veins-sparse",
    "knobbly-roots",
    "knobbly-roots-orange",
    "red-lichen-decal",
    "floating-iceberg-large",
    "floating-iceberg-small",
    "aqulio-ice-decal-blue",
    "aqulio-snowy-decal",
    "snow-drift-decal"
  }
  },
  {
    name_section = "space-location-name",
    description_section = "space-location-description",
    names = {
    "vulcanus",
    "gleba",
    "fulgora",
    "aquilo",
    "solar-system-edge",
    "shattered-planet"
  }
  },
  {
    name_section = "asteroid-chunk-name",
    description_section = nil,
    names = {
    "metallic-asteroid-chunk",
    "carbonic-asteroid-chunk",
    "oxide-asteroid-chunk",
    "promethium-asteroid-chunk"
  }
  },
  {
    name_section = "ammo-category-name",
    description_section = nil,
    names = {
    "railgun",
    "tesla",
    "seismic"
  }
  },
  {
    name_section = "fuel-category-name",
    description_section = nil,
    names = {
    "food",
    "nutrients",
    "fusion"
  }
  },
  {
    name_section = "achievement-name",
    description_section = "achievement-description",
    names = {
    "second-star-to-the-right-and-straight-on-till-morning",
    "rush-to-space",
    "todays-fish-is-trout-a-la-creme",
    "work-around-the-clock",
    "express-delivery",
    "reach-for-the-stars",
    "visit-fulgora",
    "visit-vulcanus",
    "visit-gleba",
    "visit-aquilo",
    "research-with-metallurgics",
    "research-with-agriculture",
    "research-with-electromagnetics",
    "research-with-cryogenics",
    "research-with-promethium",
    "crafting-with-quality",
    "if-it-bleeds",
    "we-need-bigger-guns",
    "size-doesnt-matter",
    "make-it-better",
    "look-at-my-shiny-rare-armor",
    "my-modules-are-legendary",
    "no-room-for-more",
    "fusion-power",
    "shattered-planet-1",
    "shattered-planet-2",
    "shattered-planet-3",
    "it-stinks-and-they-do-like-it",
    "get-off-my-lawn"
  }
  },
  {
    name_section = "airborne-pollutant-name",
    description_section = nil,
    names = {
    "spores"
  }
  },
  {
    name_section = "autoplace-control-names",
    description_section = nil,
    names = {
    "gleba_plants",
    "gleba_enemy_base",
    "gleba_water",
    "fulgora_islands",
    "vulcanus_volcanism",
    "gleba_cliff",
    "fulgora_cliff"
  }
  },
}

local function patch_space_age_locale()
  for _, set in pairs(space_age_locale_sets) do
    for _, name in pairs(set.names) do
      apply_locale_to_matching_prototype_type(name, set.name_section, set.description_section)
    end
  end
end

if mods and mods["space-age"] then
  if startup_value("rename-space-age", true) then
    patch_space_age_locale()
    debug_log("Applied mechanicist-space-age prototype localization layer.")
  else
    debug_log("Space Age retheme disabled; existing prototype localization preserved.")
  end
end

-- -----------------------------------------------------------------------------
-- Orky Business / Mekboy Reskin compatibility hook.
-- Internal mod name: ORKYMiniMAX.
-- This is intentionally a data-stage no-op for now; runtime warning behavior
-- belongs in control.lua.

if mods and mods["ORKYMiniMAX"] then
  debug_log("Detected ORKYMiniMAX / Orky Business Mekboy Reskin; no prototype patches applied in data-updates.lua.")
end


-- Read-only in-engine regression assertions, exercised via CI mod-settings.dat.
-- They check real Factorio prototype assignments after all retheme passes.
if startup_value("debug-locale-audit", false) then
  local probes = 0
  local function verify(proto_type, name, expected_key, excluded_prefix)
    local candidates = data.raw[proto_type]
    local prototype = candidates and candidates[name]
    if not prototype then return end
    local raw = prototype.localised_name
    local actual = type(raw) == "table" and raw[1] or ""
    if expected_key then
      if actual ~= expected_key then
        error("LOCALE_AUDIT_FAIL " .. proto_type .. "/" .. name ..
          " expected=" .. expected_key .. " actual=" .. tostring(actual))
      end
    elseif excluded_prefix and type(actual) == "string" and
        string.sub(actual, 1, #excluded_prefix) == excluded_prefix then
      error("LOCALE_AUDIT_FAIL disabled retheme altered " ..
        proto_type .. "/" .. name .. " to " .. actual)
    end
    probes = probes + 1
  end
  local vanilla_enabled = rename_vanilla and intensity ~= "off"
  local vanilla_prefix = intensity == "heresy" and "mechanicist-heresy." or "mechanicist-standard."
  local function verify_base(proto_type, name, category)
    local expected = vanilla_enabled and (vanilla_prefix .. category .. "." .. name) or nil
    verify(proto_type, name, expected, vanilla_prefix)
  end
  verify_base("item", "iron-plate", "item-name")
  verify_base("technology", "automation", "technology-name")

  local quality_enabled = mods and mods["quality"] and startup_value("rename-quality", true)
  if mods and mods["quality"] then
    local prefix = "mechanicist-quality."
    verify("quality", "rare",
      quality_enabled and (prefix .. "quality-name.rare") or nil, prefix)
    verify("module", "quality-module",
      quality_enabled and (prefix .. "item-name.quality-module") or nil, prefix)
    verify("technology", "quality-module",
      quality_enabled and (prefix .. "technology-name.quality-module") or nil, prefix)
    if not (mods and mods["space-age"] and startup_value("rename-space-age", true)) then
      verify("furnace", "recycler",
        quality_enabled and (prefix .. "entity-name.recycler") or nil, prefix)
    end
  end

  if mods and mods["space-age"] then
    local active = startup_value("rename-space-age", true)
    local probes_for_space_age = {
      {"assembling-machine", "big-mining-drill", "entity-name"},
      {"item", "big-mining-drill", "item-name"},
      {"technology", "big-mining-drill", "technology-name"},
      {"resource", "scrap", "entity-name"},
      {"item", "scrap", "item-name"},
      {"gun", "railgun", "item-name"},
      {"technology", "railgun", "technology-name"},
      {"ammo-category", "railgun", "ammo-category-name"},
      {"tile", "space-platform-foundation", "tile-name"},
      {"item", "space-platform-foundation", "item-name"},
      {"furnace", "recycler", "entity-name"},
    }
    for _, probe in ipairs(probes_for_space_age) do
      local key = "mechanicist-space-age." .. probe[3] .. "." .. probe[2]
      verify(probe[1], probe[2], active and key or nil, "mechanicist-space-age.")
    end
  end
  log("LOCALE_AUDIT_PASS checked=" .. probes .. " intensity=" .. tostring(intensity) ..
      " quality=" .. tostring(startup_value("rename-quality", true)) ..
      " space-age=" .. tostring(startup_value("rename-space-age", true)))
end
