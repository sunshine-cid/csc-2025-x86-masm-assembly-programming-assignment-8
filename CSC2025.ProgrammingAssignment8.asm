; Student
; Professor
; Class: CSC 2025 XXX
; Week 8 - Programming Homework #8
; Date
; Interactive program reads a string, removes anything but letters, and then outputs the string along with a letter count. There's an option to repeat the process.

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
	
	; Set the max length for our read string and reserve memory space for the string
	maxLength = 100
	stringToEdit BYTE MaxLength+1 DUP (0)
	; Set additional Memory Operands for the letterCount array and a display Counter LoopCounter
	letterCount DWORD 26 DUP (0)
	dCLoopCounter BYTE 0

	; Set several different message strings we'll be using in the program
	msgInstruction BYTE "Please enter a one line string with a maximum of 100 characters: ",0
	msgOriginal BYTE "The original string entered was: ",0
	msgCompressed BYTE "The compressed string is: ",0
	msgAgain BYTE "Enter a new string (y/n)? ",0
	msgOutputBanner BYTE "A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z",0

	; Set some single-byte character variables for use in comparisons later. Also, set a space char holder so we can easily and cleary add spaces to our letter counts
	strY BYTE "Y"
	strN BYTE "N"
	strA BYTE "A"
	strZ BYTE "Z"
	strALower BYTE "a"
	strZLower BYTE "z"
	strSpace BYTE " "

	; Reserve memory space for our 'play again'-style pre-exit question
	charAgain BYTE ?

.code

;-------------------------------- MoveDown Procedure 
;	Functional Details: This procedure recieves a pointer to a string and moves 
;	all the other characters in the string down 1 byte
;	Outputs: There is no strict output, but this does modify the string pointed 
;	to by the ESI OFFSET.
;	Registers:	ESI points to the string's current letter and moves through 
;				each other position to the end.
;				EAX (AL) is used to make a comparison to determine if we're at 
;				the end of the string.
;				EBX (BL) is used to grb the next value (ESI+1) and move it into 
;				the current position
;	Memory Locations: No specific memory locations are used but we do reference 
;	stringToEdit's OFFSET through ESI
MoveDown PROC USES ESI EAX EBX
	
MDLoop:
	
	; Grab the value from the current location
	mov al, [esi] ; Move the [value] into al
	movsx eax, al ; Sign extend EAX from AL to avoid problems
	
	cmp eax, 0 ; Check to see if string is null terminated or empty
	je MDExit ;  and if so exit

	mov bl, [esi] + 1 ; Take the value from ESI+1 and put it in BL
	movsx ebx, bl ; Sign extend EBX from BL to avoid problems
	mov [esi], bl ; Move the value we saved into the current ESI position
	inc esi ; Increment up the string

	jmp MDLoop ; Repeat

MDExit:

	ret
MoveDown ENDP

;--------------------------------  CompressString Procedure 
;	Functional Details: Practically this checks a string (offset sent through 
;	ESI) for characters in the range A-Z and a-z. Anything in that range it 
;	keeps (and counts via LetterCounter), outsiode of that range is overwritten 
;	by the next value in ESI.
;	Outputs: No strict outrput is made, but stringToEdit is modified though 
;	references to it's offset in ESI
;	Registers:	EAX (AL) is used to hold the current offset value
;				ESI is used to hold the offset to stringToEdit
;	Memory Locations: This procedure references our string comparison 
;	predefined memory operands strA, strZ, strALower, and strZLower. And 
;	although we don't reference it directly we are accessing stringToEdit 
;	through its offset.
CompressString PROC USES ESI EAX EDI

CSLoop:
	
	mov al, [esi] ; Move the [value] into al
	movsx eax, al ; Sign extend AL into EAX to prevent any sign-based problems
	
	cmp eax, 0 ; Check to see if value at current string position is null terminated or empty
	je CSExit ; and if so exit

CSLevel1: ; This section compares and strips out characters below ASCII values of "A" or "z"

	cmp al, strA ; Compare EAX to "A"
	jb CSCompress ;  if below, compress
	
	cmp al, strZLower ; Compare EAX to "z" 
	ja CSCompress ; if above, compress

CSLevel2: ; This section compares and skips values below ASCII values of "Z" or "a"

	cmp al, strZ ; Compare EAX to "Z"
	jbe CSNext ; if below or equal, skip

	cmp al, strZ ; Compare EAX to "a" 
	jae CSNext ; if above or equal, skip
	; Otherwise, compress

