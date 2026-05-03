-- Mechanicist Factorio
-- control.lua
--
-- Runtime scaffold. Prototype names/descriptions are handled during the data
-- stage. This file handles runtime integrations such as Informatron and optional
-- flavor GUI warnings.

local MOD_NAME = "mechanicist-factorio"
local MOD_VERSION = "0.1.1"

local XENOS_WARNING_ELEMENT = "mechanicist_orky_business_xenos_warning"
local XENOS_WARNING_TICK_RATE = 30

local XENOS_WARNING_TEXT_A = "[img=utility/warning_icon] XENOS USER DETECTED"
local XENOS_WARNING_TEXT_B = "[img=utility/warning_icon] CRANIAL IMPLANT FAILURE"
local XENOS_WARNING_TOOLTIP =
  "Warning: Mechanicus-approved sanctified info implant has detected a xenos user!\n" ..
  "Attempting to self-detonate cranial implant...\n" ..
  "Detonation failed. Rebooting."

local function runtime_store()
  if storage ~= nil then
    storage.mechanicist_factorio = storage.mechanicist_factorio or {}
    return storage.mechanicist_factorio
  end
  return nil
end

local function informatron_available()
  return remote and remote.interfaces and remote.interfaces["informatron"] ~= nil
end

local function debug_enabled()
  if settings and settings.startup and settings.startup[MOD_NAME .. "-debug-locale-audit"] then
    return settings.startup[MOD_NAME .. "-debug-locale-audit"].value == true
  end
  return false
end

local function debug_log(message)
  if debug_enabled() then
    log("[Mechanicist Factorio] " .. message)
  end
end

local function orky_business_active()
  return script and script.active_mods and script.active_mods["ORKYMiniMAX"] ~= nil
end

local function ensure_xenos_warning_for_player(player)
  if not player or not player.valid or not player.gui or not player.gui.top then return end

  if not orky_business_active() then
    if player.gui.top[XENOS_WARNING_ELEMENT] and player.gui.top[XENOS_WARNING_ELEMENT].valid then
      player.gui.top[XENOS_WARNING_ELEMENT].destroy()
    end
    return
  end

  local element = player.gui.top[XENOS_WARNING_ELEMENT]
  if element and element.valid then
    element.tooltip = XENOS_WARNING_TOOLTIP
    return
  end

  player.gui.top.add{
    type = "button",
    name = XENOS_WARNING_ELEMENT,
    caption = XENOS_WARNING_TEXT_A,
    tooltip = XENOS_WARNING_TOOLTIP
  }
end

local function ensure_xenos_warning_for_all_players()
  if not game or not game.players then return end

  for _, player in pairs(game.players) do
    ensure_xenos_warning_for_player(player)
  end
end

local function update_xenos_warning_flash()
  if not orky_business_active() then return end
  if not game or not game.players then return end
  if (game.tick % XENOS_WARNING_TICK_RATE) ~= 0 then return end

  local caption = XENOS_WARNING_TEXT_A
  if math.floor(game.tick / XENOS_WARNING_TICK_RATE) % 2 == 1 then
    caption = XENOS_WARNING_TEXT_B
  end

  for _, player in pairs(game.players) do
    if player and player.valid and player.gui and player.gui.top then
      local element = player.gui.top[XENOS_WARNING_ELEMENT]
      if element and element.valid then
        element.caption = caption
        element.tooltip = XENOS_WARNING_TOOLTIP
      else
        ensure_xenos_warning_for_player(player)
      end
    end
  end
end

local function initialize_mechanicist_runtime()
  local store = runtime_store()
  if store then
    store.version = MOD_VERSION
    store.informatron_available = informatron_available()
    store.orky_business_active = orky_business_active()
  end

  ensure_xenos_warning_for_all_players()

  if orky_business_active() then
    debug_log("Detected ORKYMiniMAX / Orky Business Mekboy Reskin; xenos cranial implant warning enabled.")
  end

  debug_log("Runtime initialized.")
end

-- Register Informatron pages if the optional script exists.
-- Kept in pcall so a future script-side typo cannot hard-crash the whole runtime
-- before the base mod can be tested.
local ok, err = pcall(require, "scripts.informatron")
if not ok then
  log("[Mechanicist Factorio] Informatron runtime script not loaded: " .. tostring(err))
end

script.on_init(function()
  initialize_mechanicist_runtime()
end)

script.on_configuration_changed(function()
  initialize_mechanicist_runtime()
end)

script.on_event(defines.events.on_player_created, function(event)
  if event and event.player_index then
    ensure_xenos_warning_for_player(game.players[event.player_index])
  end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  if event and event.player_index then
    ensure_xenos_warning_for_player(game.players[event.player_index])
  end
end)

script.on_event(defines.events.on_tick, function()
  update_xenos_warning_flash()
end)
