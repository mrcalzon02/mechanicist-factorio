-- Mechanicist Factorio
-- settings.lua
-- Startup settings for locale/prototype retheme behavior.

local MOD_PREFIX = "mechanicist-factorio"

local function setting_name(suffix)
  return MOD_PREFIX .. "-" .. suffix
end

data:extend({
  {
    type = "string-setting",
    name = setting_name("language-intensity"),
    setting_type = "startup",
    default_value = "standard",
    allowed_values = {"off", "standard", "heresy"},
    order = "a[language]-a[intensity]"
  },
  {
    type = "bool-setting",
    name = setting_name("rename-vanilla"),
    setting_type = "startup",
    default_value = true,
    order = "a[language]-b[vanilla]"
  },
  {
    type = "bool-setting",
    name = setting_name("rename-space-age"),
    setting_type = "startup",
    default_value = true,
    order = "a[language]-c[space-age]"
  },
  {
    type = "bool-setting",
    name = setting_name("rename-quality"),
    setting_type = "startup",
    default_value = true,
    order = "a[language]-d[quality]"
  },
  {
    type = "bool-setting",
    name = setting_name("enable-qol-integrations"),
    setting_type = "startup",
    default_value = true,
    order = "b[compatibility]-a[qol]"
  },
  {
    type = "bool-setting",
    name = setting_name("preserve-search-terms"),
    setting_type = "startup",
    default_value = true,
    order = "b[compatibility]-b[search-terms]"
  },
  {
    type = "bool-setting",
    name = setting_name("verbose-descriptions"),
    setting_type = "startup",
    default_value = true,
    order = "c[flavor]-a[verbose]"
  },
  {
    type = "bool-setting",
    name = setting_name("debug-locale-audit"),
    setting_type = "startup",
    default_value = false,
    order = "z[debug]-a[locale-audit]"
  }
})
