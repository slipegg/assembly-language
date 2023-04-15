MYDATA SEGMENT
DATA  	DW      1234H,5678H,9D4CH,0D7H,0,-1,7D2AH,8A0EH,10F5H,645DH,9H,8000H	;加入了后面2个数据，这时，8000H是最小的
N   	EQU     $-DATA
TIP		DB		'The smallest even number is:',0AH,0DH,'$'	;提示
MYDATA ENDS

CODE	SEGMENT
		ASSUME	CS:CODE,DS:MYDATA

WRITE	PROC		;子程序
;WRITE子程序说明
;功能：将BX中的数据以16进制的形式显现在屏幕上
;占用寄存器：AX，BX，CX，DX
;入口参数：BX
;出口参数：无
;示例：BX中为1234H，输出到屏幕上的是1234H
		PUSH	AX	;保护之前的参数，放入栈中
		PUSH	BX
		PUSH	CX
		PUSH	DX
		MOV	CX,4	;循环4次
		MOV	AX,BX	;将要输出的内容抓到AX
		MOV	BX,16	;BX是16，用来当除数
STAR:	MOV DX,0	;DX清零，方便存放余数
		IDIV	BX	;除以16
		PUSH	DX	;将余数储存起来
		LOOP STAR	;循环除

		MOV	CX,4	;设置循环次数
PRINT:	POP	AX		;得到之前的余数
		CMP AX,9H	;和9比较
		JL	NUMBER	;小于就不用再加7，变成字母
		ADD AX,7H
NUMBER:	ADD AX,30H	;加30，转化为字符
		MOV DL,AL	;输出这一个字符
		MOV AH,02
		INT 21H
		LOOP PRINT	;重复输出
		MOV DL,'H'	;最后加上一个H
		MOV AH,02
		INT 21H

		POP	DX	;从栈中取出，还原现场
		POP CX
		POP BX
		POP AX
		RET
WRITE	ENDP;		;子程序结束


MAIN	PROC	FAR	;采用main的方法调用主程序
		PUSH	DS
		MOV	AX,0
		PUSH	AX

		MOV	AX,MYDATA;装填DS
		MOV	DS,AX

		MOV	SI,OFFSET DATA;SI为DATA的地址
		MOV	CX,N	;将N除以2，获得循环的次数放到CX
		SHR	CX,1
		MOV BX,[SI]	;最小值用BX记录，先放入第一个数
		INC	SI		;第一个数被用掉后，相应的改变
		INC SI
		DEC CX		;CX-1	


COUNT:	TEST	WORD PTR [SI],1	;判断是不是偶数
		JNZ	LO		;不是偶数直接跳到最后，进行下一个循环
		CMP	BX,[SI]	;比较当前的数值，和之前的最小值
		JLE LO		;之前最小值任更小，就跳到后面，准备下一个循环
		MOV BX,[SI]	;不然就将最小值改为当前数值

LO:		INC SI		;SI+2，转到下一个数值
		INC SI		
		LOOP COUNT	;循环

		MOV DX,OFFSET TIP	;显示提示
		MOV AH,09H
		INT 21H

		CALL WRITE	;显示BX
;结束
		RET
MAIN	ENDP

CODE	ENDS
		END	MAIN