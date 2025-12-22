; NES Popils sound engine disassembly
; This file is meant to be viewed with tabs set to 8 spaces

		channel			equ	$F9
		soundMode		equ	$FA	; 0 = music, 1 = sfx

		sndNew			equ	$600
		musNew			equ	$600
		sfxNew			equ	$601
		sndVolume		equ	$602
		sndPlaying		equ	$604
		sndChanMask		equ	$606
		musChanMask		equ	$606
		sfxChanMask		equ	$607
		sndBank			equ	$608	; 2 bytes
		chanPtrHi		equ	$60A	; 8 bytes
		chanPtrLo		equ	$612	; 8 bytes
		chanPulseSetupVal	equ	$61A	; 8 bytes
		chanEnvType		equ	$622	; 8 bytes
		chanEnvOffset		equ	$62A	; 8 bytes
		chanAPUTimerOffset	equ	$632	; 8 bytes
		chanSweepType		equ	$63A	; 8 bytes
		chanNote		equ	$642	; 8 bytes
		chanTimer		equ	$64A	; 8 bytes
		chanEnvCursor		equ	$652	; 8 bytes
		chanSweepCursor		equ	$65A	; 8 bytes
		chanNoteDur		equ	$662	; 8 bytes
		chanMuted		equ	$66A	; 4 bytes
		sndTempo		equ	$66E	; 2 bytes
		chanTranspose		equ	$670	; 8 bytes
		chanParentPtrHi		equ	$678	; 8 bytes
		chanParentPtrLo		equ	$680	; 8 bytes
		chanSweep		equ	$688	; 8 bytes

		org	$811A

; =============== S U B R O U T I N E =======================================


InitSound:                              ; CODE XREF: RunSoundEngine+42↓p
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
chanBits:       db   1
                db   2
                db   4
                db   8

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
cmdTbl:         dw CmdSetNoteDur-1
                dw CmdSetEnvOffset-1
                dw CmdSetEnvType-1
                dw CmdSetPulseSetupVal-1
                dw CmdSetTempo-1
                dw CmdSetTimerOffset-1
                dw CmdSetChanPtr-1
                dw CmdMuteChan-1
                dw CmdRest-1
                dw CmdSetTranspose-1
                dw CmdSub-1
                dw CmdRet-1
                dw CmdSetSweepType-1
                dw CmdPlaySFX-1

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
unk_8468:       db  $E
                db  $D
                db  $B
                db   7

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
off_84A8:       dw Pulse1Volume
                dw Pulse2Volume
                dw TriangleVolume
                dw NoiseVolume

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
word_84E6:      dw Pulse1PlayNote-1
                dw Pulse2PlayNote-1
                dw TrianglePlayNote-1
                dw NoisePlayNote-1

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
NoteTbl:        db $F2               ; DATA XREF: Pulse1PlayNote+27↑t
                                        ; Pulse2PlayNote+27↑t ...
unk_85A3:       db   7
                db $80
                db   7
                db $14
                db   7
                db $AE
                db   6
                db $43 ; C
                db   6
                db $F4
                db   5
                db $9E
                db   5
                db $4E ; N
                db   5
                db   3
                db   5
                db $BA
                db   4
                db $76 ; v
                db   4
                db $36 ; 6
                db   4
                db $F9
                db   3
                db $C0
                db   3
                db $8A
                db   3
                db $57 ; W
                db   3
                db $21 ; !
                db   3
                db $FA
                db   2
                db $CF
                db   2
                db $A7
                db   2
                db $81
                db   2
                db $5D ; ]
                db   2
                db $3B ; ;
                db   2
                db $1B
                db   2
                db $FC
                db   1
                db $E0
                db   1
                db $C5
                db   1
                db $AB
                db   1
                db $90
                db   1
                db $7D ; }
                db   1
                db $67 ; g
                db   1
                db $53 ; S
                db   1
                db $40 ; @
                db   1
                db $2E ; .
                db   1
                db $1D
                db   1
                db  $D
                db   1
                db $FD
                db   0
                db $F0
                db   0
                db $E2
                db   0
                db $D5
                db   0
                db $C8
                db   0
                db $BE
                db   0
                db $B3
                db   0
                db $A9
                db   0
                db $A0
                db   0
                db $97
                db   0
                db $8E
                db   0
                db $86
                db   0
                db $7F ; 
                db   0
                db $78 ; x
                db   0
                db $71 ; q
                db   0
                db $6A ; j
                db   0
                db $64 ; d
                db   0
                db $5F ; _
                db   0
                db $59 ; Y
                db   0
                db $54 ; T
                db   0
                db $50 ; P
                db   0
                db $4B ; K
                db   0
                db $47 ; G
                db   0
                db $43 ; C
                db   0
                db $3F ; ?
                db   0
                db $3C ; <
                db   0
                db $38 ; 8
                db   0
                db $35 ; 5
                db   0
                db $32 ; 2
                db   0
                db $2F ; /
                db   0
                db $2C ; ,
                db   0
                db $2A ; *
                db   0
                db $28 ; (
                db   0
                db $25 ; %
                db   0
                db $23 ; #
                db   0
                db $21 ; !
                db   0
                db $1F
                db   0
                db $1E
                db   0
                db $1C
                db   0
                db $1A
                db   0
                db $19
                db   0
                db $17
                db   0
                db $16
                db   0
                db $15
                db   0
                db $14
                db   0
                db $12
                db   0
                db $11
                db   0
                db $10
                db   0
                db  $F
                db   0
                db  $F
                db   0
                db  $E
                db   0
                db  $D
                db   0
                db  $C
                db   0
                db  $B
                db   0
                db  $B
                db   0
                db  $A
                db   0
                db  $A
                db   0
                db   9
                db   0
                db   8
                db   0
                db   8
                db   0

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
word_867E:      dw Pulse1Pitch-1
                dw Pulse2Pitch-1
                dw TrianglePitch-1
                dw NoisePitch-1

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
envDataTbl:     dw unk_875C
                dw unk_875D
                dw unk_876E
                dw unk_8780
                dw unk_8782
                dw unk_8784
                dw unk_8797
                dw unk_879E
                dw unk_879F
                dw unk_87A0
                dw unk_87A1
                dw unk_87A6
                dw unk_87B1
                dw unk_87B8
                dw unk_87C7
                dw unk_87E3
                dw unk_87FB
                dw unk_880D
                dw unk_881D
                dw unk_8828
                dw unk_883D
                dw unk_8854
                dw unk_8866
                dw unk_886C
                dw unk_8872
                dw unk_8895
                dw unk_88A4
                dw unk_88BA
                dw unk_88C7
                dw unk_88D4
                dw unk_88E6
                dw unk_88EA
                dw unk_88F5
                dw unk_8903
                dw unk_890B
                dw unk_8916
                dw unk_8938
                dw unk_8950
                dw unk_8954
                dw unk_8964
                dw unk_8974
unk_875C:       db  $F               ; DATA XREF: ROM:envDataTbl↑o
unk_875D:       db  $F               ; DATA XREF: ROM:870C↑o
                db  $F
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   3
                db   0
unk_876E:       db  $F               ; DATA XREF: ROM:870E↑o
                db  $F
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   9
                db  $A
                db  $B
                db  $C
                db  $D
unk_8780:       db  $F               ; DATA XREF: ROM:8710↑o
                db   9
unk_8782:       db   9               ; DATA XREF: ROM:8712↑o
                db  $F
unk_8784:       db   4               ; DATA XREF: ROM:8714↑o
                db   9
                db  $F
                db  $F
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
                db   0
unk_8797:       db  $F               ; DATA XREF: ROM:8716↑o
                db  $D
                db  $B
                db   9
                db   6
                db   3
                db   0
unk_879E:       db  $C               ; DATA XREF: ROM:8718↑o
unk_879F:       db   9               ; DATA XREF: ROM:871A↑o
unk_87A0:       db   6               ; DATA XREF: ROM:871C↑o
unk_87A1:       db  $D               ; DATA XREF: ROM:871E↑o
                db  $F
                db  $F
                db  $E
                db  $D
unk_87A6:       db  $C               ; DATA XREF: ROM:8720↑o
                db  $E
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
unk_87B1:       db  $F               ; DATA XREF: ROM:8722↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $C
unk_87B8:       db  $F               ; DATA XREF: ROM:8724↑o
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
unk_87C7:       db  $F               ; DATA XREF: ROM:8726↑o
                db  $F
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
                db  $B
                db  $A
                db  $A
                db   9
                db   9
                db   8
                db   8
                db   7
                db   7
                db   6
                db   6
                db   4
                db   4
                db   3
                db   3
                db   2
                db   2
                db   1
                db   1
unk_87E3:       db  $C               ; DATA XREF: ROM:8728↑o
                db  $C
                db  $B
                db  $B
                db  $A
                db  $A
                db   9
                db   9
                db   8
                db   8
                db   7
                db   7
                db   6
                db   6
                db   5
                db   5
                db   4
                db   4
                db   3
                db   3
                db   2
                db   2
                db   1
                db   1
unk_87FB:       db  $F               ; DATA XREF: ROM:872A↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $D
                db  $C
                db  $C
                db  $C
                db  $B
                db  $B
                db   9
                db   9
                db   7
                db   6
unk_880D:       db  $F               ; DATA XREF: ROM:872C↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $C
                db  $B
                db  $B
                db  $A
                db   9
                db   8
unk_881D:       db  $F               ; DATA XREF: ROM:872E↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
unk_8828:       db  $F               ; DATA XREF: ROM:8730↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
                db  $A
                db   9
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
                db   0
unk_883D:       db  $F               ; DATA XREF: ROM:8732↑o
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   8
                db   8
                db   8
                db   8
                db   8
                db   9
                db  $A
                db  $B
                db  $C
                db  $D
                db  $E
                db  $F
unk_8854:       db   5               ; DATA XREF: ROM:8734↑o
                db  $A
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $D
                db  $D
                db  $C
                db  $C
                db  $C
                db  $B
                db  $B
                db   9
                db   9
                db   7
                db   6
unk_8866:       db  $F               ; DATA XREF: ROM:8736↑o
                db  $C
                db   9
                db   6
                db   3
                db   0
unk_886C:       db  $F               ; DATA XREF: ROM:8738↑o
                db  $D
                db   9
                db   6
                db   3
                db   9
unk_8872:       db   5               ; DATA XREF: ROM:873A↑o
                db  $A
                db  $E
                db  $F
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $D
                db  $D
                db  $C
                db  $C
                db  $C
                db  $B
                db  $B
                db  $B
                db  $A
                db  $A
                db  $A
                db   9
                db   9
                db   8
                db   8
                db   7
                db   7
                db   7
                db   7
                db   7
                db   6
                db   6
                db   6
                db   6
unk_8895:       db  $F               ; DATA XREF: ROM:873C↑o
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
unk_88A4:       db   4               ; DATA XREF: ROM:873E↑o
                db   8
                db   8
                db  $C
                db  $C
                db  $D
                db  $D
                db  $D
                db  $E
                db  $E
                db  $E
                db  $E
                db  $E
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $E
unk_88BA:       db   8               ; DATA XREF: ROM:8740↑o
                db  $C
                db  $E
                db  $F
                db  $E
                db  $D
                db  $C
                db  $C
                db  $A
                db  $A
                db   9
                db   9
                db   9
unk_88C7:       db   7               ; DATA XREF: ROM:8742↑o
                db   9
                db  $B
                db  $D
                db  $E
                db  $F
                db  $F
                db  $D
                db  $C
                db  $A
                db   9
                db   8
                db   8
unk_88D4:       db   5               ; DATA XREF: ROM:8744↑o
                db   7
                db   9
                db  $B
                db  $D
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
                db  $B
                db   9
                db   7
                db   6
unk_88E6:       db  $F               ; DATA XREF: ROM:8746↑o
                db  $C
                db   9
                db   6
unk_88EA:       db  $F               ; DATA XREF: ROM:8748↑o
                db  $D
                db  $C
                db  $A
                db   8
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
unk_88F5:       db  $F               ; DATA XREF: ROM:874A↑o
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
unk_8903:       db   7               ; DATA XREF: ROM:874C↑o
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
                db   0
unk_890B:       db   5               ; DATA XREF: ROM:874E↑o
                db   9
                db  $B
                db  $D
                db  $E
                db  $F
                db  $F
                db  $E
                db  $E
                db  $D
                db  $C
unk_8916:       db  $F               ; DATA XREF: ROM:8750↑o
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $D
                db  $C
                db  $C
                db  $B
                db  $B
                db  $A
                db  $A
                db   9
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
                db   0
unk_8938:       db  $F               ; DATA XREF: ROM:8752↑o
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db  $A
                db   9
                db   9
                db   8
                db   8
                db   8
                db   7
                db   7
                db   7
                db   6
                db   6
                db   6
                db   6
                db   5
                db   5
                db   5
                db   5
                db   4
unk_8950:       db  $F               ; DATA XREF: ROM:8754↑o
                db  $A
                db   5
                db   0
unk_8954:       db  $F               ; DATA XREF: ROM:8756↑o
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db   9
                db   8
                db   7
                db   6
                db   5
                db   4
                db   3
                db   2
                db   1
                db   0
unk_8964:       db  $B               ; DATA XREF: ROM:8758↑o
                db  $F
                db  $F
                db  $F
                db  $F
                db  $E
                db  $E
                db  $E
                db  $E
                db  $E
                db  $D
                db  $D
                db  $D
                db  $D
                db  $D
                db  $C
unk_8974:       db  $F               ; DATA XREF: ROM:875A↑o
                db  $E
                db  $D
                db  $C
                db  $B
                db  $A
                db  $A
                db  $A
                db   9
                db   9
                db   9
                db   8
                db   8
                db   8
                db   7
envEndPointTbl: db   1
                db $11
                db $12
                db   2
                db   2
                db $13
                db   7
                db   1
                db   1
                db   1
                db   5
                db  $B
                db   7
                db  $F
                db $1C
                db $18
                db $12
                db $10
                db  $B
                db $15
                db $17
                db $12
                db   6
                db   6
                db $23 ; #
                db  $F
                db $16
                db  $D
                db  $D
                db $12
                db   5
                db  $A
                db  $D
                db   7
                db  $A
                db $21 ; !
                db $17
                db   4
                db $10
                db $10
                db  $E
envLoopPointTbl:db   0
                db $10
                db $10
                db   0
                db   0
                db $12
                db   6
                db   0
                db   0
                db   0
                db   4
                db  $A
                db   0
                db   0
                db $1B
                db $17
                db $11
                db  $F
                db  $A
                db $14
                db $16
                db $11
                db   5
                db   4
                db $22 ; "
                db  $E
                db $15
                db  $C
                db  $C
                db $11
                db   4
                db   9
                db  $C
                db   6
                db   9
                db $20
                db $16
                db   3
                db  $F
                db  $F
                db  $D
sweepDataTbl:   dw unk_8A03
                dw unk_8A04
                dw unk_8A20
                dw unk_8A28
                dw unk_8A38
                dw unk_8A3A
                dw unk_8A3C
                dw unk_8A44
                dw unk_8A4C
                dw unk_8A54
                dw unk_8A56
                dw unk_8A6C
                dw unk_8A76
                dw unk_8A80
                dw unk_8A8A
                dw unk_8A8C
                dw unk_8AAB
                dw unk_8ACA
                dw unk_8ACB
                dw unk_8ACC
                dw unk_8ACD
                dw unk_8ACE
                dw unk_8ACF
unk_8A03:       db   0               ; DATA XREF: ROM:sweepDataTbl↑o
unk_8A04:       db   0               ; DATA XREF: ROM:89D7↑o
                db   0
                db   0
                db   0
                db   0
                db   0
                db   1
                db   1
                db   0
                db   0
                db $FF
                db $FF
                db   0
                db   0
                db   1
                db   1
                db   2
                db   2
                db   1
                db   1
                db   0
                db   0
                db $FF
                db $FF
                db $FE
                db $FE
                db $FF
                db $FF
unk_8A20:       db   0               ; DATA XREF: ROM:89D9↑o
                db   1
                db   2
                db   1
                db   0
                db $FF
                db $FE
                db $FF
unk_8A28:       db   0               ; DATA XREF: ROM:89DB↑o
                db   0
                db   0
                db   0
                db   1
                db   1
                db   1
                db   1
                db   0
                db   0
                db   0
                db   0
                db $FF
                db $FF
                db $FF
                db $FF
unk_8A38:       db   1               ; DATA XREF: ROM:89DD↑o
                db $FF
unk_8A3A:       db   0               ; DATA XREF: ROM:89DF↑o
                db $FF
unk_8A3C:       db   0               ; DATA XREF: ROM:89E1↑o
                db   1
                db   0
                db   0
                db   0
                db $FF
                db   0
                db   0
unk_8A44:       db   0               ; DATA XREF: ROM:89E3↑o
                db   0
                db   0
                db   1
                db   1
                db   1
                db   0
                db   0
unk_8A4C:       db   1               ; DATA XREF: ROM:89E5↑o
                db   1
                db   1
                db   0
                db   0
                db   0
                db   1
                db   1
unk_8A54:       db $FF               ; DATA XREF: ROM:89E7↑o
                db   1
unk_8A56:       db   0               ; DATA XREF: ROM:89E9↑o
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   1
                db   1
                db   1
                db   1
                db   1
unk_8A6C:       db   0               ; DATA XREF: ROM:89EB↑o
                db   0
                db   0
                db   1
                db   1
                db   1
                db   1
                db   1
                db   0
                db   0
unk_8A76:       db   1               ; DATA XREF: ROM:89ED↑o
                db   1
                db   1
                db   0
                db   0
                db   0
                db   0
                db   0
                db   1
                db   1
unk_8A80:       db $FD               ; DATA XREF: ROM:89EF↑o
                db $FE
                db $FF
                db   1
                db   2
                db   3
                db   2
                db   1
                db $FF
                db $FE
unk_8A8A:       db $FD               ; DATA XREF: ROM:89F1↑o
                db   3
unk_8A8C:       db   0               ; DATA XREF: ROM:89F3↑o
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   1
                db   1
                db   0
                db   0
                db   0
                db   1
                db   1
                db   1
                db   0
                db   0
                db   0
                db   0
                db   1
                db   1
                db   1
                db   1
                db   1
unk_8AAB:       db   0               ; DATA XREF: ROM:89F5↑o
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   0
                db   1
                db   0
                db   0
                db   1
                db   1
                db   1
                db   0
                db   0
                db   0
                db   1
                db   1
                db   1
                db   1
                db   0
                db   0
                db   0
                db   0
                db   0
unk_8ACA:       db   1               ; DATA XREF: ROM:89F7↑o
unk_8ACB:       db   2               ; DATA XREF: ROM:89F9↑o
unk_8ACC:       db   3               ; DATA XREF: ROM:89FB↑o
unk_8ACD:       db $FF               ; DATA XREF: ROM:89FD↑o
unk_8ACE:       db $FE               ; DATA XREF: ROM:89FF↑o
unk_8ACF:       db $FD               ; DATA XREF: ROM:8A01↑o
sweepEndPointTbl:db 1
                db 28
                db 8
                db 16
                db 2
                db 2
                db 8
                db 8
                db 8
                db 2
                db 22
                db 10
                db 10
                db 10
                db 2
                db 30
                db 30
                db 1
                db 1
                db 1
                db 1
                db 1
                db 1
sweepLoopPointTbl:db 0
                db 12
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 11
                db 0
                db 0
                db 0
                db 0
                db 21
                db 21
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 51
bankTbl:        db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 0
                db 2
                db 2
                db 0
                db 0
                db 0
                db 0
                db 0
                db 2
                db 3
                db 3
                db 3
                db 3
                db 3
                db 3
                db 3
                db 3
                db 0
                db 0
                db 3
                db 2
                db 2
                db 1
                db 1
                db 1
                db 0
                db 0
                db 0
SoundDataTbl:   dw 0                 ; DATA XREF: InitSound+24↑t
                                        ; InitSound+2A↑t
                dw 0
                dw 0
                dw 0
                dw $A000
                dw $A013
                dw 0
                dw 0
                dw 0
                dw $A026
                dw 0
                dw 0
                dw 0
                dw $A031
                dw 0
                dw 0
                dw 0
                dw $A05D
                dw $A04E
                dw 0
                dw 0
                dw 0
                dw $A06C
                dw 0
                dw 0
                dw 0
                dw $A0B5
                dw 0
                dw 0
                dw 0
                dw 0
                dw $A0D6
                dw 0
                dw 0
                dw $A1C5
                dw 0
                dw $A226
                dw $A259
                dw 0
                dw $A28C
                dw $A678
                dw $A853
                dw $AA42
                dw 0
                dw $AC7D
                dw $ACA8
                dw $ACCF
                dw 0
                dw $AD00
                dw $AD49
                dw $AD90
                dw 0
                dw $ADED
                dw $AE12
                dw $AE37
                dw 0
                dw $AE5A
                dw $AE9D
                dw $AEDE
                dw 0
                dw 0
                dw $A2B9
                dw 0
                dw $A2DE
                dw 0
                dw $A2EF
                dw 0
                dw $A2F8
                dw 0
                dw $A30B
                dw 0
                dw $A320
                dw $AF1B
                dw $AF40
                dw $AF63
                dw 0
                dw 0
                dw $A333
                dw 0
                dw $A346
                dw 0
                dw $A359
                dw 0
                dw 0
                dw 0
                dw 0
                dw $A388
                dw 0
                dw $AF86
                dw $B09F
                dw $B11E
                dw 0
                dw $B4B8
                dw $B54B
                dw $B5D4
                dw 0
                dw $B18D
                dw $B26A
                dw $B347
                dw 0
                dw $A4D2
                dw $A537
                dw 0
                dw 0
                dw 0
                dw $A59E
                dw 0
                dw $A5C5
                dw $B6C7
                dw $B73A
                dw $B7FD
                dw 0
                dw $B86C
                dw $B912
                dw $B9F0
                dw 0
                dw $B8C5
                dw $B965
                dw $BA3D
                dw 0
                dw 0
                dw 0
                dw $A5EC
                dw 0
                dw 0
                dw $A5FF
                dw 0
                dw 0
                dw $A60E
                dw $A623
                dw $A637
                dw $A637
                dw $AD24
                dw $AE47
                dw $AF80
                dw $B12F
                dw $B30C
                dw $B473
                dw $B5F6
                dw 0
                dw $BA8E
                dw $BABF
                dw $BAEE
                dw 0
                dw $BB1F
                dw $BBB8
                dw $BC2B
                dw 0
                dw $BCCC
                dw $BD1F
                dw $BD74
                dw 0
                dw $BDCF
                dw $BE18
                dw $BE5B
                dw 0
                dw $BE9E
                dw $BEF5
                dw $BF4C
                dw 0
                dw $B7A8
                dw $B823
                dw $B880
                dw 0
                dw $A000
                dw $A2A1
                dw $A5A8
                dw $A933
                dw $AB44
                dw $AB83
                dw $ABC0
                dw 0
                dw $AC01
                dw $AC20
                dw $AC3D
                dw 0
                dw $AC62
                dw $ACBF
                dw $AD16
                dw 0
                dw $AD73
                dw $AD84
                dw $AD97
                dw 0
                dw $ADA4
                dw $ADEF
                dw $AE3A
                dw 0
                dw $AE85
                dw $AEF6
                dw $AF65
                dw 0
                dw $AFAA
                dw $AFFB
                dw $B056
                dw 0
                dw 0
                dw 0
                dw 0
                dw $A63C
                dw 0
                dw 0
                dw 0
                dw $A64D
                dw $B0D9
                dw $B1B0
                dw $B1D1
                dw 0
                dw $A000
                dw $A28F
                dw $A5F2
                dw $A7BF
                dw $AA24
                dw $AAC3
                dw $AB62
                dw $ABCB
                dw $A175
                dw $A22C
                dw $A2E3
                dw $A3D6
                dw $A4A9
                dw $ADA6
                dw $B4EB
                dw $BC02
                dw $A000
                dw $A087
                dw $A10E
                dw 0
                db $81
                db $20
                db  $F
