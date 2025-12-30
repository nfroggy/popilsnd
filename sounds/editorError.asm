.export	editorErrorCh1
editorErrorCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $05
	.byte CMD_SET_ENV_OFFSET, $03
	.byte $08, $04
	.byte CMD_REST, $04
	.byte $08, $0a
	.byte CMD_END
.export	editorErrorCh2
editorErrorCh2:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $05
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $15, $04
	.byte CMD_REST, $04
	.byte $15, $0a
	.byte CMD_END
