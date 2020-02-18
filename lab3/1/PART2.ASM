;Lab3-part2
;function3, function4 and function5

.386

PUBLIC CALCREFER, RANKLEVEL, ALLINFO
EXTERN OUTNAME :NEAR, TRANS10 :NEAR, GA1 :BYTE, TEMP :BYTE, OUT1 :BYTE, OUT2 :BYTE, OUT3 :BYTE, 
        OUT4 :BYTE, OUT5 :BYTE, OUT6 :BYTE, OUT7 :BYTE, TEMPADDR :WORD

PRINTS MACRO PR ;9号调用输出字符串
    PUSH AX
    PUSH DX
	LEA DX, PR
	MOV AH, 9H
	INT 21H
    POP DX
    POP AX
ENDM

CRLF MACRO ;换行
    PUSH AX
    PUSH DX
	MOV DL, 0AH
	MOV AH, 2H
	INT 21H
    POP DX
    POP AX
ENDM

TENOUT MACRO NUM ;输出十进制数字
    PUSH AX
	MOV AX, WORD PTR [NUM]
	CALL TRANS10
	PRINTS TEMP
    POP AX
ENDM

; 控制输出排名信息
OUTRANK MACRO
    PUSH AX
    MOV AX, RANKNUM[DI]
    PRINTS BUF3
    CALL TRANS10
	PRINTS TEMP
    CRLF
    POP AX
ENDM

; 控制输出折扣宏
OUTDISCOUNT MACRO
    PRINTS OUT2
    ADD DL, 30H
    MOV AH, 2
    INT 21H
ENDM

OUTNODISCOUNT MACRO
    PUSH AX
    PRINTS OUT2
    MOV DH, 0
    MOV AX, DX
    CALL TRANS10
	PRINTS TEMP
    POP AX
ENDM

STACK SEGMENT USE16 PARA STACK 'STACK'
    DB 500 DUP(0)
STACK ENDS

DATA SEGMENT USE16 PARA PUBLIC 'DATA'
    ; 当实际售价为0时输出
    BUF1 DB 'FOR FREE', 0AH, 0DH, '$'
    M EQU 4
    ; 当进货数量为0或者进货数量小于等于已售数量时输出
    BUF2 DB 'NO ENOUGH COMMODITY', 0AH, 0DH, '$'
    BUF3 DB 'RANKING:$'
    ; 计算排名时使用，存放了所有商品推荐度从大到小排序后的偏移值
    RANKING DW M DUP(0)
    ; 排名
    RANKNUM DW M DUP(0)
    TEMPNUM DW ?
DATA ENDS

CODE SEGMENT USE16 PARA PUBLIC 'CODE'
    ASSUME CS:CODE, DS:DATA, SS:STACK
    
; 计算推荐度
CALCREFER PROC USES EAX EBX ECX EDX EDI ESI EBP
    MOV SI, M
    LEA BP, GA1
ONECALC:
    MOV AX, DS:WORD PTR [BP+17]
    CMP AX, DS:WORD PTR [BP+15]
    JNL NEC
    ; 推荐度 = (进货价*(2*进货数量)+已售数量*实际销售价格)*128/实际销售价格*2*进货数量
    ; 计算进货数量*2
    MOVZX EAX, DS:WORD PTR [BP+15]
    CMP EAX, 0
    JZ NEC
    SHL EAX, 1
    MOV ECX, EAX
    ; 计算实际销售价格
    MOVZX EAX, DS:BYTE PTR [BP+10]
    MUL DS:WORD PTR [BP+13]
    MOV EBX, 10
    XOR EDX, EDX
    DIV EBX
    CMP EAX, 0
    JZ NRP
    MOV EDI, EAX
    ; 计算分母,实际销售价格*2*进货数量
    MUL ECX
    MOV EBX, EAX
    ; 进货价*(2*进货数量)
    MOVZX EAX, DS:WORD PTR [BP+11]
    MUL ECX
    MOV ECX, EAX
    ; 已售数量*实际销售价格
    MOVZX EAX, DS:WORD PTR [BP+17]
    MUL EDI
    ADD EAX, ECX
    ; *128
    SHL EAX, 7
    XOR EDX, EDX
    ; 除以分母，计算出结果
    DIV EBX
    ; 存放到推荐度处
    MOV DS:[BP+19], AX
