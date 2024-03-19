/* Helpers */
INCLUDE "inc/hardware.inc"
INCLUDE "inc/macros.inc"
INCLUDE "inc/constants.inc"

/* ASM */
INCLUDE "src/wram.asm"
;INCLUDE "src/rst.asm"
INCLUDE "src/interrupts.asm"
INCLUDE "src/routines.asm"
;INCLUDE "src/scenes/sprites.asm"
INCLUDE "src/scenes/parallax.asm"
;INCLUDE "src/scenes/wave.asm"

/* Data */
INCLUDE "src/gfx.asm"

/* ROM Header */
SECTION "Header", ROM0[$0100]
    nop
    nop
    jr ResetAll

    ds $150 - @, 0

/* Game ROM Instructions */
SECTION "Game", ROM0[$0150]

ResetAll::
    xor a ; xor a is the same as 'ld a, 0', except it takes one less byte & cycle
    ldh [rNR52], a ; Disable sound
    call TurnOffLCD ; Turn off LCD before any set-up

    ; Init WRAM values
    ld l, 0
    ld de, WRAMStart
    ld bc, WRAMEnd - WRAMStart
    call ByteFill

    ; Clear garbage in OAMRAM
    ld l, 0
    ld de, _OAMRAM
    ld bc, 40 * 4 ; 40 sprites with 4 bytes each
    call ByteFill

    ; Clear screen to remove copyrighted logo
    ld l, 0
    ld de, vScreenMap
    ld bc, vWindowMap - vScreenMap
    call ByteFill

    ; Load our tiles into VRAM
    ld hl, FontTiles
    ld de, vChars0
    ld bc, FontTilesEnd - FontTiles
    call SequentialFill

    ; Smile Sprite can stay in VRAM
    ld hl, SmileSprite
    ld de, _VRAMSceneOffset - 1
    ld bc, SmileSpriteEnd - SmileSprite
    call SequentialFill

    ; Set up palettes
    ld a, %11100100
    ldh [rBGP], a ; Load palette above into BG palette
    ldh [rOBP0], a ; And sprite palette 0

    ld a, %11011000
    ldh [rOBP1], a

    ; TODO: Do this better
    call ParallaxSceneInit

    call TurnOnLCD
    ld sp, wStackBottom

MainLoop:
    call FrameStep
    call PollInput

    ; TODO: Check to see if scene is changing
    ; Go to the proper scene's Update
    call ParallaxSceneUpdate

    call WaitForVBlank

    ; Go to the proper scene's VBlank
    call ParallaxSceneVBlank

; Start waiting for the top of the frame
.endOfFrame
    xor a
    ldh [rLYC], a
    set IEB_STAT, a
    ldh [rIE], a
    res IEB_STAT, a
    set STATB_LYC, a
    ldh [rSTAT], a
    ei
    halt
    nop
    di
    xor a
    ldh [rIE], a
    ldh [rSTAT], a
    jr MainLoop
