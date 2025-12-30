; NES Popils sound engine disassembly
; This file is meant to be viewed with tabs set to 8 spaces


channel			=	$F9
soundMode		=	$FA	; 0 = music, 1 = sfx

		.segment "SOUND_RAM"
sndNew:
musNew:			.res	1
sfxNew:			.res	1
sndVolume:		.res	2
sndPlaying:		.res	2
sndChanMask:
musChanMask:		.res	1
sfxChanMask:		.res	1
sndBank:		.res	2
chanPtrHi:		.res	8
chanPtrLo:		.res	8
chanPulseSetupVal:	.res	8
chanEnvType:		.res	8
chanEnvOffset:		.res	8
chanAPUTimerOffset:	.res	8
chanSweepType:		.res	8
chanNote:		.res	8
chanTimer:		.res	8
chanEnvCursor:		.res	8
chanSweepCursor:	.res	8
chanNoteDur:		.res	8
chanMuted:		.res	4
sndTempo:		.res	2
chanTranspose:		.res	8
chanParentPtrHi:	.res	8
chanParentPtrLo:	.res	8
chanSweep:		.res	8

		.segment "SOUND_ENGINE"

CodeStart:

; =============== S U B R O U T I N E =======================================


InitSound:                   
                STA     $FC
                TAX
                LDA     bankTbl,X
                LDX     soundMode
                STA     sndBank,X
                LDX     #7              ; map bank for this song to a000-bfff
                STX     $8000
                STA     $8001
                LDA     #0
                STA     $FD
                ASL     $FC
                ROL     $FD
                ASL     $FC
                ROL     $FD
                ASL     $FC
                ROL     $FD
                CLC
                LDA     #<SoundDataTbl
                ADC     $FC
                STA     $FC
                LDA     #>SoundDataTbl
                ADC     $FD
                STA     $FD
                LDX     soundMode
                BEQ     _music
                LDA     sndChanMask,X   ; sfx init
                EOR     #$F
                STA     sndChanMask,X
                LDA     $4015
                AND     sndChanMask,X
                JMP     loc_8165
; ---------------------------------------------------------------------------

_music:                                 ; CODE XREF: InitSound+32↑j
                LDA     $4015
                AND     sfxChanMask

loc_8165:                               ; CODE XREF: InitSound+42↑j
                STA     $4015
                LDA     #0
                STA     sndChanMask,X
                STA     sndVolume,X
                STA     sndTempo,X
                TXA
                ASL     A
                ASL     A
                TAX
                LDY     #0

loc_8179:                               ; CODE XREF: InitSound+A1↓j
                LDA     ($FC),Y
                STA     chanPtrLo,X
                INY
                LDA     ($FC),Y
                STA     chanPtrHi,X
                BEQ     loc_819B
                TXA
                PHA
                TYA
                PHA
                LSR     A
                TAY
                LDA     chanBits,Y
                LDX     soundMode
                ORA     sndChanMask,X
                STA     sndChanMask,X
                PLA
                TAY
                PLA
                TAX

loc_819B:                               ; CODE XREF: InitSound+6A↑j
                INY
                LDA     #0
                STA     chanEnvCursor,X
                STA     chanSweepCursor,X
                STA     chanAPUTimerOffset,X
                STA     chanTimer,X
                STA     chanTranspose,X
                STA     chanEnvOffset,X
                STA     chanNote,X
                LDA     #1
                STA     chanNoteDur,X
                INX
                CPY     #8
                BNE     loc_8179
                RTS
; End of function InitSound

; ---------------------------------------------------------------------------
chanBits:
		.byte   1
                .byte   2
                .byte   4
                .byte   8

; =============== S U B R O U T I N E =======================================


MuteSound:                              ; CODE XREF: RunSoundEngine+32↓p
                LDA     soundMode
                BEQ     loc_81F0
                TAX
                ASL     A
                ASL     A
                TAY
                LDA     sndChanMask,X

loc_81CD:                               ; CODE XREF: MuteSound+3B↓j
                EOR     #$F
                STA     sndChanMask,X
                LDA     $4015
                AND     sndChanMask,X
                STA     $4015
                LDA     #0
                STA     sndChanMask,X
                STA     chanPtrHi,Y
                STA     chanPtrHi+1,Y
                STA     chanPtrHi+2,Y
                STA     chanPtrHi+3,Y
                STA     chanNote,Y
                RTS
; ---------------------------------------------------------------------------

loc_81F0:                               ; CODE XREF: MuteSound+2↑j
                TAX
                ASL     A
                ASL     A
                TAY
                LDA     sndChanMask
                AND     sfxChanMask
                EOR     sndChanMask
                JMP     loc_81CD
; End of function MuteSound


; =============== S U B R O U T I N E =======================================


RunSoundEngine:
                INC     $FB
                LDA     #0
                STA     chanMuted+0
                STA     chanMuted+1
                STA     chanMuted+2
                STA     chanMuted+3
                LDA     #1
                STA     soundMode

loc_8214:                               ; CODE XREF: RunSoundEngine+4D↓j
                LDX     soundMode
                LDA     sndBank,X
                LDX     #7
                STX     $8000
                STA     $8001
                LDX     soundMode
                LDA     sndNew,X        ; new song?
                CMP     sndPlaying,X
                BEQ     keepPlaying
                CMP     #0              ; sound 0?
                BNE     newSound
                STA     sndPlaying,X
                JSR     MuteSound
                JMP     loc_824B
; ---------------------------------------------------------------------------

newSound:                               ; CODE XREF: RunSoundEngine+2D↑j
                ORA     #$80
                STA     sndNew,X
                STA     sndPlaying,X
                AND     #$7F
                JSR     InitSound

keepPlaying:                            ; CODE XREF: RunSoundEngine+29↑j
                JSR     sub_828A
                JSR     sub_826A

loc_824B:                               ; CODE XREF: RunSoundEngine+35↑j
                DEC     soundMode
                BPL     loc_8214
                LDY     #1

loc_8251:                               ; CODE XREF: RunSoundEngine+67↓j
                TYA
                ASL     A
                ASL     A
                TAX
                LDA     chanPtrHi,X
                ORA     chanPtrHi+1,X
                ORA     chanPtrHi+2,X
                ORA     chanPtrHi+3,X
                BNE     loc_8266
                STA     sndNew,Y

