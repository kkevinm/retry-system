; Gamemode 0F

macro _build_status_bar_value(name)
    if !default_<name>_palette > $0F
        error "Error: \!default_<name>_palette is not valid!"
    endif
    if !default_<name>_tile > $1FF
        error "Error: \!default_<name>_tile is not valid!"
    endif

    !default_<name>_value #= ((!default_<name>_palette)<<12)|(!default_<name>_tile)
    
    if !default_<name>_value != 0 && !default_<name>_value&$8000 < $8000
        error "Error: \!default_<name>_palette is not valid!"
    endif

    !default_<name>_value #= !default_<name>_value&$7FFF
endmacro

%_build_status_bar_value(item_box)
%_build_status_bar_value(timer)
%_build_status_bar_value(coin_counter)

init:
if !sprite_status_bar
    ; Reset sprite status bar configuration.
    rep #$20
    lda.w #!default_item_box_value : sta !ram_status_bar_item_box_tile
    lda.w #!default_timer_value : sta !ram_status_bar_timer_tile
    lda.w #!default_coin_counter_value : sta !ram_status_bar_coins_tile
    sep #$20
endif

    ; If respawning or doing a level transition, skip.
    lda $141A|!addr : bne .transition

if !enter_level_sfx != $00
    ; If not loading the level from a No Yoshi intro, play the SFX.
    lda $71 : cmp #$0A : beq +
    lda.b #!enter_level_sfx : sta !enter_level_sfx_addr|!addr
    lda.b #!enter_level_delay : sta $0DB1|!addr
+
endif

if !pipe_entrance_freeze == 2
    ; Reset the $9D backup.
    lda #$00 : sta !ram_9D_backup
endif
    bra main

.transition:
    ; Check if we're respawning from Retry.
    lda !ram_is_respawning : beq .not_respawning

.respawning:
if !pipe_entrance_freeze == 2
    ; If yes, store the $9D backup to $9D.
    ; This makes pipe entrances consistent in how sprites behave during them.
    lda !ram_9D_backup : sta $9D
endif
    bra main

.not_respawning:
if !pipe_entrance_freeze == 2
    ; If it's a normal transition, backup $9D...
    lda $9D : sta !ram_9D_backup
endif

    ; ...and backup the current entrance value for later.
    ; (if warping to Yoshi Wings, change the entrance to the correct level
    ; and set the Yoshi Wings flag in the checkpoint RAM).
    lda $1B95|!addr : beq +
    %jsl_to_rts_db($05DBAC,$058125)
    lda $19D8|!addr,x : and #$FE : ora $010C|!addr : ora #$80
    bra ++
+   jsr shared_get_screen_number
    lda $19D8|!addr,x
++  sta !ram_door_dest+1
    lda $19B8|!addr,x : sta !ram_door_dest+0 

main:
if !fast_transitions
    ; Reset the mosaic timer.
    stz $0DB1|!addr
endif
    
    ; If in the door animation, call the extra routine.
    lda $71 : cmp #$0D : bne .return
    phb : phk : plb
    php
    jsr extra_door_animation
    plp
    plb

.return:
    rtl
