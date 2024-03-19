/* WRAM Values : $C000 - $DFFF */
SECTION "WRAM", WRAM0[$C000]

WRAMStart:
    wFrameCounter:: db ; Count number of frames from 0-59
    wTotalFrames:: dw ; Count total amount of frames
    wTotalSeconds:: dw ; Count every 60 frames
    wControllerInput:: dl ; Store controller input
    wSequentialOffset:: db ; Used to offset data being sequentially filled
    wSceneAttributes:: db ; Determines current scene & if transitioning
    wSpriteTest:: db ; ???
    wParallaxScrollArray:: ds 5 * 7 ; ParallaxData is stored here
    wParallaxSpeed:: db ; How fast the scene is scrolling
WRAMEnd:

/* Stick the stack at the end of WRAM */
SECTION "Stack", WRAM0[$DFFF - _StackSize]

wStack:
    ds _StackSize
wStackBottom:
