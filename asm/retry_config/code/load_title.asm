; Gamemode 03

init:
    ; Initialize the retry ram.
    lda #$00
    sta !ram_timer+0
    sta !ram_timer+1
    sta !ram_timer+2
    sta !ram_respawn+0
    sta !ram_respawn+1
    sta !ram_is_respawning
    sta !ram_music_to_play
    sta !ram_hurry_up
    sta !ram_door_dest+0
    sta !ram_door_dest+1
    sta !ram_music_backup
    sta !ram_update_request
    sta !ram_is_dying
    sta !ram_prompt_phase
    sta !ram_update_window
    sta !ram_prompt_override
    sta !ram_death_counter+0
    sta !ram_death_counter+1
    sta !ram_death_counter+2
    sta !ram_death_counter+3
    sta !ram_death_counter+4
    lda.b #!no_exit_option
    sta !ram_disable_exit
    lda #$FF
    sta !ram_set_checkpoint+0
    sta !ram_set_checkpoint+1

    ; Initialize the checkpoint ram table.
    ldx #$BE
    ldy #$5F
-   tya : cmp #$25 : bcc +
    clc : adc #$DC
+   sta !ram_checkpoint,x
    lda #$00 : adc #$00
    sta !ram_checkpoint+1,x
    dex #2
    dey
    bpl -

    ; Set the intro level checkpoint (level 0 = intro).
    rep #$20
    lda.w #!intro_sublevel : sta !ram_checkpoint
    sep #$20

    ; Call the custom load title routine.
    php : phb : phk : plb
    jsr extra_load_title
    plb : plp

    rtl