loc_8266:                               ; CODE XREF: RunSoundEngine+61↑j
                DEY
                BPL     loc_8251
                RTS
; End of function RunSoundEngine


; =============== S U B R O U T I N E =======================================


sub_826A:                               ; CODE XREF: RunSoundEngine+48↑p
                LDX     soundMode
                LDA     sndVolume,X
                BEQ     locret_8280
                BMI     loc_8281
                INC     sndVolume,X
                BPL     locret_8280
                LDA     #0
                STA     sndNew,X

loc_827D:                               ; CODE XREF: sub_826A+1E↓j
                STA     sndVolume,X

locret_8280:                            ; CODE XREF: sub_826A+5↑j
                                        ; sub_826A+C↑j ...
                RTS
; ---------------------------------------------------------------------------

loc_8281:                               ; CODE XREF: sub_826A+7↑j
                DEC     sndVolume,X
                BMI     locret_8280
                LDA     #0
                BEQ     loc_827D
; End of function sub_826A


; =============== S U B R O U T I N E =======================================


sub_828A:                               ; CODE XREF: RunSoundEngine:keepPlaying↑p
                LDA     #3
                STA     channel

loc_828E:                               ; CODE XREF: sub_828A+AD↓j
                LDA     soundMode
                ASL     A
                ASL     A
                ADC     channel
                TAX
                LDA     chanPtrHi,X
                BNE     loc_829D
                JMP     nextChan
; ---------------------------------------------------------------------------

loc_829D:                               ; CODE XREF: sub_828A+E↑j
                DEC     chanTimer,X
                BPL     loc_82BF
                LDY     soundMode
                LDA     sndTempo,Y
                STA     chanTimer,X
                DEC     chanNoteDur,X
                BNE     loc_82BF
                LDA     #$FF
                STA     chanEnvCursor,X
                STA     chanSweepCursor,X
                JSR     ChanDoNext
                LDA     chanPtrHi,X
                BEQ     nextChan

loc_82BF:                               ; CODE XREF: sub_828A+16↑j
                                        ; sub_828A+23↑j
                INC     chanSweepCursor,X
                LDY     chanSweepType,X
                LDA     chanSweepCursor,X
                CMP     sweepEndPointTbl,Y
                BCC     loc_82D3
                LDA     sweepLoopPointTbl,Y
                STA     chanSweepCursor,X

loc_82D3:                               ; CODE XREF: sub_828A+41↑j
                TYA
                ASL     A
                TAY
                LDA     sweepDataTbl,Y
                STA     $FE
                LDA     sweepDataTbl+1,Y
                STA     $FF
                LDY     chanSweepCursor,X
                LDA     ($FE),Y
                STA     chanSweep,X
                JSR     UpdateChanPitch
                INC     chanEnvCursor,X
                LDY     chanEnvType,X
                LDA     chanEnvCursor,X
                CMP     envEndPointTbl,Y
                BCC     loc_82FF
                LDA     envLoopPointTbl,Y
                STA     chanEnvCursor,X

loc_82FF:                               ; CODE XREF: sub_828A+6D↑j
                TYA
                ASL     A
                TAY
                LDA     envDataTbl,Y
                STA     $FE
                LDA     envDataTbl+1,Y
                STA     $FF
                LDY     chanEnvCursor,X
                LDA     ($FE),Y
                SEC
                SBC     chanEnvOffset,X
                BPL     loc_8319
                LDA     #0

loc_8319:                               ; CODE XREF: sub_828A+8B↑j
                STA     $F7
                LDY     soundMode
                LDA     sndVolume,Y
                LSR     A
                LSR     A
                LSR     A
                AND     #$F
                STA     $F8
                LDA     $F7
                SEC
                SBC     $F8
                BPL     loc_8330
                LDA     #0

loc_8330:                               ; CODE XREF: sub_828A+A2↑j
                JSR     UpdateChanVolume

nextChan:                               ; CODE XREF: sub_828A+10↑j
                                        ; sub_828A+33↑j
                DEC     channel
                BMI     locret_833A
                JMP     loc_828E
; ---------------------------------------------------------------------------

locret_833A:                            ; CODE XREF: sub_828A+AB↑j
                RTS
; End of function sub_828A


; =============== S U B R O U T I N E =======================================


ChanDoNext:                             ; CODE XREF: sub_828A+2D↑p
                                        ; CmdSetChanPtr+E↓j ...
                LDA     chanPtrHi,X
                STA     $FD
                LDA     chanPtrLo,X
                STA     $FC
                LDY     #0

fetchChan:                              ; CODE XREF: CmdSetEnvOffset+6↓j
                                        ; CmdSetEnvType+6↓j ...
                LDA     ($FC),Y
                INY
                CMP     #0
                BMI     loc_835E        ; high bit set = cmd
                STA     chanNote,X      ; else it's a note
                LDA     ($FC),Y
                INY
                STA     chanNoteDur,X
                JSR     PlayChanNote
                JSR     AddChanPtr
                RTS
; ---------------------------------------------------------------------------

loc_835E:                               ; CODE XREF: ChanDoNext+11↑j
                STX     $FF
                AND     #$7F
                CMP     #$E             ; valid commands are 0-d
                BCC     loc_836A
                JSR     AddChanPtr
                RTS
; ---------------------------------------------------------------------------

loc_836A:                               ; CODE XREF: ChanDoNext+29↑j
                ASL     A
                TAX
                LDA     cmdTbl+1,X
                PHA
                LDA     cmdTbl,X
                PHA
                LDX     $FF
                RTS
; End of function ChanDoNext

; ---------------------------------------------------------------------------
cmdTbl:         .word CmdSetNoteDur-1		; $80
                .word CmdSetEnvOffset-1		; $81
                .word CmdSetEnvType-1		; $82
                .word CmdSetPulseSetupVal-1	; $83
                .word CmdSetTempo-1		; $84
                .word CmdSetTimerOffset-1	; $85
                .word CmdSetChanPtr-1		; $86
                .word CmdMuteChan-1		; $87
                .word CmdRest-1			; $88
                .word CmdSetTranspose-1		; $89
                .word CmdSub-1			; $8a
                .word CmdRet-1			; $8b
                .word CmdSetSweepType-1		; $8c
                .word CmdPlaySFX-1		; $8d

