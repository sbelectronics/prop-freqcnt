OBJ
  'disp: "7segdirect"
  debugled: "debugled"
  freqcnt: "freqcnt"
  lmx2322: "lmx2322"
CON
  _clkmode = xtal1 + pll16x
  _xinfreq        = 5_000_000
VAR
   byte disp0, disp1, disp2

pub main | v, debug0, debug1, debug2
  'disp.Start(12, 0, 6)
  freqcnt.Start(21)

  lmx2322.Setup(18, 19, 20)
  lmx2322.WriteN(4, 0, 0)  ' divide by (32+1)*0, then divide by 32*(4-0) = divide by 128 
  lmx2322.WriteR(1, 0, 1, 1, 2) ' test, rs, pd_pol, cp_tri, r_cntr

  debugled.Display(@debug0, 0{pin})

  debug0:=@disp0
  debug1:=@disp1
  debug2:=@disp2

  v:=0
  repeat
      'v:=v+1
      v := freqcnt.GetFreq / 100
      'disp.setValue(v // 100, (v // 10000) / 100, v / 10000)
      debugdecimal(v)
      waitcnt(clkfreq/1000 * 100 + cnt)

pub debugdecimal(x) | v
   v:=x//100
   disp2:=(v/10)*16 + (v//10)
   v:=(x//10000)/100
   disp1:=(v/10)*16 + (v//10)
   v:=(x/10000)
   disp0:=(v/10)*16 + (v//10)