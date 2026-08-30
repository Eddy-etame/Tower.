# ASSET MANIFEST — uploaded Roblox assets (Open Cloud, creator eee1234165 / 10980709246)

Never lose these IDs. Uploader: `~/.claude/tools/rbx_upload.py` (key outside the repo).
`rbxassetid://<id>` is the in-game reference.

## Icons
| file | assetId | state | notes |
|---|---|---|---|
| `icons/icon_512.png` | 76291686882166 | Approved | The doorway + gaunt figure. **Eddy must SET it** in Creator Hub (icon assignment is not exposed to Open Cloud). Source: `icons/icon_a.png` (2048px). |

## Original foley — synthesised with ffmpeg (`audio/build_foley.sh`), we own it outright
| file | assetId | state | replaces |
|---|---|---|---|
| `audio/amb_threshold.mp3` | 75834877826444 | Reviewing | AMBIENT_SOUND (was action_falling.ogg) |
| `audio/watcher_step.mp3` | 103117196004158 | Reviewing | WATCHER_MOVE_SOUND (was footsteps_plastic) |
| `audio/surge_death.mp3` | 133805736395667 | Reviewing | SURGE_SOUND (was impact_explosion_03) |
| `audio/breaker_throw.mp3` | 84880902251839 | Reviewing | BREAKER_SOUND (was action_jump_land) |
| `audio/catch_impact.mp3` | 97636491138640 | Reviewing | CATCH_SOUND (was impact_explosion_03) |

**RULE (scar #7): do NOT swap a stub for an uploaded ID until moderation says Approved.** Shipping an
unapproved/rejected ID silences the game — that exact failure cost us several versions once already.
Re-check with: `python ~/.claude/tools/rbx_upload.py poll <operationId>` or the Creator Hub audio list.

## Test assets (harmless, ignore)
| pipe test decal | 105929786978573 | Approved |
| pipe test audio | 109173415419557 | Reviewing |
