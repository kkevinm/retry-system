; In this file you can customize the Retry prompt text relatively easily.
; If you're opening this just to change which areas of VRAM (SP1/SP2/SP3/SP4)
; are used by the Retry prompt tiles, then look at the "Basic settings".
; To also change the prompt text, look at "Advanced settings" (note: more complicated).

;============================== Basic settings =================================

; Sprite tile numbers for the tiles used by the prompt ($00-$FF = SP1/SP2, $100-$1FF = SP3/SP4).
; !prompt_tile_cursor is the cursor tile, !prompt_tile_black is a black tile (needed for the box),
; !prompt_tiles_line1 are the unique letters for the first line, !prompt_tiles_line2 are the unique letters for the second line.
; The default values should be fine, but you may need to change them if using some other patches
; that upload tiles dynamically (like 32x32 Mario or lx5's Custom Powerups).
; Note: When the prompt black box is enabled, !prompt_tile_cursor and !prompt_tile_black actually use 2 adjacent 8x8 tiles.
;       When the prompt black box is disabled, !prompt_tile_cursor uses one 8x8 tile and !prompt_tile_black is not used.
    !prompt_tile_cursor = $20
    !prompt_tile_black  = $22
    !prompt_tiles_line1 = $30,$31,$32,$33 ; RETY
    !prompt_tiles_line2 = $4A,$5A         ; XI

; Palette rows used by the letters and cursor (note: they use sprite palettes).
    !prompt_pal_letter = $08
    !prompt_pal_cursor = $08

;============================== Advanced settings ==============================

; These settings specify the index of the prompt tiles in the GFX bin file.
; By index it means at which 8x8 tile (starting from the top left) the tiles are found (starting from 0).
; You usually shouldn't edit cursor and black, but you can edit the line1 and line2 to
; change which tiles from the GFX file are used for the first and second line of the prompt.
; Of course, you also need to edit the GFX files if you want to add/remove letters, and make
; sure that they appear in the same order in "letters1.bin" and "letters2.bin").
; If you edit this, make sure that !prompt_gfx_index_line1 has the same amount of values as
; !prompt_tiles_line1, and that !prompt_gfx_index_line2 has the same amount of values as !prompt_tiles_line2.
    !prompt_gfx_index_cursor = 0
    !prompt_gfx_index_black  = 1
    !prompt_gfx_index_line1  = 3,4,5,6 ; RETY
    !prompt_gfx_index_line2  = 7,8     ; XI

; These settings specify which tiles are drawn on the two lines of the Retry prompt, and in which order.
; To find these out, take the two list of tiles !prompt_tiles_line1 and !prompt_tiles_line2 together and imagine them as a single list. This list corresponds to
; the available letters you can use (by default, R-E-T-Y-X-I). Then, for both lines you
; specifiy the index of the letters in this list, starting from 0.
; For example, with the default tiles, 0 = R, 1 = E, 2 = T, 3 = Y, so "RETRY" becomes "0,1,2,0,3".
; Note that if the black box is enabled, the letters amount is constrained by the box size. You can change !text_x_pos (down to $38 max) to have more space available.
    !prompt_tile_index_line1 = 0,1,2,0,3 ; RETRY
    !prompt_tile_index_line2 = 1,4,5,2   ; EXIT
