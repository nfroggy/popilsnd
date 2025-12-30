.export	headButtCh1
headButtCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $06
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $02
	.byte $01, $02
	.byte $00, $01
	.byte $01, $01
	.byte $02, $01
	.byte $03, $01
	.byte $04, $01
	.byte CMD_END
.export	headButtCh3
headButtCh3:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $0f, $02
	.byte CMD_SET_ENV_OFFSET, $02
	.byte $0b, $08
	.byte CMD_END
