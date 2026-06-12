; ================================================
; MINI SHELL - EMU8086 (WITH MOD + BITWISE OPS)
; ================================================

.MODEL SMALL
.STACK 100h

.DATA
    ; --- Prompt & UI ---
    welcome_msg  DB  13,10
                 DB  "  ================================",13,10
                 DB  "       MINI SHELL v1.0           ",13,10
                 DB  "    Assembly Language Project     ",13,10
                 DB  "  ================================",13,10
                 DB  "  Type 'help' for commands list  ",13,10,13,10,'$'

    prompt_msg   DB  13,10,"MiniShell> $"
    newline_str  DB  13,10,'$'
    unknown_msg  DB  13,10,"  Unknown command! Type 'help'$"

    ; --- Help ---
    help_msg     DB  13,10
                 DB  "  ============================",13,10
                 DB  "     AVAILABLE COMMANDS       ",13,10
                 DB  "  ============================",13,10
                 DB  "  help    - Show this menu",13,10
                 DB  "  cls     - Clear screen",13,10
                 DB  "  date    - Show current date",13,10
                 DB  "  time    - Show current time",13,10
                 DB  "  calc    - Calculator",13,10
                 DB  "  color   - Change text color",13,10
                 DB  "  echo    - Repeat your text",13,10
                 DB  "  about   - About this shell",13,10
                 DB  "  exit    - Exit shell",13,10
                 DB  "  ============================",13,10,'$'

    ; --- About ---
    about_msg    DB  13,10
                 DB  "  Mini Shell v1.0",13,10
                 DB  "  Built in 8086 Assembly",13,10
                 DB  "  University Project$"

    ; --- Date/Time ---
    date_msg     DB  13,10,"  Date: $"
    time_msg     DB  13,10,"  Time: $"
    slash_msg    DB  "/$"
    colon_msg    DB  ":$"

    ; --- Calculator ---
    calc_msg     DB  13,10
                 DB  "  === CALCULATOR ===",13,10
                 DB  "  Arithmetic : +  -  *  /  %",13,10
                 DB  "  Bitwise    : &  |  ~  (AND/OR/NOR)",13,10
                 DB  13,10,'$'
    num1_msg     DB  "  Enter first number : $"
    num2_msg     DB  "  Enter second number: $"
    op_msg       DB  "  Operation: $"
    result_msg   DB  13,10,"  Result = $"
    div_zero_msg DB  13,10,"  Error: Division by zero!$"
    inv_op_msg   DB  13,10,"  Error: Invalid operator!$"

    ; --- Color Command ---
    color_msg    DB  13,10
                 DB  "  === CHANGE COLOR ===",13,10
                 DB  "  1 - White  (default)",13,10
                 DB  "  2 - Green",13,10
                 DB  "  3 - Cyan",13,10
                 DB  "  4 - Red",13,10
                 DB  "  5 - Magenta",13,10
                 DB  "  6 - Yellow",13,10
                 DB  "  Enter choice (1-6): $"
    color_done   DB  13,10,"  Color changed!$"

    ; --- Echo Command ---
    echo_prompt  DB  13,10,"  Enter text to echo: $"
    echo_output  DB  13,10,"  >> $"

    ; --- Command Strings ---
    cmd_exit  DB "exit$"
    cmd_help  DB "help$"
    cmd_cls   DB "cls$"
    cmd_date  DB "date$"
    cmd_time  DB "time$"
    cmd_calc  DB "calc$"
    cmd_color DB "color$"
    cmd_echo  DB "echo$"
    cmd_about DB "about$"

    ; --- Input Buffers ---
    input_buf    DB  21
                 DB  0
                 DB  21 DUP(0)

    num_buf1     DB  7
                 DB  0
                 DB  7 DUP(0)

    num_buf2     DB  7
                 DB  0
                 DB  7 DUP(0)

    op_buf       DB  4
                 DB  0
                 DB  4 DUP(0)

    echo_buf     DB  51
                 DB  0
                 DB  51 DUP(0)

    color_buf    DB  4
                 DB  0
                 DB  4 DUP(0)

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    CALL CLEAR_SCREEN
    LEA DX, welcome_msg
    CALL PRINT_STRING

