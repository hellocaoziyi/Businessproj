; This program receives data on the 8051
; serial port. Once the program's
; initialisation is complete, it waits for
; data arriving on the RXD line (data
; that was transmitted by the external
; UART).

; Any text typed in the external UART is
; sent once the Tx Send button is pressed.
; As each character is transmitted fully,
; it disappears from the Tx window.
; The data is appended with the return
; character (0D HEX).

; The default external UART baud rate is 19,200. To
; generate this baud rate, TH1 must be set to -3.
; If the system clock is 12 MHz, the error when attempting
; to generate such a high baud rate such that very often
; garbage is received. Therefore, for 19,200 Baud, the
; system clock should be set to 11.059 HMz.

; See the notes on the serial port for more information.

; The program is written using busy-waiting.
; It continuously tests the RI flag. Once
; this flag is set by the 8051 hardware
; (a byte has been received) the program
; clears it and then moves the byte from
; SBUF to A.
; The received byte's value is checked to
; see if it is the terminating character (0D HEX).
; If it is the program jumps to the finish,
; otherwise it moves the byte to data memory
; and returns to waiting for the next byte.


	CLR SM0			; |
	SETB SM1			; | put serial port in 8-bit UART mode

	SETB REN			; enable serial port receiver

	MOV A, PCON			; |
	SETB ACC.7			; |
	MOV PCON, A			; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #-3		; put -3 in timer 1 high byte (timer will overflow every 3 us)
	MOV TL1, #-3		; put same value in low byte so when timer is first started it will overflow after approx. 3 us
	SETB TR1			; start timer 1
	MOV R1, #30H		; put data start address in R1
again:
	JNB RI, $			; wait for byte to be received
	CLR RI			; clear the RI flag
	MOV A, SBUF			; move received byte to A
	CJNE A, #0DH, skip	; compare it with 0DH - it it's not, skip next instruction
	JMP finish			; if it is the terminating character, jump to the end of the program
skip:
	MOV @R1, A			; move from A to location pointed to by R1
	INC R1			; increment R1 to point at next location where data will be stored
	JMP again			; jump back to waiting for next byte
finish:
	JMP $				; do nothing
