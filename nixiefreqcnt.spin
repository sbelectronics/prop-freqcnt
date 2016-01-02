OBJ
  debugled: "debugled"
  freqcnt: "freqcnt"
  lmx2322: "lmx2322"
  nixie1: "nixiedisplay"
  nixie2: "nixiedisplay"
CON
  _clkmode = xtal1 + pll16x
  _xinfreq        = 5_000_000
  UNIT_HZ = 0
  UNIT_KHZ = 1
  UNIT_MHZ = 2
VAR
   byte disp0, disp1, disp2
   byte units

pub main | v, debug0, debug1, debug2
  units:=UNIT_HZ

  freqcnt.Start(21)

  lmx2322.Setup(18, 19, 20)
  lmx2322.WriteN(4, 0, 0)  ' divide by (32+1)*0, then divide by 32*(4-0) = divide by 128 
  lmx2322.WriteR(1, 0, 1, 1, 2) ' test, rs, pd_pol, cp_tri, r_cntr

  debugled.Display(@debug0, 0{pin})

  debug0:=@disp0
  debug1:=@disp1
  debug2:=@disp2

  nixie1.Setup(28, 29, 1, 0)
  'nixie2.Setup(29, 28, 3, 2)

  nixie1.write_word(bcd_four(1234,false))
  nixie1.set_dp(3)

  v:=0
  repeat
      v := freqcnt.GetFreq / 100
      debugdecimal(v)
      waitcnt(clkfreq/1000 * 100 + cnt)

pub bcd_four(v,lz) | tmp
   ' convert a decimal value to four BCD digits
   ' if lz==True, then use leading zeros, otherwise use leading $A which nixie will output as blank
   tmp := 0
   if lz or (v>1000)
      tmp := tmp | ((v/1000) << 12)
   else
      tmp := tmp | ($A<<12)
      
   if lz or (v>100)
      tmp := tmp | ((v//1000/100) << 8)
   else
      tmp := tmp | ($A<<8)
      
   if lz or (v>10)
      tmp := tmp | ((v//100/10) << 4)
   else
      tmp := tmp | ($A<<4)
      
   if lz or (v>0)
      tmp := tmp | (v//10)
   else
      tmp := tmp | ($A)
   
   return tmp

pub bcd_two(v,lz) | tmp
   ' convert a decimal value to two BCD digits
   ' if lz==True, then use leading zeros, otherwise use leading $A which nixie will output as blank
   tmp := 0
   if lz or (v>10)
       tmp := tmp | ((v//100/10) << 8)
   else
       tmp := tmp | ($A<<4)
       
   if lz or (v>0)
       tmp := tmp | (v//10)
   else
       tmp := tmp | ($A)
       
   return tmp

pub display_frequency(v) | mult, tmp, digs, dp, lo_word
   if (v=>1100000) or ((units<>UNIT_KHZ) and (v=>1000000))
       units:=UNIT_MHZ
   elseif (v=>1100) or ((units<>UNIT_HZ) and (v=>1000))
       units:=UNIT_KHZ
   else
       units:=UNIT_HZ

  ' count number of digits
  digs:=1
  tmp:=v
  repeat while (tmp>10)
      digs:=digs+1
      tmp:=tmp/10

  ' count decimal point from the right
  if (units==UNIT_MHZ)
      dp:=6
  elseif (units==UNIT_KHZ)
      dp:=3
  else
      dp:=0

  ' adjust to fit 6 digits
  repeat while (digs>6)
      digs:=digs-1
      dp:=dp-1
      v:=v/10

  ' adjust decimal to count from the leftmost digit
  dp:=(6+1-dp)

  ' write the first four digits
  nixie1.write_word(bcd_four(v/100,false))

  ' compute the next two digits
  lo_word := bcd_two(v//100, (v/100)>0)
  if (lo_word == $A00)
      ' we always want at least one zero in the output  
      lo_word := 0

  ' write the next two digits and the units 
  if (units==UNIT_MHZ)
      nixie2.write_word(lo_word << 8) ' add in M and Hz symbols
  elseif (units==UNIT_KHZ)
      nixie2.write_word(lo_word << 8) ' add in K and Hz symbol
  else
      nixie2.write_word(lo_word << 8) ' add in Hz symbol

  ' set the decimal point
  if (dp=<4)
      ' decimal point is in first nixie bank
      nixie1.set_dp(dp)
      nixie2.set_dp(0)
  elseif (dp<=6)
      ' decimal point is in second nixie bank
      nixie1.set_dp(0)
      nixie2.set_dp(dp-4)
  else
      ' no decimal point
      nixie1.set_dp(0)
      nixie2.set_dp(0)  

pub debugdecimal(x) | v
   v:=x//100
   disp2:=(v/10)*16 + (v//10)
   v:=(x//10000)/100
   disp1:=(v/10)*16 + (v//10)
   v:=(x/10000)
   disp0:=(v/10)*16 + (v//10)