LOPCALC:
    DEC SI    
    JZ ENDCALC
    ADD BP, 21
    JMP ONECALC
NRP: ; 实际售价为0时输出
    PRINTS BUF1
    JMP LOPCALC
NEC: ; NOT ENOUGH COMMODITIES
    PRINTS BUF2
    JMP LOPCALC
ENDCALC:
    RET
CALCREFER ENDP

; 按推荐度排名
RANKLEVEL PROC USES AX BX CX DX DI SI
    CALL CALCREFER
    MOV CX, M
    LEA BX, GA1
    MOV DI, 0
LOPCOL: ; 先将所有商品的偏移值存放到一个地方
    MOV RANKING[DI], BX
    ADD DI, 2
    ADD BX, 21
    DEC CX
    JNZ LOPCOL
    MOV DI, 0
LOPR: ; 使用选择排序对其进行排序
    MOV BX, DI
    ADD BX, 2
LOPCMP:
    MOV SI, RANKING[DI]
    MOV CX, [SI+19]
    MOV SI, RANKING[BX]
    MOV DX, [SI+19]
    CMP DX, CX
    JB NEXTLOPR
CHANGER: ; 如果前一个商品的推荐度比后一个商品的推荐度小(将其向后排)，两者交换位置
    MOV TEMPNUM, SI
    MOV SI, RANKING[DI]
    MOV RANKING[BX], SI
    MOV SI, TEMPNUM
    MOV RANKING[DI], SI
NEXTLOPR:
    ADD BX, 2
    CMP BX, 2*M
    JB LOPCMP
    ADD DI, 2
    CMP DI, 2*(M-1)
    JB LOPR
    ; 对所有的商品进行排名
    MOV AX, 1
    MOV DI, 0
    MOV WORD PTR RANKNUM[DI], AX
LOPRANK: ; 比较前后两个商品的推荐度是否相等，如果相等，两者排名相同，否则对排名计数器加一，进行下一次比较
    MOV SI, RANKING[DI]
    MOV CX, [SI+19]
    MOV SI, RANKING[BX]
    MOV DX, [SI+19]
    CMP DX, CX
    JZ GETRANK
    INC AX
GETRANK:
    MOV WORD PTR RANKNUM+2[DI], AX
    ADD DI, 2
    CMP DI, 2*(M-1)
    JB LOPRANK
    RET
RANKLEVEL ENDP

; 输出商品所有信息
ALLINFO PROC USES DI BX SI
    CALL RANKLEVEL
    MOV DI, 0
LOPOUT:
    MOV SI, RANKING[DI]
    MOV TEMPADDR, SI
    ; 输出排名
    OUTRANK
    ; 输出商品名
    CALL OUTNAME
    CRLF
    ; 输出折扣
    MOV DL, 10[SI]
    CMP DL, 10
    JZ GREATER
    OUTDISCOUNT
    JMP OTHERS 
GREATER:
    OUTNODISCOUNT
OTHERS:
    CRLF
    ; 输出进价
    PRINTS OUT7
    TENOUT SI+11
    CRLF
    ; 输出售价
    PRINTS OUT3
    TENOUT SI+13
    CRLF
    ; 输出进货数量
    PRINTS OUT4
    TENOUT SI+15
    CRLF
    ; 输出已售数量
    PRINTS OUT5
    TENOUT SI+17
    CRLF
    ; 输出推荐度
    PRINTS OUT6
    TENOUT SI+19
    CRLF
    ADD DI, 2
    CMP DI, 2*M
    JNB ENDINFO
    JMP LOPOUT
ENDINFO:
    RET
ALLINFO ENDP

CODE ENDS
    END