CSCompress: ; This section calls the MoveDown function to erase the current value at ESI with the values above it
	
	Call MoveDown ; move down all values overwriting current position
	; We don't need to incriment becasue MoveDown essentially does that for us
	jmp CSLoop ; Repeat back at loop start

CSNext: 
	
	Call LetterCounter ; Count the letter,
	inc esi ;  then increments ESI, essentially moving us on to our next letter
	jmp CSLoop ; Repeat back at loop start

CSExit:

	ret
CompressString ENDP

;-------------------------------- LetterCount Procedure 
;	Functional Details: Practically this procedure recieves a memory offset for 
;	a letter character (upper or lowercase). Converts that character to lower 
;	case. Then subtracts the ascii base, giving us a=1,b=2,c=3 ect. We then 
;	translate that to a DWORD array offset and increment the number we find 
;	there. Essentially making a 0-25, aka a-z, array of letter counts 
;	corrisponding to their letter.
;	Registers:	EAX recieved the letter's ASCII value, and we hold the results 
;	of our calculations here as well.
;				EDI holds the base offset for our letterCount array, and then 
;				adds the generated offset so we can store our letter count in 
;				the proper position.
;	Input: Takes no strict input but does recieve a ASCII character value, and 
;	an OFFSET for our letterCount array
;	Output: Makes no strict output but does modify the values in the 
;	letterCount array.
;	Memory Locations: Utilizes the letterCount array offset
LetterCounter PROC USES EAX EDI
	
	; Recieve ASCII letter vlaue
	movsx eax, al ; Sign extend to avoid problems
	
	; Use a fancy OR trick to make all characters lowercase
	or al, 00100000b ; aka 32d

	; subtract ASCII base making 'a'=0, 'b'=1, ect
	sub eax, 01100001b ;aka 97d 

	; select letterCount[eax*4]
	imul eax, TYPE letterCount ; Taking the letter value, we multiply that by TYPE letterCount (4) the result is where in the array our letter's count values are located
	add  edi, eax ; Increment EDI by the result so we're pointing at the number position of the letter

	inc DWORD PTR[edi] ; Add 1 to the letter count for that letter's position

	ret
LetterCounter ENDP 

;-------------------------------- DisplayCount Procedure 
;	Functional Details: Practically this procedure loops through the memeory 
;	offset positions of the letterCount array, displaying the values therein, 
;	exiting when we've gone through all positions.
;	Registers:	EAX holds the letterCount[] value
;				ECX holds our maximum number of loops value
;				ESI holds the memory offset for the letterCount[esi] value
;	Input: Takes no strict input but does recieve the letterCount memory 
;	offset, and maximum loops through ECX.
;	Output: This displays the lettereCount[esi] value, followed by two 
;	spaces for formatting purposes.
;	Memory Locations: Utilizes the offset for letterCount
DisplayCount PROC USES EAX ECX ESI

	
	mov dCLoopCounter, 0 ; Set dCLoopCounter to 0, a fresh start
	movsx ecx, cl ; Sign extend to avoid any sign problems

DCLoop:	
	mov eax, [esi] ; Move the value from [esi] into EAX
	call WriteDec ;  and write it to the screen
	
	inc dCLoopCounter ; Increment dCLoopCounter and 
	cmp dCLoopCounter, cl ; compare to ECX, 
	je DCExit ; if equal exit

	add esi, TYPE letterCount ; Increment the memory offset to the next letter count value

	
	mov al, strSpace ; Move the value of a space into al
	call WriteChar ; Add a couple of spaces after decimal write
	call WriteChar ; Add a couple of spaces after decimal write

	jmp DCLoop ; Repeat through the entire letterCount array

DCExit:

	ret
DisplayCount ENDP

;-------------------------------- InitializeCount Procedure 
;	Functional Details: This walks through and overwites the letterCount 
;	array with all 0's
;	Registers:	ESI holds the letterCount memory offset
;				ECX holds the total of positions we'll be moving through
;	Input: Takes no strict input but does access letterCount through it's 
;	offset [ESI]
;	Output: Makes no strict output but does modify the letterCount array
;	Memory Locations: Accesses the letterCount offset through esi
InitializeCount PROC USES ESI ECX

	; Had a little fun with these conditionals from Chapter 6
	; Overwrite the letter count with 0s
	.REPEAT
		mov DWORD PTR[esi], 0 ; Overwrite the value in ESI to 0
		inc esi	; Increment offset
		dec ecx ; Decriment ecx
	.UNTIL ecx == 0 ; Repeat until ECX is 0

	ret
InitializeCount ENDP

