/* GFX Allocation */
SECTION "GFX Container", ROM0

FontTiles:
    incbin "gfx/font.bin"
FontTilesEnd:

SmileSprite:
    incbin "gfx/sprite_face.2bpp"
SmileSpriteEnd:

ParallaxTiles:
    incbin "gfx/parallax.2bpp"
ParallaxTilesEnd:

ParallaxTilemap:
    incbin "gfx/parallax.tilemap"
ParallaxTilemapEnd:
