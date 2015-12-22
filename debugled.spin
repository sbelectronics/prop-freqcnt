{{
*****************************************************
* Debug LED17 driver v1.1      (1wire version)      *
* look at DebugLED17Demo as how to set hub addresss *
* Author: Tony Philipsson                           *
* Copyright 2011 Electrons Engineering              *
*****************************************************
}}
CON
    A1=  %1<<1             'the 17 LED Segments
    A2=  %1<<2
    B=   %1<<3
    C=   %1<<5
    D1=  %1<<6
    D2=  %1<<7
    E=   %1<<9
    F=   %1<<10
    G1=  %1<<21
    G2=  %1<<15
    H=   %1<<11
    I=   %1<<13
    J=   %1<<14
    K=   %1<<17
    L=   %1<<18
    M=   %1<<19
    DP=  %1<<22

PUB Display (hub1,pin)  'the values @hub1,LedPin from Demo
    CLKpin := |<pin     'set the pin and selfmod DAT
    delay1 := clkfreq/1_000_000         'selfmod DAT
    delay15 := clkfreq/1_000_000 * 15   'selfmod DAT
    delay30 := clkfreq/1_000_000 * 30   'selfmod DAT
    delay200 := clkfreq/1_000_000 * 200 'selfmod DAT
    cognew(@asm_entry, hub1) 'launch assembly program in a COG    

DAT
              org  0

asm_entry     mov       dira,CLKpin                     'make only clk pin an output
              mov       outa,CLKpin                     'set all pins in this cog to low but CLKpin high               

main          mov       digit,#6                        'we have 6 digits to multiplex
              mov       sink, #1                        'reset transistor sink 
              mov       hubadrs,par                     'reset  (par=hub address of @hub1)

loop1         rdword    mychar,hubadrs                  'get the hub address
              rdbyte    mychar,mychar                   'read the byte at this hubaddress
              test      digit,#1 wz                     'test for even numbers in digit
        if_nz and       mychar,#%1111                   'dec to hex, keep lower nibble
        if_z  shr       mychar,#4                       'dec to hex, shift down upper nibble
        if_nz add       hubadrs,#4                      'next long hub adress.
              movs      fontpnt,#font                   'reset font pointer
              add       fontpnt,mychar                  'add ascii code that mychar have to font pointer
              mov       bit_test,bit23                  'reset bit mask so bit 23 is only set
fontpnt       mov       serial,0-0                      'start a new serial data       
              or        serial,sink                     'fuse in the transistor sink bit
                                                        'inner loop starts here, send 23 clk pulses plus a long latch
loop2         test      serial,bit_test wz              'test serial data bitwize, set z                                
        if_nz mov       cnt,delay1                      'a quick clk, move 1uS to Shadow Cnt.
        if_z  mov       cnt,delay15                     'a long clk (15uS), let SER dip low
              andn      outa,CLKpin                     'set pin low 
              add       cnt,cnt                         'add current cnt to shadow cnt.
        if_nz waitcnt   cnt, delay15                    'wait 1uS, add 15us to cnt when done.
        if_z  waitcnt   cnt, delay30                    'wait 15us, add 30ms to cnt when done
              or        outa,CLKpin                     'set pin high 
              waitcnt   cnt, #0                         'wait the 15us or 30us that was set above
              shr       bit_test,#1 wz                  'shift right
        if_nz jmp       #loop2                          'if not zero, jmp 
         
              mov       cnt,delay200                    'prepare a 200us delay, letting Latch go low.    
              andn      outa,CLKpin                     'set pin low  
              add       cnt, cnt                        'add cnt to shadow cnt     
              waitcnt   cnt, delay200                   'wait 200us, add 400us to cnt when done.
              add       cnt, delay200                   '200+200=400, minimum is 300
              or        outa,CLKpin                     'set pin high. Add any of YOUR CODE between this....
              waitcnt   cnt, #0                         'and this line, delay200+200 above can be up to 1800
              shl       sink,#4                         'next digit
              djnz      digit, #loop1                   'have we done 6 digits?

              jmp       #main                           'restart
          


font          long      A1+A2+B+C+D1+D2+E+F+J+M         '0
              long      B+C                             '1
              long      A1+A2+B+D1+D2+E+G1+G2           '2
              long      A1+A2+B+C+D1+D2+G2              '3
              long      B+C+F+G1+G2                     '4
              long      A1+A2+D1+D2+F+G1+K              '5
              long      A1+A2+C+D1+D2+E+F+G1+G2         '6
              long      A1+A2+B+C                       '7
              long      A1+A2+B+C+D1+D2+E+F+G1+G2       '8
              long      A1+A2+B+C+D1+D2+F+G1+G2         '9
              long      A1+A2+B+C+E+F+G1+G2             'A
              long      A1+A2+B+C+D1+D2+G2+I+L          'B
              long      A1+A2+D1+D2+E+F                 'C
              long      A1+A2+B+C+D1+D2+I+L             'D
              long      A1+A2+D1+D2+E+F+G1+G2           'E
              long      A1+A2+E+F+G1                    'F
bit23         long      |<23                            'same as %1<<23,  serial bits to shift out
delay1        long      0-0
delay15       long      0-0
delay30       long      0-0
delay200      long      0-0 
CLKpin        long      0-0
hubadrs       res       1
sink          res       1                               'what transistor to sink
mychar        res       1
buffer        res       1
bit_test      res       1
serial        res       1
digit         res       1                              