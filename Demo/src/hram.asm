/* Labels & Instructions that will live in HRAM */

SECTION "HRAM Labels", HRAM

HRAMStart:
    hScratch:: ds 16 ; 16 bytes used as scratch RAM; can be unionized if ended up being used a lot

    union ; Instructions will start & live in this section, it is unionized for easier labelling
        hASM:: ds 45
    nextu
        hOAMDMATransfer:: ds 10
        hDynamicCall::    ds 4
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
    ld a, high(wOAMSource)
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

    ; The following will insert "jp ResetAll" before the stack.
    ; This will reset the entire game if execution somehow gets all the way down here.
    ld hl, hEmergencyReset
    ld [hl], $C3 ; jp instruction
    inc hl
    ld [hl], low(ResetAll)
    inc hl
    ld [hl], high(ResetAll)

    ret
