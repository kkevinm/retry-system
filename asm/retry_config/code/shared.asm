;=====================================
; Shared routines and macros.
;=====================================

;=====================================
; Routine to get the prompt type for the current level.
;=====================================
get_prompt_type:
    ; If the override address is set, skip the rest.
    lda !ram_prompt_override : bne .not_default

    ; Otherwise, if the effect for this level is set, skip the default.
    rep #$10
    ldx $010B|!addr
    lda.l tables_effect,x
    sep #$10
    bne .not_default

    ; Otheriwse, use the default value.
    lda.b #!default_prompt_type+1

.not_default:
    rts

;=====================================
; Get translevel number the player is standing on the overworld.
;=====================================
get_translevel:
    ldy $0DD6|!addr
    lda $1F17|!addr,y : lsr #4 : sta $00
    lda $1F19|!addr,y : and #$F0 : ora $00 : sta $00
    lda $1F1A|!addr,y : asl : ora $1F18|!addr,y
    ldy $0DB3|!addr
    ldx $1F11|!addr,y : beq +
    clc : adc #$04
+   sta $01
    rep #$10
    ldx $00
    lda !7ED000,x : sta $13BF|!addr
    sep #$10
    rts

;=====================================
; Routine to save the current level's custom checkpoint value and set the midway flag.
;=====================================
hard_save:
    ; Filter title screen, etc.
    lda $0109|!addr : beq .no_intro
    cmp.b #!intro_level+$24 : beq .no_intro ; bne?
    rts

.no_intro:
    phx

    ; We won't rely on $13CE anymore, so set the midway flag in $1EA2.
    ldx $13BF|!addr
    lda $1EA2|!addr,x : ora #$40 : sta $1EA2|!addr,x

    ; Set the level's custom checkpoint.
    txa : asl : tax
    rep #$20
    lda !ram_respawn : sta !ram_checkpoint,x
    sep #$20

if !save_on_checkpoint
    ; Set up vanilla SRAM buffer.
    phb
    rep #$30
    ldx.w #$1EA2|!addr
    ldy.w #$1F49|!addr
    lda.w #$008C
    mvn $00,$00
    sep #$30
    plb

    ; Save to SRAM/BW-RAM.
    jsl $009BC9|!bank
endif

    plx
    rts

;=====================================
; Routines to reset and save the dcsave buffers.
;=====================================
if !dcsave
dcsave:
.init:
    ; Load the address to the dcsave init wrapper routine.
    rep #$20
    lda.l $05D7AC|!bank : clc : adc #$0011 : sta $0D
    sep #$20
    lda.l $05D7AE|!bank : sta $0F

    ; Call the dcsave routine.
if !sa1
    %invoke_sa1(.jml)
else
    jsl .jml
endif

    rts

.midpoint:
    ; Only save if !Midpoint = 1
    lda $00CA2B|!bank : cmp #$22 : bne ..return

    ; Load the address to the dcsave save buffer routine.
    rep #$20
    lda.l $00CA2C|!bank : sta $0D
    sep #$20
    lda.l $00CA2E|!bank : sta $0F

    ; Call the dcsave routine.
    jsl .jml

..return:
    rts

.jml:
    jml [$000D|!dp]
endif

;=====================================
; Macro to get current screen number in X.
;=====================================
macro get_screen_number()
if !lm3
    jsl $03BCDC|!bank
else
    ldx $95
    lda $5B : lsr : bcc ?+
    ldx $97
?+
endif
endmacro
