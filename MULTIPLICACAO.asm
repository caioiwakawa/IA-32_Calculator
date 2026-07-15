global mul_int

extern bit_size

section .text

; ========================================================
;  FUNÇÃO: mul_int
;  Descrição: Calcula a multiplicação de um inteiro assinado por outro inteiro assinado
;  Parâmetros:
;   [ebp+8]  -> Ponteiro para o primeiro número.
;   [ebp+12] -> Ponteiro para o segundo número.
;   [ebp+16] -> Ponteiro para onde gravar o resultado.
;               Deve ter o mesmo tamanho de num1/num2 (word ou dword,
;               conforme [bit_size]).
;   [ebp+20] -> Ponteiro para a flag de overflow.
;               Deve receber 1 caso ocorra overflow durante a
;               multiplicação e permanecer 0 caso contrário.    
;  Retorno: Nenhum (o resultado é gravado via ponteiro, não em EAX)[cite: 2].
; ========================================================

mul_int:

    push ebp
    mov ebp, esp
    push ebx

    ; Verifica o tamanho dos bits baseado na variável global
    cmp byte [bit_size], '0'    
    je .mul_int16

    cmp byte [bit_size], '1'    
    je .mul_int32

.mul_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX, ECX, EDX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            
    mov eax, [ebx]              
    
    mov ebx, [ebp+12]           
    mov ecx, [ebx]              
    imul ecx                    
    jo .overflow                
    
    mov ebx, [ebp+16]           
    mov [ebx], eax              
    jmp .end_mul                

.mul_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX, CX, DX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            
    mov ax, [ebx]               
    
    mov ebx, [ebp+12]           
    mov cx, [ebx]               
    imul cx                     
    jo .overflow                
    
    mov ebx, [ebp+16]          
    mov [ebx], ax              
    jmp .end_mul

.overflow:
    mov ebx, [ebp+20]           
    mov dword [ebx], 1          

.end_mul:
    pop ebx
    leave                       
    ret                         

    