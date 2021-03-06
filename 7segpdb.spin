VAR 
   long DigPin0, DigPin2, SegPin0, DigCount, SegPin7
   long myStack[12]
   long dispValue[4]
   long dispDot

PUB Start(digpin, segpin, digits)
   DigPin := digpin
   DigPin2 := digpin+2
   SegPin0 := segpin
   SegPin7 := segpin+7
   DigCount := digits

   dispValue[0] := 56
   dispValue[1] := 34
   dispValue[2] := 12
   
   cognew(ShowValue, @myStack)

PUB SetValue(v0, v1, v2)
   dispValue[0] := v0
   dispValue[1] := v1
   dispValue[2] := v2

PUB SetColons(v)
   if v
       dispValue[3] := 22
   else
       dispValue[3] := 0

PUB SetDot(n, v) | mask
   mask := (1 << n)
   if v
      dispDot |= mask
   else
      dispDot &= ! mask 
      
   
PRI ShowValue | digPos, displayValue, wordPos, divisor, v
   dira[DigPin0..DigPin2] ~~
   dira[SegPin0..SegPin7] ~~

   repeat
      displayValue := dispValue

      repeat wordPos from 0 to 2
          divisor := 1
          repeat digPos from 0 to 1
             outa[SegPin7..SegPin0] ~
             outa[DigPin0..DigPin2] := byte[@DigSel + (wordPos*2) + digPos]
             v := byte[@Dig0 + dispValue[wordPos] / divisor // 10] 
             if (dispDot & (1 << (wordPos*2+digPos)))
                 v := v | %10000000             
             outa[SegPin7..SegPin0] := v

             divisor := divisor * 10

             waitcnt (clkfreq / 10_000 + cnt)
          

' segPin0 top
' segPin1 rtop
' segPin2 rbot
' segPin3 bot
' SegPin4 lbot
' SegPin5 ltop
' SegPin6 mid

DAT
   DigSel        byte 3
                 byte 5
                 byte 1
                 byte 6
                 byte 2
                 byte 4

   Dig0          byte %00111111
   Dig1          byte %00000110
   Dig2          byte %01011011
   Dig3          byte %01001111
   Dig4          byte %01100110
   Dig5          byte %01101101
   Dig6          byte %01111101
   Dig7          byte %00000111
   Dig8          byte %01111111
   Dig9          byte %01100111

   