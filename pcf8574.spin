'' =================================================================================================
''
''   File....... pcf8574,spin
''   Author..... Scott Baker
''   E-mail..... smbaker@gmail.com
''
'' =================================================================================================


con

  PCF8574 = %0100_000_0                                        ' I2C device ID for PCF8574


obj

  i2c : "jm_i2c"


pub start(sclpin, sdapin)
  i2c.setupx(sclpin, sdapin)


pub wr_gpio(value, addr)
  i2c.start                                                     ' start transaction
  i2c.write(PCF8574 | (addr << 1))                              ' write id
  i2c.write(value)                                              ' write reg value
  i2c.stop                                                      ' end transaction


pub rd_gpio(addr) | id, value
  ' XXX this function is unverified XXX
  id := PCF8574 | (addr << 1)                                  

  i2c.start                                                     ' start transaction  
  i2c.write(id | %1)                                            ' id for read
  value := i2c.read(i2c#NAK)                                    ' read value from reg
  i2c.stop                                                      ' end transaction

  return value                                                  ' return value to caller


  
 
dat { license }

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}}