; This block will trigger a checkpoint silently when touched.
; It will set a checkpoint to the secondary exit defined.

!secondary_exit = $0105

incsrc "ram.asm"

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

BodyInside:
HeadInside:
    rep #$20
    lda.w #!secondary_exit|$0200
    sta !retry_ram_set_checkpoint
    sep #$20
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
    rtl

print "A block which will set a checkpoint to secondary exit number !secondary_exit."
