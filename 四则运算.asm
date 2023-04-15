DATA SEGMENT 
TIPSTART	DB	'Please enter an operational expression:',0AH,0DH,'s=','$'	;输出提示，提醒输入一个表达式
EXPRESSION	DB	100,?,100 DUP(?)	;存放表达式			002C
ANSWERTIP	DB	0AH,0DH,'The answer is:',0AH,0DH,'s=','$'	;提示在输出答案
NUMBER		DW	50 DUP(0)		;用来记录表达式中的数值		00AA	
OPERATOR	DB  50 DUP(?)		;用来记录表达式中的操作符
ADDSUBNUM	DW  50 DUP(0)		;用来记录进行了乘除操作后准备用来加减的数值	013C
X			DW  ?				;一个变量
Y			DW	?				;一个变量
ANSWER		DW  ?				;用来储存答案
ERRORTIP	DB	0AH,0DH,'The expression has error!',0ah,0dh,'$'	;输出错误提示
DATA ENDS 

CODE	SEGMENT
		ASSUME	CS:CODE,DS:DATA


MAIN	PROC	FAR	;采用main的方法调用主程序
		PUSH	DS	;准则语句
		MOV	AX,0
		PUSH	AX

		MOV	AX,DATA;装填DS
		MOV	DS,AX

		CALL WRITE			;用来获得一个从键盘输入的表达式，放入EXPRESSION中,并判断输入是否正确
		CALL CHANGETONUM	;获得表达式中的数值，放入NUMBER中
		CALL GETOPERATOR	;获得表达式中的运算符，放入OPERATOR中
		CALL FIRSTOPERATE	;进行第一步运算，将所有的乘除运算都运算完，把后续需要加减的数值都放入ADDSUBNUM中
		CALL ADDSUBALL		;进行第二步运算，将ADDSUBNUM的数按顺序进行加减运算
		CALL PRINTANSWER	;书写答案


	;结束
		RET
MAIN	ENDP

WRITE	PROC	;该子程序用来获得一个从键盘输入的表达式，放入EXPRESSION中
STARTWRITE:
		LEA DX,TIPSTART	;输出提示
		MOV AH,09H
		INT 21H

		LEA	DX,EXPRESSION;等待输入一个表达式，并放入EXPRESSION中
		MOV AH,0AH
		INT 21H	
		
		LEA	DI,EXPRESSION
		ADD	DI,2
JUDGERROR:
		CMP	BYTE PTR [DI],0DH	;遇到0DH说明结束了
		JE	ENDWRITE
		CMP	BYTE PTR [DI],'0'	;小于0的字符可能是运算符，也可能是非法的
		JL	JUDGEOPER
		CMP	BYTE PTR [DI],'9'	;大于9的一定是非法的
		JG	HAVEERROR
LOJUDGE:INC DI
		JMP	JUDGERROR

JUDGEOPER:
		CMP	BYTE PTR [DI],'+'	;如果是+-*/.就是合法的，继续判断下一个，不然就是非法的
		JE	LOJUDGE
		CMP	BYTE PTR [DI],'-'
		JE	LOJUDGE
		CMP	BYTE PTR [DI],'*'
		JE	LOJUDGE
		CMP	BYTE PTR [DI],'/'
		JE	DIVJUDGE
		CMP	BYTE PTR [DI],'.'
		JE	LOJUDGE
		JMP	HAVEERROR

DIVJUDGE:
		CMP	BYTE PTR [DI+1],'0'
		JNE	LOJUDGE

HAVEERROR:
		LEA	DX,ERRORTIP			;有非法的，就输出错误提示
		MOV	AH,09H
		INT 21H

		MOV	CL,[EXPRESSION+1]	
		MOV	CH,0
		LEA	BX,EXPRESSION
		ADD	BX,1
CLEAR:	MOV	BYTE PTR [BX],0DH	;将该内存清零，然后跳到开头，继续输入
		INC	BX
		LOOP	CLEAR
		JMP	STARTWRITE
		

ENDWRITE:
		RET
WRITE	ENDP

CHANGETONUM	PROC
		LEA SI,EXPRESSION	;获得EXPRESSION的地址到SI
		LEA DI,NUMBER		;获得NUMBER的地址到DI
		ADD SI,2			;EXPRESSION前2个是空间总长和使用空间的长度，所以要跳过
		MOV AX,0	;储存和
		MOV BX,0	;储存单个数字
		MOV	CX,0	;记录小数部分的个数

GETANUM:MOV BL,[SI]	;将字符放入BL中，继续判断
		CMP	BL,'.'	;首先判断是否是小数点
		JE	DECIMAL	;如果是就进入小数存放
		CMP BL,'0'	;如果不是，就判断是不是运算符，注意到运算符都比'0'小，所以这样判断
		JL	NEXTNUMDECI	;如果比'0'小，就说明是运算符，就准备跳到下一个字符，不然就是数字，继续将其转化为数值

		SUB	BL,'0'	;获得字符对应的数字
		MOV DX,10	;DX赋值10
		MUL DX	;	;相当于乘10
		ADD AX,BX	;将BX加入到和中
		INC SI		;SI+1
		JMP GETANUM	;继续循环到下一字符

DECIMAL:INC	SI		;因为现在SI指向的是'.',所以需要跳到下一个
		MOV BL,[SI]	;获得下一个字符
		CMP BL,'0'	;如上，比较是不是运算符
		JL	NEXTNUMDECI	;是就准备跳到下一个数值循环

		CMP	CX,2	;比较小数位数，从0开始统计，0，1，2
		JGE	DECIMAL	;如果到第2位之后的小数位数，就跳回，即不录入到数据中，为的是保持位数一致，即都是*100
		SUB	BL,'0'	;获得BL字符对应的数值
		MOV DX,10	;DX=10
		MUL DX		;AX*10
		ADD AX,BX	;AX加入BX
		INC	CX		;记录小数位数+1
		JMP	DECIMAL	;直接到下一个小数

NEXTNUMDECI:		;这里主要是处理只有一位的小数情况，这时AX需要多乘一次10
		CMP	CX,2	;比较记录的小数位数
		JGE	NEXTNUM	;如果有2位记录了，就准备到下一个数值
		MOV	DX,10	
		MUL	DX		;AX*10
		INC	CX		;记录位数+1
		JMP	NEXTNUMDECI	;跳回

NEXTNUM:MOV [DI],AX	;和在AX中，将它放入内存中
		ADD DI,2	;指向下一个空内存
		MOV BL,[SI]	
		CMP BL,0DH	;比较有没有遇到回车
		JE ENDLOOP	;遇到了就说明结束了
		INC SI		;指向表达式下一个字符
		MOV AX,0	;归0
		MOV BX,0	
		MOV	CX,0
		JMP	GETANUM

ENDLOOP:	RET	;结束了
CHANGETONUM ENDP


GETOPERATOR PROC	;获得表达式中的运算符，放入OPERATOR中
		LEA SI,EXPRESSION	;获得地址
		ADD SI,2			;与上同理，先右移2位才是真正的表达式
		LEA DI,OPERATOR		;

FINDOP:	MOV AL,[SI]		;AL是表达式的字符
		CMP	AL,0DH		;比较是不是遇到了回车，遇到了就退出比较循环
		JE	ENDFIND		
		CMP AL,'0'		;比较是不是运算符
		JGE	LOOPFIND	;不是就准备继续循环到下一个字符
		CMP	AL,'.'		;注意到小于'0'的可能是'.'，遇到这个也要到下一个字符
		JE	LOOPFIND	
		MOV [DI],AL		;将运算符放入内存中
		INC DI			;指向下一个空内存

LOOPFIND:
		INC SI			;指向表达式中的另一个字符
		JMP	FINDOP		;循环
		
ENDFIND:				;结束了
		MOV BYTE PTR [DI],0DH;最后将回车放进去，用来后续判断运算符储存何时停止
		RET
GETOPERATOR ENDP


FIRSTOPERATE PROC		;该子程序用来进行第一步运算，将所有的乘除运算都运算完，把后续需要加减的数值都放入ADDSUBNUM中
		LEA SI,NUMBER	;存放地址
		LEA	DI,ADDSUBNUM	
		LEA	BX,OPERATOR
		SUB BX,1		;BX-1，为的是规范指向的运算符都是指向的数字的前一个运算符
		MOV X,0			;设初值 记录时第几个运算
		MOV CX,0		;记录是不是刚开始乘除
		MOV AX,1		;
		MOV DX,0		;

JUDGE:	CMP X,0			;比较是不是刚开始
		JE	CONTINUEJUDGE		;刚开始就可以继续判断
		CMP BYTE PTR [BX],'+'	;比较运算符是不是'+'或'-'，是就可以继续判断
		JE	CONTINUEJUDGE		
		CMP BYTE PTR [BX],'-'	
		JE	CONTINUEJUDGE		
		JMP ENDOPERA			;不然就是回车了，就可以结束判断了
	
CONTINUEJUDGE:
		CMP	BYTE PTR [BX+1],'*'	;是乘除法就跳到乘除运算
		JE	MULDIVLOOP
		CMP	BYTE PTR [BX+1],'/'
		JE	MULDIVLOOP
		CMP	BYTE PTR [BX+1],'+'	;是加减法就说明这一轮的乘除运算结束了，准备到下一个判断
		JE	NNEXT
		CMP	BYTE PTR [BX+1],'-'	
		JE	NNEXT
		CMP	BYTE PTR [BX+1],0DH	;是回车就说明结束了
		JE	NNEXT
		JMP ENDOPERA

MULDIVLOOP:
		INC BX			;指向下一个的乘除符号
		ADD SI,2		;指向下一个的乘数或除数
		CMP	CX,0		;比较是不是刚开始乘除
		JNE	JUDGEMD		;
		MOV AX,[SI-2]	;是的话就要把第一个乘数或者被除数给AX
		MOV DX,0		;

JUDGEMD:
		CMP BYTE PTR [BX],'*'	;再判断一次
		JE	TOMUL
		CMP BYTE PTR [BX],'/'
		JE	TODIV

TOMUL:	PUSH	AX		;将AX暂时放入寄存器
		MOV	AX,[SI]		;将要乘的数除以100，缩小
		MOV	Y,100		
		DIV	Y			
		MOV	[SI],AX		;再放回[SI]
		POP	AX			;AX恢复原值
		MUL	WORD PTR [SI];乘法
		INC CX			;次数+1
		JMP CONTINUEJUDGE
		
TODIV:	PUSH	AX		;和乘法的操作差不多，就除数缩小100倍，然后再除
		MOV	AX,[SI]
		MOV	Y,100
		DIV	Y
		MOV	DX,0
		MOV	[SI],AX
		POP	AX
		DIV WORD PTR [SI]
		MOV DX,0
		INC CX
		JMP CONTINUEJUDGE


NNEXT:	ADD SI,2		;相应的指向下一个
		INC BX
		INC X
		CMP CX,0		;如果CX=0，说明没有进行乘除，将原数放回去就好了
		JE  SAVE
		MOV [DI],AX		;不然就将AX里面的计算结果放进去
		ADD	DI,2
		MOV CX,0
		JMP JUDGE
SAVE:	MOV AX,[SI-2]	;将没有乘除的放回去
		MOV [DI],AX
		ADD DI,2
		JMP JUDGE

ENDOPERA:		
	RET
FIRSTOPERATE ENDP

ADDSUBALL	PROC		;该子程序用于进行第二步运算，将ADDSUBNUM的数按顺序进行加减运算
		LEA	DI,ADDSUBNUM;获得相应的地址
		LEA SI,OPERATOR
		MOV	AX,[DI]

LOOPADDSUB:
		CMP	BYTE PTR [SI],'+'	;遇到+就相加
		JE	ADDNUM
		CMP	BYTE PTR [SI],'-'	;遇到-就相减
		JE	SUBNUM
		CMP BYTE PTR [SI],0DH	;遇到回车就结束
		JE	ENDADDSUB
		INC	SI					;不然就是乘除号，再看下一个
		JMP LOOPADDSUB			

ADDNUM:	ADD	AX,[DI+2]			;将附件所指的2个相加
		ADD	DI,2
		INC	SI
		JMP LOOPADDSUB			;再循环

SUBNUM:	SUB	AX,[DI+2]			;将附件所指的2个相减
		ADD	DI,2
		INC	SI
		JMP LOOPADDSUB			;再循环

ENDADDSUB:						;结束
		MOV	ANSWER,AX
	RET
ADDSUBALL   ENDP


PRINTANSWER	PROC		;输出答案
		LEA	DX,ANSWERTIP;输出提示
		MOV AH,09H
		INT 21H

		MOV AX,ANSWER		;AX中放答案
		MOV CX,8			;循环8次
		MOV BX,10			;令BX=10
		MOV DX,0
		MOV	SI,0
		MOV	X,0

LONE:	MOV DX,0
		DIV	BX				;EAX/10,余数在DX
		PUSH	DX			;余数放入栈中保存
		CMP	CX,8
		JNE	LO
		CMP	DX,5
		JL	LO
		ADD	AX,1
LO:		LOOP LONE			;继续循环

		

		MOV	CX,0			;这里的CX用来表示拿出了几位数了
LTWO:	INC	CX
		CMP	CX,7			;中共有8位，但是考虑到小数点和四舍五入，第7位是十分位，第8位用来四舍五入
		JE	WRITESPOT		;跳到小数部分
		POP	DX				;反向得到之前放入的数据
		CMP	DX,0			;如果DX不是0，就直接输出
		JNE	OUTPUTACHAR		
		CMP	SI,0			;如果DX是0，SI用来表示之前有没有输出过字符，
		JE	NEXTLOOP		;如果还没有输出过字符，这个0就是最前面的0，不用输出，直接下一个循环
		
OUTPUTACHAR:		
		OR	DL,30H			;DL中是之前余数的字符数值了
		INC	SI				;SI+1，说明又输出了一个字符
		MOV	AH,2			;输出这个字符
		INT 21H
NEXTLOOP:
		JMP LTWO			;继续循环

WRITESPOT:					;处理最后的小数
		CMP	SI,0			;如果之前还没有输出过字符，就说明这个数字的格式是0.3这种的，就要多输出个0
		JNE	NOZERO			;不然就不用
		MOV	DL,30H
		MOV	AH,2
		INT 21H

NOZERO:	MOV	DL,'.'			;输出一个小数点
		MOV	AH,2
		INT 21H
		
		POP	DX				;获得最后2个字符
		POP	BX
PRINTENDCHAR:
		OR	DL,30H			;输出最后一个十分位的数
		MOV	AH,2
		INT 21H
		JMP	ENDPRINT


ENDPRINT:		;结束
		RET
PRINTANSWER ENDP

CODE	ENDS	;程序结束
		END	MAIN