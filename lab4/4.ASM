.386

STACK SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK ENDS 

DATA SEGMENT USE16
	BNAME DB 'WL DING',0,0,0  ;�ϰ�����
	BPASS DB ('A'-29H)*3,('B'-29H)*3,('C'-29H)*3 ;����
	N EQU 30 ;��Ʒ����
	GA1 DB 'PEN',  7 DUP(0), 10 ;��Ʒ���Ƽ��ۿ�
      	        DW 35 XOR 'D', 56, 70, 25, ? ;�Ƽ��Ȼ�δ����
	GA2 DB 'BOOK', 6 DUP(0), 9 ;��Ʒ���Ƽ��ۿ�
         	        DW 12 XOR 'D', 30, 25, 5, ? ;�Ƽ��Ȼ�δ����
        	GA3 DB 'PENCIL',4 DUP(0), 9
                	        DW 20 XOR 'D',30,25,5,? ;���ñȽϴ�Ľ����������������
	E1 DW OVER
	P2 DW PASSWORD
        CURRENT DB 0 
	OLDINT1 DW 0,0 ;1���жϵ�ԭ�ж�ʸ���������ж�ʸ���������٣�
        OLDINT3 DW 0,0 ;3���жϵ�ԭ�ж�ʸ��
        PASSTIME DB 3 ;�趨��������������
	

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
	MOV DS,AX ;�������ݶμĴ�����ֵ

	xor  ax,ax                  ;�ӹܵ������жϣ��ж�ʸ����������
       	mov  es,ax
       	mov  ax,es:[1*4]            ;����ԭ1�ź�3���ж�ʸ��
       	mov  OLDINT1,ax
       	mov  ax,es:[1*4+2]
       	mov  OLDINT1+2,ax
       	mov  ax,es:[3*4]
       	mov  OLDINT3,ax
       	mov  ax,es:[3*4+2]
       	mov  OLDINT3+2,ax
      	cli                           ;�����µ��ж�ʸ��
       	mov  ax,OFFSET NEWINT
       	mov  es:[1*4],ax
       	mov  es:[1*4+2],cs
       	mov  es:[3*4],ax
       	mov  es:[3*4+2],cs
       	sti

	JMP INNAME


INNAME:
	MOV AUTH,0
	LEA DX,PUTNAME ;��ʾ�û���������
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
	
	cli ;��ʱ������
	mov ah,2ch
	int 21h
	push dx ;�����ȡ����Ͱٷ���

	CMP BYTE PTR [BX+2],0DH ;����ǻس�����ֱ�Ӳ�ѯ
	JE LOOKUP
	CMP BYTE PTR [BX+2],'Q' ;�����q���˳�
	JE EXIT

	mov ah,2ch ;��ȡ�ڶ�������ٷ���
	int 21h
	sti
	cmp dx,[esp] ;��ʱ�Ƿ���ͬ
	pop dx
	jz OK1 ;�����ʱ��ͬ��ͨ����η�����
	jmp OVER ;�����ʱ��ͬ������ת��OVER


OK1:
	cli  ;��ջ��鷴����
	push p2 ;PASSWORD�ĵ�ַѹջ

	MOV DI, OFFSET IN_NAME ;ָ������ĵ�ַ
	ADD DI,2
	MOV SI,OFFSET BNAME ;ָ��ԭ��ƥ�����ֵĵ�ַ
	SUB SI,1
	SUB DI,1
	MOV CX,0

LOPA:
	ADD DI,1
	ADD SI,1
	ADD CX,1
	CMP CX,8H
	JE PASSWORD 
	MOV BL,BYTE PTR [SI] ;��BL�д�����ʵ������
	CMP BL,BYTE PTR [DI] ;������ֵ������ʵ�������Ƚ�
	JE LOPA ;���Ϊ�棬����ִ����һ���Ƚ�
	JNE INPUTFAIL1 ;�粻Ϊ�棬����ʾʧ��

	pop ax
	mov bx,[esp-2] ;��ջ���ĵ�ַ��PASSWORD�ĵ�ַ��ȡ��
	sti
	jmp bx ;��������٣��򲻻�ת�Ƶ�PASSWORD
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
	LEA DX,PUTPASSWORD ;��ʾ�û���������
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

	MOV DI,OFFSET IN_PWD ;ָ������ĵ�ַ
	ADD DI,2
	MOV SI,OFFSET BPASS ;ָ��ԭ��ƥ������ĵ�ַ
	SUB SI,1
	SUB DI,1
	MOV CX,0

