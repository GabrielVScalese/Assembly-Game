


      .386                   ; minimum processor needed for 32 bit
      .model flat, stdcall   ; FLAT memory model & STDCALL calling
      option casemap :none   ; set code to case sensitive

; #########################################################################

      include \masm32\include\masm32rt.inc

      ; ---------------------------------------------
      ; main include file with equates and structures
      ; ---------------------------------------------
      include \masm32\include\windows.inc

      ; -------------------------------------------------------------
      ; In MASM32, each include file created by the L2INC.EXE utility
      ; has a matching library file. If you need functions from a
      ; specific library, you use BOTH the include file and library
      ; file for that library.
      ; -------------------------------------------------------------

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
; #########################################################################

; ------------------------------------------------------------------------
; MACROS are a method of expanding text at assembly time. This allows the
; programmer a tidy and convenient way of using COMMON blocks of code with
; the capacity to use DIFFERENT parameters in each block.
; ------------------------------------------------------------------------

      NumberOfNumbers = 1        ; Number of random numbers to be generated and shown
      RangeOfNumbers = 600        ; Range of the random numbers (0..RangeOfNumbers-1)
        ; 1. szText
      ; A macro to insert TEXT into the code section for convenient and 

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      ; 2. m2m
      ; There is no mnemonic to copy from one memory location to another,
      ; this macro saves repeated coding of this process and is easier to
      ; read in complex code.

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      ; 3. return
      ; Every procedure MUST have a "ret" to return the instruction
      ; pointer EIP back to the next instruction after the call that
      ; branched to it. This macro puts a return value in eax and
      ; makes the "ret" instruction on one line. It is mainly used
      ; for clear coding in complex conditionals in large branching
      ; code such as the WndProc procedure.

      return MACRO arg
        mov eax, arg
        ret
      ENDM

; #########################################################################

; ----------------------------------------------------------------------
; Prototypes are used in conjunction with the MASM "invoke" syntax for
; checking the number and size of parameters passed to a procedure. This
; improves the reliability of code that is written where errors in
; parameters are caught and displayed at assembly time.
; ----------------------------------------------------------------------

        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD

; #########################################################################

; ------------------------------------------------------------------------
; This is the INITIALISED data section meaning that data declared here has
; an initial value. You can also use an UNINIALISED section if you need
; data of that type [ .data? ]. Note that they are different and occur in
; different sections.
; ------------------------------------------------------------------------
.const
    ICONE   equ     500 ; define o numero associado ao icon igual ao arquivo RC
    ; define o numero da mensagem criada pelo usuario
    WM_FINISH equ WM_USER+100h  ; o numero da mensagem é a ultima + 100h
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
        msg1          db "Mandou uma mensagem Ok",0
        counterX      dd 200
        counterY      dd 10
        appleX        dd 100
        appleY        dd 100
        direction     dd "r"
        snakeWidth    dd 40
        snakeHeight   dd 35
        snakeXSize    dd 32
        snakeYSize    dd 29
        bodyX         dd 100 dup(?)
        bodyY         dd 100 dup(?)
        bodyCounter   dd 0
        randomValue   dd 0
        blocks        dd 1
        subtractX     dd 10
        addY          dd 11
        tempX         dd 0
        tempY         dd 0
        ; pontText    db "Pontos: "
        pont          dd 0
        stop          db "f"
        contador      dd 10
        imgY          dd 100  

        ; Teste
        random_bytes dd 1 DUP (?)

; #########################################################################

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

; ------------------------------------------------------------------------
; This is the start of the code section where executable code begins. This
; section ending with the ExitProcess() API function call is the only
; GLOBAL section of code and it provides access to the WinMain function
; with the necessary parameters, the instance handle and the command line
; address.
; ------------------------------------------------------------------------

    .code

; -----------------------------------------------------------------------
; The label "start:" is the address of the start of the code section and
; it has a matching "end start" at the end of the file. All procedures in
; this module must be written between these two.
; -----------------------------------------------------------------------

