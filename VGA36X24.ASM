		.186
                .Model  tPascal

ScrX            equ   360
ScrX1           equ     0
ScrX2           equ   359
ScrY1           equ     0

ScrX4 = ScrX shr 2

                .Data


extrn           MouseNumButtons         : byte
extrn           MouseFlags              : byte
extrn           MouseButtons            : byte
extrn           MouseVisibility         : byte
extrn           MouseQuLen              : byte
extrn           MouseLB                 : byte
extrn           MouseRB                 : byte
extrn           MouseCB                 : byte
extrn           MouseEventOccured       : byte
extrn           MouseBackgrExist        : byte
extrn           MouseVisible            : byte
extrn           MouseEnabled            : byte
extrn           MouseQuEnabled          : byte
extrn           MouseCurShift           : word
extrn           MouseCurHV              : word
extrn           MouseSaveAreaX          : word
extrn           MouseSaveAreaY          : word
extrn           MouseSaveAreaHV         : word
extrn           MouseHor                : word
extrn           MouseVert               : word
extrn           MouseXShifted           : word
extrn           MouseYShifted           : word
extrn           MouseHorDist            : word
extrn           MouseVertDist           : word
extrn           MouseCurPtr             : dword

extrn           MouseEvFlags            : byte
extrn           MouseEvX                : word
extrn           MouseEvY                : word

extrn           MousePreserveArea
extrn           WindowsDT
extrn           MouseQu

extrn           SegA000                 : word
extrn           ImageOffset             : word

extrn           CurColor                : byte
extrn           Test8086                : byte
extrn           BackgroundColor         : byte
extrn           CurX                    : word
extrn           CurY                    : word

extrn           f_Height                : word
extrn           f_Font                  : dword
extrn           f_Width                 : dword
extrn           f_DefWidth              : byte
extrn           f_MaskExist             : byte
extrn		f_InterLine		: byte

extrn           c_HV                    : word
extrn           c_Font                  : dword
extrn           c_Ofs                   : byte
extrn           c_XLAT                  : dword
extrn           c_Spacing               : byte
extrn           c_Mode                  : byte

extrn		CurPalette		: dword
extrn		ScrY2			: word
extrn		ScrY			: word
extrn		PageSize		: word

extrn		LineMode		: byte
extrn		LinePoints		: dword
extrn		LinePointsPos		: word


extrn		SetCourierAddr		: dword
extrn		SetTinyAddr		: dword

		f_GetWidth              dw      ?
		c_ColorText             dw      ?
                BegX			dw	?
                TextAttr		dw	?

                .Code

                jumps
                Locals  @@

public          SetVideoMode
public		SetDoubleRetrace,SetSingleRetrace

public          MouseInit, MouseDone
public          MouseQuEnable, MouseQuDisable, MouseGetEvent
public          MouseSetShape
public          MouseCenter, MouseGotoXY
public          MouseEnable, MouseDisable
public          MouseShow, MouseHide
public          FullDrawInit, FullDrawDone
public          PartDrawInit, PartDrawDone
public          SetWindowAttr, SetWindowPos, RefreshWindow
public          ScreenPutInit, ScreenPutDone
public          PutBitMap,PutTranspBitMap,PutLightBitMap,PutLightTranspBitMap
public          GetBitMap
public          Line,HorizLine,FullHorLine,GridHorLine,VertLine
public          Clipping
public          PutPixel,PutTPoint, PutTruePixel, GetPixel
public          GetLightColor
public          Bar,Bar4
public          InternalEllipse
public          ColorPoly
public          Cls,ClearPage,PageCopy,GPCopy
public		SetActivePage,SetVisualPage,SetVisualOffset
public          WaitRetrace,SetAllPalette
public          FindColor,MakeLightTbl,GetLightTbl,SetLightTbl
public          WriteXY,PrintXY,TranspText,TextWidth,TextHeight
public          SetMonoAddTable,SetMonoTextMode
public          cWriteXY,cTranspText



ClrQu           macro
                dd      0EB00EBh             ; PentiumoPhobia
                endm

OPdxax          macro
                adc     dx,0
                shr     dx,1
                rcr     ax,1
                shr     dx,1
                rcr     ax,1
                endm

ModyW           equ     0C0DEh
ModyB           equ     0BAh

cmMovBl         equ     0B3h
cmMovCl		equ	0B1h
cmMovAl		equ	0B0h

;ÍÍÍÍÍÍÍÍÍÍ Window Descriptor Table Structure definition ÍÍÍÍÍÍÍÍÍÍ;

WindowDTS       struc
PosY            dw      ?
PosX            dw      ?
SizeY           dw      ?
SizeX           dw      ?
RAMPtr          dd      ?
WindowDTS       ends


SetWindowAttr   proc    far
@@WNo           equ     byte ptr ss:[bp+18]
                push    bp
                mov     bp,sp
                cld
                mov     al,@@WNo
                mov     ah,0
                imul    di,ax,12
                add     di,offset WindowsDT
                lea     si,[bp+6]
                push    ds
                pop     es
                mov     cx,6
          SegSS rep     movsw
                pop     bp
                ret     14
SetWindowAttr   endp

SetWindowPos    proc    far
                arg     WNo:byte,Pos_X:word,Pos_Y:word
                mov     al,WNo
                mov     ah,0
                imul    bx,ax,12
                mov     ax,Pos_X
                mov     [bx+WindowsDT].PosX,ax
                mov     ax,Pos_Y
                mov     [bx+WindowsDT].PosY,ax
                ret
SetWindowPos    endp


RefreshWindow   proc    far
                arg     WNo:byte
                mov     al,WNo
                mov     ah,0
                imul    bx,ax,12
                mov     ax,[bx+WindowsDT].SizeX
                sub     ax,4
                mov     @@smSizeXm4,ax
                add     ax,4
                shr     ax,2
                mov     @@smSizeXd4,ax

                cmp     MouseVisible,0
                jz      @@NoCross

                mov     ax,[bx+WindowsDT].PosX
                add     ax,[bx+WindowsDT].SizeX
                cmp     ax,MouseXShifted
                jl      @@NoCross

                mov     ax,MouseXShifted
                add     al,byte ptr MouseCurHV[0]
                adc     ah,0
                cmp     ax,[bx+WindowsDT].PosX
                jl      @@NoCross

                mov     ax,[bx+WindowsDT].PosY
                add     ax,[bx+WindowsDT].SizeY
                cmp     ax,MouseYShifted
                jl      @@NoCross

                mov     ax,MouseYShifted
                add     al,byte ptr MouseCurHV[1]
                adc     ah,0
                cmp     ax,[bx+WindowsDT].PosY
                jl      @@NoCross

                mov     MouseVisible,0
                dec	MouseVisibility

                mov     ax,MouseSaveAreaX
                cmp     ax,[bx+WindowsDT].PosX
                jl      @@Cross

                mov     ax,MouseSaveAreaY
                cmp     ax,[bx+WindowsDT].PosY
                jl      @@Cross

                mov     ax,[bx+WindowsDT].PosX
                add     ax,[bx+WindowsDT].SizeX
                mov     cx,MouseSaveAreaX
                add     cl,byte ptr MouseSaveAreaHV[0]
                adc     ch,0
                cmp     ax,cx
                jl      @@Cross

                mov     ax,[bx+WindowsDT].PosY
                add     ax,[bx+WindowsDT].SizeY
                mov     cx,MouseSaveAreaY
                add     cl,byte ptr MouseSaveAreaHV[1]
                adc     ch,0
                cmp     ax,cx
                jl      @@Cross

                mov     MouseBackgrExist,0

                call    DrawWindow

                call    MousePutCursor

                mov     MouseVisible,1
                inc	MouseVisibility
                jmp     @@Exit

@@Cross:
                push    MouseXShifted
                push    MouseYShifted
                push    MouseCurHV

                push    bx
                call    RestoreBack
                pop     bx
                call    DrawWindow

                pop     dx
                pop     cx
                pop     bx
                pusha
                call    SaveBack
                popa
                mov     si,word ptr MouseCurPtr[0]
                mov     di,word ptr MouseCurPtr[2]
                call    DrawSprite
                mov     MouseVisible,1
                inc	MouseVisibility
                jmp     @@Exit
@@NoCross:
                call    DrawWindow
@@Exit:         ret

DrawWindow      label   near
                cld
                push    ds
                mov     ax,[bx+WindowsDT].PosY
                mov     di,ScrX
                mul     di
                add     ax,[bx+WindowsDT].PosX

                OPdxax

                mov     di,ax

                mov     es,SegA000

                mov     cx,[bx+WindowsDT].SizeY

                lds     si,[bx+WindowsDT].RAMPtr
                mov     dx,3C4h
                mov     al,2
                out     dx,al
                inc     dx
@@Line:
                mov     bl,1
                push    cx di
                mov     cx,4
@@Four:
                push    cx di
                mov     al,bl
                out     dx,al
                shl     bl,1
                mov     cx,ModyW
@@smSizeXd4 = word ptr cs:[$-2]
                push    si
@@Point:
                movsb
                add     si,3
                loop    @@Point
                pop     si di cx
                inc     si
                loop    @@Four
                add     si,ModyW
@@smSizeXm4 = word ptr cs:[$-2]

                pop     di cx
                add     di, 360/4
                loop    @@Line
                pop     ds
                retn
RefreshWindow   endp



;°±²ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ²±°
;°±²Û                    Graph mouse handling procedures                  Û²±°
;°±²ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ²±°


; ÍÍÍÍÍÍÍÍÍÍ 'MouseFlags' ÍÍÍÍÍÍÍÍÍÍ
;
; ÚÄÂ6Â5Â4Â3Â2Â1Â0¿
; ÀÄÁÂÁÂÁÂÁÂÁÂÁÂÁÂÙ
;    ³ ³ ³ ³ ³ ³ ÀÄÄ> mouse movement
;    ³ ³ ³ ³ ³ ÀÄÄÄÄ> left button pressed
;    ³ ³ ³ ³ ÀÄÄÄÄÄÄ> left button released
;    ³ ³ ³ ÀÄÄÄÄÄÄÄÄ> right button pressed
;    ³ ³ ÀÄÄÄÄÄÄÄÄÄÄ> right button released
;    ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄ> center button pressed
;    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ> center button released

; ÍÍÍÍÍÍÍÍÍÍ 'MouseButtons' ÍÍÍÍÍÍÍÍÍÍ
;
; ÚÄÂÄÂÄÂÄÂÄÂ2Â1Â0¿
; ÀÄÁÄÁÄÁÄÁÄÁÂÁÂÁÂÙ
;            ³ ³ ÀÄÄ> left button state
;            ³ ÀÄÄÄÄ> right button state
;            ÀÄÄÄÄÄÄ> center button state

meMOVE          equ     00000001b
meLP            equ     00000010b
meLR            equ     00000100b
meRP            equ     00001000b
meRR            equ     00010000b
meCP            equ     00100000b
meCR            equ     01000000b
;                       ÄÄÄÄÄÄÄÄÄ
meAllEvents     equ     01111111b
meAnyButton     equ     01111110b

mcSetPos        equ     04h
mcSetHorRange   equ     07h
mcSetVertRange  equ     08h
mcSetHandler    equ     0Ch
mcSetSens       equ     0Fh
mcReset         equ     21h

MouseHorSens    equ     10h
MouseVertSens   equ     10h


MouseF          macro  Func
                mov    ax,Func
                int    33h
                endm

CalcScrOfs      macro   IR
                push    dx
                mov     ax,cx
                mov     IR,ScrX
                mul     IR
                add     ax,bx
                OPdxax
                mov     IR,ax
                pop     dx
                endm

CalcMask        macro
                mov     cl,bl
                mov     al,10001b
                and     cl,11b
                rol     al,cl
                mov     byte ptr cs:@@FirstMask,al
                mov     ch,0
                mov     cl,dh
                mov     ah,dl
                mov     bl,al
                mov     dx,3C4h
                mov     al,2
                out     dx,al
                inc     dx
                push    bp
                mov     bp,di
                endm

