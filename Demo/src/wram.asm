/* WRAM Values : $C000 - $DFFF */

SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    ; Shadow Sources
    wShadowOAM::  ds vSpriteLength ; Source for OAM DMA transfer

    ; Parallax Scene
    wParallaxScrollArray:: ds 5 * 8 ; ParallaxData is stored here
    wParallaxSpeed::       db       ; How fast the scene is scrolling
    wParallaxAnimCount::   db       ; Count frames to animate waterfalls
WRAMEnd:
