' stty -F /dev/ttyUSB0 cs8 115200 ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke noflsh -ixon -crtscts
' cat /dev/ttyUSB0

CON
   BIT18MASK = (1 << 17)
VAR 
   long ClkPin, DataPin, LEPin
   long myStack[12]

PUB Setup(aclkpin, adatapin, alepin)
   ClkPin := aclkpin
   DataPin := adatapin
   LEPin := alepin

   dira[ClkPin] ~~
   dira[DataPin] ~~
   dira[LEPin] ~~

   outa[ClkPin] := 0
   outa[DataPin] := 0
   outa[LEPin] := 0

PUB WriteWordOld(w)
   repeat 18
       if ((w&BIT18MASK) == BIT18MASK)
           outa[DataPin] := 1
       else
           outa[DataPin] := 0
       outa[ClkPin] := 1
       outa[ClkPin] := 0

       w := w <- 1 

  outa[LEPin] := 1                                                        ' Latch The Outputs
  outa[LEPin] := 0

PUB WriteWord(w)
   outa[LEPin] := 0
   repeat 18
       outa[ClkPin] := 0 
       if ((w&BIT18MASK) == BIT18MASK)
           outa[DataPin] := 1
       else
           outa[DataPin] := 0
       w := w << 1

       waitcnt(clkfreq / 10_000 + cnt)   

       outa[ClkPin] := 1

       waitcnt(clkfreq / 10_000 + cnt)    

  outa[DataPin] := 1
  outa[LEPin] := 1

  waitcnt(clkfreq / 10_000 + cnt)

PUB WriteN(nb_cntr, na_cntr, ctl_word) | w
   w := (nb_cntr << 8) | (na_cntr << 3) | (ctl_word << 1)
   WriteWord(w) 

PUB WriteR(testbit, rs, pd_pol, cp_tri, r_cntr) | w
   w := (testbit << 14) | (rs << 13) | (pd_pol <<12) | (cp_tri << 11) | (r_cntr << 1) | 1
   WriteWord(w)