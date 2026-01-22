; This file is where you set Retry's level-specific settings.
; You can add how many settings you want, each in a separate line.
; Note that if you put the same option for the same level multiple times, only
; the last one will take effect.
; Supported settings (for each, write level as $XXX, like $105 for sublevel 105):
;
;   %checkpoint(level, value): configure the checkpoint behavior in the level, depending on value:
;     0 = vanilla checkpoint behavior (midway in the sublevel will lead to the main level's midway entrance)
;     1 = midway in the sublevel will lead to the sublevel's midway entrance
;     2 = any main/midway/secondary entrance to this sublevel will trigger a checkpoint
;     3 = both effects of 1 and 2
;     4 = any main/midway entrance to this sublevel will trigger a checkpoint
;     5 = both effects of 1 and 4
;     6 = any secondary entrance to this sublevel will trigger a checkpoint
;     7 = both effects of 1 and 6
;
;   %retry(level, value): configure the Retry type in the level, depending on value:
;     0 = follow the global setting (!default_prompt_type)
;     1 = Retry prompt and play the death jingle when dying (music will be reset)
;     2 = Retry prompt and only play the death sfx when dying (music won't be interrupted)
;     3 = instant Retry and only play the death sfx when dying (no prompt and music won't be interrupted)
;     4 = instant Retry and play the death jingle when dying (no prompt and the music will be reset)
;     5 = no Retry (vanilla death)
;
;   %checkpoint_retry(level, checkpoint, retry): configure both checkpoint and Retry types in the level
;
;   %sfx_echo(level): toggle sfx echo in the level
;
;   %reset_rng(level, value): choose the RNG reset behavior for the sublevel, depending on value:
;     0 = RNG will never be reset by Retry in this sublevel
;     1 = RNG will be reset when entering this sublevel from the Overworld (vanilla behavior)
;     2 = option 1 + RNG will be reset when dying and Retrying in this sublevel (old Retry default behavior)
;     3 = RNG will always be reset in this sublevel (option 2 + RNG will be reset when entering it from a pipe/door)
;
;   %no_room_cp_sfx(level): don't play the room checkpoint sfx when entering the level
;
;   %no_lose_lives(level): enable infinite lives in the level
;
;   %settings(level, checkpoint, retry, sfx_echo, reset_rng, no_room_cp_sfx, no_lose_lives): configure all settings for the level
;
; For details, check out "docs/settings_local.html".

