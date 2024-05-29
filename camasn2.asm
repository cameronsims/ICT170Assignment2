; Clock program, checks 12H ahead of time given

; Author       : Cameron Isaac Sims (34829454)
; Class        : ICT170 - Assignment 2
; Created      : 23/09/2023
; Last Editied : 9/10/2023
; Last Compiled: 9/10/2023

; +++++ PROGRAM METADATA +++++;

TITLE ASSIGNMENT2							; Program Name
.MODEL SMALL								; Small Model Size of Program
.STACK 100H									; Size of the Stack 256 bits

; +++++ PROGRAM VARIABLES +++++ ;

.DATA										; Data/Variables used are below
; Case #
SET_VAR DB -1								; Iterates whether we will change Hours (2), Minutes (1) or Seconds (0)
; Integer
SECOND DB 0									; Current Second (0-59), intially 0, to be incremented by 1
MINUTE DB 0									; Current Minute (0-59), intially 0, to be incremented by 1
HOUR   DB 0									; Current Hour	 (0-11), intially 0, to be incremented by 1
DIGIT_FIRST DB 0							; 1 in 10
DIGIT_LAST DB 0								; 0 in 10
; Strings / Chars
NEWLINE DB 10, 13, '$'						; New Line, in order: NEWLINE, CARRAGE RETURN, TERMINATE STRING
FORMAT_MSG DB "HH:MM:SS",10,13,'$'			; Shows the format
FORMAT_ERR DB "Invalid Number.",10,13, '$'	; Explain error which has occured
EXPLAIN_MSG DB "0z:0y:0x",10,13,'$'			; Shows the format of how the variables work
INPUT_CHAR DB "x = $"						; Shows what value we are inputting
ASK_MSG DB "Please input a number (0-9): $"	; Message to ask user for HOUR/MINUTE/SECONDS
AM_PM DB "AM$"								; Shows if we are in AM or PM (Orignally AM)
; PROGRAM META
ATH_NAME DB "Cameron Sims (34829454): $"	; My Name
ATH_CLASS DB "ICT170-Assignment 2",10,13,'$'; The Class
END_COMMENT DB "Thanks! End of Program!$"	; Thanks user for using program, then closes

; +++++ PROGRAM INSTRUCTIONS +++++ ;

.CODE										; The Code Below Is The Actual Program

