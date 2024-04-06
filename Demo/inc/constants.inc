/* Constants for easier address reading */

/* VRAM Constants */
def vTileSize8x8  equ 16
def vTileSize8x16 equ vTileSize8x8 * 2
def vSpriteSize   equ 4
def vSpriteCount  equ 40
def vSpriteLength equ vSpriteCount * vSpriteSize ; 40 sprites with 4 bytes each

def vTilesBlock0 equ $8000
def vTilesBlock1 equ $8800
def vTilesBlock2 equ $9000
def vScreenMap   equ $9800
def vWindowMap   equ $9C00

/* Input Constants */
; Individual button checks
def iDownButton   equ %10000000
def iUpButton     equ %01000000
def iLeftButton   equ %00100000
def iRightButton  equ %00010000
def iStartButton  equ %00001000
def iSelectButton equ %00000100
def iBButton      equ %00000010
def iAButton      equ %00000001

/* Game Constants */
def _60FrameCount      equ 60    ; For counting to 60 frames
def _VRAMSceneOffset   equ $8600 ; VRAM starting from here is free
def _VRAMTilemapOffset equ $60   ; When using Tilemaps, this offset is after the font and smile sprite

/* Sprite Scene Constants */
def _Sprite_Y_TopScreenBound    equ 16
def _Sprite_Y_BottomScreenBound equ 152
def _Sprite_X_LeftScreenBound   equ 8
def _Sprite_X_RightScreenBound  equ 160

/* Parallax Scene Constants */
; Speed Control Multiplier
def _Parallax_Scroll_Min_Speed        equ 0
def _Parallax_Scroll_Max_Speed        equ 6

; LCDC Interrupt Lines
def _Parallax_LYC_Interrupt_Clouds_1    equ 0
def _Parallax_LYC_Interrupt_Clouds_2    equ 23
def _Parallax_LYC_Interrupt_Mountains_1 equ 31
def _Parallax_LYC_Interrupt_Mountains_2 equ 53
def _Parallax_LYC_Interrupt_Lake_1      equ 71
def _Parallax_LYC_Interrupt_Lake_2      equ 79
def _Parallax_LYC_Interrupt_Lake_3      equ 95
def _Parallax_LYC_Interrupt_Ground      equ 119

; Different Speed Lines
def _Parallax_Clouds_1_Base_Scroll    equ 200
def _Parallax_Clouds_2_Base_Scroll    equ 100
def _Parallax_Mountains_1_Base_Scroll equ 25
def _Parallax_Mountains_2_Base_Scroll equ 35
def _Parallax_Lake_1_Base_Scroll      equ 60
def _Parallax_Lake_2_Base_Scroll      equ 70
def _Parallax_Lake_3_Base_Scroll      equ 80
def _Parallax_Ground_Base_Scroll      equ 128

; Waterfall Animation
def _Parallax_Waterfall_Anim_Frame_Count equ 6
def _Parallax_Mini_Waterfall_Min_Index   equ 184
def _Parallax_Mini_Waterfall_Max_Index   equ 196
def _Parallax_Mini_Waterfall_Anim_Offset equ 4
def _Parallax_Big_Waterfall_Min_Index    equ 152
def _Parallax_Big_Waterfall_Max_Index    equ 176
def _Parallax_Big_Waterfall_Anim_Offset  equ 8