DrawPrepare     macro
                CalcScrOfs di
                CalcMask
                ClrQu
                endm

CalcMouseShift  macro
                sub    cl,byte ptr MouseCurShift[0]
                sbb    ch,0
                sub    dl,byte ptr MouseCurShift[1]
                sbb    dh,0
                mov    MouseXShifted,cx
                mov    MouseYShifted,dx
                endm

ClrMouseVars    macro
                mov    MouseQuLen,al
                mov    MouseBackgrExist,al
                mov    MouseFlags,al
                mov    MouseButtons,al
                mov    MouseLB,al
                mov    MouseRB,al
                mov    MouseCB,al
                mov    MouseEventOccured,al
                inc    ax
                mov    MouseEnabled,al
                call   MouseCenter
                endm

MouseInit       proc far
                MouseF mcReset
                cmp    ax,21h
                je     @@NoDriver
                mov    MouseNumButtons,bl


                xor    ax,ax
                mov    MouseVisible,al
                mov    MouseVisibility,7Fh

                ClrMouseVars

                xor    cx,cx
                mov    dx,ScrX
                MouseF mcSetHorRange
		mov    dx,ScrY
                MouseF mcSetVertRange

                mov    cx,MouseHorSens
                mov    dx,MouseVertSens
                MouseF mcSetSens

                push   cs
                pop    es
                lea    dx,MouseHandler
                mov    cx,meAllEvents
                MouseF mcSetHandler
@@NoDriver:     ret
MouseInit       endp

MouseSetShape   proc far
                arg     Adr:dword,Bounds:word,Shift:word
                call   MouseHide
                mov    ax,Bounds
                mov    MouseCurHV,ax
                mov    ax,Shift
                mov    MouseCurShift,ax
                les    bx,Adr
                mov    word ptr MouseCurPtr[0],bx
                mov    word ptr MouseCurPtr[2],es
                call   MouseShow
                ret
MouseSetShape   endp


MouseEnable     proc far
                cmp    MouseEnabled,1
                je     @@Exit
                xor    ax,ax
                ClrMouseVars
                mov    al,0
                cmp    MouseVisibility,80h
                jb     @@Set
                mov    al,1
@@Set:          mov    MouseVisible,al
@@Exit:         ret
MouseEnable     endp

MouseQuEnable   proc   far
                mov    MouseQuLen,0
                mov    MouseQuEnabled,1
                ret
MouseQuEnable   endp

MouseQuDisable  proc   far
                mov    MouseQuEnabled,0
                ret
MouseQuDisable  endp

MouseGetEvent   proc   far
                cld
                cmp    MouseQuLen,0
                jnz    @@CopyEvent
                mov    MouseEvFlags,0
                jmp    @@Exit
@@CopyEvent:    sub    MouseQuLen,5
                push   ds
                pop    es
                lea    si,MouseQu
                mov    al,MouseQuLen
                mov    ah,0
                add    si,ax
                lea    di,MouseEvFlags
                movsb
                movsw
                movsw
@@Exit:         ret
MouseGetEvent   endp

MouseHandler    proc far
                cld
                push   seg DATA
                pop    ds
                cmp    MouseEnabled,0
                jz     @@Exit
                mov    MouseEventOccured,1
                mov    MouseFlags,al
                mov    al,bl
                mov    MouseButtons,al
                and    al,1
                mov    MouseLB,al
                mov    al,bl
                shr    al,1
                and    al,1
                mov    MouseRB,al
                mov    al,bl
                shr    al,2
                and    al,1
                mov    MouseCB,al
                mov    MouseHor,cx
                mov    MouseVert,dx
                CalcMouseShift
                mov    MouseHorDist,si
                mov    MouseVertDist,di

                cmp    MouseQuEnabled,0
                jz     @@LeaveQu
                cmp    MouseQuLen,30*5
                jz     @@LeaveQu

                mov    bl,MouseQuLen
                mov    bh,0
                lea    di,MouseQu[bx]
                mov    al,MouseFlags
                cmp    bl,0
                jz     @@Not2Move
                cmp    al,meMove
                jne    @@Not2Move
                cmp    ds:[di-5],al
                jne    @@Not2Move
                mov    ax,MouseHor
                mov    ds:[di-4],ax
                mov    ax,MouseVert
                mov    ds:[di-2],ax
                jmp    @@LeaveQu

@@Not2Move:     push   ds
                pop    es
                stosb
                mov    ax,MouseHor
                stosw
                mov    ax,MouseVert
                stosw
                add    MouseQuLen,5

@@LeaveQu:
                cmp    MouseVisible,0
                jz     @@Exit

                push   cx dx
                call   RestoreBack
                pop    cx bx

                mov    dx,MouseCurHV

                push   bx cx dx
                call   SaveBack
                pop    dx cx bx

                mov    si,word ptr MouseCurPtr[0]
                mov    di,word ptr MouseCurPtr[2]
                call   DrawSprite
@@Exit:         ret
MouseHandler    endp

MouseDone       proc far
                xor    ax,ax
                mov    MouseEnabled,al
                xor    cx,cx
                MouseF mcSetHandler
                ret
MouseDone       endp

MouseDisable    proc far
                cmp    MouseEnabled,0
                jz     @@Exit
                mov    MouseEnabled,0
                call   RestoreBack
@@Exit:         ret
MouseDisable    endp

MouseSetPos     proc near
		; cx=X, dx=Y
                pushf
                cli
                mov    MouseHor,cx
                mov    MouseVert,dx
                MouseF mcSetPos
                CalcMouseShift
                cmp    MouseVisible,0
                jz     @@Invis
                call   RestoreBack
                call   MousePutCursor
@@Invis:        popf
                ret
MouseSetPos     endp

MouseCenter     proc far
                mov    cx,ScrX/2
		mov    dx,ScrY
		shr    dx,1
                call   MouseSetPos
                ret
MouseCenter     endp

MouseGotoXY     proc far
                arg     Pos_X:word,Pos_Y:word
                mov    cx,Pos_X
                mov    dx,Pos_Y
                call   MouseSetPos
                ret
MouseGotoXY     endp

MouseShow       proc far
                mov    al,0
                inc    MouseVisibility
                jns    @@SET
                cmp    MouseVisible,1
                je     @@Exit
                call   MousePutCursor
                mov    al,1
@@SET:          mov    MouseVisible,al
@@Exit:         ret
MouseShow       endp

MouseHide       proc far
                mov    al,1
                dec    MouseVisibility
                js     @@Set
                cmp    MouseVisible,0
                jz     @@Exit
                call   RestoreBack
                mov    al,0
@@Set:          mov    MouseVisible,al
@@Exit:         ret
MouseHide       endp

FullDrawInit    proc far
                ret
FullDrawInit    endp

FullDrawDone    proc far
                ret
FullDrawDone    endp

PartDrawInit    proc far
                ret
PartDrawInit    endp

PartDrawDone    proc far
                ret
PartDrawDone    endp

SaveBack        proc near
		; bx=X,cx=Y,dl=h,dh=v
                cld
                pushf
                cli
                mov     MouseBackgrExist,0
                mov     ax,bx
                add     al,dl
                adc     ah,0
                js      @@Invis
                or      bx,bx
                js      @@LeftRide
                cmp     bx,ScrX
                jnb     @@Invis
                cmp     ax,ScrX
                jb      @@HorNor
		sub     ax,ScrX ; X - Right Ride
                sub     dl,al
                jmp     @@CalcVert
@@LeftRide:
                sub     dl,al
                mov     dl,al
                xor     bx,bx
@@HorNor:
@@CalcVert:     cmp     dl,0
                jz      @@Invis
                mov     ax,cx
                add     al,dh
                adc     ah,0
                js      @@Invis
                or      cx,cx
                js      @@UpRide
                cmp     cx,ScrY
                jnb     @@Invis
                cmp     ax,ScrY
                jb      @@VertNor
                sub     ax,ScrY
                sub     dh,al
                mov     cx,ScrY
                sub     cl,dh
                sbb     ch,0
                jmp     @@DrawIt
@@UpRide:
                mov     dh,al
                xor     cx,cx
@@VertNor:
@@DrawIt:       cmp     dl,0
                jz      @@Invis
                cmp     dh,0
                jz      @@Invis
                mov     MouseSaveAreaX,bx
                mov     MouseSaveAreaY,cx
                mov     MouseSaveAreaHV,dx
                mov     MouseBackgrExist,1
                push    ds
                push    ds
                pop     es
                mov     ds,SegA000
                lea     di,MousePreserveArea

                CalcScrOfs si

                mov     al,bl
                and     al,11b
                mov     byte ptr cs:@@FirstAreaPan,al
                mov     ch,0
                mov     cl,dh
                mov     ah,dl
                mov     dx,3CEh
                mov     al,4
                out     dx,al
                inc     dx
                push    bp
                mov     bp,si

                ClrQu
@@VertLoop:     push    cx
		mov	bl,0
                org	$-1
@@FirstAreaPan  db      ?
                mov     cl,ah
@@HorzLoop:     mov     al,bl
                out     dx,al
                movsb
                dec     si
                inc     bl
                cmp     bl,4
                jb      @@not4
                inc     si
                mov     bl,0
@@not4:         loop    @@HorzLoop
                pop     cx
                add     bp,ScrX/4
                mov     si,bp
                loop    @@VertLoop
                pop     bp
                pop     ds
@@Invis:        popf
                ret
SaveBack        endp

RestoreBack     proc near
@@cmMovAl       equ     0B0h
                cld
                pushf
                cli
                cmp     MouseBackgrExist,0
                je      @@Exit
                mov     dx,MouseSaveAreaHV
                cmp     dl,0
                jz      @@Exit
                cmp     dh,0
                jz      @@Exit
                lea     si,MousePreserveArea
                mov     es,SegA000
                mov     bx,MouseSaveAreaX
                mov     cx,MouseSaveAreaY

                DrawPrepare

@@VertLoop:     push    cx
		mov	al,0
                org	$-1
@@FirstMask     db      ?
                mov     cl,ah
@@HorLoop:      out     dx,al
                movsb
                dec     di
                rol     al,1
                adc     di,0
                loop    @@HorLoop
                pop     cx
                add     bp,ScrX/4
                mov     di,bp
                loop    @@VertLoop
                pop     bp
@@Exit:         popf
                ret
RestoreBack     endp

DrawSprite      proc near
                uses    ds
		; bx=X, cx=Y, dl=h, dh=V, si=ImageOfs, di=ImageSeg

@@cmAddSi       equ     0C683h
@@cmSubSi       equ     0EE83h

                cld
                pushf
                cli
                mov     es,SegA000
                mov     @@hv,dx
                mov     @@SourceSEG,di
                mov     byte ptr cs:@@SkipFAdd,0
                mov     byte ptr cs:@@ColAdd,0
                jmp     @@Strt
@@Invis:        jmp     @@End
@@Strt:         mov     ax,bx
                add     al,dl
                adc     ah,0
                js      @@Invis
                or      bx,bx
                js      @@LeftRide
                cmp     bx,ScrX
                jnb     @@Invis
                cmp     ax,ScrX
                jb      @@HorNor
		sub     ax,ScrX ; X - Right Ride
                sub     dl,al
                mov     byte ptr cs:@@ColAdd,al
                mov     byte ptr cs:@@SkipFAdd,al
                jmp     @@CalcVert
@@LeftRide:     sub     dl,al
                mov     byte ptr cs:@@ColAdd,dl
                mov     dl,al
                xor     bx,bx
