.export pauseCh0
pauseCh0:
	.byte CMD_TRANSPOSE, $0C
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $04
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $1F, $03
	.byte $20, $03
	.byte $24, $06
	.byte $27, $06
	.byte $2B, $19
	.byte CMD_GOTO
	.word pauseCh23

.export pauseCh1
pauseCh1:
	.byte CMD_TRANSPOSE, $0C
	.byte CMD_SET_ENV_TYPE, $04
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $0B
	.byte CMD_REST, $02
	.byte $1F, $03
	.byte $20, $03
	.byte $24, $06
	.byte $27, $06
	.byte $2B, $19

.export pauseCh23
pauseCh23:
	.byte CMD_REST, $01
	.byte CMD_GOTO
	.word pauseCh23
