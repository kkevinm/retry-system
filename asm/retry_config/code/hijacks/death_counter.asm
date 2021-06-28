; Position to write the counter too in the status bar.
!counter_status_bar = $0F15|!addr

if !status_death_counter

pushpc

org $008F49
    jml status_death_counter

pullpc

status_death_counter:
    ldx #$04
.tiles_loop:
    lda !ram_death_counter,x : sta !counter_status_bar,x
    dex : bpl .tiles_loop
.hide_loop:
    inx
    lda !ram_death_counter,x : bne .return
    cpx #$04 : beq .return
    lda #$FC : sta !counter_status_bar,x
    bra .hide_loop
.return:
    jml $008F5B|!bank

else

pushpc

; Restore the hijack if settings are changed.
if read1($008F49) == $5C
org $008F49
    lda $0DBE|!addr
    inc
endif

pullpc

endif
