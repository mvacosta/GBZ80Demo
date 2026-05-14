/* Parallax Demo Scene */

SECTION "Parallax Demo", ROM0

/*
    Data for when to scroll the screen.
        0 - LYC Position
        1 - Base Scrolling Speed (Lo)
        2 - Base Scrolling Speed (Hi)
        2 - Scroll Current Value (Lo)
        3 - Scroll Current Value (Hi)
*/
ParallaxData:
    ; Skip LYC for Clouds (since it scrolls at 0)
    dw _Parallax_Clouds_1_Base_Scroll
    dw _Parallax_Clouds_1_Base_Scroll
    db _Parallax_LYC_Interrupt_Clouds_2
    dw _Parallax_Clouds_2_Base_Scroll
    dw _Parallax_Clouds_2_Base_Scroll
    db _Parallax_LYC_Interrupt_Mountains_1
    dw _Parallax_Mountains_1_Base_Scroll
    dw _Parallax_Mountains_1_Base_Scroll
    db _Parallax_LYC_Interrupt_Mountains_2
    dw _Parallax_Mountains_2_Base_Scroll
    dw _Parallax_Mountains_2_Base_Scroll
    db _Parallax_LYC_Interrupt_Lake_1
    dw _Parallax_Lake_1_Base_Scroll
    dw _Parallax_Lake_1_Base_Scroll
    db _Parallax_LYC_Interrupt_Lake_2
    dw _Parallax_Lake_2_Base_Scroll
    dw _Parallax_Lake_2_Base_Scroll
    db _Parallax_LYC_Interrupt_Lake_3
    dw _Parallax_Lake_3_Base_Scroll
    dw _Parallax_Lake_3_Base_Scroll
    db _Parallax_LYC_Interrupt_Ground
    dw _Parallax_Ground_Base_Scroll
    dw _Parallax_Ground_Base_Scroll
    db $FF ; Terminator
.end

/*
    Data for animating the waterfalls.
        0 - Sreen Map Index
        1 - Tile Index
*/
WaterfallAnimData:
    ; Left Mini Waterfall
    dw vScreenMap+230
    db _Parallax_Mini_Waterfall_Min_Index
    dw vScreenMap+231
    db _Parallax_Mini_Waterfall_Min_Index+1
    dw vScreenMap+262
    db _Parallax_Mini_Waterfall_Min_Index+2
    dw vScreenMap+263
    db _Parallax_Mini_Waterfall_Min_Index+3
    ; Right Mini Waterfall
    dw vScreenMap+246
    db _Parallax_Mini_Waterfall_Min_Index
    dw vScreenMap+247
    db _Parallax_Mini_Waterfall_Min_Index+1
    dw vScreenMap+278
    db _Parallax_Mini_Waterfall_Min_Index+2
    dw vScreenMap+279
    db _Parallax_Mini_Waterfall_Min_Index+3
    db $FF ; First terminator to know when to check for Big Waterfall
    ; Big Waterfall (Top Tiles)
    dw vScreenMap+237
    db _Parallax_Big_Waterfall_Min_Index
    dw vScreenMap+238
    db _Parallax_Big_Waterfall_Min_Index+1
    dw vScreenMap+239
    db _Parallax_Big_Waterfall_Min_Index+1
    dw vScreenMap+240
    db _Parallax_Big_Waterfall_Min_Index+1
    dw vScreenMap+241
    db _Parallax_Big_Waterfall_Min_Index+1
    dw vScreenMap+242
    db _Parallax_Big_Waterfall_Min_Index+2
    ; Big Waterfall (Bottom Tiles)
    dw vScreenMap+268
    db _Parallax_Big_Waterfall_Min_Index+3
    dw vScreenMap+269
    db _Parallax_Big_Waterfall_Min_Index+4
    dw vScreenMap+270
    db _Parallax_Big_Waterfall_Min_Index+5
    dw vScreenMap+271
    db _Parallax_Big_Waterfall_Min_Index+5
    dw vScreenMap+272
    db _Parallax_Big_Waterfall_Min_Index+5
    dw vScreenMap+273
    db _Parallax_Big_Waterfall_Min_Index+5
    dw vScreenMap+274
    db _Parallax_Big_Waterfall_Min_Index+6
    dw vScreenMap+275
    db _Parallax_Big_Waterfall_Min_Index+7
    db $FF ; Second terminator
.end

