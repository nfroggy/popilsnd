.segment "BANK0"
.include "sounds/cmds.inc"

.include "sounds/tengenLogo.asm"
.include "sounds/level.asm"
.include "sounds/gameOver.asm"
.include "sounds/badClear.asm"
.include "sounds/blockBreak.asm"
.include "sounds/punchNothing.asm"
.include "sounds/headButt.asm"
.include "sounds/punchBlock.asm"
.include "sounds/teleport.asm"
.include "sounds/menu.asm"
.include "sounds/editorMusic.asm"
.include "sounds/death.asm"
.include "sounds/punchSolid.asm"
.include "sounds/pause.asm"
.include "sounds/goodClear.asm"
.include "sounds/roundsUnlocked.asm"

.export noiseTest
noiseTest:
	.byte $00, $20
	.byte $01, $20
	.byte $02, $20
	.byte $03, $20
	.byte $04, $20
	.byte $05, $20
	.byte $06, $20
	.byte $07, $20
	.byte $08, $20
	.byte $09, $20
	.byte $0a, $20
	.byte $0b, $20
	.byte $0c, $20
	.byte $0d, $20
	.byte $0e, $20
	.byte $0f, $20
	.byte CMD_END