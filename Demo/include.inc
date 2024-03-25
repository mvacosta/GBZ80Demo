/* External */
include "inc/hardware.inc/hardware.inc"
include "inc/macros.inc"
include "inc/constants.inc"

/* ASM */
include "src/hram.asm"
include "src/wram.asm"
include "src/rst.asm"
include "src/interrupts.asm"
include "src/routines.asm"
;include "src/scenes/sprites.asm"
include "src/scenes/parallax.asm"
;include "src/scenes/wave.asm"

/* Data */
include "src/gfx.asm"

SECTION "Credits", ROM0[$7F80]

db "\n"
db "SPECIAL THANKS"
db "\n"
db "gbdev.io\n"
db "RGBDS\n"
db "hardware.inc\n"
db "ISSOtm\n"
db "Game Boy Development Community"
ds 32, "\n"
db "Made by  Costa"
db "\n"
