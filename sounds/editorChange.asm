.export	editorChangeCh2
editorChangeCh2:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $1f, $01
	.byte $22, $01
	.byte $24, $01
	.byte $27, $01
	.byte CMD_END