; =============== S U B R O U T I N E =======================================


CmdSetNoteDur:                          ; DATA XREF: ROM:cmdTbl↑t
                LDA     ($FC),Y
                INY
                STA     chanNoteDur,X
                JSR     AddChanPtr
                RTS
; End of function CmdSetNoteDur


; =============== S U B R O U T I N E =======================================


CmdSetEnvOffset:                        ; DATA XREF: ROM:8379↑t
                LDA     ($FC),Y
                INY
                STA     chanEnvOffset,X
                JMP     fetchChan
; End of function CmdSetEnvOffset


; =============== S U B R O U T I N E =======================================


CmdSetEnvType:                          ; DATA XREF: ROM:837B↑t
                LDA     ($FC),Y
                INY
                STA     chanEnvType,X
                JMP     fetchChan
; End of function CmdSetEnvType


; =============== S U B R O U T I N E =======================================


CmdSetPulseSetupVal:                    ; DATA XREF: ROM:837D↑t
                LDA     ($FC),Y
                INY
                STA     chanPulseSetupVal,X
                JMP     fetchChan
; End of function CmdSetPulseSetupVal


; =============== S U B R O U T I N E =======================================


CmdSetTempo:                            ; DATA XREF: ROM:837F↑t
                TXA
                PHA
                LDA     ($FC),Y
                INY
                LDX     soundMode
                STA     sndTempo,X
                PLA
                TAX
                JMP     fetchChan
; End of function CmdSetTempo


; =============== S U B R O U T I N E =======================================


CmdSetTimerOffset:                      ; DATA XREF: ROM:8381↑t
                LDA     ($FC),Y
                INY
                STA     chanAPUTimerOffset,X
                JMP     fetchChan
; End of function CmdSetTimerOffset


; =============== S U B R O U T I N E =======================================


CmdSetSweepType:                        ; DATA XREF: ROM:838F↑t
                LDA     ($FC),Y
                INY
                STA     chanSweepType,X
                JMP     fetchChan
; End of function CmdSetSweepType


; =============== S U B R O U T I N E =======================================


CmdPlaySFX:                             ; DATA XREF: ROM:8391↑t
                LDA     ($FC),Y
                INY
                CPX     #1
                BEQ     loc_83E3
                STA     sfxNew

loc_83E3:                               ; CODE XREF: CmdPlaySFX+5↑j
                JMP     fetchChan
; End of function CmdPlaySFX


; =============== S U B R O U T I N E =======================================


CmdSetChanPtr:                          ; DATA XREF: ROM:8383↑t
                LDA     ($FC),Y
                INY
                PHA
                LDA     ($FC),Y
                INY
                STA     chanPtrHi,X
                PLA
                STA     chanPtrLo,X
                JMP     ChanDoNext
; End of function CmdSetChanPtr


; =============== S U B R O U T I N E =======================================


CmdSub:                                 ; DATA XREF: ROM:838B↑t
                LDA     ($FC),Y
                INY
                PHA
                LDA     ($FC),Y
                INY
                PHA
                JSR     AddChanPtr
                LDA     chanPtrHi,X
                STA     chanParentPtrHi,X
                LDA     chanPtrLo,X
                STA     chanParentPtrLo,X
                PLA
                STA     chanPtrHi,X
                PLA
                STA     chanPtrLo,X
                JMP     ChanDoNext
; End of function CmdSub


; =============== S U B R O U T I N E =======================================


CmdRet:                                 ; DATA XREF: ROM:838D↑t
                LDA     chanParentPtrHi,X
                STA     chanPtrHi,X
                LDA     chanParentPtrLo,X
                STA     chanPtrLo,X
                JMP     ChanDoNext
; End of function CmdRet


; =============== S U B R O U T I N E =======================================


CmdMuteChan:                            ; DATA XREF: ROM:8385↑t
                LDA     #0
                STA     chanPtrHi,X
                STA     chanNote,X
                TYA
                PHA
                LDY     channel
                LDA     chanMuted,Y
                BNE     loc_8442
                LDA     unk_8468,Y
                AND     $4015
                STA     $4015

loc_8442:                               ; CODE XREF: CmdMuteChan+F↑j
                PLA
                TAY
                RTS
; End of function CmdMuteChan


; =============== S U B R O U T I N E =======================================


CmdRest:                             ; DATA XREF: ROM:8387↑t
                TYA
                PHA
                LDY     channel
                LDA     chanMuted,Y
                BNE     loc_8457
                LDA     unk_8468,Y
                AND     $4015
                STA     $4015

loc_8457:                               ; CODE XREF: CmdKeyOff?+7↑j
                PLA
                TAY
                LDA     ($FC),Y
                INY
                STA     chanNoteDur,X
                LDA     #0
                STA     chanNote,X
                JSR     AddChanPtr
                RTS
; End of function CmdKeyOff?

; ---------------------------------------------------------------------------
unk_8468:       .byte  $E
                .byte  $D
                .byte  $B
                .byte   7

; =============== S U B R O U T I N E =======================================


CmdSetTranspose:                        ; DATA XREF: ROM:8389↑t
                LDA     ($FC),Y
                INY
                STA     chanTranspose,X
                JMP     fetchChan
; End of function CmdSetTranspose


; =============== S U B R O U T I N E =======================================


AddChanPtr:                             ; CODE XREF: ChanDoNext+1F↑p
                                        ; ChanDoNext+2B↑p ...
                TYA
                CLC
                ADC     $FC
                STA     chanPtrLo,X
                LDA     $FD
                ADC     #0
                STA     chanPtrHi,X
                RTS
; End of function AddChanPtr


; =============== S U B R O U T I N E =======================================


UpdateChanVolume:                       ; CODE XREF: sub_828A:loc_8330↑p
                PHA
                LDY     channel
                LDA     chanMuted,Y
                BEQ     loc_848E
                PLA
                RTS
; ---------------------------------------------------------------------------

