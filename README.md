# EmbeddedHC12_Calculator_Simple
program to dimm the LED lights on CSM-12C128 board as follows:\
(1) Initially turn on the LED 3 and 4; and turn off the LED 1 and 2.\
(2) Instruct the user to enter the LED 1 light level, 0 to 100 in range.\
(3) When a user enters the LED 1 light level followed by an 'Enter' (ie. 'Return') key, on a HyperTerminal, dim the LED 1 light to that level. For example, if a user type '17' followed by an 'Enter' key hit on the HyperTerminal, then turn on LED 1 with light level 17%.\
(4) Input positive decimal number only, followed by an 'Enter' (ie. 'Return') key.\
(5) Input maximum three digit number only, 0 to 100 in range.\
(6) Input number with leading zero is OK, or OK to flag this as invalid input.\
(7) Input only one number, no spaces.\
(8) Echo-print user input.\
(9) In case of an invalid input, print error message on the next line: 'Invalid input'\
(10) Allow a user to enter the LED 1 light level as many time as he/she desires.
# Display Example
Welcome!  Enter the LED 1 light level, 0 to 100 in range, and hit 'Enter'.

17                     ;valid input, light level set to 17%

35                     ;valid input, light level set to 35%

100                    ;valid input, light level set to 100%

1234                   ;too many characters, light level not changed\
invalid input

102                    ;out of range, light level not changed\
invalid input

5AB                    ;wrong characters, light level not changed\
invlaid input

0                      ;valid input, light level set to 0%

                       ;no digit - enter key only, light level not changed\
invalid input

3 8\
invalid input

-15\
invalid input

015                     ;valid input, light level set to 15% (OK to flag this as invalid input)

A7\
invalid input
