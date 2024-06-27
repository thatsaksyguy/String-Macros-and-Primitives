TITLE String Primitives and Macros     (Proj6_saksj.asm)

; Author: Jonathan Saks
; Last Modified: 8/12/22
; OSU email address: saksj@oregonstate.edu
; Course number/section:   CS271 Section 7
; Project Number:  6               Due Date: 8/12/22
; Description: This program will take in 10 signed integers from the user and
;			   display each inputted number, the sum, and the average.

INCLUDE Irvine32.INC

; Displays the current total of the inputted numbers from the user
mPrintCurrTotal	MACRO stringOff, totalString, currTotal
		CALL			CrLf
		mDisplayString	totalString
		PUSH			stringOff
		PUSH			currTotal
		CALL			WriteVal
		CALL			CrLf

ENDM

; Prompts and receives input from the user.
mGetString MACRO inPrompt, inString, lengthLim, stringLen, stringOff, inNum
		PUSH			EAX
		PUSH			ECX
		PUSH			EDX
		mDisplayString	inPrompt
		PUSH			stringOff
		PUSH			inNum
		CALL			WriteVal
		MOV				AL, ':'
		CALL			WriteChar
		MOV				AL, ' '
		CALL			WriteChar
		MOV				EDX, inString
		MOV				ECX, lengthLim
		CALL			ReadString
		MOV				stringLen, EAX
		POP				EDX
		POP				ECX
		POP				EAX

ENDM

; Displays the string to the console
mDisplayString MACRO stringOff
		PUSH			EDX
		MOV				EDX, stringOff
		CALL			WriteString
		POP				EDX

ENDM

		; Defining constants
		COUNT = 10
		MAX_LENGTH = 15

.data
		; Defining variables
		titleMsg			BYTE	"Project 6 - String Primitives by Jonathan Saks", 13, 10, 0
		introMsg			BYTE	"Please provide 10 signed decimal integers. Each number needs to be small enough to fit", 13, 10
							BYTE	"inside a 32 bit register. After you have finished inputting the raw numbers I will display", 13, 10
							BYTE	"a list of the integers, their sum, and their average value.",13, 10, 13, 10, 0
		
		inputMsg			BYTE	"Please enter a signed integer: ", 0
		errorMsg			BYTE	"ERROR: You did not enter a signed number or your number was too big.", 13, 10, 0
		errorFlag			DWORD	0
		currTotal			BYTE	"Current sum: ", 0
		userIn				BYTE	MAX_LENGTH DUP(?)
		inputLength			DWORD	0
		inputSign			SDWORD	1
		inputArr			SDWORD	COUNT DUP(?)
		outNum				BYTE	"You entered the following numbers: ", 0
		outSum				BYTE	"The sum of these numbers is: ", 0
		outAve				BYTE	"The truncated average is: ", 0
		outString			BYTE	MAX_LENGTH DUP(?)
		farewellMsg			BYTE	"Thanks for playing!", 13, 10, 0

.code

main PROC 
		mDisplayString	offset titleMsg
		mDisplayString	offset introMsg
		MOV				ECX, COUNT
		MOV				EDI, offset inputArr

	_getUserIn:
		PUSH			offset currTotal
		PUSH			offset inputArr
		PUSH			ECX
		PUSH			offset outString
		PUSH			offset errorMsg
		PUSH			EDI
		PUSH			offset inputSign
		PUSH			offset errorFlag
		PUSH			offset inputLength
		PUSH			offset userIn
		PUSH			offset inputMsg
		CALL			ReadVal
		ADD				EDI, type SDWORD				
		LOOP			_getUserIn
		PUSH			offset outString
		PUSH			offset inputArr
		PUSH			offset outAve
		PUSH			offset outSum
		PUSH			offset outNum
		CALL			printOut
		CALL			CrLf
		CALL			CrLf
		mDisplayString	offset farewellMsg

	Invoke ExitProcess,0
main ENDP

