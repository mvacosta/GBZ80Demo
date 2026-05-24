/* Parallax Demo Scene */

SECTION "Parallax Demo", ROM0

/*
    Parallax Scrolling Data
*/
ParallaxScroll_Speeds:
    dw 200 ; Clouds 1
    dw 100 ; Clouds 2
    dw 25  ; Mountains 1
    dw 35  ; Mountains 2
    dw 60  ; Lake 1
    dw 70  ; Lake 2
    dw 80  ; Lake 3
    dw 128 ; Ground
.end

ParallaxLCDCInterrupt_Lines:
    db 0   ; Clouds 1
    db 23  ; Clouds 2
    db 31  ; Mountains 1
    db 53  ; Mountains 2
    db 71  ; Lake 1
    db 79  ; Lake 2
    db 95  ; Lake 3
    db 119 ; Ground
.end

/*
    Waterfall Mini Left & Right Animation Data
*/
WaterfallMiniLeft_ScTile:
    dw vScreenMap+230
    dw vScreenMap+231
    dw vScreenMap+262
    dw vScreenMap+263
.end

WaterfallMiniRight_ScTile:
    dw vScreenMap+246
    dw vScreenMap+247
    dw vScreenMap+278
    dw vScreenMap+279
.end

WaterfallMini_Anim:
    .Frame1
    db 184, 185, 186, 187
    .Frame2
    db 188, 189, 190, 191
    .Frame3
    db 192, 193, 194, 195
    .Frame4
    db 196, 197, 198, 199
.end

WaterfallMiniLeft_Seq:
    dw WaterfallMini_Anim.Frame1
    dw WaterfallMini_Anim.Frame2
    dw WaterfallMini_Anim.Frame3
    dw WaterfallMini_Anim.Frame4
.end

WaterfallMiniRight_Seq:
    dw WaterfallMini_Anim.Frame3
    dw WaterfallMini_Anim.Frame4
    dw WaterfallMini_Anim.Frame1
    dw WaterfallMini_Anim.Frame2
.end

/*
    Waterfall Big Animation Data
*/
WaterfallBig_ScTile:
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

WaterfallBig_Anim:
    .Frame1
    db      152, 153, 153, 153, 153, 154      ; Top tiles
    db 155, 156, 157, 156, 157, 156, 158, 159 ; Bottom tiles
    .Frame2
    db      160, 161, 161, 161, 161, 162
    db 163, 164, 165, 164, 165, 164, 166, 167
    .Frame3
    db      168, 169, 169, 169, 169, 170
    db 171, 172, 173, 172, 173, 172, 174, 175
    .Frame4
    db      176, 177, 177, 177, 177, 178
    db 179 ,180, 181, 180, 181, 180, 182, 183
.end

WaterfallBig_Seq:
    dw WaterfallBig_Anim.Frame1
    dw WaterfallBig_Anim.Frame2
    dw WaterfallBig_Anim.Frame3
    dw WaterfallBig_Anim.Frame4
.end

/*
    Base OAM values for the Palm Tree sprite.
*/
def X00 equ 128
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

/* 
    Routines
*/

ParallaxSceneInit:
    ; Init values
    xor a
    ld [wParallaxScrollIndex], a
    ld [wParallaxSpeed], a
    ld [wParallaxAnimCount], a
    ld [wParallaxAnimFrame], a
    ld hl, wParallaxScrollArray ; Cloud 1 layer needs to have the NextSCX populated
    inc hl
    ld a, [hl]
    ld [wParallaxNextSCX], a
    call ParallaxCleanUp

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
    ld hl, ParallaxScroll_Speeds
    ld de, wParallaxScrollArray
    ld bc, ParallaxScroll_Speeds.end - ParallaxScroll_Speeds
    call MemCopy

    ; Init Waterfall Animation
    call DoWaterfallAnimation ; Call once to populate Waterfall data
    call VBlankTransfer ; Transfer immediately to have the Waterfalls displayed frame 1

    ; Display Palm Tree as sprite
    xor a
    ldh [C0], a
    ld hl, PalmTreeSprite
    ld de, wShadowOAM
    ld bc, PalmTreeSprite.end - PalmTreeSprite
    call MemCopy
    call hOAMDMATransfer ; Transfer to OAM so it displays frame 1

    ; Setup Update & VBlank
    SetUpdateCallTo ParallaxSceneUpdate
    SetVBlankCallTo ParallaxSceneVBlank
    ret


ParallaxSceneUpdate:
    ; Setup interrupts for parallax scrolling
    ld a, 0 ; Clouds 1 scrolls immediately
    ldh [rLYC], a
    xor a
    set B_IE_STAT, a
    ldh [rIE], a
    xor IE_STAT | STAT_LYC
    ldh [rSTAT], a
    SetLCDInterruptTo ParallaxSceneLCDInterrupt
    ei ; Enable interrupt to scroll background when needed

    ; Update wParallaxScrollArray's values
    xor a
    ldh [C0], a
    ld hl, wParallaxScrollArray
:
    ; Get the value to increment by
    push hl
    add a
    ld b, 0
    ld c, a
    ld hl, ParallaxScroll_Speeds
    add hl, bc

    ; Add value to current position
    ld a, [hl]
    ld c, a
    pop hl
    ld a, [hl+]
    ld e, a
    ld a, [hl-]
    ld d, a
    push hl
    push de
    pop hl

    ; For layers below Clouds, we need to multiple by wParallaxSpeed
    ldh a, [C0]
    jrls 2, :+
    jr :++
:   ; Clouds 1 & 2, just add once
    ld a, 1
    jr .addParallax
:   ; Lower than clouds, we need to iterate
    ld a, [wParallaxSpeed]
    bit 7, a
    jr z, .addParallax
    ; First we need to turn the value into a a positive one
    cpl
    inc a

.subParallax
    ld [C1], a
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc a, b
    ld h, a
    ldh a, [C1]
    dec a
    jr nz, .subParallax
    jr :+

.addParallax
    add hl, bc
    dec a
    jr nz, .addParallax
:
    ; Store back in array
    ld e, l
    ld d, h
    pop hl
    ld a, e
    ld [hl+], a
    ld a, d
    ld [hl+], a

    ; Continue for each parallax layer
    ldh a, [C0]
    inc a
    ld b, a
    jrls 2, :+
    ld a, [wParallaxSpeed]
    cp 0
    jr z, :++
:   ; If wParallaxSpeed is 0 we don't need to update the layers below Clouds
    ld a, b
    ldh [C0], a
    jrls (ParallaxLCDCInterrupt_Lines.end - ParallaxLCDCInterrupt_Lines), :-----
:
    ; Check if we need to animate the waterfall
    ld a, [wParallaxAnimCount]
    jreq _Parallax_Waterfall_Anim_Frame_Count, :+
    inc a
    ld [wParallaxAnimCount], a
    jr .end

:   ; Do the Waterfall animation and reset the frame count
    call DoWaterfallAnimation
    xor a
    ld [wParallaxAnimCount], a

.end ; Once here, we just need to wait for HBlank interrupts
    halt
    nop
    ldh a, [rLY]
    jrls 119, .end ; 119 would be the last parallax layer

    di
    ret


DoWaterfallAnimation:
    ld a, [wParallaxAnimFrame]
    ldh [C0], a

    ; Left Mini Waterfall
    add a
    ld hl, WaterfallMiniLeft_Seq
    add l
    ld l, a
    jr nc, :+
    inc h
:
    ld a, [hl+]
    ldh [W1], a
    ld a, [hl]
    ldh [W1+1], a
    ld hl, wTransferCopy
    ld de, WaterfallMiniLeft_ScTile
    ld b, WaterfallMini_Anim.Frame2 - WaterfallMini_Anim.Frame1
    call .fillLoop

    ; Right Mini Waterfall
    ldh a, [C0]
    add a
    push hl
    ld hl, WaterfallMiniRight_Seq
    add l
    ld l, a
    jr nc, :+
    inc h
