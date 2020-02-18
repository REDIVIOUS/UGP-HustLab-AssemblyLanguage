.386

STACK SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK ENDS 

DATA SEGMENT USE16
	BNAME DB 'WL DING',0,0,0  ;老板姓名
	BPASS DB ('A'-29H)*3,('B'-29H)*3,('C'-29H)*3 ;密码
	N EQU 30 ;商品数量
	GA1 DB 'PEN',  7 DUP(0), 10 ;商品名称及折扣
      	        DW 35 XOR 'D', 56, 70, 25, ? ;推荐度还未计算
	GA2 DB 'BOOK', 6 DUP(0), 9 ;商品名称及折扣
         	        DW 12 XOR 'D', 30, 25, 5, ? ;推荐度还未计算
        	GA3 DB 'PENCIL',4 DUP(0), 9
                	        DW 20 XOR 'D',30,25,5,? ;设置比较大的进货量，防溢出测试
	E1 DW OVER
	P2 DW PASSWORD
        CURRENT DB 0 
	OLDINT1 DW 0,0 ;1号中断的原中断矢量（用于中断矢量表反跟踪）
        OLDINT3 DW 0,0 ;3号中断的原中断矢量
        PASSTIME DB 3 ;设定最大输入密码次数
	

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
	TWOTIME DB 'YOU HAVE ONLY TWO TIME TO INPUT PASSWORD$'
	ONETIME DB 'YOU HAVE ONE TIME TO INPUT PASSWORD$'
	PUTNAME DB 'PLEASE INPUT THE NAME(INPUT ENTER TO LOOKUP, INPUT Q TO QUIT)$'
	NOTITEM DB 'DO NOT FIND THE ITEM$'
	PUTPASSWORD DB 'PLEASE INPUT THE PASSWORD$'
	ITEMNAME DB 'PLEASE INPUT THE ITEM NAME(INPUT ENTER TO INPUT NAME)$'
	LOGFAIL1 DB 'YOUR USER NAME IS WRONG!$'
	LOGFAIL2 DB 'YOUR PASSWORD IS WRONG!$'
	LOGINREMIND DB 'IDENTIFICATION GOT!$'
	DATA ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA
START: 
	MOV AX,DATA
	MOV DS,AX ;设置数据段寄存器的值

	xor  ax,ax                  ;接管调试用中断，中断矢量表反跟踪
       	mov  es,ax
       	mov  ax,es:[1*4]            ;保存原1号和3号中断矢量
       	mov  OLDINT1,ax
       	mov  ax,es:[1*4+2]
       	mov  OLDINT1+2,ax
       	mov  ax,es:[3*4]
       	mov  OLDINT3,ax
       	mov  ax,es:[3*4+2]
       	mov  OLDINT3+2,ax
      	cli                           ;设置新的中断矢量
       	mov  ax,OFFSET NEWINT
       	mov  es:[1*4],ax
       	mov  es:[1*4+2],cs
       	mov  es:[3*4],ax
       	mov  es:[3*4+2],cs
       	sti

	JMP INNAME


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
	
	cli ;计时反跟踪
	mov ah,2ch
	int 21h
	push dx ;保存获取的秒和百分秒

	CMP BYTE PTR [BX+2],0DH ;如果是回车，则直接查询
	JE LOOKUP
	CMP BYTE PTR [BX+2],'Q' ;如果是q就退出
	JE EXIT

	mov ah,2ch ;获取第二次秒与百分秒
	int 21h
	sti
	cmp dx,[esp] ;计时是否相同
	pop dx
	jz OK1 ;如果计时相同，通过这次反跟踪
	jmp OVER ;如果计时不同，则跳转到OVER


OK1:
	cli  ;堆栈检查反跟踪
	push p2 ;PASSWORD的地址压栈

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
	JNE INPUTFAIL1 ;如不为真，则提示失败

	pop ax
	mov bx,[esp-2] ;把栈顶的地址（PASSWORD的地址）取到
	sti
	jmp bx ;如果被跟踪，则不会转移到PASSWORD
	db 'i do not know!'

INPUTFAIL1:
	MOV AUTH,0
	MOV DL,0AH
	MOV AH,2H
	INT 21H
        LEA DX, LOGFAIL1
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP INNAME

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
        	CMP CX,4H 
	JE SUCCESSFUL ;如果密码匹配成功，则输出成功信息
	MOV BL, BYTE PTR [DI] ;存入用户输入

	sub bl,29h ;按照解密规则生成真实密码
	mov CURRENT,bl
	add bl,CURRENT
	add bl,CURRENT 

	CMP BL,BYTE PTR [SI] ;输入密码和真是密码比较
	JE LOPB ;若为真比较下一位
	JNE INPUTFAIL2;若不为真则提示失败

INPUTFAIL2:
	MOV AUTH,0
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA DX, LOGFAIL2
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	
	dec PASSTIME       ;判断输入密码或者用户名错误次数是否达到三次
	cmp PASSTIME,0  ;若输入三次不正确则退出程序
	JE LOOKUP
	cmp PASSTIME,1
	je one
	cmp PASSTIME,2
	je two
one:
        	lea dx,offset ONETIME ;若只输错一次或者两次，则提示剩下输入次数
	mov ah,9h
	int 21h
	mov dl, 0ah
	mov ah,2h
	int 21h
	jmp PASSWORD
two:
       	lea dx,offset TWOTIME
	mov ah,9h
	int 21h
	mov dl,0ah
        	mov ah,2h
	int 21h
	jmp PASSWORD

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

IFPASS:
	mov bx,es:[1*4] ;检查中断矢量表是否被调试工具阻止修改或者恢复
	Inc bx
	jmp bx ;如果正常修改，这里跳转到TESTINT（即正常进入LOOKUP），否则不能正常跳转
	db 'now,you see.'

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

	xor bx,'D' ;解密得到真实数值

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

NEWINT:  
	iret
TESTINT: 
	jmp LOOKUP

OVER:   
	cli                           ;还原中断矢量
        	mov  ax,OLDINT1
       	 mov  es:[1*4],ax
        	mov  ax,OLDINT1+2
        	mov  es:[1*4+2],ax
        	mov  ax,OLDINT3
        	mov  es:[3*4],ax
        	mov  ax,OLDINT3+2
        	mov  es:[3*4+2],ax
        	sti

EXIT:
	MOV AH,4CH
	INT 21H

CODE ENDS

	END START 