;-------------------------------- Main Procedure 
;	Functional Details: Practically this procedure informs the user we'll be 
;	taking in a string, takes in the string, displays it, calls to edit it, 
;	displays the edited string, and finally asks the user if they'd like to do 
;	it all again.
;	Outputs: We display a message asking for string input, the string is 
;	displayed while being typed, the string is again displayed whit an 
;	"Original String: " label, then the edited string is displayed with a 
;	"Compressed String: " label, then a message asking if the user would like 
;	to enter another string is displayed.
;	Registers:	EDX is used to reference several string memory offsets.
;				ECX is used to set the max length of a ReadString call's input
;				ESI is used to poutn to the input string in order that it might 
;				be edited though the CompressString and MoveDown procedures.
;	Memory Locations: stringToEdit is specifically used to store the user 
;	entered string. charAgain is explicitly used to hold the value (Y or N) 
;	for if the user wants to go again. There are also many string offsets used 
;	to display various messages.
main PROC
	
MainLoopStart:
	; Initialize the letterCount array to all 0's
	mov ecx, SIZEOF letterCount - TYPE letterCount ; Set the counter to the size of our lettercount array minus one array unit size
	mov esi, OFFSET letterCount ; set ESI to the offset for our letterCount array
	call InitializeCount ; Call the procedure which sets letterCount to all 0s

	mov edx, OFFSET msgInstruction ; Move the welcome message offset into edx
	call WriteString ;Dislpay the welcome message
	call Crlf ; Drop down a line for formatting purposes
	call Crlf ; New line for readability

	; Take input of the string
	mov edx, OFFSET stringToEdit ; Move the offset for our string array into edx
	mov ecx, maxLength ; Set the max length for our string into ecx
	call ReadString ; Read input from the keyboard/user
	call Crlf ; New line for readability

	; Display the "Original String" message
	mov edx, OFFSET msgOriginal ; Move the offset for our 'original string' message into edx
	call WriteString ; Write that string!
	mov edx, OFFSET stringToEdit ; Now we wnt to display the original string so we move that offset into edx
	call WriteString ; and display it
	call Crlf ; New line for readability
	call Crlf ; New line for readability

	; Edit the string
	mov esi, OFFSET stringToEdit ; CompressString needs esi to point to the beginning of our string
	mov edi, OFFSET letterCount ; The LetterCount procedure requires edi point to the offset of our letterCount, and since CompressString calls LetterCount we need to provide it!
	call CompressString

	; Display the "Compressed String" message and the edited string
	mov edx, OFFSET msgCompressed ; Move the offset of our message into edx
	call WriteString ; and display it
	mov edx, OFFSET stringToEdit ; Move the offset for our compressed string into edx
	call WriteString ; and display it
	call Crlf ; New line for readability
	call Crlf ; New line for readability

	; Write the 'Output Banner' to the console
	mov edx, OFFSET msgOutputBanner ; Move the offset of our message into edx
	call WriteString ; and display it
	call Crlf ; New line for readability

	 
	mov esi, OFFSET letterCount ; DisplayCount requires the offset of our letterCount in esi
	mov ecx, LENGTHOF letterCount ; and the length in ecx
	call DisplayCount ; Displays the letter counts corrisponding the above letter in the 'Output Banner'
	call Crlf ; New line for readability
	call Crlf ; New line for readability
	
MainAgain: ; "Would you like to enter a new string?" portion of the program
	
	mov  edx,OFFSET msgAgain ; move the offset for our message into edx
	call WriteString ; and display it

	call ReadChar ; Take input from the user regarding repeating the program
	call WriteChar ; Display the character typed, this is necessary since ReadChar doesn't display the Char typed
	call Crlf ; Move the display line down 1
	call Crlf ; Move the display line down 1

	movsx eax, al ; we need to overwrite the rest of the EAX register with the sign from AL becasue ReadChar loads the value to AL
	mov charAgain, al ; Store the read character in our memory operand

	INVOKE Str_ucase, ADDR charAgain ; Convert input Char to Uppercase
	
	; Compare input character to uppercase Y, if equals jump to MainLoopStart
	mov al, charAgain ; Move our input char value into al
	cmp al, strY ; Compare to Y
	je MainLoopStart ; If equal, jump to the top of the program

	; Compare input to uppercase N, if equals, jump to MainExit
	cmp al, strN ; Compare our input char to N
	je MainExit ; if equal move to the exit portion of our program

	jmp MainAgain ; If neither y or n was pressed, repeat prompt

MainExit:

    ; Call Irvine's exit procedure
	exit
main ENDP
END main
