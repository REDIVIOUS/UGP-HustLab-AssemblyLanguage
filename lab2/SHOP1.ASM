.386

STACK SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK ENDS 

DATA SEGMENT USE16
	BNAME DB 'WL DING',0,0,0  ;老板姓名（由于我的名字拼音超过了10个字节，故名采用缩写）
	BPASS DB '111111' ;密码
	N EQU 30 ;商品数量
	M EQU 3000
	GA1 DB 'PEN',  7 DUP(0), 10 ;商品名称及折扣
      	        DW 35, 56, 70, 25, ? ;推荐度还未计算
	GA2 DB 'BOOK', 6 DUP(0), 9 ;商品名称及折扣
         	        DW 12, 30, 25, 5, ? ;推荐度还未计算
        	GA3 DB 'TEST1',5 DUP(0), 9
                	         DW 500,30,25,5,? ;设置比较大的进货量，防溢出测试
        	GA4 DB 'TEST2',5 DUP(0), 10
                         DW 0,30,25,0,? ;进货价和已销售量设置为0，看能否正常输出
	GAN DB N-5 DUP('Temp-Value' ,8)
	         DW N-5 DUP(12,30,25,5,?) ;除了几个已经具体定义了的商品信息以外，其他商品信息暂时假定为一样的
	GAB DB 'BAG',7 DUP(0), 10 ;BAG和它的折扣
	        DW 12,30,2000,0,? ;进货价，销售价，销售总数，已售数量，利润率


	AUTH DB 0
	TEMP1 DW ?
	ADRESST DW ?;暂存地址
	IN_NAME DB 12
       	   DB ?
	        DB 12 DUP(0)
	IN_PWD DB 10
            DB ?
            DB 10 DUP(0)
	IN_ITEM DB 12
        	   DB ?
      	   DB 12 DUP(0)
	PUTNAME DB 'PLEASE INPUT THE NAME(INPUT ENTER TO LOOKUP, INPUT Q TO QUIT)$'
	NOTITEM DB 'DO NOT FIND THE ITEM$'
	PUTPASSWORD DB 'PLEASE INPUT THE PASSWORD$'
	ITEMNAME DB 'PLEASE INPUT THE ITEM NAME(INPUT ENTER TO INPUT NAME)$'
	LOGFAIL DB 'YOUR USER NAME OR PASSWORD IS WRONG!$'
	LOGINREMIND DB 'IDENTIFICATION GOT!$'
	REMINDED DB 'THE TIME CALCULATE IS OVER!$'
	TEMP_REMIND DB 'temp sign$'
	DATA ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA
START: 
	MOV AX,DATA
	MOV DS,AX ;设置数据段寄存器的值

INNAME:
	MOV AUTH,0
	LEA DX,PUTNAME ;提示用户输入名字
	MOV AH,9H
	INT 21H
	MOV DL, 0AH
	MOV AH,2H
	INT 21H

	LEA DX,IN_NAME 
	MOV AH,10
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA BX,OFFSET IN_NAME 

	CMP BYTE PTR [BX+2],0DH ;如果是回车，则直接查询
	JE LOOKUP
	CMP BYTE PTR [BX+2],'Q' ;如果是q就退出
	JE EXIT

	MOV DI, OFFSET IN_NAME ;指向输入的地址
	ADD DI,2
	MOV SI,OFFSET BNAME ;指向原来匹配名字的地址
	SUB SI,1
	SUB DI,1
	MOV CX,0

LOPA:
	ADD DI,1
	ADD SI,1
	ADD CX,1
	CMP CX,8H
	JE PASSWORD 
	MOV BL,BYTE PTR [SI] ;在BL中存入真实的姓名
	CMP BL,BYTE PTR [DI] ;将输入值有与真实姓名作比较
	JE LOPA ;如果为真，继续执行下一个比较
	JNE INPUTFAIL ;如不为真，则提示失败
	

PASSWORD:
	LEA DX,PUTPASSWORD ;提示用户输入密码
	MOV AH,9H
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H

	LEA DX,OFFSET IN_PWD
	MOV AH,10
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21
	LEA BX,OFFSET IN_PWD

	MOV DI,OFFSET IN_PWD ;指向输入的地址
	ADD DI,2
	MOV SI,OFFSET BPASS ;指向原来匹配密码的地址
	SUB SI,1
	SUB DI,1
	MOV CX,0

