;------------------------------------------------------------------------------------------------------
; A Simple SoC  Application
; Toggle LEDs at a given frequency. 
;------------------------------------------------------------------------------------------------------



; Vector Table Mapped to Address 0 at Reset

						PRESERVE8
                		THUMB

        				AREA	RESET, DATA, READONLY	  			; First 32 WORDS is VECTOR TABLE
        				EXPORT 	__Vectors
					
__Vectors		    	DCD		0x00003FFC							; 16K Internal Memory
        				DCD		Reset_Handler
        				DCD		0  			
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				DCD		0
        				DCD 	0
        				DCD		0
        				
        				; External Interrupts
						        				
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
        				DCD		0
              
                AREA |.text|, CODE, READONLY
;Reset Handler
Reset_Handler   PROC
                GLOBAL Reset_Handler
                ENTRY
				
DIR0			LDR	   	R1, =0x53000004				;Write to GPIO direction register
				LDR		R0, =0x00					;Direction 0 GPIOIN
				STR	  	R0, [R1]					;Push 0x00 into GPIO
				
READIN			LDR	 	R1, =0x53000000				;Read from GPIOIN
				LDR		R3, [R1]					;Expect 8'h3A
				

DIR1		   	LDR 	R1, =0x53000004				;Write to GPIO direction register
				LDR		R0, =0x01					;Set to output
				STR		R0, [R1]

WRITE 			LDR 	R1, =0x53000000				;Write to GPIOOUT (LED) 
				STR		R3, [R1]

READOUT			LDR		R1, =0x53000000				;Read from GPIOOUT
				LDR		R2, [R1]			


VGA				LDR	   	R1, =0x50000000				;Write to VGA
				LDR		R0, =0x48					;H
				LDR		R2, =0x65					;e
				LDR		R3, =0x6c					;l
				LDR		R4, =0x6f					;o
				
				STR		R0, [R1]					;H
				STR		R2, [R1]					;e
				STR		R3,	[R1]					;l
				STR		R3,	[R1]					;l
				STR		R4,	[R1]					;o
				
				LDR		R0, =0x2FFFFF				;Delay
Loop1			SUBS	R0,R0,#1
				BNE Loop1

				B DIR0
				ENDP


				ALIGN 		4						; Align to a word boundary

		END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
   