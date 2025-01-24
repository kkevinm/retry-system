checkpoint_effect:
    fillbyte $00 : fill $200

sfx_echo:
    fillbyte $00 : fill $40

reset_rng:
    fillbyte $FF : fill $40

disable_room_cp_sfx:
    fillbyte $00 : fill $40

lose_lives:
    fillbyte $FF : fill $40

macro _check_level(level, macro_name)
    if <level> < 0 || <level> > $1FF
        error "Error: %<macro_name> level values needs to be between $000 and $1FF!"
    endif
endmacro

macro _define_bitwise_index(level)
    !__idx #= (<level>)>>3
endmacro

function _bitwise_table_value(level) = (1<<(7-((level)&7)))

macro checkpoint(level, val)
    %_check_level(<level>, "checkpoint")
    if <val> < 0 || <val> > 3
        error "Error: %checkpoint value needs to be between 0 and 3!"
    endif

    !__idx #= <level>
    !{_checkpoint_effect_!{__idx}} ?= 0
    !{_checkpoint_effect_!{__idx}} #= !{_checkpoint_effect_!{__idx}}|(<val>)
    
    pushpc
    
    org tables_checkpoint_effect+!__idx
        db !{_checkpoint_effect_!{__idx}}
    
    pullpc
endmacro

macro retry(level, val)
    %_check_level(<level>, "retry")
    if <val> < 0 || <val> > 4
        error "Error: %retry value needs to be between 0 and 4!"
    endif
    
    !__idx #= <level>
    !{_checkpoint_effect_!{__idx}} ?= 0
    !{_checkpoint_effect_!{__idx}} #= !{_checkpoint_effect_!{__idx}}|((<val>)<<4)
    
    pushpc
    
    org tables_checkpoint_effect+!__idx
        db !{_checkpoint_effect_!{__idx}}
    
    pullpc
endmacro

macro sfx_echo(level)
    %_check_level(<level>, "sfx_echo")

    %_define_bitwise_index(<level>)
    !{_sfx_echo_!{__idx}} ?= 0
    !{_sfx_echo_!{__idx}} #= !{_sfx_echo_!{__idx}}|_bitwise_table_value(<level>)
    
    pushpc
    
    org tables_sfx_echo+!__idx
        db !{_sfx_echo_!{__idx}}
    
    pullpc
endmacro

macro no_reset_rng(level)
    %_check_level(<level>, "no_reset_rng")

    %_define_bitwise_index(<level>)
    !{_no_reset_rng_!{__idx}} ?= 0
    !{_no_reset_rng_!{__idx}} #= !{_no_reset_rng_!{__idx}}|_bitwise_table_value(<level>)
    
    pushpc
    
    org tables_reset_rng+!__idx
        db !{_no_reset_rng_!{__idx}}^$FF
    
    pullpc
endmacro

macro disable_room_cp_sfx(level)
    %_check_level(<level>, "disable_room_cp_sfx")

    %_define_bitwise_index(<level>)
    !{disable_room_cp_sfx_!{__idx}} ?= 0
    !{disable_room_cp_sfx_!{__idx}} #= !{disable_room_cp_sfx_!{__idx}}|_bitwise_table_value(<level>)

    pushpc
    
    org tables_disable_room_cp_sfx+!__idx
        db !{disable_room_cp_sfx_!{__idx}}
    
    pullpc
endmacro

macro no_lose_lives(level)
    %_check_level(<level>, "no_lose_lives")

    %_define_bitwise_index(<level>)
    !{_no_lose_lives_!{__idx}} ?= 0
    !{_no_lose_lives_!{__idx}} #= !{_no_lose_lives_!{__idx}}|_bitwise_table_value(<level>)

    pushpc
    
    org tables_lose_lives+!__idx
        db !{_no_lose_lives_!{__idx}}^$FF
    
    pullpc
endmacro

macro checkpoint_retry(level, checkpoint, retry)
    %checkpoint(<level>, <checkpoint>)
    %retry(<level>, <retry>)
endmacro

macro settings(level, checkpoint, retry, sfx_echo, no_reset_rng, disable_room_cp_sfx, no_lose_lives)
    %checkpoint_retry(<level>, <checkpoint>, <retry>)
    if <sfx_echo> != 0
        %sfx_echo(<level>)
    endif
    if <no_reset_rng> != 0
        %no_reset_rng(<level>)
    endif
    if <disable_room_cp_sfx> != 0
        %disable_room_cp_sfx(<level>)
    endif
    if <no_lose_lives> != 0
        %no_lose_lives(<level>)
    endif
endmacro
