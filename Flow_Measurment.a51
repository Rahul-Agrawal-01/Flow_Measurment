ORG 0000H         
        SJMP MAIN           

        ORG 0003H           
        SJMP Pulse_ISR_Direct

        ORG 0030H
PULSE_COUNT:    DS 2
TOTAL_vollume:   DS 2



PULSES_PER_LITER EQU 10   

; Main Program
        ORG 0050H
MAIN:
        MOV SP, #60H        
        MOV 30H, #0        
        MOV 31H, #0         
        MOV 32H, #0         
        MOV 33H, #0       

        
        SETB IT0            
        SETB EX0           
        SETB EA            

        ACALL LCD_INIT

        MOV DPTR, #welcome_sir
        ACALL LCD_STRING
        acall DELAY_5S
		
MAIN_LOOP:
        ACALL UPDATE_DISPLAY 
        SJMP MAIN_LOOP       

Pulse_Isr_Direct:
        PUSH ACC           
        PUSH PSW          

		ACALL DELAY_2S

        INC 30H           
        MOV A, 30H
        JNZ ISR_CHECK_HIGH
        INC 31H             
ISR_CHECK_HIGH:
        MOV A, 31H          
        CJNE A, #HIGH(PULSES_PER_LITER), ISR_END
        MOV A, 30H          
        CJNE A, #LOW(PULSES_PER_LITER), ISR_END

        SETB P1.3 
		ACALL DELAY_5S
		INC 32H             
        MOV A, 32H
        JNZ RESET_PULSE
        INC 33H            

RESET_PULSE:
        MOV 30H, #0        
        MOV 31H, #0        

ISR_END:      
        POP PSW
        POP ACC
        RETI               

LCD_INIT:
        MOV P2, #00H        
        CLR P1.0            
        CLR P1.1            
        MOV A, #38H       
        ACALL LCD_CMD
        MOV A, #0EH         
        ACALL LCD_CMD
        MOV A, #01H         
        ACALL LCD_CMD
        MOV A, #06H        
        ACALL LCD_CMD
        RET

LCD_CMD:
        MOV P2, A           
        SETB P1.2           
        ACALL DELAY         
        CLR P1.2            
        ACALL DELAY
        RET

LCD_DATA:
        MOV P2, A           
        SETB P1.0           
        CLR P1.1            
        SETB P1.2          
        ACALL DELAY
        CLR P1.2            
        ACALL DELAY
        CLR P1.0           
        RET

LCD_STRING:
        CLR A
        MOVC A, @A+DPTR     
        JZ LCD_STR_END     
        ACALL LCD_DATA      
        INC DPTR
        SJMP LCD_STRING     

LCD_STR_END:
        RET

UPDATE_DISPLAY:
        MOV A, #80H         
        ACALL LCD_CMD
        MOV DPTR, #impulse_string
        ACALL LCD_STRING
        MOV A, 31H        
        ACALL DISP_HEX
        MOV A, 30H          
        ACALL DISP_HEX
		
        MOV A, #0C0H        
        ACALL LCD_CMD
        MOV DPTR, #vollume_string
        ACALL LCD_STRING

        
        MOV A, 33H          
        ACALL DISP_HEX
        MOV A, 32H        
        ACALL DISP_HEX
		MOV DPTR, #ltr
        ACALL LCD_STRING
RET

DISP_HEX:
        PUSH ACC
        SWAP A              
        ANL A, #0FH
        ACALL HEX_TO_ASCII
        ACALL LCD_DATA
        POP ACC
        ANL A, #0FH         
        ACALL HEX_TO_ASCII
        ACALL LCD_DATA
        RET

HEX_TO_ASCII:
        CJNE A, #10, HTA_CHECK
HTA_CHECK:
        JC HTA_NUM        
        ADD A, #55        
        RET
HTA_NUM:
        ADD A, #48         
        RET
		

DELAY_2S:
    MOV R7, #20      
DELAY_LOOP1:
    MOV R6, #200     
DELAY_LOOP2:
    MOV R5, #250     
DELAY_LOOP3:
    NOP              
     NOP              
    DJNZ R5, DELAY_LOOP3  
    DJNZ R6, DELAY_LOOP2
    DJNZ R7, DELAY_LOOP1  
    RET

DELAY_5S:
    MOV R7, #50      
DELAY_LOOP11:
    MOV R6, #200      
DELAY_LOOP22:
    MOV R5, #250      
DELAY_LOOP33:
    NOP               
    NOP               
    DJNZ R5, DELAY_LOOP33  
    DJNZ R6, DELAY_LOOP22  
    DJNZ R7, DELAY_LOOP11  
    RET
	

DELAY:
        MOV R6, #50
DELAY1:
        MOV R7, #100
DELAY2:
        DJNZ R7, DELAY2
        DJNZ R6, DELAY1
        RET

; Messages
welcome_sir:
        DB "Hi Jayesh Sir", 0
impulse_string:
        DB "Count :", 0
vollume_string: 
        DB "Volume:", 0
ltr:
        DB "ltr",0
welcome_project:
        DB "Welcome to flow",0
        END