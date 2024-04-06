/* WRAM Values : $C000 - $DFFF */

SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    ; Global Variables
    wShadowOAM::  ds vSpriteLength ; Source for OAM DMA transfer
    wCopyOffset:: db ; Used to offset data being sequentially filled

    ; Parallax Scene
    wParallaxScrollArray:: ds 5 * 7 ; ParallaxData is stored here
    wParallaxSpeed::       db       ; How fast the scene is scrolling
    wParallaxAnimCount::   db       ; Count frames to animate waterfalls
WRAMEnd:
