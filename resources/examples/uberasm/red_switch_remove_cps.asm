; This UberASM should be inserted as level asm.
; It will make so whenever a red switch (sprite C8) is pressed in the level,
; all the checkpoints in the game will be removed.

; SFX to play when hitting the switch (0 to disable it)
!sfx      = $16
!sfx_addr = $1DFC|!addr

main:
    lda $9D : ora $13D4|!addr : bne .return
    ldx.b #!sprite_slots-1
.loop:
    lda !14C8,x : cmp #$08 : bcc ..next
    lda !9E,x : cmp #$C8 : bne ..next
    lda !1558,x : cmp #$05 : bne ..next
..found:
if !sfx
    lda.b #!sfx : sta !sfx_addr
endif
    jsl retry_api_reset_all_cps
    rtl
..next:
    dex : bpl .loop
.return:
    rtl
