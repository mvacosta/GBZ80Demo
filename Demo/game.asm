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
    ld b, 0
    ld hl, WRAMStart
    ld de, WRAMEnd - WRAMStart
    call MemSet

    call InitHRAM ; Init HRAM

    ; Clear garbage in OAMRAM
    ld b, 0
    ld hl, _OAMRAM
    ld de, vSpriteLength
    call MemSet

    ; Clear screen to remove logo
    ld b, 0
    ld hl, vScreenMap
    ld de, vWindowMap - vScreenMap
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
    PollInput
    ;call FrameStep

    call hUpdateCall

    call WaitForVBlank

    call hVBlankCall

    call hOAMDMATransfer
    call VBlankTransfer

; Start waiting for the top of the frame
.endOfFrame
    xor a
    ldh [rLYC], a
    set B_IE_STAT, a
    ldh [rIE], a
    xor IE_STAT | STAT_LYC
    ldh [rSTAT], a
    xor a
    ei
    nop
    halt
    nop
    di
    ldh [rIE], a
    ldh [rSTAT], a
    jr MainLoop
