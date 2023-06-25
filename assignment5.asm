***************************************
*
* Name: Logan Deal
* ID: REDACTED
* Date: 11/7/2022
* Lab5
*
* Program description:
*
* Generate the sum of integer squares numbers from an "input" array and store results in an "output" array
*
* Pseudocode of Main Program: 
* 
* unsigned int NARR[5] = {1, 5, 100, 200, 254};
* #define SENTIN $FF
* unsigned int RESARR[20];
* 
* unsigned int* NARRptr = &NARR[0];
* unsigned int* RESARRptr = &RESARR[0];
* unsigned int* NARRptrsv;
* unsigned int* NARRptrsv;
*
* while (*NARRptr != SENTIN) {
*	NARRptrsv = NARRptr;
*	RESARRptrsv = RESARRptr;
*	*RESARRptr = getSum(*NARRptr);
*	RESARRptr++;
*	RESARRptr++;
*	RESARRptr++;
*	RESARRptr++;
*	NARRptr++;
* }
*
*---------------------------------------
*
* Pseudocode of Subroutine:
*
* unsigned int getSum(N) {
*	unsigned int result[];
*	unsigned int sq_result;
*	unsigned int current;
*	unsigned int add;
*	unsigned int end;
*	unsigned int* ptr;
*
*	result = 0;
*	CF = 0;
*	current = N;
*
*	while (current >= 1) {
*		sq_result = 0;
*		add = 1;
*		end = current + current - 1;
*	
*		while (add <= end) {
*			sq_result += add;
*			add += 2;
*		}
*
*		ptr = &result[2];
*		*ptr += sq_result;
*		
*		ptr--;
*		ptr--;
*		
*		*ptr += CF;
*		current--;
*	}
*	
*	return result;
* }
*	
***************************************
* start of data section
		ORG	$B000
NARR		FCB	1, 5, 100, 200, 254, $FF
SENTIN	EQU	$FF

		ORG $B010
RESARR	RMB	20	


* define any variables that your MAIN program might need here
* REMEMBER: Your subroutine must not access any of the main
* program variables including NARR and RESARR.
NARRPTRSV	RMB	2
RESARRPTRSV	RMB	2


		ORG	$C000
		LDS	#$01FF		
* start of your program
* declare NARR and RESARR ptrs
		LDX	#NARR
		LDY	#RESARR
* check if at end of NARR
WHILE		LDAA	0,X
		CMPA	#SENTIN
		BEQ	ENDWHILE
* pass N to subroutine in register
		LDAA	0,X
* save NARRptr and RESARRptr so that X and Y registers can be used by subroutine
		STX	NARRPTRSV
		STY	RESARRPTRSV
* call subroutine
		JSR	SUB
* redeclare NARR and RESARR ptrs
		LDX	NARRPTRSV
		LDY	RESARRPTRSV
* pull return value off the stack and store in RESARR
		PULA
		PULB
		STD	0,Y
		PULA
		PULB
		STD	2,Y
* advance RESARR ptr
		INY
		INY
		INY
		INY
* advance NARR ptr
		INX
	
		BRA	WHILE
ENDWHILE	STOP

* NOTE: NO STATIC VARIABLES ALLOWED IN SUBROUTINE
* Local var stack order:
* ADD 2 bytes 0,Y
* END 2 bytes 2,Y
* SQ_RESULT 2 bytes 4,Y
* CURRENT 1 byte 0,X
* RESULT 4 bytes 1,X

		ORG	$D000
* start of your subroutine 
* pull return address, make a 4-byte hole for the return value, push return address	
SUB		PULX
		DES
		DES
		DES
		DES
		PSHX	
* open hole for result var
		DES
		DES
		DES
		DES
* set result var to 0
		TSX
		CLR 0,X
		CLR 1,X
		CLR 2,X
		CLR 3,X
* clear carry bit so that it can be utilized later
		CLC
* open hole for current var
		DES
		TSX
* set current to passed in N value
		STAA	0,X
* open hole for sq_result var
		DES
		DES
* open hole for end var
		DES
		DES
* open hole for add var
		DES
		DES
		TSY
* check for current >= 1
WHILE2	LDAA	0,X
		CMPA	#1
		BLO	ENDWHILE2
* set sq_result var to 0
		CLR	4,Y
		CLR	5,Y
* set add var to 1
		LDD	#1
		STD	0,Y
* set end var to 2*current...
		CLRA	
		LDAB	0,X
		STD	2,Y
		ADDD	2,Y
* ...-1
		SUBD	#1
		STD	2,Y
* check for add <= end
WHILE3	LDD	0,Y
		CPD	2,Y
		BHI	ENDWHILE3
* add add var to sq_result var
		LDD	4,Y
		ADDD	0,Y
		STD	4,Y
* increment add var by 2
		LDD	0,Y
		ADDD	#2
		STD	0,Y
		
		BRA	WHILE3
* add sq_result to lower bytes of result
ENDWHILE3	LDD	3,X
		ADDD	4,Y
		STD	3,X
* add carry to higher bytes of result
		LDD	1,X
		ADCB	#0
		ADCA	#0
		STD	1,X
* decrement current so that the next square can be calculated
		DEC	0,X

		BRA WHILE2
* load higher bytes of result into D register
ENDWHILE2	LDD	1,X
* store higher bytes of result in higher bytes of return value
		STD	7,X
* load lower bytes of result into D register
		LDD	3,X
* store lower bytes of result into lower bytes of return value
		STD	9,X
* close local var holes (11 bytes) and return
		INS
		INS
		INS
		INS
		INS
		INS
		INS
		INS
		INS
		INS
		INS

		RTS
