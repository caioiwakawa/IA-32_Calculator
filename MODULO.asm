global mod_int

extern bit_size

section .text

; ========================================================
; FUNÇÃO: mod_int
; Descrição: Calcula o modulo de dois inteiros assinados (16 ou 32 bits, conforme a
; variável global [bit_size]) e grava o QUOCIENTE no destino indicado.
; Parâmetros:
;   [ebp+8]  -> Ponteiro para o primeiro número (Dividendo)[cite: 2].
;   [ebp+12] -> Ponteiro para o segundo número (Divisor)[cite: 2].
;   [ebp+16] -> Ponteiro para onde gravar o resultado[cite: 2].
;               Deve ter o mesmo tamanho de num1/num2 (word ou dword,
;               conforme [bit_size])[cite: 2].
; Retorno: Nenhum (o resultado é gravado via ponteiro, não em EAX)[cite: 2].
; ========================================================
mod_int:
    
    push ebp
    mov ebp, esp

    ; Verifica o tamanho dos bits baseado na variável global
    cmp byte [bit_size], '0'    
    je .mod_int16

    cmp byte [bit_size], '1'    
    je .mod_int32

.mod_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX, ECX, EDX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            
    mov eax, [ebx]              
    
    cdq                         
    mov ebx, [ebp+12]           
    mov ecx, [ebx]              
    idiv ecx                    
    
    mov ebx, [ebp+16]           
    mov [ebx], edx              
    jmp .end_mod                

.mod_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX, CX, DX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            
    mov ax, [ebx]               
    
    cwd                         
    mov ebx, [ebp+12]           
    mov cx, [ebx]               
    idiv cx                     
    
    mov ebx, [ebp+16]           
    mov [ebx], dx               

.end_mod:
    leave                       
    ret                         