LOPB:
	ADD DI,1
	ADD SI,1
	ADD CX,1
	CMP CX,7H 
	JE SUCCESSFUL ;如果密码匹配成功，则输出成功信息
	MOV BL, BYTE PTR [SI] ;BL中存入真实密码
	CMP BL,BYTE PTR [DI] ;输入密码和真是密码比较
	JE LOPB ;若为真比较下一位
	JNE INPUTFAIL;若不为真则提示失败

INPUTFAIL:
	MOV AUTH,0
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA DX, LOGFAIL
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP INNAME

SUCCESSFUL:
	MOV AUTH,1
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA DX,LOGINREMIND ;若成功则输出成功的提示信息
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP LOOKUP

LOOKUP:
	MOV DX,OFFSET ITEMNAME ;提示输入要查找的货物
	MOV AH,9H
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA DX,IN_ITEM ;用户输入要查找的货物 
	MOV AH,10
	INT 21H
	MOV BL,IN_ITEM+1
	MOV BH,0
	MOV BYTE PTR IN_ITEM+2[BX],'$' ;在输入串尾部补上'$'
	MOV DL,0AH
	MOV AH,2H
	INT 21H

	MOV SI,OFFSET IN_ITEM
	CMP BYTE PTR [SI+2],0DH ;判断是否为回车，若是则回到输入用户名
	JE INNAME
        	MOV CX,N ;设定循环的总数
	MOV DX,OFFSET GA1


NEXT:
	MOV DI,OFFSET IN_ITEM
	MOV BL,BYTE PTR [DI+1]
	ADD BL,1
	ADD DI,2
	MOV SI,DX
	SUB SI,1
	SUB DI,1
	
LOPC:
	ADD DI,1
	ADD SI,1
	SUB BL,1
	CMP BL,0 
	JE ITEMC
	MOV AL,BYTE PTR [SI]
	CMP AL,BYTE PTR [DI] ;逐个判断货物名称是否相符
	JE LOPC
	DEC CX
	ADD DX,21
	CMP CX,0
	JNE NEXT ;若货物没有循环完，判断下一个货物
	JE FINDFAIL ;若循环完了还没有找到，则查找失败

FINDFAIL:
	LEA DX,NOTITEM ;如果没有找到，输出没有找到的错误消息
	MOV AH,9H
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP LOOKUP ;回到LOOKUP重新输入寻找

ITEMC: ;之前为用户输入货物查找的步骤
	MOV DI,0
	CMP AUTH,1
     JE PRINT
	MOV BX,0
	MOV SP,DX   ;将当前商品的位置存下来
     MOV BP,1 ;设置外层循环计数器，即客户数量
	MOV AX,0
     CALL TIMER ;开始计时
	JMP LOPD

LOPD:
	CMP BP,M ;比较当前循环次数是否到M次
	JGE FINISHCUS ;若完成循环，输出时间并回到功能一
	INC BP ;若不是，执行下一次客户输入
	MOV SI,SP ;将货物首地址传到SI
	MOV AX,0
MOV BX,0
	MOV AX,WORD PTR [SI]+17 ;已经销售数量
	MOV BX,WORD PTR [SI]+15 ;货物总量
	CMP AX,BX 
	JGE INNAME ;如果已经销售数量大于货物总量，回到功能一
	MOV BX,0
	INC AX ;已经销售数量加一
	MOV WORD PTR [SI]+17,AX ;将更新后的销售数量传回数据段
	MOV AX,0
	MOV DI,1 ;内层循环计数器，指示从第一个开始的货物，刷新推荐度
	MOV SI,OFFSET GA1 ;从第一个货物开始更新推荐度
	JMP FINDSUC