start:
    invoke GetModuleHandle, NULL ; provides the instance handle
    mov hInstance, eax

    invoke  GetCommandLine        ; provides the command line address
    mov     CommandLine, eax

    ; carrego o bitmap
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

    ; eax tem o ponteiro para uma string que mostra toda linha de comando.
    ;invoke wsprintf,addr buffer,chr$("%s"), eax
    ;invoke MessageBox,NULL,ADDR buffer,ADDR szDisplayName,MB_OK

    invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
    
    invoke ExitProcess,eax       ; cleanup & return to operating system

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

        szText szClassName,"Generic_Class"

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc      ; address of WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst               ; instance handle
        mov wc.hbrBackground,  COLOR_BTNFACE+1     ; system color
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName  ; window class name
        ; id do icon no arquivo RC
        invoke LoadIcon,hInst,500                  ; icon ID   ; resource icon
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW         ; system cursor
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc     ; register the window class

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 700
        mov Wht, 700
        
        invoke GetSystemMetrics,SM_CXSCREEN ; get screen width in pixels
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN ; get screen height in pixels
        invoke TopXY,Wht,eax
        mov Wty, eax

        ; ==================================
        ; Create the main application window
        ; ==================================
        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL

        mov   hWnd,eax  ; copy return value into handle DWORD

        invoke LoadMenu,hInst,600                 ; load resource menu
        invoke SetMenu,hWnd,eax                   ; set it to main window

        invoke ShowWindow,hWnd,SW_SHOWNORMAL      ; display the window
        invoke UpdateWindow,hWnd                  ; update the display

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0         ; get each message
      cmp eax, 0                                  ; exit if GetMessage()
      je ExitLoop                                 ; returns zero
      invoke TranslateMessage, ADDR msg           ; translate it
      invoke DispatchMessage,  ADDR msg           ; send it to message proc
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; #########################################################################

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

  ;  mov ebp, offset bodyX
   ; mov esi, offset bodyY
  ;  mov edi, 0


    ; cuidado ao declarar variaveis locais pois ao terminar o procedimento
    ; seu valor é limpado colocado lixo no lugar.
; -------------------------------------------------------------------------
; Message are sent by the operating system to an application through the
; WndProc proc. Each message can have additional values associated with it
; in the two parameters, wParam & lParam. The range of additional data that
; can be passed to an application is determined by the message.
; -------------------------------------------------------------------------

    .if uMsg == WM_COMMAND
    ;----------------------------------------------------------------------
    ; The WM_COMMAND message is sent by menus, buttons and toolbar buttons.
    ; Processing the wParam parameter of it is the method of obtaining the
    ; control's ID number so that the code for each operation can be
    ; processed. NOTE that the ID number is in the LOWORD of the wParam
    ; passed with the WM_COMMAND message. There may be some instances where
    ; an application needs to seperate the high and low words of wParam.
    ; ---------------------------------------------------------------------
    
    ;======== menu commands ========

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

    ;====== end menu commands ======
    .elseif uMsg == WM_LBUTTONDOWN
            mov eax,lParam
            and eax,0FFFFh
            mov hitpoint.x,eax
            mov eax,lParam
            shr eax,16
            mov hitpoint.y,eax

    .elseif uMsg == WM_LBUTTONUP
            mov eax,lParam
            and eax,0FFFFh
            mov hitpointEnd.x,eax
            mov eax,lParam
            shr eax,16
            mov hitpointEnd.y,eax
            invoke wsprintf,addr buffer,chr$("Posicao Inicial =  %d, %d Posicao Final =  %d, %d"), hitpoint.x, hitpoint.y,hitpointEnd.x,hitpointEnd.y
         ;   invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
            invoke InvalidateRect, hWnd, NULL, FALSE
            mov   rect.left, 10
            mov   rect.top , 200
            mov   rect.right, 350
            mov   rect.bottom, 230
            invoke InvalidateRect, hWnd, addr rect, TRUE

    .elseif uMsg == WM_CHAR
            invoke wsprintf,addr buffer,chr$("counterX: %d"), counterY
            invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName, MB_OK
    .elseif uMsg == WM_KEYDOWN
            ;invoke wsprintf,addr buffer,chr$("Tecla codigo = %d"), wParam            
            ;invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
            ; X vai de 01 ate 950
            ; Y vai de 01 ate 910
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
    
    .elseif uMsg == WM_CLOSE
            
    .elseif uMsg == WM_FINISH
            ; aqui iremos desenhar sem chamar a função InvalideteRect
