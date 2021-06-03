; Gamemode 13

init:
    ; Reset some stuff related to lx5's Custom Powerups.
if !custom_powerups == 1
if !dynamic_items == 1
    ldy $0DC2|!addr
    lda.b #read1($02802D|!bank)
    dec
    sta $00
    lda.b #read1($02802E|!bank)
    sta $01
    lda.b #read1($02802F|!bank)
    sta $02
    lda [$00],y
    xba
    rep #$20
    and #$FF00
    lsr #3
    adc.w #read2($00A38B|!bank)
    sta !item_gfx_pointer+4
    clc
    adc #$0200
    sta !item_gfx_pointer+10
    sep #$20
    lda !item_gfx_refresh
    ora #$13
    sta !item_gfx_refresh
endif

    lda #$FF
    sta !item_gfx_oldest
    sta !item_gfx_latest

    lda $86
    sta !slippery_flag_backup

.init_cloud_data
    lda $19
    cmp #!cloud_flower_powerup_num
    bne +

    rep #$30
    phx
    ldx #$006C
-   lda $94
    sta.l !collision_data_x,x
    lda $96
    sta.l !collision_data_x+2,x
    dex #4
    bpl -
    plx
    sep #$30
+   
endif

    ; Reset DSX sprites.
if !reset_dsx
    stz $06FE|!addr
endif

    ; Set/unset the SFX echo.
if !amk
    ; $05 = SFX to reset echo.
    ldy #$05

    ; Load index to the mask table.
    lda $010B|!addr : and #$07 : tax

    ; Load mask and save it for later.
    lda.l $018000|!bank,x : sta $00

    ; Load index for the echo table.
    rep #$20
    lda $010B|!addr : lsr #3 : tax
    sep #$20

    ; If value & mask is 0, branch (bit is not set).
    lda.l tables_sfx_echo,x : and $00 : beq +

    ; Otherwise, use $06 = SFX to set echo.
    iny

    ; Finally, store to $1DFA.
+   sty $1DFA|!addr
endif

    ; If not entering from the overworld, skip.
    lda $141A|!addr : bne .room_transition

    ; Backup the timer value.
    lda $0F31|!addr : sta !ram_timer+0
    lda $0F32|!addr : sta !ram_timer+1
    lda $0F33|!addr : sta !ram_timer+2

.room_transition:
    lda !ram_is_respawning : bne ..respawning
    rep #$10
    ldx $010B|!addr
    lda.l tables_checkpoint,x
    sep #$10
    cmp #$02
    bcc .normal

..respawning
    ; Fix issues with the "level ender" sprite.
    stz $1493|!addr
    stz $13C6|!addr

    ; Reset mode 7 values.
    stz $36
    stz $37

if !amk
    ; Backup the music that should play.
    lda $0DDA|!addr : sta !ram_music_to_play
endif

.normal:
    ; Reset the respawning flag.
    lda #$00 : sta !ram_is_respawning

main:
if !fast_transitions
    ; Reset the mosaic timer.
    stz $0DB1|!addr
endif
    rtl
