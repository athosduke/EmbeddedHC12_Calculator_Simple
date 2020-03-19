***********************************************************
*
* Title:       Homework 6
*
* Rivision:    V4.5
*
* Date:        Oct 16 2019
*
* Programmer:  Songmeng Wang
*
* Company:    The Pennsylvania State University
*
* Algorithm:   Loops and conditional branches of CSM-12C128 board
*
* Register use:A accumulator:delay time counter
*             B accumulator:delay time counter
*             X register:delay loop counter
*             Y register:delay loop counter
*
* Memory use: RAM locations from $3000 for data
*                           from $3100 for instruction
*
* Input: Parameters hard coded in program
*
* Output: LED 1,2,3,4 at PORT 4,5,6,7
*
* Observation: This is the program that hold LED 2 on and rise/fall 
*             light level of LED 4 sequentially 
*
* Comments: This program is developed and simulated using Codeworrior 
*          development software
*
***********************************************************
;export symbols
              XDEF      Entry          ; export 'Entry' symbol
              ABSENTRY  Entry          ; for assembly entry point

;include derivative specific macros
PORTB         EQU     $0001
DDRB          EQU     $0003
;add more for the ones you need

SCISR1        EQU     $00cc            ; Serial port (SCI) Status Register 1
SCIDRL        EQU     $00cf            ; Serial port (SCI) Data Register

;following is for the TestTerm debugger simulation only
;SCISR1        EQU     $0203            ; Serial port (SCI) Status Register 1
;SCIDRL        EQU     $0204            ; Serial port (SCI) Data Register

CR            equ     $0d              ; carriage return, ASCII 'Return' key
LF            equ     $0a              ; line feed, ASCII 'next line' character

;variable/data section below
              ORG     $3000            ; RAMStart defined as $3000
                                       ; in MC9S12C128 chip ($3000 - $3FFF)
Count         DS.B    1
Buff          DS.B    5
num           DS.B    1
Counter1      DC.W    $0004                ; initial X register count number
Counter2      DC.W    $0001                ; initial Y register count number


; Each message ends with $00 (NULL ASCII character) for your program.
;
; There are 256 bytes from $3000 to $3100.  If you need more bytes for
; your messages, you can put more messages 'msg3' and 'msg4' at the end of 
; the program.
                                  
StackSP                                ; Stack space reserved from here to
                                       ; StackST

              ORG  $3100
;code section below
Entry
              LDS   #Entry             ; initialize the stack pointer

; add PORTB initialization code here

              LDAA       #%11110000    ; set PORTB bit 7,6,5,4 as output, 3,2,1,0 as input
              STAA       DDRB          ; LED 1,2,3,4 on PORTB bit 4,5,6,7
                                       ; DIP switch 1,2,3,4 on PORTB bit 0,1,2,3.
              LDAA       #%00110000    ; Turn off LED 1,2 at PORTB bit 4,5
              STAA       PORTB         ; Note: LED numbers and PORTB bit numbers are different

              ldx   #msg1              ; print the first message, 'Welcome!.... '
              jsr   printmsg
            
              ldaa  #CR                ; move the cursor to beginning of the line
              jsr   putchar            ;   Cariage Return/Enter key
              ldaa  #LF                ; move the cursor to next line, Line Feed
              jsr   putchar
                        
newlooop      ldy   #Buff              ; initialize X
              clr   Count              ; initialize Count 

looop         
              jsr   getchar            ; type writer - check the key board
              cmpa  #$00               ;  if nothing typed, keep checking
              beq   looop
                                       ;  otherwise - what is typed on key board
              jsr   putchar            ; is displayed on the terminal window
             
              staa  1,Y+               ; save char in buff, increment X
              inc   Count              ; increment Count
                            
              cmpa  #CR
              bne   looop              ; if Enter/Return key is pressed, move the