FINDSUC:
	;LCMP AUTH,1 ;判断登录状态，若是若已经登陆则显示该商品名称，若不是则计算推荐度
	;JE PRINT
	;MOV SI,DX
	MOV AL,[SI+10] ;折扣 
     	MOV AH,0
     	MOV BX,[SI+13]  ;销售价
     	MUL BX ;销售价乘以折扣
     	MOV BX,10
     	MOV DX,0
    	DIV BX ;销售价乘以折扣除以10，实际售价
    	MOV CX,AX
    	MOV AX,[SI]+11 ;进货价
    	MOV BX,128
    	MUL BX ;进货价乘以128
   	MOV DX,0
   	DIV CX ;进货价乘以128除以销售价
   	MOV TEMP1,AX
   	MOV AX,[SI]+17 ;已售数量
    	MOV BX,64 
     	MUL BX ;已售数量乘以64
     	MOV BX,[SI]+15  ;进货数量
     	MOV DX,0
     	DIV BX ;已售数量乘以64除以进货数量
	ADD AX,TEMP1 ;两部分推荐度相加，存入AX
	CMP DI,0
	JZ GRADE
	CMP DI,N+1 ;比较当前的内层循环次数是否到N，若没到，继续循环
    	JGE LOPD ;如果全部货物的推荐度刷新完，循环下一个客户
	INC DI ;否则下一个更新下一个商品推荐度
	ADD SI,21
	JMP FINDSUC ;计算下一个商品推荐度

FINISHCUS:
     	LEA DX,REMINDED
     	MOV AH,9H
     	INT 21H
     	MOV DL,0AH;换行符
     	MOV AH,2H
     	INT 21H
	MOV AX,1
     	CALL TIMER ;结束计时
	JMP INNAME ;之后为输出等级的步骤


GRADE:
	CMP AX,100
	JGE LEVELA ;大于100输出A
	CMP AX,50
	JGE LEVELB ;大于50输出B
	CMP AX,10
	JGE LEVELC ;大于10输出C
	JMP LEVELF ;其他输出F

LEVELA:
	MOV DL,41H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP ELOP

LEVELB:
	MOV DL,42H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP ELOP

LEVELC:
	MOV DL,43H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP ELOP

LEVELF:
	MOV DL,46H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP ELOP

ELOP: 
	 MOV DL,0AH
                  MOV AH,2H
                  INT 21H
                  MOV AL,0
                  MOV AUTH,AL;将登陆状态改为未登录
                  JMP INNAME

PRINT:
	LEA DX,IN_ITEM+2
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME

;时间计数器(ms),在屏幕上显示程序的执行时间(ms)
;使用方法:
;	   MOV  AX, 0	;表示开始计时
;	   CALL TIMER
;	   ... ...	;需要计时的程序
;	   MOV  AX, 1	
;	   CALL TIMER	;终止计时并显示计时结果(ms)
;输出: 改变了AX和状态寄存器
TIMER	PROC
	PUSH  DX
	PUSH  CX
	PUSH  BX
	MOV   BX, AX
	MOV   AH, 2CH
	INT   21H	     ;CH=hour(0-23),CL=minute(0-59),DH=second(0-59),DL=centisecond(0-100)
	MOV   AL, DH
	MOV   AH, 0
	IMUL  AX,AX,1000
	MOV   DH, 0
	IMUL  DX,DX,10
	ADD   AX, DX
	CMP   BX, 0
	JNZ   _T1
	MOV   CS:_TS, AX
_T0:	POP   BX
	POP   CX
	POP   DX
	RET
_T1:	SUB   AX, CS:_TS
	JNC   _T2
	ADD   AX, 60000
_T2:	MOV   CX, 0
	MOV   BX, 10
_T3:	MOV   DX, 0
	DIV   BX
	PUSH  DX
	INC   CX
	CMP   AX, 0
	JNZ   _T3
	MOV   BX, 0
_T4:	POP   AX
	ADD   AL, '0'
	MOV   CS:_TMSG[BX], AL
	INC   BX
	LOOP  _T4
	PUSH  DS
	MOV   CS:_TMSG[BX+0], 0AH
	MOV   CS:_TMSG[BX+1], 0DH
	MOV   CS:_TMSG[BX+2], '$'
	LEA   DX, _TS+2
	PUSH  CS
	POP   DS
	MOV   AH, 9
	INT   21H
	POP   DS
	JMP   _T0
_TS	DW    ?
 	DB    'Time elapsed in ms is '
_TMSG	DB    12 DUP(0)
TIMER   ENDP


EXIT:
	MOV AH,4CH
	INT 21H

CODE ENDS

	END START 