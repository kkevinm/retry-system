checkpoint_effect:
    %dbn($00,$200)

sfx_echo:
if !default_sfx_echo
    %dbn($FF,$40)
else
    %dbn($00,$40)
endif

if !reset_rng < !reset_rng_type_min || !reset_rng > !reset_rng_type_max
    error "Error: \!rng_reset value needs to be between !reset_rng_type_min and !reset_rng_type_max!"
endif

reset_rng:
    %dbn(!reset_rng,$200)

disable_room_cp_sfx:
    %dbn($00,$40)

lose_lives:
    %dbn($FF,$40)

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
    if <val> < !checkpoint_type_min || <val> > !checkpoint_type_max
        error "Error: %checkpoint value needs to be between !checkpoint_type_min and !checkpoint_type_max!"
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
    if <val> < !retry_type_min || <val> > !retry_type_max
        error "Error: %retry value needs to be between !retry_type_min and !retry_type_max!"
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
if !default_sfx_echo
    !{_sfx_echo_!{__idx}} ?= $FF
    !{_sfx_echo_!{__idx}} #= !{_sfx_echo_!{__idx}}&(_bitwise_table_value(<level>)^$FF)
else
    !{_sfx_echo_!{__idx}} ?= 0
    !{_sfx_echo_!{__idx}} #= !{_sfx_echo_!{__idx}}|_bitwise_table_value(<level>)
endif
    
    pushpc
    
    org tables_sfx_echo+!__idx
        db !{_sfx_echo_!{__idx}}
    
    pullpc
endmacro

macro reset_rng(level, val)
    %_check_level(<level>, "reset_rng")
    if <val> < !reset_rng_type_min || <val> > !reset_rng_type_max
        error "Error: %rng_reset value needs to be between !reset_rng_type_min and !reset_rng_type_max!"
    endif

    pushpc
    
    org tables_reset_rng+<level>
        db <val>

    pullpc
endmacro

macro no_room_cp_sfx(level)
    %_check_level(<level>, "no_room_cp_sfx")

    %_define_bitwise_index(<level>)
    !{no_room_cp_sfx_!{__idx}} ?= 0
    !{no_room_cp_sfx_!{__idx}} #= !{no_room_cp_sfx_!{__idx}}|_bitwise_table_value(<level>)

    pushpc
    
    org tables_disable_room_cp_sfx+!__idx
        db !{no_room_cp_sfx_!{__idx}}
    
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

macro settings(level, checkpoint, retry, sfx_echo, reset_rng, no_room_cp_sfx, no_lose_lives)
    %checkpoint_retry(<level>, <checkpoint>, <retry>)
    if <sfx_echo> != 0
        %sfx_echo(<level>)
    endif
    %reset_rng(<level>, <reset_rng>)
    if <no_room_cp_sfx> != 0
        %no_room_cp_sfx(<level>)
    endif
    if <no_lose_lives> != 0
        %no_lose_lives(<level>)
    endif
endmacro