SHELL_LOOP:
    LEA DX, prompt_msg
    CALL PRINT_STRING

    LEA DX, input_buf
    CALL GET_INPUT

    CALL PRINT_NEWLINE
    CALL PROCESS_COMMAND

    JMP SHELL_LOOP

MAIN ENDP

; ================================================
PRINT_NEWLINE PROC
    LEA DX, newline_str
    CALL PRINT_STRING
    RET
PRINT_NEWLINE ENDP

; ================================================
PROCESS_COMMAND PROC
    LEA SI, input_buf+2

    LEA DI, cmd_exit
    CALL STR_COMPARE
    JE DO_EXIT

    LEA DI, cmd_help
    CALL STR_COMPARE
    JE DO_HELP

    LEA DI, cmd_cls
    CALL STR_COMPARE
    JE DO_CLS

    LEA DI, cmd_date
    CALL STR_COMPARE
    JE DO_DATE

    LEA DI, cmd_time
    CALL STR_COMPARE
    JE DO_TIME

    LEA DI, cmd_calc
    CALL STR_COMPARE
    JE DO_CALC

    LEA DI, cmd_color
    CALL STR_COMPARE
    JE DO_COLOR

    LEA DI, cmd_echo
    CALL STR_COMPARE
    JE DO_ECHO

    LEA DI, cmd_about
    CALL STR_COMPARE
    JE DO_ABOUT

    LEA DX, unknown_msg
    CALL PRINT_STRING
    RET

DO_EXIT:
    MOV AH, 4Ch
    MOV AL, 0
    INT 21h

DO_HELP:
    LEA DX, help_msg
    CALL PRINT_STRING
    RET

DO_CLS:
    CALL CLEAR_SCREEN
    RET

DO_DATE:
    CALL SHOW_DATE
    RET

DO_TIME:
    CALL SHOW_TIME
    RET

DO_CALC:
    CALL CALCULATOR
    RET

DO_COLOR:
    CALL CHANGE_COLOR
    RET

DO_ECHO:
    CALL ECHO_TEXT
    RET

DO_ABOUT:
    LEA DX, about_msg
    CALL PRINT_STRING
    RET

PROCESS_COMMAND ENDP

; ================================================
; CALCULATOR - Arithmetic + Bitwise Operations
; +  -  *  /  % (mod)
; &  |  ~  (AND, OR, NOR)
; ================================================
CALCULATOR PROC
    LEA DX, calc_msg
    CALL PRINT_STRING

    ; --- Get First Number ---
    LEA DX, num1_msg
    CALL PRINT_STRING
    LEA DX, num_buf1
    CALL GET_INPUT
    CALL PRINT_NEWLINE
    LEA SI, num_buf1+2
    CALL STR_TO_NUM
    MOV BX, AX              ; BX = num1

    ; --- Get Operator ---
    LEA DX, op_msg
    CALL PRINT_STRING
    LEA DX, op_buf
    CALL GET_INPUT
    CALL PRINT_NEWLINE

    ; --- Get Second Number ---
    LEA DX, num2_msg
    CALL PRINT_STRING
    LEA DX, num_buf2
    CALL GET_INPUT
    CALL PRINT_NEWLINE
    LEA SI, num_buf2+2
    CALL STR_TO_NUM
    MOV CX, AX              ; CX = num2

    ; --- Print Result Label ---
    LEA DX, result_msg
    CALL PRINT_STRING

    ; --- Check Operator ---
    MOV AL, op_buf[2]       ; Get operator char

    ; Arithmetic
    CMP AL, '+'
    JE CALC_ADD
    CMP AL, '-'
    JE CALC_SUB
    CMP AL, '*'
    JE CALC_MUL
    CMP AL, '/'
    JE CALC_DIV
    CMP AL, '%'
    JE CALC_MOD

    ; Bitwise
    CMP AL, '&'
    JE CALC_AND
    CMP AL, '|'
    JE CALC_OR
    CMP AL, '~'
    JE CALC_NOR

    ; Invalid
    LEA DX, inv_op_msg
    CALL PRINT_STRING
    JMP CALC_DONE

