/* WRAM Values : $C000 - $DFFF */

SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    ; VRAM Containers
    wShadowOAM::      ds vSpriteLength   ; Source for OAM DMA transfer
    wTransferCopy::   ds vTransferLength ; Source for VBlankTransfer (meant for Screen and Window tiles but could be used for copying random bytes)

    ; Parallax Scene
    wParallaxScrollArray:: ds 2 * 8 ; Each scrolling section is a word, and there's 8 sections
    wParallaxScrollIndex:: db       ; Index position in data arrays (i * 2 for words)
    wParallaxNextSCX::     db       ; The next SCX scroll value to use
    wParallaxSpeed::       db       ; How fast the scene is scrolling
    wParallaxAnimCount::   db       ; Count frames to animate waterfalls
    wParallaxAnimFrame::   db       ; Which frame of animation we're on for the waterfalls
WRAMEnd:
