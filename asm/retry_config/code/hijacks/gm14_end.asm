pushpc

; Hijack the end of game mode 14.
org $00A2EA
    jml gm14_end

pullpc

;=====================================
; gm14_end routine
;
;
;=====================================
gm14_end:
    ; Preserve X and Y and set DBR.
    phx : phy
    phb : phk : plb

    ; Call the custom gm14_end routine.
    php : phb
    jsr extra_gm14_end
    plb : plp

    ; Check if we have to set the checkpoint.
    rep #$20
    lda !ram_set_checkpoint : cmp #$FFFF
    sep #$20
    beq .no_checkpoint

.set_checkpoint:
    jsr set_checkpoint

.no_checkpoint:
    ; Check if Mario is dying.
    lda $71 : cmp #$09 : bne .no_death

    ; Only do the following code once per death.
    lda !ram_is_dying : bne .no_death

.death:
    ; Set the flag.
    inc : sta !ram_is_dying

    ; Handle dying.
    jsr death_routine

.no_death:
    ; Check if it's time to draw the tiles.
    lda !ram_prompt_phase : cmp #$02 : bne .return

.draw_prompt:
    ; Draw the tiles.
    jsr prompt_oam

.return:
    ; Restore DBR, X and Y.
    plb : ply : plx

    ; Restore original code.
    pla : sta $1D : pla
    jml $00A2EE|!bank

;=====================================
; set_checkpoint routine
;=====================================
set_checkpoint:
    ; Save individual dcsave buffers.
    ; Needed because we skip over $00F2DD, where the routine is called.
if !dcsave
    jsr shared_dcsave_midpoint
endif
    
    ; Set midway flag, just to be safe.
    lda #$01 : sta $13CE|!addr
    
    ; Check if it's a normal or custom midway.
    lda !ram_set_checkpoint+1 : cmp #$FF : bne .custom_destination

.normal_midway:
    ; If it's the intro level, skip.
    lda $0109|!addr : beq ..no_intro
    cmp.b #!intro_level+$24 : bne .return

..no_intro:
    ; Check if this midway sets the midway entrance for the sublevel or the main level.
    rep #$10
    ldx $010B|!addr
    lda.l tables_checkpoint,x
    sep #$10
    cmp #$01 : beq ...sub_midway
    cmp #$03 : bcs ...sub_midway

...main_midway:
    jsr calc_entrance
    bra +
...sub_midway:
    jsr calc_entrance_2
+
if !amk
    lda $0DDA|!addr : sta !ram_music_backup
endif
    bra .return2

.custom_destination:
    ; Set the checkpoint destination.
    rep #$20
    lda !ram_set_checkpoint : sta !ram_respawn
    sep #$20

if !amk
    ; Always reload the samples, just to be safe.
    lda #$FF : sta !ram_music_backup
endif
    
.return2:
    ; Save the midway entrance as a checkpoint.
    jsr shared_hard_save

.return:
    ; Reset the set_checkpoint address.
    lda #$FF : sta !ram_set_checkpoint : sta !ram_set_checkpoint+1
    rts

;=====================================
; calc_entrance routine
;=====================================
calc_entrance:
    ; If it's not the intro level, skip.
    lda $13BF|!addr : bne .no_intro

    ; Set intro sublevel number as respawn point.
    rep #$20
    lda.w #!intro_sublevel : sta !ram_respawn
    sep #$20
    bra .check_midway

.no_intro:
    ; Convert $13BF value to sublevel number.
    cmp #$25 : bcc +
    clc : adc #$DC
+   sta !ram_respawn
    lda #$00 : adc #$00
..store_entrance_high:
    sta !ram_respawn+1

.check_midway:
    ; If the midway flag is not set, return.
    ldx $13BF|!addr
    lda $1EA2|!addr,x : and #$40 : bne ..midway
    lda $13CE|!addr : beq .return

..midway:
    ; Set the midway flag in the respawn entrance.
    lda !ram_respawn+1 : ora #$08 : sta !ram_respawn+1

.return:
    rts

.2:
    ; Set current sublevel number as the respawn point.
    lda $010B|!addr : sta !ram_respawn
    lda $010C|!addr : bra .no_intro_store_entrance_high

;=====================================
; death_sfx routine
;
; Handles death music/sfx when dying, death counter and other stuff.
; This runs just before AMK, so we can kill the death song before it starts.
;=====================================
death_routine:
    ; Update the death counter.
    ldx #$04
-   lda !ram_death_counter,x : inc : sta !ram_death_counter,x
    cmp #10 : bcc +
    lda #$00 : sta !ram_death_counter,x
    dex : bpl -
+
    ; Call the custom death routine.
    php : phb
    jsr extra_death
    plb : plp

    ; If the music is sped up, play the death song to make it normal again.
    lda !ram_hurry_up : bne .return

if !lose_lives
    ; If not infinite lives and they're over, skip retry as we're about to game over.
    lda $0DBE|!addr : beq .return
endif

    ; Check if we have to disable the death music.
    jsr shared_get_prompt_type
    cmp #$02 : bcc .return
    cmp #$04 : bcs .return

.no_death_song:
    ; Don't play the death song.
    stz $1DFB|!addr

    ; Play the death SFX.
    lda.b #!death_sfx : sta !death_sfx_addr

    ; Undo the $0DDA change.
    ; This ensures the song won't be reloaded if it's the same after respawning.
    lda !ram_music_backup : sta $0DDA|!addr

.return:
    rts

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

!letters_num = (.letters_x_pos_end-.letters_x_pos)

prompt_oam:
    ; Get as many free slots as possible at the start of $0200.
    jsr defrag_oam

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
