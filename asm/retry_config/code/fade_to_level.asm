; Gamemode 0F

init:
    ; If entering from the overworld, skip.
    lda $141A|!addr : beq main

    ; If respawning from Retry, skip.
    lda !ram_is_respawning : bne main

    ; Backup the current entrance value for later.
    %get_screen_number()
    lda $19B8|!addr,x : sta !ram_door_dest
    lda $19D8|!addr,x : sta !ram_door_dest+1

main:
if !fast_transitions
    ; Reset the mosaic timer.
    stz $0DB1|!addr
endif

    rtl