; ---- ARITHMETIC ----
CALC_ADD:
    MOV AX, BX
    ADD AX, CX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_SUB:
    MOV AX, BX
    SUB AX, CX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_MUL:
    MOV AX, BX
    IMUL CX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_DIV:
    CMP CX, 0
    JE CALC_DIV_ZERO
    MOV AX, BX
    CWD
    IDIV CX
    CALL PRINT_NUM          ; AX = quotient
    JMP CALC_DONE

CALC_MOD:
    ; MOD = remainder after division
    ; Same as DIV but print DX (remainder)
    CMP CX, 0
    JE CALC_DIV_ZERO
    MOV AX, BX
    CWD
    IDIV CX                 ; DX = remainder
    MOV AX, DX              ; Move remainder to AX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_DIV_ZERO:
    LEA DX, div_zero_msg
    CALL PRINT_STRING
    JMP CALC_DONE

; ---- BITWISE ----
CALC_AND:
    ; AND: both bits must be 1
    MOV AX, BX
    AND AX, CX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_OR:
    ; OR: at least one bit must be 1
    MOV AX, BX
    OR  AX, CX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_NOR:
    ; NOR: OR first, then NOT
    MOV AX, BX
    OR  AX, CX
    NOT AX
    CALL PRINT_NUM
    JMP CALC_DONE

CALC_DONE:
    CALL PRINT_NEWLINE
    RET

CALCULATOR ENDP

; ================================================
CHANGE_COLOR PROC
    LEA DX, color_msg
    CALL PRINT_STRING

    LEA DX, color_buf
    CALL GET_INPUT
    CALL PRINT_NEWLINE

    MOV AL, color_buf[2]

    CMP AL, '1'
    JE COLOR_WHITE
    CMP AL, '2'
    JE COLOR_GREEN
    CMP AL, '3'
    JE COLOR_CYAN
    CMP AL, '4'
    JE COLOR_RED
    CMP AL, '5'
    JE COLOR_MAGENTA
    CMP AL, '6'
    JE COLOR_YELLOW
    JMP COLOR_SKIP

COLOR_WHITE:
    MOV BL, 07h
    JMP SET_COLOR
COLOR_GREEN:
    MOV BL, 0Ah
    JMP SET_COLOR
COLOR_CYAN:
    MOV BL, 0Bh
    JMP SET_COLOR
COLOR_RED:
    MOV BL, 0Ch
    JMP SET_COLOR
COLOR_MAGENTA:
    MOV BL, 0Dh
    JMP SET_COLOR
COLOR_YELLOW:
    MOV BL, 0Eh
    JMP SET_COLOR

SET_COLOR:
    MOV AH, 06h
    MOV AL, 00h
    MOV BH, BL
    MOV CX, 0000h
    MOV DX, 184Fh
    INT 10h
    MOV AH, 02h
    MOV BH, 00h
    MOV DX, 0000h
    INT 10h
    LEA DX, color_done
    CALL PRINT_STRING

COLOR_SKIP:
    RET
CHANGE_COLOR ENDP

; ================================================
ECHO_TEXT PROC
    LEA DX, echo_prompt
    CALL PRINT_STRING

    LEA DX, echo_buf
    CALL GET_INPUT
    CALL PRINT_NEWLINE

    LEA DX, echo_output
    CALL PRINT_STRING

    LEA SI, echo_buf+2
    MOV CL, echo_buf[1]
    XOR CH, CH
    CMP CX, 0
    JE ECHO_DONE

