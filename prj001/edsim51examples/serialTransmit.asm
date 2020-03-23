; This program sends the text abc down the
; 8051 serial port to the external UART at 4800 Baud.

; To generate this baud rate, timer 1 must overflow
; every 13 us with SMOD equal to 1 (this is as close as
; we can get to 4800 baud at a system clock frequency 
; of 12 Mz).
; See the notes on the serial port for more information.

; The data is sent with even parity,
; therefore for it to be received correctly
; the external UART must be set to Even Parity



	CLR SM0			; |
	SETB SM1			; | put serial port in 8-bit UART mode

	MOV A, PCON			; |
	SETB ACC.7			; |
	MOV PCON, A			; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #243		; put -13 in timer 1 high byte (timer will overflow every 13 us)
	MOV TL1, #243		; put same value in low byte so when timer is first started it will overflow after 1 us
	SETB TR1			; start timer 1

	MOV 30H, #'a'		; |
	MOV 31H, #'b'		; |
	MOV 32H, #'c'		; | put data to be sent in RAM, start address 30H

	MOV 33H, #0			; null-terminate the data (when the accumulator contains 0, no more data to be sent)
	MOV R0, #30H		; put data start address in R0
again:
	MOV A, @R0			; move from location pointed to by R0 to the accumulator
	JZ finish			; if the accumulator contains 0, no more data to be sent, jump to finish
	MOV C, P			; otherwise, move parity bit to the carry
	MOV ACC.7, C		; and move the carry to the accumulator MSB
	MOV SBUF, A			; move data to be sent to the serial port
	INC R0			; increment R0 to point at next byte of data to be sent
	JNB TI, $			; wait for TI to be set, indicating serial port has finished sending byte
	CLR TI			; clear TI
	JMP again			; send next byte
finish:
	JMP $				; do nothing
