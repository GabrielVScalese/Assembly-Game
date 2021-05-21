  .386                   
  .model flat, stdcall  
  option casemap :none  

  ; Libraries

  includelib \Masm32\lib\winmm.lib
  include \masm32\include\windows.inc
  include \masm32\include\user32.inc
  include \masm32\include\kernel32.inc
  include \MASM32\INCLUDE\gdi32.inc
  include \Masm32\include\winmm.inc 
  includelib \masm32\lib\user32.lib
  includelib \masm32\lib\kernel32.lib
  includelib \MASM32\LIB\gdi32.lib
  include \masm32\include\masm32rt.inc
  include \masm32\include\windows.inc
  include \masm32\include\user32.inc
  include \masm32\include\kernel32.inc
  include \MASM32\INCLUDE\gdi32.inc
  include \MASM32\INCLUDE\Comctl32.inc
  include \MASM32\INCLUDE\comdlg32.inc
  include \MASM32\INCLUDE\shell32.inc
  INCLUDE \Masm32\Include\msimg32.inc
  INCLUDE \Masm32\Include\oleaut32.inc
  includelib \masm32\lib\user32.lib
  includelib \masm32\lib\kernel32.lib
  includelib \MASM32\LIB\gdi32.lib
  includelib \MASM32\LIB\Comctl32.lib
  includelib \MASM32\LIB\comdlg32.lib
  includelib \MASM32\LIB\shell32.lib
  INCLUDELIB \Masm32\Lib\msimg32.lib
  INCLUDELIB \Masm32\Lib\oleaut32.lib
  INCLUDELIB \Masm32\Lib\msvcrt.lib
  INCLUDELIB \Masm32\Lib\masm32.lib
  INCLUDELIB \Masm32\Lib\cryptdll.lib
  INCLUDE \MASM32\INCLUDE\cryptdll.inc

  ; Macros

  NumberOfNumbers = 1        
  RangeOfNumbers = 600       

  szText MACRO Name, Text:VARARG
    LOCAL lbl
      jmp lbl
        Name db Text,0
      lbl:
    ENDM

  m2m MACRO M1, M2
    push M2
    pop  M1
  ENDM

  return MACRO arg
    mov eax, arg
    ret
  ENDM

  WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
  WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
  TopXY PROTO   :DWORD,:DWORD

  PlaySound PROTO STDCALL :DWORD, :DWORD, :DWORD

; Sections

.const
    ICONE   equ     500 
    WM_FINISH equ WM_USER+100h
    headRight   equ   100
    headLeft    equ   101
    headDown    equ   102
    headUp      equ   103
    apple       equ   104
    background  equ   105
    block       equ   106
    CREF_TRANSPARENT  EQU 00FFFFFFh

.data
        szDisplayName db "Snake Game",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        buffer        db 128 dup(0)
        X             dd 0
        Y             dd 0
        counterX      dd 200
        counterY      dd 10
        appleX        dd 100
        appleY        dd 100
        appleX2       dd 200
        appleY2       dd 300
        appleX3       dd 30
        appleY3       dd 20
        direction     dd "r"
        snakeWidth    dd 40
        snakeHeight   dd 35
        snakeXSize    dd 32
        snakeYSize    dd 29
        pont          dd 0
        stop          db "f"
        contador      dd 10
        imgY          dd 100
        random_bytes dd 1 DUP (?)

        BackgroundMusic     db "background_music.mp3", 0
        AppleSong           db "apple_song.mp3", 0
        open_dwCallback     dd ?
        open_wDeviceID     dd ?
        open_lpstrDeviceType  dd ?
        open_lpstrElementName  dd ?
        open_lpstrAlias     dd ?
		    generic_dwCallback   dd ?
        play_dwCallback     dd ?
        play_dwFrom       dd ?
        play_dwTo        dd ?
        
.data?
        hitpoint        POINT <>
        hitpointEnd     POINT <>
        threadID        DWORD ?  
        hEventStart     HANDLE ?
        hBmpHeadRight   dd  ?
        hBmpHeadLeft    dd  ?
        hBmpHeadDown    dd  ?
        hBmpHeadUp      dd  ?
        hBmpApple       dd  ?
        hBmpBack        dd  ?
        hBmpBlock       dd  ?

  .code

