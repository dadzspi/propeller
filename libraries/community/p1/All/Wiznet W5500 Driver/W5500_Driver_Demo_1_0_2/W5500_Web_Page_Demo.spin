''**************************************
''
''  W5500 Web Page Demo
''
''  Orginal Code by: Timothy D. Swieter, P.E.
''  Modification by: Benjamin Yaroch
''
''Description:
''
''      This is a demo of serving a web page using the W5500 IC and the Propeller. 
''
''
CON

  ' Processor Settings
  _clkmode = xtal1 + pll16x     'Use the PLL to multiple the external clock by 16
  _xinfreq = 5_000_000          'An external clock of 5MHz. is used (80MHz. operation)

  'WIZ module I/O
  MISO           = 0             ' Master In Slave Out
  MOSI           = 1             ' Master Out Slave In
  SCS            = 2             ' Slave Select
  SCLK           = 3             ' Serial Clock            
  RST            = 4             ' Reset  

  _bytebuffersize = 2048

VAR               'Variables to be located here

  'Configuration variables for the W5500
  byte  MAC[6]                  '6 element array contianing MAC or source hardware address ex. "02:00:00:01:23:45"
  byte  Gateway[4]              '4 element array containing gateway address ex. "192.168.0.1"
  byte  Subnet[4]               '4 element array contianing subnet mask ex. "255.255.255.0"
  byte  IP[4]                   '4 element array containing IP address ex. "192.168.0.13"

  'verify variables for the W5500
  byte  vMAC[6]                 '6 element array contianing MAC or source hardware address ex. "02:00:00:01:23:45"
  byte  vGateway[4]             '4 element array containing gateway address ex. "192.168.0.1"
  byte  vSubnet[4]              '4 element array contianing subnet mask ex. "255.255.255.0"
  byte  vIP[4]                  '4 element array containing IP address ex. "192.168.0.13"

  long  localSocket             '1 element for the socket number

  'Variables to info for where to return the data to
  byte  destIP[4]               '4 element array containing IP address ex. "192.168.0.16"
  long  destSocket              '1 element for the socket number

  'Misc variables
  byte  data[2048]
  
  long  PageCount  

OBJ             

  ETHERNET      : "W5500_Driver"                        ' Driver as named in the repository
  PST           : "Parallax Serial Terminal.spin"       ' A terminal object created by Parallax, used for debugging
  STR           : "STREngine.spin"                      ' A string processing utility

