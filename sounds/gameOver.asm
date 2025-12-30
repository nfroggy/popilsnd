.export	gameOverCh0
gameOverCh0:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $13
	.byte CMD_SET_SWEEP_TYPE, $0c
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $24, $18
	.byte $26, $18
	.byte $27, $18
	.byte $29, $18
	.byte CMD_SET_ENV_TYPE, $14
	.byte CMD_SET_SWEEP_TYPE, $0a
	.byte $2b, $30
	.byte CMD_SET_SWEEP_TYPE, $0c
	.byte CMD_SET_ENV_TYPE, $13
	.byte $27, $18
	.byte $22, $18
	.byte $24, $18
	.byte $29, $18
	.byte $26, $18
	.byte $22, $18
	.byte $27, $30
	.byte CMD_REST, $03
	.byte $33, $2d
	.byte CMD_END
.export	gameOverCh1
gameOverCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $13
	.byte CMD_SET_SWEEP_TYPE, $0b
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $20, $18
	.byte $22, $18
	.byte $24, $18
	.byte $26, $18
	.byte CMD_SET_ENV_TYPE, $14
	.byte CMD_SET_SWEEP_TYPE, $0a
	.byte $27, $30
	.byte CMD_SET_SWEEP_TYPE, $0b
	.byte CMD_SET_ENV_TYPE, $13
	.byte $22, $18
	.byte $1f, $18
	.byte $20, $18
	.byte $24, $18
	.byte $22, $18
	.byte $20, $18
	.byte $1f, $30
	.byte $2b, $30
	.byte CMD_END
.export	gameOverCh2
gameOverCh2:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $0a
	.byte CMD_SET_SWEEP_TYPE, $0c
	.byte CMD_SET_ENV_OFFSET, $02
	.byte $20, $0c
	.byte CMD_REST, $0c
	.byte $14, $0c
	.byte CMD_REST, $0c
	.byte $21, $0c
	.byte CMD_REST, $0c
	.byte $15, $0c
	.byte CMD_REST, $0c
	.byte $22, $0c
	.byte CMD_REST, $0c
	.byte $16, $0c
	.byte CMD_REST, $0c
	.byte $24, $0c
	.byte CMD_REST, $0c
	.byte $18, $0c
	.byte CMD_REST, $0c
	.byte $1d, $30
	.byte $22, $30
	.byte $1b, $0c
	.byte CMD_REST, $24
	.byte $0f, $0c
	.byte CMD_REST, $24
	.byte CMD_END