start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax

    invoke  GetCommandLine
    mov     CommandLine, eax

    invoke LoadBitmap, hInstance, headRight
    mov    hBmpHeadRight, eax

    invoke LoadBitmap, hInstance, headLeft
    mov    hBmpHeadLeft, eax

    invoke LoadBitmap, hInstance, headDown
    mov    hBmpHeadDown, eax

    invoke LoadBitmap, hInstance, headUp
    mov    hBmpHeadUp, eax

    invoke LoadBitmap, hInstance, apple
    mov    hBmpApple, eax

    invoke LoadBitmap, hInstance, background
    mov    hBmpBack, eax

    invoke LoadBitmap, hInstance, block
    mov    hBmpBlock, eax

    mov   open_lpstrDeviceType, 0h
    mov   open_lpstrElementName,OFFSET BackgroundMusic
    invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
    invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
    
    invoke ExitProcess,eax

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

        szText szClassName,"Generic_Class"

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc    
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst               
        mov wc.hbrBackground,  COLOR_BTNFACE+1    
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName  
        invoke LoadIcon,hInst,500                
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW        
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc     

        mov Wwd, 700
        mov Wht, 700
        
        invoke GetSystemMetrics,SM_CXSCREEN 
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN 
        invoke TopXY,Wht,eax
        mov Wty, eax

        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL

        mov   hWnd,eax 

        invoke LoadMenu,hInst,600               
        invoke SetMenu,hWnd,eax                  

        invoke ShowWindow,hWnd,SW_SHOWNORMAL    
        invoke UpdateWindow,hWnd                 

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0       
      cmp eax, 0                                
      je ExitLoop                              
      invoke TranslateMessage, ADDR msg          
      invoke DispatchMessage,  ADDR msg           
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL rect   :RECT
    LOCAL Font   :DWORD
    LOCAL Font2  :DWORD
    LOCAL hOld   :DWORD

    LOCAL memDC  :DWORD

    .if uMsg == WM_COMMAND

    .if wParam == 1000
        invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

    .elseif wParam == 1001            
        mov eax, offset ThreadProc
        invoke CreateThread, NULL, NULL, eax,  \
                              NULL, NORMAL_PRIORITY_CLASS, \
                              ADDR threadID
        mov     contador, 0                                 

    .elseif wParam == 1900
        szText TheMsg,"Assembler, Pure & Simple"
        invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
    .endif

    ; Avisa se a musica acabou
    .elseif uMsg == MM_MCINOTIFY
      mov   open_lpstrDeviceType, 0h      
      mov   open_lpstrElementName,OFFSET BackgroundMusic
      invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
      invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback

    .elseif uMsg == WM_KEYDOWN
            .if wParam == VK_DOWN
              .if direction != "u"
                mov direction, "d"
              .endif
            .endif                 
            .if wParam == VK_UP
              .if direction != "d"
                mov direction, "u"
              .endif
            .endif
            .if wParam == VK_RIGHT
             .if direction != "l"
               mov direction, "r"
             .endif
            .endif                 
            .if wParam == VK_LEFT
              .if direction != "r"
               mov direction, "l"
              .endif
            .endif            
     
    .elseif uMsg == WM_FINISH
            mov   rect.left, 100
            mov   rect.top , 100
            mov   rect.right, 32
            mov   rect.bottom, 32
            invoke InvalidateRect, hWnd, NULL, TRUE

    .elseif uMsg == WM_PAINT
            invoke BeginPaint,hWin,ADDR Ps
            mov    hDC, eax

            ; Background image

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax
            invoke SelectObject, memDC, hBmpBack
            mov  hOld, eax  
            invoke BitBlt, hDC, 0, 0,3320,2300, memDC, 10,10, SRCCOPY
            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  

            .if counterY > 610
              mov counterX, 50
              mov counterY, 40
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers             
              xor edx, edx                      
              div ecx                                   
              mov appleX, edx 
              add appleX, 150  

              mov appleX2, edx
              .if appleX2 > 300
                sub appleX2, 300
              .else
                sub appleX2, 100
              .endif

              mov appleX3, edx
              .if appleX3 < 200
                add appleX3, 400
              .else
                add appleX3, 100
              .endif

              xor edx, edx
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers            
              xor edx, edx                    
              div ecx                            
              mov appleY, edx  
              add appleY, 150

              mov appleY2, edx
              .if appleY2 < 300
                add appleY2, 345
              .else
                add appleY2, 100
              .endif

              mov appleY3, edx
              .if appleY3 > 300
                sub appleY3, 234
              .else
                sub appleY3, 100
              .endif

              mov stop, "t"
              invoke wsprintf,addr buffer,chr$("You lose! Your pontuation: %d"), pont       
              invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
            .endif

            .if counterX >= 650 || counterY < 1 || counterX < 1
              mov counterX, 50
              mov counterY, 40
             invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers             
              xor edx, edx                       
              div ecx                             
              .if edx < 40
                add edx, 40
              .endif
              mov appleX, edx 
              xor edx, edx
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers            
              xor edx, edx                       
              div ecx                             
              .if edx < 40
                add edx, 40
              .endif
              mov appleY, edx 
              mov stop, "t"
              invoke wsprintf,addr buffer,chr$("You lose! Your pontuation: %d"), pont            
              invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
            .endif

            .if stop == "t"
              mov stop, "f"
              mov direction, "r"
              mov pont, 0
            .endif
            
            ; Snake

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            .if direction == "r"
              invoke SelectObject, memDC, hBmpHeadRight
              mov snakeWidth, 40
              mov snakeHeight, 35
              mov snakeXSize, 32
              mov snakeYSize, 29
            .endif

            .if direction == "l"
              invoke SelectObject, memDC, hBmpHeadLeft
              mov snakeWidth, 40
              mov snakeHeight, 35
              mov snakeXSize, 32
              mov snakeYSize, 29
            .endif

            .if direction == "d"
              invoke SelectObject, memDC, hBmpHeadDown
              mov snakeWidth, 35
              mov snakeHeight, 40
              mov snakeXSize, 29
              mov snakeYSize, 32
            .endif

            .if direction == "u"
              invoke SelectObject, memDC, hBmpHeadUp
              mov snakeWidth, 35
              mov snakeHeight, 40
              mov snakeXSize, 29
              mov snakeYSize, 32
            .endif

            mov  hOld, eax 

            invoke TransparentBlt, hDC, counterX, counterY, snakeWidth, snakeHeight, memDC, \
                            0, 0, snakeXSize, snakeYSize, CREF_TRANSPARENT

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  
          
            ; Apple image 1

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            invoke SelectObject, memDC, hBmpApple
            mov  hOld, eax  

            invoke TransparentBlt, hDC, appleX, appleY, 24, 30, memDC, \
                            0, 0, 28, 33, CREF_TRANSPARENT

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  

            ; Apple image 2

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            invoke SelectObject, memDC, hBmpApple
            mov  hOld, eax  

            invoke TransparentBlt, hDC, appleX2, appleY2, 24, 30, memDC, \
                            0, 0, 28, 33, CREF_TRANSPARENT

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  

            ; Apple image 3

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            invoke SelectObject, memDC, hBmpApple
            mov  hOld, eax  

            invoke TransparentBlt, hDC, appleX3, appleY3, 24, 30, memDC, \
                            0, 0, 28, 33, CREF_TRANSPARENT

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC 

            invoke EndPaint,hWin,ADDR Ps
            return  0

    .elseif uMsg == WM_CREATE
        mov     X,40
        mov     Y,60
        mov     imgY,250
        invoke  CreateEvent, NULL, FALSE, FALSE, NULL
        mov     hEventStart, eax
    
        mov eax, offset ThreadProc
        invoke CreateThread, NULL, NULL, eax,  \
                                 NULL, NORMAL_PRIORITY_CLASS, \
                                 ADDR threadID
        mov     contador, 0       

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

