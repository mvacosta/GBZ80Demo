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
def CC rb
def CD rb
def CE rb
def CF rb

def W0 equ C0 ; words
def W1 equ C2
def W2 equ C4
def W3 equ C6
def W4 equ C8
def W5 equ CA
def W6 equ CC
def W7 equ CE

SECTION "HRAM Labels", HRAM

HRAMStart:
    ; Global Variables
    hFrameCounter:: db ; Count number of frames from 0-59
    hTotalFrames::  dw ; Count total amount of frames
    hTotalSeconds:: dw ; Count every 60 frames
    hRNG::          dw ; RNG value after being rolled

    ; Controller Input
    hInputButtonLast:: db ; Input from previous frame
    hInputButtonDown:: db ; Input that was pressed this frame
    hInputButtonHold:: db ; Input that was held since last frame
    hInputButtonUp::   db ; Input that has been released this frame

    hPadHRAM:: ds 5  ; Just pad out the rest of $FF80; might use it in the future
    hScratch:: ds 16 ; 16 bytes used as scratch RAM; C# constants above refer to this region

    union ; Instructions will start & live in this section; it is unionized for easier labelling
        hASM:: ds 29
    nextu
        hOAMDMATransfer:: ds 10
        hUpdateCall::     ds 3
        hVBlankCall::     ds 3
    endu

    hEmergencyReset: ds 3 ; "jp ResetAll" will be stored here
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
    ; Init HRAM values
    ld l, 0
    ld de, HRAMStart
    ld bc, HRAMEnd - HRAMStart
    call MemSet

    ; Copy OAM DMA transfer routine into HRAM
    ld hl, OAMDMATransferInstructions
    ld de, hOAMDMATransfer
    ld bc, OAMDMATransferInstructions.end - OAMDMATransferInstructions
    call MemCopy

    ; Set up the dynamic Update and VBlank calls (and the Emergency Reset)
    ld a, $C3 ; jp instruction
    ld hl, hUpdateCall
    ld [hl], a
    inc hl
    ld [hl], $FF
    inc hl
    ld [hl], $FF
    inc hl ; hVBlankCall
    ld [hl], a
    inc hl
    ld [hl], $FF
    inc hl
    ld [hl], $FF

    ; This will reset the entire game if execution somehow gets all the way down here
    ld hl, hEmergencyReset
    ld [hl], a
    inc hl
    ld [hl], low(ResetAll)
    inc hl
    ld [hl], high(ResetAll)

    ret