LOPB:
	ADD DI,1
	ADD SI,1
	ADD CX,1
        	CMP CX,4H 
	JE SUCCESSFUL ;�������ƥ��ɹ���������ɹ���Ϣ
	MOV BL, BYTE PTR [DI] ;�����û�����

	sub bl,29h ;���ս��ܹ���������ʵ����
	mov CURRENT,bl
	add bl,CURRENT
	add bl,CURRENT 

	CMP BL,BYTE PTR [SI] ;�����������������Ƚ�
	JE LOPB ;��Ϊ��Ƚ���һλ
	JNE INPUTFAIL2;����Ϊ������ʾʧ��

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
	
	dec PASSTIME       ;�ж�������������û�����������Ƿ�ﵽ����
	cmp PASSTIME,0  ;���������β���ȷ���˳�����
	JE LOOKUP
	cmp PASSTIME,1
	je one
	cmp PASSTIME,2
	je two
one:
        	lea dx,offset ONETIME ;��ֻ���һ�λ������Σ�����ʾʣ���������
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
	LEA DX,LOGINREMIND ;���ɹ�������ɹ�����ʾ��Ϣ
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP LOOKUP

IFPASS:
	mov bx,es:[1*4] ;����ж�ʸ�����Ƿ񱻵��Թ�����ֹ�޸Ļ��߻ָ�
	Inc bx
	jmp bx ;��������޸ģ�������ת��TESTINT������������LOOKUP����������������ת
	db 'now,you see.'

LOOKUP:
	MOV DX,OFFSET ITEMNAME ;��ʾ����Ҫ���ҵĻ���
	MOV AH,9H
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	LEA DX,IN_ITEM ;�û�����Ҫ���ҵĻ��� 
	MOV AH,10
	INT 21H
	MOV BL,IN_ITEM+1
	MOV BH,0
	MOV BYTE PTR IN_ITEM+2[BX],'$' ;�����봮β������'$'
	MOV DL,0AH
	MOV AH,2H
	INT 21H

	MOV SI,OFFSET IN_ITEM
	CMP BYTE PTR [SI+2],0DH ;�ж��Ƿ�Ϊ�س���������ص������û���
	JE INNAME
        	MOV CX,N ;�趨ѭ��������
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
	CMP AL,BYTE PTR [DI] ;����жϻ��������Ƿ����
	JE LOPC
	DEC CX
	ADD DX,21
	CMP CX,0
	JNE NEXT ;������û��ѭ���꣬�ж���һ������
	JE FINDFAIL ;��ѭ�����˻�û���ҵ��������ʧ��

FINDFAIL:
	LEA DX,NOTITEM ;���û���ҵ������û���ҵ��Ĵ�����Ϣ
	MOV AH,9H
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP LOOKUP ;�ص�LOOKUP��������Ѱ��

FINDSUC:
	CMP AUTH,1 ;�жϵ�¼״̬���������Ѿ���½����ʾ����Ʒ���ƣ�������������Ƽ���
	JE PRINT
	MOV SI,DX
	MOV AL,[SI+10] ;�ۿ� 
        	MOV AH,0
        	MOV BX,[SI+13]  ;���ۼ�

	xor bx,'D' ;���ܵõ���ʵ��ֵ

        	MUL BX ;���ۼ۳����ۿ�
        	MOV BX,10
        	MOV DX,0
        	DIV BX ;���ۼ۳����ۿ۳���10��ʵ���ۼ�
        	MOV CX,AX
        	MOV AX,[SI]+11 ;������
        	MOV BX,128
        	MUL BX ;�����۳���128
        	MOV DX,0
        	DIV CX ;�����۳���128�������ۼ�
        	MOV TEMP1,AX
        	MOV AX,[SI]+17 ;��������
        	MOV BX,64 
        	MUL BX ;������������64
        	MOV BX,[SI]+15  ;��������
        	MOV DX,0
        	DIV BX ;������������64���Խ�������
	ADD AX,TEMP1 ;�������Ƽ�����ӣ�����AX
	CMP AX,100
	JGE LEVELA ;����100���A
	CMP AX,50
	JGE LEVELB ;����50���B
	CMP AX,10
	JGE LEVELC ;����10���C
	JMP LEVELF ;�������F

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
	cli                           ;��ԭ�ж�ʸ��
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