TopXY proc wDim:DWORD, sDim:DWORD
    shr sDim, 1      
    shr wDim, 1   
    mov eax, wDim   
    sub sDim, eax   

    return sDim

TopXY endp


ThreadProc PROC USES ecx Param:DWORD

  invoke WaitForSingleObject, hEventStart, 300
  .if eax == WAIT_TIMEOUT && stop == "f"
    .if direction == "r"
      .if pont > 5 && pont < 20
        add counterX, 20
      .ELSEIF pont > 20
        add counterX, 30
      .ELSE
        add counterX, 10
      .endif
    .endif

    .if direction == "l"
      .if pont > 5 && pont < 20
        sub counterX, 20
      .ELSEIF pont > 20
        sub counterX, 30
      .ELSE
        sub counterX, 10
      .endif
    .endif

    .if direction == "u"
      .if pont > 5 && pont < 20
        sub counterY, 20
      .ELSEIF pont > 20
        sub counterY, 30
      .ELSE
        sub counterY, 10
      .endif
    .endif

    .if direction == "d"
      .if pont > 5 && pont < 20
        add counterY, 20
      .ELSEIF pont > 20
        add counterY, 30
      .ELSE
        add counterY, 10
      .endif
    .endif

    mov eax, appleX
    sub eax, 25
    mov ecx, appleX
    add ecx, 25 

    .if counterX >= eax && counterX <= ecx
      mov eax, appleY
      sub eax, 20
      mov ecx, appleY
      add ecx, 20

      .if counterY >= eax && counterY <= ecx
        inc pont
        
        mov   open_lpstrDeviceType, 0h         
        mov   open_lpstrElementName,OFFSET AppleSong
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
        invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback

        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             
        xor edx, edx                        
        div ecx                             
        .if edx < 40
          add edx, 40
        .endif
        mov appleX, edx 
        xor edx, edx
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers            
        xor edx, edx                        
        div ecx                             
        .if edx < 40
          add edx, 40
        .endif
        mov appleY, edx 
      .endif
  
    .endif

    mov eax, appleX2
    sub eax, 25
    mov ecx, appleX2
    add ecx, 25 

    .if counterX >= eax && counterX <= ecx    
      mov eax, appleY2
      sub eax, 20
      mov ecx, appleY2
      add ecx, 20

      .if counterY >= eax && counterY <= ecx
        inc pont

        mov   open_lpstrDeviceType, 0h         
        mov   open_lpstrElementName,OFFSET AppleSong
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
        invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
        
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             
        xor edx, edx                        
        div ecx                             
        .if edx < 40
          add edx, 40
        .endif
        mov appleX2, edx 
        xor edx, edx
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             
        xor edx, edx                        
        div ecx                             
        .if edx < 40
          add edx, 40
        .endif
        mov appleY2, edx 
      .endif
  
    .endif

    mov eax, appleX3
    sub eax, 25
    mov ecx, appleX3
    add ecx, 25 
    
    .if counterX >= eax && counterX <= ecx    
      mov eax, appleY3
      sub eax, 20
      mov ecx, appleY3
      add ecx, 20

      .if counterY >= eax && counterY <= ecx
        inc pont

        mov   open_lpstrDeviceType, 0h         
        mov   open_lpstrElementName,OFFSET AppleSong
        invoke mciSendCommandA,0,MCI_OPEN, MCI_OPEN_ELEMENT,offset open_dwCallback 
        invoke mciSendCommandA,open_wDeviceID,MCI_PLAY,MCI_FROM or MCI_NOTIFY,offset play_dwCallback
        
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             
        xor edx, edx                        
        div ecx        

        .if edx < 40
          add edx, 40
        .endif

        mov appleX3, edx 
        xor edx, edx
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers    

        .if edx < 40
          add edx, 40
        .endif

        mov appleY3, edx 
      .endif
  
    .endif

    invoke SendMessage, hWnd, WM_FINISH, NULL, NULL

  .endif
  jmp  ThreadProc
  ret  

ThreadProc ENDP 

end start
