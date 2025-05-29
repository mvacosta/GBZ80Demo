/* WRAM Values : $C000 - $DFFF */

SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    ; VRAM Containers
    wShadowOAM::      ds vSpriteLength   ; Source for OAM DMA transfer
    wTransferCopy::   ds vTransferLength ; Source for VBlankTransfer (meant for Screen and Window tiles but could be used for copying random bytes)

    ; Parallax Scene
    wParallaxScrollArray:: ds 5 * 8 ; ParallaxData is stored here
    wParallaxSpeed::       db       ; How fast the scene is scrolling
    wParallaxAnimCount::   db       ; Count frames to animate waterfalls
WRAMEnd:
