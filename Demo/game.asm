/* Helpers */
include "include.inc"

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

    call InitHRAM ; Init HRAM

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

    call ParallaxSceneInit
    call TurnOnLCD

    ; Clear stack
    xor a
    ld hl, hStack
    ld b, hStack - hStackStart
.stackLoop
    ld [hl+], a
    dec b
    jr nz, .stackLoop
    ld sp, hStackStart
    jr MainLoop.endOfFrame

MainLoop:
    call FrameStep
    call PollInput

    call hUpdateCall

    call WaitForVBlank

    call hVBlankCall

; Start waiting for the top of the frame
.endOfFrame
    xor a
    ldh [rLYC], a
    set IEB_STAT, a
    ldh [rIE], a
    xor IEF_STAT | STATF_LYC
    ldh [rSTAT], a
    xor a
    ei
    halt
    nop
    di
    ldh [rIE], a
    ldh [rSTAT], a
    jr MainLoop
