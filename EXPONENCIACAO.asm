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
    cmp byte [bit_size], '0'    ; Checa se é 16 bits[cite: 2]
    je .exp_int16

    cmp byte [bit_size], '1'    ; Checa se é 32 bits[cite: 2]
    je .exp_int32

.exp_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX, EBX, ECX, EDX)
    ; ----------------------------------------------------

    mov eax, 1                  ; EAX = Resultado

    mov ebx, [ebp+12]           ; EBX = Ponteiro do Número 2 (expoente) [cite: 2]
    mov ecx, [ebx]              ; ECX = Valor do Número 2

    mov ebx, [ebp+8]            ; EBX = Ponteiro do Número 1 (base) [cite: 2]
    mov ebx, [ebx]              ; EBX = Valor do Número 1 (32 bits)

.exp_int32_loop:
    cmp ecx, 0
    je .end_int32_loop

    imul ebx                    ; Multiplica EDX:EAX por EBX. Resposta -> EAX, Base -> EDX.
    jo .overflow                ; Verifica se ocorreu overflow na flag OF

    dec ecx
    jmp .exp_int32_loop
    
.end_int32_loop:
    mov ebx, [ebp+16]           ; EBX = Ponteiro do Resultado[cite: 2]
    mov [ebx], eax              ; Salva a resposta de 32 bits na memória[cite: 2]
    jmp .end_exp                ; Pula para o final da função

.exp_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX, BX, CX, DX)
    ; ----------------------------------------------------
    
    mov ax, 1                   ; AX = Resultado

    mov ebx, [ebp+12]           ; EBX = Ponteiro do Número 2 [cite: 2]
    mov cx, [ebx]               ; CX = Valor do Número 2

    mov ebx, [ebp+8]            ; EBX = Ponteiro do Número 1 [cite: 2]
    mov bx, [ebx]               ; AX = Valor do Número 1 (16 bits)

.exp_int16_loop:
    cmp ecx, 0
    je .end_int16_loop

    imul cx                     ; Multiplica DX:AX por CX. NUM1 -> AX, NUM2 -> DX.
    jo .overflow                ; Verifica se ocorreu overflow na flag OF

    dec cx
    jmp .exp_int16_loop
  
.end_int16_loop:
    mov ebx, [ebp+16]           ; EBX = Ponteiro do Resultado[cite: 2]
    mov [ebx], ax               ; Salva a resposta de 16 bits na memória[cite: 2]
    jmp .end_exp

.overflow:
    mov ebx, [ebp+20]           ; ocorreu overflow
    mov dword [ebx], 1          ; muda flag de overflow para 1

.end_exp:
    pop ebx
    leave                       ; Restaura o frame da pilha[cite: 2]
    ret                         ; Retorna à rotina chamadora[cite: 2]