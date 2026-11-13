; ---------------------------------------------------------------------------
; PATCH.COM - minimal DOS patcher for Carmageddon (CARMAV.EXE -> CARMAVR.EXE)
;
; Replaces four "call" instructions (5 bytes each) with NOPs:
;   0x66BDA, 0x66C02, 0x7391E, 0x73928   (file offsets)
;
; Before touching a site it checks that the first byte is still E8h (CALL),
; so an already patched or foreign executable is rejected instead of damaged.
;
; usage:  PATCH.COM <file>
; ---------------------------------------------------------------------------
        bits 16
        org 100h

start:
        mov     si, 80h                 ; PSP command tail
        mov     cl, [si]
        xor     ch, ch
        inc     si
        or      cx, cx
        jz      usage
.skipsp:
        cmp     byte [si], ' '
        jne     got
        inc     si
        dec     cx
        jz      usage
        jmp     .skipsp
got:
        mov     bx, si                  ; NUL-terminate the file name
        add     bx, cx
        mov     byte [bx], 0

        mov     dx, si
        mov     ax, 3D02h               ; open, read/write
        int     21h
        jc      openfail
        mov     [handle], ax

        mov     si, table
.loop:
        lodsw
        mov     [seeklo], ax
        lodsw
        cmp     ax, 0FFFFh
        je      fin
        mov     [seekhi], ax

        mov     bx, [handle]            ; seek to the site
        mov     ax, 4200h
        mov     dx, [seeklo]
        mov     cx, [seekhi]
        int     21h
        jc      iofail

        mov     bx, [handle]            ; read one byte and verify it is CALL
        mov     ah, 3Fh
        mov     cx, 1
        mov     dx, chkbuf
        int     21h
        jc      iofail
        cmp     byte [chkbuf], 0E8h
        jne     sigfail

        mov     bx, [handle]            ; seek back
        mov     ax, 4200h
        mov     dx, [seeklo]
        mov     cx, [seekhi]
        int     21h
        jc      iofail

        mov     bx, [handle]            ; write five NOPs
        mov     ah, 40h
        mov     cx, 5
        mov     dx, nops
        int     21h
        jc      iofail
        jmp     .loop

fin:
        mov     bx, [handle]
        mov     ah, 3Eh                 ; close
        int     21h
        mov     dx, msgok
        call    print
        mov     ax, 4C00h
        int     21h

openfail:
        mov     dx, msgopen
        jmp     fail
sigfail:
        mov     dx, msgsig
        jmp     fail
iofail:
        mov     dx, msgio
fail:
        call    print
        mov     ax, 4C01h
        int     21h

usage:
        mov     dx, msguse
        call    print
        mov     ax, 4C02h
        int     21h

print:
        mov     ah, 9
        int     21h
        ret

; --- data ------------------------------------------------------------------
msgok   db 'OK: 4 patches applied, 20 bytes changed.', 13, 10, '$'
msgopen db 'ERROR: cannot open file for read/write.', 13, 10, '$'
msgsig db 'ERROR: unexpected byte at a patch site.', 13, 10
        db '       (already patched, or not CARMAV.EXE).', 13, 10, '$'
msgio   db 'ERROR: seek/read/write failed.', 13, 10, '$'
msguse  db 'Usage: PATCH.COM <file>', 13, 10, '$'

handle  dw 0
seeklo  dw 0
seekhi  dw 0
chkbuf  db 0
nops    db 90h, 90h, 90h, 90h, 90h

table   dw 0x6BDA, 0x0006          ; 0x066BDA
        dw 0x6C02, 0x0006          ; 0x066C02
        dw 0x391E, 0x0007          ; 0x07391E
        dw 0x3928, 0x0007          ; 0x073928
        dw 0, 0xFFFF               ; terminator
