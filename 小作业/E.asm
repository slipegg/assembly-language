MYDATA SEGMENT
DATA  	DW      1234H,5678H,9D4CH,0D7H,0,-1,7D2AH,8A0EH,10F5H,645DH,9H,8000H	;�����˺���2�����ݣ���ʱ��8000H����С��
N   	EQU     $-DATA
TIP		DB		'The smallest even number is:',0AH,0DH,'$'	;��ʾ
MYDATA ENDS

CODE	SEGMENT
		ASSUME	CS:CODE,DS:MYDATA

WRITE	PROC		;�ӳ���
;WRITE�ӳ���˵��
;���ܣ���BX�е�������16���Ƶ���ʽ��������Ļ��
;ռ�üĴ�����AX��BX��CX��DX
;��ڲ�����BX
;���ڲ�������
;ʾ����BX��Ϊ1234H���������Ļ�ϵ���1234H
		PUSH	AX	;����֮ǰ�Ĳ���������ջ��
		PUSH	BX
		PUSH	CX
		PUSH	DX
		MOV	CX,4	;ѭ��4��
		MOV	AX,BX	;��Ҫ���������ץ��AX
		MOV	BX,16	;BX��16������������
STAR:	MOV DX,0	;DX���㣬����������
		IDIV	BX	;����16
		PUSH	DX	;��������������
		LOOP STAR	;ѭ����

		MOV	CX,4	;����ѭ������
PRINT:	POP	AX		;�õ�֮ǰ������
		CMP AX,9H	;��9�Ƚ�
		JL	NUMBER	;С�ھͲ����ټ�7�������ĸ
		ADD AX,7H
NUMBER:	ADD AX,30H	;��30��ת��Ϊ�ַ�
		MOV DL,AL	;�����һ���ַ�
		MOV AH,02
		INT 21H
		LOOP PRINT	;�ظ����
		MOV DL,'H'	;������һ��H
		MOV AH,02
		INT 21H

		POP	DX	;��ջ��ȡ������ԭ�ֳ�
		POP CX
		POP BX
		POP AX
		RET
WRITE	ENDP;		;�ӳ������


MAIN	PROC	FAR	;����main�ķ�������������
		PUSH	DS
		MOV	AX,0
		PUSH	AX

		MOV	AX,MYDATA;װ��DS
		MOV	DS,AX

		MOV	SI,OFFSET DATA;SIΪDATA�ĵ�ַ
		MOV	CX,N	;��N����2�����ѭ���Ĵ����ŵ�CX
		SHR	CX,1
		MOV BX,[SI]	;��Сֵ��BX��¼���ȷ����һ����
		INC	SI		;��һ�������õ�����Ӧ�ĸı�
		INC SI
		DEC CX		;CX-1	


COUNT:	TEST	WORD PTR [SI],1	;�ж��ǲ���ż��
		JNZ	LO		;����ż��ֱ��������󣬽�����һ��ѭ��
		CMP	BX,[SI]	;�Ƚϵ�ǰ����ֵ����֮ǰ����Сֵ
		JLE LO		;֮ǰ��Сֵ�θ�С�����������棬׼����һ��ѭ��
		MOV BX,[SI]	;��Ȼ�ͽ���Сֵ��Ϊ��ǰ��ֵ

LO:		INC SI		;SI+2��ת����һ����ֵ
		INC SI		
		LOOP COUNT	;ѭ��

		MOV DX,OFFSET TIP	;��ʾ��ʾ
		MOV AH,09H
		INT 21H

		CALL WRITE	;��ʾBX
;����
		RET
MAIN	ENDP

CODE	ENDS
		END	MAIN