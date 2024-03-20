/* Helpers */
include "include.inc"

/* ASM */
include "src/wram.asm"
;include "src/rst.asm"
include "src/interrupts.asm"
include "src/routines.asm"
;include "src/scenes/sprites.asm"
include "src/scenes/parallax.asm"
;include "src/scenes/wave.asm"

/* Data */
include "src/gfx.asm"

/* ROM Header */
SECTION "Header", ROM0[$0100]
    nop
    nop
    jr ResetAll

    ds $150 - @, 0

/* Game ROM Instructions */
SECTION "Game", ROM0[$0150]

/*
    Game entry point - calling this should reset everything
*/
ResetAll::
    xor a ; xor a is the same as 'ld a, 0', except it takes one less byte & cycle
    ldh [rNR52], a ; Disable sound
    call TurnOffLCD ; Turn off LCD before any set-up

    ; Init WRAM values
    ld l, 0
    ld de, WRAMStart
    ld bc, WRAMEnd - WRAMStart
    call MemSet

    ; Clear garbage in OAMRAM
    ld l, 0
    ld de, _OAMRAM
    ld bc, vSpriteLength
    call MemSet

    ; Clear screen to remove copyrighted logo
    ld l, 0
    ld de, vScreenMap
    ld bc, vWindowMap - vScreenMap
    call MemSet

    ; Load our tiles into VRAM
    ld hl, FontTiles
    ld de, vTilesBlock0
    ld bc, FontTilesEnd - FontTiles
    call MemCopy

    ; Smile Sprite can stay in VRAM
    ld hl, SmileSprite
    ld de, _VRAMSceneOffset - vTileSize8x8
    ld bc, SmileSpriteEnd - SmileSprite
    call MemCopy

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
    di
    xor a
    ldh [rIE], a
    ldh [rSTAT], a
    jr MainLoop