@@HorNor:
@@CalcVert:     cmp     dl,0
                jz      @@Invis
                mov     ax,cx
                add     al,dh
                adc     ah,0
                js      @@Invis
                or      cx,cx
                js      @@UpRide
                cmp     cx,ScrY
                jnb     @@Invis
                cmp     ax,ScrY
                jb      @@VertNor
                sub     ax,ScrY
                sub     dh,al
                mov     cx,ScrY
                sub     cl,dh
                sbb     ch,0
                jmp     @@DrawIt
@@UpRide:       mov     dh,al
                push    @@hv
                sub     byte ptr @@hv[0],al
                mov     al,byte ptr @@hv[1]
                mul     byte ptr @@hv[0]
                pop     @@hv
                add     si,ax
                xor     cx,cx
@@VertNor:
@@DrawIt:       cmp     dh,0
                jz      @@Invis
                cmp     dl,0
                jz      @@Invis

                DrawPrepare
                mov	bl,ah

                mov     ds,@@SourceSEG
                dw      @@cmSubSi
@@SkipFAdd      db      ?

                ClrQu
@@VertLoop:     push    cx
                mov	al,0
		org	$-1
@@FirstMask     db      ?
                mov	cl,bl
                add	si,0
		org	$-1
@@ColAdd        db      ?

@@HorLoop:      mov	ah,byte ptr ds:[si]
                inc	si
                or	ah,ah
                jz      @@NextPoint
                out     dx,al
		mov     byte ptr es:[di],ah
@@NextPoint:    rol     al,1
                adc     di,0
                loop    @@HorLoop
@@AfterHor:     pop     cx
                add     bp,ScrX/4
                mov     di,bp
                loop    @@VertLoop
                pop     bp
@@End:          popf
                ret

@@hv            dw      ?
@@SourceSEG     dw      ?
DrawSprite      endp

MousePutCursor  proc near
                mov     bx,MouseXShifted
                mov     cx,MouseYShifted
                mov     dx,MouseCurHV
                push    bx cx dx
                call    SaveBack
                pop     dx cx bx
                mov     si,word ptr MouseCurPtr[0]
                mov     di,word ptr MouseCurPtr[2]
                call    DrawSprite
                ret
MousePutCursor  endp

GetBitMap       proc    far
                arg     X:word,Y:word,H:word,V:word,Adr:dword
                uses    ds

 @@Get          macro   Panel
                mov     al,Panel
                out     dx,al
                mov     cx,H
                mov     si,bx
                rep     movsw
                endm

                cld
                mov     ds,SegA000
                les     di,Adr
		imul    bx,Y,ScrX4
                mov     ax,X
                shr     ax,2
                add     bx,ax
                mov     dx,3CEh
                mov     al,4
                out     dx,al
                inc     dx
                shr     H,3
 @@VLoop:       @@Get   0
                @@Get   1
                @@Get   2
                @@Get   3
		add     bx,ScrX4
                dec     V
                jnz     @@VLoop
                ret
GetBitMap       endp


PutBitMapDef    macro
                arg     X:word,Y:word,H:word,V:word,Adr:dword
                uses    ds
                cld
                mov     es,SegA000
                lds     si,Adr
		imul    bx,Y,ScrX4
                mov     ax,X
                shr     ax,2
                add     bx,ax
                mov     dx,3C4h
                mov     al,2
                out     dx,al
                inc     dx
                endm

PutBitMap       proc far
 @@Draw         macro   Panel
                mov     al,Panel
                out     dx,al
                mov     cx,H
                mov     di,bx
                rep     movsw
                endm

                PutBitMapDef
                shr     H,3
 @@VLoop:       @@Draw 1
                @@Draw 2
                @@Draw 4
                @@Draw 8
		add     bx,ScrX4
                dec     V
                jnz     @@VLoop
                ret
PutBitMap       endp

PutTranspBitMap proc far
 @@Draw         macro   Panel
                local   L,S
                mov     al,Panel
                out     dx,al
                mov     cx,H
                mov     di,bx
        L:      lodsb
                cmp     al,0
                jz      S
                mov     byte ptr es:[di],al
        S:      inc     di
                loop    L
                endm

                PutBitMapDef
                shr     H,2
 @@VLoop:       @@Draw 1
                @@Draw 2
                @@Draw 4
                @@Draw 8
		add     bx,ScrX4
                dec     V
                jnz     @@VLoop
                ret
PutTranspBitMap endp

PutLightBitMap   proc far
 @@Draw         macro   Panel
     local @@1
                mov     al,Panel
                out     dx,al
                mov     cx,H
                mov     di,BPtr
           @@1: lodsb
          SegCS xlat
                stosb
                loop    @@1
                endm

                local   BPtr
                PutBitMapDef

                shr     H,2
                mov     BPtr,bx
                lea     bx,LightTbl
 @@VLoop:       @@Draw 1
                @@Draw 2
                @@Draw 4
                @@Draw 8
		add     BPtr,ScrX4
                dec     V
                jnz     @@VLoop
                ret
PutLightBitMap   endp

PutLightTranspBitMap   proc far
 @@Draw         macro   Panel
     local @@1,S
                mov     al,Panel
                out     dx,al
                mov     cx,H
                mov     di,BPtr
           @@1: lodsb
                cmp     al,0
                jz      S
          SegCS xlat
                mov     byte ptr es:[di],al
        S:      inc     di
                loop    @@1
                endm

                local   BPtr
                PutBitMapDef

                shr     H,2
                mov     BPtr,bx
                lea     bx,LightTbl
 @@VLoop:       @@Draw 1
                @@Draw 2
                @@Draw 4
                @@Draw 8
                add     BPtr,ScrX4
                dec     V
                jnz     @@VLoop
                ret
PutLightTranspBitMap   endp

ScreenPutInit   proc far
ScreenPutInit   endp

ScreenPutDone   proc far
ScreenPutDone   endp

SetVideoMode    proc far
		mov     ax,13h     ; Call BIOS int10h (ax=13h)
                int     10h
                mov     dx,3c4h
                mov     ax,0604h
                out     dx,ax
                mov     ax,0100h
                out     dx,ax
		mov     dx,3c2h
                mov     al,0e7h
                out     dx,al
                mov     dx,3c4h
                mov     ax,0300h
                out     dx,ax
                mov     dx,3ceh                 ; Set ModeX
                mov     ax,4005h
                out     dx,ax
                mov     ax,0506h
                out     dx,ax
                mov     es,SegA000
                xor     di,di                   ; Clear VRAM
                xor     ax,ax
                mov     cx,8000h
                rep     stosw
                mov     dx,3d4h                 ; Set CRTC regs
                lea     si,@@ModeSetup
                mov     cx,18
          SegCS rep     outsw
		mov	ScrY2,239
		mov	ScrY,240
		mov	PageSize,(ScrX4)*240
                ret
 @@ModeSetup    dw 0C11h,6b00h,5901h,5a02h,8e03h,5e04h,8a05h,0D06h,3e07h
                dw 4109h,0ea10h,08c11h,0df12h,2d13h,14h,0e715h,616h,0e317h
SetVideoMode    endp

SetDoubleRetrace proc	far
		mov	dx,3D4h
		mov     ax,04009h
		out     dx,ax
		mov	ScrY2,479
		mov	ScrY,280
		mov	PageSize,(ScrX4)*480
		ret
SetDoubleRetrace endp

SetSingleRetrace proc	far
		mov	dx,3D4h
		mov     ax,04109h
		out     dx,ax
		mov	ScrY2,239
		mov	ScrY,240
		mov	PageSize,(ScrX4)*240
		ret
SetSingleRetrace endp

TruncateX       proc    near
		mov     ax,ScrX1
		cmp     ax,ss:[bx]
		jle     @@1
		mov     ss:[bx],ax
                inc     cl
      @@1:      mov     ax,ScrX2
                cmp     ax,ss:[bx]
                jge     @@2
                mov     ss:[bx],ax
                inc     cl
      @@2:      ret
TruncateX       endp

TruncateY       proc    near
                mov     ax,ScrY1
                cmp     ax,ss:[bx]
                jle     @@1
                mov     ss:[bx],ax
                inc     cl
      @@1:      mov     ax,ScrY2
                cmp     ax,ss:[bx]
                jge     @@2
                mov     ss:[bx],ax
                inc     cl
      @@2:      ret
TruncateY       endp


IntrHorLine     proc    near

; Draw horisontal line si-bx (es:di points to current Y)

                local   F:byte,L:byte

		cld
                mov     dx,3C4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     cx,bx
                sub     cx,si
                jnz     @@NP
                mov     cx,si
                shr     si,2
                add     di,si
                and     cx,3
                mov     al,1
                shl     al,cl
                out     dx,al
                mov     al,CurColor
                stosb
                jmp     @@5
      @@NP:     inc     cx
                inc     bx
                mov     ax,si
                and     ax,3
                mov     F,al
                jz      @@@1
                mov     ah,4
                sub     ah,al
                shr     ax,8
                sub     cx,ax
                jnc     @@@1
                xor     cx,cx
    @@@1:       mov     ax,bx
                and     ax,3
                mov     L,al
                sub     cx,ax
                jnc     @@@3
                xor     cx,cx
     @@@3:      mov     ax,si
                shr     ax,2
                add     di,ax
                cmp     F,0
                jz      @@2
                cmp     L,0
                jz      @@@2
                cmp     cx,0
                jg      @@@2
                push    cx
                mov     cx,bx
                shr     cx,2
                mov     ax,si
                shr     ax,2
                cmp     ax,cx
                pop     cx
                jnz     @@@2
                mov     al,0Fh
                mov     cl,F
                shl     al,cl
                mov     cl,4
                sub     cl,L
                mov     ah,0Fh
                shr     ah,cl
                and     al,ah
                out     dx,al
                mov     al,CurColor
                stosb
                jmp     @@5
        @@@2:   push    cx
                mov     al,0Fh
                mov     cl,F
                shl     al,cl
                out     dx,al
                mov     al,CurColor
                stosb
                pop     cx
         @@2:   shr     cx,2
                jz      @@3
                mov     al,0Fh
                out     dx,al
                mov     al,CurColor
                mov     ah,al
                cmp     Test8086,2
                jb      @@186
                .386
                push    ax
                push    ax
                pop     eax
                push    cx
                shr     cx,2
                rep     stosd
                pop     cx
                and     cx,3
                rep     stosb
                jmp     @@3
         @@186: shr     cx,1
                rep     stosw
                adc     cx,0
                rep     stosb
         @@3:   cmp     L,0
                jz      @@5
                mov     cl,4
                sub     cl,L
                mov     al,0Fh
                shr     al,cl
                out     dx,al
                mov     al,CurColor
		stosb
      @@5:      ret
IntrHorLine     endp


HorizLine       proc    far
		arg     x1:word,x2:word,y:word
		mov     cl,0
		lea     bx,x1
		call    TruncateX
		lea     bx,x2
		call    TruncateX
		cmp     cl,1
		ja      @@5
		mov     ax,y
		cmp     ax,ScrY1
		jl      @@5
		cmp     ax,ScrY2
		jg      @@5
		mov     di,x1
		cmp     di,x2
		jle     @@1
		xchg    di,x2
		mov     x1,di
	@@1:    cmp	LineMode,0
		jz	@@V
		les	di,LinePoints
		add	di,LinePointsPos
		mov	cx,x2
		cmp	Test8086,2
		jb	@@186
		.386
		mov	ax,x1
		sub	cx,ax
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		shl	eax,16
		mov	ax,y
	@@P3:	stosd
		inc	ax
		loop	@@P3
		.186
		jmp	@@5
	@@186:  mov	si,x1
		sub	cx,si
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		mov	dx,y
	@@P1:	mov	ax,dx
		stosw
		mov	ax,si
		inc	si
		stosw
		loop	@@P1
		jmp	@@5

	@@V:    mov     es,SegA000
		imul    di,y,ScrX4
		add     di,ImageOffset
		mov     si,x1
		mov     bx,x2
		call    IntrHorLine
      @@5:      ret
HorizLine       endp

