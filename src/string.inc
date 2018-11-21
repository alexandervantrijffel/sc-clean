; ##########################################################################

StrLen PROTO :DWORD
InString  PROTO STDCALL :DWORD,:DWORD,:DWORD 

    .code

; ##########################################################################



; ##########################################################################

StrLen proc item:DWORD

  ; -------------------------------------------------------------
  ; This procedure has been adapted from an algorithm written by
  ; Agner Fog. It has the unusual characteristic of reading up to
  ; three bytes past the end of the buffer as it uses DWORD size
  ; reads. It is measurably faster than a classic byte scanner on
  ; large linear reads and has its place where linear read speeds
  ; are important.
  ; -------------------------------------------------------------

    push    ebx
    mov     eax,item               ; get pointer to string
    lea     edx,[eax+3]            ; pointer+3 used in the end
  @@:     
    mov     ebx,[eax]              ; read first 4 bytes
    add     eax,4                  ; increment pointer
    lea     ecx,[ebx-01010101h]    ; subtract 1 from each byte
    not     ebx                    ; invert all bytes
    and     ecx,ebx                ; and these two
    and     ecx,80808080h    
    jz      @B                     ; no zero bytes, continue loop
    test    ecx,00008080h          ; test first two bytes
    jnz     @F
    shr     ecx,16                 ; not in the first 2 bytes
    add     eax,2
  @@:
    shl     cl,1                   ; use carry flag to avoid branch
    sbb     eax,edx                ; compute length
    pop     ebx

    ret

StrLen endp


;***********************************************************************************
;										InString
;***********************************************************************************

InString proc startpos:DWORD,lpSource:DWORD,lpPattern:DWORD 
  ; ------------------------------------------------------------------ 
  ; InString searches for a substring in a larger string and if it is 
  ; found, it returns its position in eax.   ; 
  ; It uses a one (1) based character index (1st character is 1, 
  ; 2nd is 2 etc...) for both the "StartPos" parameter and the returned 
  ; character position.  ;  ; Return Values. 
  ; If the function succeeds, it returns the 1 based index of the start 
  ; of the substring.  ;  0 = no match found 
  ; -1 = substring same length or longer than main string 
  ; -2 = "StartPos" parameter out of range (less than 1 or longer than 
  ; main string) 
  ; ------------------------------------------------------------------ 
    LOCAL pLen:DWORD 
    push ebx 
    push esi 
    push edi 

    mov esi, lpSource 
    mov edi, lpPattern 

    invoke StrLen,esi 
    mov ebx, eax           ; ebx = source length 
    invoke StrLen,edi 
    mov ecx,startpos       ;ecx = startpos 
    add edi,eax            ;edi=end of pattern 
    neg eax                ;edi+eax = start of pattern 
    mov pLen, eax           ; - (pattern length) 
    dec ecx           ;ecx = startpos -1 
    js @errm2                  ;startpos <= 0? yes - goto error -2 
    add ebx,eax           ;ebx= sLen - pLen 
    js @errm1           ; if sLen < pLen goto error -1 
    lea esi,[esi][ebx][1]    ; esi= address of part wich is < pLen 
    not ebx           ;ebx = -(ebx+1)= - ((sLen - pLen)+1) 
    add ecx,ebx           ; ecx = startpos -1 ebx = - ((sLen - pLen)+1)               ;if ecx >=  (sLen - pLen)+1 then 
    jns @errm2           ;ecx - ((sLen-pLen)+1) >= 0 and SF =0 
    mov al,[edi][eax]  ;first byte 
    jmp Loop_Start 
;@@@@@@@@@ 

Pre_Loop: 
   pop ecx        ;restore ECX 
   inc  ecx        ;start on next byte 
Loop_Start: 
   cmp al,[esi+ecx] 
   je Pre_Sub 
   inc ecx 
   jnz Loop_Start 
   xor eax,eax 
   jmp isOut 
Pre_Sub: 
   push ecx    ;preserve ECX 
   mov edx,pLen 
Sub_Loop: 
   inc ecx 
   inc edx ;don't check fist byte 
   mov ah,[esi+ecx] 
   je found ;edi+0 = pattern end 
   cmp ah,[edi][edx] 
   je Sub_Loop 
   jmp Pre_Loop    
    
; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 
found: 
    pop eax                  
    sub eax, ebx ;sub neg value = add positive 
    inc eax 
    
  isOut: 
    pop edi 
    pop esi 
    pop ebx 
    ret 
@errm2: 
   mov eax,-2 
   jmp isOut 
@errm1: 
   mov eax,-1 
   jmp isOut 
InString endp 


; ##########################################################################
