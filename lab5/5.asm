.386
.model flat,stdcall
option casemap:none

WinMain proto:dword,:dword,:dword,:dword
WndProc proto:dword,:dword,:dword,:dword
Display proto:dword
CALCREFER proto
TRANS2 proto

; include 5.inc
; include user32.inc
; include gdi32.inc
; include kernel32.inc
; include shell32.inc
; include windows.inc

; includelib user32.lib
; includelib gdi32.lib
; includelib kernel32.lib
; includelib shell32.lib

include \masm32\task5\5.inc
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\shell32.inc
      
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\shell32.lib

item struct
    iname db 10 dup(0) 
    discount db 0
    input dw 0
    selling dw 0
    initem dw 0
    sellyet dw 0
    reco dw 0
item ends

.data
    out_name db 'item_name',0
    out_discount db 'discount',0
    out_inprice db 'in_price',0
    out_sellprice db 'sell_price',0
    out_initem db 'in_item',0
    out_sell db 'sell_item',0
    out_rec db 'recommendation',0
    out_about db 'ACM1701 WL DING',0 ;about的内容
    windowtype db 'TryWinClass',0 ;窗口类名
    windowname db 'shop of dwl',0 ;窗口抬头
    commodity item<'PEN',10,10,25,120,80,?> ;折扣，进货价，售货价，进货总数，已售数量，推荐度
    item<'BOOK',9,12,30,25,5,?>
    item<'NOTE',8,30,50,40,20,?> 
    item<'PENCIL',10,5,8,10,5,?>
    BUF1 db 10 dup(0)
    TEMP1 dd 0
    TEMP2 dd 0
    TEMP3 dd 0
    N equ 5
    hInstance dd 0
    CommandLine dd 0
    menuname db 'MyMenu',0
    


.code
start:
    invoke GetModuleHandle,NULL;获得并保存本程序的句柄
    mov hInstance,eax
    invoke GetCommandLine
    mov CommandLine,eax
    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT;调用窗口主程序
    invoke ExitProcess,eax;退出本程序，返回Windows

;窗口主程序
WinMain proc hInst:dword,hPreInst:dword,CmdLine:dword,CmdShow:dword
    local wc:WNDCLASSEX;创建主窗口时所需要的信息由该结构说明
    local msg:MSG;消息结构变量用于存放获取的信息
    local hWnd:HWND;存放窗口句柄

;给WNDCLASSEX结构变量wc的各字段赋值
    mov wc.cbSize,SIZEOF WNDCLASSEX;WNDCLASSEX结构类型的字节数
    mov wc.style,CS_HREDRAW or CS_VREDRAW;窗口风格
    mov wc.lpfnWndProc,OFFSET WndProc;本窗口过程的入口地址
    mov wc.cbClsExtra,NULL;不用自定义数据则不需要OS预留空间，置NULL
    mov wc.cbWndExtra,NULL;同上
    push hInst;本应用程序句柄->wc.hInstance
    pop wc.hInstance
    mov wc.hbrBackground,COLOR_WINDOW+1;窗口的背景设为白色
    mov wc.lpszMenuName,OFFSET menuname;菜单名
    mov wc.lpszClassName,OFFSET windowtype;窗口类名
    invoke LoadIcon,NULL,IDI_APPLICATION;装入系统默认图标
    mov wc.hIcon,eax;保存图标的句柄
    mov wc.hIconSm,0;窗口不带小图标
    invoke LoadCursor,NULL,IDC_ARROW;装入系统默认的光标
    mov wc.hCursor,eax;保存光标的句柄
    invoke RegisterClassEx,ADDR wc;注册窗口类
    invoke CreateWindowEx,NULL,ADDR windowtype,;建立windowtype类窗口
    ADDR windowname,;窗口标题地址
    WS_OVERLAPPEDWINDOW+WS_VISIBLE,;创建可显示的窗口
    CW_USEDEFAULT,CW_USEDEFAULT,;窗口左上角坐标默认值
    CW_USEDEFAULT,CW_USEDEFAULT,;窗口宽度，高度默认值
    NULL,NULL,;无父窗口，无菜单
    hInst,NULL;本程序句柄，无参数传递给窗口
    mov hWnd,eax;保存窗口的句柄
    invoke ShowWindow,hWnd,SW_SHOWNORMAL
    invoke UpdateWindow,hWnd
    StartLoop:;进入消息循环
    invoke GetMessage,ADDR msg,NULL,0,0;从windows获取消息
    cmp eax,0;如果eax不为0，则转换并分发消息
    je ExitLoop;如果eax为0，则转exitloop
    invoke TranslateMessage,ADDR msg;从键盘接受按键并转换为消息
    invoke DispatchMessage,ADDR msg;将消息分发到窗口的消息处理程序
    jmp StartLoop;再循环获取消息
ExitLoop:
    mov eax,msg.wParam;设置返回码
    ret
