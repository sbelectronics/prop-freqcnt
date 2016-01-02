obj
   mcp23017: "jm_mcp23017"
   pcf8574: "pcf8574"
var
   byte mcpaddr
   byte pcfaddr
   byte dp

pub Setup(sclpin, sdapin, amcpaddr, apcfaddr)
   mcp23017.start(sclpin, sdapin)
   pcf8574.start(sclpin, sdapin)
   mcpaddr := amcpaddr
   pcfaddr := pcfaddr
   ' configure as output
   mcp23017.cfg_dira(0, mcpaddr)
   mcp23017.cfg_dirb(0, mcpaddr)

pub write_word(v)
   ' port a has the leftmost two digits
   ' port b has the rightmost two digits
   ' on each port, the digits are swapped
   mcp23017.wr_gpioa((v>>12) | ((v>>4) & $F0), mcpaddr)
   mcp23017.wr_gpiob(((v>>4) & $0F) | ((v<<4) & $F0), mcpaddr)

pub set_dp(v) | m
   ' decimal points are numbered from
   '     leftmost = 1
   ' to
   '     rightmost = 4 
   if (v==1)
       dp:= (dp & $0F) | 1  
   elseif (v==2)
       dp:= (dp & $0F) | 2
   elseif (v==3)
       dp:= (dp & $0F) | 4
   elseif (v==4)
       dp:= (dp & $0F) | 8
   else
       dp:= (dp & $0F)
   pcf8574.wr_gpio(dp, pcfaddr)
   