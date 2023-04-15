DATA SEGMENT
		BUFFER	DB	80,?,80 DUP(?)	;用来存储输入字符
		LETTER	DB	0				;统计字母个数
		NUM		DB	0				;统计数字个数
		OTHER	DB	0				;统计其他字符个数
		TIP0	DB	"Please enter less than 80 characters:"		;设置了一些提示语
		TIP1	DB	"the number of letters is:$"
		TIP2	DB	"the number of number is:$"
		TIP3	DB	"the number of other is:$"
		TIP4	DB	"more than 80,error!"
		HUICE	DB	0AH,0DH,'$'	;调用后相当于回车键
DATA	ENDS

CODE SEGMENT
		ASSUME CS:CODE,DS:DATA
START:	MOV	AX,DATA			;装填DS
		MOV	DS,AX
		
		MOV	DX,OFFSET TIP0	;输出提示
		MOV AH,09H
		INT	21H
		MOV	DX,OFFSET HUICE	;回车
		MOV AH,09H
		INT	21H

		LEA	DX,BUFFER		;输入一些字符串
		MOV	AH,0AH
		INT	21H

		MOV	DX,OFFSET HUICE	;回车
		MOV AH,09H
		INT	21H

		MOV	CL,BUFFER+1		;用CX记录总共要循环多少次
		MOV	CH,0
		LEA	BX,BUFFER+2		;用BX记录需要统计的字符串的地址，这里获得首地址

		CMP	CX,80
		JC	COUNT			;如果输入不大于80，就到COUNT，继续
		MOV	DX,OFFSET TIP4	;不然输出提示，输入过多
		MOV AH,09H
		INT	21H
		JMP THEEND			;直接跳到最后

COUNT:	MOV	AL,[BX]			;将BX所指的字符传到AX
		MOV AH,0
		CMP	AX,30H			;比较AX和30H
		JNC	ONE				;没有溢出，即AX>=30H，就跳到ONE继续判断
		INC	OTHER			;不然就说明是小于30H，是其他字符，对应+1
		JMP	LO				;说明已经判断出来了，直接跳到最后循环部分
;以下的判断方法都差不多，不在赘述
ONE:	CMP	AX,3AH
		JNC	TWO
		INC NUM				;30H~39H，是数字
		JMP LO
TWO:	CMP	AX,41H
		JNC	THREE
		INC OTHER			;3AH~40H，是其他字符
		JMP LO
THREE:	CMP AX,5BH
		JNC	FOUR
		INC LETTER			;41H~5AH，是字母
		JMP LO
FOUR:	CMP AX,61H
		JNC FIVE
		INC	OTHER			;5BH~60H，是其他字符
		JMP LO
FIVE:	CMP AX,7BH
		JNC	SIX
		INC LETTER			;61H~7AH，是字母
		JMP LO
SIX:	INC	OTHER			;大于7AH，是其他字符

LO:		INC	BX				;BX指向下一个字符
		LOOP	COUNT		;循环统计

;输出提示字母的数量
		MOV	DX,OFFSET TIP1	;输出提示英文	
		MOV AH,09H
		INT	21H

		MOV AL,LETTER		;将统计的字母的数字转移到AL
		MOV CX,2			;因为限制80个字符，所以只用循环2次，即只有2位数
		MOV DL,10			;令DX=10
		MOV DH,0
LONE:	MOV AH,0
		DIV	DL				;AX/10,余数在AH
		PUSH	AX			;放入栈中保存
		LOOP LONE			;继续循环
		MOV CX,2			;重置CX
LTWO:	POP	DX				;反向得到之前放入的数据
		XCHG DH,DL			;交换
		OR	DL,30H			;DL中是之前余数的字符数值了
		MOV	AH,2			;输出这个字符
		INT 21H
		LOOP LTWO			;继续循环

		MOV	DX,OFFSET HUICE	;输出数字后回车
		MOV AH,09H
		INT	21H

;下面2个基本相同，不再赘述
;输出提示数字的数量
		MOV	DX,OFFSET TIP2
		MOV AH,09H
		INT	21H

		MOV AL,NUM
		MOV CX,2
		MOV DL,10
		MOV DH,0
NONE:	MOV AH,0
		DIV	DL
		PUSH	AX
		LOOP NONE
		MOV CX,2
NTWO:	POP	DX
		XCHG DH,DL
		OR	DL,30H
		MOV	AH,2
		INT 21H
		LOOP NTWO

		MOV	DX,OFFSET HUICE
		MOV AH,09H
		INT	21H

;输出提示其他字符的数量
		MOV	DX,OFFSET TIP3
		MOV AH,09H
		INT	21H

		MOV AL,OTHER
		MOV CX,2
		MOV DL,10
		MOV DH,0
OONE:	MOV AH,0
		DIV	DL
		PUSH	AX
		LOOP OONE
		MOV CX,2
OTWO:	POP	DX
		XCHG DH,DL
		OR	DL,30H
		MOV	AH,2
		INT 21H
		LOOP OTWO

		MOV	DX,OFFSET HUICE
		MOV AH,09H
		INT	21H

THEEND:
MOV	AX, 4C00H		;程序结束
INT	21H

CODE ENDS
	END START