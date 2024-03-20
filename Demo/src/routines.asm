/* Reusable Routines (some with parameters!) */

SECTION "Routines", ROM0

/*
    Fills block of memory with byte held in L.
    Parameters:
         L - Byte to set with
        DE - Start address to set to
        BC - Amount of addresses to set to
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
        HL - Address to copy data from
        DE - Address to copy data to
        BC - Amount of addresses to copy to
        wCopyOffset - Set to offset the Sequential Fill
*/
MemCopy::
    ld a, [hl+]
    push hl
    ld hl, wCopyOffset
    add a, [hl]
    pop hl
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    jr z, .cleanUp
    inc de
    jr MemCopy
.cleanUp
    xor a
    ld [wCopyOffset], a ; Clear the Offset incase this routine is called without it being set
    ret

; Turn on LCD using these attributes
TurnOnLCD::
    ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_BG9800 | LCDCF_BGON | LCDCF_OBJ8 | LCDCF_OBJON
    ldh [rLCDC], a
    ret

; Turn off the LCD in order to write to VRAM
TurnOffLCD::
    ldh a, [rLCDC]
    rlca ; LCD On/Off bit is the 7th bit
    ret nc ; If we don't carry then the LCD is already turned off

    call WaitForVBlank

    xor a
    ldh [rLCDC], a ; Turn off LCD
    ret

; Wait for the LCD control to enter VBlank via interrupt
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

; Count each frame and increment total frames and "seconds"
FrameStep::
    ld a, [wTotalFrames]
    inc a
    ld [wTotalFrames], a
    cp 0
    jr nz, .secondsCheck
    ld a, [wTotalFrames + 1]
    inc a
    ld [wTotalFrames + 1], a

.secondsCheck
    ld a, [wFrameCounter]
    inc a
    cp _60FrameCount
    jr nc, .addSecond

.saveCount
    ld [wFrameCounter], a
    ret

.addSecond
    ld a, [wTotalSeconds]
    inc a
    ld [wTotalSeconds], a
    cp 0
    jr nz, .resetCount
    ld a, [wTotalSeconds + 1]
    inc a
    ld [wTotalSeconds + 1], a

.resetCount
    xor a ; Reset Counter; Every 0 is ~1 second
    jr .saveCount

; Read inputs and put them into wControllerInput
PollInput:: ; Get inputs pressed and store it into RAM
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
    ld a, [iInputButtonLast]
    ld c, a

    ; Button Down
    cpl
    and b
    ld [iInputButtonDown], a

    ; Button Held
    ld a, c
    and b
    ld [iInputButtonHold], a

    ; Button Up
    ld a, c
    and b
    cpl
    and c
    ld [iInputButtonUp], a

    ; Save the current inputs for next frame
    ld a, b
    ld [iInputButtonLast], a

    ret

; Returns with A containing a random number between 0 - 255
RNG::
    ret
