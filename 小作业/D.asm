DATA	SEGMENT
;һЩ��ʾ���
TIP1	DB	0AH,0DH,'Monday',0AH,0DH,'$'
TIP2	DB	0AH,0DH,'Tuesday',0AH,0DH,'$'
TIP3	DB	0AH,0DH,'Wednesday',0AH,0DH,'$'
TIP4	DB	0AH,0DH,'Thursday',0AH,0DH,'$'
TIP5	DB	0AH,0DH,'Friday',0AH,0DH,'$'
TIP6	DB	0AH,0DH,'Saturday',0AH,0DH,'$'
TIP7	DB	0AH,0DH,'Sunday',0AH,0DH,'$'
TIPE	DB	0AH,0DH,'Error!',0AH,0DH,'$'
TIPS	DB	0AH,0DH,'Please enter a number:',0AH,0DH,'$'

COD		DW	D1,D2,D3,D4,D5,D6,D7	;��ַ��
DATA	ENDS

CODE	SEGMENT
ASSUME	CS:CODE,DS:DATA
START:	MOV	AX,DATA			;װ��DS
		MOV DS,AX

INPUT:	MOV	DX,OFFSET TIPS	;�����ʾ
		MOV AH,09H
		INT	21H

		MOV	AH,01H			;����һ���ַ�
		INT 21H

		CMP	AL,'0'			;����0֮�������˳�
		JZ	THEEND

		CMP	AL,'1'			;��1��7�Ƚϣ�������������Χ��˵�������������������ʾ��
		JB	DE
		CMP	AL,'7'
		JA	DE

		SUB	AL,'1'			;���ַ�����1~0��2~2��3~4��4~6����7~12��˳��ת��������¼��AL�У����������ַ���Ӧ��
		SHL	AL,1

		MOV BL,AL
		MOV BH,0
		JMP	COD[BX]			;���Ѱַ�����յ�ַ���ҵ���ת�ĵ�ַ��������ת

;���ζ�Ӧ����һ�����ڶ������������������죬������������
D1:		MOV	DX,OFFSET TIP1	;��DX������Ӧ�ĵ����ַ������׵�ַ
		JMP OUTPUT			;ֱ����ת�����
D2:		MOV	DX,OFFSET TIP2
		JMP OUTPUT
D3:		MOV	DX,OFFSET TIP3
		JMP OUTPUT
D4:		MOV	DX,OFFSET TIP4
		JMP OUTPUT
D5:		MOV	DX,OFFSET TIP5
		JMP OUTPUT
D6:		MOV	DX,OFFSET TIP6
		JMP OUTPUT
D7:		MOV	DX,OFFSET TIP7
		JMP OUTPUT
DE:		MOV	DX,OFFSET TIPE

OUTPUT:	MOV	AH, 9		;���DX�е�ַ��Ӧ���ַ���
		INT	21H
		
		JMP	INPUT

THEEND:	MOV	AX, 4C00H	;�������
		INT	21H
CODE	ENDS
		END	START