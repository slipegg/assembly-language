DATA	SEGMENT
X	DW  	55, 127, 37, 512
Y	DW  	4 DUP (?)
DATA	ENDS
CODE	SEGMENT
	ASSUME	CS: CODE, DS: DATA
START:	MOV  	AX, DATA
	MOV	DS, AX
	MOV	DI, 2		;�ڶ���Ԫ���������ڵ�λ��
	MOV	AX, X[DI]	;ȡ��X����ڶ���Ԫ��
	MOV	Y[DI], AX	;����Y����ڶ���Ԫ����
	MOV	AX, X[DI+4]	;ȡ��X������ĸ�Ԫ��
	MOV	Y[DI+4], AX	;����Y������ĸ�Ԫ����
	MOV	X[2],0		;X�ĵڶ���Ԫ������
	MOV	X[6],0		;X�ĵ��ĸ�Ԫ������
	MOV	AX, 4C00H
	INT  	21H
CODE	ENDS
	END	START