FullHorLine	proc	far
		arg     y:word
		cld
		mov     es,SegA000
		imul    di,y,ScrX4
		add     di,ImageOffset
		cmp     Test8086,2
		mov     dx,3C4h
		mov     ax,0F02h
		out     dx,ax
		jb      @@186
		.386
		mov     cl,CurColor
		mov     ch,cl
		mov     ax,cx
		shl     eax,16
		mov     ax,cx
		mov     cx,22	; ScrX4/4
		rep     stosd
		stosw
		.186
		jmp	@@End
	@@186:  mov     al,CurColor
		mov	ah,al
		mov     cx,ScrX4/2
		rep	stosw
	@@End:  ret
FullHorLine	endp

GridHorLine	proc	far
		arg	y:word,C1:byte,C2:byte,C3:byte,C4:byte
		cld
		mov     es,SegA000
		imul    di,y,ScrX4
		add     di,ImageOffset
		cmp     Test8086,2
		mov     dx,3C4h
		mov     al,2
		out	dx,al
		inc	dx
		mov	al,1
		out	dx,al
		mov	al,C1
		mov	es:[di],al
		mov	al,2
		out	dx,al
		mov	al,C2
		mov	es:[di],al
		mov	al,4
		out	dx,al
		mov	al,C3
		mov	es:[di],al
		mov	al,8
		out	dx,al
		mov	al,C4
		mov	es:[di],al
		mov	al,0Fh
		out	dx,al
		mov	dx,3CEh
		mov     ax,4105h
		out     dx,ax
		mov	al,es:[di]
		cmp	Test8086,2
		jb	@@186
		.386
		mov	cx,22	; ScrX4/4
		rep	stosd
		stosw
		.186
		jmp	@@1
	@@186:  mov	cx,ScrX4/2
		rep	stosw
	@@1:    mov     ax,4005h
		out     dx,ax
		ret
GridHorLine	endp


VertLine        proc    far
		arg     x:word,y1:word,y2:word
		cld
		mov     cl,0
		lea     bx,y1
		call    TruncateY
		lea     bx,y2
		call    TruncateY
		cmp     cl,1
		ja      @@LE
                mov     ax,y1
		cmp     ax,y2
                jbe     @@0
                xchg    ax,y2
		mov     y1,ax
	@@0:    cmp	LineMode,0
		jz	@@V
		les	di,LinePoints
		add	di,LinePointsPos
		mov	cx,y2
		cmp	Test8086,2
		jb	@@186
		.386
		mov	ax,y1
		sub	cx,ax
		shl	eax,16
		mov	ax,x
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		ror	eax,16
	@@P3:	stosd
		inc	ax
		loop	@@P3
		.186
		jmp	@@LE
	@@186:  mov	si,y1
		sub	cx,si
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		mov	dx,x
	@@P1:   mov	ax,si
		stosw
		inc	si
		mov	ax,dx
		stosw
		loop	@@P1
		jmp	@@LE

	@@V:    imul    ax,ScrX4
		add     ax,ImageOffset
		mov     di,x
		cmp     di,ScrX1
		jl      @@LE
		cmp     di,ScrX2
		jg      @@LE
		shr     di,2
                add     di,ax
                mov     dx,3C4h
                mov     cl,byte ptr x
		and     cl,3
                mov     bx,0102h
		shl     bh,cl
		mov     cx,y2
		sub     cx,y1
		inc     cx
		mov     es,SegA000
		mov     ax,bx
		out     dx,ax
		mov     al,CurColor
      @@2:      mov     es:[di],al
		add     di,ScrX4
		loop    @@2
      @@LE:     ret
VertLine        endp

Clipping        proc    far x1,y1,x2,y2 : word
		mov     si,X1
		mov     di,Y1
		mov     bx,X2
		mov     dx,Y2
		call    SetOutCodes
		mov     cl,al
		mov     bx,si
		mov     dx,di
		call    SetOutCodes
		mov     ch,al
@@REPEAT:       mov     ah,al
		or      al,cl           ;Inside if zero
		je      @@ExitTrue
		and     ah,cl           ;Outside if not zero
		jne     @@ExitFalse
                cmp     ch,0
                jne     @@ELSE1
                xchg    si,X2
                xchg    di,Y2
                xchg    ch,cl
@@ELSE1:        test    ch,00000001b
                je      @@ELSE2
                mov     ax,Y2
                sub     ax,di
                mov     bx,ScrX1
                sub     bx,si
                imul    bx
                mov     bx,X2
                sub     bx,si
                idiv    bx
                jo      @@ExitFalse
                add     di,ax
                mov     si,ScrX1
                jmp     @@ELSE5
@@ELSE2:        test    ch,00000010b
                je      @@ELSE3
                mov     ax,X2
                sub     ax,si
                mov     bx,ScrY1
                sub     bx,di
                imul    bx
                mov     bx,Y2
                sub     bx,di
                idiv    bx
                jo      @@ExitFalse
                add     si,ax
                mov     di,ScrY1
                jmp     @@ELSE5
@@ELSE3:        test    ch,00000100b
                je      @@ELSE4
                mov     ax,Y2
                sub     ax,di
                mov     bx,ScrX2
                sub     bx,si
                imul    bx
                mov     bx,X2
                sub     bx,si
                idiv    bx
                jo      @@ExitFalse
                add     di,ax
                mov     si,ScrX2
                jmp     @@ELSE5
@@ELSE4:        test    ch,00001000b
                je      @@ELSE5
                mov     ax,X2
                sub     ax,si
                mov     bx,ScrY2
                sub     bx,di
                imul    bx
                mov     bx,Y2
                sub     bx,di
                idiv    bx
                jo      @@ExitFalse
                add     si,ax
                mov     di,ScrY2
@@ELSE5:        mov     bx,si
                mov     dx,di
                call    SetOutCodes
                mov     ch,al
                jmp     @@REPEAT
@@ExitFalse:    stc
@@ExitTrue:     mov     cx,X2
                mov     dx,Y2
                ret

SetOutCodes     proc    near
                cmp     Test8086,2
                jb      @@186
                .386
                cmp     bx,ScrX1
                setl    al
                cmp     bx,ScrX2
                setg    ah
                shl     ah,2
                or      al,ah
                cmp     dx,ScrY1
                setl    ah
                shl     ah,1
                or      al,ah
                cmp     dx,ScrY2
                setg    ah
                shl     ah,3
                or      al,ah
                .186
                jmp     @@End
        @@186:
                cmp     bx,ScrX1
                mov     al,1
                jl      @@1
                mov     al,0
        @@1:    cmp     bx,ScrX2
                mov     ah,1
                jg      @@2
                mov     ah,0
        @@2:    shl     ah,2
                or      al,ah
                cmp     dx,ScrY1
                mov     ah,1
                jl      @@3
                mov     ah,0
        @@3:    shl     ah,1
                or      al,ah
                cmp     dx,ScrY2
                mov     ah,1
                jg      @@4
                mov     ah,0
        @@4:    shl     ah,3
                or      al,ah
        @@End:
                ret
SetOutCodes     endp
Clipping        endp

PutTPoint	proc	far  ; PutTPoint has the same code as PutPixel !
PutTPoint	endp

PutPixel        proc    far
                arg     x:word, y:word
                mov     ax,x
                cmp     ax,ScrX1
                jl      @@Done
                cmp     ax,ScrX2
                jg      @@Done
                mov     ax,y
                cmp     ax,ScrY1
                jl      @@Done
                cmp     ax,ScrY2
                jg      @@Done
                mov     dx,3C4h
                mov     ax,0102h
                mov     cl,byte ptr x
                and     cl,3
                shl     ah,cl
                out     dx,ax
                mov     ax,y
                imul    ax,ScrX4
                add     ax,ImageOffset
                mov     bx,x
                shr     bx,2
                add     bx,ax
                mov     es,SegA000
                mov     al,CurColor
                mov     es:[bx],al
      @@Done:   ret
PutPixel        endp

GetPixel        proc    far
                arg     x:word, y:word
                mov     ax,x
                cmp     ax,ScrX1
                jl      @@Invis
                cmp     ax,ScrX2
                jg      @@Invis
                mov     ax,y
                cmp     ax,ScrY1
                jl      @@Invis
                cmp     ax,ScrY2
                jng     @@Vis
      @@Invis:  mov     al,0
                jmp     @@End
      @@Vis:    mov     es,SegA000
                mov     ax,y
                imul    ax,ScrX4
                add     ax,ImageOffset
                mov     bx,x
                shr     bx,2
                add     bx,ax
                mov     al,4
                mov     ah,byte ptr x
                and     ah,3
                mov     dx,3CEh
                out     dx,ax
                mov     al,es:[bx]
      @@End:    ret
GetPixel        endp


Line            proc    far
                arg     x1:word,y1:word,x2:word,y2:word
		local   DeltaX:word,DeltaY:word
                push    x1 y1 x2 y2
                call    Clipping
                jc      @@LExit
                cmp     si,cx
                jle     @@LTR
                xchg    si,cx
                xchg    di,dx
      @@LTR:    mov     x1,si
                mov     y1,di
                mov     x2,cx
                mov     y2,dx
		mov     ax,cx
                sub     ax,si
                je      @@VLine
                mov     bx,dx
                sub     bx,di
                je      @@HLine
		jns	@@SY
		neg	bx
		mov	DeltaY,bx
		neg	bx
		jmp	@@SX
	@@SY:   mov	DeltaY,bx
	@@SX:	mov	DeltaX,ax
		cwd
		idiv    bx
		or      ax,ax
		je      @@DXmin
		push    bx
		mov     dx,bx
		mov	bx,DeltaX
		xor     ax,ax
		neg     dx
		cmp     dx,bx
		je      @@Angle45
		neg     dx
		cmp     dx,bx
		je      @@Angle45

		cmp	LineMode,0
		jz	@@MaxV
		les	di,LinePoints
		add	di,LinePointsPos
		mov	cx,DeltaX
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		mov	dx,1
		mov	ax,y1
		cmp	ax,y2
		jb	@@@Inv0
		neg	dx
	@@@Inv0:mov	bx,x1
		mov	si,DeltaX
		shr	si,1
	@@@1:   stosw
		xchg	ax,bx
		stosw
		xchg	ax,bx
		sub     si,DeltaY
		ja      @@@1N
		add     si,DeltaX
		add     ax,dx
	@@@1N:  inc	bx
		loop    @@@1
		jmp	@@LExit
	@@maxV:	sar     dx,1
		rcr     ax,1
		idiv    bx
		or      ax,ax
		jns     @@P
		neg     ax
      @@P:      shl     ax,1
		mov     si,ax
		mov     ax,ScrX4
		mul     y1
		add     ax,ImageOffset
		mov     di,x1
		shr     di,2
		add     di,ax
		mov     es,SegA000
		mov     ax,1102h
		mov     cl,byte ptr x1
		and     cl,3
		rol     ah,cl
		mov     cx,ScrX4
		pop     dx
		or      dx,dx
		jge     @@2
		neg     cx
      @@2:      mov     dx,3C4h
		out	dx,ax
		mov	al,ah
		inc	dx
		mov	ah,CurColor
		push	bp
		mov	bp,8000h
      @@5:      out     dx,al
		mov     es:[di],ah
		rol     al,1
		adc	di,0
		add     bp,si
		jnc     @@4
		add     di,cx
      @@4:      dec     bx
		jge     @@5
		pop	bp
		jmp     @@LExit

      @@DXmin:  cmp	LineMode,0
		jz      @@minV
		les	di,LinePoints
		add	di,LinePointsPos
		mov	cx,DeltaY
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		mov	dx,1
		mov	ax,y1
		cmp	ax,y2
		jb	@@@Inv1
		neg	dx
	@@@Inv1:mov	bx,x1
		mov	si,DeltaY
		shr	si,1
	@@@2:   stosw
		xchg	ax,bx
		stosw
		xchg	ax,bx
		sub     si,DeltaX
		ja      @@@2N
		add     si,DeltaY
		inc	bx
	@@@2N:  add     ax,dx
		loop    @@@2
		jmp	@@LExit


	@@minV:	push    bx
		mov	dx,DeltaX
		xor     ax,ax
		sar     dx,1
		rcr     ax,1
		idiv    bx
		or      ax,ax
		jns     @@Q
		neg     ax
      @@Q:      shl     ax,1
		mov     si,ax
		or      bx,bx
		jns     @@R
		neg     bx
      @@R:   	mov     ax,ScrX4
		mul     y1
		add     ax,ImageOffset
		mov     di,x1
		shr     di,2
		add     di,ax
		mov     es,SegA000
		mov     ax,1102h
		mov     cl,byte ptr x1
		and     cl,3
		rol     ah,cl
		mov     cx,ScrX4
		pop     dx
		or      dx,dx
		jge     @@8
		neg     cx
      @@8:      mov     dx,3C4h
		out	dx,ax
		mov	al,ah
		inc	dx
		mov	ah,CurColor
		push	bp
		mov	bp,8000h
      @@6:      mov     es:[di],ah
		add     bp,si
		jnc     @@7
		rol	al,1
		adc	di,0
		out     dx,al
	@@7:	add     di,cx
		dec     bx
		jge     @@6
		pop	bp
		jmp     @@LExit

      @@Angle45:cmp	LineMode,0
		jz	@@A45V

		les	di,LinePoints
		add	di,LinePointsPos
		mov	cx,DeltaY
		inc	cx
		mov	bx,cx
		shl	bx,2
		add	LinePointsPos,bx
		mov	dx,1
		mov	ax,y1
		cmp	ax,y2
		jb	@@@Inv4
		neg	dx
	@@@Inv4:mov	bx,x1
	@@@4:	stosw
		add	ax,dx
		xchg	ax,bx
		stosw
		inc	ax
		xchg	ax,bx
		loop	@@@4
		jmp	@@LExit

	@@A45V:	mov     ax,ScrX4
		mul     y1
		add     ax,ImageOffset
		mov     di,x1
		shr     di,2
		add     di,ax
		mov     es,SegA000
		mov     ax,1102h
		mov     cl,byte ptr x1
		and     cl,3
		rol     ah,cl
		mov     cx,ScrX4
		pop     dx
		or      dx,dx
		jge     @@9
		neg     cx
      @@9:      mov     dx,3C4h
		out	dx,ax
		mov	al,ah
		inc	dx
		mov	ah,CurColor
      @@A:      out     dx,al
		mov     es:[di],ah
		rol     al,1
		adc	di,0
		add     di,cx
		dec     bx
		jge     @@A
		jmp     @@LExit

      @@VLine:  push    x1 y1 y2
		call    VertLine
		jmp     @@LExit

      @@HLine:  push    x1 x2 y1
		call    HorizLine
      @@LExit:  ret
