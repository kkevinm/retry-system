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

;=====================================;
; Save and SRAM default values tables ;
;=====================================;
; This table can be used to save custom values to SRAM, so they can persist when the console is turned off. By default it saves the custom checkpoint ram and the death counter.
; Each line is formatted as follows:
;  dl $XXXXXX = what RAM address to save. Make sure it's always 3 bytes long (i.e. use $7E0019 instead of $19 or $0019).
;  dw $XXXX = how many bytes to save at that address (remove the $ to use a decimal value).
; For example, adding "dl $7E1F3C : dw 12" will make the 1-Up checkpoints for all levels save.
; Make sure to always put a colon between the two elements!
;
; NOTE: make sure to keep the ".end:" at the end of the table!
; NOTE 2: for each address you add here, you need to add the default values in the sram_defaults table below.

save:
    dl !ram_checkpoint    : dw 192
    dl !ram_death_counter : dw 5

    ; Feel free to add your own stuff here.


.end:

; Here you specify the default values of the addresses you want to save, for when a new save file is started.
; You can do "db $XX,$XX,..." for 1 byte values, "dw $XXXX,$XXXX,..." for 2 bytes values and "dl $XXXXXX,$XXXXXX,..." for 3 bytes values.
; The amount of values of each entry should correspond to the dw $XXXX value in the save table
; (for example, the checkpoint values are 192, and the death counter values are 5).

sram_defaults:
    
    ; Default checkpoint values (don't edit this!).
    db $00,$00,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00,$06,$00,$07,$00
    db $08,$00,$09,$00,$0A,$00,$0B,$00,$0C,$00,$0D,$00,$0E,$00,$0F,$00
    db $10,$00,$11,$00,$12,$00,$13,$00,$14,$00,$15,$00,$16,$00,$17,$00
    db $18,$00,$19,$00,$1A,$00,$1B,$00,$1C,$00,$1D,$00,$1E,$00,$1F,$00
    db $20,$00,$21,$00,$22,$00,$23,$00,$24,$00,$01,$01,$02,$01,$03,$01
    db $04,$01,$05,$01,$06,$01,$07,$01,$08,$01,$09,$01,$0A,$01,$0B,$01
    db $0C,$01,$0D,$01,$0E,$01,$0F,$01,$10,$01,$11,$01,$12,$01,$13,$01
    db $14,$01,$15,$01,$16,$01,$17,$01,$18,$01,$19,$01,$1A,$01,$1B,$01
    db $1C,$01,$1D,$01,$1E,$01,$1F,$01,$20,$01,$21,$01,$22,$01,$23,$01
    db $24,$01,$25,$01,$26,$01,$27,$01,$28,$01,$29,$01,$2A,$01,$2B,$01
    db $2C,$01,$2D,$01,$2E,$01,$2F,$01,$30,$01,$31,$01,$32,$01,$33,$01
    db $34,$01,$35,$01,$36,$01,$37,$01,$38,$01,$39,$01,$3A,$01,$3B,$01

    ; Initial death counter value (don't edit this!).
    db $00,$00,$00,$00,$00

    ; Feel free to add your own stuff here.


