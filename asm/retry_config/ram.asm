;=====================================
; RAM addresses used by retry.
; You usually don't need to change these.
;=====================================

;=====================================
; What freeram to use.
; 231 + (!max_custom_midway_num*4) bytes are used.
;=====================================
!retry_freeram     = $7FB400
!retry_freeram_sa1 = $40C000

;=====================================
; What freeram is used by AMK. Shoudln't need to be changed usually.
;=====================================
!amk_freeram = $7FB000

;=====================================
; Don't change from here.
;=====================================
if !sa1
    !freeram = !retry_freeram_sa1
else
    !freeram = !retry_freeram
endif

; Use the same offsets as the retry patch to keep compatibility with other resources.
!ram_timer           = !freeram+$00 ; 3
!ram_respawn         = !freeram+$03 ; 2
!ram_is_respawning   = !freeram+$05 ; 1
!ram_music_to_play   = !freeram+$06 ; 1
!ram_hurry_up        = !freeram+$07 ; 1
!ram_door_dest       = !freeram+$08 ; 2
!ram_music_backup    = !freeram+$0A ; 1
!ram_update_request  = !freeram+$0B ; 1
!ram_prompt_phase    = !freeram+$0C ; 1
!ram_update_window   = !freeram+$0D ; 1
!ram_is_dying        = !freeram+$0E ; 1
!ram_prompt_override = !freeram+$0F ; 1
!ram_disable_exit    = !freeram+$10 ; 1
!ram_set_checkpoint  = !freeram+$11 ; 2
!ram_reserved        = !freeram+$13 ; 14 (reserved for future expansion)
!ram_checkpoint      = !freeram+$20 ; 192
!ram_death_counter   = !freeram+$E0 ; 5
!ram_cust_obj_data   = !freeram+$E5 ; 1+(!max_custom_midway_num*4)
