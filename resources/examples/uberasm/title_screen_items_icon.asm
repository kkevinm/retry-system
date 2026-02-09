; This UberASM should be normally inserted as gamemode asm for gamemodes 8 and 9,
; but on gamemode A if you're using the "One File, One Player" patch.
; It will draw a tile next to the load/erase file menu for each save file that
; has at least a certain number of items collected (by default, moons).
; To make this work you need to save the items in SRAM by adding it to the Retry
; save table (for example, "dl $1FEE|!addr : dw 12").
; This can work for moons, dragon coins or invisible 1-Up checkpoints (or also
; custom items that are stored bitwise in a 12 byte table).

; Change to $1F2F|!addr for dragon coins, $1F3C for invisible 1-Up checkpoints
!items = $1FEE|!addr

; How many items needed to show the tile
!items_num = 10

; Tile and properties
!tile = $2E
!pal  = 7
!page = 0

; Position to draw for the first file
!x_pos = $17
!y_pos = $0F

; How many save files you have (set 1 if using "One Player, One File" or similar)
!save_file_num = 3

macro count_bits(addr, size)
    stz $0E
    ldy.b #<size>-1
?-  lda <addr>,y : sta $0F
    ldx #$07
    lda #$00
?-- lsr $0F : adc #$00
    dex : bpl ?--
    clc : adc $0E : sta $0E
    dey : bpl ?-
endmacro

macro begin_stripe()
    rep #$30
    lda $7F837B
    tax
endmacro

macro write_tile(layer, x, y, tile, prop)
    lda.w #(($800*<layer>*(<layer>-1))+$2000)|((<y>)<<5)|(<x>)
    xba
    sta $7F837D,x
    inx #2
    lda.w #2-1
    xba
    sta $7F837D,x
    inx #2
    sep #$20
    lda <tile> : sta $7F837D+0,x
    lda <prop> : sta $7F837D+1,x
    rep #$20
    inx #2
endmacro

macro end_stripe()
    txa
    sta $7F837B
    lda #$FFFF
    sta $7F837D,x
    sep #$30
endmacro

macro draw_for_file(n)
    lda.b #<n> : sta $010A|!addr
    jsl retry_api_get_sram_var : dl !items
    bcc ?draw
    jmp ?end
?draw:
    %count_bits([$00], 12)
    cmp.b #!items_num : bcc ?end
    lda $0100|!addr : cmp #$09 : beq ?erase
?load:
    %begin_stripe()
    %write_tile(3, !x_pos, !y_pos+(<n>*2), #!tile, #$20|(!pal<<2)|(!page&1))
    %end_stripe()
    bra ?end
?erase:
    %begin_stripe()
    %write_tile(3, !x_pos+3, !y_pos+(<n>*2), #!tile, #$20|(!pal<<2)|(!page&1))
    %end_stripe()
?end:
endmacro

init:
    lda $010A|!addr : pha
    for i = 0..!save_file_num
        %draw_for_file(!i)
    endfor
    pla : sta $010A|!addr
    rtl