loc_848E:                               ; CODE XREF: UpdateChanVolume+6↑j
                LDA     chanMuted,Y
                CLC
                ADC     #1
                STA     chanMuted,Y
                TYA
                ASL     A
                TAY
                LDA     off_84A8,Y
                STA     $FE
                LDA     off_84A8+1,Y
                STA     $FF
                PLA
                JMP     ($FE)
; End of function UpdateChanVolume

; ---------------------------------------------------------------------------
off_84A8:       .word Pulse1Volume
                .word Pulse2Volume
                .word TriangleVolume
                .word NoiseVolume

; =============== S U B R O U T I N E =======================================


Pulse1Volume:                           ; DATA XREF: ROM:off_84A8↑o
                ORA     chanPulseSetupVal,X
                STA     $4000
                RTS
; End of function Pulse1Volume


; =============== S U B R O U T I N E =======================================


Pulse2Volume:                           ; DATA XREF: ROM:84AA↑o
                ORA     chanPulseSetupVal,X
                STA     $4004
                RTS
; End of function Pulse2Volume


; =============== S U B R O U T I N E =======================================


TriangleVolume:                         ; DATA XREF: ROM:84AC↑o
                ORA     #$80            ; length counter halt
                STA     $4008
                RTS
; End of function TriangleVolume


; =============== S U B R O U T I N E =======================================


NoiseVolume:                            ; DATA XREF: ROM:84AE↑o
                ORA     #$30 ; '0'      ; length counter halt, constant volume
                STA     $400C
                RTS
; End of function NoiseVolume


; =============== S U B R O U T I N E =======================================


PlayChanNote:                           ; CODE XREF: ChanDoNext+1C↑p
                TXA
                PHA
                TYA
                PHA
                LDY     channel
                LDA     chanMuted,Y
                BEQ     loc_84DA
                PLA
                TAY
                PLA
                TAX
                RTS
; ---------------------------------------------------------------------------

loc_84DA:                               ; CODE XREF: PlayChanNote+9↑j
                TYA
                ASL     A
                TAY
                LDA     word_84E6+1,Y
                PHA
                LDA     word_84E6,Y
                PHA
                RTS
; End of function PlayChanNote

; ---------------------------------------------------------------------------
word_84E6:      .word Pulse1PlayNote-1
                .word Pulse2PlayNote-1
                .word TrianglePlayNote-1
                .word NoisePlayNote-1

; =============== S U B R O U T I N E =======================================


Pulse1PlayNote:                         ; DATA XREF: ROM:word_84E6↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                STA     $FF
                BPL     loc_84FB
                DEC     $FE

loc_84FB:                               ; CODE XREF: Pulse1PlayNote+9↑j
                LDA     $4015           ; enable pulse 1
                ORA     #1
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $4002
                LDA     NoteTbl+1,X
                ADC     $FE
                STA     $4003
                PLA
                TAY
                PLA
                TAX

locret_8521:
                RTS
; End of function Pulse1PlayNote


; =============== S U B R O U T I N E =======================================


Pulse2PlayNote:                         ; DATA XREF: ROM:84E8↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                STA     $FF
                BPL     loc_852F
                DEC     $FE

loc_852F:                               ; CODE XREF: Pulse2PlayNote+9↑j
                LDA     $4015
                ORA     #2
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $4006
                LDA     NoteTbl+1,X
                ADC     $FE
                STA     $4007
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function Pulse2PlayNote


; =============== S U B R O U T I N E =======================================


TrianglePlayNote:                       ; DATA XREF: ROM:84EA↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                STA     $FF
                BPL     loc_8563
                DEC     $FE

loc_8563:                               ; CODE XREF: TrianglePlayNote+9↑j
                LDA     $4015
                ORA     #4
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $400A
                LDA     NoteTbl+1,X
                ADC     $FE
                STA     $400B
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function TrianglePlayNote


; =============== S U B R O U T I N E =======================================


NoisePlayNote:                          ; DATA XREF: ROM:84EC↑t
                LDA     $4015           ; enable noise channel
                ORA     #8
                STA     $4015
                LDA     chanNote,X
                AND     #$F
                STA     $400E           ; set noise period
                STA     $400F           ; key on
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function NoisePlayNote

; ---------------------------------------------------------------------------
NoteTbl:        .byte $F2               ; DATA XREF: Pulse1PlayNote+27↑t
                                        ; Pulse2PlayNote+27↑t ...