; Prompts user for signed integers, takes valid inputs and converts them
; from strings to SDWORD.
ReadVal PROC uses EAX EBX ECX EDX ESI EDI
		PUSH			EBP
		MOV				EBP, ESP

	_getInput:
		MOV				EAX, COUNT
		SUB				EAX, [EBP + 64]
		INC				EAX
		PUSH			EAX
		MOV				ECX, EAX
		MOV				ESI, [EBP + 68]
		MOV				EBX, 0

	_sumNextInt:
		MOV				EAX, 0
		CLD
		LODSD
		ADD				EBX, EAX
		LOOP			_sumNextInt
		POP				EAX
		mPrintCurrTotal	[EBP + 60], [EBP + 72], EBX
		mGetString		[EBP + 32], [EBP + 36], MAX_LENGTH, [EBP + 40], [EBP + 60], EAX
		PUSH			[EBP + 48]
		PUSH			[EBP + 44]
		PUSH			[EBP + 40]
		PUSH			[EBP + 36]
		CALL			stringValid
		MOV				EAX, [EBP + 44]
		MOV				EAX, [EAX]
		CMP				EAX, 0
		JNE				_errorMsg
		PUSH			[EBP + 52]
		PUSH			[EBP + 48]
		PUSH			[EBP + 44]
		PUSH			[EBP + 40]
		PUSH			[EBP + 36]
		CALL			convertString
		MOV				EAX, [EBP + 44]
		MOV				EAX, [EAX]
		CMP				EAX, 0
		JE				_end

	_errorMsg:
		mDisplayString	[EBP + 56]
		MOV				EAX, [EBP + 44]
		MOV				DWORD ptr [EAX], 0
		JMP				_getInput

	_end:
		POP				EBP
		RET				44

ReadVal ENDP

; Validates each character, setting the flag accordingly
stringValid PROC uses EAX ECX EDX ESI
		PUSH			EBP
		MOV				EBP, ESP
		MOV				ESI, [EBP + 24]
		MOV				ECX, [EBP + 28]
		CMP				ECX, 0
		JLE				_lengthErr
		CMP				ECX, 12
		JGE				_lengthErr
		MOV				EAX, 0
		CLD
		LODSB
		PUSH			[EBP + 36]
		PUSH			[EBP + 32]
		PUSH			EAX
		CALL			validFirstChar
		DEC				ECX
		CMP				ECX, 0
		JLE				_validEnd

	_nextChar:
		MOV				EAX, 0
		CLD
		LODSB
		PUSH			[EBP + 32]
		PUSH			EAX
		CALL			validChar
		MOV				EAX, 0
		MOV				EDX, [EBP + 32]
		CMP				EAX, [EDX]
		JNE				_validEnd
		LOOP			_nextChar
		JMP				_validEnd

	_lengthErr:
		MOV				EAX, [EBP + 32]
		MOV				DWORD ptr [EAX], 1

	_validEnd:
		POP				EBP
		RET				16

stringValid ENDP

; Validates the very first character of the string input, allowing for
; the user to enter '+' or '-'. Error flag is set accordingly.
validFirstChar PROC uses EAX EDX
		PUSH			EBP
		MOV				EBP, ESP
		MOV				EAX, [EBP + 16]
		CMP				EAX, 2Bh
		JE				_end
		CMP				EAX, 2Dh
		JE				_negativeChar
		CMP				EAX, 30h
		JB				_errorFirstChar
		CMP				EAX, 39h
		JA				_errorFirstChar
		JMP				_end

	_negativeChar:
		MOV				EAX, [EBP + 24]
		MOV				EDX, -1
		MOV				[EAX], EDX
		JMP				_end

	_errorFirstChar:
		MOV				EAX, [EBP + 20]
		MOV				DWORD ptr [EAX], 1

	_end:
		POP				EBP
		RET				12

validFirstChar ENDP

; Validates the character of the user string to only allow number inputs. Error
; flag is set accordingly
validChar PROC uses EAX
		PUSH			EBP
		MOV				EBP, ESP
		MOV				EAX, [EBP + 12]
		CMP				EAX, 30h
		JB				_err
		CMP				EAX, 39h
		JA				_err
		JMP				_end

	_err:
		MOV				EAX, [EBP + 16]
		MOV				DWORD ptr [EAX], 1		

	_end:
		POP				EBP
		RET				8

validChar ENDP

