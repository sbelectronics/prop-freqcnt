VAR
   long InPin
   long Gate
   long Frequency
   long myStack[12]  

PUB Start(finpin)
   InPin := finpin
   Gate := 1000

   cognew(CountFreq, @myStack)

PUB GetFreq
   return Frequency

PRI CountFreq | freq
  'Pulses are sampled on this pin.
  DirA[InPin] := 0
  CTRA := 0 'Clear CTRA settings
  CTRA := (%01010 << 26 ) | (%001 << 23) | (0 << 9) | (InPin) 'Trigger to count rising

  FRQA := 1 'Count 1 pulses on each trigger
  repeat
    PHSA := 0 'Clear accumulated value
    waitcnt(clkfreq/1000 * Gate + cnt)
    Frequency := PHSA * (1000/Gate)  