charchecked   ldaa  #LF                ; cursor to next line
              jsr   putchar
              
              dey
              dec   Count             ; decrement 1 caused by enter
              
              ldaa  Count              ; load Count num into A              
              
              cmpa  #$03
              bgt   errormsg1          ; branch to errormsg if enter more than 3 char
              
              cmpa  #$00
              beq   errormsg2          ; branch to errormsg2 if nothing entered
                            
              dey   
              jsr   getnum             ; get the number entered in num

              ldx   #msg6
              jsr   printmsg
              
              ldaa  #CR                ; move the cursor to beginning of the line
              jsr   putchar            ;   Cariage Return/Enter key
              ldaa  #LF                ; move the cursor to next line, Line Feed
              jsr   putchar
              
              ldy   #Buff              ; initialize X
              clr   Count              ; initialize Count
              
              ldaa  num
              
              cmpa  #$64
              beq   fulldim
              
              cmpa  #$00
              lbeq  zerodim
              
dimming       bclr  PORTB,%00010000    ;
              jsr   timedelay          ;
              bset  PORTB,%00010000    ;          ;
              jsr   timedelayinv       ;
              
              jsr   getchar            ; type writer - check the key board
              cmpa  #$00               ;  if nothing typed, keep checking
              beq   dimming
              
              jsr   putchar            ; is displayed on the terminal window
             
              staa  1,Y+               ; save char in buff, increment X
              inc   Count              ; increment Count
                            
              cmpa  #CR
              bne   dimming            ; if Enter/Return key is pressed, move the
              bra   charchecked
              
errormsg1     ldx   #msg2
              jsr   printmsg           ; print too many characters
              bra   return

errormsg2     ldx   #msg3
              jsr   printmsg           ; print no digit
              bra   return

errormsg3     ldx   #msg4
              jsr   printmsg           ; print invalid char
              bra   return

errormsg4     ldx   #msg5
              jsr   printmsg           ; print out of range
              bra   return

return        ldaa  #CR                ; move the cursor to beginning of the line
              jsr   putchar            ;   Cariage Return/Enter key
              ldaa  #LF                ; move the cursor to next line, Line Feed
              jsr   putchar
              
              lbra  newlooop

fulldim       bclr  PORTB,%00010000
              lbra  looop
zerodim       bset  PORTB,%00010000
              lbra  looop               
               
;subroutine section below

;***********printmsg***************************
;* Program: Output character string to SCI port, print message
;* Input:   Register X points to ASCII characters in memory
;* Output:  message printed on the terminal connected to SCI port
;* 
;* Registers modified: CCR
;* Algorithm:
;     Pick up 1 byte from memory where X register is pointing
;     Send it out to SCI port
;     Update X register to point to the next byte
;     Repeat until the byte data $00 is encountered
;       (String is terminated with NULL=$00)
;**********************************************
NULL           equ     $00
printmsg       psha                   ;Save registers
               pshx
printmsgloop   ldaa    1,X+           ;pick up an ASCII character from string
                                       ;   pointed by X register
                                       ;then update the X register to point to
                                       ;   the next byte
               cmpa    #NULL
               beq     printmsgdone   ;end of strint yet?
               jsr     putchar        ;if not, print character and do next
               bra     printmsgloop

printmsgdone   pulx 
               pula
               rts
;***********end of printmsg********************


;***************putchar************************
;* Program: Send one character to SCI port, terminal
;* Input:   Accumulator A contains an ASCII character, 8bit
;* Output:  Send one character to SCI port, terminal
;* Registers modified: CCR
;* Algorithm:
;    Wait for transmit buffer become empty
;      Transmit buffer empty is indicated by TDRE bit
;      TDRE = 1 : empty - Transmit Data Register Empty, ready to transmit
;      TDRE = 0 : not empty, transmission in progress
;**********************************************
putchar        brclr SCISR1,#%10000000,putchar   ; wait for transmit buffer empty
               staa  SCIDRL                      ; send a character
               rts
;***************end of putchar*****************


;****************getchar***********************
;* Program: Input one character from SCI port (terminal/keyboard)
;*             if a character is received, other wise return NULL
;* Input:   none    
;* Output:  Accumulator A containing the received ASCII character
;*          if a character is received.
;*          Otherwise Accumulator A will contain a NULL character, $00.
;* Registers modified: CCR
;* Algorithm:
;    Check for receive buffer become full
;      Receive buffer full is indicated by RDRF bit
;      RDRF = 1 : full - Receive Data Register Full, 1 byte received
;      RDRF = 0 : not full, 0 byte received
;**********************************************
getchar        brclr SCISR1,#%00100000,getchar7
               ldaa  SCIDRL
               rts
