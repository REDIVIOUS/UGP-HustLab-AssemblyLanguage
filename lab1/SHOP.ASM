.386

STACK SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK ENDS 

DATA SEGMENT USE16
	BNAME DB 'WL DING',0,0,0  ;老板姓名（由于我的名字拼音超过了10个字节，故名采用缩写）
	BPASS DB '111111' ;密码
	N EQU 30 ;商品数量
	GA1 DB 'PEN',  7 DUP(0), 10 ;商品名称及折扣
      	        DW 35, 56, 70, 25, ? ;推荐度还未计算
	GA2 DB 'BOOK', 6 DUP(0), 9 ;商品名称及折扣
         	        DW 12, 30, 25, 5, ? ;推荐度还未计算
        GA3 DB 'TEST1',5 DUP(0), 9
                DW 500,30,25,5,? ;设置比较大的进货量，防溢出测试
        GA4 DB 'TEST2',5 DUP(0), 10
                 DW 0,30,25,0,? ;进货价和已销售量设置为0，看能否正常输出
	GAN DB N-4 DUP('Temp-Value' ,8)
	         DW N-4 DUP(12,30,25,5,?) ;除了几个已经具体定义了的商品信息以外，其他商品信息暂时假定为一样的

	AUTH DB 0
	TEMP1 DW ?
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
	ADD BX,1
	ADD DI,2
	MOV SI,DX
	SUB SI,1
	SUB DI,1
	
LOPC:
	ADD DI,1
	ADD SI,1
	SUB BL,1
	CMP BL,0 
	JE FINDSUC
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

FINDSUC:
	CMP AUTH,1 ;判断登录状态，若是若已经登陆则显示该商品名称，若不是则计算推荐度
	JE PRINT
	MOV SI,DX
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
	JMP INNAME

LEVELB:
	MOV DL,42H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME	

LEVELC:
	MOV DL,43H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME

LEVELF:
	MOV DL,46H
	MOV AH,2
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME

PRINT:
	LEA DX,IN_ITEM+2
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME

EXIT:
	MOV AH,4CH
	INT 21H

CODE ENDS

	END START 