; +++++ MAIN() +++++ ;
; This is the main part of the program, it starts from here and branches out
MAIN PROC									; Main Procedure, where the program starts from
	; +++++ PROGRAM SET UP +++++ ;
	; Initalise DX Register		
	MOV AX, @DATA 							; Load the data segment address to AX
	MOV DS, AX								; Initalise the Data Segment Register
	MOV SET_VAR, 0							; Make value for seperating minutes, seconds and hour

	; +++++ PROGRAM EXPLAINATION & DETAILS +++++ ;
	CALL STUDENTINFO
	; Show the format of the function
	EXPLAIN:								; Header of program, calls back here if there is any issues 
		MOV AH, 09H							; Get Register ready to show String value
		MOV DX, OFFSET FORMAT_MSG			; Show how the program will work
		INT 21H								; Show value of FORMAT_MSG
		; Show how the program will work	
		MOV DX, OFFSET EXPLAIN_MSG			; Show how the program will work
		INT 21H								; Show value of EXPLAIN_MSG
		
	; +++++ PROGRAM VALUE INPUT +++++ ;
	ASK_VALUE:								; ASK_VALUE tag
		; If we already have asked for the hour
		CMP SET_VAR, 2						; If we have iterated over twice,
			JG EXIT_ASKING					; Then Jump to the end
		; Show String			
		MOV AH, 09H							; Get Register ready to show String value
		MOV DX, OFFSET ASK_MSG				; Load Offset of the String into the register
		INT 21H								; Show value of ASK_MSG
		; Show what variable we are changing
		MOV DX, OFFSET INPUT_CHAR			; Send variable (x/y/z) to display register
		INT 21H								; Show value in prompt
		INC INPUT_CHAR						; Change Value so that for the next prompt it will go x->y->z
		; Get number value from the console
		MOV AH, 1							; Prepare Register to recieve value
		INT 21H								; Get Value From Prompt
		; SWITCH SET_VAR			
		CMP SET_VAR, 1						; Compare SET_VAR (This varaible is used to loop over the same code, making sure to assign itself to either HOURS,MINS OR SECS
			JL SET_SECOND					; If SET_VAR is lower than 1
			JE SET_MINUTE					; If SET_VAR is equal to 1
			JG SET_HOUR						; If SET_VAR is higher than 1
		; CASE SET_SECOND				
		SET_SECOND:							; if SET_VAR is 2
			MOV SECOND, AL					; Set HOUR to the value input
			SUB SECOND, '0'					; Reverse the HOUR back so its in binary value not in ASCII code
			JMP END_CASE					; Jump to the end tag, so that we do not execute the code below
		; CASE SET_MINUTE				
		SET_MINUTE:							; if SET_VAR is 1
			MOV MINUTE, AL					; Set HOUR to the value input
			SUB MINUTE, '0'					; Reverse the HOUR back so its in binary value not in ASCII code
			JMP END_CASE					; Jump to the end tag, so that we do not execute the code below
		; CASE SET_HOUR			
		SET_HOUR:							; if SET_VAR is 0 (HOUR)
			MOV HOUR, AL					; Set HOUR to the value input
			SUB HOUR, '0'					; Reverse the HOUR back so its in binary value not in ASCII code
			JMP END_CASE					; Jump to the end tag, so that we do not execute the code below
		; END_CASE				
		END_CASE:							; End Case
			INC SET_VAR						; Increase SET_VAR by 1
			MOV AH, 09H						; Prepare Register to show a String
			MOV DX, OFFSET NEWLINE			; Input character for new line
			INT 21H							; Place String in Prompt
			JMP CHK_ANSWER					; Check the value just input, see if it is valid
	; Checks if the value which has been input by the user is valid (ANSWER JUST INPUT WILL BE IN [AL] REGISTER!!!!
	CHK_ANSWER:								; Label if the input from the user is inbetween 0 and 9
		; If AL <= 9 && AL >= 0
		CMP AL, '0'							; Compare AL to ASCII character '0'
			JL ANSWER_WRONG					; If the value is lower, then jump back to explaining the program.
		; If the value is greater-than or equal to 0, then the following will execute.
		CMP AL, '9'							; Compare AL to 9
			JLE ASK_VALUE					; If the value is between 0<=x<=9, jump back to asking the value
			JG ANSWER_WRONG					; If we are ASCII value is greater
	ANSWER_WRONG:							; If the value entered is not a valid number, then:
		MOV AH, 09H							; Get Register ready to show String value
		MOV DX, OFFSET FORMAT_ERR			; Get the display register ready to show string value
		INT 21H								; Show string value which will explain to the user what the did wrong
		DEC SET_VAR							; Set back value which has dictates which variable we modify 
		DEC INPUT_CHAR						; Set back the variable name which we just input x<-y<-z
		JMP ASK_VALUE						; Go back, asks user again 
	; Exit Asking the user for values
	EXIT_ASKING:							; Show EXIT_ASKING label
		MOV AH, 09H							; Prepare Register to show
		MOV DX, OFFSET NEWLINE				; Input character for new line
		INT 21H								; Place Character in Prompt
		
	; +++++ PROGRAM LOOP +++++ ;
	; Below should be equal to 12*60*60 (Hour*Minutes*Seconds) = 43200
	MOV CX, 43200							; Amount of times that we will loop the time
	; Label for showing time (we should not need to go above ever again)
	TIME: 									; Time Process (loop back here to increment)
		CALL SHOWTIME						; Show the time
		MOV AH, 09H							; Show a String on interupt 21H
		MOV DX, OFFSET AM_PM				; Show the Merdian we are in
		INT 21H								; Show the denomination
		MOV DX, OFFSET NEWLINE				; Set new line character to be shown
		INT 21H								; Show in console
		JMP INCREASE_SEC					; Skip the below (done so we can skip back because it otherwise will not increase values
			
		; For the next part, we want to check in order of minority [right (Minute) to left (Hour)]
		; This ensures that the values we get will be expected by a clock
			
		; If seconds have reached 60, tick over the minute reset the value
		INCREASE_SEC:						; Tag for increasing seconds
			INC SECOND						; Increase Second by 1
			CMP SECOND, 60					; Compare the Seconds to 60
				JNZ INCREASE_MIN			; If it isn't equal to zero, skip to the minutes, do not execute below
				XOR AL, AL					; Set the value 0 to register (so that we can put it in the variable)
				MOV SECOND, AL				; Set the variable to 0, using the register (otherwise won't work)
				INC MINUTE					; Increase Minute by 1
		; If minutes have reached 60, tick over the hour, reset the minutes
		INCREASE_MIN:						; Label for skipping the logic above
			CMP MINUTE, 60					; Compare the Minute to 60
				JNZ INCREASE_HOUR			; If it isn't equal to zero, skip to the minutes, do not execute below
				XOR AL, AL					; Set the value 0 to register (so that we can put it in the variable)
				MOV MINUTE, AL				; Set the variable to 0, using the register (otherwise won't work)
				INC HOUR					; Increase hour by 1
		; If hours have reached 13, set to 1
		INCREASE_HOUR:						; Label for skipping the logic above
			CMP HOUR, 12					; If hour is 12, then reset to 0
				JNZ INCREASE_NOTHING		; If the hour is <12 (will not be 0), then loop back to TIME Label (goes to TIME)
				XOR AL, AL					; Set the value 0 to register (so that we can put it in the variable)
				MOV HOUR, AL				; Set the variable to 0, using the register (otherwise won't work)
				ADD AM_PM, 15				; Change from AM (Default) to PM (because P is 15 chars ahead of A)
		INCREASE_NOTHING:					; Used above, this is so that we do not set the hour back to 0 constantly
			LOOP TIME	 					; Loop back to TIME
		
	; exit to DOS		
	EXIT:									; Used in loop to exit program
		MOV AH, 09H							; Show a String on interupt 21H
		MOV DX, OFFSET END_COMMENT			; Show a Closing message to the user signaling an end to the program
		INT 21H								; Show the denomination
		MOV AX, 4C00H						; Register to exit program
		INT 21H								; Exit the program (back to DOS)
MAIN ENDP									; End of Main()

; +++++ SHOWTIME() +++++ ;

; Shows my name and information
SHOWTIME PROC								; Beginning of ShowTime()
	; Beginning of TIME, we will show HOURS->MINUTES->SECONDS
	SHOW_HOUR:								; Show Hour
		MOV AL, HOUR						; Move HOUR to the register for showing number
		CALL SHOWDOUBLEDIGIT				; Show a double digit number
	; Seperate hours, from minutes	
	MOV AH, 2								; Set Register ready to show value
	MOV DX, ':'								; Set colon to be displayed
	PUSH DX									; Save state so we don't need to re-input the values
	INT 21H									; Show in console
	; Minutes, shows the minutes will then go lower and show seconds
	SHOW_MINUTE:							; Show Minutes
		MOV AL, MINUTE				    	; Move MINUTE to the register for showing value
		CALL SHOWDOUBLEDIGIT				; Show a double digit number
	; Seperate minutes, from seconds	
	MOV AH, 2								; Set Register ready to show value
	POP DX									; Get the state from the stack
	INT 21H									; Show in console
	; Shows Seconds, lower will check if all the values are valid
	SHOW_SECOND:							; Show Seconds
		MOV AL, SECOND						; Move SECOND to the register for following function
		CALL SHOWDOUBLEDIGIT				; Show a double digit number
	RET 0									; Return stack pointer of 0
SHOWTIME ENDP								; Ending of ShowTime()

; +++++ SHOWDOUBLEDIGIT() +++++ ;

; Shows value in [AL] Register that is double digit
SHOWDOUBLEDIGIT PROC						; Beginning of ShowDoubleDigit()
	XOR AH, AH								; Hold this line, copy value to AH
	MOV BL, 10								; Used to convert Digit to ASCII, puts the remainder (digit we want AH)
	DIV BL									; Divides itself by 10
	; Split the register into two variables
	MOV DIGIT_FIRST, AL						; Split first 8 bytes to variable
	MOV DIGIT_LAST, AH						; Split last 8 bytes to variable
	; Show the variables in prompt		
	MOV AH, 2								; Moves value 2 into register, this will allow us to show values
	; Show first number (1 in 10)		
	MOV DL, DIGIT_FIRST						; Send variable to display register
	ADD DL, '0'								; Increase such that it is in a proper ASCII code
	INT 21H									; Show value in prompt
	; Show last number (0 in 10)			
	MOV DL, DIGIT_LAST						; Send variable to display register
	ADD DL, '0'								; Increase such that it is in a proper ASCII code
	INT 21H									; Show value in prompt
	RET 0									; Return 2 to the stack pointer
SHOWDOUBLEDIGIT ENDP						; End of ShowDoubleDigit()

; +++++ STUDENTINFO() +++++ ;

; Shows my name and information
STUDENTINFO PROC							; Beginning of StudentInfo()
	MOV AH, 09H								; Get Register ready to show String value
	MOV DX, OFFSET ATH_NAME					; Set string value for my name
	INT 21H									; Show name in prompt to user
	MOV DX, OFFSET ATH_CLASS				; Set string value for the class
	INT 21H									; Show class in prompt to user 
	RET 0									; Return procedure with no pointer
STUDENTINFO ENDP							; Ending of StudentInfo()

END MAIN									; End Entire Program