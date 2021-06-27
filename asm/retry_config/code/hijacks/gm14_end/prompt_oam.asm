;=====================================
; prompt_oam routine
;
; Handles drawing the prompt tiles when necessary.
; It's setup to only draw in empty OAM slots, so unless the OAM table is full, it won't overwrite tiles.
; The tiles will also have highest priority over every other sprite.
;=====================================

; Check if palette values make sense.
assert !letter_palette >= $08 && !letter_palette <= $0F, "Error: \!letter_palette should be between $08 and $0F."
assert !cursor_palette >= $08 && !cursor_palette <= $0F, "Error: \!cursor_palette should be between $08 and $0F."

; Convert palettes from row number to YXPPCCCT format.
!letter_props #= ($30|((!letter_palette-8)<<1))
!cursor_props #= ($30|((!cursor_palette-8)<<1))

; Helper functions.
function x_pos(offset) = (!text_x_pos+offset)
function y_pos(offset) = (!text_y_pos+offset)

!letters_num = (prompt_oam_letters_x_pos_end-prompt_oam_letters_x_pos)

erase_tiles:
    ; Erase the prompt's OAM tiles when in Reznor/Morton/Roy/Ludwig's rooms.
    ; This avoids the BG from glitching out when the prompt disappears.
    lda $0D9B|!addr : cmp #$C0 : bne .return
    lda #$F0
    ldy.b #4*(!letters_num-1)
.loop:
    sta $0201|!addr,y
    dey #4 : bpl .loop
.return:
    rts

prompt_oam:
    ; Get as many free slots as possible at the start of $0200.
    ; Skip this in Reznor/Morton/Roy's rooms to avoid glitching their BGs.
    lda $0D9B|!addr : cmp #$C0 : beq +
    jsr defrag_oam
+
    ; Draw the letters.
    ldx.b #!letters_num-1
    ldy.b #4*(!letters_num-1)

.oam_draw_loop:
    ; Store OAM values.
    lda.w .letters_x_pos,x : sta $0200|!addr,y
    lda.w .letters_y_pos,x : sta $0201|!addr,y
    lda.w .letters_tile,x : sta $0202|!addr,y
    lda.b #!letter_props : sta $0203|!addr,y
    
    ; Store OAM size. X is always Y/4 so we can use that directly.
    lda.w .letters_size,x : sta $0420|!addr,x

    ; Go to the next slot.
    dey #4

    ; Go to the next tile.
    dex : bpl .oam_draw_loop

    ; Now handle the exit option.
.handle_exit:
    ; If exit is enabled, skip.
    lda !ram_disable_exit : beq .handle_cursor

if !no_prompt_box
    ; If not box, put the "exit" tiles offscreen.
    lda #$F0
    sta $0209|!addr : sta $020D|!addr : sta $0211|!addr : sta $0215|!addr
else
    ; Otherwise, turn them all into black tiles.
    lda.b #!tile_blk
    sta $020A|!addr : sta $020E|!addr : sta $0212|!addr : sta $0216|!addr
endif

    ; Now handle the cursor.
.handle_cursor:
    ; Hide it on both lines if it's on a blinking frame.
    lda $1B91|!addr : eor #$1F : and #$18 : beq ..hide_both

..hide_one:
    ; Otherwise, only hide the one that's not on the selected option's line.
    lda $1B92|!addr : eor #$01 : asl #2 : tay

if !no_prompt_box
    ; If no box, just put the tile offscreen.
    lda #$F0 : sta $0201|!addr,y
else
    ; Otherwise, turn into a black tile.
    lda.b #!tile_blk : sta $0202|!addr,y
endif
    bra ..end

..hide_both:
if !no_prompt_box
    ; If no prompt, put both tiles offscreen.
    lda #$F0
    sta $0201|!addr : sta $0205|!addr
else
    ; Otherwise, turn them into black tiles.
    lda.b #!tile_blk
    sta $0202|!addr : sta $0206|!addr
endif

..end:
    rts

;=====================================
; These tables control what's drawn in the prompt box.
; In all cases, the letters are just 8x8 tiles (original retry uses 16x16 tiles to use less
; OAM tiles, I chose 8x8 so I use less space in SP1, it's easier to manage which tiles in the
; GFX are overwritten and it's easier to optimize the space used when not having the box).
;  - If it's a regular prompt, we need to draw 6 16x16 black tiles to hide the
;    "window cutoff" (one of these is the cursor).
;  - If the box was disabled, we don't need 4 of the black tiles, and the other 2
;    (used for the cursor) are 8x8 instead (since we don't need to cover cutoff).
;  - If the exit option is disabled, the "EXIT" tiles are drawn as black tiles instead, if the
;    box is on (to cover the cutoff). Otherwise, they're moved offscreen. Either way they use
;    4 slots to have an easier drawing routine in any case.
; In summary, if !no_promp_box = 1, 11 slots are used, otherwise 15.
;=====================================

; X position of each letter on the screen.
.letters_x_pos:
    db x_pos($00) ; Black / Cursor
    db x_pos($00) ; Black / Cursor
    db x_pos($10) ; E
    db x_pos($18) ; X
    db x_pos($20) ; I
    db x_pos($28) ; T
    db x_pos($10) ; R
    db x_pos($18) ; E
    db x_pos($20) ; T
    db x_pos($28) ; R
    db x_pos($30) ; Y
if not(!no_prompt_box)
    db x_pos($E0) ; Black
    db x_pos($F0) ; Black
    db x_pos($E0) ; Black
    db x_pos($F0) ; Black
endif
..end:

; Y position of each letter on the screen.
.letters_y_pos:
    db y_pos($00) ; Black / Cursor
    db y_pos($10) ; Black / Cursor
    db y_pos($10) ; E
    db y_pos($10) ; X
    db y_pos($10) ; I
    db y_pos($10) ; T
    db y_pos($00) ; R
    db y_pos($00) ; E
    db y_pos($00) ; T
    db y_pos($00) ; R
    db y_pos($00) ; Y
if not(!no_prompt_box)
    db y_pos($00) ; Black
    db y_pos($00) ; Black
    db y_pos($10) ; Black
    db y_pos($10) ; Black
endif
..end:

; Tile number for each letter.
.letters_tile:
    db !tile_curs,!tile_curs
    db !tile_e,!tile_x,!tile_i,!tile_t
    db !tile_r,!tile_e,!tile_t,!tile_r,!tile_y
if not(!no_prompt_box)
    db !tile_blk,!tile_blk,!tile_blk,!tile_blk
endif
..end:

; Size (8x8 or 16x16) for each letter.
.letters_size:
if !no_prompt_box
    db $00,$00
else
    db $02,$02
endif
    db $00,$00,$00,$00
    db $00,$00,$00,$00,$00
if not(!no_prompt_box)
    db $02,$02,$02,$02
endif
..end:

;=====================================
; defrag_oam routine
;
; This routine puts all used slots in OAM at the end of the table in contiguous spots.
; The result is that all free slots will be at the beginning of the table.
; This allows the letters to be drawn with max priority w.r.t. everything else, and to not overwrite other tiles.
;=====================================
defrag_oam:
    ; Since we scan both $0200 and $0300, we need 16 bit indexes.
    rep #$10
    ; Y: index in the original OAM table.
    ldy #$01FC
    ; X: index in the rearranged table.
    ldx #$01FC
.loop:
    ; If the slot is free, go to the next one.
    lda $0201|!addr,y : cmp #$F0 : beq ..next

    ; Otherwise, copy the Y slot in the X slot...
    rep #$20
    lda $0200|!addr,y : sta $0200|!addr,x
    lda $0202|!addr,y : sta $0202|!addr,x

    ; ...and mark the Y slot as free.
    lda #$F0F0 : sta $0200|!addr,y

    phx : phy

    ; Compute the indexes in $0420.
    tya : lsr #2 : tay
    txa : lsr #2 : tax

    ; Copy the entry in $0420 as well.
    sep #$20
    lda $0420|!addr,y : sta $0420|!addr,x

    ply : plx

    ; Go to the next slot in the rearranged table.
    dex #4

..next:
    ; Go to the next slot in the original table, and loop back if not the end.
    dey #4 : bpl .loop

.end:
    sep #$10
    rts
