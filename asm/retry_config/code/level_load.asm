; Gamemode 11

init:
    ; Reset the custom midway object counter.
    lda #$00 : sta !ram_cust_obj_num
    rtl
