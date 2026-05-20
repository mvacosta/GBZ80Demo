/* Reusable Routines (some with parameters!) */

SECTION "Routines", ROM0

/*
    Fills block of memory with byte held in b.
    Parameters:
         b - Byte to set with
        hl - Start address to set to
        de - Amount of addresses to set to
*/
MemSet::
    ld a, b
    ld [hl+], a
    dec de
    ld a, e ; Check if zero
    or d
    ret z
    jr MemSet

/*
    Copies block of memory from HL into DE.
    Parameters:
        hl - Address to copy data from
        de - Address to copy data to
        bc - Amount of addresses to copy to
        C0 - Set to offset the copied values
*/
MemCopy::
    ldh a, [C0]
    add a, [hl]
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    jr z, .cleanUp
    inc hl
    inc de
    jr MemCopy
.cleanUp
    xor a
    ldh [C0], a ; Clear the offset incase this routine is called again
    ret

/* Turn on LCD using these attributes */
TurnOnLCD::
    ld a, LCDC_ON | LCDC_BLOCK01 | LCDC_BG_9800 | LCDC_BG_ON | LCDC_OBJ_8 | LCDC_OBJ_ON
    ldh [rLCDC], a
    ret

/* Turn off the LCD in order to write to VRAM */
TurnOffLCD::
    ldh a, [rLCDC]
    rlca ; LCD On/Off bit is the 7th bit
    ret nc ; If we don't carry then the LCD is already turned off

    call WaitForVBlank

    xor a
    ldh [rLCDC], a ; Turn off LCD
    ret

/* Wait for the LCD control to enter VBlank via interrupt */
WaitForVBlank::
    xor a
    set B_IE_VBLANK, a
    ldh [rIE], a
    ei
    halt
    nop
    di
    xor a
    ldh [rIE], a
    ret

/* Count each frame and increment total frames and "seconds" */
FrameStep::
    ldh a, [hTotalFrames]
    inc a
    ldh [hTotalFrames], a
    cp 0
    jr nz, .secondsCheck
    ldh a, [hTotalFrames + 1]
    inc a
    ldh [hTotalFrames + 1], a

.secondsCheck
    ldh a, [hFrameCounter]
    inc a
    cp _60FrameCount
    jr nc, .addSecond

.saveCount
    ldh [hFrameCounter], a
    ret

.addSecond
    ldh a, [hTotalSeconds]
    inc a
    ldh [hTotalSeconds], a
    cp 0
    jr nz, .resetCount
    ldh a, [hTotalSeconds + 1]
    inc a
    ldh [hTotalSeconds + 1], a

.resetCount
    xor a ; Reset Counter; Every 0 is ~1 second
    jr .saveCount

/*  */
VBlankTransfer::
    ldh a, [hTransferCount]
    cp 0
    ret z
    ld b, a
    ld hl, wTransferCopy
:
    ld e, [hl]
    inc hl
    ld d, [hl]
    inc hl
    ld a, [hl+]
    ld [de], a
    dec b
    jr nz, :-
    xor a
    ldh [hTransferCount], a
    ret

/* de has address, a has value */
AppendToVBlankTransfer::
    ld b, a
    ldh a, [hTransferCount]
    ld c, a
    ld a, b
    ld b, $00
    ld hl, wTransferCopy
    add hl, bc
    ld [hl], e
    inc hl
    ld [hl], d
    inc hl
    ld [hl], a
    ldh a, [hTransferCount]
    inc a
    ldh [hTransferCount], a
    ret

/* Returns with A & hRNG+0 containing a random number between 0 - 255 */
RNG::
    ldh a, [hRNG+1]
    ld b, a
    add a
    add a
    add a
    add a
    xor b
    ld c, a
    add a
    xor c
    ld b, a
    ldh a, [hRNG]
    rrca
    xor b
    ld b, a
    ldh a, [hRNG]
    ldh [hRNG+1], a
    ld a, b
    ldh [hRNG], a
    ret
