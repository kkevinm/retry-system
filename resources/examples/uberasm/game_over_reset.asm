; This UberASM should be inserted as gamemode asm for gamemode 17.
; It will make so at the end of the game over animation, the current save file
; will be erased and the title screen will be reloaded, making game overs a
; permanent reset.

main:
    ; Skip if it's not the "GAME OVER" screen
    lda $143B|!addr : cmp #$14 : bne .return
    ; Skip if the "GAME OVER" animation has not started
    lda $143C|!addr : bne .return
    ; Skip if the "GAME OVER" animation has not almost finished
    lda $143D|!addr : cmp #$04 : bcs .return
    ; Erase current save file
    lda $010A|!addr
    jsl retry_api_erase_file
    ; Go to the title screen
    lda #$03 : sta $0100|!addr
.return:
    rtl
