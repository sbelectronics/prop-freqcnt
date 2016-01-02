'' =================================================================================================
''
''   File....... jm_mcp23017.spin
''   Author..... Jon "JonnyMac" McPhalen
''               Copyright (c) 2011-14 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 20 AUG 2014
''               -- modified to allow all addresses from single object
''               -- streamlined with wr_reg() and rd_reg()
''
'' =================================================================================================


con { fixed io pins }

  RX1 = 31                                                      ' programming / terminal
  TX1 = 30
  
  SDA = 29                                                      ' eeprom / i2c
  SCL = 28


con { mcp23017 regs }

  MCP23017 = %0100_000_0                                        ' I2C device ID for MCP23017

  ' command bytes for standard POR settings
  ' -- IOCON.BANK = 0
  
  IODIRA   = $00                                                ' command bytes 
  IODIRB   = $01 
  IPOLA    = $02 
  IPOLB    = $03 
  GPINTENA = $04 
  GPINTENB = $05 
  DEFVALA  = $06 
  DEFVALB  = $07 
  INTCONA  = $08 
  INTCONB  = $09 
  IOCON    = $0A 
  GPPUA    = $0C 
  GPPUB    = $0D 
  INTFA    = $0E 
  INTFB    = $0F 
  INTCAPA  = $10 
  INTCAPB  = $11 
  GPIOA    = $12 
  GPIOB    = $13 
  OLATA    = $14
  OLATB    = $15 


obj

  i2c : "jm_i2c"


pub start(sclpin, sdapin)

'' Connect MCP23017 to I2C buss
'' -- sclpin and sdapin are I2C buss pins

  i2c.setupx(sclpin, sdapin)                                    ' connect to i2C


pub wr_reg(reg, value, addr)

'' Write value to register in device at addr
'' -- see constants section for valid registers
'' -- see MCP23017 docs for details on register value
'' -- addr is device address, %000 to %111

  i2c.start                                                     ' start transaction
  i2c.write(MCP23017 | (addr << 1))                             ' write id
  i2c.write(reg)                                                ' write reg #
  i2c.write(value)                                              ' write reg value
  i2c.stop                                                      ' end transaction


pub rd_reg(reg, addr) | id, value

'' Read value from register in device at addr
'' -- see constants section for valid registers
'' -- see MCP23017 docs for details on register value
'' -- addr is device address, %000 to %111

  id := MCP23017 | (addr << 1)                                  ' id for write

  i2c.start                                                     ' start transaction
  i2c.write(id)                                                 ' write id
  i2c.write(reg)                                                ' write reg #
  i2c.start                                                     ' re-start     
  i2c.write(id | %1)                                            ' id for read
  value := i2c.read(i2c#NAK)                                    ' read value from reg
  i2c.stop                                                      ' end transaction

  return value                                                  ' return value to caller


con

  { ------------------------------- }
  {  Named methods for easy access  }  
  { ------------------------------- }
   
  
pub cfg_dira(dirbits, addr)

'' Configure GPIOA IO pins
'' -- 0 bit = output, 1 bit = input
'' -- addr is device address, %000 to %111

  wr_reg(IODIRA, dirbits, addr)


pub cfg_pola(polbits, addr)  

'' Configure GP0 input polarity
'' -- 0 bit = normal, 1 bit = inverted
'' -- addr is device address, %000 to %111

  wr_reg(IPOLA, polbits, addr)


pub cfg_iocon(iocbits, addr) 

'' Configure IOCON bits
'' -- see documentation for details on iocon bits
'' -- addr is device address, %000 to %111

  wr_reg(IOCON, iocbits, addr)
  

pub cfg_pua(pubits, addr)

'' Configure GPIOA pull-ups
'' -- 1 bit = pull-up pin via 100K
'' -- addr is device address, %000 to %111

  wr_reg(GPPUA, pubits, addr)
  

pub wr_gpioa(outbits, addr)

'' Write outbits to GPIOA pins
'' -- only pins set as outputs affected
'' -- addr is device address, %000 to %111

  wr_reg(GPIOA, outbits, addr)


pub rd_gpioa(addr) | devid, inbits

'' Read GPIOA bits
'' -- addr is device address, %000 to %111

  return rd_reg(GPIOA, addr)


pub cfg_dirb(dirbits, addr)

'' Configure GPIOB IO pins
'' -- 0 bit = output, 1 bit = input
'' -- addr is device address, %000 to %111

  wr_reg(IODIRB, dirbits, addr)


pub cfg_polb(polbits, addr)

'' Configure GPIOB input polarity
'' -- 0 bit = normal, 1 bit = inverted
'' -- addr is device address, %000 to %111

  wr_reg(IPOLB, polbits, addr)


pub cfg_pub(pubits, addr)

'' Configure GPIOB pull-ups
'' -- 1 bit = pull-up pin via 100K
'' -- addr is device address, %000 to %111

  wr_reg(GPPUB, pubits, addr)
 

pub wr_gpiob(outbits, addr) 

'' Write value to GPIOB
'' -- addr is device address, %000 to %111

  wr_reg(GPIOB, outbits, addr)


pub rd_gpiob(addr) | devid, inbits

'' Read GPIOB bits
'' -- addr is device address, %000 to %111

  return rd_reg(GPIOB, addr)
  
 
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