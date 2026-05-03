-- Mechanicist Factorio
-- scripts/informatron.lua
--
-- Registers Mechanicist Factorio documentation pages with Informatron.
-- Locale files provide the text; this file exposes the menu tree and renders
-- the requested page content.
--
-- This file must exist at:
--   mechanicist-factorio_0.1.1/scripts/informatron.lua

local function mod_active(name)
  return script and script.active_mods and script.active_mods[name] ~= nil
end

local function always_active()
  return true
end

local pages = {
  base = {
    interface = "mechanicist-factorio",
    locale = "mechanicist-factorio",
    active = always_active,
    menu = {
      "mechanicist-overview",
      "mechanicist-settings",
      "mechanicist-compat",
      "mechanicist-roadmap",
      "mechanicist-loop",
      "mechanicist-first-ten",
      "mechanicist-mining",
      "mechanicist-power",
      "mechanicist-automation",
      "mechanicist-logistics",
      "mechanicist-research",
      "mechanicist-defense",
      "mechanicist-oil",
      "mechanicist-circuits",
      "mechanicist-rail",
      "mechanicist-robots",
      "mechanicist-modules",
      "mechanicist-nuclear",
      "mechanicist-rocket",
      "mechanicist-space-age",
      "mechanicist-quality",
      "mechanicist-survival",
      "mechanicist-glossary",
      "mechanicist-heresy"
    },
    text_counts = {
      ["mechanicist-factorio"] = 1,
      ["mechanicist-overview"] = 1,
      ["mechanicist-settings"] = 2,
      ["mechanicist-compat"] = 1,
      ["mechanicist-roadmap"] = 1,
      ["mechanicist-loop"] = 1,
      ["mechanicist-first-ten"] = 2,
      ["mechanicist-mining"] = 1,
      ["mechanicist-power"] = 1,
      ["mechanicist-automation"] = 1,
      ["mechanicist-logistics"] = 1,
      ["mechanicist-research"] = 1,
      ["mechanicist-defense"] = 2,
      ["mechanicist-oil"] = 1,
      ["mechanicist-circuits"] = 1,
      ["mechanicist-rail"] = 1,
      ["mechanicist-robots"] = 1,
      ["mechanicist-modules"] = 1,
      ["mechanicist-nuclear"] = 1,
      ["mechanicist-rocket"] = 1,
      ["mechanicist-space-age"] = 1,
      ["mechanicist-quality"] = 1,
      ["mechanicist-survival"] = 1,
      ["mechanicist-glossary"] = 1,
      ["mechanicist-heresy"] = 1,
    }
  },

  space_age = {
    interface = "mechanicist-space-age",
    locale = "mechanicist-space-age",
    active = function() return mod_active("space-age") end,
    menu = {
      "mechanicist-space-age-orbit",
      "mechanicist-space-age-cargo",
      "mechanicist-space-age-vulcanus",
      "mechanicist-space-age-gleba",
      "mechanicist-space-age-fulgora",
      "mechanicist-space-age-aquilo",
      "mechanicist-space-age-machines",
      "mechanicist-space-age-science",
      "mechanicist-space-age-threats",
      "mechanicist-space-age-quality",
      "mechanicist-space-age-checklist",
      "mechanicist-space-age-heresy"
    },
    text_counts = {
      ["mechanicist-space-age"] = 2,
      ["mechanicist-space-age-orbit"] = 3,
      ["mechanicist-space-age-cargo"] = 2,
      ["mechanicist-space-age-vulcanus"] = 3,
      ["mechanicist-space-age-gleba"] = 3,
      ["mechanicist-space-age-fulgora"] = 3,
      ["mechanicist-space-age-aquilo"] = 3,
      ["mechanicist-space-age-machines"] = 2,
      ["mechanicist-space-age-science"] = 2,
      ["mechanicist-space-age-threats"] = 2,
      ["mechanicist-space-age-quality"] = 1,
      ["mechanicist-space-age-checklist"] = 1,
      ["mechanicist-space-age-heresy"] = 1,
    }
  },

  quality = {
    interface = "mechanicist-quality",
    locale = "mechanicist-quality",
    active = function() return mod_active("quality") end,
    menu = {
      "mechanicist-quality-core-loop",
      "mechanicist-quality-grades",
      "mechanicist-quality-modules",
      "mechanicist-quality-recycling",
      "mechanicist-quality-filtering",
      "mechanicist-quality-production-chains",
      "mechanicist-quality-machines",
      "mechanicist-quality-armor-equipment",
      "mechanicist-quality-modules-beacons",
      "mechanicist-quality-space-age",
      "mechanicist-quality-difficulty",
      "mechanicist-quality-checklist",
      "mechanicist-quality-final-warning"
    },
    text_counts = {
      ["mechanicist-quality"] = 1,
      ["mechanicist-quality-core-loop"] = 1,
      ["mechanicist-quality-grades"] = 1,
      ["mechanicist-quality-modules"] = 1,
      ["mechanicist-quality-recycling"] = 1,
      ["mechanicist-quality-filtering"] = 1,
      ["mechanicist-quality-production-chains"] = 1,
      ["mechanicist-quality-machines"] = 1,
      ["mechanicist-quality-armor-equipment"] = 1,
      ["mechanicist-quality-modules-beacons"] = 1,
      ["mechanicist-quality-space-age"] = 1,
      ["mechanicist-quality-difficulty"] = 1,
      ["mechanicist-quality-checklist"] = 1,
      ["mechanicist-quality-final-warning"] = 1,
    }
  },

  rampant_fixed = {
    interface = "mechanicist-rampant-fixed",
    locale = "mechanicist-rampant-fixed",
    active = function() return mod_active("RampantFixed") end,
    menu = {
      "mechanicist-rampant-fixed-overview",
      "mechanicist-rampant-fixed-what-it-does",
      "mechanicist-rampant-fixed-vanilla-vs-rampant",
      "mechanicist-rampant-fixed-pollution",
      "mechanicist-rampant-fixed-early-game",
      "mechanicist-rampant-fixed-kill-zones",
      "mechanicist-rampant-fixed-logistics",
      "mechanicist-rampant-fixed-radar",
      "mechanicist-rampant-fixed-expansion",
      "mechanicist-rampant-fixed-artillery",
      "mechanicist-rampant-fixed-weapons",
      "mechanicist-rampant-fixed-space-age",
      "mechanicist-rampant-fixed-lessons",
      "mechanicist-rampant-fixed-checklist",
      "mechanicist-rampant-fixed-final-admonition"
    },
    text_counts = {
      ["mechanicist-rampant-fixed"] = 1,
      ["mechanicist-rampant-fixed-overview"] = 1,
      ["mechanicist-rampant-fixed-what-it-does"] = 1,
      ["mechanicist-rampant-fixed-vanilla-vs-rampant"] = 1,
      ["mechanicist-rampant-fixed-pollution"] = 1,
      ["mechanicist-rampant-fixed-early-game"] = 1,
      ["mechanicist-rampant-fixed-kill-zones"] = 1,
      ["mechanicist-rampant-fixed-logistics"] = 1,
      ["mechanicist-rampant-fixed-radar"] = 1,
      ["mechanicist-rampant-fixed-expansion"] = 1,
      ["mechanicist-rampant-fixed-artillery"] = 1,
      ["mechanicist-rampant-fixed-weapons"] = 1,
      ["mechanicist-rampant-fixed-space-age"] = 1,
      ["mechanicist-rampant-fixed-lessons"] = 1,
      ["mechanicist-rampant-fixed-checklist"] = 1,
      ["mechanicist-rampant-fixed-final-admonition"] = 1,
    }
  },
}

local function menu_for(def)
  return function(data)
    local menu = {}
    for _, page_name in ipairs(def.menu) do
      menu[page_name] = 1
    end
    return menu
  end
end

local function add_text(element, locale_section, page_name, index)
  element.add{
    type = "label",
    name = page_name .. "_text_" .. index,
    caption = {locale_section .. ".page_" .. page_name .. "_text_" .. index},
    single_line = false
  }
end

local function page_content_for(def)
  return function(data)
    local page_name = data.page_name
    local element = data.element
    if not element or not element.valid then return end

    local count = def.text_counts[page_name]
    if not count then return end

    for i = 1, count do
      add_text(element, def.locale, page_name, i)
    end
  end
end

for _, def in pairs(pages) do
  if def.active() then
    remote.add_interface(def.interface, {
      informatron_menu = menu_for(def),
      informatron_page_content = page_content_for(def)
    })
  end
end
