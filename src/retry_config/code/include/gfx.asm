!gfx_bank = ((gfx_letters>>16)&$FF)

macro incgfx(file)
    incbin "../../gfx/<file>.bin"
endmacro

letters:
.box:
    %incgfx(letters1)

.no_box:
    %incgfx(letters2)

if !sprite_status_bar

digits:
    %incgfx(digits)

coins:
    %incgfx(coins)

timer:
    %incgfx(timer)

lives:
    %incgfx(lives)

bonus_stars:
    %incgfx(bonus_stars)

death:
    %incgfx(death)

item_box:
if !8x8_item_box_tile
    %incgfx(item_box_8x8)
else
    %incgfx(item_box_16x16)
endif

if !draw_retry_indicator
indicator:
    %incgfx(indicator)
endif

endif
