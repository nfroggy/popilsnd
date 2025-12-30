.export	punchSolidCh1
punchSolidCh1:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_TEMPO, $00
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $0d
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $02
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $04
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $06
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $08
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $0a
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $0c
	.byte $0a, $02
	.byte CMD_SET_ENV_OFFSET, $0e
	.byte $0a, $02
	.byte CMD_END
.export	punchSolidCh3
punchSolidCh3:
	.byte CMD_TRANSPOSE, $0c
	.byte CMD_SET_ENV_TYPE, $00
	.byte CMD_SET_SWEEP_TYPE, $00
	.byte CMD_SET_ENV_OFFSET, $00
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $02
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $04
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $06
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $08
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $0a
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $0c
	.byte $0c, $02
	.byte CMD_SET_ENV_OFFSET, $0e
	.byte $0c, $02
	.byte CMD_END
