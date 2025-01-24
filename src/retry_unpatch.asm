; Patching this file with Asar will remove all of Retry's hijacks.
; Do not patch this if you don't want to remove the Retry from your ROM,
; and do not insert it with UberASM Tool either.
; Basically, you can ignore this file as long as you're using Retry in your ROM.
; For more information, see "docs/uninstall.html".

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

if read1($00A2EA) == $5C && read4(read3($00A2EA+1)-4) == $4D6E6976
org $00A2EA
    pla
    sta $1D
    pla
endif

org $05D842
    lda $0109|!addr
    db $D0

org $05D9DA
    and #$40
    beq $0E

org $05D9EC
    rep #$10
    lda $01

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
org $009BCB
    plb
    ldx $010A|!addr

if !sa1 == 0
org $00FFD8
    db $01
endif
endif

if read1($009CF5) == $5C
org $009CF5
    bne $2B
    phx
    stz $0109|!addr
endif

org $009E25
    db $04

if read1($01AD33) == $94
org $01AD33
    db $D1
endif

if read1($01AD3A) == $95
org $01AD3A
    db $D2
endif

org $05DA1C
    cmp #$52
    bcc $04

if read1($00C572) == $5C
org $00C572
    lda $15
    and #$08
endif

org $00D0D8
    dec $0DBE|!addr
    bpl $09

org $008E5B
    lda #$FF
    sta $1DF9|!addr

if read1($008F49) == $5C
org $008F49
    lda $0DBE|!addr
    inc

; Here I assume that people won't turn on the "DEATHS" display without also turning on the death counter display.
org $008C89
    db $30,$28,$31,$28,$32,$28,$33,$28,$34,$28,$FC,$38
endif

if read1($0081F4+2) == $69
org $0081F4
    jsr $8DAC
endif

if read1($008275+4) == $69
org $008275
    lda $0D9B|!addr
    beq $18
endif

if read1($0082E8+2) == $69
org $0082E8
    jsr $8DAC
endif

if read1($00985A+2) == $69
org $00985A
    jsr $8CFF
endif

if read1($00A5A8+2) == $69
org $00A5A8
    jsr $8CFF
endif

if read1($05B31B+1) == $69
org $05B31B
    ldy #$1C
endif

org $009856
    lda #$20
    sta $44

org $00D0D8
    dec $0DBE|!addr
    bpl $09
