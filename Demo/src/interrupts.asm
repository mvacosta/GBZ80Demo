/* Interrupt Jump Vectors */

SECTION "Vertical Blank", ROM0[$0040]
VBlankInterrupt:
    reti
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "LCD STAT", ROM0[$0048]
LCDInterrupt:
    reti
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "Timer Overflow", ROM0[$0050]
TimerInterrupt:
    reti
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "Serial Transfer Complete", ROM0[$0058]
STInterrupt:
    reti
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "Joypad Pressed", ROM0[$0060]
JoypadInterrupt:
    reti
    nop
    nop
    nop
    nop
    nop
    nop
    nop

; Every nop & reti are 1 byte
; Filling all of these just for references sake
