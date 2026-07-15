global exp_int

extern bit_size

section .text

; ========================================================
;  FUNÇÃO: exp_int
;  Descrição: Calcula a exponenciação de um inteiro assinado por outro inteiro assinado
;  Parâmetros:
;   [ebp+8]  -> Ponteiro para o primeiro número (Base).
;   [ebp+12] -> Ponteiro para o segundo número (Expoente).
;   [ebp+16] -> Ponteiro para onde gravar o resultado.
;               Deve ter o mesmo tamanho de num1/num2 (word ou dword,
;               conforme [bit_size]).
;   [ebp+20] -> Ponteiro para a flag de overflow.
;               Deve receber 1 caso ocorra overflow durante a
;               exponenciação e permanecer 0 caso contrário.    
;  Retorno: Nenhum (o resultado é gravado via ponteiro, não em EAX)[cite: 2].
; ========================================================

exp_int:

    push ebp
    mov ebp, esp
    push ebx

    ; Verifica o tamanho dos bits baseado na variável global
    cmp byte [bit_size], '0'   
    je .exp_int16

    cmp byte [bit_size], '1'   
    je .exp_int32

.exp_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX, EBX, ECX, EDX)
    ; ----------------------------------------------------

    mov eax, 1                  

    mov ebx, [ebp+12]           
    mov ecx, [ebx]             

    mov ebx, [ebp+8]          
    mov ebx, [ebx]            

.exp_int32_loop:
    cmp ecx, 0
    je .end_int32_loop

    imul ebx                  
    jo .overflow              

    dec ecx
    jmp .exp_int32_loop
    
.end_int32_loop:
    mov ebx, [ebp+16]          
    mov [ebx], eax             
    jmp .end_exp              

.exp_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX, BX, CX, DX)
    ; ----------------------------------------------------
    
    mov ax, 1                 

    mov ebx, [ebp+12]          
    mov cx, [ebx]             

    mov ebx, [ebp+8]            
    mov bx, [ebx]             

.exp_int16_loop:
    cmp ecx, 0
    je .end_int16_loop

    imul cx                    
    jo .overflow               

    dec cx
    jmp .exp_int16_loop
  
.end_int16_loop:
    mov ebx, [ebp+16]         
    mov [ebx], ax               
    jmp .end_exp

.overflow:
    mov ebx, [ebp+20]         
    mov dword [ebx], 1        

.end_exp:
    pop ebx
    leave                      
    ret                        