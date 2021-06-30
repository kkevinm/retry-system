; Gamemode 03

init:
    ; Initialize the retry ram to 0.
    rep #$30
    ldx #$0024
    lda #$0000
-   sta !retry_freeram,x
    dex #2 : bpl -

    ; Initialize "set checkpoint" handle to $FFFF.
    dec : sta !ram_set_checkpoint

    ; Initialize the checkpoint ram table.
    ldx #$00BE
    ldy #$005F
-   tya : cmp #$0025 : bcc +
    clc : adc #$00DC
+   sta !ram_checkpoint,x
    dex #2
    dey : bpl -

    ; Set the intro level checkpoint (level 0 = intro).
    lda.w #!intro_sublevel : sta !ram_checkpoint
    
    sep #$30

    ; Initialize "No exit" flag.
    lda.b #!no_exit_option : sta !ram_disable_exit

    ; Call the custom load title routine.
    php : phb : phk : plb
    jsr extra_load_title
    plb : plp
    
    rtl