getchar7       clra
               rts
;****************end of getchar**************** 


;*****************getnum***********************
;*input: Count, Buff, X
;*output: number in num
;**********************************************
getnum         
               ldab   1,Y-    ; load last char in B, decrement X
               subb   #$30    ; subtract by 30
               
               cmpb   #$09     ;
               bgt    errormsg3 ; branch if greater than 9
               cmpb   #$00     ;
               blt    errormsg3 ; branch if less than 0
               
               stab   num     ; store in num

               dec    Count   ; decrement Count
               beq    done    ; return if count = 0
               
               ldab   1,Y-    ; load second char in B, decrement X
               
               subb   #$30    ; subtract by 30
               
               cmpb   #$09    ;
               lbgt    errormsg3 ; branch if greater than 9
               cmpb   #$00    ;
               lblt    errormsg3 ; branch if less than 0
               
               ldaa   #$0A    ; store 10 in A
               mul            ; multiply A and B, stored in D
               addb   num     ; add last num
               
               stab   num     ; store in num

               dec    Count   ; decrement Count
               beq    done    ; return if count = 0
                              
               
               ldab   1,Y-    ; load third char in B, decrement X

               subb   #$30    ; subtract by 30
               
               cmpb   #$09     ;
               lbgt   errormsg3 ; branch if greater than 9
               cmpb   #$00     ;
               lblt   errormsg3 ; branch if less than 0
               cmpb   #$01     ;
               lbgt   errormsg4 ; branch if greater than 1
               
               ldaa   #$64     ; store 100 in A
               mul            ; multiply A and B
               addb   num     ; add last num
               
               cmpb   #$64    ;
               lbgt   errormsg4 ; branch if greater than 100
               
               stab   num     ; store in num

done           rts          

;*****************timedelay***********************
;*
;*
;**********************************************
timedelay      ldab   num
loopdelay      jsr    delay10us
               decb
               bne    loopdelay
               rts 

;*****************timedelayinv*****************
;*
;*
;**********************************************
timedelayinv   ldab   num
               subb   #$64
               negb

loopdelayinv   jsr    delay10us
               decb
               bne    loopdelayinv
               rts
               
               
;************************************************************
; delay10us subroutine
; 
; This subroutine causes 10 us delay
; Input: a 16 bit count number in 'Counter2'
; Output: time delay, cpu cycle waisted
; Registers in use: Y register, as counter
; Memory locations in use: a 16 bit input number in 'Counter2'
;

delay10us
          PSHY
          
          LDY       Counter2             ; long delay by
dly10loop JSR       delay1us             ; Y*delay1us
          DEY
          BNE       dly10loop
          
          PULY
          RTS

;************************************************************
; delay1ussubroutine
;
; This subroutine causes 1 us delay
; Input: a 16 bit count number in 'Counter1'
; Output: time delay, cpu cycle waisted
; Register in use: X register, as counter
; Memory locations in use: a 16 bit input number in 'Counter1'
;

delay1us
          PSHX
          
          LDX       Counter1             ; short delay
dly1loop  DEX
          BNE       dly1loop
          
          PULX
          RTS
                


;OPTIONAL
;more variable/data section below
; this is after the program code section
; of the RAM.  RAM ends at $3FFF
; in MC9S12C128 chip

msg1           DC.B    'Welcome!  Enter the LED 1 light level,0 to 100 in range, and hit Enter.', $00
msg2           DC.B    'too many characters, light level not changed. ', $00
msg3           DC.B    'no digit - enter key only, light level not changed', $00
msg4           DC.B    'wrong characters, light level not changed', $00
msg5           DC.B    'out of range, light level not changed', $00
msg6           DC.B    'valid input, light level changed', $00


               END               ; this is end of assembly source file
                                 ; lines below are ignored - not assembled/compiled
