if read1($00FFD5) == $23
    sa1rom
    !sa1   = 1
    !dp    = $3000
    !addr  = $6000
    !bank  = $000000
    !sprite_slots = 22
else
    lorom
    !sa1   = 0
    !dp    = $0000
    !addr  = $0000
    !bank  = $800000
    !sprite_slots = 12
endif

org $00A2EA
    pla
    sta $1D
    pla

org $05D842
    lda $0109|!addr
    db $D0

org $05D9DA
    and #$40
    beq $0E

org $05DAA3
    lda.l $05D78A|!bank,x

org $00F2D8
    lda $13CD|!addr
    nop #2 ; LM edit.

if read1($0DA415) == $5C && read1($0DA106) != $5C
org $0DA415
    sep #$30
    lda $1931|!addr
endif

org $0DA691
    lda.l $001EA2|!addr,x

if read1($009BCB) == $5C
org $00FFD8
    db $01

org $009BCB
    plb
    ldx $010A|!addr

org $009CF5
	bne $2B
    phx
    stz $0109|!addr
endif

org $01AD33
    db $D1

org $01AD3A
    db $D2

org $008E5B
    lda #$FF
    sta $1DF9|!addr

if read1($008F49) == $5C
org $008F49
    lda $0DBE|!addr
    inc
endif
