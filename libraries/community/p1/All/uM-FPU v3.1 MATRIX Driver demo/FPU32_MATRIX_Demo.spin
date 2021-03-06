{{
┌─────────────────────────────┬───────────────────┬──────────────────────┐
│ FPU32_Matrix_Demo.spin v3.0 │ Author: I.Kövesdi │ Rel.: 30   Nov  2011 │
├─────────────────────────────┴───────────────────┴──────────────────────┤
│                    Copyright (c) 2011 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  This terminal application demonstrates many procedures and the general│
│ usage of the "FPU32_MATRIX_Driver.spin (v3.0)" driver object. Starting │
│ with simple matrix algebra, the user is provided with examples of      │
│ eigen-decomposition and singular value decomposition of random         │
│ matrices, inversion of random square matrices and even with complete   │
│ algorithms that use intensively the "FPU32_MATRIX_Driver.spin" object. │
│ This application uses 2 additional COGs: one for the serial UART and   │
│ one for the FPU driver.                                                │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  If your embedded application has anything to do with the physical     │
│ reality, e.g. it deals with position, speed, acceleration, rotation,   │
│ attitude or even with airplane navigation or UAV flight control then   │
│ you should use vectors and matrices in your calculations. A matrix can │
│ be a "storage" for a bunch of related numbers, e.g. a covariance matrix│
│ or can define a transform on a vector or on other matrices. The use of │
│ matrix algebra shines in many areas of computation mathematics as in   │
│ coordinate transformations, rotational dynamics, control theory        │
│ including the Kalman filter. Matrix algebra can simplify complicated   │
│ problems and its rules are not artificial mathematical constructions,  │
│ but come from the nature of the problems and their solutions. A good   │
│ summary that might give you some inspiration is as follows:            │
│                                                                        │
│ "In the worlds of math, engineering and physics, it's the matrix that  │ 
│ separates the men from the boys, the  women from the girls."           │
│                                                (Jack W. Crenshaw).     │
│                                                                        │
│  A matrix is an array of numbers organized in rows and columns. We     │
│ usually give the row number first, then the column. So a [3-by-4]      │
│ matrix has twelve numbers arranged in three rows where each row has a  │
│ length of four                                                         │
│                                                                        │
│                          ┌               ┐                             │
│                          │ 1  2  3   4   │                             │
│                          │ 2  3  4   5   │                             │
│                          │ 3  4  5  6.28 │                             │
│                          └               ┘                             │
│                                                                        │
│  Since computer RAM is organized sequentially, as we access it with a  │
│ single number that we call address, we have to find a way to map the   │
│ two dimensions of the matrix onto the one-dimensional, sequential      │
│ memory. In Propeller SPIN that is rather easy since we can use arrays. │
│ For the previous matrix we can declare an array of LONGs, e.g.         │
│                                                                        │
│                           VAR   LONG mA[12]                            │
│                                                                        │
│ that is large enough to contain the "three times four" 32 bit IEEE 754 │
│ float numbers of the  matrix. In SPIN language the indexing starts with│
│ zero, so the first row, first column element of this matrix is placed  │
│ in mA[0]. The second row, fourth column element is placed in mA[7]. The│
│ general convention that I used with the "FPU_Matrix_Driver.spin" object│
│ is that the ith row, jth column element is accessed at the index       │
│                                                                        │ 
│                        "mA[i,j]" = mA[index]                           │
│                                                                        │
│ where                                                                  │
│                                                                        │
│                    index = (i-1)*(#col) + (j-1)                        │
│                                                                        │
│ and #col = 4 in this example. There are the 'Matrix_Put' and the       │
│ 'Matrix_Get' procedures in the driver to aid the access to the elements│
│ of a matrix. In this example the second row, fourth column element of  │
│ mA can be set to 5.0 using                                             │
│                                                                        │
│            OBJNAME.Matrix_Put(@mA, 5.0, 2, 4, #row, #col)              │
│                                                                  │
│         Address of mA in HUB───┘    │   │  │    │     │                │
│         Float value─────────────────┘   │  │    │     │                │
│         Target indexes──────────────────┻──┘    │     │                │
│         Matrix dimensions───────────────────────┻─────┘                │
│                                                                        │
│ Like in the previous example, the bunch of data in matrices is accessed│
│ by the driver using the starting HUB memory address of the array. For  │
│ example, after you declared mB and mC matrices to be the same [3-by-4] │
│ size as mA                                                             │
│                                                                        │
│                           VAR   LONG mB[12]                            │
│                           VAR   LONG mC[12]                            │
│                                                                        │
│ you can add mB to mC and store the result in mA with the following     │
│ single procedure call                                                  │
│                                                                        │
│  OBJNAME.Matrix_Add(@mA, @mB, @mC, 3, 4)     (meaning mA := mB + mC)   │
│                                                                        │
│ You can't multiply mB with mC, of course, but you can multiply mB with │
│ the transpose of mC. To obtain this transpose use                      │
│                                                                        │
│  OBJNAME.Matrix_Transpose(@mCT, @mC, 3, 4)   (meaning mCT := Tr. of mC)│
│                                                                        │
│ mCT is a [4-by-3] matrix, which can be now multiplied from the left    │
│ with mB as                                                             │
│                                                                        │
│  OBJNAME.Matrix_Multiply(@mD,@mB,@mCT,3,4,3) (meaning mD := mB * mCT)  │
│                                                                        │
│ where the result mD is a [3-by-3] matrix. This matrix algebra coding   │
│ convention can yield compact and easy to debug code. The following 8   │      
│ lines of SPIN code (OBJNAME here is FPUMAT) were taken from the        │
│ 'FPU_ExtendedKF.spin' application and calculate the Kalman gain matrix │
│ from five other matrices (A, P, C, CT, Sz) at a snap                   │
│                                                                        │
│        (    Formula: K = A * P * CT * Inv[C * P * CT + Sz]   )         │
│                                                                        │            
│      FPUMAT.Matrix_Transpose(@mCT, @mC, _R, _N)                        │
│      FPUMAT.Matrix_Multiply(@mAP, @mA, @mP, _N, _N, _N)                │
│      FPUMAT.Matrix_Multiply(@mAPCT, @mAP, @mCT, _N, _N, _R)            │
│      FPUMAT.Matrix_Multiply(@mCP, @mC, @mP, _R, _N, _N)                │
│      FPUMAT.Matrix_Multiply(@mCPCT, @mCP, @mCT, _R, _N, _R)            │
│      FPUMAT.Matrix_Add(@mCPCTSz, @mCPCT, @mSz, _R, _R)                 │
│      FPUMAT.Matrix_Invert(@mCPCTSzInv, @mCPCTSz, _R)                   │       
│      FPUMAT.Matrix_Multiply(@mK, @mAPCT, @mCPCTSzInv, _N, _R, _R)      │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  You can use HyperTerminal or PST with this application. When using PST│
│ uncheck the [10] = Line Feed option in the Preferences/Function window.│
│  SPIN can generate for you the 32 bit FLOAT representation of a number │
│ during compile time. But, during run time, the responsibility is upon  │
│ to you to convert LONGs to FLOATs, or vice versa. You can use native   │
│ FPU code for that and there are some conversion utilities in the       │
│ driver, too. Check that and take care.                                 │
│  The MATRIX driver is a member of a family of drivers for the uM-FPU   │
│ v3.1 with 2-wire SPI connection. The family has been placed on OBEX:   │
│                                                                        │
│  FPU32_SPI     (Core driver of the FPU32 family)                       │
│  FPU32_ARITH   (Basic arithmetic operations)                           │
│ *FPU32_MATRIX  (Basic and advanced matrix operations)                  │
│  FPU32_FFT     (FFT with advanced options as, e.g. ZOOM FFT)     (soon)│
│                                                                        │
│  The procedures and functions of these drivers can be cherry picked and│
│ used together to build application specific uM-FPU v3.1 drivers.       │
│  Other specialized drivers, as GPS, MEMS, IMU, MAGN, NAVIG, ADC, DSP,  │
│ ANN, STR are in preparation with similar cross-compatibility features  │
│ around the instruction set and with the user defined function ability  │
│ of the uM-FPU v3.1.                                                    │
│                                                                        │ 
└────────────────────────────────────────────────────────────────────────┘
}}


CON

_CLKMODE = XTAL1 + PLL16X
_XINFREQ = 5_000_000


{
Schematics

                                              5V(REG)           
                                               │                     
P   │                                   10K    │  
  A3├4────────────────────────────┳─────────┫   
R   │                              │           │
  A4├5────────────────────┐       │           │
O   │                      │       │           │ 
  A5├6────┳──────┐                        │
P   │       │      12     16       1           │
            │    ┌──┴──────┴───────┴──┐        │                               
          1K    │ SIN   SCLK   /MCLR │        │                  
            │    │                    │        │
            │    │                AVDD├18──────┫       
            └─11┤SOUT             VDD├14──────┘
                 │                    │         
                 │     uM-FPU 3.1     │
                 │                    │                                                                                           
            ┌───4┤CS                  │         
            ┣───9┤SIN                 │             
            ┣──17┤AVSS                │         
            ┣──13┤VSS                 │         
            │    └────────────────────┘
            
           GND

The CS pin(4) of the FPU is tied to LOW to select SPI mode at Reset and
must remain LOW during operation. For this Demo the 2-wire SPI connection
was used, where the SOUT and SIN pins were connected through a 1K resistor
and the DIO pin(6) of the Propeller was connected to the SIN pin(12) of
the FPU.
}


'--------------------------------Connections------------------------------
'            On Propeller                           On FPU
'-----------------------------------  ------------------------------------
'Sym.   A#/IO       Function            Sym.  P#/IO        Function
'-------------------------------------------------------------------------
_MCLR = 3 'Out  FPU Master Clear   -->  MCLR  1  In   Master Clear
_FCLK = 4 'Out  FPU SPI Clock      -->  CLK  16  In   SPI Clock Input     
_FDIO = 5 ' Bi  FPU SPI In/Out     -->  SIN  12  In   SPI Data In 
'       └─────────────────via 1K   <--  SOUT 11 Out   SPI Data Out


'Debug timing parameter
'_DBGDEL     = 80_000_000
_DBGDEL       = 40_000_000             'For faster run
                                                 
'_FLOAT_SEED  = 0.31415927              'Change this (from [0,1]) to run 
                                       'the demo with other pseudorandom
                                       'data
_FLOAT_SEED  = 0.27182818           


OBJ

PST      : "Parallax Serial Terminal"  'From Parallax Inc. v1.0
                                     
FPUMAT   : "FPU32_MATRIX_Driver"       'v3.0
 
  
VAR

LONG  fpu32

LONG  cog_ID

LONG  m1_2x2[2 * 2]

LONG  m1_3x3[3 * 3]
LONG  m2_3x3[3 * 3]

LONG  m1_3x4[3 * 4]

LONG  m1_4x4[4 * 4]
  
LONG  m1_3x7[3 * 7]  
LONG  m2_3x7[3 * 7]
LONG  m3_3x7[3 * 7]

LONG  m1_5x2[5 * 2]
LONG  m2_5x2[5 * 2]
LONG  m3_5x2[5 * 2]
LONG    eVc2[5 * 2]

  
LONG  m1_5x5[5 * 5]
LONG  m2_5x5[5 * 5]
LONG  m3_5x5[5 * 5]
LONG     eVc[5 * 5]

LONG  m1_5x6[5 * 6]

LONG  m1_5x7[5 * 7]
    
LONG  m1_5x11[5 * 11]  

LONG  m1_7x6[7 * 6]

LONG  m1_9x9[9 * 9]
LONG  m2_9x9[9 * 9]

LONG  m1_11x5[11 * 5]

LONG  m1_11x11[11 * 11]
LONG  m2_11x11[11 * 11] 

LONG  magnNED[3]
LONG  magnBody[3]
LONG  gravNED[3]
LONG  gravBody[3]
LONG  t1b[3]
LONG  t2b[3]
LONG  t3b[3]
LONG  t1n[3]
LONG  t2n[3]
LONG  t3n[3]
LONG  dcmBT[3 * 3]
LONG  dcmNT[3 * 3]
LONG  dcmTN[3 * 3]
LONG  dcmBN[3 * 3]            
LONG  heading
LONG  pitch
LONG  roll
  
LONG sjmB[36]
LONG sjmBT[36]
LONG sjmBBT[36]
LONG sjmX[36]
LONG sjmXB[36]
LONG sjm2IXB[36]
LONG sjm2I[36]


DAT '------------------------Start of SPIN code---------------------------
  
  
PUB StartApplication | ad                               
'-------------------------------------------------------------------------
'----------------------------┌──────────────────┐-------------------------
'----------------------------│ StartApplication │-------------------------
'----------------------------└──────────────────┘-------------------------
'-------------------------------------------------------------------------
''     Action: - Starts UART driver object
''             - Makes a MASTER CLEAR of the FPU
''             - Starts FPU_Matrix driver object
''             - Calls matrix calculation demo
'' Parameters: None
''    Results: None
''+Reads/Uses: /Hardware constants FROM CON section
''    +Writes: cog_ID, fpu3
''      Calls: FullDuplexSerialPlus---->PST.Start
''             FPU_Matrix_Driver ------>FPUMAT.StartCOG
''                                      FPUMAT.StopCOG
''             FPU_Matrix_Demo 
'-------------------------------------------------------------------------
'Start UART
PST.Start(57600)
  
WAITCNT(8 * CLKFREQ + CNT)

PST.Char(PST#CS)
PST.Str(STRING("uM-FPU V3.1 Matrix Driver Demo with SPI protocol", PST#NL))
PST.Char(PST#NL) 

WAITCNT(CLKFREQ + CNT)

ad := @cog_ID

'FPU Master Clear...
PST.Str(STRING("FPU MASTER CLEAR...", PST#NL, PST#NL))
OUTA[_MCLR]~~ 
DIRA[_MCLR]~~
OUTA[_MCLR]~
WAITCNT(CLKFREQ + CNT)
OUTA[_MCLR]~~
DIRA[_MCLR]~

fpu32 := FPUMAT.StartDriver(_FDIO, _FCLK, ad)

IF fpu32
  PST.Str(STRING("FPU Matrix Driver started in COG "))
  PST.Dec(cog_ID)

  WAITCNT(2 * CLKFREQ + CNT)
  
  FPU_Matrix_Demo

  PST.Char(PST#NL)
  PST.Str(STRING("FPU Matrix Driver Demo terminated normally..."))
  FPUMAT.StopDriver
  WAITCNT(CLKFREQ + CNT) 
  PST.Stop 
ELSE
  PST.Char(PST#NL)
  PST.Str(STRING("FPU Matrix Driver Start failed! Check system.", PST#NL))
  WAITCNT(CLKFREQ + CNT)
  PST.Stop
'-------------------------------------------------------------------------    


PRI FPU_MATRIX_Demo | char, oKay, cntr, j, r, c, rnd, i, fV, fV2, fV3
'-------------------------------------------------------------------------
'---------------------------┌─────────────────┐---------------------------
'---------------------------│ FPU_MATRIX_Demo │---------------------------
'---------------------------└─────────────────┘---------------------------
'-------------------------------------------------------------------------
'     Action: Demonstrates matrix operations with the use of FPU 
' Parameters: None
'    Results: None
'+Reads/Uses: None
'    +Writes: None
'      Calls: FullDuplexSerialPlus------>PST.Str
'                                        PST.Dec
'                                        PST.Tx
'             FPU_Matrix_Driver--------->FPUMAT.Procedures...  
'-------------------------------------------------------------------------
PST.Char(PST#CS)
PST.Str(STRING("---uM-FPU-V3.1 with 2-wire SPI connection---"))
PST.Char(PST#NL)

WAITCNT(CLKFREQ + CNT)

oKay := FALSE
oKay := FPUMAT.Reset
PST.Char(PST#NL)   
IF oKay 
  PST.Str(STRING("FPU Software Reset done...", PST#NL))
ELSE
  PST.Str(STRING("FPU Software Reset failed...", PST#NL))
  PST.Str(STRING("Please check hardware and restart...", PST#NL))
  REPEAT                             'Untill restart or switch off

WAITCNT(CLKFREQ + CNT)

char := FPUMAT.ReadSyncChar
PST.Str(STRING(PST#NL,  "Response to _SYNC: $"))
PST.Hex(char, 2)
IF (char == FPUMAT#_SYNC_CHAR)
  PST.Str(STRING("    (OK)", PST#NL))  
ELSE
  PST.Str(STRING("   Not OK!", PST#NL))
  PST.Str(STRING("Please check hardware and restart...", PST#NL))
  REPEAT                             'Untill restart or switch off

WAITCNT(CLKFREQ + CNT)

'Initialise random number sequence
rnd := FPUMAT.Rnd_Float_UnifDist(_FLOAT_SEED)  

PST.Char(PST#CS)
PST.Str(STRING("Create Identity matrices...", PST#NL))
PST.Str(STRING(PST#NL,  "{I} [2-by-2] :", PST#NL))

FPUMAT.Matrix_Identity(@m1_2x2, 2)

REPEAT r FROM 1 TO 2
  REPEAT c FROM 1 TO 2
    PST.Str(FloatToString(m1_2x2[((r-1)*2)+(c-1)], 30))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(_DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{I} [3-by-3] :", PST#NL))

FPUMAT.Matrix_Identity(@m1_3x3, 3)

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 3
    PST.Str(FloatToString(m1_3x3[((r-1)*3)+(c-1)], 30))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(_DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{I} [11-by-11] :", PST#NL))

FPUMAT.Matrix_Identity(@m1_11x11, 11)

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m1_11x11[((r-1)*11)+(c-1)], 30))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
  
WAITCNT(4 * _DBGDEL + CNT)


PST.Char(PST#CS)   
PST.Str(STRING("Create a [9-by-9] Diagonal matrix..."))
PST.Char(PST#NL)
PST.Char(PST#NL)

PST.Str(STRING("Lambda = "))
PST.Str(FloatToString(0.1234, 0))
PST.Char(PST#NL)

PST.Str(STRING(PST#NL,  "{D} = Lambda * {I} [9-by-9]", PST#NL))

FPUMAT.Matrix_Diagonal(@m1_9x9, 9, 1.234)       

REPEAT r FROM 1 TO 9
  REPEAT c FROM 1 TO 9
    PST.Str(FloatToString(m1_9x9[((r-1)*9)+(c-1)], 63))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)     

PST.Char(PST#CS)   
PST.Str(STRING("Check Put and Get procedures... "))
PST.Char(PST#NL)

PST.Str(STRING(PST#NL,  "Put 6.28 into [7,2]:", PST#NL)) 
FPUMAT.Matrix_Put(@m1_9x9, 6.28, 7, 2, 9, 9)

REPEAT r FROM 1 TO 9
  REPEAT c FROM 1 TO 9
    PST.Str(FloatToString(m1_9x9[((r-1)*9)+(c-1)], 63))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "Transpose the matrix...", PST#NL)) 
'Do matrix transposition
FPUMAT.Matrix_Transpose(@m2_9x9, @m1_9x9, 9, 9)

REPEAT r FROM 1 TO 9
  REPEAT c FROM 1 TO 9
    PST.Str(FloatToString(m2_9x9[((r-1)*9)+(c-1)], 63))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)    

PST.Str(STRING(PST#NL,  "Get value from [2,7]:", PST#NL)) 
fV := FPUMAT.Matrix_Get(@m2_9x9, 2, 7, 9, 9)
PST.Str(FloatToString(fV, 63))

WAITCNT(6 * _DBGDEL + CNT)

PST.Char(PST#CS)
PST.Str(STRING("Add and subtract [3-by-7] random matrices..."))
PST.Char(PST#NL)

WAITCNT(_DBGDEL + CNT) 

'Fill up  [7x3] random matrices
REPEAT i FROM 0 TO 20
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m2_3x7[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -19, 19)

REPEAT i FROM 0 TO 20
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m3_3x7[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -19, 19)

'Now convert them to float
FPUMAT.Matrix_LongToFloat(@m2_3x7, 3, 7)
FPUMAT.Matrix_LongToFloat(@m3_3x7, 3, 7)

'Do scalar matrix multiplication
FPUMAT.Matrix_ScalarMultiply(@m2_3x7, @m2_3x7, 3, 7, 0.123)
FPUMAT.Matrix_ScalarMultiply(@m3_3x7, @m3_3x7, 3, 7, 0.123)       

PST.Str(STRING(PST#NL,  "{B} [3-by-7]:", PST#NL))

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 7
    PST.Str(FloatToString(m2_3x7[((r-1)*7)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(_DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{C} [3-by-7]:", PST#NL))

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 7
    PST.Str(FloatToString(m3_3x7[((r-1)*7)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{A}={B}+{C} [3-by-7]:", PST#NL))

'Do matrix addition
FPUMAT.Matrix_Add(@m1_3x7, @m2_3x7, @m3_3x7, 3, 7) 

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 7
    PST.Str(FloatToString(m1_3x7[((r-1)*7)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{A}={B}-{C} [3-by-7]:", PST#NL))

'Do matrix substraction
FPUMAT.Matrix_Subtract(@m1_3x7, @m2_3x7, @m3_3x7, 3, 7)

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 7
    PST.Str(FloatToString(m1_3x7[((r-1)*7)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

PST.Char(PST#CS)
PST.Str(STRING("Multiply [5-by-7] and [7-by-6] random matrices..."))
PST.Char(PST#NL)

WAITCNT(_DBGDEL + CNT) 

'Fill up random matrices
REPEAT i FROM 0 TO 34
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_5x7[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -19, 19)

REPEAT i FROM 0 TO 41
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_7x6[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -19, 19)

'Now convert them to float
FPUMAT.Matrix_LongToFloat(@m1_5x7, 5, 7)
FPUMAT.Matrix_LongToFloat(@m1_7x6, 7, 6)

'Do scalar * matrix multiplication
FPUMAT.Matrix_ScalarMultiply(@m1_5x7, @m1_5x7, 5, 7, 0.123)
FPUMAT.Matrix_ScalarMultiply(@m1_7x6, @m1_7x6, 7, 6, 0.123)       

PST.Str(STRING(PST#NL,  "{B} [5-by-7]:", PST#NL))

REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 7
    PST.Str(FloatToString(m1_5x7[((r-1)*7)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{C} [7-by-6]:", PST#NL))

REPEAT r FROM 1 TO 7
  REPEAT c FROM 1 TO 6
    PST.Str(FloatToString(m1_7x6[((r-1)*6)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)          

PST.Str(STRING(PST#NL,  "{A}={B}*{C} [5-by-6]:", PST#NL))

'Do matrix multiplication
FPUMAT.Matrix_Multiply(@m1_5x6, @m1_5x7, @m1_7x6, 5, 7, 6)

 REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 6
    PST.Str(FloatToString(m1_5x6[((r-1)*6)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT) 

WAITCNT(12 * _DBGDEL + CNT)

PST.Char(PST#CS) 
PST.Str(STRING("Eigen Decompositin of a random [5-by-5] matrix {A}")) 
PST.Str(STRING(PST#NL,  "in the form", PST#NL))
PST.Str(STRING(PST#NL,  "             {A}={U}*{L}*{UT}", PST#NL))
PST.Str(STRING(PST#NL, "where {U} is a [5-by-5] orthonormal matrix and"))
PST.Str(STRING(PST#NL,  "the diagonal of {L} contains the eigenvalues."))
PST.Char(PST#NL)

PST.Str(STRING(PST#NL,  "{A} [5-by-5]:", PST#NL))
'Fill up  [5x5] random matrix
REPEAT i FROM 0 TO 24
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_5x5[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -19, 19)
  
'Now convert it to float
FPUMAT.Matrix_LongToFloat(@m1_5x5, 5, 5)

'Make a [5-by-5] symmetric, albeit random matrix
FPUMAT.Matrix_Transpose(@m2_5x5, @m1_5x5, 5, 5)
FPUMAT.Matrix_Add(@m1_5x5, @m1_5x5, @m2_5x5, 5, 5)
FPUMAT.Matrix_ScalarMultiply(@m1_5x5, @m1_5x5, 5, 5, 0.5)

REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(m1_5x5[((r-1)*5)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(6 * _DBGDEL + CNT)

'Do the eigen-decomposition
FPUMAT.Matrix_Eigen(@m1_5x5, @eVc, 5)

PST.Char(PST#NL)
PST.Str(STRING("Eigenvalues are in the diagonal of {L} [5-by-5]:"))
PST.Char(PST#NL) 
REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(m1_5x5[((r-1)*5)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
 
WAITCNT(8 * _DBGDEL + CNT)

PST.Char(PST#NL)
PST.Str(STRING("Eigenvectors are in the colums of {U} [5-by-5]:"))
PST.Char(PST#NL)      
REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(eVc[((r-1)*5)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
 
WAITCNT(8 * _DBGDEL + CNT)


               PST.Str(STRING(PST#NL, "Check that {U}*{UT}={I}, in other words,"))
PST.Str(STRING(PST#NL, "{U} is an orthonormal matrix...",PST#NL))

FPUMAT.Matrix_Transpose(@m3_5x5, @eVc, 5, 5)
FPUMAT.Matrix_Multiply(@m2_5x5, @eVc, @m3_5x5, 5, 5, 5)
    
REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(m2_5x5[((r-1)*5)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
   
WAITCNT(6 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL, "{A} can be restored as", PST#NL))
PST.Str(STRING(PST#NL,  "{A}={U}*{L}*{UT}:",PST#NL,PST#NL))

'{A}={E}*{UT}
FPUMAT.Matrix_Multiply(@m2_5x5, @m1_5x5, @m3_5x5, 5, 5, 5)
'{A}={U}*{E}*{UT}
FPUMAT.Matrix_Multiply(@m2_5x5, @eVc, @m2_5x5, 5, 5, 5)

REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(m2_5x5[((r-1)*5)+(c-1)], 84))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
 
WAITCNT(8 * _DBGDEL + CNT)
PST.Char(PST#CS) 
PST.Str(STRING("Singular Value Decomposition (SVD) of a random"))
PST.Str(STRING(PST#NL,  "matrix {A} in the form", PST#NL))
PST.Str(STRING(PST#NL,  "             {A}={U}*{SV}*{VT}", PST#NL))
PST.Str(STRING(PST#NL, "where {U}, {VT} are orthonormal matrices and"))
PST.Char(PST#NL)
PST.Str(STRING("the diagonal of {SV} contains the singular values."))
PST.Char(PST#NL)

WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{A} [3-by-4]:", PST#NL))
'Fill up  [3-by-4] random matrix
REPEAT i FROM 0 TO 11
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_3x4[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -9, 9)

'Now convert it to float
FPUMAT.Matrix_LongToFloat(@m1_3x4, 3, 4)

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 4
    PST.Str(FloatToString(m1_3x4[((r-1)*4)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(6 * _DBGDEL + CNT)

'Do singular value decomposition
FPUMAT.Matrix_SVD(@m1_3x4, @m1_3x3, @m1_4x4, 3, 4)

PST.Str(STRING(PST#NL,  "{U} [3-by-3]:", PST#NL))
REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 3
    PST.Str(FloatToString(m1_3x3[((r-1)*3)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
  
WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL, "{SV} [3-by-4] (same size as {A}):", PST#NL))
REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 4
    PST.Str(FloatToString(m1_3x4[((r-1)*4)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{VT} [4-by-4]:", PST#NL))
REPEAT r FROM 1 TO 4
  REPEAT c FROM 1 TO 4
    PST.Str(FloatToString(m1_4x4[((r-1)*4)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

'Now restore {A} to check
PST.Str(STRING(PST#NL, "Restore {A} as {U}*{SV}*{VT}:", PST#NL)) 

'{A}={SV}*{VT}
FPUMAT.Matrix_Multiply(@m1_3x4, @m1_3x4, @m1_4x4, 3, 4, 4)
'{A}={U}*{SV}*{VT} 
FPUMAT.Matrix_Multiply(@m1_3x4, @m1_3x3, @m1_3x4, 3, 3, 4) 

REPEAT r FROM 1 TO 3
  REPEAT c FROM 1 TO 4
    PST.Str(FloatToString(m1_3x4[((r-1)*4)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(12 * _DBGDEL + CNT)

PST.Str(STRING(16, 1,"SVD of another random matrix "))
PST.Str(STRING(PST#NL,  "{A} [5-by-2]:", PST#NL))
'Fill up  [5-by-2] random matrix
REPEAT i FROM 0 TO 9
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_5x2[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -9, 9)

'Now convert it to float
FPUMAT.Matrix_LongToFloat(@m1_5x2, 5, 2)

REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 2
    PST.Str(FloatToString(m1_5x2[((r-1)*2)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(6 * _DBGDEL + CNT)

'Do singular value decomposition
FPUMAT.Matrix_SVD(@m1_5x2, @m1_5x5, @m1_2x2, 5, 2)

PST.Str(STRING(PST#NL,  "{U} [5-by-5]:", PST#NL))
REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 5
    PST.Str(FloatToString(m1_5x5[((r-1)*5)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)
  
WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL, "{SV} [5-by-2] (same size as {A}):", PST#NL))
REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 2
    PST.Str(FloatToString(m1_5x2[((r-1)*2)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "{VT} [2-by-2]:", PST#NL))
REPEAT r FROM 1 TO 2
  REPEAT c FROM 1 TO 2
    PST.Str(FloatToString(m1_2x2[((r-1)*2)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)

'Now restore {A} to check
PST.Str(STRING(PST#NL, "Restore {A} as {U}*{SV}*{VT}:", PST#NL)) 

'{A}={SV}*{VT}
FPUMAT.Matrix_Multiply(@m1_5x2, @m1_5x2, @m1_2x2, 5, 2, 2)
'{A}={U}*{SV}*{VT} 
FPUMAT.Matrix_Multiply(@m1_5x2, @m1_5x5, @m1_5x2, 5, 5, 2) 

REPEAT r FROM 1 TO 5
  REPEAT c FROM 1 TO 2
    PST.Str(FloatToString(m1_5x2[((r-1)*2)+(c-1)], 94))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(12 * _DBGDEL + CNT)

PST.Char(PST#CS) 
PST.Str(STRING("**********************************************"))
PST.Char(PST#NL)
PST.Str(STRING("It's high time now to test our matrix algebra"))
PST.Char(PST#NL)
PST.Str(STRING("toolkit with some more complex algorithm..."))


WAITCNT(8 * _DBGDEL + CNT) 

'At a given point in the Troposphere our navigation computer "knows"
'the components of the following physical vectors in North East Down 
'(NED) navigational frame:

magnNED[0] := 31.9     'North component of WMM2005 magn. vector
magnNED[1] := 12.3     'East component of WMM2005 magn. vector
magnNED[2] := 18.2     'Down component of WMM2005 magn. vector
                       'in uT 

gravNED[0] := 0.0      'North component of WGS84 gravity vector
gravNED[1] := 0.0      'East component of WGS84 gravity vector
gravNED[2] := 9.808    'Down component of WGS84 gravity vector
                       'in m/s2

'The strapped down sensors of our plane, however, measure
magnBody[0] := -27.9   'Magn. component to nose direction
magnBody[1] := 20.6    'Magn. component to right wing direction
magnBody[2] := 18.9    'Magn. component to bely direction
                       'in uT

gravBody[0] := 0.67    'Grav. component to nose direction 
gravBody[1] := 0.85    'Grav. component to right wing direction 
gravBody[2] := 9.74    'Grav. component to bely direction 
                       'in m/s2

PST.Char(PST#CS)
PST.Str(STRING("*************************************************"))
PST.Char(PST#NL)
PST.Str(STRING("Somewhere in the Troposphere of Mother Earth the"))
PST.Char(PST#NL)
PST.Str(STRING("navigation computer calculates the NED components"))
PST.Char(PST#NL)
PST.Str(STRING("of the magnetic and gravity vectors for that place:"))
PST.Char(PST#NL)
PST.Str(STRING("  B(North)[uT] = "))
PST.Str(FloatToString(magnNED[0], 51))
PST.Str(STRING(PST#NL, "  B(East) [uT] = "))
PST.Str(FloatToString(magnNED[1], 51))
PST.Str(STRING(PST#NL, "  B(Down) [uT] = "))
PST.Str(FloatToString(magnNED[2], 51))
PST.Str(STRING(PST#NL, "G(North)[m/s2] = "))
PST.Str(FloatToString(gravNED[0], 73))
PST.Str(STRING(PST#NL, "G(East) [m/s2] = "))
PST.Str(FloatToString(gravNED[1], 73))
PST.Str(STRING(PST#NL, "G(Down) [m/s2] = "))
PST.Str(FloatToString(gravNED[2], 73))
PST.Char(PST#NL)     

WAITCNT(12 * _DBGDEL + CNT) 

PST.Str(STRING("However, the strapped down sensors measure these"))
PST.Char(PST#NL)
PST.Str(STRING("vectors in Body frame components, and they are :")) 
PST.Str(STRING(PST#NL,  "  B(Nose) [uT] = "))
PST.Str(FloatToString(magnBody[0], 51))
PST.Str(STRING(PST#NL,  "  B(Rwing)[uT] = "))
PST.Str(FloatToString(magnBody[1], 51))
PST.Str(STRING(PST#NL,  "  B(Bely) [uT] = "))
PST.Str(FloatToString(magnBody[2], 51))
PST.Str(STRING(PST#NL, "G(Nose) [m/s2] = "))
PST.Str(FloatToString(gravBody[0], 73))
PST.Str(STRING(PST#NL, "G(Rwing)[m/s2] = "))
PST.Str(FloatToString(gravBody[1], 73))
PST.Str(STRING(PST#NL, "G(Bely) [m/s2] = "))
PST.Str(FloatToString(gravBody[2], 73))
PST.Char(PST#NL) 

WAITCNT(8 * _DBGDEL + CNT)   

PST.Str(STRING("What are the Heading, Pitch and Roll Euler angles"))
PST.Char(PST#NL)
PST.Str(STRING("of the airplane in a straightforward and accurate"))
PST.Char(PST#NL)
PST.Str(STRING("approximation? Let us use the 'Triad' algorithm."))
PST.Char(PST#NL)
PST.Str(STRING("This algorithm may be good for your robot, as well."))
PST.Char(PST#NL)
PST.Str(STRING("-------------------------------------------------->"))

WAITCNT(6 * _DBGDEL + CNT)

'Let us use the Triad algorithm to calculate the Body to NED
'Direction Cosine Matrix (DCM)

'First create an orthogonal, rigth handed frame using the Body
'frame coordinates of the two measured physical vector. Let us
'start with the magnetic vector
FPUMAT.Vector_Unitize(@t1b, @magnBody)
FPUMAT.Vector_CrossProduct(@t2b, @magnBody, @gravBody)
FPUMAT.Vector_Unitize(@t2b, @t2b)
FPUMAT.Vector_CrossProduct(@t3b, @t1b, @t2b)

'Then create the same frame (the triad) but calculate it from the
'NED frame physical vector components this time
FPUMAT.Vector_Unitize(@t1n, @magnNED)
FPUMAT.Vector_CrossProduct(@t2n, @magnNED, @gravNED)
FPUMAT.Vector_Unitize(@t2n, @t2n)
FPUMAT.Vector_CrossProduct(@t3n, @t1n, @t2n)

'Unit vector DCM matrices can now be created from these othogonal
'tb, tn unit vectors by putting the vector components into the
'columns of [3x3] DCM matrices

'Create {Body to Triad} rotation matrix
REPEAT i FROM 0 TO 2
  dcmBT[i * 3] := t1b[i]
  dcmBT[(i * 3) + 1] := t2b[i]
  dcmBT[(i * 3) + 2] := t3b[i]

'Create {NAV to Triad} rotation matrix
REPEAT i FROM 0 TO 2
  dcmNT[i * 3] := t1n[i]
  dcmNT[(i * 3) + 1] := t2n[i]
  dcmNT[(i * 3) + 2] := t3n[i]
'Transpose this matrix to obtain {Triad to NAV} rotation matrix
FPUMAT.Matrix_Transpose(@dcmTN, @dcmNT, 3, 3)

'Now we can calculate {Body to NAV} rotation matrix by multiplying
'{Body to Triad} * {Triad to NAV} rotation matrices
FPUMAT.Matrix_Multiply(@dcmBN, @dcmBT, @dcmTN, 3, 3, 3)
 
'Now we have the Body to NAV DCM. From this we can calculate
'an approximation to the attitude

'Psi = ArcTan(-DCM21/DCM11)
fV := dcmBN[0]                               '(1-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV) 
fV := dcmBN[3]                               '(2-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmd(FPUMAT#_FNEG)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
heading := FPUMAT.ReadReg

'Theta = ArcTan(DCM31/SQRT(DCM11^2+DCM21^2))
fV := dcmBN[0]                               '(1-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
fV := dcmBN[3]                               '(2-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 125)
FPUMAT.WriteCmd(FPUMAT#_SQRT)
fV := dcmBN[6]                               '(3-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
pitch := FPUMAT.ReadReg

'Phi = ArcTan(DCM32/DCM33)
fV := dcmBN[8]                               '(3-1)*3 + (3-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV) 
fV := dcmBN[7]                               '(3-1)*3 + (2-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
roll := FPUMAT.ReadReg

'Now let us do it again starting with the gravity vector this time.
'Create an orthogonal, rigth handed frame using the two measured
'physical vector's Body frame coordinates
FPUMAT.Vector_Unitize(@t1b, @gravBody)
FPUMAT.Vector_CrossProduct(@t2b, @gravBody, @magnBody)
FPUMAT.Vector_Unitize(@t2b, @t2b)
FPUMAT.Vector_CrossProduct(@t3b, @t1b, @t2b)

'Then create the same frame (the triad) but now calculate with the
'NED frame physical vector components
FPUMAT.Vector_Unitize(@t1n, @gravNED)
FPUMAT.Vector_CrossProduct(@t2n, @gravNED, @magnNED)
FPUMAT.Vector_Unitize(@t2n, @t2n)
FPUMAT.Vector_CrossProduct(@t3n, @t1n, @t2n)

'Unit vector DCM matrices can now be created From these othogonal
'tb, tn unit vectors-by-putting the t vector components into the
'columns of [3x3] DCM matrices

'Create {Body to Triad} rotation matrix
REPEAT i FROM 0 TO 2
  dcmBT[i * 3] := t1b[i]
  dcmBT[(i * 3) + 1] := t2b[i]
  dcmBT[(i * 3) + 2] := t3b[i]

'Create {NAV to Triad} rotation matrix
REPEAT i FROM 0 TO 2
  dcmNT[i * 3] := t1n[i]
  dcmNT[(i * 3) + 1] := t2n[i]
  dcmNT[(i * 3) + 2] := t3n[i]
'Transpose it to obtain {Triad to NAV} rotation matrix
FPUMAT.Matrix_Transpose(@dcmTN, @dcmNT, 3, 3)

'Now we can calculate {Body to NAV} rotation matrix by multiplying
'{Body to Triad} * {Triad to NAV} rotation matrices
FPUMAT.Matrix_Multiply(@dcmBN, @dcmBT, @dcmTN, 3, 3, 3)

'Again we have the Body to NAV DCM. From this we can calculate
'another approximation to the attitude

'Psi = ArcTan(-DCM21/DCM11)
fV := dcmBN[0]                               '(1-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV) 
fV := dcmBN[3]                               '(2-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmd(FPUMAT#_FNEG)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
'Take average with previous value
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, heading)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 2)
FPUMAT.Wait   
FPUMAT.WriteCmd(FPUMAT#_FREADA)
heading := FPUMAT.ReadReg

'Convert to compass bearing
oKay := FPUMAT.F32_GT(0.0, heading, 0.0)
IF oKay                 'Then give 360 to heading
  FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
  FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, heading)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.WriteCmdByte(FPUMAT#_FADDI, 120)
  FPUMAT.Wait 
  FPUMAT.WriteCmd(FPUMAT#_FREADA)
  heading := FPUMAT.ReadReg 

'Theta = ArcTan(DCM31/SQRT(DCM11^2+DCM21^2))
fV := dcmBN[0]                               '(1-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 125)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 125)
fV := dcmBN[3]                               '(2-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_FMUL, 126)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 125)
FPUMAT.WriteCmd(FPUMAT#_SQRT)
fV := dcmBN[6]                               '(3-1)*3 + (1-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
'Take average
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, pitch)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 2)
FPUMAT.Wait 
FPUMAT.WriteCmd(FPUMAT#_FREADA)
pitch := FPUMAT.ReadReg

'Phi = ArcTan(DCM32/DCM33)
fV := dcmBN[8]                               '(3-1)*3 + (3-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV) 
fV := dcmBN[7]                               '(3-1)*3 + (2-1)
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, fV)
FPUMAT.WriteCmdByte(FPUMAT#_ATAN2, 126)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_DEGREES)
'Take average
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 126)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, roll)
FPUMAT.WriteCmdByte(FPUMAT#_FADD, 127)
FPUMAT.WriteCmdByte(FPUMAT#_FDIVI, 2)
FPUMAT.Wait
FPUMAT.WriteCmd(FPUMAT#_FREADA)
roll := FPUMAT.ReadReg

'Display results
PST.Str(STRING(PST#NL,  "Heading = "))
PST.Str(FloatToString(heading, 50))
PST.Str(STRING(PST#NL,  "  Pitch = "))
PST.Str(FloatToString(pitch, 50))
PST.Str(STRING(PST#NL,  "   Roll = "))
PST.Str(FloatToString(roll, 50))
PST.Char(PST#NL) 

WAITCNT(12 * _DBGDEL + CNT) 

PST.Char(PST#CS)
PST.Str(STRING("***************************************************"))
PST.Char(PST#NL)
PST.Str(STRING("Now find inverse of a random [6-by-6] {B} matrix"))
PST.Char(PST#NL)
PST.Str(STRING("with Shultz - Jones - Mayer iteration, which is an"))
PST.Char(PST#NL)
PST.Str(STRING("interesting variant of the celebrated Newton method"))
PST.Char(PST#NL)
PST.Str(STRING("applied to matrix inversion. Using SJM iteration:"))
PST.Char(PST#NL)
PST.Char(PST#NL)
PST.Str(STRING("               {X}=2*{X}-{X}*{B}*{X}", PST#NL, PST#NL))
PST.Str(STRING("to attempt convergence:", PST#NL, PST#NL))
PST.Str(STRING("                    {X}-->{1/B}", PST#NL, PST#NL))
PST.Str(STRING("all one needs are matrix multiply and substraction,"))
PST.Char(PST#NL)
PST.Str(STRING("and away one goes..."))
PST.Char(PST#NL)
    
WAITCNT(16 * _DBGDEL + CNT) 

REPEAT cntr FROM 1 to 2

  PST.Char(PST#NL)
  PST.Str(STRING("First create a random [6-by-6] {B} matrix..."))
  PST.Char(PST#NL)

  WAITCNT(_DBGDEL + CNT)

  PST.Char(PST#NL)
  PST.Str(STRING("{B}:"))
  PST.Char(PST#NL)

  'Fill up  a [6x6] random matrix
  IF (cntr == 1)
    REPEAT i FROM 0 TO 35
      rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
      sjmB[i] := FPUMAT.Rnd_Float_NormDist(rnd, 0.0, 1.234) 
  ELSE
    REPEAT i FROM 0 TO 35
      rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
      sjmB[i] := FPUMAT.Rnd_Float_NormDist(rnd, 0.0, 12.34)
    
  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmB[((r-1)*6)+(c-1)], 82))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(8 * _DBGDEL + CNT)

  PST.Str(STRING(PST#NL,  "Now calculate {B}*{BT} matrix and"))
  PST.Str(STRING(PST#NL,  "find it's maximum elements...", PST#NL))

  WAITCNT(_DBGDEL + CNT) 
 
  'Transpose {B}
  FPUMAT.Matrix_Transpose(@sjmBT, @sjmB, 6, 6)

  PST.Str(STRING(PST#NL,  "{B}*{BT}:", PST#NL))
  
  'Calculate {B} * {BT}
  FPUMAT.Matrix_Multiply(@sjmBBT, @sjmB, @sjmBT, 6, 6, 6)

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmBBT[((r-1)*6)+(c-1)], 81))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)  

  WAITCNT(_DBGDEL + CNT)
  
  fV := FPUMAT.Matrix_Max(@sjmBBT, 6, 6)

  PST.Str(STRING(PST#NL,  "Max of {B}*{BT}:"))
  PST.Str(FloatToString(fV, 0)) 
  PST.Char(PST#NL)

  WAITCNT(8 * _DBGDEL + CNT)

  PST.Str(STRING(PST#NL, "Now calculate a first approximation"))
  PST.Str(STRING(PST#NL, "to the inverse as {X} = {BT}/Max..."))
  PST.Char(PST#NL)

  WAITCNT(_DBGDEL + CNT) 

  PST.Str(STRING(PST#NL,  "{X}:", PST#NL))
   
  fV :=  FPUMAT.F32_INV(fV)
  FPUMAT.Matrix_ScalarMultiply(@sjmX, @sjmBT, 6, 6, fV)

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmX[((r-1)*6)+(c-1)], 84))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  'Now prepare a Diagonal matrix for repeated use
  FPUMAT.Matrix_Diagonal(@sjm2I, 6, 2.0)
       
  WAITCNT(4 * _DBGDEL + CNT) 

  PST.Str(STRING(PST#NL, "Now we can start the SJM iteration. First"))
  PST.Str(STRING(PST#NL, "calculate {X}*{B}. Note that this is the"))
  PST.Str(STRING(PST#NL, "product that should approach an Identity"))
  PST.Str(STRING(PST#NL, "matrix as the iteration proceeds...",PST#NL))

  WAITCNT(6 * _DBGDEL + CNT)  

  PST.Str(STRING(PST#NL,  "{X}*{B}:", PST#NL))

  FPUMAT.Matrix_Multiply(@sjmXB, @sjmX, @sjmB, 6, 6, 6)

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmXB[((r-1)*6)+(c-1)], 84))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(8 * _DBGDEL + CNT)

  'Accelerate  convergence a bit
  fV := FPUMAT.Matrix_Max(@sjmXB, 6, 6)

  PST.Str(STRING(PST#NL,  "Max of {X}*{B}:"))
  PST.Str(FloatToString(fV, 0)) 
  PST.Char(PST#NL)

  WAITCNT(4 * _DBGDEL + CNT)

  fV :=  FPUMAT.F32_Inv(fV)
  FPUMAT.Matrix_ScalarMultiply(@sjmXB, @sjmXB, 6, 6, fV)
  FPUMAT.Matrix_Subtract(@sjm2IXB, @sjm2I, @sjmXB, 6, 6)  

  PST.Str(STRING(PST#NL,  "2*{I}-({X}*{B}/Max):", PST#NL))

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjm2IXB[((r-1)*6)+(c-1)], 84))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(4 * _DBGDEL + CNT)

  PST.Char(PST#NL)
  PST.Str(STRING("Multiply this from the right with previous {X}"))
  PST.Str(STRING(PST#NL,  "to obtain new {X}...", PST#NL))

  FPUMAT.Matrix_Multiply(@sjmX, @sjm2IXB, @sjmX, 6, 6, 6)
  FPUMAT.Matrix_ScalarMultiply(@sjmX, @sjmX, 6, 6, fV)

  PST.Str(STRING(PST#NL,  "{X}=2*{X} -{X}*{B}*{X}:"))
  PST.Char(PST#NL)

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmX[((r-1)*6)+(c-1)], 84))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(4 * _DBGDEL + CNT)

  PST.Char(PST#NL)
  PST.Str(STRING("OK. Let us now check the  {X}*{B}  product"))
  PST.Char(PST#NL)
  PST.Str(STRING("again with the new {X}. Diagonal elements of"))
  PST.Char(PST#NL)
  PST.Str(STRING("this product might be now slightly dominant,"))
  PST.Char(PST#NL)
  PST.Str(STRING("although the whole thing  probably won't be "))
  PST.Str(STRING(PST#NL,  "very much like an Identity matrix..."))
  PST.Char(PST#NL) 

  WAITCNT(6 * _DBGDEL + CNT)

  PST.Str(STRING(PST#NL,  "New {X}*{B}:", PST#NL))

  FPUMAT.Matrix_Multiply(@sjmXB, @sjmX, @sjmB, 6, 6, 6)

  REPEAT r FROM 1 TO 6
    REPEAT c FROM 1 TO 6
      PST.Str(FloatToString(sjmXB[((r-1)*6)+(c-1)], 84))
    PST.Char(PST#NL)
    WAITCNT((_DBGDEL/25) + CNT)

  WAITCNT(8 * _DBGDEL + CNT)

  'Do SJM iteration   
  REPEAT 50                               '
    fV := FPUMAT.Matrix_Max(@sjmXB, 6, 6)
    fV2 := FPUMAT.Matrix_Min(@sjmXB, 6, 6)

    FPUMAT.WriteCmdLONG(FPUMAT#_FWRITE0, fV2)
    FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 0)
    FPUMAT.WriteCmd(FPUMAT#_FABS)
    FPUMAT.Wait  
    FPUMAT.WriteCmd(FPUMAT#_FREADA)
    fV3 := FPUMAT.ReadReg
    oKay :=FPUMAT.F32_GT(fV, fV3, 0.001)
    IF NOT(oKay)
     fV := fV2
      
    fV :=  FPUMAT.F32_Inv(fV)
      
    FPUMAT.Matrix_ScalarMultiply(@sjmXB, @sjmXB, 6, 6, fV)
    FPUMAT.Matrix_Subtract(@sjm2IXB, @sjm2I, @sjmXB, 6, 6)  
    FPUMAT.Matrix_Multiply(@sjmX, @sjm2IXB, @sjmX, 6, 6, 6)
    FPUMAT.Matrix_ScalarMultiply(@sjmX, @sjmX, 6, 6, fV)

    PST.Str(STRING(PST#NL,  "New {X}*{B}:", PST#NL))

    FPUMAT.Matrix_Multiply(@sjmXB, @sjmX, @sjmB, 6, 6, 6)

    REPEAT r FROM 1 TO 6
      REPEAT c FROM 1 TO 6
        PST.Str(FloatToString(sjmXB[((r-1)*6)+(c-1)], 84))
      PST.Char(PST#NL)
      WAITCNT((_DBGDEL/25) + CNT)

    'Check for convergence  
    fV := FPUMAT.Matrix_Max(@sjmXB, 6, 6)
    fV2 := FPUMAT.Matrix_Min(@sjmXB, 6, 6)
    oKay :=  FPUMAT.F32_EQ(fV, 1.0, 0.0001)
    IF oKay
      oKay :=  FPUMAT.F32_EQ(fV2, 0.0, 0.0001)
    IF oKay
      QUIT    

    WAITCNT(_DBGDEL + CNT)
  
  WAITCNT(2 * _DBGDEL + CNT)

  IF oKay
    WAITCNT(4 * _DBGDEL + CNT) 
    PST.Char(PST#NL)
    PST.Str(STRING("Well done. {X}*{B} is close to identity matrix, "))
    PST.Char(PST#NL)
    PST.Str(STRING("so {X} is close to the inverse of {B}:"))
    PST.Char(PST#NL)

    REPEAT r FROM 1 TO 6
      REPEAT c FROM 1 TO 6
        PST.Str(FloatToString(sjmX[((r-1)*6)+(c-1)], 83))
      PST.Char(PST#NL)
      WAITCNT((_DBGDEL/25) + CNT)

  ELSE
    WAITCNT(2 * _DBGDEL + CNT) 
    PST.Char(PST#NL)
    PST.Str(STRING("Our mathemetical hope for convergence was not"))
    PST.Char(PST#NL)
    PST.Str(STRING("fulfilled. Sometimes just happens..."))
    PST.Char(PST#NL)
      
  WAITCNT(12 * _DBGDEL + CNT)

  IF (cntr < 2)
    PST.Char(PST#NL)
    PST.Str(STRING("Let us do it again with a new random matrix, that"))
    PST.Char(PST#NL)
    PST.Str(STRING("has about ten times larger elements."))
    PST.Char(PST#NL)
    
  WAITCNT(_DBGDEL + CNT)


PST.Char(PST#CS)
PST.Str(STRING("*****************************************************"))
PST.Char(PST#NL)
PST.Str(STRING("Let us now make calculations with larger matrices."))
PST.Char(PST#NL)

WAITCNT(2 * _DBGDEL + CNT)

PST.Str(STRING("Multiply [11-by-11] random matrices..."))
PST.Char(PST#NL)

WAITCNT(_DBGDEL + CNT)

'Fill up  [11x11] random matrix
REPEAT i FROM 0 TO 120
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m1_11x11[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -9, 9)

'Now convert it to float
FPUMAT.Matrix_LongToFloat(@m1_11x11, 11, 11)

'Do scalar * matrix multiplication
FPUMAT.Matrix_ScalarMultiply(@m1_11x11,@m1_11x11,11,11,0.123)

PST.Str(STRING(PST#NL,  "{B} [11-by-11]:", PST#NL))

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m1_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)
  
'Fill up  another [11x11] random matrix
REPEAT i FROM 0 TO 120
  rnd := FPUMAT.Rnd_Float_UnifDist(rnd) 
  m2_11x11[i] := FPUMAT.Rnd_Long_UnifDist(rnd, -9, 9)

'Now convert it to float
FPUMAT.Matrix_LongToFloat(@m2_11x11, 11, 11)

'Do scalar * matrix multiplication
FPUMAT.Matrix_ScalarMultiply(@m2_11x11,@m2_11x11,11,11,0.123)

PST.Str(STRING(PST#NL,  "{C} [11-by-11]:", PST#NL))

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m2_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)  

PST.Str(STRING(PST#NL,  "{A}={B}*{C} [11-by-11]:", PST#NL))

'Do matrix multiplication
FPUMAT.Matrix_Multiply(@m1_11x11,@m1_11x11,@m2_11x11,11,11,11)

 REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m1_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT) 

WAITCNT(4 * _DBGDEL + CNT)

PST.Char(PST#NL)
PST.Str(STRING("Invert this product matrix...", PST#NL))
PST.Str(STRING(PST#NL,  "{1/A} [11-by-11]:", PST#NL))

'Invert 
FPUMAT.Matrix_Invert(@m2_11x11, @m1_11x11, 11)

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m2_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT) 

WAITCNT(4 * _DBGDEL + CNT)

PST.Str(STRING(PST#NL,  "Check that {A}*{1/A}={I} [11-by-11]:"))
PST.Char(PST#NL)
'Do matrix multiplication
FPUMAT.Matrix_Multiply(@m1_11x11,@m1_11x11,@m2_11x11,11,11,11)

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m1_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(4 * _DBGDEL + CNT)  

PST.Char(PST#NL)
PST.Str(STRING("A symmetric matrix [11-by-11]:"))
PST.Char(PST#NL)

'Make a symmetric matrix 
FPUMAT.Matrix_Transpose(@m1_11x11,@m2_11x11,11,11)
FPUMAT.Matrix_Add(@m2_11x11,@m2_11x11,@m1_11x11,11,11)

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m2_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)    

PST.Str(STRING(PST#NL,  "Eigenvalues of this matrix [11-by-11]:"))
PST.Char(PST#NL)
  
FPUMAT.Matrix_Eigen(@m2_11x11, @m1_11x11, 11)

REPEAT r FROM 1 TO 11
  REPEAT c FROM 1 TO 11
    PST.Str(FloatToString(m2_11x11[((r-1)*11)+(c-1)], 62))
  PST.Char(PST#NL)
  WAITCNT((_DBGDEL/25) + CNT)

WAITCNT(8 * _DBGDEL + CNT)    
'-------------------------------------------------------------------------


PRI FloatToString(floatV, format)
'-------------------------------------------------------------------------
'------------------------------┌───────────────┐--------------------------
'------------------------------│ FloatToString │--------------------------
'------------------------------└───────────────┘--------------------------
'-------------------------------------------------------------------------
'     Action: Converts a HUB/floatV into string within FPU then loads it
'             back into HUB
' Parameters: - Float value
'             - Format code in FPU convention
'    Results: Pointer to string in HUB
'+Reads/Uses: /FPUMAT:FPU CONs                
'    +Writes: FPU Reg:127
'      Calls: FPU_Matrix_Driver------->FPUMAT.WriteCmdByte
'                                      FPUMAT.WriteCmdLONG
'                                      FPUMAT.ReadRaFloatAsStr
'       Note: Quick solution for debug and test purposes
'-------------------------------------------------------------------------
FPUMAT.WriteCmdByte(FPUMAT#_SELECTA, 127)
FPUMAT.WriteCmdLONG(FPUMAT#_FWRITEA, floatV) 
RESULT := FPUMAT.ReadRaFloatAsStr(format) 
'-------------------------------------------------------------------------


DAT '---------------------------MIT License-------------------------------


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}                  