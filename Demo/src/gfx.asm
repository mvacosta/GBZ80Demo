/* GFX Allocation */
SECTION "GFX Container", ROM0

FontTiles:
    include "gfx/font.bin"
FontTilesEnd:

SmileSprite:
    incbin "gfx/sprite_face.2bpp"
SmileSpriteEnd:

ParallaxTiles:
    incbin "gfx/parallax.2bpp"
    incbin "gfx/animated_big_waterfall.2bpp"
    incbin "gfx/animated_mini_waterfall.2bpp"
ParallaxTilesEnd:

ParallaxTilemap:
    incbin "gfx/parallax.tilemap"
ParallaxTilemapEnd:
