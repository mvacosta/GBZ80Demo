/* Reusable routines (some with parameters!) */

SECTION "Routines", ROM0

; Fill amount of memory with one byte of data
; Parameters:
; l - Byte to fill with
; de - Address to fill data to
; bc - Amount of addresses to fill up to
ByteFill::
    ld a, l
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    ret z
    inc de
    jr ByteFill

; Fill amount of memory with one address of data
; Parameters:
; hl - Byte to fill with
; de - Address to fill data to
; bc - Amount of addresses to fill up to
AddressFill::
    ld a, [hl]
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    ret z
    inc de
    jr AddressFill

; Copy data to memory sequentially, from one address to another
; Parameters:
; hl - Address to copy data from
; de - Address to copy data to
; bc - Amount of addresses to copy to
; wSequentialOffset - Set to offset the Sequential Fill
SequentialFill::
    ld a, [hli]
    push hl
    ld hl, wSequentialOffset
    add a, [hl]
    pop hl
    ld [de], a
    dec bc
    ld a, c ; Check if zero
    or b
    jr z, .cleanUp
    inc de
    jr SequentialFill
.cleanUp
    ld hl, wSequentialOffset ; Clear the Offset incase this routine is called without it being set
    ld a, [hl]
    xor a
    ld [hl], a
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
