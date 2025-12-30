.export	teleportCh1
teleportCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $1f, $02
	.byte $22, $02
	.byte $25, $02
	.byte $28, $02
	.byte CMD_SET_ENV_OFFSET, $04
	.byte $20, $02
	.byte $23, $02
	.byte $26, $02
	.byte $29, $02
	.byte CMD_SET_ENV_OFFSET, $08
	.byte $21, $02
	.byte $24, $02
	.byte $27, $02
	.byte $2a, $02
	.byte CMD_SET_ENV_OFFSET, $0c
	.byte $22, $02
	.byte $25, $02
	.byte $28, $02
	.byte $2b, $02
	.byte CMD_END
