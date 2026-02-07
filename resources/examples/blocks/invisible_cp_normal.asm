; This block will trigger a checkpoint silently when touched.
; It will act as a vanilla checkpoint, so by default it will give a checkpoint
; to the main level's midway entrance. If the %checkpoint value for the sublevel
; is 1 (in Retry's "settings_local.asm"), it will give a checkpoint to the
; current sublevel's midway entrance.

incsrc "ram.asm"

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

BodyInside:
HeadInside:
    lda #$00 : sta !retry_ram_set_checkpoint
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
    rtl

print "A block which will set the midway for the current level. Depending on the Retry settings, it will give the midway for the main level or the sublevel."
