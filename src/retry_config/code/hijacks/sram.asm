; This file handles expanding the normal SRAM and saving custom addresses to it.
; It works on both lorom (SRAM) and SA-1 (BW-RAM).

; Bank byte of the SRAM/BW-RAM address.
!sram_bank          = (!sram_addr>>16)
!sram_defaults_bank = (tables_sram_defaults>>16)

; How big is the save table.
!save_table_size           = (tables_sram_defaults-tables_save)
!save_table_size_game_over = (tables_save_not_game_over-tables_save)

if !sram_feature

pushpc

; Change SRAM size in the header.
if read1($00FFD8) < !sram_size
org $00FFD8
    db !sram_size
endif

; Hijack save game routine.
org $009BCB
    jml save_game

; Hijack load game routine.
org $009CF5
    jml load_game

pullpc

; Place the MVN routine in RAM to be able to change the bank parameters at runtime
; MVN <src_bank>,<dst_bank> : RTS
; Note that MVN has dst_bank before src_bank when assembled
base $0008|!dp
    data_transfer:
        .mvn:      skip 1
        .dst_bank: skip 1
        .src_bank: skip 1
        .rts:      skip 1
base off

; Setup MVN and RTS in data_tranfer
macro setup_data_transfer()
    ; MVN = opcode $54
    lda #$54 : sta.b data_transfer_mvn

    ; RTS = opcode $60
    lda #$60 : sta.b data_transfer_rts
endmacro

macro next_iteration()
    ; Progress to the sram address to save to
    lda $02 : clc : adc $04 : sta $02
    
    ; Restore registers
    plb : plx
    
    ; Increase save table index
    txa : clc : adc #$0005 : tax

    ; If not at the end of the save table, loop
    cpx $06 : bcc .loop
endmacro

;=====================================
; save_game routine
;=====================================
save_game:
    ; Set the DBR.
    phk : plb

    ; Call the custom save routine.
    php : phb
    jsr extra_save_file
    plb : plp

    ; Setup data transfer routine
    %setup_data_transfer()

    ; Write destination bank parameter in data transfer routine
    lda.b #!sram_bank : sta.b data_transfer_dst_bank

    ; $02 = starting sram address
    jsr get_sram_addr : sta $02

    ; $06 = save table size to save
    lda.w #!save_table_size : sta $06

    ldx #$0000
.loop:
    ; $00 = source address
    lda.w tables_save,x : sta $00
    phx : phb
    
    ; $04 = transfer size
    lda.w tables_save+3,x : sta $04

    ; Push MVN accumulator parameter on the stack (size - 1)
    dec : pha

    ; Write source bank parameter in data transfer routine
    sep #$20
    lda.w tables_save+2,x : sta.b data_transfer_src_bank
    rep #$20

    ; Call the data transfer routine with parameters:
    ; - X = $00 = source address
    ; - Y = $02 = destination address
    ; - A = transfer size - 1
    ldx $00
    ldy $02
    pla
    jsr.w data_transfer

    ; Loop the entire save table
    %next_iteration()

.end:
    sep #$30
    
    ; Restore original code and jump back.
    plb
    ldx $010A|!addr
    jml $009BCF|!bank

;=====================================
; load_game routine
;=====================================
load_game:
    ; Load or init the file
    beq +
    jmp init_file
+   
    ; Preserve DB, X, Y, P.
    phb : phk : plb
    phx : phy : php

    ; Call the custom load routine.
    sep #$30
    php : phb
    jsr extra_load_file
    plb : plp

    ; $06 = save table size to load (entire table)
    rep #$30
    lda.w #!save_table_size : sta $06

    ; Load the save file.
    jsr load_file

    ; Restore DBR, P, X and Y.
    plp : ply : plx
    plb
    
    ; Restore original code and jump back.
    phx
    stz $0109|!addr
    jml $009CFB|!bank

load_game_over:
    ; Preserve DB, X, Y, P.
    phb : phk : plb
    phx : phy : php

    ; $06 = save table size to load (not the game_over part)
    rep #$30
    lda.w #!save_table_size_game_over : sta $06

    ; Load the save file.
    jsr load_file

    ; Restore DBR, P, X and Y.
    plp : ply : plx
    plb
    rtl

load_file:
    sep #$20

    ; Setup data transfer routine
    %setup_data_transfer()

    ; Write source bank parameter in data transfer routine
    lda.b #!sram_bank : sta.b data_transfer_src_bank

    ; $02 = starting sram address
    jsr get_sram_addr : sta $02

    ; Load the data from sram
    jsr load_data
    rts

init_file:
    ; Preserve X and Y.
    phx : phy

    ; Set 8 bit X/Y for the custom routine.
    sep #$10

    ; Set DBR.
    phb : phk : plb

    ; Call the custom load routine.
    php : phb
    jsr extra_load_new_file
    plb : plp

    ; Setup data transfer routine
    %setup_data_transfer()

    ; Write source bank parameter in data transfer routine
    lda.b #!sram_defaults_bank : sta.b data_transfer_src_bank

    ; $02 = starting sram defaults address
    rep #$30
    lda.w #tables_sram_defaults : sta $02

    ; $06 = save table size
    lda.w #!save_table_size : sta $06

    ; Load the data from rom (sram defaults table)
    jsr load_data

    ; Initialize the intro level checkpoint.
    jsr shared_get_intro_sublevel
    sta !ram_checkpoint

    ; Keep 16 bit X/Y for the original code.
    sep #$20

    ; Restore DBR, Y and X.
    plb : ply : plx

    ; Jump back.
    jml $009D22|!bank

; Helper routine for load_file and init_file operations
; Inputs:
; - A,X,Y 16 bit
; - $02 = starting address to load from
; - $06 = table size
; - data_transfer mvn, rts and src_bank set up
load_data:
    ldx #$0000
.loop:
    ; Y = destination address
    lda.w tables_save,x : tay

    phx : phb
    
    ; $04 = transfer size
    lda.w tables_save+3,x : sta $04

    ; Push MVN accumulator parameter on the stack (size - 1)
    dec : pha
    
    ; Write destination bank parameter in data transfer routine
    sep #$20
    lda.w tables_save+2,x : sta.b data_transfer_dst_bank
    rep #$20

    ; Call the data transfer routine with parameters:
    ; - X = $02 = source address
    ; - Y = destination address (loaded earlier)
    ; - A = transfer size - 1
    ldx $02
    pla
    jsr.w data_transfer
    
    ; Loop the entire save table
    %next_iteration()

.end:
    rts

;=====================================
; get_sram_addr routine.
;
; Small routine to get the low and high byte of the destination address into $02.
;=====================================
get_sram_addr:
    rep #$30
    lda $010A|!addr : and #$00FF : asl : tax
    lda.l .sram_addr,x
    rts    

.sram_addr:
    dw !sram_addr,!sram_addr+!file_size,!sram_addr+(2*!file_size)

else

; Restore code, in case settings are changed.
if not(!sram_plus) && not(!bwram_plus)

pushpc

if read1($00FFD8) == !sram_size
org $00FFD8
    db $01
endif

if read1($009BCB) == $5C
org $009BCB
    plb
    ldx $010A|!addr
endif

if read1($009CF5) == $5C
org $009CF5
    bne $2B
    phx
    stz $0109|!addr
endif

pullpc

endif

endif
