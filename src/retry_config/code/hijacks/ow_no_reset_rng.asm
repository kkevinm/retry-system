; Normally Overworld and cutscene loading resets a bunch of RAM, including the
; RNG state. This hijack ensures that it won't be reset on Overworld load (since
; it is handled in the Retry code).

pushpc

; $00A1A8 is hijacked by the SA-1 pack
org $00A1AD
    jml ow_no_reset_rng

org $00A1BB
    return:

pullpc

ow_no_reset_rng:
    ; Replicate the vanilla code for $1A-$D7 (X already loaded here)
-   stz $1A,x
    dex : bpl -

    lda $0100|!addr : cmp #$0C : bne .cutscene

    ; For Overworld, reset everything except RNG
    ldx.w #$148B-$13D3-1
-   stz $13D3|!addr,x
    dex : bpl -
    ldx.w #$07CE-($148B-$13D3)-4
-   stz $148F|!addr,x
    dex : bpl -
    jml return

.cutscene:
    ; For cutscenes, replicate the vanilla code
    ; (I'm not sure if not resetting RNG here can cause issues)
    ldx #$07CE
-   stz $13D3|!addr,x
    dex : bpl -
    jml return
