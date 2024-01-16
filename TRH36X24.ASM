        .186
        jumps
CODE    segment
        assume  cs:CODE
        org     100h

Start:  jmp     Install

        org     300h

New10:  cmp     ax,83h
        jz      Proc83
        cmp     ax,93h
        jz      Proc93

Old10:  db      0EAh
Old10o  dw      ?
Old10s  dw      ?

Proc83: pushf
        cld
        push    ax cx dx di es
        push    cs
        pop     es
        mov     dx,3C7h
        mov     al,0
        out     dx,al
        mov     cx,768
        mov     dl,0C9h
        xor     di,di
        rep     insb
        pop     es di dx cx ax
        popf
        jmp     Old10

Proc93: pushf
        call    dword ptr cs:Old10o
        pushf
        cld
        push    ax cx dx si ds
        push    cs
        pop     ds
        mov     dx,3C8h
        mov     al,0
        out     dx,al
        mov     cx,768
        inc     dx
        xor     si,si
        rep     outsb
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
        mov     dx,3ceh
        mov     ax,4005h
        out     dx,ax
        mov     ax,0506h
        out     dx,ax
        mov     dx,3d4h
        lea     si,ModeSetup
        mov     cx,18
        rep     outsw
        pop     ds si dx cx ax
        popf
        iret
ModeSetup dw 0C11h,6b00h,5901h,5a02h,8e03h,5e04h,8a05h,0D06h,3e07h
          dw 4109h,0ea10h,08c11h,0df12h,2d13h,14h,0e715h,616h,0e317h
EndTSR:

Install:
        mov     es,word ptr ds:[2Ch]
        mov     ah,49h
        int     21h
        mov     ax,3510h
        int     21h
        mov     Old10o,bx
        mov     Old10s,es
        lea     dx,New10
        mov     ax,2510h
        int     21h
        lea     dx,EndTSR
        int     27h

CODE    ends
        end     Start