;            invoke GetDC, hWnd
;            mov    hDC, eax
                          
;            invoke ReleaseDC, hWin, hDC
            
            mov   rect.left, 100
            mov   rect.top , 100
            mov   rect.right, 32
            mov   rect.bottom, 32
            invoke InvalidateRect, hWnd, NULL, TRUE ;;addr rect, TRUE

    .elseif uMsg == WM_PAINT

            invoke BeginPaint,hWin,ADDR Ps
            ; aqui entra o desejamos desenha, escrever e outros.
            ; há uma outra maneira de fazer isso, mas veremos mais adiante.
            
            mov    hDC, eax

            ; Background image

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax
            invoke SelectObject, memDC, hBmpBack
            mov  hOld, eax  
            invoke BitBlt, hDC, 0, 0,3320,2300, memDC, 10,10, SRCCOPY
            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  

            ; invoke GetClientRect,hWnd, ADDR rect
          
            ; invoke DrawText, hDC, ADDR pontText, -1, ADDR rect, \
            ;      DT_SINGLELINE

            .if counterY > 610
              mov counterX, 50
              mov counterY, 40
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX        
              mov appleX, edx 
              add appleX, 150  
              .if edx < 40
                add edx, 40
              .endif
              xor edx, edx
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
               mov appleY, edx  
               add appleY, 150                       
              .if edx < 40
                add edx, 40
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
              mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
              .if edx < 40
                add edx, 40
              .endif
              mov appleX, edx 
              xor edx, edx
              invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
              lea esi, random_bytes
              lodsd 
              mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
              xor edx, edx                        ; Needed for DIV
              div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
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
            
            ; Block image
            
 
            mov edx, 0 ; counter

            ; Body

            .WHILE edx < pont
              mov edi, offset bodyX
              mov esi, offset bodyY
              ; mov tempX, dword ptr [edi + edx] ; x
              ; mov tempY, dword ptr [esi + edx] ; y
              invoke CreateCompatibleDC, hDC
              mov   memDC, eax
              invoke SelectObject, memDC, hBmpBlock
              mov  hOld, eax  
              invoke TransparentBlt, hDC, dword ptr [edi + edx], dword ptr [esi + edx], 12,14, memDC, \
                            0, 0, 7, 12, CREF_TRANSPARENT
              invoke SelectObject,hDC,hOld
              invoke DeleteDC,memDC 
              invoke wsprintf,addr buffer,chr$("tempX: %d"), tempX            
              invoke MessageBox,hWin,ADDR buffer,ADDR szDisplayName,MB_OK
              inc edx
            .ENDW

            xor eax, eax
            xor ecx, ecx
            xor ebx, ebx

            ; Apple image

            invoke CreateCompatibleDC, hDC
            mov   memDC, eax

            invoke SelectObject, memDC, hBmpApple
            mov  hOld, eax  

            invoke TransparentBlt, hDC, appleX, appleY, 24, 30, memDC, \
                            0, 0, 28, 33, CREF_TRANSPARENT

            invoke SelectObject,hDC,hOld
            invoke DeleteDC,memDC  
        

            invoke EndPaint,hWin,ADDR Ps
            return  0

    .elseif uMsg == WM_CREATE
    ; --------------------------------------------------------------------
    ; This message is sent to WndProc during the CreateWindowEx function
    ; call and is processed before it returns. This is used as a position
    ; to start other items such as controls. IMPORTANT, the handle for the
    ; CreateWindowEx call in the WinMain does not yet exist so the HANDLE
    ; passed to the WndProc [ hWin ] must be used here for any controls
    ; or child windows.
    ; --------------------------------------------------------------------
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

    .elseif uMsg == WM_CLOSE
 
    .elseif uMsg == WM_DESTROY
    ; ----------------------------------------------------------------
    ; This message MUST be processed to cleanly exit the application.
    ; Calling the PostQuitMessage() function makes the GetMessage()
    ; function in the WinMain() main loop return ZERO which exits the
    ; application correctly. If this message is not processed properly
    ; the window disappears but the code is left in memory.
    ; ----------------------------------------------------------------
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam
    ; --------------------------------------------------------------------
    ; Default window processing is done by the operating system for any
    ; message that is not processed by the application in the WndProc
    ; procedure. If the application requires other than default processing
    ; it executes the code when the message is trapped and returns ZERO
    ; to exit the WndProc procedure before the default window processing
    ; occurs with the call to DefWindowProc().
    ; --------------------------------------------------------------------

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    ; ----------------------------------------------------
    ; This procedure calculates the top X & Y co-ordinates
    ; for the CreateWindowEx call in the WinMain procedure
    ; ----------------------------------------------------

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ########################################################################

