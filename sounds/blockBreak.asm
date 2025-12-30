.export	blockBreakCh1
blockBreakCh1:
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $0d
	.byte CMD_SET_ENV_OFFSET, $03
	.byte $07, $02
	.byte $08, $02
	.byte $07, $02
	.byte $08, $02
	.byte $1b, $02
	.byte $19, $02
	.byte CMD_SET_ENV_OFFSET, $01
	.byte $17, $01
	.byte $15, $01
	.byte $13, $01
	.byte $11, $01
	.byte $0f, $01
	.byte $0d, $01
	.byte CMD_END
.export	blockBreakCh3
blockBreakCh3:
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $01
	.byte $0d, $0e
	.byte CMD_END
