; Gamemode 11

init:
    ; Better safe than sorry.
    stz $13 : stz $14

    ; Reset the custom midway object counter.
    lda #$00 : sta !ram_cust_obj_num

    ; Don't trigger the prompt by accident, and reset the death flag.
    lda #$00 : sta !ram_prompt_phase
               sta !ram_is_dying

    ; Check if we entered from the overworld.
    lda $141A|!addr : bne .room_transition

    ; The game sets $13BF a bit later so we need to do it ourselves
    ; (unless we're in the intro level).
    lda $13BF|!addr : beq +
    jsr shared_get_translevel
+
    ; Don't trigger Yoshi init.
    lda #$00 : sta !ram_is_respawning
               sta !ram_hurry_up

    ; Call the custom reset routine.
    php : phb : phk : plb
    jsr extra_reset
    plb : plp

    ; Set the destination from the level's checkpoint value.
    lda $13BF|!addr : asl : tax
    rep #$20
    lda !ram_checkpoint,x : sta !ram_respawn
    sep #$20
    bra .skip

.room_transition:
    ; If respawning from retry, skip.
    lda !ram_is_respawning : bne .skip

    ; Check if we should count this entrance as a checkpoint.
    rep #$10
    ldx $010B|!addr
    lda.l tables_checkpoint,x
    sep #$10
    cmp #$02
    bcc .skip

..set_checkpoint:
    ; Set the checkpoint to the current entrance.
    lda !ram_door_dest : sta !ram_respawn
    lda !ram_door_dest+1 : sta !ram_respawn+1

    ; Update the checkpoint value.
    jsr shared_hard_save

    ; Call the custom checkpoint routine.
    php : phb : phk : plb
    jsr extra_room_checkpoint
    plb : plp

    ; Play the silent checkpoint SFX.
    lda.b #!room_cp_sfx : sta !room_cp_sfx_addr

    ; Save individual dcsave buffers.
if !dcsave
    jsr shared_dcsave_midpoint
endif

.skip:
    ; Reset Yoshi, but only if respawning and not parked outside of a Castle/Ghost House.
    lda !ram_is_respawning : beq ..no_yoshi_reset
if not(!counterbreak_yoshi)
    lda $1B9B|!addr : bne ..no_yoshi_reset
endif
    stz $0DC1|!addr

..no_yoshi_reset:
    rtl
