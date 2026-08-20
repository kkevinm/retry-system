;=====================================;
; Save and SRAM default values tables ;
;=====================================;
; This table can be used to save custom values to SRAM, so they can persist when the console is turned off.
; By default it saves the custom checkpoint ram (so multiple midways will save properly) and the death counter.
; Each line is formatted as follows:
;  dl $XXXXXX : dw $YYYY
; where:
;  $XXXXXX = what RAM address to save. Make sure it's always 3 bytes long (i.e. use $7E0019 instead of $19 or $0019).
;  $YYYY = how many bytes to save at that address (remove the $ to use a decimal value).
; For example, adding "dl $7E1F3C : dw 12" will make the 1-Up checkpoints for all levels save.
; Make sure to always put a colon between the two elements!
; The addresses you put under ".not_game_over" will be saved like usual, but they won't be reloaded from SRAM when getting a game over.
; This can be useful if you want some things to retain even if the player got a game over before being able to save them.
; The addresses you put under ".global" behave differently than the others: they will be saved independently from the save slots,
; and are only loaded when booting the game. This can be used to save stuff that's global and not related to a specific save slot
; (for example like Jump 1/2's costumes, which when you unlock are then available in all save files and all successive playthroughs).
;
; Note: for each address you add here, you need to add the default values in the sram_defaults table below.
; Note: if using SA-1, for addresses in $7E0100-$7E1FFF you must change them to $400100-$401FFF and for addresses $7E0000-$7E00FF you must change them to $003000-$0030FF.
;       Additionally, a lot of other addresses might be remapped to different locations (see SA-1 docs for more info).
; Note: in the "save" and ".not_game_over" tables combined you can put up to 2688 bytes on SA-1, and up to 2005 bytes on lorom.
;       In the ".global" table you can put up to 124 bytes.

save:
    dl !retry_ram_checkpoint    : dw 2*!ow_levels_count
    ; Feel free to add your own stuff here.
    

.not_game_over:
    dl !retry_ram_death_counter : dw 5
    ; Feel free to add your own stuff here.
    

.global:
    ; Feel free to add your own stuff here.
    

; Here you specify the default values of the addresses you want to save, for when a new save file is started.
; You can do "db $XX,$XX,..." for 1 byte values, "dw $XXXX,$XXXX,..." for 2 bytes values and "dl $XXXXXX,$XXXXXX,..." for 3 bytes values. If you need to insert a lot of repeating values in a row, you can use
; %dbn($XX,n) for 1 byte values, %dwn($XXXX,n) for 2 byte values or %dln($XXXXXX,n) for 3 byte values, where n is
; the amount of times the value is repeated (max 242).
; The amount of values of each entry should correspond to the dw $YYYY value in the save table
; (for example, the death counter values are 5).
; If you have some addresses after ".not_game_over" and ".global" in the save table, put their default values after
; ".not_game_over" and ".global" here too (in the same order as the other table, of course).
; Regarding the ".global" values, they will be initialized on game startup rather than on a new save file.

sram_defaults:
    ; Default checkpoint values (don't edit this!).
    for i = 0..!ow_levels_count
        dw select(greater(!i,$24),!i+$DC,!i)
    endfor
    ; Feel free to add your own stuff here.
    

.not_game_over:
    ; Initial death counter value (don't edit this!).
    %dbn($00,5)
    ; Feel free to add your own stuff here.
    

.global:
    ; Feel free to add your own stuff here.
    
