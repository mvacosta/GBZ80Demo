/* WRAM Values : $C000 - $DFFF */

SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    ; Global Variables
    wOAMSource:: ds vSpriteLength ; Source for OAM DMA transfer
    wFrameCounter:: db ; Count number of frames from 0-59
    wTotalFrames:: dw ; Count total amount of frames
    wTotalSeconds:: dw ; Count every 60 frames
    wCopyOffset:: db ; Used to offset data being sequentially filled

    ; Controller Input
    wInputButtonLast:: db ; Input from previous frame
    wInputButtonDown:: db ; Input that was pressed this frame
    wInputButtonHold:: db ; Input that was held since last frame
    wInputButtonUp::   db ; Input that has been released this frame

    wSceneAttributes:: db ; Determines current scene & if transitioning
    wSpriteTest:: db ; ???

    ; Parallax Scene
    wParallaxScrollArray:: ds 5 * 7 ; ParallaxData is stored here
    wParallaxSpeed::       db       ; How fast the scene is scrolling
    wParallaxAnimCount::   db       ; Count frames to animate waterfalls
WRAMEnd:
