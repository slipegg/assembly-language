EXTRN	DISPBX:FAR
MYDATA SEGMENT
DATA  	DW      1234H,5678H,9D4CH,0D7H,0,-1,7D2AH,8A0EH,10F5H,645DH,9H,8000H	;加入了后面2个数据，这时，8000H是最小的
N   	EQU     $-DATA
TIP		DB		'The smallest even number is:',0AH,0DH,'$'	;提示
MYDATA ENDS

CODE	SEGMENT
		ASSUME	CS:CODE,DS:MYDATA


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
		JLE LO		;之前最小值更小，就跳到后面，准备下一个循环
		MOV BX,[SI]	;不然就将最小值改为当前数值

LO:		INC SI		;SI+2，转到下一个数值
		INC SI		
		LOOP COUNT	;循环

		MOV DX,OFFSET TIP	;显示提示
		MOV AH,09H
		INT 21H

		CALL DISPBX	;显示BX
;结束
		RET
MAIN	ENDP

CODE	ENDS
		END	MAIN