.export	editorPlaceCh1
editorPlaceCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $27, $01
	.byte $2b, $01
	.byte $2e, $01
	.byte $33, $01
	.byte CMD_SET_ENV_OFFSET, $08
	.byte $27, $01
	.byte $2b, $01
	.byte $2e, $01
	.byte CMD_SET_ENV_TYPE, $06
	.byte $33, $06
	.byte CMD_END
