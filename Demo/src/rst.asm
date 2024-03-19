/* RST Instruction Jump Vectors */

SECTION "0x00 Jump Vector", ROM0[$0000]
aRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x08 Jump Vector", ROM0[$0008]
bRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x10 Jump Vector", ROM0[$0010]
cRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x18 Jump Vector", ROM0[$0018]
dRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x20 Jump Vector", ROM0[$0020]
eRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x28 Jump Vector", ROM0[$0028]
fRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x30 Jump Vector", ROM0[$0030]
gRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

SECTION "0x38 Jump Vector", ROM0[$0038]
hRST:
    ret
    nop
    nop
    nop
    nop
    nop
    nop
    nop

; Every nop & ret are 1 byte
; Filling all of these just for references sake
