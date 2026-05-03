# Mechanicist Factorio - Master Planning Document

## 1. Core Project Intent

Mechanicist Factorio is a thematic conversion project for Factorio 2.0 intended to translate the base game into a darker, more ritualized, industrial machine-cult style inspired by grim far-future war industry, priestly engineering, sacred logistics, manufactorum bureaucracy, and the slow spiritual corrosion of automation.

The first major goal is language conversion: item names, recipe names, technology names, entity names, tips, flavor text, descriptions, menu entries, and player-facing terminology should feel as though Factorio has been filtered through an Administratum archive, a Mechanicus forge ledger, and a deeply unwell production supervisor who believes every assembler has a soul and every missing gear wheel is a minor heresy.

The second major goal is progression conversion: the underlying shape of Factorio should remain recognizable, but the recipe tree and technology tree should be adjusted so that industrialization feels more like a ritualized ascent through sanctioned knowledge, material consecration, machine rites, logistics doctrine, and escalating permission structures.

The third major goal is compatibility: wherever possible, the mod should preserve the functional names, prototype keys, and expected base-game references that other mods rely on. The player-facing surface should change dramatically. The underlying machine-readable structure should change cautiously.

## 2. Compatibility Doctrine

This mod should not casually rename internal prototype keys for vanilla items, fluids, entities, technologies, recipes, equipment, tiles, or achievements. Factorio mods frequently depend on those keys remaining stable. If another mod expects `iron-plate`, `automation-science-pack`, `steel-processing`, `assembling-machine-2`, or `logistic-science-pack`, those keys should still exist and should still behave predictably unless there is a very specific reason to alter them.

The preferred method is localization override, not prototype replacement.

For example, the internal item key may remain:

```lua
iron-plate
```

But the displayed name may become something like:

```text
Sanctified Ferric Plate
```

The internal recipe key may remain:

```lua
automation-science-pack
```

But the displayed name may become something like:

```text
Litany of Basic Machine Permission
```

The internal technology key may remain:

```lua
automation
```

But the displayed name may become something like:

```text
First Rite of Automated Labor
```

This allows other mods to continue reading, extending, replacing, or depending on vanilla data structures while the player sees a heavily rethemed experience.

## 3. What Should Change First

The first phase should focus on safe, high-impact language conversion.

This includes:

- `locale/en/base.cfg` or equivalent localization files
- item names and descriptions
- recipe names and descriptions
- technology names and descriptions
- entity names and descriptions
- equipment and weapon descriptions
- tips, warnings, and tutorial-style text if practical
- mod settings names and descriptions
- Informatron or documentation entries, if used later

The first phase should avoid major prototype surgery. The goal is to establish the voice of the mod without breaking compatibility.

## 4. What Should Change Second

The second phase should begin adding new thematic layers while still respecting vanilla compatibility.

Possible additions include:

- ritual paperwork intermediates
- sanctioned machine components
- consecrated versions of existing intermediate products
- manufactorum compliance goods
- administratum requisition chains
- forge-certification materials
- doctrinal technology gates
- machine-spirit calibration items
- waste, scrap, incense, ash, contaminated residue, or rejected components

These additions should use a clear internal naming prefix so they do not collide with other mods. For example:

```lua
mechanicist-requisition-slip
mechanicist-sanctioned-cogitator-fragment
mechanicist-machine-oil-incense
mechanicist-forge-rite-document
```

New items should generally be added as supporting intermediates, not as destructive replacements for core vanilla resources.

## 5. Recipe Progression Philosophy

The base Factorio recipe tree should remain broadly recognizable, but the experience should be reframed.

Iron, copper, stone, coal, crude oil, circuits, engines, science packs, modules, logistics systems, military production, and rocket construction should still follow a familiar industrial escalation. However, the path between milestones can be made more ritualistic, bureaucratic, and grim.

The mod should ask:

- What would the Mechanicist cult believe this recipe means?
- What authorization, blessing, calibration, or certification would be required before this machine is allowed to exist?
- What residue, scrap, ash, corrupted waste, or failed component does this process produce?
- What technology should represent the knowledge required to make this step socially, spiritually, and industrially permissible?
- How can the process be made more thematic without making the game unreadable or incompatible?

The goal is not to make every recipe punishing. The goal is to make the factory feel like it is passing through layers of industrial doctrine.

## 6. Technology Progression Philosophy

Technologies should be renamed and described as sanctioned discoveries, recovered doctrines, machine rites, forge permissions, and dangerous revelations.

The base technology tree should mostly remain structurally intact at first. Prerequisites may be adjusted later, but should be handled carefully.

Possible technology naming patterns include:

- Rite of [Function]
- Doctrine of [System]
- Catechism of [Material]
- Litany of [Process]
- Sanctioned Use of [Machine]
- Recovered Pattern: [Technology]
- Forge Permission: [Production Class]
- Adept Clearance: [Industrial Capability]
- Omnissian Injunction: [Dangerous Capability]

Examples:

- Automation -> First Rite of Automated Labor
- Logistics -> Doctrine of Sacred Conveyance
- Steel Processing -> Catechism of Tempered Ferrum
- Oil Processing -> Rite of Black Sacrament Distillation
- Advanced Electronics -> Cogitator Substrate Doctrine
- Rocketry -> Litany of Ballistic Ascension
- Space Science -> Communion with the Void Archive

Descriptions should explain what the technology does mechanically while also making it sound like the player has been granted access to forbidden or highly regulated industrial knowledge.

## 7. Science Pack Retheme

Science packs are one of the most important thematic conversion targets because they represent progression itself.

The internal keys should remain unchanged for compatibility:

- `automation-science-pack`
- `logistic-science-pack`
- `military-science-pack`
- `chemical-science-pack`
- `production-science-pack`
- `utility-science-pack`
- `space-science-pack`

The displayed names can be rethemed aggressively.

Possible names:

- Automation Science Pack -> Basic Machine Rite Dossier
- Logistic Science Pack -> Sacred Conveyance Dossier
- Military Science Pack -> Munitorum Violence Authorization
- Chemical Science Pack -> Alchemical Refinement Dossier
- Production Science Pack -> Manufactorum Expansion Writ
- Utility Science Pack -> High Function Cogitator Writ
- Space Science Pack -> Void Communion Data Reliquary

The recipes may eventually be modified to include paperwork, machine rites, or consecrated components, but the internal science pack items should remain compatible with vanilla research units unless there is an explicit compatibility layer.

## 8. Space Age Integration

The mod is intended primarily for default Factorio with Space Age and Quality available. Space Age content should be rethemed after the base-game foundation is stable.

Each planet or major Space Age system can be reframed as a different kind of forge world, shrine world, quarantine zone, extraction moon, or forbidden research site.

Possible directions:

- Vulcanus: forge world, magma shrine, foundry pilgrimage, metallurgical penitence
- Fulgora: dead data world, storm-wracked archive, corrupted circuitry reliquary
- Gleba: bio-alchemical plague garden, nutrient shrine, rot-fueled production sacrament
- Aquilo: cryogenic penance world, frozen logistics trial, cold-machine endurance rite
- Space platforms: void chapels, orbital reliquaries, logistics cathedrals, machine shrines

The same compatibility doctrine applies: display names and descriptions can change heavily, but internal prototype names should remain stable unless the mod deliberately adds new content.

## 9. Quality Integration

Quality should be reframed as degrees of sanctification, inspection, or relic-grade refinement.

Possible displayed quality terms:

- Normal -> Standard Pattern
- Uncommon -> Approved Pattern
- Rare -> Sanctified Pattern
- Epic -> Relic Pattern
- Legendary -> Archeotech Pattern

If these names can be localized without breaking other mods, they should be converted. If not, the mod should use setting-controlled behavior so players can choose between vanilla-readable quality names and full Mechanicist terminology.

## 10. Quality-of-Life Mod Integration

Optional integrations should be conservative. The mod should detect popular QoL mods where practical and provide localization compatibility rather than hard dependency behavior.

Examples of possible QoL integration targets:

- search helper mods
- recipe browser mods
- factory planner mods
- rate calculator mods
- logistics helper mods
- UI organization mods
- Informatron-style documentation mods

The core rule is that QoL mods should remain useful. Theming should not make the game impossible to search, plan, or debug.

A setting should exist to preserve vanilla search terms in descriptions. This allows a player to search for `iron`, `copper`, `science`, `belt`, `assembler`, or `circuit` even when the displayed names have been fully converted.

## 11. Naming Style Guide

The tone should be grim, industrial, pseudo-religious, bureaucratic, and slightly absurd.

Good word families:

- rite
- litany
- catechism
- sanction
- writ
- dossier
- reliquary
- manufactorum
- ferric
- cupric
- cogitator
- datum
- engine-spirit
- machine-spirit
- doctrinal
- consecrated
- sanctified
- approved pattern
- recovered pattern
- void-rated
- forge-blessed
- munitorum
- administratum
- calibration
- compliance
- penitence
- ash
- slag
- residue
- sacred unguent
- black sacrament

Avoid overusing direct copyrighted faction names in prototype keys. The mod can evoke the style without relying on exact protected naming everywhere.

## 12. Description Style Guide

Descriptions should remain mechanically useful. A player should still be able to understand what an item or technology does.

Preferred structure:

1. First sentence: clear mechanical function.
2. Second sentence: thematic explanation.
3. Optional third sentence: warning, joke, bureaucratic cruelty, or grim machine-cult flavor.

Example:

```text
Used to craft basic transport belts and early automation components. Each strip of sanctioned iron is stamped, blessed, and entered into the forge ledger before being permitted to touch a machine casing. Unauthorized bending is punishable by reassignment to slag inspection.
```

The joke should not hide the function.

## 13. Recipe Modification Rules

When recipes are modified, follow these rules:

1. Preserve vanilla recipe keys where compatibility matters.
2. Avoid deleting vanilla recipes outright unless replacing them with a compatibility-safe equivalent.
3. Add new ingredients sparingly at first.
4. Prefer thematic intermediates that can be turned on or off by settings.
5. Keep early-game recipes readable and playable.
6. Avoid making basic automation require too many strange intermediates.
7. Use new items to add flavor, not to bury every recipe under six paperwork layers.
8. Maintain reasonable crafting times unless the whole tier is intentionally being stretched.
9. Keep science pack items valid as research tools.
10. Watch for fluid/item category errors when modifying recipes.

## 14. Technology Modification Rules

When technologies are modified, follow these rules:

1. Preserve technology keys where possible.
2. Retheme localization first.
3. Change prerequisites only after the localization pass is stable.
4. Add new technologies as side branches before inserting them into the main trunk.
5. Use settings to control heavier progression changes.
6. Keep multiplayer compatibility in mind.
7. Avoid invalid research ingredients; research units must use valid tool-type science items.
8. Keep the base progression legible to players using planners or recipe browsers.

## 15. Suggested Development Phases

### Phase 1 - Foundation

- Repair and finalize `info.json`.
- Write the README synopsis.
- Create startup settings for language intensity and integration behavior.
- Create this master planning document.

### Phase 2 - Base Localization Pass

- Rewrite base item names.
- Rewrite base item descriptions.
- Rewrite recipe names.
- Rewrite recipe descriptions.
- Rewrite technology names.
- Rewrite technology descriptions.
- Add vanilla search terms where useful.

### Phase 3 - Science and Progression Identity

- Retheme all science packs.
- Retheme labs, research, modules, beacons, and high-tier production.
- Identify the first safe recipe modifications.
- Add paperwork or sanctioning intermediates only where they improve the experience.

### Phase 4 - Recipe and Technology Restructuring

- Add new intermediate items.
- Add new side technologies.
- Modify select recipe requirements.
- Add optional stricter progression chains.
- Keep a compatibility setting for lighter behavior.

### Phase 5 - Space Age and Quality Retheme

- Retheme Space Age planets and mechanics.
- Retheme Quality names and descriptions.
- Add optional compatibility behavior for players who need default search language.

### Phase 6 - Documentation and Player Guidance

- Add in-game documentation if Informatron or another documentation mod is present.
- Explain what has been renamed.
- Explain any recipe changes.
- Explain any technology restructuring.
- Explain compatibility settings.
- Include a glossary mapping vanilla names to Mechanicist names.

### Phase 7 - Testing and Compatibility Audit

- Test with base Factorio only.
- Test with Space Age.
- Test with Quality.
- Test with common QoL mods.
- Test with recipe browser/planner mods.
- Check all modified technologies for valid science packs.
- Check all modified recipes for valid item/fluid categories.
- Check locale coverage for missing names and descriptions.

## 16. Major File Categories We Will Likely Need

Likely files or folders:

```text
info.json
README.md
settings.lua
locale/en/base.cfg
locale/en/settings.cfg
prototypes/items.lua
prototypes/recipes.lua
prototypes/technology.lua
prototypes/categories.lua
prototypes/integration-space-age.lua
prototypes/integration-quality.lua
prototypes/integration-qol.lua
control.lua
```

Not every file is required immediately. The safest order is metadata, settings, localization, then prototypes.

## 17. Immediate Next Work Items

1. Build or revise the English locale file.
2. Decide the exact naming style for science packs.
3. Decide whether vanilla search terms should appear in descriptions by default.
4. Create a base-game terminology map from vanilla to Mechanicist terms.
5. Identify which recipes are safe to retheme only and which should eventually be modified.
6. Identify which technologies should remain structurally untouched and which can receive new side-branch prerequisites.
7. Establish the internal prefix for new prototype keys.

Recommended internal prefix:

```text
mechanicist-
```

## 18. Prime Directive

The surface language may become unhinged, priestly, grim, bureaucratic, and soaked in machine oil.

The internal keys should remain boring, stable, compatible, and predictable.

That contrast is the heart of the mod: a factory that looks like a sacred manufactorum from the outside while still behaving like Factorio under the hood.