Line            endp

Bar             proc    far
		arg     x1:word,y1:word,x2:word,y2:word
		local   DY:word,SV:byte
                cld
		mov     cl,0
		lea     bx,x1
		call    TruncateX
                lea     bx,x2
                call    TruncateX
                cmp     cl,1
                ja      @@LocEx
                mov     cl,0
                lea     bx,y1
                call    TruncateY
                lea     bx,y2
                call    TruncateY
                cmp     cl,1
                ja      @@LocEx
      @@7:      mov     ax,x1
                cmp     ax,x2
                jle     @@5
                xchg    ax,x2
                mov     x1,ax
      @@5:      mov     ax,y1
                cmp     ax,y2
                jle     @@6
                xchg    ax,y2
                mov     y1,ax
      @@6:      imul    ax,ScrX4
                add     ax,ImageOffset
                mov     di,x1
                shr     di,2
                add     di,ax
                mov     cl,byte ptr x1
                and     cl,3
                mov     bh,01h
                shl     bh,cl
                mov     SV,bh
                mov     cx,y2
                sub     cx,y1
                inc     cx
                mov     DY,cx
                mov     si,x2
                sub     si,x1
                inc     si
                mov     dx,3C4h
                mov     es,SegA000
      @@0:      push    si di
                mov     bl,4
                mov     bh,SV
      @@1:      push    di
                mov     ah,bh
                mov     al,2
                out     dx,ax
                mov     al,CurColor
                cmp     Test8086,2
                jb      @@186
                .386
                mov     cl,al
                mov     ch,al
                mov     ax,cx
                shl     eax,16
                mov     ax,cx
                mov     cx,si
                add     cx,3
                shr     cx,2
                push    cx
                shr     cx,2
                rep     stosd
                pop     cx
                and     cx,3
                rep     stosb
                .186
                jmp     @@STO
    @@186:      mov     ah,al
                mov     cx,si
                add     cx,3
                shr     cx,3
                rep     stosw
                adc     cl,0
                rep     stosb
      @@STO:    pop     di
                shl     bh,1
                cmp     bh,8
                jbe     @@3
                mov     bh,1
                inc     di
      @@3:      dec     si
                jle     @@4
                dec     bl
                jne     @@1
      @@4:      pop     di
                pop     si
                add     di,ScrX4
                dec     DY
                jne     @@0
      @@LocEx:
                ret
Bar             endp

Bar4            proc    far
                arg     x:word,y:word,w:word,h:word
                cld
                mov     ax,y
                imul    ax,ScrX4
                add     ax,ImageOffset
                mov     di,x
                shr     di,2
                add     di,ax
                mov     dx,3C4h
                mov     ax,0F02h
                out     dx,ax
                mov     es,SegA000
                add     w,3
                shr     w,2
                mov     al,CurColor
                mov     ah,al
                mov     si,ScrX4
                sub     si,w
                mov     bx,h
                cmp     Test8086,2
                jb      @@186
                .386
                mov     cx,ax
                shl     eax,16
                mov     ax,cx
      @@386:    mov     cx,w
                push    cx
                shr     cx,2
                rep     stosd
                pop     cx
                and     cx,3
                rep     stosb
                add     di,si
                dec     bx
                jne     @@386
                .186
                jmp     @@LocEx
      @@186:    mov     cx,w
                shr     cx,1
                rep     stosw
                adc     cl,0
                rep     stosb
                add     di,si
                dec     bx
                jne     @@186
      @@LocEx:
                ret
Bar4            endp

InternalEllipse proc    near
                arg     x:word,y:word,RadX:word,RadY:word,What:Byte
                local   LoVARd:word,HiVARd:word,LoVARdx:word,HiVARdx:word
                local   PutProc:word,LoVARd:word,HiVARd:word,LoVARdx:word
                local   HiVARdx:word,PutProc:word,LoVARdy:word,HiVARdy:word
                local   LoAsquared:word,HiAsquared:word,LoBsquared:word
                local   HiBsquared:word,LoTwoAsquared:word,DtX:word
                local   HiTwoAsquared:word,LoTwoBsquared:word
                local   HiTwoBsquared:word,ULAddr:word,URAddr:word
                local   LRAddr:word,LLAddr:Word,LongMultiply:word
                local   LMask:byte,RMask:byte;

                lea     ax,LongMul386
                cmp     Test8086,2
                jb      @@SetMulPrc
                lea     ax,LongMul186
  @@SetMulPrc:  mov     LongMultiply,ax
                mov     PutProc,offset Set4Pixels
                cmp     What,1
                jne     @@NoOne
                mov     PutProc,offset DrawLines
@@NoOne:        mov     DtX,0
	   ; initial constants
                mov     ax,RadX
                mul     ax
                mov     LoAsquared,ax
		mov     HiAsquared,dx    ; a^2
                shl     ax,1
                rcl     dx,1
                mov     LoTwoAsquared,ax
		mov     HiTwoAsquared,dx ; 2*a^2
                mov     ax,RadY
                mul     ax
                mov     LoBsquared,ax
		mov     HiBsquared,dx    ; b^2
                shl     ax,1
                rcl     dx,1
                mov     LoTwoBsquared,ax
		mov     HiTwoBsquared,dx ; 2*b^2
	   ; plot pixels from (0,b) until dy/dx = -1
	   ; initial buffer address and bit mask
                mov     ax,ScrX4
                mul     RadY
                mov     si,ax
                mov     di,ax
                mov     ax,y
                mov     bx,x
                mov     cl,bl
                mov     dx,ScrX4
                mul     dx
                shr     bx,2
                add     bx,ax
                add     bx,ImageOffset
                mov     es,SegA000
		add     si,bx              ; SI := offset of (0,b)
                mov     ULAddr,si
                mov     URAddr,si
		sub     bx,di              ; AX := offset of (0,-b)
                mov     LLAddr,bx
                mov     LRAddr,bx
	   ; initial decision variables
                xor     ax,ax
                mov     LoVARdx,ax
		mov     HiVARdx,ax
		mov     ax,LoTwoAsquared
		mov     dx,HiTwoAsquared
		mov     cx,RadY
		call    LongMultiply
		mov     LoVARdy,ax
		mov     HiVARdy,dx
		mov     ax,LoAsquared
		mov     dx,HiAsquared
		sar     dx,1
		rcr     ax,1
		sar     dx,1
		rcr     ax,1               ; DX:AX = Asquared/4
		add     ax,LoBsquared
		adc     dx,HiBsquared      ; DX:AX = Bsquared + Asquared/4
                mov     LoVARd,ax
                mov     HiVARd,dx
                mov     ax,LoAsquared
                mov     dx,HiAsquared
                mov     cx,RadY
		call    LongMultiply      ; DX:AX = Asquared*b
                sub     LoVARd,ax
		sbb     HiVARd,dx          ; d = Bsquared - Asquared*b + Asquared/4
	   ; loop until dy/dx >= -1
		mov     bx,RadY            ; BX := initial y-coordinate
		xor     cx,cx              ; CH := 0 (initial y-increment)
					; CL := 0 (initial x-increment)
@@L10:          mov     ax,LoVARdx
                mov     dx,HiVARdx
                sub     ax,LoVARdy
                sbb     dx,HiVARdy
		jns  @@L20               ; jump if dx>=dy
                call    PutProc
		mov     cx,1               ; CH := 0 (y-increment)
					; CL := 1 (x-increment)
                cmp     HiVARd,0
		js      @@L11               ; jump if d < 0
		mov     ch,1               ; increment in y direction
		dec     bx                 ; decrement current y-coordinate
                mov     ax,LoVARdy
                mov     dx,HiVARdy
		sub     ax,LoTwoAsquared   ; DX:AX := dy - TwoAsquared
                sbb     dx,HiTwoAsquared
                mov     LoVARdy,ax
		mov     HiVARdy,dx         ; dy -= TwoAsquared
                sub     LoVARd,ax
		sbb     HiVARd,dx          ; d -= dy
@@L11:          mov     ax,LoVARdx
                mov     dx,HiVARdx
		add     ax,LoTwoBsquared   ; DX:AX := dx + TwoBsquared
                adc     dx,HiTwoBsquared
                mov     LoVARdx,ax
		mov     HiVARdx,dx         ; dx += TwoBsquared
                add     ax,LoBsquared
		adc     dx,HiBsquared      ; DX:AX := dx + Bsquared
                add     LoVARd,ax
		adc     HiVARd,dx          ; d += dx + Bsquared
                jmp     @@L10
	   ; plot pixels from current (x,y) until y < 0
	   ; initial buffer address and bit mask
