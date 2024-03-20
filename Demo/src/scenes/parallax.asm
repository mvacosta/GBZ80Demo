/* Parallax Demo Scene */

SECTION "Parallax Demo", ROM0

/*
    Array holding data for when to scroll the screen.
        0 - LYC Position
        1 - Base Scrolling Speed (High)
        2 - Base Scrolling Speed (Low)
        2 - Scroll Current Value (High; loaded to SCX)
        3 - Scroll Current Value (Low)
*/
ParallaxData:
    ; Skip LYC for Clouds (since it scrolls at 0)
    dw _Parallax_Clouds_Base_Scroll
    dw _Parallax_Clouds_Base_Scroll
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
    db $FF ; Array terminator
.end

ParallaxSceneInit:
    ; Load parallax tiles into VRAM
    ld hl, ParallaxTiles
    ld de, _VRAMSceneOffset
    ld bc, ParallaxTilesEnd - ParallaxTiles
    call MemCopy

    ; Load Parallax tilemap
    ld hl, ParallaxTilemap
    ld de, vScreenMap
    ld bc, ParallaxTilemapEnd - ParallaxTilemap
    ld a, _VRAMTilemapOffset
    ld [wCopyOffset], a
    call MemCopy

    ; Setup Parallax array data
    ld hl, ParallaxData
    ld de, wParallaxScrollArray
    ld bc, ParallaxData.end - ParallaxData
    call MemCopy

    xor a
    ld [wParallaxSpeed], a
    call ParallaxCleanUp
    ret

ParallaxSceneUpdate:
    ld hl, wParallaxScrollArray

    xor a
    ldh [rSTAT], a
    ldh a, [rIE]
    set IEB_STAT, a
    ldh [rIE], a
    ei

    ; Need to skip cloud line wait since it is at line 0
    ldh a, [rSTAT]
    jr .setupScroll

.interruptLoop
    ; Set up interrupts to scroll in H-Blank
    ld a, [hl+]
    ldh [rLYC], a ; Set next line to interrupt
    ldh a, [rSTAT]
    xor a
    set STATB_LYC, a
    ldh [rSTAT], a
    halt ; Line interrupt
    nop

.setupScroll ; For skipping the initial part of the loop for the clouds
    inc hl
    inc hl
    xor a
    set STATB_MODE00, a
    ldh [rSTAT], a
    halt ; H-Blank interrupt
    nop

    ; Scroll ASAP
    ld a, [hl-]
    ldh [rSCX], a

    ; Array in HL looks like this from here:
    ; 0 - LYC
    ; 1 - Speed (Hi)
    ; 2 - Speed (Lo) <- Starting here
    ; 3 - Pos (Hi)
    ; 4 - Pos (Lo)

    ; Set up to be able to add 16-bit values (Add Speed to Pos)
    ld b, [hl]
    dec hl
    ld c, [hl]
    inc hl
    inc hl
    push hl
    push bc
    ld b, [hl]
    inc hl
    ld c, [hl]
    push bc
    pop hl ; Swap HL and BC for the loop below to work properly
    pop bc

    ; Clouds will always scroll at the same speed so check for that and skip getting multiplier
    ldh a, [rLY]
    jrgq _Parallax_LYC_Interrupt_Mountains_1, .speedLoopStart
    ld a, 1
    jr .speedLoop

.speedLoopStart
    ; Increase scroll amount, multiplying by wParallaxSpeed
    ld a, [wParallaxSpeed]

.speedLoop
    jreq 0, .speedLoopEnd
    add hl, bc
    dec a
    jr .speedLoop

.speedLoopEnd
    ld b, h
    ld c, l
    pop hl
    ld [hl], b
    inc hl
    ld [hl], c

    ; Check if end of array
    inc hl
    ld a, [hl]
    jpnq $FF, .interruptLoop

    ; Clean-up
    di
    xor a
    ldh [rSTAT], a
    ldh [rLYC], a
    ldh [rIE], a

    ret

ParallaxSceneVBlank:
    ; We will increase scroll speed during VBlank
    ld a, [iInputButtonDown]
    and iRightButton
    jr nz, .increaseSpeed
    ld a, [iInputButtonDown]
    and iLeftButton
    jr nz, .decreaseSpeed
    jr ParallaxCleanUp

.increaseSpeed ; Increase speed on pressing Right
    ld a, [wParallaxSpeed]
    jrgq _Parallax_Scroll_Max_Speed, ParallaxCleanUp
    inc a
    ld [wParallaxSpeed], a
    jr ParallaxCleanUp

.decreaseSpeed ; Decrease speed on pressing Left
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
