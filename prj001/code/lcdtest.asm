;define time,key
SECOND EQU 30H
MINUTE EQU 31H
HOUR EQU 32H
SW0 EQU P2.0
SW1 EQU P2.1

;program start here
ORG 0000H
LJMP MAIN

MAIN:
;initialise
	LCALL InitTime
	LCALL InitLcd
	LCALL LcdDisplay2
LOOP:
;timecount and display
	LCALL LcdDisplay
	LCALL Delay1s
	LCALL TimeCount
	CALL KEYSCAN
	JMP LOOP

InitTime:
	MOV SECOND,#00H
	MOV MINUTE,#00H
	MOV HOUR,#00H
	RET

InitLcd:
	CLR P1.3		;set instruction mode

	;instruction 'function set'
	CLR P1.7
	CLR P1.6
	SETB P1.5
	CLR P1.4

	SETB P1.2		
	CLR P1.2

	CALL Delay50us

	SETB P1.2	
	CLR P1.2

	SETB P1.7	

	SETB P1.2	
	CLR P1.2

	CALL Delay50us
	
	;instruction 'Set DDRAM address'
	MOV A,#0EH
	CALL SendCharacter
	CALL Delay50us

	;instruction 'function set'
	CLR P1.7
	CLR P1.6
	SETB P1.5	
	CLR P1.4

	SETB P1.2	
	CLR P1.2

	CALL Delay50us

	SETB P1.2	
	CLR P1.2

	SETB P1.7	

	SETB P1.2	
	CLR P1.2

	CALL Delay50us

	;instruction 'Display On/Off control'
	MOV A,#0CH
	CALL SendCharacter
	CALL Delay50us

	;instruction 'Clear display'
	MOV A,#01H
	CALL SendCharacter
	CALL Delay2ms
	
	RET

LcdDisplay:
	;second
	MOV A,#87H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	SETB P1.3
	MOV A,SECOND
	ANL A,#0FH
	ADD A,#30H
	CALL SendCharacter
	CALL Delay50us

	MOV A,#86H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	MOV A,SECOND
	SWAP A
	ANL A,#07H
	ADD A,#30H
	SETB P1.3
	CALL SendCharacter
	CALL Delay50us

	;minute
	MOV A,#84H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	SETB P1.3
	MOV A,MINUTE
	ANL A,#0FH
	ADD A,#30H
	CALL SendCharacter
	CALL Delay50us

	MOV A,#83H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	MOV A,MINUTE
	SWAP A
	ANL A,#07H
	ADD A,#30H
	SETB P1.3
	CALL SendCharacter
	CALL Delay50us

	;hour
	MOV A,#81H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	SETB P1.3
	MOV A,HOUR
	ANL A,#0FH
	ADD A,#30H
	CALL SendCharacter
	CALL Delay50us

	MOV A,#80H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	MOV A,HOUR
	SWAP A
	ANL A,#07H
	ADD A,#30H
	SETB P1.3
	CALL SendCharacter
	CALL Delay50us

	RET

LcdDisplay2:
	; display ' : '
	CLR P1.3
	MOV A,#82H
	CALL SendCharacter
	CALL Delay50us
	SETB P1.3
	MOV A,#3AH
	CALL SendCharacter
	CALL Delay50us

	MOV A,#85H
	CLR P1.3
	CALL SendCharacter
	CALL Delay50us
	MOV A,#3AH
	SETB P1.3
	CALL SendCharacter
	CALL Delay50us

	RET

TimeCount:
	;SECONDS
	MOV   A,#01H
	ADD   A,30H
	DA    A
	CJNE  A,#60H,SECONDSCOUNT
	MOV   A,#00H
	SECONDSCOUNT:
	MOV   30H,A
	JNZ   RETUNT

	;MINUTES
	MOV   A,#01H
	ADD   A,31H
	DA    A
	CJNE  A,#60H,MINUTESCOUNT
	MOV   A,#00H
	MINUTESCOUNT:
	MOV   31H,A
	JNZ   RETUNT

	;HOURS
	MOV   A,#01H
	ADD   A,32H
	DA    A
	CJNE  A,#24H,HOURSCOUNT
	MOV   A,#00H
	HOURSCOUNT:
	MOV   32H,A
	RETUNT: 
	RET

KEYSCAN:
	JB SW0,NOKEYPRESS
	JB SW1,NOKEYPRESS
	MOV 30H,#00H
	MOV 31H,#00H
	MOV 32H,#00H
NOKEYPRESS:
	RET


SendCharacter:
	MOV C, ACC.7
	MOV P1.7, C
	MOV C, ACC.6
	MOV P1.6, C
	MOV C, ACC.5
	MOV P1.5, C
	MOV C, ACC.4
	MOV P1.4, C

	SETB P1.2	
	CLR P1.2

	MOV C, ACC.3
	MOV P1.7, C
	MOV C, ACC.2
	MOV P1.6, C
	MOV C, ACC.1
	MOV P1.5, C
	MOV C, ACC.0
	MOV P1.4, C

	SETB P1.2	
	CLR P1.2
	RET

Delay1s:
	MOV R7,#1	;if you want to run in a real time, change #1 to #10
	D3:
	MOV R6,#200
	D2:
	MOV R5, #250
	DJNZ R5, $
	DJNZ R6,D2
	DJNZ R7,D3
	RET

Delay2ms:
	MOV R6,#10
	D1:
	MOV R5, #100
	DJNZ R5, $
	DJNZ R6,D1
	RET

Delay50us:
	MOV R5, #25
	DJNZ R5, $
	RET
