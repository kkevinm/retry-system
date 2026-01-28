namespace nested off

; Macros to load files and namespace them easily.
macro incsrc(folder,file)
    namespace <file>
        incsrc "../retry_config/<folder>/<file>.asm"
    namespace off
endmacro

; Label used in retry_gm.asm
empty:
    rtl

;===============================================================================
; Load shared settings, defines and resources.
;===============================================================================
    %incsrc(code/include,defines)
    %incsrc(code/include,misc)
    %incsrc(code/include,rom)
    %incsrc("",ram)
    %incsrc("",settings_global)
    %incsrc(code/include,gfx)
    
;===============================================================================
; Check incompatibilities.
;===============================================================================
    %incsrc(code,check_incompatibilities)

;===============================================================================
; Load the user tables.
;===============================================================================
    %incsrc(code/include,ssb_tables)
if !use_legacy_tables
    %incsrc(legacy,tables)
else
    %incsrc(code/include,tables)
    %incsrc("",settings_local)
endif
if !sram_feature
    %incsrc("",sram_tables)
endif

;===============================================================================
; Load the code.
;===============================================================================
    %incsrc(code,shared)
    %incsrc("",extra)
    %incsrc(code,startup)
    %incsrc(code,fade_to_level)
    %incsrc(code,level_init_1)
    %incsrc(code,level_init_2)
    %incsrc(code,level_init_3)
    %incsrc(code,level_transition)
    %incsrc(code,in_level)
    %incsrc(code,prompt)
    %incsrc(code,nmi)
    %incsrc(code,load_overworld)
    %incsrc(code,fade_to_overworld)
    %incsrc(code,game_over)
    %incsrc(code,time_up)
    %incsrc(code,sprite_status_bar)
    %incsrc(code,api)

;===============================================================================
; Load the hijacks.
;===============================================================================
    %incsrc(code/hijacks,hex_edits)
    %incsrc(code/hijacks,multiple_midways)
    %incsrc(code/hijacks,vanilla_midway)
    %incsrc(code/hijacks,custom_midway)
    %incsrc(code/hijacks,sram)
    %incsrc(code/hijacks,hurry_up)
    %incsrc(code/hijacks,death_counter_vanilla)
    %incsrc(code/hijacks,initial_facing_fix)
    %incsrc(code/hijacks,item_box_fix)
    %incsrc(code/hijacks,remove_status_bar)
    %incsrc(code/hijacks,vanilla_boss_gm13)
    %incsrc(code/hijacks,switch_palace_message_fix)
    %incsrc(code/hijacks,ow_no_reset_rng)
