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

WaterfallMiniLeft_ScTile:
    dw vScreenMap+230
    dw vScreenMap+231
    dw vScreenMap+262
    dw vScreenMap+263
.end

WaterfallMiniRight__ScTile:
    dw vScreenMap+246
    dw vScreenMap+247
    dw vScreenMap+278
    dw vScreenMap+279
.end

WaterfallBig__ScTile:
    dw vScreenMap+237 ; Top Tiles
    dw vScreenMap+238
    dw vScreenMap+239
    dw vScreenMap+240
    dw vScreenMap+241
    dw vScreenMap+242
    dw vScreenMap+268 ; Bottom Tiles
    dw vScreenMap+269
    dw vScreenMap+270
    dw vScreenMap+271
    dw vScreenMap+272
    dw vScreenMap+273
    dw vScreenMap+274
    dw vScreenMap+275
.end

WaterfallMini_Anim:
    ; Frame 1
    db 184, 185, 186, 187
    ; Frame 2
    db 188, 189, 190, 191
    ; Frame 3
    db 192, 193, 194, 195
    ; Frame 4
    db 196, 197, 198, 199
.end

WaterfallBig_Anim:
    ; Frame 1
    db      152, 153, 153, 153, 153, 154      ; Top tiles
    db 155, 156, 157, 157, 157, 157, 158, 159 ; Bottom tiles
    ; Frame 2
    db      160, 161, 161, 161, 161, 162
    db 163, 164, 165, 165, 165, 165, 166, 167
    ; Frame 3
    db      168, 169, 169, 169, 169, 170
    db 171, 172, 173, 173, 173, 173, 174, 175
    ; Frame 4
    db      176, 177, 177, 177, 177, 178
    db 179 ,180, 181, 181, 181, 181, 182, 183
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

    ; Set initial state for Waterfalls
    xor a
    ldh [C0], a
    ld hl, wTransferCopy
    ld de, WaterfallMiniLeft_ScTile
    ld b, 4

:   ; Our loop for copying data to wTransferCopy
    ld a, [de]
    ld [hl+], a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld hl, WaterfallMini_Anim
    ldh a, [C0]
    add l
    ld l, a
    ldh a, [C0]
    inc a
    ldh [C0], a
    ld a, [hl]
    pop hl
    ld [hl+], a
    dec b
    jr nz, :-

    ldh a, [C0]
    jreq 4, :+
    jreq 12, :++
    jr :++++

:   ; Mini Right Waterfall Set-Up
    ld b, 4
    jr :++

:   ; Big Waterfall Set-Up
    ld b, 14

:   ; Next Waterfall Set-Up
    add 4 ; Not done, so start populating from this offset
    ldh [C0], a
    jr :----

:   ; Finish
    ; We populated this data in wTransferCopy so let's transfer!
    ld a, 22
    ldh [hTransferCount], a
    call VBlankTransfer

    ; Display Palm Tree as sprite
    xor a
    ldh [C0], a
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
    set B_IE_STAT, a
    ldh [rIE], a
    xor IE_STAT | STAT_LYC
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
    ;

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
    ld a, IE_STAT | STAT_MODE_0
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