WinMain endp

;窗口消息处理程序
WndProc proc hWnd:dword,uMsg:dword,wParam:dword,lParam:dword
local hdc:HDC;存放设备上下文句柄
.if uMsg==WM_DESTROY;收到的是销毁窗口信息
    invoke PostQuitMessage,NULL;发出退出消息
.elseif uMsg==WM_KEYDOWN
.if wParam==VK_F1
invoke MessageBox,hWnd,ADDR out_about,ADDR windowname,0
.endif
.elseif uMsg==WM_COMMAND
.if wParam==IDM_File_Exit
invoke SendMessage,hWnd,WM_CLOSE,0,0
.elseif wParam==IDM_Action_Recommendation
mov ebx, offset commodity
invoke CALCREFER
mov ebx, offset commodity[1*21]
invoke CALCREFER
mov ebx, offset commodity[2*21] 
invoke CALCREFER
mov ebx, offset commodity[3*21]
invoke CALCREFER
.elseif wParam==IDM_Action_List
invoke Display,hWnd
.elseif wParam==IDM_Help_About
invoke MessageBox,hWnd,ADDR out_about,ADDR windowname,0
.endif
.else
invoke DefWindowProc,hWnd,uMsg,wParam,lParam;不是本程序要处理的消息，作其他缺省处理
ret
.endif
mov eax,0
ret
WndProc endp

;输出信息函数
Display proc hWnd:dword
x_axis equ 8
y_axis equ 10
x_jmp equ 100
y_jmp equ 30
size_of equ sizeof(item)
local hdc:HDC
invoke GetDC,hWnd
mov hdc,eax

invoke TextOut,hdc,x_axis+0*x_jmp,y_axis+0*y_jmp,OFFSET out_name,9
invoke TextOut,hdc,x_axis+1*x_jmp,y_axis+0*y_jmp,OFFSET out_discount,8
invoke TextOut,hdc,x_axis+2*x_jmp,y_axis+0*y_jmp,OFFSET out_inprice,8
invoke TextOut,hdc,x_axis+3*x_jmp,y_axis+0*y_jmp,OFFSET out_sellprice,10
invoke TextOut,hdc,x_axis+4*x_jmp,y_axis+0*y_jmp,OFFSET out_initem,7
invoke TextOut,hdc,x_axis+5*x_jmp,y_axis+0*y_jmp,OFFSET out_sell,9
invoke TextOut,hdc,x_axis+6*x_jmp,y_axis+0*y_jmp,OFFSET out_rec,14

invoke TextOut,hdc,x_axis+0*x_jmp,y_axis+1*y_jmp,OFFSET commodity[0*21].iname,3
mov al,commodity[0*size_of].discount
mov ah,0
invoke TRANS2
invoke TextOut,hdc,x_axis+1*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2
mov ax,commodity[0*size_of].input
invoke TRANS2
invoke TextOut,hdc,x_axis+2*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2
mov ax,commodity[0*size_of].selling
invoke TRANS2
invoke TextOut,hdc,x_axis+3*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2
mov ax,commodity[0*size_of].initem
invoke TRANS2
invoke TextOut,hdc,x_axis+4*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2
mov ax,commodity[0*size_of].sellyet
invoke TRANS2
invoke TextOut,hdc,x_axis+5*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2
mov ax,commodity[0*size_of].reco
invoke TRANS2
invoke TextOut,hdc,x_axis+6*x_jmp,y_axis+1*y_jmp,OFFSET BUF1,2

invoke TextOut,hdc,x_axis+0*x_jmp,y_axis+2*y_jmp,OFFSET commodity[1*21].iname,4
mov al,commodity[1*size_of].discount
mov ah,0
invoke TRANS2
invoke TextOut,hdc,x_axis+1*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,1
mov ax,commodity[1*size_of].input
invoke TRANS2
invoke TextOut,hdc,x_axis+2*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,2
mov ax,commodity[1*size_of].selling
invoke TRANS2
invoke TextOut,hdc,x_axis+3*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,2
mov ax,commodity[1*size_of].initem
invoke TRANS2
invoke TextOut,hdc,x_axis+4*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,2
mov ax,commodity[1*size_of].sellyet
invoke TRANS2
invoke TextOut,hdc,x_axis+5*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,2
mov ax,commodity[1*size_of].reco
invoke TRANS2
invoke TextOut,hdc,x_axis+6*x_jmp,y_axis+2*y_jmp,OFFSET BUF1,2

invoke TextOut,hdc,x_axis+0*x_jmp,y_axis+3*y_jmp,OFFSET commodity[2*21].iname,4
mov al,commodity[2*size_of].discount
mov ah,0
invoke TRANS2
invoke TextOut,hdc,x_axis+1*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,1
mov ax,commodity[2*size_of].input
invoke TRANS2
invoke TextOut,hdc,x_axis+2*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,2
mov ax,commodity[2*size_of].selling
invoke TRANS2
invoke TextOut,hdc,x_axis+3*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,2
mov ax,commodity[2*size_of].initem
invoke TRANS2
invoke TextOut,hdc,x_axis+4*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,2
mov ax,commodity[2*size_of].sellyet
invoke TRANS2
invoke TextOut,hdc,x_axis+5*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,2
mov ax,commodity[2*size_of].reco
invoke TRANS2
invoke TextOut,hdc,x_axis+6*x_jmp,y_axis+3*y_jmp,OFFSET BUF1,2

invoke TextOut,hdc,x_axis+0*x_jmp,y_axis+4*y_jmp,OFFSET commodity[3*21].iname,5
mov al,commodity[3*size_of].discount
mov ah,0
invoke TRANS2
invoke TextOut,hdc,x_axis+1*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
mov ax,commodity[3*size_of].input
invoke TRANS2
invoke TextOut,hdc,x_axis+2*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
mov ax,commodity[3*size_of].selling
invoke TRANS2
invoke TextOut,hdc,x_axis+3*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
mov ax,commodity[3*size_of].initem
invoke TRANS2
invoke TextOut,hdc,x_axis+4*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
mov ax,commodity[3*size_of].sellyet
invoke TRANS2
invoke TextOut,hdc,x_axis+5*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
mov ax,commodity[3*size_of].reco
invoke TRANS2
invoke TextOut,hdc,x_axis+6*x_jmp,y_axis+4*y_jmp,OFFSET BUF1,2
ret
Display endp

; 计算推荐度：入口参数ebx存放首地址
CALCREFER PROC USES EAX EBX ECX EDX EDI ESI
    mov esi, ebx
    MOV AX, [esi+17]
    CMP AX, [esi+15]
    JNL ENDCALC
    ; 推荐度 = (进货价*(2*进货数量)+已售数量*实际销售价格)*128/实际销售价格*2*进货数量
    ; 计算进货价*进货数量*2
    MOVZX EAX, word ptr [esi+15]
    SHL EAX, 1
    MOVZX ECX, word ptr [esi+11]
    MUL ECX
    MOV TEMP1,EAX
    ; 计算实际销售价格
    MOVZX EAX, byte ptr [esi+10]
    MOV BX, [esi+13]
    MOVZX EDX, BX
    MUL EDX
    MOV EBX, 10
    XOR EDX, EDX
    DIV EBX
    MOV TEMP2,EAX
    ; 计算分母,实际销售价格*2*进货数量
    MOVZX EBX,word ptr [esi+15]
    MUL EBX
    SHL EAX,1
    MOV TEMP3,EAX
    ; 计算已售数量*实际售价
    MOVZX EBX,word ptr [esi+17]
    MOV EAX,TEMP2
    MUL EBX

    ;两部分加法
    ADD EAX,TEMP1
    ; 乘以128
    SHL EAX,7
    ;除法
    MOV EBX,TEMP3
    XOR EDX,EDX
    DIV EBX
    ; 存放推荐度
    MOV [esi+19], AX
ENDCALC:
    RET
CALCREFER ENDP

;待转化数放在AX中，输出在BUF1中
TRANS2 PROC
    PUSH EBX     ;保护现场
    PUSH ECX
    PUSH EDX
    PUSH ESI
    MOV BX,10 ;等会BX作为被除数（因为是要转化成10进制）
    MOV ECX,0  ;计数器清零
    LEA ESI,BUF1    ;将BUF1的地址给SI，等会通过变址寻址把相应的数据放在BUF1中
    OR  AX,AX     ;AX为正数是直接进入后面的转换
    JNS LOP1
    NEG AX          ;AX为负数时先转变成正数
    MOV BYTE PTR [ESI],'-'   ;此时应该先存放一个负号
    INC ESI
LOP1:
    XOR DX , DX   ;通过异或将DX清零，这种清零方式应该更快一些（可以试着验证一下）
    DIV BX         ;除10取余，二进制转化为10进制的正常操作
    PUSH DX        ;将余数进栈（因为顺序是反的，第一个余数应该是转换后的进制的最后一位，此时进行一次进出栈转换顺序）
    INC CX
    OR  AX , AX     ;AX为0时跳出循环
    JNZ LOP1
LOP2:   
    POP AX         ;将之前的余数出栈
    ADD AL , 30H   ;将余数加30H变成相应的ASCII码
    MOV [ESI],AL     ;将余数出栈
    INC ESI
    LOOP LOP2   ;计数器减一并且判断是否跳出循环
    MOV BYTE PTR [ESI],' '   ;在存放空间的最后加入一个字符串结束符，方便等会字符串的输出
    POP ESI      ;保护现场
    POP EDX
    POP ECX
    POP EBX
    RET
TRANS2 ENDP

end start
