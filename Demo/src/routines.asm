/* Reusable Routines (some with parameters!) */

SECTION "Routines", ROM0

/*
    Fills block of memory with byte held in l.
    Parameters:
         l - Byte to set with
        de - Start address to set to
        bc - Amount of addresses to set to
*/
MemSet::
    ld a, l
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    ret z
    inc de
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
    ldh [C0], a ; Clear the offset incase this routine is again
    ret

/* Turn on LCD using these attributes */
TurnOnLCD::
    ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ8 | LCDCF_OBJON
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
    ei
    xor a
    set IEB_VBLANK, a
    ldh [rIE], a
    halt
    nop
    xor a
    ldh [rIE], a
    di
    ret

/*
    Set up the dynamic Update call.
    Parameters:
        de - Address used in the dynamic jump
*/
SetUpdateCall::
    ld hl, hUpdateCall+1
    ld [hl], e
    inc hl
    ld [hl], d
    ret

/*
    Set up the dynamic VBlank call.
    Parameters:
        de - Address used in the dynamic jump
*/
SetVBlankCall::
    ld hl, hVBlankCall+1
    ld [hl], e
    inc hl
    ld [hl], d
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

/* Read inputs and put them into the four HRAM input variables. */
PollInput::
    ld a, P1F_5 ; %00100000; checking to see the status of the D-Pad
    ldh [rP1], a

    ldh a, [rP1] ; Check multiple times to avoid bouncing
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]

    and $0F ; Only check with the bottom bits
    swap a ; Swap the bottom and upper bits
    ld b, a ; We'll keep the status of the D-Pad in b for the time being

    ld a, P1F_4 ; %00010000; checking to see the status of the four buttons
    ldh [rP1], a

    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]

    and $0F
    or b ; This effectively stores all 8 inputs into one byte

    ; Store new Inputs
    cpl
    ld b, a

    ; Determine Down, Hold, and Up inputs
    ; b = Current Button Inputs, c = Last Button Inputs
    ldh a, [hInputButtonLast]
    ld c, a

    ; Button Down
    cpl
    and b
    ldh [hInputButtonDown], a

    ; Button Held
    ld a, c
    and b
    ldh [hInputButtonHold], a

    ; Button Up
    ld a, c
    and b
    cpl
    and c
    ldh [hInputButtonUp], a

    ; Save the current inputs for next frame
    ld a, b
    ldh [hInputButtonLast], a

    ret

; Returns with A containing a random number between 0 - 255 */
RNG::
    ret