; Converts the string to SDWORD. If too big, error flag is set accordingly.
convertString PROC uses EAX EBX ECX EDX ESI EDI
		PUSH			EBP
		MOV				EBP, ESP
		MOV				ESI, [EBP + 32]
		MOV				EDI, [EBP + 48]
		MOV				ECX, [EBP + 36]
		MOV				EBX, 0
		MOV				EDX, 1
		MOV				EAX, ECX
		DEC				EAX
		ADD				ESI, EAX

	_addInt:
		MOV				EAX, 0
		STD
		LODSB
		CMP				EAX, 2Bh
		JE				_signFlag
		CMP				EAX, 2Dh
		JE				_signFlag
		SUB				EAX, 30h
		PUSH			EDX
		IMUL			EDX
		ADD				EBX, EAX
		JO				_err
		POP				EDX
		MOV				EAX, EDX
		MOV				EDX, 10
		IMUL			EDX
		MOV				EDX, EAX
		LOOP			_addInt

	_signFlag:
		MOV				EAX, EBX
		MOV				EBX, [EBP + 44]
		MOV				EBX, [EBX]
		IMUL			EBX
		MOV				EBX, [EBP + 44]	
		MOV				sdword ptr [EBX], 1
		MOV				[EDI], EAX
		JMP				_end

	_err:
		POP				EDX
		MOV				EAX, [EBP + 40]
		MOV				DWORD ptr [EAX], 1

	_end:
		POP				EBP
		RET				20

convertString ENDP

; Converts SDWORD to strings.
WriteVal PROC uses EAX EBX ECX EDX EDI
		PUSH			EBP
		MOV				EBP, ESP
		MOV				EDX, [EBP + 28]
		MOV				EDI, [EBP + 32]
		MOV				ECX, 10
		MOV				EBX, 1000000000
		CMP				EDX, 0
		JL				_negativeNum
		JMP				_getChar

	_negativeNum:
		NEG				EDX
		MOV				EAX, '-'
		STOSB			

	_getChar:
		MOV				EAX, EDX
		CDQ
		DIV				EBX
		PUSH			EDX
		CMP				EAX, 0
		JNE				_saveChar
		CMP				ECX, 1
		JE				_saveChar
		PUSH			EAX
		PUSH			EBX
		MOV				EAX, [EBP + 32]

	_checkNextChar:
		MOV				BL, BYTE PTR [EAX]
		CMP				BL, 31h
		JGE				_nonLeadingZero
		INC				EAX
		CMP				EDI, EAX
		JLE				_leadingZero
		JMP				_checkNextChar

	_leadingZero:
		POP				EBX
		POP				EAX
		JMP				_end

	_nonLeadingZero:
		POP				EBX
		POP				EAX

	_saveChar:
		ADD				EAX, 30h
		STOSB

	_end:
		MOV				EAX, EBX
		CDQ
		MOV				EBX, 10
		DIV				EBX
		MOV				EBX, EAX
		POP				EDX
		LOOP			_getChar
		MOV				EAX, 0
		STOSB
		mDisplayString	[EBP + 32]
		MOV				ECX, MAX_LENGTH
		MOV				EDI, [EBP + 32]
		MOV				EAX, 0
		REP				STOSB
		POP				EBP
		RET				8
WriteVal ENDP

; Displays all numbers in the array, including the sum and average.
printOut PROC uses EAX EBX ECX EDX ESI
		PUSH			EBP
		MOV				EBP, ESP
		MOV				ECX, COUNT
		MOV				ESI, [EBP + 40]
		CALL			CrLf
		mDisplayString	[EBP + 28]

	_printNum:
		LODSD
		PUSH			[EBP + 44]
		PUSH			EAX
		CALL			WriteVal
		CMP				ECX, 1
		JE				_calcSum
		MOV				AL, ','
		CALL			WriteChar
		MOV				AL, ' '
		CALL			WriteChar
		LOOP			_printNum

	_calcSum:
		MOV				ECX, COUNT
		MOV				ESI, [EBP + 40]
		MOV				EBX, 0

	_sumNext:
		LODSD
		ADD				EBX, EAX
		LOOP			_sumNext
		CALL			CrLf
		mDisplayString	[EBP + 32]
		MOV				EAX, EBX
		PUSH			[EBP + 44]
		PUSH			EAX
		CALL			WriteVal

	_calcAve:
		MOV				EBX, COUNT
		CDQ
		IDIV			EBX
		CALL			CrLf
		mDisplayString	[EBP + 36]
		PUSH			[EBP + 44]
		PUSH			EAX
		CALL			WriteVal

		POP				EBP
		RET				16
printOut ENDP

END main