PUB main | temp0, temp1, temp2, readSize

  PauseMSec(2_000)              'A small delay to allow time to switch to the terminal application after loading the device

  '**************************************
  ' Start the processes in their cogs
  '**************************************

  'Start the terminal application
  'The terminal operates at 115,200 BAUD on the USB/COM Port the Prop Plug is attached to
  PST.Start(115_200)

  'Start the W5500 driver
  ethernet.Start(SCS, SCLK, MOSI, MISO, RST)

  '**************************************
  ' Initialize the variables
  '**************************************

  'The following variables can be adjusted by the demo user to fit in their particular network application.
  'Note the MAC ID is a locally administered address.   See Wikipedia MAC_Address 
  
  'MAC ID to be assigned to W5500
  MAC[0] := $02
  MAC[1] := $00
  MAC[2] := $00
  MAC[3] := $01
  MAC[4] := $23
  MAC[5] := $45

  'Subnet address to be assigned to W5500
  Subnet[0] := 255
  Subnet[1] := 255
  Subnet[2] := 255
  Subnet[3] := 0

  'IP address to be assigned to W5500
  IP[0] := 192
  IP[1] := 168
  IP[2] := 1
  IP[3] := 200

  'Gateway address of the system network
  Gateway[0] := 192
  Gateway[1] := 168
  Gateway[2] := 1
  Gateway[3] := 1

  'Local socket
  localSocket := 80 

  'Destination IP address - can be left zeros, the TCO demo echoes to computer that sent the packet
  destIP[0] := 0
  destIP[1] := 0
  destIP[2] := 0
  destIP[3] := 0

  destSocket := 80
    
  '**************************************
  ' Begin
  '**************************************

  'Clear the terminal screen
  PST.Home
  PST.Clear
   
  'Draw the title bar
  PST.Str(string("    Prop/W5500 Web Page Serving Test ", PST#NL, PST#NL))

  'Set the W5500 addresses
  PST.Str(string("Initialize all addresses...  ", PST#NL))  
  SetVerifyMAC(@MAC[0])
  SetVerifyGateway(@Gateway[0])
  SetVerifySubnet(@Subnet[0])
  SetVerifyIP(@IP[0])

  'Addresses should now be set and displayed in the terminal window.
  'Next initialize Socket 0 for being the TCP server

  PST.Str(string("Initialize socket 0, port "))
  PST.dec(localSocket)
  PST.Str(string(PST#NL))

  'Testing Socket 0's status register and display information
  PST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readSPI(ETHERNET#_Register_0, ETHERNET#_Sn_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PST.Str(string("$00 - socket closed", PST#NL, PST#NL))
    ETHERNET#_SOCK_INIT   : PST.Str(string("$13 - socket initalized", PST#NL, PST#NL))
    ETHERNET#_SOCK_LISTEN : PST.Str(string("$14 - socket listening", PST#NL, PST#NL))
    ETHERNET#_SOCK_ESTAB  : PST.Str(string("$17 - socket established", PST#NL, PST#NL))    
    ETHERNET#_SOCK_UDP    : PST.Str(string("$22 - socket UDP open", PST#NL, PST#NL))

  'Try opening a socket using a ASM method
  PST.Str(string("Attempting to open TCP on socket 0, port "))
  PST.dec(localSocket)
  PST.Str(string("...", PST#NL))
  
  ETHERNET.SocketOpen(0, ETHERNET#_TCPPROTO, localSocket, destSocket, @destIP[0])

  'Wait a moment for the socket to get established
  PauseMSec(500)

  'Testing Socket 0's status register and display information
  PST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readSPI(ETHERNET#_Register_0, ETHERNET#_Sn_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PST.Str(string("$00 - socket closed", PST#NL, PST#NL))
    ETHERNET#_SOCK_INIT   : PST.Str(string("$13 - socket initalized/opened", PST#NL, PST#NL))
    ETHERNET#_SOCK_LISTEN : PST.Str(string("$14 - socket listening", PST#NL, PST#NL))
    ETHERNET#_SOCK_ESTAB  : PST.Str(string("$17 - socket established", PST#NL, PST#NL))    
    ETHERNET#_SOCK_UDP    : PST.Str(string("$22 - socket UDP open", PST#NL, PST#NL))

  'Try setting up a listen on the TCP socket
  PST.Str(string("Setting TCP on socket 0, port "))
  PST.dec(localSocket)
  PST.Str(string(" to listening", PST#NL))

  ETHERNET.SocketTCPlisten(0)

  'Wait a moment for the socket to listen
  PauseMSec(500)

  'Testing Socket 0's status register and display information
  PST.Str(string("Socket 0 Status Register: "))
  ETHERNET.readSPI(ETHERNET#_Register_0, ETHERNET#_Sn_SR, @temp0, 1)

  case temp0
    ETHERNET#_SOCK_CLOSED : PST.Str(string("$00 - socket closed", PST#NL, PST#NL))
    ETHERNET#_SOCK_INIT   : PST.Str(string("$13 - socket initalized", PST#NL, PST#NL))
    ETHERNET#_SOCK_LISTEN : PST.Str(string("$14 - socket listening", PST#NL, PST#NL))
    ETHERNET#_SOCK_ESTAB  : PST.Str(string("$17 - socket established", PST#NL, PST#NL))    
    ETHERNET#_SOCK_UDP    : PST.Str(string("$22 - socket UDP open", PST#NL, PST#NL))

  PageCount := 0

  'Infinite loop of the server
  repeat
    ' This demo only uses one of the sockets maintained by the W5500. It does not
    ' handle simultaneous browsers or simultaneous connections from the same browser.
    ' The alternative is to implement a multi-socket state machine (see Mike G's code).
    '
    ' For many applications the simplifying assumption here is acceptable and
    ' saves resources.

    'Waiting for a client to connect
    PST.Str(string("Waiting for a client to connect.", PST#NL))
    'Testing Socket 0's status register and looking for a client to connect to our server
    repeat while !ETHERNET.SocketTCPestablished(0)   
    PST.Str(string("Connection established.", PST#NL))

    ' Wait for data from the TCP stream
    bytefill(@data, 0, _bytebuffersize)
    PST.Str(string("Waiting for TCP data.", PST#NL)) 
    repeat
      ETHERNET.readSPI(ETHERNET#_Register_0, ETHERNET#_Sn_SR, @temp0, 1)
      if(!ETHERNET.SocketTCPestablished(0))
        ' If the client has gone then break out of the loop. Ideally we should
        ' continue at the top of the main loop. For simplicity we'll just continue
        ' on as if nothing went wrong.
        quit
      readSize := ETHERNET.rxTCP(0, @data)     
      if(readSize>0)
        quit

    ' Assumption: all of the request comes in as one chunk of data that fits in the buffer.
    '
    ' The sender might send the request in chunks e.g. a-line-at-a-time that must be
    ' reassembled into one buffer. Be careful: the data buffer must be as large as the
    ' W5500's configured read buffer. A large request could be larger than this buffer.
    ' In reality, nearly all requests from browsers are small and arrive all at once.
    '
    ' For many applications the simplifying assumption here is acceptable and
    ' saves resources.

    PST.Str(string("Read "))
    PST.dec(readSize)
    PST.Str(string(" bytes from TCP",PST#NL))

    ' There are several HTTP methods. This demo only handles GETs (starts with a "G")
    
    if data[0] == "G"
       
      PageCount++

      PST.Str(string("serving page "))
      PST.dec(PageCount)
      PST.Str(string(PST#NL))
       
      'Send the web page - hardcoded here
      'status lin
      StringSend(0, string("HTTP/1.1 200 OK"))
      StringSend(0, string(PST#NL, PST#LF))
       
      'optional header
      StringSend(0, string("Server: W5500 Web Server/demo 1"))
      StringSend(0, string("Connection: close"))
      StringSend(0, string("Content-Type: text/html"))
      StringSend(0, string(PST#NL, PST#LF))
       
      'blank line
      StringSend(0, string(PST#NL, PST#LF))
       
      'File
      StringSend(0, string("<HTML>", PST#NL))
      StringSend(0, string("<HEAD>", PST#NL))
      StringSend(0, string("<TITLE>"))
      StringSend(0, string("Spinneret"))
      StringSend(0, string("</TITLE>", PST#NL))
      StringSend(0, string("</HEAD>", PST#NL))
      StringSend(0, string("<BODY>", PST#NL))
      StringSend(0, string("<H1>"))
      StringSend(0, string("Helloooooo World!!"))
      StringSend(0, string("</H1>", PST#NL))
      StringSend(0, string("<HR>", PST#NL))
      StringSend(0, string("<P>"))  
      StringSend(0, string("A test document from a WizNet W5500 Web Server"))
      StringSend(0, string("</P>", PST#NL))
      StringSend(0, string("<P>"))  
      StringSend(0, string("This page has been served "))
      StringSend(0, string("<b>"))
      StringSend(0, STR.numberToDecimal(PageCount, 5))
      StringSend(0, string("</b>"))
      StringSend(0, string(" times since powering on of the module"))
      StringSend(0, string("</P>", PST#NL))
      StringSend(0, string("</BODY>", PST#NL))
      StringSend(0, string("</HTML>", PST#NL))
      StringSend(0, string(PST#NL, PST#LF))
       
    PauseMSec(5)

    'End the connection
    ETHERNET.SocketTCPdisconnect(0)

    PauseMSec(10)

    'Connection terminated
    ETHERNET.SocketClose(0)
    PST.Str(string("Connection complete.", PST#NL, PST#NL))

    'Once the connection is closed, need to open socket again
    OpenSocketAgain

PRI SetVerifyMAC(_firstOctet)

  'Set the MAC ID and display it in the terminal
  ETHERNET.WriteMACaddress(true, _firstOctet)

  
  PST.Str(string("  Set MAC ID........"))
  PST.hex(byte[_firstOctet + 0], 2)
  PST.Str(string(":"))
  PST.hex(byte[_firstOctet + 1], 2)
  PST.Str(string(":"))
  PST.hex(byte[_firstOctet + 2], 2)
  PST.Str(string(":"))
  PST.hex(byte[_firstOctet + 3], 2)
  PST.Str(string(":"))
  PST.hex(byte[_firstOctet + 4], 2)
  PST.Str(string(":"))
  PST.hex(byte[_firstOctet + 5], 2)
  PST.Str(string(PST#NL))

  'Wait a moment
  PauseMSec(500)
 
  ETHERNET.ReadMACAddress(@vMAC[0])
  
  PST.Str(string("  Verified MAC ID..."))
  PST.hex(vMAC[0], 2)
  PST.Str(string(":"))
  PST.hex(vMAC[1], 2)
  PST.Str(string(":"))
  PST.hex(vMAC[2], 2)
  PST.Str(string(":"))
  PST.hex(vMAC[3], 2)
  PST.Str(string(":"))
  PST.hex(vMAC[4], 2)
  PST.Str(string(":"))
  PST.hex(vMAC[5], 2)
  PST.Str(string(PST#NL))
  PST.Str(string(PST#NL))

PRI SetVerifyGateway(_firstOctet)

  'Set the Gatway address and display it in the terminal
  ETHERNET.WriteGatewayAddress(true, _firstOctet)

  PST.Str(string("  Set Gateway....."))
  PST.dec(byte[_firstOctet + 0])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 1])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 2])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 3])
  PST.Str(string(PST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadGatewayAddress(@vGATEWAY[0])
  
  PST.Str(string("  Verified Gateway.."))
  PST.dec(vGATEWAY[0])
  PST.Str(string("."))
  PST.dec(vGATEWAY[1])
  PST.Str(string("."))
  PST.dec(vGATEWAY[2])
  PST.Str(string("."))
  PST.dec(vGATEWAY[3])
  PST.Str(string(PST#NL))
  PST.Str(string(PST#NL))

PRI SetVerifySubnet(_firstOctet)

  'Set the Subnet address and display it in the terminal
  ETHERNET.WriteSubnetMask(true, _firstOctet)

  PST.Str(string("  Set Subnet......"))
  PST.dec(byte[_firstOctet + 0])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 1])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 2])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 3])
  PST.Str(string(PST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadSubnetMask(@vSUBNET[0])
  
  PST.Str(string("  Verified Subnet..."))
  PST.dec(vSUBNET[0])
  PST.Str(string("."))
  PST.dec(vSUBNET[1])
  PST.Str(string("."))
  PST.dec(vSUBNET[2])
  PST.Str(string("."))
  PST.dec(vSUBNET[3])
  PST.Str(string(PST#NL))
  PST.Str(string(PST#NL))

PRI SetVerifyIP(_firstOctet)

  'Set the IP address and display it in the terminal
  ETHERNET.WriteIPAddress(true, _firstOctet)

  PST.Str(string("  Set IP.........."))
  PST.dec(byte[_firstOctet + 0])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 1])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 2])
  PST.Str(string("."))
  PST.dec(byte[_firstOctet + 3])
  PST.Str(string(PST#NL))

  'Wait a moment
  PauseMSec(500)

  ETHERNET.ReadIPAddress(@vIP[0])
  
  PST.Str(string("  Verified IP......."))
  PST.dec(vIP[0])
  PST.Str(string("."))
  PST.dec(vIP[1])
  PST.Str(string("."))
  PST.dec(vIP[2])
  PST.Str(string("."))
  PST.dec(vIP[3])
  PST.Str(string(PST#NL))
  PST.Str(string(PST#NL))

PRI StringSend(_socket, _dataPtr)

  ETHERNET.txTCP(0, _dataPtr, strsize(_dataPtr))

PRI OpenSocketAgain

  ETHERNET.SocketOpen(0, ETHERNET#_TCPPROTO, localSocket, destSocket, @destIP[0])
  ETHERNET.SocketTCPlisten(0)

PRI PauseMSec(Duration)

''  Pause execution for specified milliseconds.
''  This routine is based on the set clock frequency.
''  
''  params:  Duration = number of milliseconds to delay                                                                                               
''  return:  none
  
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}