@@L20:          push    bx cx
                mov     ax,LoAsquared
                mov     dx,HiAsquared
                sub     ax,LoBsquared
                sbb     dx,HiBsquared
                mov     bx,ax
                mov     cx,dx
                sar     dx,1
		rcr     ax,1               ; DX:AX := (Asquared-Bsquared)/2
                add     ax,bx
		adc     dx,cx              ; DX:AX := 3*(Asquared-Bsquared)/2
                sub     ax,LoVARdx
                sbb     dx,HiVARdx
                sub     ax,LoVARdy
		sbb     dx,HiVARdy         ; DX:AX := 3*(Asquared-Bsquared)/2 - (dx+dy)
		sar     dx,1
		rcr     ax,1   ; DX:AX := ( 3*(Asquared-Bsquared)/2 - (dx+dy) )/2
                add     LoVARd,ax
                adc     HiVARd,dx
           ; loop until y < 0
                pop     cx bx              ; CH,CL := y- and x-increments
@@L21:          call    PutProc		   ; BX := y
                mov     cx,100h            ; CH := 1 (y-increment)
           ; CL := 0 (x-increment)
                cmp  HiVARd,0
                jns     @@L22               ; jump if d >= 0
		mov     cl,1                ; increment in x direction
                mov     ax,LoVARdx
                mov     dx,HiVARdx
		add     ax,LoTwoBsquared   ; DX:AX := dx + TwoBsquared
                adc     dx,HiTwoBsquared
                mov     LoVARdx,ax
                mov     HiVARdx,dx
                add     LoVARd,ax
                adc     HiVARd,dx
@@L22:          mov     ax,LoVARdy
                mov     dx,HiVARdy
                sub     ax,LoTwoAsquared
                sbb     dx,HiTwoAsquared
                mov     LoVARdy,ax
                mov     HiVARdy,dx
                sub     ax,LoAsquared
                sbb     dx,HiAsquared
                sub     LoVARd,ax
                sbb     HiVARd,dx
                dec     bx
		jns     @@L21               ; loop if y >= 0
@@Lexit:        ret

LongMul186      proc near
                push    ax
                mov     ax,dx
                mul     cx
                xchg    ax,cx
                pop     dx
                mul     dx
                add     dx,cx
                ret
LongMul186      endp

LongMul386      proc near
                .386
                xchg    ax,dx
                shl     eax,16
                mov     ax,dx
                movzx   ecx,cx
                mul     ecx
                shld    edx,eax,16
                .186
                ret
LongMul386      endp

Set4Pixels      proc near
                uses    ax,bx,dx
                push    bx
                xor     ch,ch
                add     DtX,cx
                mov     ax,x
                sub     ax,DtX
                mov     ULAddr,ax
                add     bx,y
                cmp     bx,ScrY2
                jg      @@2
                push    ax
                mov     ax,x
                add     ax,DtX
                mov     URAddr,ax
                push    ax
                mov     ax,ScrX4
                mul     bx
                add     ax,ImageOffset
                pop     di
                push    ax
                mov     dx,3C4h
                mov     cx,di
                cmp     cx,ScrX1
                jl      @@1
                cmp     cx,ScrX2
                jg      @@1
                shr     di,2
                and     cl,3
                add     di,ax
                mov     ax,0102h
                shl     ah,cl
                out     dx,ax
                mov     al,CurColor
                mov     es:[di],al
@@1:            pop     ax
                pop     di
                mov     cx,di
                cmp     cx,ScrX1
                jl      @@2
                cmp     cx,ScrX2
                jg      @@2
                shr     di,2
                and     cl,3
                add     di,ax
                mov     ax,0102h
                shl     ah,cl
                out     dx,ax
                mov     al,CurColor
                mov     es:[di],al

@@2:            pop     bx
                mov     ax,y
                sub     ax,bx
                cmp     ax,ScrY1
                jl      @@4
                imul    ax,ScrX4
                mov     dx,3C4h
                add     ax,ImageOffset
                mov     di,ULAddr
                push    ax
                mov     cx,di
                cmp     cx,ScrX1
                jl      @@3
                cmp     cx,ScrX2
                jg      @@3
                shr     di,2
                and     cl,3
                add     di,ax
                mov     ax,0102h
                shl     ah,cl
                out     dx,ax
                mov     al,CurColor
                mov     es:[di],al
@@3:            pop     ax

                mov     di,URAddr
                mov     cx,di
                cmp     cx,ScrX1
                jl      @@4
                cmp     cx,ScrX2
                jg      @@4
                shr     di,2
                and     cl,3
                add     di,ax
                mov     ax,0102h
                shl     ah,cl
                out     dx,ax
                mov     al,CurColor
                mov     es:[di],al
@@4:            ret
Set4Pixels      endp

DrawLines       proc near
                uses    ax,bx,dx
                push    bx
                xor     ch,ch
                add     DtX,cx
                mov     ax,x
                sub     ax,DtX
                mov     ULAddr,ax
                push    ax
                mov     ax,x
                add     ax,DtX
                mov     URAddr,ax
                push    ax
                add     bx,y
                push    bx
                call    HorizLine
                pop     bx
                push    ULAddr
                push    URAddr
                mov     ax,y
                sub     ax,bx
                push    ax
                call    HorizLine
                ret
DrawLines       endp
InternalEllipse endp


                .386

ColorPoly       proc    far
                arg     Bounds : DWord, Num : Word
		local   CurrentX1 : dword       ; Current X1
		local   CurrentX2 : dword       ; Current X2
		local   Vertex1   : word        ; First poly vertex
		local   Vertex2   : word        ; Second poly vertex
		local   StartX1   : word        ; Start X for first line
		local   FinalX1   : word        ; Final X for first line
		local   StartX2   : word        ; Start X for second line
		local   FinalX2   : word        ; Final X for second line
		local   FinalY1   : word        ; Final Y for first line
		local   FinalY2   : word        ; Final Y for second line
		local   LastPoint : byte        ; 1 if processing last point
                cld
                les     si,Bounds

;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
                push    bp
                mov     cx,Num
                mov     di,es:[si+2]
                mov     bx,32767
                mov     bp,-32768
                mov     dl,1
@@L1:           SegES   lodsw
                cmp     di,es:[si]
                sete    dh
                and     dl,dh
                add     si,2
                cmp     ax,bx
                jg      @@L11
                mov     bx,ax
@@L11:          cmp     ax,bp
                jl      @@L12
                mov     bp,ax
@@L12:          loop    @@L1
                mov     ax,bp
                pop     bp
                cmp     ax,ScrX1
                jl      @@Done
                cmp     bx,ScrX2
                jg      @@Done
                sub     ax,bx
                jo      @@Done
                cmp     dl,1
                je      @@DoLine
                mov     si,word ptr Bounds
;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

                mov     bx,32767
                mov     di,-32768
                xor     cx,cx
@@L2:           add     si,2
                SegES   lodsw
                cmp     ax,bx
                jg      @@L3
                mov     bx,ax
                mov     dx,cx
@@L3:           cmp     ax,di
                jle     @@L4
                mov     di,ax
@@L4:           inc     cx
                cmp     cx,Num
                jb      @@L2
                cmp     di,ScrY1
                jl      @@Done
                cmp     bx,ScrY2
                jg      @@Done
                sub     di,bx
                jo      @@Done

                mov     si,word ptr Bounds
                mov     Vertex1,dx
                mov     Vertex2,dx
                mov     bx,dx
                shl     bx,2
                add     si,bx
                SegES   lodsw
                mov     FinalX1,ax
                mov     FinalX2,ax
                mov     word ptr CurrentX1+2,ax
                mov     word ptr CurrentX2+2,ax
                SegES   lodsw
                mov     FinalY1,ax
                mov     FinalY2,ax
                mov     si,ax
                imul    ax,ScrX4
                mov     LastPoint,0
                mov     es,SegA000
                mov     di,ImageOffset
                add     di,ax
                mov     dx,si
                mov     fs,word ptr Bounds+2

;**********°±²Û Main loop Û²±°*************
; DI = VRAM addr (X=0)
; DX = current Y
@@REPEAT:       cmp     dx,FinalY1
                jge     @@BOUND1
@@ELSE1:        cmp     dx,FinalY2
                jge     @@BOUND2
@@ELSE2:        cmp     dx,ScrY1
                jl      @@IncY
                mov     si,word ptr CurrentX1+2
                mov     bx,word ptr CurrentX2+2
                call    @@DrawLine

                add     CurrentX1,12345678h
@@DeltaX1       equ     dword ptr $-4
                add     CurrentX2,12345678h
@@DeltaX2       equ     dword ptr $-4
                add     di,ScrX4
                inc     dx
                cmp     dx,ScrY2
                jle     @@REPEAT
                jmp     @@Done

@@IncY:         mov     ax,ScrY1
                cmp     ax,FinalY1
                jl      @@IY_1
                mov     ax,FinalY1
@@IY_1:         cmp     ax,FinalY2
                jl      @@IY_2
                mov     ax,FinalY2
@@IY_2:         mov     si,ax
                sub     ax,dx
                movzx   eax,ax
                mov     ebx,eax

                mul     @@DeltaX1
                add     CurrentX1,eax
                mov     eax,ebx
                mul     @@DeltaX2
                add     CurrentX2,eax
                mov     ax,ScrX4
                mul     bx
                add     di,ax
                mov     dx,si
                cmp     dx,FinalY2
                jge     @@BOUND2
                cmp     dx,FinalY1
                jl      @@ELSE2

@@BOUND1:       cmp     LastPoint,0
                jne     @@Done
                mov     bx,Vertex1
                dec     bx
                jge     @@11
                mov     bx,Num
                dec     bx
@@11:           mov     Vertex1,bx
                cmp     bx,Vertex2
                sete    LastPoint
                mov     si,word ptr Bounds
                shl     bx,2
                add     si,bx
		mov     ax,fs:[si]      ; X
                xchg    ax,FinalX1
                mov     StartX1,ax
                mov     word ptr CurrentX1+2,ax
                mov     word ptr CurrentX1,8000h
		mov     ax,fs:[si+2]    ; Y
                mov     FinalY1,ax
                sub     ax,dx
                jg      @@12

                cmp     dx,ScrY1
                jl      @@BOUND1
                mov     si,StartX1
                mov     bx,FinalX1
                call    @@DrawLine
                jmp     @@BOUND1

@@12:           mov     si,dx           ; push dx
                movzx   ebx,ax
                mov     ax,FinalX1
                sub     ax,StartX1
                shl     eax,10h
                cdq
                idiv    ebx

                mov     @@DeltaX1,eax
		mov     dx,si           ; pop dx
                jmp     @@ELSE1

@@BOUND2:       cmp     LastPoint,0
                jne     @@Done
                mov     bx,Vertex2
                inc     bx
                cmp     bx,Num
                jb      @@21
                xor     bx,bx
@@21:           mov     Vertex2,bx
                cmp     bx,Vertex1
                sete    LastPoint
                mov     si,word ptr Bounds
                shl     bx,2
                add     si,bx
                mov     ax,fs:[si]
                xchg    ax,FinalX2
                mov     StartX2,ax
                mov     word ptr CurrentX2+2,ax
                mov     word ptr CurrentX2,8000h
                mov     ax,fs:[si+2]
                mov     FinalY2,ax
                sub     ax,dx
                jg      @@22

                cmp     dx,ScrY1
                jl      @@BOUND2
                mov     si,StartX2
                mov     bx,FinalX2
                call    @@DrawLine
                jmp     @@BOUND2

@@22:           mov     si,dx           ; push dx
                movzx   ebx,ax
                mov     ax,FinalX2
                sub     ax,StartX2
                shl     eax,10h
                cdq
                idiv    ebx
                mov     @@DeltaX2,eax
		mov     dx,si           ; pop dx
                jmp     @@ELSE2

@@DoLine:       cmp     di,ScrY1
                jl      @@Done
                cmp     di,ScrY2
                jg      @@Done
                mov     bx,32767
                mov     dx,-32768
                mov     cx,Num
                mov     si,word ptr Bounds
@@DLL0:         SegES   lodsw
                add     si,2
                cmp     ax,bx
                jg      @@DLL1
                mov     bx,ax
@@DLL1:         cmp     ax,dx
                jl      @@DLL2
                mov     dx,ax
@@DLL2:         loop    @@DLL0
                mov     si,dx
                mov     dx,di
                mov     ax,ScrX4
                imul    di
                mov     es,SegA000
                mov     di,ImageOffset
                add     di,ax
                push    offset @@Done

;*** si = StartX1; bx = FinalX1; ***
@@DrawLine:     cmp     si,bx
                jle     @@DL1
                xchg    si,bx
@@DL1:          cmp     si,ScrX2
                jg      @@LEx
                cmp     bx,ScrX1
                jl      @@LEx
                cmp     si,ScrX1
                jge     @@DL2
                mov     si,ScrX1
@@DL2:          cmp     bx,ScrX2
                jle     @@DL3
                mov     bx,ScrX2
@@DL3:          push    di dx
                call    IntrHorLine
                pop     dx di
@@LEx:          retn
@@Done:         ret
ColorPoly       endp

WaitRetrace     proc    far
                mov   dx,3DAh
        @@1:    in    al,dx
                test  al,8
                je    @@1
        @@2:    in    al,dx
                test  al,8
                jne   @@2
                ret
WaitRetrace     endp

SetAllPalette   proc    far
                arg     Addr:dword
                call    WaitRetrace
                les     si,Addr
                mov     dx,3C8h
                mov     al,0
                out     dx,al
                mov     cx,100h*3
                inc     dx
        SegES   rep     outsb
                ret
                endp

FindColor       proc    far
		arg     R:byte,G:byte,B:byte
		les     si,CurPalette
                xor     bx,bx
                mov     cx,256
                cmp     Test8086,2
                jb      @@186
                .386
                mov     edx,-1
      @@1:      push    edx
          SegES lodsb
                sub     al,R
                jnc     @@R
                neg     al
        @@R:    movzx   eax,al
                mov     edx,eax
                mul     al
                mul     edx
                mov     edi,eax
          SegES lodsb
                sub     al,G
                jnc     @@G
                neg     al
        @@G:    movzx   eax,al
                mov     edx,eax
                mul     al
                mul     edx
                add     edi,eax
          SegES lodsb
                sub     al,B
                jnc     @@B
                neg     al
        @@B:    movzx   eax,al
                mov     edx,eax
                mul     al
                mul     edx
                add     edi,eax
                pop     edx
                cmp     edi,edx
                jae     @@2
                mov     edx,edi
                mov     bx,cx
                or      edx,edx
                je      @@3
      @@2:      loop    @@1
                .186
                jmp     @@3
      @@186:    mov     dx,-1
     @@@1:SegES lodsb
                sub     al,R
                imul    al
                mov     di,ax
          SegES lodsb
                sub     al,G
                imul    al
                add     di,ax
          SegES lodsb
                sub     al,B
                imul    al
                add     di,ax
                cmp     di,dx
                jae     @@@2
                mov     dx,di
                mov     bx,cx
                or      dx,dx
                je      @@3
      @@@2:     loop    @@@1
      @@3:      dec     bx
                mov     al,bl
                not     al
                ret
FindColor       endp

PutTruePixel	proc	far
		arg	x:word,y:word,R:byte,G:byte,B:byte
		local	TC:byte
		mov	al,CurColor
		mov	TC,al
		push	word ptr R
		push	word ptr G
		push	word ptr B
		call	FindColor
		mov	CurColor,al
		push	x y
		call	PutPixel
		mov	al,TC
		mov	CurColor,al
		ret
PutTruePixel	endp


MakeLightTbl    proc    far
		arg     Intens:byte
                cld
                xor     di,di
                mov     bl,Intens
                mov     bh,100
		les     si,CurPalette
                mov     cx,256
                cmp     bl,bh
                ja      @@Light
        @@DL:   push    es si di cx bx
   rept 3
          SegES lodsb
                mul     bl
                div     bh
                push    ax
   endm
                call    FindColor
                pop     bx cx di si es
                add     si,3
                mov     cs:LightTbl[di],al
                inc     di
                loop    @@DL
                jmp     @@@
        @@Light:sub     bl,bh
        @@LL:   push    es si di cx bx
   rept 3
          SegES lodsb
                mov     dl,al
                mul     bl
                div     bh
                add     al,dl
                push    ax
   endm
                call    FindColor
                pop     bx cx di si es
                add     si,3
                mov     cs:LightTbl[di],al
                inc     di
                loop    @@LL
        @@@:    ret
MakeLightTbl    endp

GetLightTbl     proc    far
                arg     Tbl:dword
                cld
                les     di,Tbl
                lea     si,LightTbl
                mov     cx,128
          SegCS rep     movsw
                ret
GetLightTbl     endp

SetLightTbl     proc    far
                arg     Tbl:dword
                cld
                push    ds
                lds     si,Tbl
                push    cs
                pop     es
                lea     di,LightTbl
                mov     cx,128
                rep     movsw
                pop     ds
                ret
SetLightTbl     endp

Cls             proc    far
                cld
                xor     di,di
                mov     dx,3C4h
                mov     ax,0F02h
                out     dx,ax
                mov     es,SegA000
                mov     al,BackgroundColor
                mov     ah,al
                cmp     Test8086,2
                jb      @@186
                .386
		mov     cx,PageSize
		shr	cx,2
		push    ax
		push    ax
		pop     eax
		rep     stosd
		.186
		jmp     @@@
	@@186:  mov     cx,PageSize
		shr	cx,1
		rep     stosw
        @@@:    ret
Cls             endp

ClearPage       proc    far
                arg     Pg:byte
		cld
                mov     al,Pg
                mov     ah,0
		mul	PageSize
		mov	di,ax
		mov     dx,3C4h
                mov     ax,0F02h
                out     dx,ax
                mov     es,SegA000
                mov     al,BackgroundColor
                mov     ah,al
                cmp     Test8086,2
                jb      @@186
                .386
		mov     cx,PageSize
		shr	cx,2
		push    ax
		push    ax
		pop     eax
		rep     stosd
		.186
		jmp     @@@
	@@186:  mov     cx,PageSize
		shr	cx,1
		rep     stosw
        @@@:    ret
ClearPage       endp

PageCopy        proc    far
                arg     Page1:byte,Page2:byte
                mov     es,SegA000
                mov     al,Page1
                mov     ah,0
		mul	PageSize
		mov	si,ax
		mov     al,Page2
		mov	ah,0
		mul	PageSize
		mov	di,ax
		mov     cx,PageSize
		mov     dx,3C4h
		mov     ax,0F02h
		out     dx,ax
		mov     dx,3CEh
		mov     ax,0003h
		out     dx,ax
		mov     ax,4105h
		out     dx,ax
		SegES rep movsb
		mov     ax,4005h
		out     dx,ax
		ret
PageCopy        endp

GPCopy          proc    far
                arg     x:word,y:word,h:word,v:word,Page1:byte,d_x:word,d_y:word,Page2:byte
                uses    ds
                mov     al,Page1
                mov     ah,0
                mov     bx,PageSize
                mul     bx
                mov     si,x
                shr     si,2
                add     si,ax
                imul    ax,y,ScrX4
                add     si,ax
                mov     al,Page2
                mov     ah,0
		mul     bx
                mov     di,d_x
                shr     di,2
                add     di,ax
                imul    ax,d_y,ScrX4
                add     di,ax
                mov     ax,0A000h
                mov     ds,ax
                mov     es,ax
                mov     dx,03CEh
                mov     ax,4105h
		out     dx,ax           ; Write mode 1
                mov     dl,0C4h
                mov     ax,0F02h
                out     dx,ax
                mov     ax,h
                shr     ax,2
                mov     bx,v
                mov     dx,ScrX4
                sub     dx,ax

@@NextRow:      mov     cx,ax
                rep     movsb
                add     si,dx
                add     di,dx
		dec     bx
		jne     @@NextRow
		mov     dx,03CEh
		mov     ax,4005h
		out     dx,ax           ; Write mode 0
		ret
GPCopy          endp

SetActivePage	proc	far
		arg	Pg:byte
		mov     al,Pg
		mov     ah,0
		mov     bx,PageSize
		mul     bx
		mov	ImageOffset,ax
		ret
SetActivePage	endp

SetVisualPage	proc	far
		arg	Pg:byte
		mov     al,Pg
		mov     ah,0
		mov     bx,PageSize
		mul     bx
		mov	bx,ax
		mov     dx,3D4h
		mov     al,0Ch
		mov     ah,bh
		out     dx,ax
		inc     al
		mov     ah,bl
		out     dx,ax
		ret
SetVisualPage	endp


SetVisualOffset proc	far
		arg	Ofs:word
		mov	bx,Ofs
		mov     dx,3D4h
		mov     al,0Ch
		mov     ah,bh
		out     dx,ax
		inc     al
		mov     ah,bl
		out     dx,ax
		ret
SetVisualOffset endp

PutChar1        proc    near
		arg     Attr:byte
		local   TV:byte,VC:byte,AO:word
		cld
		mov     AO,offset MonoAddTable
		push	ds
		mov     ax,f_Height
		mov     VC,al
                mul     bl
                add     ax,word ptr f_Font
                mov     si,ax
                imul    ax,CurY,ScrX4
                add     ax,ImageOffset
                mov     di,CurX
                shr     di,2
                add     di,ax
                mov     bx,0102h
                mov     dx,3C4h
                mov     cl,byte ptr CurX
                and     cl,3
                shl     bh,cl
                mov     es,SegA000
                mov     ds,word ptr f_Font[2]
      @@1:      lodsb
                mov     TV,al
                mov     al,Attr
		mov     cx,bx  ; push bx
                mov     bx,AO
                add     al,cs:[bx]
                inc     bx
                mov     AO,bx
		mov     bx,cx  ; pop bx
                mov     cx,8
                push    di bx
      @@2:      xchg    ax,bx
                out     dx,ax
                xchg    ax,bx
                shl     TV,1
                jnc     @@3
                mov     es:[di],al
      @@3:      shl     bh,1
                cmp     bh,8
                jbe     @@4
                inc     di
                mov     bh,1
      @@4:      loop    @@2
                pop     bx di
                add     di,ScrX4
                dec     VC
                jne     @@1
                pop     ds
                ret
PutChar1        endp

PutCharB        proc    near
                arg     Attr:byte
                local   TV:byte,VC:byte
                uses    ds
                cld
                mov     ax,f_Height
                mov     VC,al
                mul     bl
                add     ax,word ptr f_Font
                mov     si,ax
                imul    ax,CurY,ScrX4
                add     ax,ImageOffset
                mov     di,CurX
                shr     di,2
                add     di,ax
                mov     bx,0102h
                mov     dx,3C4h
                mov     cl,byte ptr CurX
                and     cl,3
                shl     bh,cl
                mov     es,SegA000
                mov     ds,word ptr f_Font[2]
      @@1:      lodsb
                mov     TV,al
                mov     al,Attr
                mov     cx,8
                push    di bx
      @@2:      xchg    ax,bx
                out     dx,ax
                xchg    ax,bx
                shl     TV,1
                jnc     @@3
                mov     es:[di],al
      @@3:      shl     bh,1
                cmp     bh,8
                jbe     @@4
                inc     di
                mov     bh,1
      @@4:      loop    @@2
                pop     bx di
                add     di,ScrX4
                dec     VC
                jne     @@1
                ret
PutCharB        endp