unk_85A3:       .byte   7
                .byte $80
                .byte   7
                .byte $14
                .byte   7
                .byte $AE
                .byte   6
                .byte $43 ; C
                .byte   6
                .byte $F4
                .byte   5
                .byte $9E
                .byte   5
                .byte $4E ; N
                .byte   5
                .byte   3
                .byte   5
                .byte $BA
                .byte   4
                .byte $76 ; v
                .byte   4
                .byte $36 ; 6
                .byte   4
                .byte $F9
                .byte   3
                .byte $C0
                .byte   3
                .byte $8A
                .byte   3
                .byte $57 ; W
                .byte   3
                .byte $21 ; !
                .byte   3
                .byte $FA
                .byte   2
                .byte $CF
                .byte   2
                .byte $A7
                .byte   2
                .byte $81
                .byte   2
                .byte $5D ; ]
                .byte   2
                .byte $3B ; ;
                .byte   2
                .byte $1B
                .byte   2
                .byte $FC
                .byte   1
                .byte $E0
                .byte   1
                .byte $C5
                .byte   1
                .byte $AB
                .byte   1
                .byte $90
                .byte   1
                .byte $7D ; }
                .byte   1
                .byte $67 ; g
                .byte   1
                .byte $53 ; S
                .byte   1
                .byte $40 ; @
                .byte   1
                .byte $2E ; .
                .byte   1
                .byte $1D
                .byte   1
                .byte  $D
                .byte   1
                .byte $FD
                .byte   0
                .byte $F0
                .byte   0
                .byte $E2
                .byte   0
                .byte $D5
                .byte   0
                .byte $C8
                .byte   0
                .byte $BE
                .byte   0
                .byte $B3
                .byte   0
                .byte $A9
                .byte   0
                .byte $A0
                .byte   0
                .byte $97
                .byte   0
                .byte $8E
                .byte   0
                .byte $86
                .byte   0
                .byte $7F ; 
                .byte   0
                .byte $78 ; x
                .byte   0
                .byte $71 ; q
                .byte   0
                .byte $6A ; j
                .byte   0
                .byte $64 ; d
                .byte   0
                .byte $5F ; _
                .byte   0
                .byte $59 ; Y
                .byte   0
                .byte $54 ; T
                .byte   0
                .byte $50 ; P
                .byte   0
                .byte $4B ; K
                .byte   0
                .byte $47 ; G
                .byte   0
                .byte $43 ; C
                .byte   0
                .byte $3F ; ?
                .byte   0
                .byte $3C ; <
                .byte   0
                .byte $38 ; 8
                .byte   0
                .byte $35 ; 5
                .byte   0
                .byte $32 ; 2
                .byte   0
                .byte $2F ; /
                .byte   0
                .byte $2C ; ,
                .byte   0
                .byte $2A ; *
                .byte   0
                .byte $28 ; (
                .byte   0
                .byte $25 ; %
                .byte   0
                .byte $23 ; #
                .byte   0
                .byte $21 ; !
                .byte   0
                .byte $1F
                .byte   0
                .byte $1E
                .byte   0
                .byte $1C
                .byte   0
                .byte $1A
                .byte   0
                .byte $19
                .byte   0
                .byte $17
                .byte   0
                .byte $16
                .byte   0
                .byte $15
                .byte   0
                .byte $14
                .byte   0
                .byte $12
                .byte   0
                .byte $11
                .byte   0
                .byte $10
                .byte   0
                .byte  $F
                .byte   0
                .byte  $F
                .byte   0
                .byte  $E
                .byte   0
                .byte  $D
                .byte   0
                .byte  $C
                .byte   0
                .byte  $B
                .byte   0
                .byte  $B
                .byte   0
                .byte  $A
                .byte   0
                .byte  $A
                .byte   0
                .byte   9
                .byte   0
                .byte   8
                .byte   0
                .byte   8
                .byte   0

; =============== S U B R O U T I N E =======================================


UpdateChanPitch:                        ; CODE XREF: sub_828A+5E↑p
                TXA
                PHA
                TYA
                PHA
                LDY     channel
                LDA     chanMuted,Y
                BEQ     loc_8672
                PLA
                TAY
                PLA
                TAX
                RTS
; ---------------------------------------------------------------------------

loc_8672:                               ; CODE XREF: UpdateChanPitch+9↑j
                TYA
                ASL     A
                TAY
                LDA     word_867E+1,Y
                PHA
                LDA     word_867E,Y
                PHA
                RTS
; End of function UpdateChanPitch

; ---------------------------------------------------------------------------
word_867E:      .word Pulse1Pitch-1
                .word Pulse2Pitch-1
                .word TrianglePitch-1
                .word NoisePitch-1

; =============== S U B R O U T I N E =======================================


Pulse1Pitch:                            ; DATA XREF: ROM:word_867E↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                CLC
                ADC     chanSweep,X
                STA     $FF
                LDA     $4015
                ORA     #1
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $4002
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function Pulse1Pitch


; =============== S U B R O U T I N E =======================================


Pulse2Pitch:                            ; DATA XREF: ROM:8680↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                CLC
                ADC     chanSweep,X
                STA     $FF
                LDA     $4015
                ORA     #2
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $4006
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function Pulse2Pitch


; =============== S U B R O U T I N E =======================================


TrianglePitch:                          ; DATA XREF: ROM:8680↑t
                                        ; ROM:8682↑t
                LDA     #0
                STA     $FE
                LDA     chanAPUTimerOffset,X
                CLC
                ADC     chanSweep,X
                STA     $FF
                LDA     $4015
                ORA     #4
                STA     $4015
                LDA     chanNote,X
                CLC
                ADC     chanTranspose,X
                ASL     A
                TAX
                LDA     NoteTbl,X
                CLC
                ADC     $FF
                STA     $400A

NoisePitch:
                PLA
                TAY
                PLA
                TAX
                RTS
; End of function TrianglePitch

; ---------------------------------------------------------------------------
envDataTbl:     .word unk_875C
                .word unk_875D
                .word unk_876E
                .word unk_8780
                .word unk_8782
                .word unk_8784
                .word unk_8797
                .word unk_879E
                .word unk_879F
                .word unk_87A0
                .word unk_87A1
                .word unk_87A6
                .word unk_87B1
                .word unk_87B8
                .word unk_87C7
                .word unk_87E3
                .word unk_87FB
                .word unk_880D
                .word unk_881D
                .word unk_8828
                .word unk_883D
                .word unk_8854
                .word unk_8866
                .word unk_886C
                .word unk_8872
                .word unk_8895
                .word unk_88A4
                .word unk_88BA
                .word unk_88C7
                .word unk_88D4
                .word unk_88E6
                .word unk_88EA
                .word unk_88F5
                .word unk_8903
                .word unk_890B
                .word unk_8916
                .word unk_8938
                .word unk_8950
                .word unk_8954
                .word unk_8964
                .word unk_8974
unk_875C:       .byte  $F               ; DATA XREF: ROM:envDataTbl↑o
unk_875D:       .byte  $F               ; DATA XREF: ROM:870C↑o
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   3
                .byte   0
unk_876E:       .byte  $F               ; DATA XREF: ROM:870E↑o
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   9
                .byte  $A
                .byte  $B
                .byte  $C
                .byte  $D
unk_8780:       .byte  $F               ; DATA XREF: ROM:8710↑o
                .byte   9
unk_8782:       .byte   9               ; DATA XREF: ROM:8712↑o
                .byte  $F
unk_8784:       .byte   4               ; DATA XREF: ROM:8714↑o
                .byte   9
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
                .byte   0
unk_8797:       .byte  $F               ; DATA XREF: ROM:8716↑o
                .byte  $D
                .byte  $B
                .byte   9
                .byte   6
                .byte   3
                .byte   0
unk_879E:       .byte  $C               ; DATA XREF: ROM:8718↑o
unk_879F:       .byte   9               ; DATA XREF: ROM:871A↑o
unk_87A0:       .byte   6               ; DATA XREF: ROM:871C↑o
unk_87A1:       .byte  $D               ; DATA XREF: ROM:871E↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $D
unk_87A6:       .byte  $C               ; DATA XREF: ROM:8720↑o
                .byte  $E
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
unk_87B1:       .byte  $F               ; DATA XREF: ROM:8722↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $C
unk_87B8:       .byte  $F               ; DATA XREF: ROM:8724↑o
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
unk_87C7:       .byte  $F               ; DATA XREF: ROM:8726↑o
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   8
                .byte   8
                .byte   7
                .byte   7
                .byte   6
                .byte   6
                .byte   4
                .byte   4
                .byte   3
                .byte   3
                .byte   2
                .byte   2
                .byte   1
                .byte   1
unk_87E3:       .byte  $C               ; DATA XREF: ROM:8728↑o
                .byte  $C
                .byte  $B
                .byte  $B
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   8
                .byte   8
                .byte   7
                .byte   7
                .byte   6
                .byte   6
                .byte   5
                .byte   5
                .byte   4
                .byte   4
                .byte   3
                .byte   3
                .byte   2
                .byte   2
                .byte   1
                .byte   1
unk_87FB:       .byte  $F               ; DATA XREF: ROM:872A↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte   9
                .byte   9
                .byte   7
                .byte   6
unk_880D:       .byte  $F               ; DATA XREF: ROM:872C↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
unk_881D:       .byte  $F               ; DATA XREF: ROM:872E↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
unk_8828:       .byte  $F               ; DATA XREF: ROM:8730↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
                .byte   0
unk_883D:       .byte  $F               ; DATA XREF: ROM:8732↑o
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   8
                .byte   8
                .byte   8
                .byte   8
                .byte   8
                .byte   9
                .byte  $A
                .byte  $B
                .byte  $C
                .byte  $D
                .byte  $E
                .byte  $F
unk_8854:       .byte   5               ; DATA XREF: ROM:8734↑o
                .byte  $A
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte   9
                .byte   9
                .byte   7
                .byte   6
unk_8866:       .byte  $F               ; DATA XREF: ROM:8736↑o
                .byte  $C
                .byte   9
                .byte   6
                .byte   3
                .byte   0
unk_886C:       .byte  $F               ; DATA XREF: ROM:8738↑o
                .byte  $D
                .byte   9
                .byte   6
                .byte   3
                .byte   9
unk_8872:       .byte   5               ; DATA XREF: ROM:873A↑o
                .byte  $A
                .byte  $E
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte  $B
                .byte  $A
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   8
                .byte   8
                .byte   7
                .byte   7
                .byte   7
                .byte   7
                .byte   7
                .byte   6
                .byte   6
                .byte   6
                .byte   6
unk_8895:       .byte  $F               ; DATA XREF: ROM:873C↑o
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
unk_88A4:       .byte   4               ; DATA XREF: ROM:873E↑o
                .byte   8
                .byte   8
                .byte  $C
                .byte  $C
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $E
unk_88BA:       .byte   8               ; DATA XREF: ROM:8740↑o
                .byte  $C
                .byte  $E
                .byte  $F
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   9
unk_88C7:       .byte   7               ; DATA XREF: ROM:8742↑o
                .byte   9
                .byte  $B
                .byte  $D
                .byte  $E
                .byte  $F
                .byte  $F
                .byte  $D
                .byte  $C
                .byte  $A
                .byte   9
                .byte   8
                .byte   8
unk_88D4:       .byte   5               ; DATA XREF: ROM:8744↑o
                .byte   7
                .byte   9
                .byte  $B
                .byte  $D
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte   9
                .byte   7
                .byte   6
unk_88E6:       .byte  $F               ; DATA XREF: ROM:8746↑o
                .byte  $C
                .byte   9
                .byte   6
unk_88EA:       .byte  $F               ; DATA XREF: ROM:8748↑o
                .byte  $D
                .byte  $C
                .byte  $A
                .byte   8
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
unk_88F5:       .byte  $F               ; DATA XREF: ROM:874A↑o
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
unk_8903:       .byte   7               ; DATA XREF: ROM:874C↑o
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
                .byte   0
unk_890B:       .byte   5               ; DATA XREF: ROM:874E↑o
                .byte   9
                .byte  $B
                .byte  $D
                .byte  $E
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $C
unk_8916:       .byte  $F               ; DATA XREF: ROM:8750↑o
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $C
                .byte  $C
                .byte  $B
                .byte  $B
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
                .byte   0
unk_8938:       .byte  $F               ; DATA XREF: ROM:8752↑o
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   8
                .byte   8
                .byte   8
                .byte   7
                .byte   7
                .byte   7
                .byte   6
                .byte   6
                .byte   6
                .byte   6
                .byte   5
                .byte   5
                .byte   5
                .byte   5
                .byte   4
unk_8950:       .byte  $F               ; DATA XREF: ROM:8754↑o
                .byte  $A
                .byte   5
                .byte   0
unk_8954:       .byte  $F               ; DATA XREF: ROM:8756↑o
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte   9
                .byte   8
                .byte   7
                .byte   6
                .byte   5
                .byte   4
                .byte   3
                .byte   2
                .byte   1
                .byte   0
unk_8964:       .byte  $B               ; DATA XREF: ROM:8758↑o
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $F
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $E
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $D
                .byte  $C
unk_8974:       .byte  $F               ; DATA XREF: ROM:875A↑o
                .byte  $E
                .byte  $D
                .byte  $C
                .byte  $B
                .byte  $A
                .byte  $A
                .byte  $A
                .byte   9
                .byte   9
                .byte   9
                .byte   8
                .byte   8
                .byte   8
                .byte   7
envEndPointTbl: .byte   1
                .byte $11
                .byte $12
                .byte   2
                .byte   2
                .byte $13
                .byte   7
                .byte   1
                .byte   1
                .byte   1
                .byte   5
                .byte  $B
                .byte   7
                .byte  $F
                .byte $1C
                .byte $18
                .byte $12
                .byte $10
                .byte  $B
                .byte $15
                .byte $17
                .byte $12
                .byte   6
                .byte   6
                .byte $23 ; #
                .byte  $F
                .byte $16
                .byte  $D
                .byte  $D
                .byte $12
                .byte   5
                .byte  $A
                .byte  $D
                .byte   7
                .byte  $A
                .byte $21 ; !
                .byte $17
                .byte   4
                .byte $10
                .byte $10
                .byte  $E
envLoopPointTbl:.byte   0
                .byte $10
                .byte $10
                .byte   0
                .byte   0
                .byte $12
                .byte   6
                .byte   0
                .byte   0
                .byte   0
                .byte   4
                .byte  $A
                .byte   0
                .byte   0
                .byte $1B
                .byte $17
                .byte $11
                .byte  $F
                .byte  $A
                .byte $14
                .byte $16
                .byte $11
                .byte   5
                .byte   4
                .byte $22 ; "
                .byte  $E
                .byte $15
                .byte  $C
                .byte  $C
                .byte $11
                .byte   4
                .byte   9
                .byte  $C
                .byte   6
                .byte   9
                .byte $20
                .byte $16
                .byte   3
                .byte  $F
                .byte  $F
                .byte  $D
sweepDataTbl:   .word unk_8A03
                .word unk_8A04
                .word unk_8A20
                .word unk_8A28
                .word unk_8A38
                .word unk_8A3A
                .word unk_8A3C
                .word unk_8A44
                .word unk_8A4C
                .word unk_8A54
                .word unk_8A56
                .word unk_8A6C
                .word unk_8A76
                .word unk_8A80
                .word unk_8A8A
                .word unk_8A8C
                .word unk_8AAB
                .word unk_8ACA
                .word unk_8ACB
                .word unk_8ACC
                .word unk_8ACD
                .word unk_8ACE
                .word unk_8ACF
unk_8A03:       .byte   0               ; DATA XREF: ROM:sweepDataTbl↑o
unk_8A04:       .byte   0               ; DATA XREF: ROM:89D7↑o
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte $FF
                .byte $FF
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   2
                .byte   2
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte $FF
                .byte $FF
                .byte $FE
                .byte $FE
                .byte $FF
                .byte $FF
unk_8A20:       .byte   0               ; DATA XREF: ROM:89D9↑o
                .byte   1
                .byte   2
                .byte   1
                .byte   0
                .byte $FF
                .byte $FE
                .byte $FF
unk_8A28:       .byte   0               ; DATA XREF: ROM:89DB↑o
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte $FF
                .byte $FF
                .byte $FF
                .byte $FF
unk_8A38:       .byte   1               ; DATA XREF: ROM:89DD↑o
                .byte $FF
unk_8A3A:       .byte   0               ; DATA XREF: ROM:89DF↑o
                .byte $FF
unk_8A3C:       .byte   0               ; DATA XREF: ROM:89E1↑o
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte $FF
                .byte   0
                .byte   0
unk_8A44:       .byte   0               ; DATA XREF: ROM:89E3↑o
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
unk_8A4C:       .byte   1               ; DATA XREF: ROM:89E5↑o
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
unk_8A54:       .byte $FF               ; DATA XREF: ROM:89E7↑o
                .byte   1
unk_8A56:       .byte   0               ; DATA XREF: ROM:89E9↑o
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   1
unk_8A6C:       .byte   0               ; DATA XREF: ROM:89EB↑o
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
unk_8A76:       .byte   1               ; DATA XREF: ROM:89ED↑o
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
unk_8A80:       .byte $FD               ; DATA XREF: ROM:89EF↑o
                .byte $FE
                .byte $FF
                .byte   1
                .byte   2
                .byte   3
                .byte   2
                .byte   1
                .byte $FF
                .byte $FE
unk_8A8A:       .byte $FD               ; DATA XREF: ROM:89F1↑o
                .byte   3
unk_8A8C:       .byte   0               ; DATA XREF: ROM:89F3↑o
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   1
unk_8AAB:       .byte   0               ; DATA XREF: ROM:89F5↑o
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   1
                .byte   1
                .byte   1
                .byte   1
                .byte   0
                .byte   0
                .byte   0
                .byte   0
                .byte   0
unk_8ACA:       .byte   1               ; DATA XREF: ROM:89F7↑o
unk_8ACB:       .byte   2               ; DATA XREF: ROM:89F9↑o
unk_8ACC:       .byte   3               ; DATA XREF: ROM:89FB↑o
unk_8ACD:       .byte $FF               ; DATA XREF: ROM:89FD↑o
unk_8ACE:       .byte $FE               ; DATA XREF: ROM:89FF↑o
unk_8ACF:       .byte $FD               ; DATA XREF: ROM:8A01↑o
sweepEndPointTbl:.byte 1
                .byte 28
                .byte 8
                .byte 16
                .byte 2
                .byte 2
                .byte 8
                .byte 8
                .byte 8
                .byte 2
                .byte 22
                .byte 10
                .byte 10
                .byte 10
                .byte 2
                .byte 30
                .byte 30
                .byte 1
                .byte 1
                .byte 1
                .byte 1
                .byte 1
                .byte 1
sweepLoopPointTbl:.byte 0
                .byte 12
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 11
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 21
                .byte 21
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 0
                .byte 51
		
		
bankTbl:        .byte 0	; 0
                .byte 0	; 1
                .byte 0	; 2
                .byte 0	; 3
                .byte 0	; 4
                .byte 0	; 5
                .byte 0	; 6
                .byte 0	; 7
                .byte 0	; 8
                .byte 0	; 9
                .byte 0	; 10
                .byte 0	; 11
                .byte 0	; 12
                .byte 0	; 13
                .byte 0	; 14
                .byte 0	; 15
                .byte 0	; 16
                .byte 0	; 17
                .byte 0	; 18
                .byte 0	; 19
                .byte 0	; 20
                .byte 0	; 21
                .byte 0	; 22
                .byte 0	; 23
                .byte 0	; 24
                .byte 0	; 25
                .byte 0	; 26
                .byte 0	; 27
                .byte 0	; 28
                .byte 0	; 29
                .byte 0	; 30
                .byte 0	; 31
                .byte 0	; 32
                .byte 2	; 33
                .byte 2	; 34
                .byte 0	; 35
                .byte 0	; 36
                .byte 0	; 37
                .byte 0	; 38
                .byte 0	; 39
                .byte 2	; 40
                .byte 3	; 41
                .byte 3	; 42
                .byte 3	; 43
                .byte 3	; 44
                .byte 3	; 45
                .byte 3	; 46
                .byte 3	; 47
                .byte 3	; 48
                .byte 0	; 49
                .byte 0	; 50
                .byte 3	; 51
                .byte 2	; 52
                .byte 2	; 53
                .byte 1	; 54
                .byte 1	; 55
                .byte 1	; 56
                .byte 0	; 57
                .byte 0	; 58
                .byte 0	; 59
SoundDataTbl:   
		.word 0		; 0
                .word 0
                .word 0
                .word 0
		
		.import tengenLogoCh0, tengenLogoCh1
                .word tengenLogoCh0	; 1
                .word tengenLogoCh1
                .word 0
                .word 0

		.import noiseTest
                .word 0		; 2
                .word 0
                .word 0
                .word noiseTest

                .word 0		; 3
                .word 0
                .word 0
                .word 0

                .word 0		; 4
                .word 0
                .word 0
                .word 0

                .word 0		; 5
                .word 0
                .word 0
                .word 0

                .word 0		; 6
                .word 0
                .word 0
                .word 0

                .word 0		; 7
                .word 0
                .word 0
                .word 0

                .word 0		; 8
                .word 0
                .word 0
                .word 0

                .word 0		; 9
                .word 0
                .word 0
                .word 0

		.import levelCh0, levelCh1, levelCh2
                .word levelCh0		; 10
                .word levelCh1
                .word levelCh2
                .word 0

		.import gameOverCh0, gameOverCh1, gameOverCh2
                .word gameOverCh0		; 11
                .word gameOverCh1
                .word gameOverCh2
                .word 0

		.import badClearCh0, badClearCh1, badClearCh2
                .word badClearCh0		; 12
                .word badClearCh1
                .word badClearCh2
                .word 0

                .word 0		; 13
                .word 0
                .word 0
                .word 0

                .word 0		; 14
                .word 0
                .word 0
                .word 0
		
		.import blockBreakCh1, blockBreakCh3
                .word 0		; 15
                .word blockBreakCh1
                .word 0
                .word blockBreakCh3
		
		.import punchNothingCh3
                .word 0		; 16
                .word 0		; there's supposed to be a sound here but it's not in game gear
                .word 0
                .word punchNothingCh3

		.import headButtCh1, headButtCh3
                .word 0		; 17
                .word headButtCh1
                .word 0
                .word headButtCh3

                .word 0		; 18
                .word 0
                .word 0
                .word 0

		.import punchBlockCh1, punchBlockCh3
                .word 0		; 19
                .word punchBlockCh1
                .word 0
                .word punchBlockCh3

                .word 0		; 20
                .word 0
                .word 0
                .word 0

                .word 0		; 21
                .word 0
                .word 0
                .word 0

		.import menuCh0, menuCh1, menuCh2
                .word menuCh0	; 22
                .word menuCh1
                .word menuCh2
                .word 0

                .word 0		; 23
                .word 0
                .word 0
                .word 0

		.import editorMusicCh0, editorMusicCh1, editorMusicCh2
                .word editorMusicCh0		; 24
                .word editorMusicCh1
                .word editorMusicCh2
                .word 0

		.import deathCh0, deathCh1
                .word deathCh0		; 25
                .word deathCh1
                .word 0
                .word 0

                .word 0		; 26
                .word 0
                .word 0
                .word 0

                .word 0		; 27
                .word 0
                .word 0
                .word 0

                .word 0		; 28
                .word 0
                .word 0
                .word 0

                .word 0		; 29
                .word 0
                .word 0
                .word 0

                .word 0		; 30
                .word 0
                .word 0
                .word 0

                .word 0		; 31
                .word 0
                .word 0
                .word 0

		.import pauseCh0, pauseCh1, pauseCh23
                .word pauseCh0		; 32
                .word pauseCh1
                .word pauseCh23
                .word pauseCh23

		.import attractCh0, attractCh1, attractCh2
                .word attractCh0	; 33
                .word attractCh1
                .word attractCh2
                .word 0

		.import titleCh0, titleCh1, titleCh2
                .word titleCh0	; 34
                .word titleCh1
                .word titleCh2
                .word 0

                .word 0		; 35
                .word 0
                .word 0
                .word 0

		.import goodClearCh0, goodClearCh1, goodClearCh2
                .word goodClearCh0		; 36
                .word goodClearCh1
                .word goodClearCh2
                .word 0

		.import roundsUnlockedCh0, roundsUnlockedCh1, roundsUnlockedCh2
                .word roundsUnlockedCh0		; 37
                .word roundsUnlockedCh1
                .word roundsUnlockedCh2
                .word 0

                .word 0		; 38
                .word 0
                .word 0
                .word 0

                .word 0		; 39
                .word 0
                .word 0
                .word 0

                .word 0		; 40
                .word 0
                .word 0
                .word 0

                .word 0		; 41
                .word 0
                .word 0
                .word 0

                .word 0		; 42
                .word 0
                .word 0
                .word 0

                .word 0		; 43
                .word 0
                .word 0
                .word 0

                .word 0		; 44
                .word 0
                .word 0
                .word 0

                .word 0		; 45
                .word 0
                .word 0
                .word 0

                .word 0		; 46
                .word 0
                .word 0
                .word 0

                .word 0		; 47
                .word 0
                .word 0
                .word 0

                .word 0		; 48
                .word 0
                .word 0
                .word 0

                .word 0		; 49
                .word 0
                .word 0
                .word 0

                .word 0		; 50
                .word 0
                .word 0
                .word 0

                .word 0		; 51
                .word 0
                .word 0
                .word 0

                .word 0		; 52
                .word 0
                .word 0
                .word 0

                .word 0		; 53
                .word 0
                .word 0
                .word 0

                .word 0		; 54
                .word 0
                .word 0
                .word 0

                .word 0		; 55
                .word 0
                .word 0
                .word 0

                .word 0		; 56
                .word 0
                .word 0
                .word 0

CodeEnd:

.if CodeEnd - CodeStart > $be9
.error "code too big to fit in rom!"
.endif
