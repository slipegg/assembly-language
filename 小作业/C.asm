DATA SEGMENT
		BUFFER	DB	80,?,80 DUP(?)	;�����洢�����ַ�
		LETTER	DB	0				;ͳ����ĸ����
		NUM		DB	0				;ͳ�����ָ���
		OTHER	DB	0				;ͳ�������ַ�����
		TIP0	DB	"Please enter less than 80 characters:"		;������һЩ��ʾ��
		TIP1	DB	"the number of letters is:$"
		TIP2	DB	"the number of number is:$"
		TIP3	DB	"the number of other is:$"
		TIP4	DB	"more than 80,error!"
		HUICE	DB	0AH,0DH,'$'	;���ú��൱�ڻس���
DATA	ENDS

CODE SEGMENT
		ASSUME CS:CODE,DS:DATA
START:	MOV	AX,DATA			;װ��DS
		MOV	DS,AX
		
		MOV	DX,OFFSET TIP0	;�����ʾ
		MOV AH,09H
		INT	21H
		MOV	DX,OFFSET HUICE	;�س�
		MOV AH,09H
		INT	21H

		LEA	DX,BUFFER		;����һЩ�ַ���
		MOV	AH,0AH
		INT	21H

		MOV	DX,OFFSET HUICE	;�س�
		MOV AH,09H
		INT	21H

		MOV	CL,BUFFER+1		;��CX��¼�ܹ�Ҫѭ�����ٴ�
		MOV	CH,0
		LEA	BX,BUFFER+2		;��BX��¼��Ҫͳ�Ƶ��ַ����ĵ�ַ���������׵�ַ

		CMP	CX,80
		JC	COUNT			;������벻����80���͵�COUNT������
		MOV	DX,OFFSET TIP4	;��Ȼ�����ʾ���������
		MOV AH,09H
		INT	21H
		JMP THEEND			;ֱ���������

COUNT:	MOV	AL,[BX]			;��BX��ָ���ַ�����AX
		MOV AH,0
		CMP	AX,30H			;�Ƚ�AX��30H
		JNC	ONE				;û���������AX>=30H��������ONE�����ж�
		INC	OTHER			;��Ȼ��˵����С��30H���������ַ�����Ӧ+1
		JMP	LO				;˵���Ѿ��жϳ����ˣ�ֱ���������ѭ������
;���µ��жϷ�������࣬����׸��
ONE:	CMP	AX,3AH
		JNC	TWO
		INC NUM				;30H~39H��������
		JMP LO
TWO:	CMP	AX,41H
		JNC	THREE
		INC OTHER			;3AH~40H���������ַ�
		JMP LO
THREE:	CMP AX,5BH
		JNC	FOUR
		INC LETTER			;41H~5AH������ĸ
		JMP LO
FOUR:	CMP AX,61H
		JNC FIVE
		INC	OTHER			;5BH~60H���������ַ�
		JMP LO
FIVE:	CMP AX,7BH
		JNC	SIX
		INC LETTER			;61H~7AH������ĸ
		JMP LO
SIX:	INC	OTHER			;����7AH���������ַ�

LO:		INC	BX				;BXָ����һ���ַ�
		LOOP	COUNT		;ѭ��ͳ��

;�����ʾ��ĸ������
		MOV	DX,OFFSET TIP1	;�����ʾӢ��	
		MOV AH,09H
		INT	21H

		MOV AL,LETTER		;��ͳ�Ƶ���ĸ������ת�Ƶ�AL
		MOV CX,2			;��Ϊ����80���ַ�������ֻ��ѭ��2�Σ���ֻ��2λ��
		MOV DL,10			;��DX=10
		MOV DH,0
LONE:	MOV AH,0
		DIV	DL				;AX/10,������AH
		PUSH	AX			;����ջ�б���
		LOOP LONE			;����ѭ��
		MOV CX,2			;����CX
LTWO:	POP	DX				;����õ�֮ǰ���������
		XCHG DH,DL			;����
		OR	DL,30H			;DL����֮ǰ�������ַ���ֵ��
		MOV	AH,2			;�������ַ�
		INT 21H
		LOOP LTWO			;����ѭ��

		MOV	DX,OFFSET HUICE	;������ֺ�س�
		MOV AH,09H
		INT	21H

;����2��������ͬ������׸��
;�����ʾ���ֵ�����
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

;�����ʾ�����ַ�������
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
MOV	AX, 4C00H		;�������
INT	21H

CODE ENDS
	END START