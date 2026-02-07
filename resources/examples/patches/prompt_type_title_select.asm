; Patch to change the 1/2 players options on the file select screen to
; "Instant Retry" / "Prompt Retry".
; To change the options edit the tables below.

incsrc "ram.asm"

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
else
    lorom
    !addr = $0000
endif

org $009E0D
    jsr SetRetryPrompt

; Free space in bank 0
org $00BA4D
SetRetryPrompt:
	; Set prompt type from menu selection
    lda.w PromptType,x
    sta !retry_ram_prompt_override
    ; Always player 1
    stz $0DB2|!addr
    rts

; Retry prompt type for 1/2 players (same format %checkpoint in settings_local.asm)
PromptType:
    db $03,$02

; Change the text displayed
org $05B88E
	db $12,$0C ; I
	db $17,$0C ; N
	db $1C,$0C ; S
	db $1D,$0C ; T
	db $0A,$0C ; A
	db $17,$0C ; N
	db $1D,$0C ; T
	db $FC,$38 ; 
	db $1B,$0C ; R
	db $0E,$0C ; E
	db $1D,$0C ; T
	db $1B,$0C ; R
	db $22,$0C ; Y

org $05B8AC
	db $19,$0C ; P
	db $1B,$0C ; R
	db $18,$0C ; O
	db $16,$0C ; M
	db $19,$0C ; P
	db $1D,$0C ; T
	db $FC,$38 ;
	db $1B,$0C ; R
	db $0E,$0C ; E
	db $1D,$0C ; T
	db $1B,$0C ; R
	db $22,$0C ; Y
	db $FC,$38 ;
