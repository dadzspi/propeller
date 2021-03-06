{{
  Demo/test program for LCD Base driver.

  Version: 1.0
  Author:  Tom Dinger
           propeller@tomdinger.net
  Date:    2010-09-16
  (c) Copyright 2010 Tom Dinger
  See end of file for terms of use.

  This demo program does very basic calls to the display driver.
  It should work for all LCD displays (and some VFDs) that use
  HD44780-command-compatible controllers (e.g. Samsung KS0066).

  Adjust the pin assignments to match your hardware connections
  to the display.
    
}}
{
  Version History:
  
  1.0 -- 2010-09-16 -- Initial release.

  1.3 -- 2010-11-14 -- changed the pin use to match other demos.
}


CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

  ' Pin assignments
  ' For the Propeller Demo Board, these are the RGB signals
  ' on the VGA connector -- I need P0 to P7 for the 8-bit
  ' wide data bus
  RS = 19      ' 1                   
  RW = 21      ' 2                    
  E  = 23      ' 3
  ' These must be four consecutive pins
  DB4 = 4
  DB7 = 7

  ' ASCII codes.
  CR  = $0D             ' Used as Newline in PST
  LF  = $0A
  PSTClearScreen = 16
  

OBJ
  LCDBase : "LCDBase_4bit_direct_HD44780"
  DBG     : "SimpleDebug"
  
PUB Demo | t, n, s 
  DBG.start(9600)
  LCDBase.usDelay( 5_000_000 ) ' time enough to activate PST
  
  DBG.str(string(PSTClearScreen,"Starting test program -- LCD Init",CR))

  LCDBase.Init( true, E, RS, RW, DB7, DB4 )

  ' Test Busy wait
  DBG.str(string("Waiting for idle",CR))
  t := LCDBase.ReadBusy
  DBG.str(string("BusyWord == $"))
  DBG.hex(t,4)
  DBG.putc(CR)

  DBG.str(string("send a character",CR))
  LCDBase.WriteByte("H")
  LCDBase.WriteByte("i")
  LCDBase.usDelay( 5_000_000 )

  DBG.str(string("count busy cycles after clear",CR))
  t := LCDBase#BusyFlag
  n := 0
  LCDBase.WriteCommand( LCDBase#ClearDisplayCmd ) ' clear
  repeat while ( (t & LCDBase#BusyFlag) <> 0 )
    t := LCDBase.ReadBusy
    ++n
  DBG.str(string("Tested busy count: "))
  DBG.dec(n)
  DBG.putc(CR)

  DBG.str(string("send a series of characters",CR))
  s := string("Done")
  LCDBase.WriteData( s, strsize(s) )

  ' Test reading ram address
  t := LCDBase.ReadBusy
  DBG.str(string("Cursor position (should be $0004): $"))
  DBG.hex(t,4)
  DBG.putc(CR)

  DBG.str(string("done",CR))

  repeat ' stall here...

{{
 
  (c) Copyright 2010 Tom Dinger

┌────────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                           │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a     │
│copy of this software and associated documentation files (the               │
│"Software"), to deal in the Software without restriction, including         │
│without limitation the rights to use, copy, modify, merge, publish,         │
│distribute, sublicense, and/or sell copies of the Software, and to          │
│permit persons to whom the Software is furnished to do so, subject to       │
│the following conditions:                                                   │
│                                                                            │
│The above copyright notice and this permission notice shall be included     │
│in all copies or substantial portions of the Software.                      │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS     │
│OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                  │
│MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.      │
│IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, │
│DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR       │
│OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE   │
│USE OR OTHER DEALINGS IN THE SOFTWARE.                                      │
└────────────────────────────────────────────────────────────────────────────┘
}}
  