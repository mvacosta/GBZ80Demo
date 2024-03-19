; Sprite Demo Instructions

SECTION "Sprites Demo", ROM0
    
SpriteSceneInit:
    ; Setup Sprite Data
    ld b, _Sprite_Y_BottomScreenBound
    ld c, _Sprite_X_LeftScreenBound + 1
    ld d, %00000000
    ld e, 16
    ld hl, $FE00 ; OAM

.XSpritesSetup:
    ld a, b
    ld [hli], a
    sub a, 9
    ld b, a
    
    ld a, c
    ld [hli], a
    add a, 10
    ld c, a

    ld a, $5F
    ld [hli], a

    ld a, d
    ld [hli], a
    xor a, %00010000
    ld d, a

    dec e
    jr nz, .XSpritesSetup

    ; Setup for second batch
    ld b, _Sprite_Y_TopScreenBound + 1
    ld c, _Sprite_X_LeftScreenBound
    ld e, 16

.YSpritesSetup:
    ld a, b
    ld [hli], a
    add a, 9
    ld b, a
    
    ld a, c
    ld [hli], a
    add a, 10
    ld c, a

    ld a, $5F
    ld [hli], a

    ld a, d
    ld [hli], a
    xor a, %00010000
    ld d, a

    dec e
    jr nz, .YSpritesSetup

    ld a, [wSpriteTest]
    ld a, %00000001 ; Moving Up
    ld [wSpriteTest], a
    ret

SpriteSceneUpdate:
    nop
    ret

SpriteSceneVBlank:
    nop
    ;call MoveSpriteUpDown
    ret


; Sprite Demo Routines
MoveSpriteUpDown:
    ld a, [wSpriteTest]
    bit 0, a
    ld a, [$FE00]
    jr z, .MoveDown
    jr .MoveUp

.MoveUp:    
    dec a
    cp _Sprite_Y_TopScreenBound
    jr z, .ResetBit
    jr .Return

.ResetBit:
    ld b, a
    ld a, [wSpriteTest]
    res 0, a
    ld [wSpriteTest], a
    ld a, b
    jr .Return

.MoveDown:
    inc a
    cp _Sprite_Y_BottomScreenBound
    jr z, .SetBit
    jr .Return

.SetBit:
    ld b, a
    ld a, [wSpriteTest]
    set 0, a
    ld [wSpriteTest], a
    ld a, b

.Return:
    ld [$FE00], a
    ret