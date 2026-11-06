# Mechanicist Factorio

**Latest development release:** **v0.1.3 — Factorio 2.1 localization repairs**  
**Last verified official engine before this patch:** Factorio **2.1.24** (build 87808) on v0.1.2. New v0.1.3 runtime validation and release publication are gated on CI.

Mechanicus-inspired **English localization and lore retheme** for Factorio, using existing internal prototype IDs. No tanks or vehicles are added by this mod.

## Install
1. Download the latest **mechanicist-factorio_0.1.3.zip** directly from [GitHub Releases](https://github.com/mrcalzon02/mechanicist-factorio/releases/tag/v0.1.3) when the new release is published, or from the [Factorio Mod Portal](https://mods.factorio.com/mod/mechanicist-factorio) once it lists 0.1.3.
2. Keep the ZIP intact, and copy it into Factorio's **mods** folder: Windows %APPDATA%\Factorio\mods\ ; Linux ~/.factorio/mods/ ; macOS ~/Library/Application Support/factorio/mods/ .
3. Disable/remove old Mechanicist versions. In Factorio 2.1's Mods menu, enable the new version and restart if prompted. Base, Elevated Rails, Recycler, Quality and Space Age are supported individually where applicable and in the complete expansion combination.

## What changed since 0.1.2
- Fixed incorrectly shared Space Age prototype name mappings by matching the correct entity/item/technology/recipe/etc. categories.
- Implemented the **rename-quality** setting for actual Quality prototypes. The GUI and tutorial strings are independent static locale overrides and may remain rethemed when this toggle is off.
- Disabled localization switches no longer clear other mods' or official Factorio prototype-localized fields.
- Repaired a missing Space Age Informatron root-title pointer.
- Added **ci/audit_locale.py** source/key coverage checks and eight true headless mod-settings configurations. The engine checks target actual prototype localization, not just successful load.

## Test matrix
The automated workflow validates the **exact packaged ZIP** against the official stable Factorio 2.1 headless engine for:
base-standard, base-heresy, base-off, Elevated Rails, Quality-on, Quality-off, full Space Age, and Space Age-off.

Each scenario must create a map, pass in-engine localization assertions, simulate **1,200 ticks**, and start a private headless server. Published files are gated on passing runtime checks.

[Headless validation workflow](https://github.com/mrcalzon02/mechanicist-factorio/actions/workflows/mechanicist-headless.yml) · [v0.1.3 release notes](RELEASE_NOTES.md) · [Mod-specific README](mechanicist-factorio_0.1.3/README.md).

## Scope and limitations
- English-only translation files: base, Quality and Space Age. They are not foreign-language packs.
- Optional Informatron and Rampant Fixed pages are locale documentation hooks; **external third-party mods are not part of this isolated test environment**.
- Headless test validation is not a visual screenshot check of every translated tooltip.
- The optional Quality setting controls **prototype labels**, not global GUI/tip strings.

## Automatic publication
The successful workflow publishes a GitHub **v0.1.3** release containing exactly the tested ZIP and matching SHA-256 checksum, then submits the same ZIP to the existing [Factorio Mod Portal](https://mods.factorio.com/mod/mechanicist-factorio). API acceptance and eventual public readback are tracked separately; delayed portal indexing is reported as a warning, not as proof of upload failure. Existing releases are never overwritten or retagged.