PutChar2        proc    near
                arg     Attr:Word,CharW:word
                local   TV:byte,VC:byte,AO:word
                uses    ds
                cld
                mov     AO,offset MonoAddTable
                mov     ax,f_Height
                mov     VC,al
                mul     bl
                add     ax,word ptr f_Font
                mov     si,ax
                imul    ax,CurY,ScrX4
                add     ax,ImageOffset
                mov     di,CurX
                shr     di,2
                add     di,ax
                mov     bx,0102h
                mov     dx,3C4h
                mov     cl,byte ptr CurX
                and     cl,3
                shl     bh,cl
                mov     es,SegA000
                mov     ds,word ptr f_Font[2]
      @@1:      lodsb
                mov     TV,al
                mov     ax,Attr
		mov     cx,bx  ; push bx
                mov     bx,AO
                add     al,cs:[bx]
                inc     bx
                mov     AO,bx
		mov     bx,cx  ; pop bx
                mov     cx,CharW
                push    di bx
      @@2:      xchg    ax,bx
                out     dx,ax
                xchg    ax,bx
                shl     TV,1
                jnc     @@Fore
                mov     es:[di],al
                jmp     @@3
      @@Fore:   mov     es:[di],ah
      @@3:      shl     bh,1
                cmp     bh,8
                jbe     @@4
                inc     di
                mov     bh,1
      @@4:      loop    @@2
                pop     bx di
                add     di,ScrX4
                dec     VC
                jne     @@1
                ret
PutChar2        endp

PutChar3        proc
                arg    Attr:word,CharW:word
                local  TV:byte,VC:byte,AO:word
                uses   ds
                cld
                mov     AO,offset MonoAddTable
                mov     ax,f_Height
                mov     VC,al
                mul     bl
                add     ax,word ptr f_Font
                mov     si,ax
                imul    ax,CurY,ScrX4
                add     ax,ImageOffset
                mov     di,CurX
                shr     di,2
                add     di,ax
                mov     bx,0102h
                mov     dx,3C4h
                mov     cl,byte ptr CurX
                and     cl,3
                shl     bh,cl
                mov     es,SegA000
                mov     ds,word ptr f_Font[2]
      @@1:      lodsb
                mov     ah,al
                mov     al,byte ptr Attr
                mov     cx,bx  ; push bx
                mov     bx,AO
                add     al,cs:[bx]
                inc     bx
                mov     AO,bx
                mov     bx,cx  ; pop bx
                mov     cx,CharW
                push    di bx
      @@2:      xchg    ax,bx
                out     dx,ax
                xchg    ax,bx
                shl     ah,1
                jnc     @@3
                mov     es:[di],al
      @@3:      shl     bh,1
                cmp     bh,8
                jbe     @@4
                inc     di
                mov     bh,1
      @@4:      loop    @@2
                pop     bx di
                add     di,ScrX4
                dec     VC
                jne     @@1
                ret
PutChar3        endp

SoftTMProc      proc    near
                mov     bh,0
                les     ax,f_Width
                add     bx,ax
                mov     al,es:[bx]
                mov     ah,0
                ret
SoftTMProc      endp

HardTMProc      proc    near
                mov     al,f_DefWidth
                mov     ah,0
                ret
HardTMProc      endp

ccSpace		equ	' '
ccLargeSpace	equ	20
ccTAB		equ	9
ccNewLine	equ	13
ccSetAttr	equ	23 ; > WORD
ccLF		equ	22 ; > BYTE

TestSpec	macro
                local	NSpace,NLargeSpace,NTAB,NNewLine,NSetAttr,NLF,NewLine
                cmp	al,ccSpace
                jne     NSpace
                mov	al,f_DefWidth
                mov	ah,0
                add	CurX,ax
                jmp	@@LP
	NSpace: cmp	al,ccLargeSpace
        	jne	NLargeSpace
                mov	al,f_DefWidth
                mov	ah,0
                shl	ax,1
                add	CurX,ax
                jmp	@@LP
   NLargeSpace:	cmp     al,ccNewLine
                jne	NNewLine
                mov	ah,0
       NewLine: mov	al,f_InterLine
                add	CurY,ax
		mov	ax,BegX
                mov	CurX,ax
        	jmp	@@LP
      NNewLine: cmp	al,ccTAB
                jne	NTAB
                mov	al,f_DefWidth
                mov	ah,0
		shl	ax,3
                add	CurX,ax
                jmp	@@LP
	NTAB:	cmp	al,ccLF
        	jne	NLF
                dec	cx
                SegES	lodsb
                mov	ah,0
                add     CurY,ax
                jmp	NewLine
	NLF:    cmp	al,ccSetAttr
      		jne	NSetAttr
      		SegES	lodsw
                sub	cx,2
                mov	TextAttr,ax
      		jmp	@@LP
      NSetAttr:
		endm

WriteXY         proc    far
                arg     x:word,y:word,ATextAttr:word,s:dword
                cld
                mov	ax,ATextAttr
                mov	TextAttr,ax
                mov     ax,x
                mov     CurX,ax
                mov     ax,y
                mov     CurY,ax
                les     si,s
                SegES   lodsb
                mov     cl,al
                mov     ch,0
                jcxz    @@Lend
     @@NextChar:SegES   lodsb

     		TestSpec

                mov     bl,al
                push    cx si es

                mov     cl,bl
                call    f_GetWidth
                push    ax
                push    TextAttr
                push    ax
                mov     bl,cl
                call    PutChar2
                pop     ax
                add     CurX,ax
                pop     es si cx
      @@LP:     loop    @@NextChar
      @@LEnd:   ret
WriteXY         endp

TranspText      proc    far
                arg     x:word,y:word,ATextAttr:byte,s:dword
                cld
                mov	al,ATextAttr
                mov	byte ptr TextAttr,al
                mov     ax,x
                mov     CurX,ax
                mov	BegX,ax
                mov     ax,y
                mov     CurY,ax
                les     si,s
                SegES   lodsb
                mov     cl,al
                mov     ch,0
                jcxz    @@Lend

    @@NextChar: SegES   lodsb

                TestSpec

	        mov     bl,al
                push    cx si es

                mov     cl,bl
                call    f_GetWidth
                push    ax
                push    word ptr TextAttr
                push    ax
                mov     bl,cl
                call    PutChar3
                pop     ax
                add     CurX,ax
                pop     es si cx
	@@LP:   loop    @@NextChar
      @@LEnd:   ret
TranspText      endp

PrintXY         proc    far
                arg     x:word,y:word,ATextAttr:word,s:dword
                cld
                mov	ax,ATextAttr
                mov	TextAttr,ax
    		mov     ax,x
                mov     CurX,ax
                mov     BegX,ax
                mov     ax,y
                mov     CurY,ax
                les     si,s
                SegES   lodsb
                mov     cl,al
                mov     ch,0
                jcxz    @@Lend

     @@NextChar:SegES   lodsb

                TestSpec

                cmp     f_MaskExist,0
                jnz     @@@

                push    cx si es

                mov	bl,al
                mov	bh,0
                xor     ax,ax
                push    word ptr cs:MonoAddTable[0]
                mov     word ptr cs:MonoAddTable[0],ax
                push    word ptr cs:MonoAddTable[2]
                mov     word ptr cs:MonoAddTable[2],ax
                push    word ptr cs:MonoAddTable[4]
                mov     word ptr cs:MonoAddTable[4],ax
                push    word ptr cs:MonoAddTable[6]
                mov     word ptr cs:MonoAddTable[6],ax

		push	bx
                push    TextAttr[1]
                push	bx
                inc	CurX
                inc	CurY
                call    PutChar3
                dec	CurY
                dec	CurX
                pop     bx

                pop     word ptr cs:MonoAddTable[6]
                pop     word ptr cs:MonoAddTable[4]
                pop     word ptr cs:MonoAddTable[2]
                pop     word ptr cs:MonoAddTable[0]

                push    bx
                push    TextAttr
                push	bx
                call    PutChar3
                pop     bx
                call    f_GetWidth
                add     CurX,ax
                pop     es si cx

                jmp     @@LP
        @@@:
		add     word ptr f_Font,256*8

		mov     bl,al
                push    cx si es

		push	bx
                push    word ptr TextAttr[1]
                call    PutCharB
                pop     bx
                push    bx
                sub     word ptr f_Font,256*8
                push    TextAttr
                call    PutChar1
                pop     bx
                call    f_GetWidth
                add     CurX,ax
                pop     es si cx
      	@@LP:	loop    @@NextChar
      @@LEnd:   ret
PrintXY         endp

TextHeight	proc	far
                arg     s:dword
                cld
                les     si,s
                SegES   lodsb
                mov     ch,0
                mov     cl,al
                xor	ax,ax
                push	CurY CurX
                mov	CurY,ax
                mov	CurX,ax
                mov	BegX,ax
                jcxz	@@end
	@@1:    SegES	lodsb
        	TestSpec
	@@LP:   loop	@@1
	@@End:  mov	ax,CurY
        	add	al,f_InterLine
                pop	CurX
                adc	ah,0
                pop	CurY
		ret
TextHeight	endp


TextWidth       proc    far
                arg     s:dword
                local	MaxW:word

                les     si,s
                SegES   lodsb
                mov     ch,0
                mov     cl,al
                xor	ax,ax
                push	CurX CurY
                mov	CurY,ax
                mov	CurX,ax
                mov	MaxW,ax
                mov	BegX,ax
                jcxz    @@end

       @@0:     mov     es,word ptr s[2]
                SegES   lodsb

                TestSpec

  		mov     bl,al
                mov     bh,0
                add     bx,word ptr f_Width
                mov     es,word ptr f_Width[2]
                mov     al,es:[bx]
                mov     ah,0
                add	CurX,ax
       @@LP:    mov	ax,CurX
                cmp	MaxW,ax
                jae	@@NMore
                mov	MaxW,ax
	@@NMore:loop    @@0
       @@end:   mov     ax,MaxW
                pop	CurY CurX
                ret
TextWidth       endp

SetMonoTextMode proc    far
                arg     Mode:byte
                cmp     Mode,0
                lea     ax,SoftTMProc
                jz      @@1
                lea     ax,HardTMProc
        @@1:    mov     f_GetWidth,ax
                ret
SetMonoTextMode endp

SetMonoAddTable proc    far
                arg     Addr:dword
                cld
                push    ds
                lds     si,Addr
                push    cs
                pop     es
                lea     di,MonoAddTable
                movsw
                movsw
                movsw
                movsw
                pop     ds
                ret
SetMonoAddTable endp


WriteText       proc    near
                arg     x:word,y:word,s:dword
                cld
                les     si,s
                SegES   lodsb
                mov     cl,al
                mov     ch,0
                jcxz    @@Lend
     @@NextChar:cmp     x,ScrX2
                jge     @@LEnd
                mov     es,word ptr s[2]
                SegES   lodsb
                sub     al,c_Ofs
                les     bx,c_XLAT
          SegES xlat
                push    cx
                push    si
                mov     ah,0
                push    x
                mov     dl,byte ptr c_HV
                mov     dh,0
                add     x,dx
                mov     bl,c_Spacing
                mov     bh,0
                add     x,bx
                push    y
                push    c_HV
                push    word ptr c_Font[2]
                mov     bx,word ptr c_Font[0]
                mul     dl
                mov     dl,byte ptr c_HV[1]
                mul     dx
                add     bx,ax
                push    bx
                push    cs
                call    c_ColorText
                pop     si
                pop     cx
                loop    @@NextChar
        @@LEnd: ret
WriteText       endp

cWriteDef       macro   Prc,Lgh
                local @@1
                push    x
                push    y
                push    word ptr s[2]
                push    word ptr s[0]
                lea     ax,Prc
                cmp     c_Mode,0
                jz      @@1
                lea     ax,Lgh
        @@1:    mov     c_ColorText,ax
                call    WriteText
                endm

cWriteXY        proc    far
                arg     x:word,y:word,s:dword
                cWriteDef PutBitMap,PutLightBitMap
                ret
cWriteXY        endp

cTranspText     proc    far
                arg     x:word,y:word,s:dword
                cWriteDef PutTranspBitMap,PutLightTranspBitMap
                ret
cTranspText     endp

GetLightColor   proc    far
                lea     bx,LightTbl
                mov     al,CurColor
         SegCS  xlat
                ret
GetLightColor   endp

MonoAddTable    db      8 dup (?)
LightTbl        db      256 dup (?)
                end

      ***  THAT'S ALL FOLKS ! ***
