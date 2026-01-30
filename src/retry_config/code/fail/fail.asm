;===============================================================================
; This manages the fail state when the SRAM or WRAM states are corrupted,
; probably indicating a misuse of Retry (i.e. loading a Retry-less save file or
; save state with Retry newly installed).
;===============================================================================

; Macro to upload a palette from a table to the color index specified
macro _upload_palette(dst, src)
    lda.b #<dst> : sta $2121
    ldx #$2200 : stx $4300
    ldx.w #<src> : stx $4302
    ldx.w #<src>_end-<src> : stx $4305
    lda #$01 : sta $420B
endmacro

; Macro to upload a GFX file from a table to the VRAM address specified
macro _upload_gfx(dst, src)
    lda #$80 : sta $2115
    ldx.w #<dst> : stx $2116
    ldx.w #$1801 : stx $4300
    ldx.w #<src> : stx $4302
    ldx.w #<src>_end-<src> : stx $4305
    lda #$01 : sta $420B
endmacro

sram:
    jsr setup
    ldx.w #sram_fail_msg
    jmp finalize

wram:
    jsr setup
    ldx.w #wram_fail_msg
    jmp finalize

setup:
    phk : plb
    sep #$20
    rep #$10
    ; Disable interrupts
    sei
    stz $4200
    ; Disable HDMA
    stz $420C
    ; Clear SPC I/O
    stz $2140
    stz $2141
    stz $2142
    stz $2143
    ; Enable f-blank
    lda #$80 : sta $2100
        ; Enable background color
    stz $2130
    lda #$20 : sta $2131
    ; BG color: #181818
    lda #$84 : sta $2132
    lda #$44 : sta $2132
    lda #$24 : sta $2132
        ; No bullshit modes
    stz $2133
    ; Layer 3 at (0,-1)
    stz $2111 : stz $2111
    lda #$FF : sta $2112 : sta $2112
    ; Layer 3 and objects on main, nothing on sub
    lda #$14 : sta $212C
    stz $212D
    stz $212E
    stz $212F
    ; 8x8 and 16x16 objects, sprite GFX at VRAM $6000
    lda #$03 : sta $2101
    ; No OAM bullshit
    stz $2102
    stz $2103
    ; Mode 0
    stz $2105
    ; No mosaic
    stz $2106
    ; No windows
    stz $2123
    stz $2124
    stz $2125
    stz $2126
    stz $2127
    stz $2128
    stz $2129
    stz $212A
    stz $212B
    ; Layer 3 256x256 tilemap at tilemap $5000
    lda #$50 : sta $2109
    ; Layer 3 GFX at VRAM $4000
    lda #$04 : sta $210C
    ; Set DMA bank for all uploads
    lda.b #setup>>16 : sta $4304
    ; Upload layer 3 GFX to VRAM $4000
    %_upload_gfx($4000, layer3_gfx)
    ; Upload sprite GFX to VRAM $6000
    %_upload_gfx($6000, sprite_gfx)
    ; Upload layer 3 tilemap properties
    lda #$80 : sta $2115
    ldx.w #$5000 : stx $2116
    ldx.w #$1908 : stx $4300
    ldx.w #layer3_props : stx $4302
    ldx.w #($10*2)*($0E*2) : stx $4305
    lda #$01 : sta $420B
    ; Upload layer 3 palette
    %_upload_palette($00, layer3_pal)
    ; Upload sprite palette
    %_upload_palette($80, sprite_pal)
    ; Clear OAM table
    ldx.w #$0200|!addr : stx $2181
    stz $2183
    ldx #$8008 : stx $4300
    ldx.w #offscreen : stx $4302
    ldx.w #$0200 : stx $4305
    lda #$01 : sta $420B
    ldx.w #$0400|!addr : stx $2181
    stz $2183
    ldx #$8008 : stx $4300
    ldx.w #zero : stx $4302
    ldx.w #$0020 : stx $4305
    lda #$01 : sta $420B
    ; Copy sprite tilemap
    ldx.w #$0200|!addr : stx $2181
    stz $2183
    ldx #$8000 : stx $4300
    ldx.w #sprite_tilemap : stx $4302
    ldx.w #sprite_tilemap_end-sprite_tilemap : stx $4305
    lda #$01 : sta $420B
    ; Upload OAM table
    ldx.w #$0400 : stx $4300
    ldx.w #$0200|!addr : stx $4302
    stz $4304
    ldx #$0220 : stx $4305
    lda #$01 : sta $420B
    rts

layer3_gfx:
    incbin "layer3.bin"
.end:

layer3_props:
    db $20

layer3_pal:
    dw $0000,$7FDD
.end:

sprite_gfx:
    incbin "sprite.bin"
.end:

sprite_pal:
    ; Mario palette
    dw $0000,$7FFF,$0000,$0D71,$1E9B,$3B7F,$635F,$581D
    dw $000A,$391F,$44C4,$4E08,$6770,$30B6,$35DF,$03FF
    ; Luigi palette
    dw $0000,$7FFF,$0000,$0D71,$1E9B,$3B7F,$4F3F,$581D
    dw $1140,$3FE0,$3C07,$7CAE,$7DB3,$2F00,$165F,$03FF
.end:

offscreen:
    db $F0

zero:
    db $00

!spr1_x = $20
!spr1_y = $08
!spr1_p = $00
!spr2_x = $C8
!spr2_y = !spr1_y
!spr2_p = $42

sprite_tilemap:
    ; First Mario
    db !spr1_x+$00,!spr1_y+$00,$00,!spr1_p
    db !spr1_x+$08,!spr1_y+$00,$01,!spr1_p
    db !spr1_x+$00,!spr1_y+$08,$02,!spr1_p
    db !spr1_x+$08,!spr1_y+$08,$03,!spr1_p
    db !spr1_x+$00,!spr1_y+$10,$04,!spr1_p
    db !spr1_x+$08,!spr1_y+$10,$05,!spr1_p
    ; Second Mario
    db !spr2_x+$00,!spr2_y+$00,$01,!spr2_p
    db !spr2_x+$08,!spr2_y+$00,$00,!spr2_p
    db !spr2_x+$00,!spr2_y+$08,$03,!spr2_p
    db !spr2_x+$08,!spr2_y+$08,$02,!spr2_p
    db !spr2_x+$00,!spr2_y+$10,$05,!spr2_p
    db !spr2_x+$08,!spr2_y+$10,$04,!spr2_p
.end:

finalize:
    ; Upload layer 3 tilemap tiles (X = src address)
    stx $4302
    lda.b #finalize>>16 : sta $4304
    stz $2115
    ldx.w #$5000 : stx $2116
    ldx.w #$1800 : stx $4300
    ldx.w #($10*2)*($0E*2) : stx $4305
    lda #$01 : sta $420B
    ; Waiting for next v-blank
-   bit $4212 : bmi -
-   bit $4212 : bpl -
    ; Turn on the screen
    lda #$0F : sta $2100
    ; We stuck here :(
-   bra -

incsrc charset.asm

sram_fail_msg:
    db "                                "
    db "                                "
    db "         !!! ERROR !!!          "
    db "                                "
    db "                                "
    db " Retry has detected an error in "
    db " your save data!                "
    db "                                "
    db " This can be caused by:         "
    db " - Loading a save file that was "
    db "   created before inserting     "
    db "   Retry in the hack            "
    db " - SRAM corruption              "
    db "                                "
    db " Usually you can solve it by    "
    db " erasing all the save files and "
    db " creating new ones.             "
    db "                                "
    db " If you're the hack creator and "
    db " you think this should not have "
    db " happened, contact me on SMW    "
    db " Central or on Discord.         "
    db "                                "
    db " If you're a player and you are "
    db " reading this, let the hack     "
    db " creator know.                  "
    db "                                "
    db "                                "

wram_fail_msg:
    db "                                "
    db "                                "
    db "         !!! ERROR !!!          "
    db "                                "
    db "                                "
    db " Retry has detected an error in "
    db " your RAM state!                "
    db "                                "
    db " This can be caused by:         "
    db " - Loading a save state that    "
    db "   was created before inserting "
    db "   Retry in the hack            "
    db " - RAM corruption               "
    db "                                "
    db " Usually you can solve it by    "
    db " restarting the hack and then   "
    db " creating a new save state.     "
    db "                                "
    db " If you're the hack creator and "
    db " you think this should not have "
    db " happened, contact me on SMW    "
    db " Central or on Discord.         "
    db "                                "
    db " If you're a player and you are "
    db " reading this, let the hack     "
    db " creator know.                  "
    db "                                "
    db "                                "
