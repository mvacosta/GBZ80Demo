/* "Extended" Instruction Macros */
; Macros that are fake instructions so I don't have to remember the exact order of instructions every time

/* JP Extensions */

/*
    jpeq n8, n16 (Jump if Equal)
    Compare A to value n8 and jp to address n16 if A == value.
*/
macro jpeq
    cp \1
    jp z, \2
endm

/*
    jpnq n8, n16 (Jump if Not Equal)
    Compare A to value n8 and jp to address n16 if A != value.
*/
macro jpnq
    cp \1
    jp nz, \2
endm

/*
    jpls n8, n16 (Jump if Less than)
    Compare A to value n8 and jp to address n16 if A < value.
*/
macro jpls
    cp \1
    jp c, \2
endm

/*
    jplq n8, n16 (Jump if Less than or Equal)
    Compare A to value n8 and jp to address n16 if A <= value.
*/
macro jplq
    jpls \1, \2
    jp z, \2
endm

/*
    jpgr n8, n16 (Jump if Greater than)
    Compare A to value n8 and jp to address n16 if A > value.
*/
macro jpgr
    cp \1
    jr z, .eq\@
    jp nc, \2
.eq\@
endm

/*
    jpgq n8, n16 (Jump if Greater than or Equal)
    Compare A to value n8 and jp to address n16 if A >= value.
*/
macro jpgq
    cp \1
    jp nc, \2 
endm

/* JR Extensions */

/*
    jreq n8, n16 (Relative Jump if Equal)
    Compare A to value n8 and jr to address n16 if A == value.
*/
macro jreq
    cp \1
    jr z, \2
endm

/*
    jrnq n8, n16 (Relative Jump if Not Equal)
    Compare A to value n8 and jr to address n16 if A != value.
*/
macro jrnq
    cp \1
    jr nz, \2
endm

/*
    jrls n8, n16 (Relative Jump if Less than)
    Compare A to value n8 and jr to address n16 if A < value.
*/
macro jrls
    cp \1
    jr c, \2
endm

/*
    jrlq n8, n16 (Relative Jump if Less than or Equal)
    Compare A to value n8 and jr to address n16 if A <= value.
*/
macro jrlq
    jrls \1, \2
    jr z, \2
endm

/*
    jrgr n8, n16 (Relative Jump if Greater than)
    Compare A to value n8 and jr to address n16 if A > value.
*/
macro jrgr
    cp \1
    jr z, .eq\@
    jr nc, \2
.eq\@
endm

/*
    jrgq n8, n16 (Relative Jump if Greater than or Equal)
    Compare A to value n8 and jr to address n16 if A >= value.
*/
macro jrgq
    cp \1
    jr nc, \2 
endm

/* CALL Extensions */

/*
    ceq n8, n16 (Call if Equal)
    Compare A to value n8 and call address n16 if A == value.
*/
macro ceq
    cp \1
    call z, \2
endm

/*
    cnq n8, n16 (Call if Not Equal)
    Compare A to value n8 and call address n16 if A != value.
*/
macro cnq
    cp \1
    call nz, \2
endm

/*
    cls n8, n16 (Call if Less than)
    Compare A to value n8 and call address n16 if A < value.
*/
macro cls
    cp \1
    call c, \2
endm

/*
    clq n8, n16 (Call if Less than or Equal)
    Compare A to value n8 and call address n16 if A <= value.
*/
macro clq
    cls \1, \2
    call z, \2
endm

/*
    cgr n8, n16 (Call if Greater than)
    Compare A to value n8 and call address n16 if A > value.
*/
macro cgr
    cp \1
    jr z, .eq\@
    call nc, \2
.eq\@
endm

/*
    cgq n8, n16 (Call if Greater than or Equal)
    Compare A to value n8 and call address n16 if A >= value.
*/
macro cgq
    cp \1
    call nc, \2 
endm
