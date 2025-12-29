.export	tengenLogoCh0
tengenLogoCh0:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $0e
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $27, $07
	.byte $20, $07
	.byte $24, $07
	.byte $27, $07
	.byte $2b, $1e
	.byte CMD_END
.export	tengenLogoCh1
tengenLogoCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $0e
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $01
	.byte CMD_REST, $01
	.byte $1d, $0e
	.byte $20, $07
	.byte $24, $07
	.byte $27, $1e
	.byte CMD_END
