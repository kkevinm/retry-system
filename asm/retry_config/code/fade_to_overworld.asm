; Gamemode 0D

; Tile used for empty space. By default it's the border "filled" tile.
!empty_tile  = $FE
!empty_props = $38

init:

; Draw the death counter in the Overworld.
.death_counter:
if !ow_death_counter
    pea.w (!stripe_table>>16)|(init>>16<<8)
    plb
    rep #$30
    ldy.w !stripe_index
    lda.w #$5000|(!ow_death_counter_y_pos<<5)|!ow_death_counter_x_pos
    xba : sta.w !stripe_table,y
    iny #2
    lda.w #($05*2)-1
    xba : sta.w !stripe_table,y
    iny #2
    ldx #$0000
    sep #$20
    stz $00
..stripe_loop:
    lda.l !ram_death_counter,x : bne +
    lsr $00 : bcs +
    lda.b #!empty_tile : sta.w !stripe_table,y
    lda.b #!empty_props
    bra ++
+   clc : adc.b #!ow_digit_0 : sta.w !stripe_table,y
    lda #$01 : sta $00
    lda.b #!ow_death_counter_props
++  sta.w !stripe_table+1,y
    iny #2
    inx
    cpx #$0005 : bcc ..stripe_loop
..end:
    lda #$FF : sta.w !stripe_table,y
    sty.w !stripe_index
    sep #$10
    plb
endif

    rtl
