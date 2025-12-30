.export	punchBlockCh1
punchBlockCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $00, $02
	.byte $07, $03
	.byte $01, $03
	.byte $07, $03
	.byte $01, $03
	.byte CMD_END
.export	punchBlockCh3
punchBlockCh3:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $0f, $02
	.byte $0a, $06
	.byte CMD_SET_ENV_OFFSET, $09
	.byte $0a, $04
	.byte CMD_END