/*
    Base OAM values for the Palm Tree sprite.
*/
def X00 equ _Parallax_Ground_Base_Scroll
def Xn1 equ X00 - 8
def Xn2 equ Xn1 - 8
def Xp1 equ X00 + 8
def Xp2 equ Xp1 + 8
PalmTreeSprite:
    db                  28, Xn1, 201, 0, 28, X00, 202, 0, 28, Xp1, 203, 0, 28, Xp2, 204, 0
    db 36, Xn2, 205, 0, 36, Xn1, 206, 0, 36, X00, 207, 0, 36, Xp1, 208, 0, 36, Xp2, 209, 0
    db 44, Xn2, 210, 0, 44, Xn1, 211, 0, 44, X00, 212, 0, 44, Xp1, 213, 0, 44, Xp2, 214, 0
    db 52, Xn2, 215, 0, 52, Xn1, 216, 0, 52, X00, 217, 0, 52, Xp1, 218, 0,
    db                                   60, X00, 219, 0
    db                                   68, X00, 219, 0
    db                                   76, X00, 219, 0
    db                                   84, X00, 219, 0
    db                                   92, X00, 219, 0
    db                                  100, X00, 219, 0
    db                                  108, X00, 219, 0
    db                                  116, X00, 219, 0
    db                                  124, X00, 219, 0
    db                                  132, X00, 200, 0
.end
purge X00, Xn1, Xn2, Xp1, Xp2

ParallaxSceneInit:
    ; Load parallax tiles into VRAM
    ld hl, ParallaxTiles
    ld de, _VRAMSceneOffset
    ld bc, ParallaxTilesEnd - ParallaxTiles
    call MemCopy

    ; Load parallax tilemap
    ld hl, ParallaxTilemap
    ld de, vScreenMap
    ld bc, ParallaxTilemapEnd - ParallaxTilemap
    ld a, _VRAMTilemapOffset
    ldh [C0], a
    call MemCopy

    ; Setup parallax array with initial data
    ld hl, ParallaxData
    ld de, wParallaxScrollArray
    ld bc, ParallaxData.end - ParallaxData
    call MemCopy

    ; Setup waterfall first set of tiles
    ld c, 2
    ld hl, WaterfallAnimData
    ld a, [hl+]

.waterfallLoop
    ld e, a
    ld a, [hl+]
    ld d, a
    ld a, [hl+]
    ld [de], a
    ld a, [hl+]
    jrnq $FF, .waterfallLoop
    ld a, [hl+]
    dec c
    jr nz, .waterfallLoop

    ; Display Palm Tree as sprite
    ld hl, PalmTreeSprite
    ld de, wShadowOAM
    ld bc, PalmTreeSprite.end - PalmTreeSprite
    call MemCopy
    call hOAMDMATransfer ; Transfer to OAM so it displays frame 1

    ; Init WRAM values
    xor a
    ld [wParallaxSpeed], a
    ld [wParallaxAnimCount], a
    call ParallaxCleanUp

    ; Setup Update & VBlank
    SetUpdateCallTo ParallaxSceneUpdate
    SetVBlankCallTo ParallaxSceneVBlank
    ret

ParallaxSceneUpdate:
    ld a, _Parallax_LYC_Interrupt_Ground
    ldh [rLYC], a
    xor a
    set IEB_STAT, a
    ldh [rIE], a
    xor IEF_STAT | STATF_LYC
    ldh [rSTAT], a
    SetLCDInterruptTo ParallaxSceneLCDInterrupt
    ei

    ; Check if Waterfalls need to be animated
    ld hl, wParallaxAnimCount
    ld a, [hl]
    jreq _Parallax_Waterfall_Anim_Frame_Count, .anim
    inc a
    jr .cont

.anim
    ld hl, WaterfallAnimData
    ld e, [hl]
    

    xor a
    ld hl, wParallaxAnimCount

.cont ; Can skip above if it doesn't need updating
    ld [hl], a

    halt
    nop
    halt
    nop

    di
    ret

ParallaxSceneVBlank:
    ; Increase scroll speed
    ldh a, [hInputButtonDown]
    and iRightButton
    jr nz, .increaseScrollRight
    ldh a, [hInputButtonDown]
    and iLeftButton
    jr nz, .increaseScrollLeft
    jr ParallaxCleanUp

.increaseScrollRight ; Increase scroll speed to the right
    ld a, [wParallaxSpeed]
    jrgq _Parallax_Scroll_Max_Speed, ParallaxCleanUp
    inc a
    ld [wParallaxSpeed], a
    jr ParallaxCleanUp

.increaseScrollLeft ; Increase scroll speed to the left
    ld a, [wParallaxSpeed]
    jrlq _Parallax_Scroll_Min_Speed, ParallaxCleanUp
    dec a
    ld [wParallaxSpeed], a

ParallaxCleanUp:
    ; Minor clean-up
    xor a
    ldh [rLYC], a
    ldh [rSCX], a
    ldh [rSCY], a
    ret

ParallaxSceneLCDInterrupt:
    push af
    push de
    push hl
    SetLCDInterruptTo .hBlank
    ld a, IEF_STAT | STATF_MODE00
    ldh [rSTAT], a
    pop hl
    pop de
    pop af
    ret
.hBlank
    push af
    ldh a, [CF]
    inc a
    ldh [rSCX], a
    ldh [CF], a
    push hl
    ClearLCDInterrupt
    pop hl
    pop af
    ret
