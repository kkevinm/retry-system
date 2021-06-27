; Retry table-based settings.

;=================================================;
; Multiple Midway and Local Retry Prompt Settings ;
;=================================================;
; The following table controls two different behaviors for each sublevel.
; Each $XX value refers to a sublevel. The guides at the top and right of the table should help visualize it.
;
; The first digit in XX is used to change the Retry behavior for the sublevel:
;  0 = follow the global setting (!default_prompt_type)
;  1 = prompt + play the death jingle when players die. Recommended if you want the music to restart on each death.
;  2 = prompt + play only the sfx when players die (music won't be interrupted).
;  3 = no prompt + play only the sfx (the fastest option; "yes" is chosen automatically).
;        In this option, you can press start then select to exit the level.
;  4 = no retry (as if "no" is chosen automatically). Use this to have a vanilla death sequence.
;
; The second digit sets the behavior of midways bars and level entrances in the sublevel (see the figures in the "midway instruction" folder):
;  0 = Vanilla. The midway bar in the corresponding sublevel will lead to the midway entrance of the main level.
;  1 = The Midway bar in the corresponding sublevel will lead to the midway entrance of this sublevel as a checkpoint.
;  2 = Any main/secondary/midway entrance through door/pipe/etc. whose destination is the corresponding sublevel will
;        trigger a checkpoint like midway bars, and the checkpoint will lead to this entrance.
;  3 = This option enables both the effects of 1 (midway bar) and 2 (level entrances).
;
; NOTE: The custom midway objects could do almost everything that you may want without using this.
;       However this may be easier to use for some people, and it's what original retry also uses.
;
; For example, having $32 as the value for level 105 will set the value 3 for the Retry prompt
; (no prompt + play only the sfx) and 2 for the checkpoint (any entrance to the level will set a checkpoint).

checkpoint_effect:
;       0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 000-00F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 010-01F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 020-02F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 030-03F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 040-04F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 050-05F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 060-06F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 070-07F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 080-08F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 090-09F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0A0-0AF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0B0-0BF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0C0-0CF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0D0-0DF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0E0-0EF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 0F0-0FF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 100-10F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 110-11F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 120-12F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 130-13F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 140-14F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 150-15F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 160-16F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 170-17F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 180-18F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 190-19F
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1A0-1AF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1B0-1BF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1C0-1CF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1D0-1DF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1E0-1EF
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 1F0-1FF

;=================;
; Echo SFX Enable ;
;=================;
; Allows you to enable echo on SFX on a sublevel basis.
; You can already do that easily with an UberASM init code, but it may be tedious
; to have to insert the same code in a lot of levels, so this table makes it easier.
; Each digit in the table corresponds to a sublevel: if a digit is set to 1,
; the corresponding sublevel will have echo on SFX.
; For example, %10000001 as the first value means echo on for levels 000 and 007.
;
; The guides at the top and right of the table should help visualize it.
;
; NOTE: this feature only works with AddmusicK.

sfx_echo:
;       01234567  89ABCDEF
    db %00000000,%00000000 ; 000-00F
    db %00000000,%00000000 ; 010-01F
    db %00000000,%00000000 ; 020-02F
    db %00000000,%00000000 ; 030-03F
    db %00000000,%00000000 ; 040-04F
    db %00000000,%00000000 ; 050-05F
    db %00000000,%00000000 ; 060-06F
    db %00000000,%00000000 ; 070-07F
    db %00000000,%00000000 ; 080-08F
    db %00000000,%00000000 ; 090-09F
    db %00000000,%00000000 ; 0A0-0AF
    db %00000000,%00000000 ; 0B0-0BF
    db %00000000,%00000000 ; 0C0-0CF
    db %00000000,%00000000 ; 0D0-0DF
    db %00000000,%00000000 ; 0E0-0EF
    db %00000000,%00000000 ; 0F0-0FF
    db %00000000,%00000000 ; 100-10F
    db %00000000,%00000000 ; 110-11F
    db %00000000,%00000000 ; 120-12F
    db %00000000,%00000000 ; 130-13F
    db %00000000,%00000000 ; 140-14F
    db %00000000,%00000000 ; 150-15F
    db %00000000,%00000000 ; 160-16F
    db %00000000,%00000000 ; 170-17F
    db %00000000,%00000000 ; 180-18F
    db %00000000,%00000000 ; 190-19F
    db %00000000,%00000000 ; 1A0-1AF
    db %00000000,%00000000 ; 1B0-1BF
    db %00000000,%00000000 ; 1C0-1CF
    db %00000000,%00000000 ; 1D0-1DF
    db %00000000,%00000000 ; 1E0-1EF
    db %00000000,%00000000 ; 1F0-1FF

;=================;
; Reset RNG table ;
;=================;
; With this table you can control in which sublevels the RNG seeds will be reset when dying.
; 1 = reset RNG, 0 = don't reset RNG.
; By default this applies to all levels, to have consistent setups after death,
; but you can disable it when preferred.
;
; Format is the same as the sfx_echo table: each digits corresponds to one sublevel.

reset_rng:
;       01234567  89ABCDEF
    db %11111111,%11111111 ; 000-00F
    db %11111111,%11111111 ; 010-01F
    db %11111111,%11111111 ; 020-02F
    db %11111111,%11111111 ; 030-03F
    db %11111111,%11111111 ; 040-04F
    db %11111111,%11111111 ; 050-05F
    db %11111111,%11111111 ; 060-06F
    db %11111111,%11111111 ; 070-07F
    db %11111111,%11111111 ; 080-08F
    db %11111111,%11111111 ; 090-09F
    db %11111111,%11111111 ; 0A0-0AF
    db %11111111,%11111111 ; 0B0-0BF
    db %11111111,%11111111 ; 0C0-0CF
    db %11111111,%11111111 ; 0D0-0DF
    db %11111111,%11111111 ; 0E0-0EF
    db %11111111,%11111111 ; 0F0-0FF
    db %11111111,%11111111 ; 100-10F
    db %11111111,%11111111 ; 110-11F
    db %11111111,%11111111 ; 120-12F
    db %11111111,%11111111 ; 130-13F
    db %11111111,%11111111 ; 140-14F
    db %11111111,%11111111 ; 150-15F
    db %11111111,%11111111 ; 160-16F
    db %11111111,%11111111 ; 170-17F
    db %11111111,%11111111 ; 180-18F
    db %11111111,%11111111 ; 190-19F
    db %11111111,%11111111 ; 1A0-1AF
    db %11111111,%11111111 ; 1B0-1BF
    db %11111111,%11111111 ; 1C0-1CF
    db %11111111,%11111111 ; 1D0-1DF
    db %11111111,%11111111 ; 1E0-1EF
    db %11111111,%11111111 ; 1F0-1FF

;============;
; Save Table ;
;============;
; This table can be used to save custom values to SRAM, so they can persist when the console is turned off. By default it saves the custom checkpoint ram and the death counter.
; Each line is formatted as follows:
;  dl $XXXXXX = what RAM address to save. Make sure it's always 3 bytes long (i.e. use $7E0019 instead of $19 or $0019).
;  dw $XXXX = how many bytes to save at that address (remove the $ to use a decimal value).
; For example, adding "dl $7E1F3C : dw 12" will make the 1-Up checkpoints for all levels save.
; Make sure to always put a colon between the two elements!
;
; NOTE: make sure to keep the ".end:" at the end of the table!

save:
    dl !ram_checkpoint    : dw 192
    dl !ram_death_counter : dw 5


.end:
