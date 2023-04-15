DATA SEGMENT
A	DB		70H
B	DB		60H
C	DB		40H
D	DB		20H
S	DW  	?
DATA	ENDS
CODE	SEGMENT
		ASSUME	CS:CODE,DS:DATA
START:
MOV	AX,DATA
MOV	DS,AX

MOV	AL,C
CBW
MOV	CX,AX
MOV	AL,D
CBW
ADD	CX,AX	;C+D的结果在CX,因为原本两个数是字节的长度，所以相加不会超过字，所以不会溢出
MOV	AL,A
IMUL	B	;A*B的结果在AX
CWD			;把被除数扩大到双字
IDIV	CX	;这样商就在AX中，有字的大小，因为原本的被除数也是字的大小，所以不会溢出	
MOV	CX,AX	;第一个式子的结果在CX

MOV	AL,B
CBW
MOV BX,AX
MOV AL,A
CBW
SUB	AX,BX	;A-B的结果在AX,因为原本两个减的数都是字节的长度，所以相减不会超过字，所以不会溢出
MOV	BX,5	
IMUL	BX	;5*(A-B)的结果在AX,因为AX是两个字相乘的结果，所以它最多就是在AH的最低位有一个1，所以再*5，是可以保证不会超过AX的范围的
CWD
MOV	BX,2
IDIV	BX	;除以2，被除数的有效数字全部都在AX中，所以除以2，最后的结果是可以用AX装下的，保证不溢出
MOV	BX,AX	;第二个式子的结果在BL

MOV AL,C
CBW
IDIV	D
CBW			;第三个式子C/D的结果在AX，两个的有效数字都是字节的大小，所以相除是可以保证在AL中的，只是不能除以0

ADD	AX,BX
ADD AX,CX	;三个式子的累加结果在AL
MOV S,AX	;结果转移到了S

MOV		AH,4CH
INT		21H

CODE	ENDS
	END	START