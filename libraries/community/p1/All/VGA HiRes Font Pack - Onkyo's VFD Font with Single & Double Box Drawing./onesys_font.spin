''
'' Onesys drop in copy & paste font pack for Parallax's
'' VGA High-Res Text Driver.  Modeled after Onkyo's VFD font
'' featured on their high end audio equipment.
''
''
'' Font pack supports either double or single lined box 
'' drawings.  The double lined font has three additional
'' characters for dividing a box w/ a single horizontal line.
'' The tilde character, "~" has been changed to the
'' aproximate symbol as in 3.9bar is aprox 4. (AKA "≈")
''
'' Includes code to switch between three fonts on the fly
'' in real time, memory permitting.
'' 
'' The font does beautifully at 640x480 & 800x600 yet cannot
'' hold integrity at 1024x768.  Alternative Monitor timings 
'' referenced under CON.
''
''
''
'' ggysbers, 102814
''   Swapped lower-case vowels "e" and "i"  ──just kidding =)
''
CON

''800 x 600 @ 72Hz VESA: 100 x 50 characters
{                                                         ' Original/Default            
  hp = 800      'horizontal pixels                        ' 800   
  vp = 600      'vertical pixels                          ' 600
  hf = 56       'horizontal front porch pixels            ' 40    
  hs = 120      'horizontal sync pixels                   ' 128
  hb = 64       'horizontal back porch pixels             ' 88
  vf = 37       'vertical front porch lines               ' 1
  vs = 6        'vertical sync lines                      ' 4
  vb = 23       'vertical back porch lines                ' 23
  hn = 0        'horizontal normal sync state (0 for +)   ' 0
  vn = 0        'vertical normal sync state (1 for -)     ' 0
  pr = 50       'pixel rate in MHz at 80MHz system clock  ' 50
                '  5MHz granularity
}

''800 x 600 @ 60Hz SVGA: 100 x 50 characters              
'{                                                         
  hp = 800      'horizontal pixels                          
  vp = 600      'vertical pixels                         
  hf = 40       'horizontal front porch pixels               
  hs = 128      'horizontal sync pixels                  
  hb = 88       'horizontal back porch pixels            
  vf = 1        'vertical front porch lines              
  vs = 4        'vertical sync lines                     
  vb = 23       'vertical back porch lines               
  hn = 0        'horizontal normal sync state (0 for +)  
  vn = 0        'vertical normal sync state (1 for -)    
  pr = 40       'pixel rate in MHz at 80MHz system clock 
                '  5MHz granularity
'}

''640 x 480 @ 60Hz VGA Standard: 80 x 40 characters       ' Old Crusty Low-Radiation =) CRTs
{
  hp = 640      'horizontal pixels                        ' 640
  vp = 480      'vertical pixels                          ' 480
  hf = 16       'horizontal front porch pixels            ' 24
  hs = 96       'horizontal sync pixels                   ' 40
  hb = 48       'horizontal back porch pixels             ' 128
  vf = 10       'vertical front porch lines               ' 9
  vs = 2        'vertical sync lines                      ' 3
  vb = 33       'vertical back porch lines                ' 28
  hn = 1        'horizontal normal sync state (0 for +)   ' 1
  vn = 1        'vertical normal sync state (1 for -)     ' 1
  pr = 25       'pixel rate in MHz at 80MHz system clock  ' 30
                '  5MHz granularity
}

{{To use both the standard/default font and the custom fonts on the fly,
  note the varriable "TypeFace" and it's use under tagged heading
  'implant pointers' of public method "start."   }}
