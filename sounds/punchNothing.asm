.export	punchNothingCh3
punchNothingCh3:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $0f, $02
	.byte $06, $03
	.byte $05, $03
	.byte CMD_SET_ENV_OFFSET, $09
	.byte $06, $02
	.byte $05, $02
	.byte CMD_END