ECHO_LOOP:
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI
    LOOP ECHO_LOOP

ECHO_DONE:
    CALL PRINT_NEWLINE
    RET
ECHO_TEXT ENDP

; ================================================
SHOW_DATE PROC
    MOV AH, 2Ah
    INT 21h

    LEA DX, date_msg
    CALL PRINT_STRING

    MOV AL, DL
    CALL PRINT_TWO_DIGITS
    LEA DX, slash_msg
    CALL PRINT_STRING
    MOV AL, DH
    CALL PRINT_TWO_DIGITS
    LEA DX, slash_msg
    CALL PRINT_STRING
    MOV AX, CX
    CALL PRINT_NUM
    RET
SHOW_DATE ENDP

; ================================================
SHOW_TIME PROC
    MOV AH, 2Ch
    INT 21h

    LEA DX, time_msg
    CALL PRINT_STRING

    MOV AL, CH
    CALL PRINT_TWO_DIGITS
    LEA DX, colon_msg
    CALL PRINT_STRING
    MOV AL, CL
    CALL PRINT_TWO_DIGITS
    LEA DX, colon_msg
    CALL PRINT_STRING
    MOV AL, DH
    CALL PRINT_TWO_DIGITS
    RET
SHOW_TIME ENDP

; ================================================
PRINT_TWO_DIGITS PROC
    PUSH AX
    PUSH DX
    MOV AH, 0
    MOV DL, 10
    DIV DL
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    ADD AH, '0'
    MOV DL, AH
    MOV AH, 02h
    INT 21h
    POP DX
    POP AX
    RET
PRINT_TWO_DIGITS ENDP

; ================================================
PRINT_STRING PROC
    MOV AH, 09h
    INT 21h
    RET
PRINT_STRING ENDP

; ================================================
GET_INPUT PROC
    MOV AH, 0Ah
    INT 21h
    RET
GET_INPUT ENDP

; ================================================
CLEAR_SCREEN PROC
    MOV AH, 00h
    MOV AL, 03h
    INT 10h
    RET
CLEAR_SCREEN ENDP

; ================================================
STR_COMPARE PROC
    PUSH SI
    PUSH DI
    PUSH BX
CMP_LOOP:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP BL, '$'
    JE CMP_CHECK_END
    CMP AL, BL
    JNE CMP_NOT_EQUAL
    INC SI
    INC DI
    JMP CMP_LOOP
CMP_CHECK_END:
    CMP AL, 13
    JE CMP_EQUAL
    CMP AL, 0
    JE CMP_EQUAL
    CMP AL, ' '
    JE CMP_EQUAL
CMP_NOT_EQUAL:
    POP BX
    POP DI
    POP SI
    MOV AX, 1
    RET
CMP_EQUAL:
    POP BX
    POP DI
    POP SI
    XOR AX, AX
    RET
STR_COMPARE ENDP

; ================================================
STR_TO_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX
    XOR AX, AX
    XOR BX, BX
STN_LOOP:
    MOV BL, [SI]
    CMP BL, 13
    JE STN_DONE
    CMP BL, 0
    JE STN_DONE
    CMP BL, '0'
    JB STN_DONE
    CMP BL, '9'
    JA STN_DONE
    SUB BL, '0'
    MOV CX, 10
    MUL CX
    ADD AX, BX
    INC SI
    JMP STN_LOOP
STN_DONE:
    POP DX
    POP CX
    POP BX
    RET
STR_TO_NUM ENDP

; ================================================
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JGE PN_POSITIVE
    PUSH AX
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    POP AX
    NEG AX

PN_POSITIVE:
    XOR CX, CX
    MOV BX, 10
PN_DIVIDE:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE PN_DIVIDE

    CMP CX, 0
    JNE PN_PRINT
    MOV DL, '0'
    MOV AH, 02h
    INT 21h
    JMP PN_END

PN_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP PN_PRINT
        
        
PN_END:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

END MAIN