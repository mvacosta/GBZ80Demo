/* GFX Allocation */
SECTION "GFX Container", ROM0

FontTiles:
INCLUDE "gfx/font.bin"
FontTilesEnd:

SmileSprite:
INCBIN "gfx/sprite_face.2bpp"
SmileSpriteEnd:

ParallaxTiles:
INCBIN "gfx/parallax.2bpp"
ParallaxTilesEnd:

ParallaxTilemap:
INCBIN "gfx/parallax.tilemap"
ParallaxTilemapEnd:
