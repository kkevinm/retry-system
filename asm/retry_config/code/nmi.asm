; Gamemode 14

;=====================================
; nmi routine
;
; I know that uploading each tile individually is slow, but it makes it easy
; to change where the tiles are uploaded to for the user, and easier to manage
; the case where the "exit" option is left out.
;=====================================

; Helper functions to compute addresses more compactly.
function gfx_addr(offset)  = (retry_gfx+(offset*$20))
function vram_addr(offset) = (!base_vram+(offset*$10))
function vram_size(num)    = (num*$20)

level:
    ; Skip if it's not time to upload the tiles.
    lda !ram_update_request : beq .return
    
    ; Only upload on this frame.
    dec : sta !ram_update_request

    ; With 5+ cycle iterations it saves time over doing lda.l.
    phb : phk : plb

    ; Loop to upload all the tiles.
    ; If the exit option is disabled, we skip the XI tiles.
    lda !ram_disable_exit : tay
    ldx.w .index,y

    rep #$20
.loop:
    ; Increment address after each word.
    ldy.b #$80 : sty $2115

    ; Write from CPU to PPU, 2 registers write once, to $2118 (VRAM).
    lda.w #$1801 : sta $4320

    ; VRAM address to write to.
    lda.w .dest,x : sta $2116

    ; Source address (low and high byte) to upload from.
    lda.w .src,x : sta $4322

    ; Source address (bank byte) to upload from.
    ldy.b #retry_gfx>>16 : sty $4324

    ; Upload 8x8 tile(s).
    lda.w .size,x : sta $4325

    ; Start DMA transfer on channel 2.
    ldy.b #$04 : sty $420B

    ; Go to the next tile.
    dex #2 : bpl .loop

.end:
    sep #$20
    plb
.return:
    rtl

; Index in the below tables to start from when the exit option is enabled/disabled.
.index:
    db .src_end-.src-2
    db .src_exit-.src-2

.src:
    dw gfx_addr(5) ; Cursor
    dw gfx_addr(2) ; R
    dw gfx_addr(3) ; E
    dw gfx_addr(1) ; T
    dw gfx_addr(7) ; Y
if not(!no_prompt_box)
    dw gfx_addr(6) ; Black
    dw gfx_addr(6) ; Black
endif
..exit:
    dw gfx_addr(4) ; X
    dw gfx_addr(0) ; I
..end:

.dest:
    dw vram_addr(!tile_curs)
    dw vram_addr(!tile_r)
    dw vram_addr(!tile_e)
    dw vram_addr(!tile_t)
    dw vram_addr(!tile_y)
if not(!no_prompt_box)
    dw vram_addr(!tile_blk)
    dw vram_addr(!tile_blk+1)
endif
..exit:
    dw vram_addr(!tile_x)
    dw vram_addr(!tile_i)
..end:

.size:
if !no_prompt_box
    dw vram_size(1) ; Cursor
else
    dw vram_size(2) ; Cursor
endif
    dw vram_size(1) ; R
    dw vram_size(1) ; E
    dw vram_size(1) ; T
    dw vram_size(1) ; Y
if not(!no_prompt_box)
    dw vram_size(1) ; Black
    dw vram_size(1) ; Black
endif
..exit:
    dw vram_size(1) ; X
    dw vram_size(1) ; I
..end:
