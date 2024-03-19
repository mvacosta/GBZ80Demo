/* Constants for easier address reading */

/* VRAM Constants */
def vChars0 equ $8000
def vChars1 equ $8800
def vChars2 equ $9000
def vScreenMap equ $9800
def vWindowMap equ $9C00

/* Input Constants */
; These corrospond to the WRAM addresses for wControllerInput
rsset $C005
def iInputButtonLast rb ; The last frame's button input
def iInputButtonDown rb ; When the button is initially pressed down
def iInputButtonHold rb ; When the button is being held
def iInputButtonUp   rb ; When the button is released

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
def _StackSize         equ $40   ; 64 bytes for Stack
def _60FrameCount      equ 60    ; For counting to 60 frames
def _VRAMSceneOffset   equ $8600 ; VRAM starting from here is free
def _VRAMTilemapOffset equ $60   ; When using Tilemaps, this offset is after the font and smile sprite

/* Scene Constants */
def _Scene0Sprites  equ %00000001
def _Scene1Parallax equ %00000010
def _Scene2Wave     equ %00000100

def _SceneTransitionIn   equ %00001000
def _SceneTransitionOut  equ %00010000
def _SceneTransitionInit equ %00100000

def _LCDSCheck equ %10000000

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
def _Parallax_LYC_Interrupt_Clouds      equ 0
def _Parallax_LYC_Interrupt_Mountains_1 equ 31
def _Parallax_LYC_Interrupt_Mountains_2 equ 53
def _Parallax_LYC_Interrupt_Lake_1      equ 71
def _Parallax_LYC_Interrupt_Lake_2      equ 79
def _Parallax_LYC_Interrupt_Lake_3      equ 95
def _Parallax_LYC_Interrupt_Ground      equ 119

; Different Speed Lines
def _Parallax_Clouds_Base_Scroll      equ 200
def _Parallax_Mountains_1_Base_Scroll equ 25
def _Parallax_Mountains_2_Base_Scroll equ 35
def _Parallax_Lake_1_Base_Scroll      equ 60
def _Parallax_Lake_2_Base_Scroll      equ 70
def _Parallax_Lake_3_Base_Scroll      equ 80
def _Parallax_Ground_Base_Scroll      equ 128
