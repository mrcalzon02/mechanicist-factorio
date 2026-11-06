# Mechanicist Factorio 0.1.3 — English Localization Reliability

**Factorio 2.1 / official expansion modules:** Base, Elevated Rails, Recycler, Quality, Space Age.

## Repairs
- **Space Age type isolation:** Same-named prototypes (e.g. big-mining-drill as an item, machine and technology) receive their category-correct translations; one category no longer overwrites the others.
- **Quality setting:** rename-quality now enables/disables the *prototype* retheme for Quality grades, modules, technology, recycler and related signals. Static English GUI and tips strings remain independently localized.
- **Disabled rethemes:** Off settings leave existing official and third-party prototype localization unchanged rather than wiping localised_name and localised_description fields.
- **Informatron:** Added the missing Space Age documentation root title.
- **Regression coverage:** CI validates all locale references, 8 isolated Factorio 2.1 runtime settings configurations, real data-stage localized-name assignments, maps, 1,200 simulation ticks, and private server startup for each.

## Install
Download **mechanicist-factorio_0.1.3.zip** from this release's Assets or the matching [Factorio Mod Portal listing](https://mods.factorio.com/mod/mechanicist-factorio). Place the ZIP **unchanged** into your Factorio mods folder; do not extract. Disable or remove old Mechanicist packages first.

Windows: %APPDATA%\Factorio\mods\  
Linux: ~/.factorio/mods/  
macOS: ~/Library/Application Support/factorio/mods/

The companion .sha256 file is a checksum, not a second mod.

**Scope:** Official engine/DLC-only headless validation. Interactive GUI visual checks and third-party mod combinations remain outside this isolated release.

[GitHub workflow with detailed logs](https://github.com/mrcalzon02/mechanicist-factorio/actions/workflows/mechanicist-headless.yml) · [README](https://github.com/mrcalzon02/mechanicist-factorio/blob/main/README.md).