PUB start(BasePin, ScreenPtr, ColorPtr, CursorPtr, SyncPtr, TypeFace) : okay | i, j
''                                                          --------

  'if driver is already running, stop it   {{Make sure public method block "start" of}}
  stop                                     {{VGA High-Res Text Driver begins with a  }}
                                           {{call to it's "stop" method}}


''****  Begin code block to replace in active driver.  ****''''''''''''''''''''''''''''
  'implant pointers                                                                   '
  longmove(@screen_base, @ScreenPtr, 3)                                               '
  case TypeFace                                         'TypeFace equals ...          '
     1:font_base := @onesys_single                      '1 for single line drawings   '  
     2:font_base := @onesys_double                      '2 for double line drawings   '
     3:font_base := @onesys_thick                       '3 for thick line drawings    '     
     other:font_base := @standard                       '* for standard stock font    '
                                                                                      '
''****  End code block to replace in active driver.    ****''''''''''''''''''''''''''''                                                                                      '
                                                                                      

DAT

' 8 x 12 font - characters 0..127
'
' Each long holds four scan lines of a single character. The longs are arranged into
' groups of 128 which represent all characters (0..127). There are three groups which
' each contain a vertical third of all characters. They are ordered top, middle, and
' bottom.


''****  Begin Font Block, standard & onesys_single & onesys_double  ****''''''''''''''''''''''''''
''default font                                                                                   '
standard long                                                                                    '
long   $0C080000,$30100000,$7E3C1800,$18181800,$81423C00,$99423C00,$8181FF00,$E7C3FF00  'top     '
long   $1E0E0602,$1C000000,$00000000,$00000000,$18181818,$18181818,$00000000,$18181818           '
long   $00000000,$18181818,$18181818,$18181818,$18181818,$00FFFF00,$CC993366,$66666666           '
long   $AA55AA55,$0F0F0F0F,$0F0F0F0F,$0F0F0F0F,$0F0F0F0F,$00000000,$00000000,$00000000           '
long   $00000000,$3C3C1800,$77666600,$7F363600,$667C1818,$46000000,$1B1B0E00,$1C181800           '
long   $0C183000,$180C0600,$66000000,$18000000,$00000000,$00000000,$00000000,$60400000           '
long   $73633E00,$1E181000,$66663C00,$60663C00,$3C383000,$06067E00,$060C3800,$63637F00           '
long   $66663C00,$66663C00,$1C000000,$00000000,$18306000,$00000000,$180C0600,$60663C00           '
long   $63673E00,$66663C00,$66663F00,$63663C00,$66361F00,$06467F00,$06467F00,$63663C00           '
long   $63636300,$18183C00,$30307800,$36666700,$06060F00,$7F776300,$67636300,$63361C00           '
long   $66663F00,$63361C00,$66663F00,$66663C00,$185A7E00,$66666600,$66666600,$63636300           '
long   $66666600,$66666600,$31637F00,$0C0C3C00,$03010000,$30303C00,$361C0800,$00000000           '
long   $0C000000,$00000000,$06060700,$00000000,$30303800,$00000000,$0C6C3800,$00000000           '
long   $06060700,$00181800,$00606000,$06060700,$18181E00,$00000000,$00000000,$00000000           '
long   $00000000,$00000000,$00000000,$00000000,$0C080000,$00000000,$00000000,$00000000           '
long   $00000000,$00000000,$00000000,$18187000,$18181800,$18180E00,$73DBCE00,$18180000           '
                                                                                                 '
long   $080C7E7E,$10307E7E,$18181818,$7E181818,$81818181,$99BDBDBD,$81818181,$E7BD99BD  'middle  '
long   $1E3E7E3E,$1C3E3E3E,$30F0C000,$0C0F0300,$00C0F030,$00030F0C,$00FFFF00,$18181818           '
long   $18FFFF00,$00FFFF18,$18F8F818,$181F1F18,$18FFFF18,$00FFFF00,$CC993366,$66666666           '
long   $AA55AA55,$FFFF0F0F,$F0F00F0F,$0F0F0F0F,$00000F0F,$FFFF0000,$F0F00000,$0F0F0000           '
long   $00000000,$0018183C,$00000033,$7F363636,$66603C06,$0C183066,$337B5B0E,$0000000C           '
long   $0C060606,$18303030,$663CFF3C,$18187E18,$00000000,$00007E00,$00000000,$060C1830           '
long   $676F6B7B,$18181818,$0C183060,$60603860,$307F3336,$60603E06,$66663E06,$0C183060           '
long   $66763C6E,$60607C66,$1C00001C,$00001C1C,$180C060C,$007E007E,$18306030,$00181830           '
long   $033B7B7B,$66667E66,$66663E66,$63030303,$66666666,$06263E26,$06263E26,$63730303           '
long   $63637F63,$18181818,$33333030,$36361E36,$66460606,$63636B7F,$737B7F6F,$63636363           '
long   $06063E66,$7B636363,$66363E66,$66301C06,$18181818,$66666666,$66666666,$366B6B63           '
long   $663C183C,$18183C66,$43060C18,$0C0C0C0C,$30180C06,$30303030,$00000063,$00000000           '
long   $0030381C,$333E301E,$6666663E,$0606663C,$3333333E,$067E663C,$0C0C3E0C,$3333336E           '
long   $66666E36,$1818181C,$60606070,$361E3666,$18181818,$6B6B6B3F,$6666663E,$6666663C           '
long   $6666663B,$3333336E,$066E7637,$300C663C,$0C0C0C7E,$33333333,$66666666,$6B6B6363           '
long   $1C1C3663,$66666666,$0C30627E,$180C060C,$18181818,$18306030,$00000000,$0018187E           '
                                                                                                 '
long   $00000000,$00000000,$00001818,$0000183C,$00003C42,$00003C42,$0000FF81,$0000FFC3  'bottom  '
long   $0002060E,$00000000,$18181818,$18181818,$00000000,$00000000,$00000000,$18181818           '
long   $18181818,$00000000,$18181818,$18181818,$18181818,$00FFFF00,$CC993366,$66666666           '
long   $AA55AA55,$FFFFFFFF,$F0F0F0F0,$0F0F0F0F,$00000000,$FFFFFFFF,$F0F0F0F0,$0F0F0F0F           '
long   $00000000,$00001818,$00000000,$00003636,$0018183E,$00006266,$00006E3B,$00000000           '
long   $00003018,$0000060C,$00000000,$00000000,$0C181C1C,$00000000,$00001C1C,$00000103           '
long   $00003E63,$00007E18,$00007E66,$00003C66,$00007830,$00003C66,$00003C66,$00000C0C           '
long   $00003C66,$00001C30,$0000001C,$0C181C1C,$00006030,$00000000,$0000060C,$00001818           '
long   $00003E07,$00006666,$00003F66,$00003C66,$00001F36,$00007F46,$00000F06,$00007C66           '
long   $00006363,$00003C18,$00001E33,$00006766,$00007F66,$00006363,$00006363,$00001C36           '
long   $00000F06,$00603C36,$00006766,$00003C66,$00003C18,$00003C66,$0000183C,$00003636           '
long   $00006666,$00003C18,$00007F63,$00003C0C,$00004060,$00003C30,$00000000,$FFFF0000           '
long   $00000000,$00006E33,$00003B66,$00003C66,$00006E33,$00003C66,$00001E0C,$1E33303E           '
long   $00006766,$00007E18,$3C666660,$00006766,$00007E18,$00006B6B,$00006666,$00003C66           '
long   $0F063E66,$78303E33,$00000F06,$00003C66,$0000386C,$00006E33,$0000183C,$00003636           '
long   $00006336,$1C30607C,$00007E46,$00007018,$00001818,$00000E18,$00000000,$0000007E           '
                                                                                                 '
'' onkyo/onesys                                                                                  '
'' single lined box drawing                                                                      '
onesys_single  long                                                                              '
long  $08000000,$10000000,$3c180000,$18180000,$423c0000,$423c0000,$8181ff00,$c181ff00
long  $0c040000,$00000000,$00000000,$00000000,$10101010,$10101010,$00000000,$10101010
long  $00000000,$10101010,$10101010,$10101010,$10101010,$00ffff00,$cc993366,$66666666
long  $aa55aa55,$0f0f0f0f,$0f0f0f0f,$0f0f0f0f,$0f0f0f0f,$00000000,$00000000,$00000000
long  $00000000,$08080800,$24242400,$24240000,$423c1010,$42000000,$09060000,$04080800
long  $08100000,$08040000,$42000000,$00000000,$00000000,$00000000,$00000000,$40000000
long  $423c0000,$18100000,$423c0000,$423c0000,$22200000,$027e0000,$023c0000,$407e0000
long  $423c0000,$423c0000,$00000000,$00000000,$10200000,$00000000,$08040000,$20221c00
long  $413e0000,$423c0000,$423e0000,$423c0000,$221e0000,$027e0000,$027e0000,$023c0000
long  $42420000,$083e0000,$40700000,$22420000,$02020000,$63410000,$42420000,$423c0000
long  $423e0000,$423c0000,$423e0000,$423c0000,$087f0000,$42420000,$22220000,$41410000
long  $42420000,$22220000,$407e0000,$04043c00,$02010000,$20203c00,$22140800,$00000000
long  $20101000,$00000000,$02020000,$00000000,$40400000,$00000000,$04380000,$00000000
long  $02020000,$10100000,$40400000,$02020000,$10180000,$00000000,$00000000,$00000000
long  $00000000,$00000000,$00000000,$00000000,$08000000,$00000000,$00000000,$00000000
long  $00000000,$00000000,$00000000,$08187000,$08080800,$10180e00,$db8e0000,$08000000

long  $0c7e7e0c,$307e7e30,$1818187e,$7e181818,$81818181,$99bdbd99,$81818181,$8f9bb1e1
long  $3c7c3c1c,$1c1c1c00,$1010f000,$10101f00,$0000f010,$00001f10,$0000ff00,$10101010
long  $1010ff00,$0000ff10,$1010f010,$10101f10,$1010ff10,$00ffff00,$cc993366,$66666666
long  $aa55aa55,$ffff0f0f,$f0f00f0f,$0f0f0f0f,$00000f0f,$ffff0000,$f0f00000,$0f0f0000
long  $00000000,$00080808,$00000000,$7e24247e,$42403c02,$44081022,$69050609,$00000000
long  $04040404,$10101010,$18ff1824,$083e0808,$00000000,$007e0000,$00000000,$04081020
long  $464a5262,$10101010,$08102040,$40403840,$207e2222,$40403e02,$42423e02,$08102040
long  $42423c42,$40407c42,$00000808,$00000808,$04020408,$7e007e00,$20402010,$00080810
long  $39455d41,$42427e42,$42423e42,$02020202,$42424242,$02021e02,$02021e02,$42427a02
long  $42427e42,$08080808,$40404040,$120a0e12,$02020202,$41414955,$62524a46,$42424242
long  $02023e42,$42424242,$120a3e42,$40403c02,$08080808,$42424242,$22222222,$55494141
long  $24182442,$08081422,$04081020,$04040404,$20100804,$20202020,$00000000,$00000000
long  $00000000,$7c403c00,$42423e02,$02027c00,$42427c40,$7e423c00,$04041c04,$42427c00
long  $42423e02,$10101800,$40406000,$0e122202,$10101010,$49493700,$42423e00,$42423c00
long  $42423e00,$42427c00,$02423e00,$3c023c00,$08087e08,$42424200,$22222200,$49414100
long  $18244200,$42424200,$18207e00,$080c060c,$08080808,$10306030,$db8e0071,$08083e08

long  $00000008,$00000010,$00001818,$0000183c,$00003c42,$00003c42,$00ff8181,$00ff8185
long  $00040c1c,$00000000,$10101010,$10101010,$00000000,$00000000,$00000000,$10101010
long  $10101010,$00000000,$10101010,$10101010,$10101010,$00ffff00,$cc993366,$66666666
long  $aa55aa55,$ffffffff,$f0f0f0f0,$0f0f0f0f,$00000000,$ffffffff,$f0f0f0f0,$0f0f0f0f
long  $00000000,$00000808,$00000000,$00002424,$0010103c,$00000042,$00402e11,$00000000
long  $00001008,$00000408,$00004224,$00000008,$04080800,$00000000,$00000808,$00000102
long  $00003c42,$00007c10,$00007e04,$00003c42,$00002020,$00003c42,$00003c42,$00000808
long  $00003c42,$00001c20,$00000808,$04080800,$00201008,$00000000,$00040810,$00000808
long  $00003e01,$00004242,$00003e42,$00003c42,$00001e22,$00007e02,$00000202,$00007c42
long  $00004242,$00003e08,$00003c42,$00004222,$00007e02,$00004141,$00004242,$00003c42
long  $00000202,$00380c32,$00004222,$00003c42,$00000808,$00003c42,$00000814,$00004163
long  $00004242,$00000808,$00007e02,$003c0404,$00000040,$003c2020,$00000000,$ff000000
long  $00000000,$00007c42,$00003e42,$00007c02,$00007c42,$00003c02,$00000404,$3c40407c
long  $00004242,$00007c10,$3c424040,$00002212,$00007c10,$00004949,$00004242,$00003c42
long  $02023e42,$40407c42,$00000202,$00003e40,$00007008,$00007c42,$00000814,$00003649
long  $00004224,$3c40407c,$00007e04,$00007018,$00000808,$00000e18,$00000071,$00003e00
                                                                                                 '
'' onkyo/onesys                                                                                  '
'' double lined box drawing                                                                      '
onesys_double  long                                                                              '
long  $08000000,$10000000,$3c180000,$18180000,$423c0000,$423c0000,$8181ff00,$c181ff00
long  $0c040000,$00000000,$fc000000,$3f000000,$e4242424,$27242424,$ff000000,$24242424
long  $ff000000,$e7242424,$e4242424,$27242424,$e7242424,$00ffff00,$cc993366,$24242424
long  $aa55aa55,$0f0f0f0f,$0f0f0f0f,$0f0f0f0f,$00000000,$00000000,$24242424,$00000000
long  $00000000,$08080800,$24242400,$24240000,$423c1010,$42000000,$09060000,$04080800
long  $08100000,$08040000,$42000000,$00000000,$00000000,$00000000,$00000000,$40000000
long  $423c0000,$18100000,$423c0000,$423c0000,$22200000,$027e0000,$023c0000,$407e0000
long  $423c0000,$423c0000,$00000000,$00000000,$10200000,$00000000,$08040000,$20221c00
long  $413e0000,$423c0000,$423e0000,$423c0000,$221e0000,$027e0000,$027e0000,$023c0000
long  $42420000,$083e0000,$40700000,$22420000,$02020000,$63410000,$42420000,$423c0000
long  $423e0000,$423c0000,$423e0000,$423c0000,$087f0000,$42420000,$22220000,$41410000
long  $42420000,$22220000,$407e0000,$04043c00,$02010000,$20203c00,$22140800,$00000000
long  $20101000,$00000000,$02020000,$00000000,$40400000,$00000000,$04380000,$00000000
long  $02020000,$10100000,$40400000,$02020000,$10180000,$00000000,$00000000,$00000000
long  $00000000,$00000000,$00000000,$00000000,$08000000,$00000000,$00000000,$00000000
long  $00000000,$00000000,$00000000,$08187000,$08080800,$10180e00,$db8e0000,$08000000

long  $0c7e7e0c,$307e7e30,$1818187e,$7e181818,$81818181,$99bdbd99,$81818181,$8f9bb1e1
long  $3c7c3c1c,$1c1c1c00,$04040404,$20202020,$04040404,$20202020,$00000000,$24242424
long  $00000000,$00000000,$04040404,$20202020,$00000000,$00ffff00,$cc993366,$2424e424
long  $aa55aa55,$ffff0f0f,$f0f00f0f,$0f0f0f0f,$0000ff00,$ffff0000,$24242724,$0f0f0000
long  $00000000,$00080808,$00000000,$7e24247e,$42403c02,$44081022,$69050609,$00000000
long  $04040404,$10101010,$18ff1824,$083e0808,$00000000,$007e0000,$00000000,$04081020
long  $464a5262,$10101010,$08102040,$40403840,$207e2222,$40403e02,$42423e02,$08102040
long  $42423c42,$40407c42,$00000808,$00000808,$04020408,$7e007e00,$20402010,$00080810
long  $39455d41,$42427e42,$42423e42,$02020202,$42424242,$02021e02,$02021e02,$42427a02
long  $42427e42,$08080808,$40404040,$120a0e12,$02020202,$41414955,$62524a46,$42424242
long  $02023e42,$42424242,$120a3e42,$40403c02,$08080808,$42424242,$22222222,$55494141
long  $24182442,$08081422,$04081020,$04040404,$20100804,$20202020,$00000000,$00000000
long  $00000000,$7c403c00,$42423e02,$02027c00,$42427c40,$7e423c00,$04041c04,$42427c00
long  $42423e02,$10101800,$40406000,$0e122202,$10101010,$49493700,$42423e00,$42423c00
long  $42423e00,$42427c00,$02423e00,$3c023c00,$08087e08,$42424200,$22222200,$49414100
long  $18244200,$42424200,$18207e00,$080c060c,$08080808,$10306030,$db8e0071,$08083e08

long  $00000008,$00000010,$00001818,$0000183c,$00003c42,$00003c42,$00ff8181,$00ff8185
long  $00040c1c,$00000000,$242424e4,$24242427,$000000fc,$0000003f,$000000ff,$24242424
long  $242424e7,$000000ff,$242424e4,$24242427,$242424e7,$00ffff00,$cc993366,$24242424
long  $aa55aa55,$ffffffff,$f0f0f0f0,$0f0f0f0f,$00000000,$ffffffff,$24242424,$0f0f0f0f
long  $00000000,$00000808,$00000000,$00002424,$0010103c,$00000042,$00402e11,$00000000
long  $00001008,$00000408,$00004224,$00000008,$04080800,$00000000,$00000808,$00000102
long  $00003c42,$00007c10,$00007e04,$00003c42,$00002020,$00003c42,$00003c42,$00000808
long  $00003c42,$00001c20,$00000808,$04080800,$00201008,$00000000,$00040810,$00000808
long  $00003e01,$00004242,$00003e42,$00003c42,$00001e22,$00007e02,$00000202,$00007c42
long  $00004242,$00003e08,$00003c42,$00004222,$00007e02,$00004141,$00004242,$00003c42
long  $00000202,$00380c32,$00004222,$00003c42,$00000808,$00003c42,$00000814,$00004163
long  $00004242,$00000808,$00007e02,$003c0404,$00000040,$003c2020,$00000000,$ff000000
long  $00000000,$00007c42,$00003e42,$00007c02,$00007c42,$00003c02,$00000404,$3c40407c
long  $00004242,$00007c10,$3c424040,$00002212,$00007c10,$00004949,$00004242,$00003c42
long  $02023e42,$40407c42,$00000202,$00003e40,$00007008,$00007c42,$00000814,$00003649
long  $00004224,$3c40407c,$00007e04,$00007018,$00000808,$00000e18,$00000071,$00003e00

''****  End Font Block, standard & onesys_single & onesys_double  ****''''''''''''''''''''''''''''


DAT
{{
┌────────────────────────────────────────────────────────────────────────────────────────────────┐
│ NOTICE: Merry Christmas, Free to Use, Yo Ho Ho...                                              │
├────────────────────────────────────────────────────────────────────────────────────────────────┤
│ THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT  │
│ NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND         │
│ NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,   │
│ DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, │
│ OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR OTHER DEALINGS IN THE COMPILED BINARY CODE │
│ OR FIRM/SOFT-WARE.                                                                             │
└────────────────────────────────────────────────────────────────────────────────────────────────┘
}}
'EOF