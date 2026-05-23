/* Labels & Instructions that will live in HRAM */

/* HRAM hScratch Constants */
rsset $FF90 ; bytes
def C0 rb
def C1 rb
def C2 rb
def C3 rb
def C4 rb
def C5 rb
def C6 rb
def C7 rb
def C8 rb
def C9 rb
def CA rb
def CB rb
def CC rb ; Keep for H/VBlank
def CD rb
def CE rb
def CF rb

rsset $FF90 ; words
def W0 rw
def W1 rw
def W2 rw
def W3 rw
def W4 rw
def W5 rw
def W6 rw ; Keep for H/VBlank
def W7 rw

SECTION "HRAM Labels", HRAM

HRAMStart:
    ; Global Variables
    hFrameCounter::  db ; Count number of frames from 0-59
    hTotalFrames::   dw ; Count total amount of frames
    hTotalSeconds::  dw ; Count every 60 frames
    hTransferCount:: db ; How many bytes to transfer during VBlankTransfer
    hRNG::           dw ; RNG value after being rolled

    ; Controller Input
    hInputButtonLast:: db ; Input from previous frame
    hInputButtonDown:: db ; Input that was pressed this frame
    hInputButtonHold:: db ; Input that was held since last frame
    hInputButtonUp::   db ; Input that has been released this frame

    hPadHRAM:: ds 4  ; Just pad out the rest of $FF80; might use it in the future
    hScratch:: ds 16 ; 16 bytes used as scratch RAM; C# constants above refer to this region

    union ; Instructions will start & live in this section; it is unionized for easier labelling
        hASM:: ds 32
    nextu
        hOAMDMATransfer::   ds 10
        hUpdateCall::       ds 3
        hVBlankCall::       ds 3
        hLCDInterruptCall:: ds 3
        hEmergencyReset::   ds 3 ; "jp ResetAll" will be stored here
    endu
HRAMEnd:

hStack:: ds 62   ; This is the top of the stack
hStackStart:: db ; Address for the bottom of the stack

/*
    Instructions that get copied into hASM.
    These shouldn't be called normally, they should be called via HRAM using the labels above.
*/
SECTION "HRAM Executed Code", ROM0

/*
    From gbdev.io/pandocs, a routine to copy into HRAM for the OAM DMA transfers
*/
OAMDMATransferInstructions:
    ld a, high(wShadowOAM)
    ldh [rDMA], a
    ld a, vSpriteCount
.wait ; Wait for 160 cycles to finish the transfer
    dec a
    jr nz, .wait
    ret
.end

/* Call to initialize HRAM */
InitHRAM::
    ; Init HRAM values & Seed initial RNG value
    ld a, $7F
    ld c, a
    ld b, HRAMEnd - HRAMStart
    ld hl, HRAMStart
.loop
    add a, [hl] ; Comment this out to get a consistent starting RNG
    jr nc, .continue
    inc c
.continue
    ld [hl], 0
    dec b
    jr z, .seed
    inc hl
    jr .loop

.seed
    ; Save RNG's initial value & roll it once
    ldh [hRNG], a
    ld a, c
    add a
    add a
    add a
    add a
    xor c
    ldh [hRNG+1], a
    call RNG ; If HRAM is initalized with $00, RNG should become $3E7F

    ; Copy OAM DMA transfer routine into HRAM
    ld hl, OAMDMATransferInstructions
    ld de, hOAMDMATransfer
    ld bc, OAMDMATransferInstructions.end - OAMDMATransferInstructions
    call MemCopy

    ; Set up the dynamic Update and VBlank calls (and the Emergency Reset)
    ClearUpdateCall
    ClearVBlankCall
    ClearLCDInterrupt

    ; This will reset the entire game if execution somehow gets all the way down here
    ld hl, hEmergencyReset
    ld [hl+], a
    ld [hl], low(ResetAll)
    inc hl
    ld [hl], high(ResetAll)

    ret
