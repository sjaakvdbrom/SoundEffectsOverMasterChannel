# SoundEffectsOverMasterChannel

A lightweight addon that plays certain sounds over the master channel instead of sound effects.

## Why?

If you are like me and you would like to play with only the most essential sounds, you are probably going to want to disable most sound channels. There are some sounds we would like to still hear though, and this add-on aims to fix that.

## Supported sounds
* LFG (Dungeon, Raid, premade) invites
* Bloodlust effects
  * Fury of the aspects currently plays the bloodlust sound since I cannot find the correct one.

## Slash commands
* `/semc list` - show all sound toggles and their current state.
* `/semc status` - same as list.
* `/semc status bloodlust` - show one sound state.
* `/semc on bloodlust` - enable bloodlust sounds.
* `/semc off bloodlust` - disable bloodlust sounds.
* `/semc on readycheck` - enable LFG invite ready check sound.
* `/semc off readycheck` - disable LFG invite ready check sound.

Aliases are supported. For example: `lust`, `heroism`, and `timewarp` map to `bloodlust`; `lfg` maps to `readycheck`.

## Adding new sounds
If you would like me to add a sound you can [create an issue](../../issues/new). There is no gaurantee it will be added however.

## Release and versioning
- Curse/WowAce packaging reads `.pkgmeta` and `CHANGELOG.md`.
- `SoundEffectsOverMasterChannel.toc` uses `## Version: @project-version@`, which is replaced during packaging.
- Create a git tag for each release (for example `v1.1.2`). The tag drives the packaged addon version.
- Add a matching heading in `CHANGELOG.md` (for example `## 1.1.2`) before tagging.

