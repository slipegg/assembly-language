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
ADD	CX,AX	;C+D�Ľ����CX,��Ϊԭ�����������ֽڵĳ��ȣ�������Ӳ��ᳬ���֣����Բ������
MOV	AL,A
IMUL	B	;A*B�Ľ����AX
CWD			;�ѱ���������˫��
IDIV	CX	;�����̾���AX�У����ֵĴ�С����Ϊԭ���ı�����Ҳ���ֵĴ�С�����Բ������	
MOV	CX,AX	;��һ��ʽ�ӵĽ����CX

MOV	AL,B
CBW
MOV BX,AX
MOV AL,A
CBW
SUB	AX,BX	;A-B�Ľ����AX,��Ϊԭ�����������������ֽڵĳ��ȣ�����������ᳬ���֣����Բ������
MOV	BX,5	
IMUL	BX	;5*(A-B)�Ľ����AX,��ΪAX����������˵Ľ������������������AH�����λ��һ��1��������*5���ǿ��Ա�֤���ᳬ��AX�ķ�Χ��
CWD
MOV	BX,2
IDIV	BX	;����2������������Ч����ȫ������AX�У����Գ���2�����Ľ���ǿ�����AXװ�µģ���֤�����
MOV	BX,AX	;�ڶ���ʽ�ӵĽ����BL

MOV AL,C
CBW
IDIV	D
CBW			;������ʽ��C/D�Ľ����AX����������Ч���ֶ����ֽڵĴ�С����������ǿ��Ա�֤��AL�еģ�ֻ�ǲ��ܳ���0

ADD	AX,BX
ADD AX,CX	;����ʽ�ӵ��ۼӽ����AL
MOV S,AX	;���ת�Ƶ���S

MOV		AH,4CH
INT		21H

CODE	ENDS
	END	START