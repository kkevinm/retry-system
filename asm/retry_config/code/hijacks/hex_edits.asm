pushpc

; Change initial life counter.
org $009E25
    db !initial_lives-1

; Enable/disable life loss on death.
org $00D0D8
if !lose_lives
    dec $0DBE|!addr
else
    bra $01
endif

; Initial sprite facing fix.
; Easier to just fix the SubHorzPos routine in bank 1 rather than updating $D1.
org $01AD33
if !initial_facing_fix
    db $94
else
    db $D1
endif

org $01AD3A
if !initial_facing_fix
    db $95
else
    db $D2
endif

pullpc
