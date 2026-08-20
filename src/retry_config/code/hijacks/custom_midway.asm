;=====================================
; This inserts the custom midway objects.
; Main custom object code taken from ObjecTool 0.5 by 0x400 and imamelia.
; Custom midway code by worldpeace.
;=====================================

if !use_custom_midway_bar

pushpc

; This restores vanilla code at $0DA415, specifically when either Retry's
; custom objects are not used or when they're used together with Arinsu's
; ObjecTool. This removed a game crash if patching the tool on a ROM that
; already had Retry inserted, and then reinserting Retry.
if read1($0DA415) == $5C && read1(!rom_objectool_byte) != $5C

pushpc

org $0DA415
    sep #$30
    lda $1931|!addr

pullpc

endif ; read1($0DA415) == $5C && read1(!rom_objectool_byte) != $5C

if read2(!rom_ari_objectool_check_addr) == !rom_ari_objectool_check_word

org $0DA104
    jml custom_midway

else

org $0DA415
    jml new_norm_objects

endif ; read2(!rom_ari_objectool_check_addr) == !rom_ari_objectool_check_word

pullpc

if read2(!rom_ari_objectool_check_addr) != !rom_ari_objectool_check_word

new_norm_objects:
    sep #$30

    ; Check if it's a custom normal object.
    lda $5A : cmp #$2D : beq .custom

.not_custom:
    lda $1931|!addr
    jml $0DA41A|!bank

.custom:
    ; Store the first new settings byte.
    ldy #$00
    lda [$65],y : sta $5A

    ; Store the second new settings byte.
    iny
    lda [$65],y : sta $58

    ; Add 2 to the pointer so it ends up in the correct place.
    ; SMW expects them to have 3 bytes but this has 5 bytes.
    iny
    tya : clc : adc $65 : sta $65
    lda $66 : adc #$00 : sta $66

    ; If ObjecTool is inserted...
    lda.l !rom_objectool_byte : cmp #$5C : bne .no_objectool

    ; ...jump to its code if the custom object number is $20-$3F, $42-$4F or $52-$FF.
    lda $5A : cmp #$20 : bcc .no_objectool
              cmp #$40 : beq .no_objectool
              cmp #$41 : beq .no_objectool
              cmp #$50 : beq .no_objectool
              cmp #$51 : beq .no_objectool

    ; Jump to ObjecTool's custom normal objects code.
    ; This jumps in the middle of the NewNormObjects routine, right before PHB : PHK : PLB,
    ; assuming the code won't change in future updates.
    rep #$20
    lda.l !rom_objectool_normal_code_address : clc : adc.w #68 : sta $00
    sep #$20
    lda.l !rom_objectool_normal_code_address+2 : sta $02
    jml [$0000|!dp]

.no_objectool:
    ; Process custom midway
    jsl custom_midway

    ; Jump back to an rts.
    jml $0DA53C|!bank

endif ; read2(!rom_ari_objectool_check_addr) != !rom_ari_objectool_check_word

; Bytes that can read from ROM to check the presence of Retry's custom midway
; feature (if read1($0DA104) == $5C && read2(read3($0DA104+1)-3) == $1337)
dw !custom_midway_interface_magic_word
db !custom_midway_interface_version

custom_midway:
    ; If midways are overridden, don't spawn it.
    lda !ram_midways_override : and #$7F : beq .spawn
    rtl

.spawn:
    ; Backup $59 ($58-$59 used for entrance info).
    lda $59 : pha

    ; Check which type of entrance is set in the extra bytes.
    lda $5A : cmp #$40 : beq .main_entrance
              cmp #$41 : beq .main_entrance
              cmp #$50 : beq .midway_entrance
              cmp #$51 : beq .midway_entrance
              ; Objects $20-$3F would be free but have no use for now
              cmp #$20 : bcs .return

.secondary_entrance:
    and #$01 : ora #$02 : sta $59
    lda $5A : and #$1E : asl #3 : tsb $59
    bra .end

.main_entrance:
    and #$01
    bra +

.midway_entrance:
    and #$01 : ora #$08
+   sta $59

.end:
    ; If there's already enough custom midway objects, return.
    lda !ram_cust_obj_num : cmp.b #!max_custom_midway_num : bcs .return

    ; Update the custom midway objects counter.
    inc : sta !ram_cust_obj_num

    ; (avoid doing DEC by loading addr-2,x later)
    rep #$30
    and #$00FF : asl : tax
    lda $57
    and #$00FF : clc : adc $6B

    ; Store index in $7EC800.
    sec : sbc #$C800 : sta !ram_cust_obj_data-2,x

    ; Store entrance info.
    lda $58 : sta !ram_cust_obj_entr-2,x

    ; If this is the midway that triggered the current checkpoint, don't make it spawn.
    lda !ram_respawn : eor $58 : and #$FBFF
    sep #$30
    beq .return

.spawn_midway:
    ldy $57
    lda #$38 : sta [$6B],y
    lda #$00 : sta [$6E],y
    lda $57 : and #$0F : beq .return
    dey
    lda #$35 : sta [$6B],y
    lda #$00 : sta [$6E],y

.return:
    ; Restore $59.
    pla : sta $59
    rtl

else ; if not(!use_custom_midway_bar)

; Restore code, in case settings are changed.
if read1($0DA104) == $5C

org $0DA104
if read2(!rom_ari_objectool_check_addr) == !rom_ari_objectool_check_word
    rtl : nop #3
else
    db $A1,$6B,$E2,$30
endif ; read2(!rom_ari_objectool_check_addr) == !rom_ari_objectool_check_word

endif ; read1($0DA104) == $5C

endif ; !use_custom_midway_bar
