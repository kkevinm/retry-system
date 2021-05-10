; Gamemode 0C

init:

; Reset various counters.
.counterbreak:
if !counterbreak_yoshi
    stz $13C7|!addr
    stz $187A|!addr
endif

if !counterbreak_powerup
    ; Reset powerup.
    stz $19
endif

if !counterbreak_item_box
    ; Reset item box.
    stz $0DC2|!addr
endif

if !counterbreak_coins
    ; Reset coin counter.
    stz $0DBF|!addr
endif

if !counterbreak_bonus_stars
    ; Reset bonus stars counter.
    stz $0F48|!addr
    stz $0F49|!addr
endif

if !counterbreak_score
    ; Reset score counter.
    rep #$20
    stz $0F34|!addr
    stz $0F36|!addr
    stz $0F38|!addr
    sep #$20
endif
    
    ; Reset the prompt override address.
    lda #$00 : sta !ram_prompt_override

    ; Reset the "No exit" address.
    lda.b #!no_exit_option : sta !ram_disable_exit

; Reset the current level's checkpoint if the level was beaten.
.reset_checkpoint:
    ; Skip if the level wasn't just beaten.
    lda $0DD5|!addr : beq ..skip
                      bmi ..skip

    ; Reset the custom checkpoint for the current level.
    lda $13BF|!addr
    rep #$30
    and #$00FF : asl : tax
    lsr : cmp #$0025 : bcc +
    clc : adc #$00DC
+   sta !ram_checkpoint,x
    sta !ram_respawn
    sep #$30

..skip:
    rtl
