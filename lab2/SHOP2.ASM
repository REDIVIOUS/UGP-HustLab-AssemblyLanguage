.386

STACK SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK ENDS 

DATA SEGMENT USE16
	BNAME DB 'WL DING',0,0,0  ;�ϰ������������ҵ�����ƴ��������10���ֽڣ�����������д��
	BPASS DB '111111' ;����
	N EQU 30 ;��Ʒ����
	M EQU 2000
	GA1 DB 'PEN',  7 DUP(0), 10 ;��Ʒ���Ƽ��ۿ�
      	        DW 35, 56, 70, 25, ? ;�Ƽ��Ȼ�δ����
	GA2 DB 'BOOK', 6 DUP(0), 9 ;��Ʒ���Ƽ��ۿ�
         	        DW 12, 30, 25, 5, ? ;�Ƽ��Ȼ�δ����
        GA3 DB 'TEST1',5 DUP(0), 9
                DW 500,30,25,5,? ;���ñȽϴ�Ľ����������������
        GA4 DB 'TEST2',5 DUP(0), 10
                 DW 0,30,25,0,? ;�����ۺ�������������Ϊ0�����ܷ��������
	GAN DB N-5 DUP('Temp-Value' ,8)
	         DW N-5 DUP(12,30,25,5,?) ;���˼����Ѿ����嶨���˵���Ʒ��Ϣ���⣬������Ʒ��Ϣ��ʱ�ٶ�Ϊһ����
	GAB DB 'BAG',7 DUP(0), 10 ;BAG�������ۿ�
	        DW 12,30,2000,0,? ;�����ۣ����ۼۣ���������������������������


	AUTH DB 0
	TEMP1 DW ?
	ADRESST DW ?;�ݴ��ַ
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
	DATA ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA
START: 
	MOV AX,DATA
	MOV DS,AX ;�������ݶμĴ�����ֵ

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

	CMP BYTE PTR [BX+2],0DH ;����ǻس�����ֱ�Ӳ�ѯ
	JE LOOKUP
	CMP BYTE PTR [BX+2],'Q' ;�����q���˳�
	JE EXIT

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
	JNE INPUTFAIL ;�粻Ϊ�棬����ʾʧ��
	

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
	CMP CX,7H 
	JE SUCCESSFUL ;�������ƥ��ɹ���������ɹ���Ϣ
	MOV BL, BYTE PTR [SI] ;BL�д�����ʵ����
	CMP BL,BYTE PTR [DI] ;�����������������Ƚ�
	JE LOPB ;��Ϊ��Ƚ���һλ
	JNE INPUTFAIL;����Ϊ������ʾʧ��

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
	LEA DX,LOGINREMIND ;���ɹ�������ɹ�����ʾ��Ϣ
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2H
	INT 21H
	JMP LOOKUP

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

ITEMC:
	MOV DI,0
	CMP AUTH,1
                 JE PRINT
	MOV BX,0
	MOV SP,DX   ;����ǰ��Ʒ��λ�ô�����
       	MOV BP,1 ;�������ѭ�������������ͻ�����
	MOV AX,0
                 CALL TIMER ;��ʼ��ʱ

LOPD:
	CMP BP,M ;�Ƚϵ�ǰѭ�������Ƿ�M��
	JGE FINISHCUS ;�����ѭ�������ʱ�䲢�ص�����һ
	INC BP ;�����ǣ�ִ����һ�οͻ�����
	MOV SI,SP ;�������׵�ַ����SI
	MOV AX,WORD PTR [SI]+17 ;�Ѿ���������
	MOV BX,WORD PTR [SI]+15 ;��������
	CMP AX,BX 
	JGE INNAME ;����Ѿ������������ڻ����������ص�����һ
	INC AX ;�Ѿ�����������һ
	MOV WORD PTR [SI]+17,AX ;�����º�����������������ݶ�
	MOV DI,1 ;�ڲ�ѭ����������ָʾ�ӵ�һ����ʼ�Ļ��ˢ���Ƽ���
	MOV SI,OFFSET GA1 ;�ӵ�һ�����￪ʼ�����Ƽ���

FINDSUC:
	MOV AL,[SI+10] ;�ۿ� 
        	MOV AH,0
        	MOV BX,[SI+13]  ;���ۼ�
        	MUL BX ;���ۼ۳����ۿ�
        	MOV BX,10
        	MOV DX,0
        	DIV BX ;���ۼ۳����ۿ۳���10��ʵ���ۼ�
        	MOV CX,AX
        	MOV AX,[SI]+11 ;������
	SAL AX,7 ;AX����128
        	MOV DX,0
        	DIV CX ;�����۳���128�������ۼ�
        	MOV TEMP1,AX
        	MOV AX,[SI]+17 ;��������
	SAL AX,6 ;AX����64
        	MOV BX,[SI]+15  ;��������
        	MOV DX,0
        	DIV BX ;������������64���Խ�������
	ADD AX,TEMP1 ;�������Ƽ�����ӣ�����AX
	CMP DI,0
	JZ GRADE
	CMP DI,N+1 ;�Ƚϵ�ǰ���ڲ�ѭ�������Ƿ�N����û��������ѭ��
                 JGE LOPD ;���ȫ��������Ƽ���ˢ���꣬ѭ����һ���ͻ�
	INC DI ;������һ��������һ����Ʒ�Ƽ���
	ADD SI,21
	JMP FINDSUC ;������һ����Ʒ�Ƽ���

FINISHCUS:
               LEA DX,REMINDED
               MOV AH,9H
               INT 21H
               MOV DL,0AH;���з�
               MOV AH,2H
               INT 21H
              MOV AX,1
        	CALL TIMER ;������ʱ
	JMP INNAME

GRADE:
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
                  MOV AUTH,AL;����½״̬��Ϊδ��¼
                  JMP INNAME

PRINT:
	LEA DX,IN_ITEM+2
	MOV AH,9
	INT 21H
	MOV DL,0AH
	MOV AH,2
	INT 21H
	JMP INNAME

;ʱ�������(ms),����Ļ����ʾ�����ִ��ʱ��(ms)
;ʹ�÷���:
;	   MOV  AX, 0	;��ʾ��ʼ��ʱ
;	   CALL TIMER
;	   ... ...	;��Ҫ��ʱ�ĳ���
;	   MOV  AX, 1	
;	   CALL TIMER	;��ֹ��ʱ����ʾ��ʱ���(ms)
;���: �ı���AX��״̬�Ĵ���
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