ThreadProc PROC USES ecx Param:DWORD

  invoke WaitForSingleObject, hEventStart, 300
  .if eax == WAIT_TIMEOUT && stop == "f"
    mov edx, counterX ; temp
    mov ebx, counterY ; temp

    .if direction == "r"
      add counterX, 10
    .endif

    .if direction == "l"
      sub counterX, 10
    .endif

    .if direction == "u"
      sub counterY, 10
    .endif

    .if direction == "d"
      add counterY, 10
    .endif

    mov eax, appleX
    sub eax, 25
    mov ecx, appleX
    add ecx, 25 

    ; EBP -> nao usar
    .if counterX >= eax && counterX <= ecx    ; Colisao Cobra X Maca
      mov eax, appleY
      sub eax, 20
      mov ecx, appleY
      add ecx, 20

      .if counterY >= eax && counterY <= ecx
        mov edi, offset bodyX
        mov esi, offset bodyY
        mov eax, pont

        mov dword ptr[edi + eax], edx ; x temporario
        mov dword ptr [esi + eax], ebx ; y temporario
        inc pont

        ;.if pont == 0
         ; .if direction == "r"
          ;  mov ecx, counterX
           ; sub ecx, 20
            ;mov edx, counterY
            ;mov dword ptr [ebp + edi], ecx
            ;mov dword ptr [esi + edi], edx
          ;.endif
          ;.if direction == "l"
           ; mov ecx, counterX
            ;add ecx, 20
            ;mov edx, counterY
            ;mov dword ptr [ebp + edi], ecx
            ;mov dword ptr [esi + edi], edx
          ;.endif
          ;.if direction == "u"
           ; mov ecx, counterY
           ; add ecx, 20
           ; mov edx, counterX
           ; mov dword ptr [ebp + edi], edx
           ; mov dword ptr [esi + edi], ecx
          ;.endif
          ;.if direction == "d"
           ; mov ecx, counterY
           ; sub ecx, 20
           ; mov edx, counterX
           ; mov dword ptr [ebp + edi], edx
          ; mov dword ptr [esi + edi], ecx
          ;.endif
        ;.endif
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
        xor edx, edx                        ; Needed for DIV
        div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
        .if edx < 40
          add edx, 40
        .endif
        mov appleX, edx 
        xor edx, edx
        invoke CDGenerateRandomBits, Addr random_bytes, (NumberOfNumbers)
        lea esi, random_bytes
        lodsd 
        mov ecx, RangeOfNumbers             ; Range (0..RangeOfNumbers-1)
        xor edx, edx                        ; Needed for DIV
        div ecx                             ; EDX:EAX/ECX -> EAX remainder EDX
        .if edx < 40
          add edx, 40
        .endif
        mov appleY, edx 
      .endif
  
    .endif

    invoke SendMessage, hWnd, WM_FINISH, NULL, NULL

  .endif
  jmp  ThreadProc
  ret  

ThreadProc ENDP 

end start