:
    ld a, [hl+]
    ldh [W1], a
    ld a, [hl]
    ldh [W1+1], a
    pop hl
    ld de, WaterfallMiniRight_ScTile
    ld b, WaterfallMini_Anim.Frame2 - WaterfallMini_Anim.Frame1
    call .fillLoop

    ; Big Waterfall
    ld a, [C0]
    add a
    push hl
    ld hl, WaterfallBig_Seq
    add l
    ld l, a
    jr nc, :+
    inc h
:
    ld a, [hl+]
    ldh [W1], a
    ld a, [hl]
    ldh [W1+1], a
    pop hl
    ld de, WaterfallBig_ScTile
    ld b, WaterfallBig_Anim.Frame2 - WaterfallBig_Anim.Frame1
    call .fillLoop
    jr .end

.fillLoop
    ld a, [de]
    ld [hl+],a
    inc de
    ld a, [de]
    ld [hl+], a
    inc de
    push hl
    ld a, [W1]
    ld l, a
    inc a
    ldh [W1], a
    ld a, [W1+1]
    ld h, a
    jr nz, :+
    inc a
    ldh [W1+1], a
:
    ld a, [hl]
    pop hl
    ld [hl+], a
    dec b
    jr nz, .fillLoop
    ret

.end
    ; Increment animation frame
    ld a, [wParallaxAnimFrame]
    inc a
    jrls 4, :+
    xor a
:
    ld [wParallaxAnimFrame], a
    ldh a, [hTransferCount]
    add ((WaterfallMini_Anim.Frame2 - WaterfallMini_Anim.Frame1) * 2) + (WaterfallBig_Anim.Frame2 - WaterfallBig_Anim.Frame1)
    ldh [hTransferCount], a
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
    inc a
    bit 7, a
    jr nz, :+
    jrgr _Parallax_Scroll_Max_Speed, ParallaxCleanUp
:
    ld [wParallaxSpeed], a
    jr ParallaxCleanUp

.increaseScrollLeft ; Increase scroll speed to the left
    ld a, [wParallaxSpeed]
    dec a
    bit 7, a
    jr z, :+
    jrls _Parallax_Scroll_Min_Speed, ParallaxCleanUp
:
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
    ld a, [wParallaxNextSCX]
    ldh [rSCX], a

    ; Setup for the next line scroll amount
    push bc
    push de
    push hl
    ld a, [wParallaxScrollIndex]
    inc a
    ldh [CC], a
    add a
    ld hl, wParallaxScrollArray
    ld b, 0
    ld c, a
    add hl, bc
    inc hl
    ld a, [hl]
    ld [wParallaxNextSCX], a

    ; See if we've reached the end of the array
    ldh a, [CC]
    jreq (ParallaxLCDCInterrupt_Lines.end - ParallaxLCDCInterrupt_Lines), .noMoreScrolling

    ; If not setup next line scroll
    ld [wParallaxScrollIndex], a
    ld hl, ParallaxLCDCInterrupt_Lines
    ld b, 0
    ld c, a
    add hl, bc
    ld a, [hl]
    ldh [rLYC], a
    xor a
    set B_IE_STAT, a
    ldh [rIE], a
    xor IE_STAT | STAT_LYC
    ldh [rSTAT], a
    SetLCDInterruptTo ParallaxSceneLCDInterrupt
    jr .end

.noMoreScrolling
    xor a
    ld [wParallaxScrollIndex], a
    ld hl, wParallaxScrollArray
    inc hl
    ld a, [hl]
    ld [wParallaxNextSCX], a
    ClearLCDInterrupt

.end
    pop hl
    pop de
    pop bc
    pop af
    ret
