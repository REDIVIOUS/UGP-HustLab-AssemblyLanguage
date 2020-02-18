.386
DATA SEGMENT USE16
    INF1 DB 'IN DECIMAL: $'
    INF2 DB 'IN HEXADECIMAL: $'
    INF3 DB 'HOUR SHOW$'
    INF4 DB 'MINUTE SHOW$'
    INF5 DB 'DATE SHOW$'
    INF6 DB 'MONTH SHOW$'
    INF7 DB 'ZERO SHOW$'
    BIA DB 04H ;储存当前调用的地址
    NUM DB ? ;储存当前地址的数据
DATA ENDS

STACK SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,SS:STACK
START:
    MOV AX,DATA
    MOV DS,AX
    MOV AL,BIA ;读取操作地址
    OUT 70H,AL ;设定访问信息地址
    JMP $+2 ;延时
    IN AL,71H
    MOV AH,AL 
    AND AL,0FH ;AL中存入得到数据的低四位
    SHR AH,4 ;得到数据的高四位存入AH第四位中
    ADD AX,3030H ;转换为ASCII码
    XCHG AH,AL ;将高位放在前面显示
    MOV WORD PTR NUM,AX ;得到数据结果放入NUM中
    ;提示输出的信息种类
    LEA DX,INF3
    MOV AH,9H
    INT 21H
    MOV DL,0AH
    MOV AH,2H
    INT 21H
    ;输出十进制时间
    LEA DX,INF1
    MOV AH,9H
    INT 21H
    MOV BX,OFFSET NUM
    ADD BX,2
    MOV AX,'$'
    MOV [BX],AX
    LEA DX,NUM
    MOV AH,9H
    INT 21H
    ;输出十六进制时间
    MOV DL,0AH
    MOV AH,2H
    INT 21H
    LEA DX,INF2
    MOV AH,9H
    INT 21H
    CALL SHOW16
    MOV AH,4CH
    INT 21H

;将10进制数转换为16进制输出，入口参数为BX存放待转换数
TRANS16 PROC
    MOV CX,4 ;16进制
LOP1:
    ROL BX,4  ;从最高四位开始处理，将其通过循环移位移动到最低4位
    MOV AL,BL
    AND AL,0FH  ;将AL高四位置为0，取低四位
    ADD AL,30H
    CMP AL,'9'
    JBE PRINT ;如果为0-9，直接输出
    ADD AL,07H ;否则转换为A-F，再输出
PRINT:
    MOV DL,AL
    MOV AH,2H
    INT 21H ;输出al中的字符
    DEC CX
    JNZ LOP1
    RET
TRANS16 ENDP

;将读取到的数字字符串转换成数字,NUM中存入要转换的数字,存入BX
TRANS1 PROC
    MOV BX,0
    MOV SI,OFFSET NUM
LOP2:
    MOV AH,0
    MOV AL,BYTE PTR[SI] 
    CMP AX,'$'
    JZ EXIT
    SUB AX,'0'
    XCHG BX,AX
    MOV CX,10
    MUL CX
    ADD BX,AX
    INC SI
    JMP LOP2
EXIT: RET
TRANS1 ENDP

SHOW16 PROC
    CALL TRANS1
    CALL TRANS16
    RET
SHOW16 ENDP

CODE ENDS
    END START

