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
    cmp byte [bit_size], '0'    ; Checa se é 16 bits[cite: 2]
    je .mod_int16

    cmp byte [bit_size], '1'    ; Checa se é 32 bits[cite: 2]
    je .mod_int32

.mod_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX, ECX, EDX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            ; EBX = Ponteiro do Número 1 (Dividendo)[cite: 2]
    mov eax, [ebx]              ; EAX = Valor do Número 1 (32 bits)
    
    cdq                         ; Estende o sinal de EAX para EDX:EAX (Prepara para IDIV)
    
    mov ebx, [ebp+12]           ; EBX = Ponteiro do Número 2 (Divisor)[cite: 2]
    mov ecx, [ebx]              ; ECX = Valor do Número 2
    idiv ecx                    ; Divide EDX:EAX por ECX. Quociente -> EAX, Resto -> EDX.
    
    mov ebx, [ebp+16]           ; EBX = Ponteiro do Resultado[cite: 2]
    mov [ebx], edx              ; Salva o QUOCIENTE de 32 bits na memória[cite: 2]
    jmp .end_mod                ; Pula para o final da função

.mod_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX, CX, DX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            ; EBX = Ponteiro do Número 1 (Dividendo)[cite: 2]
    mov ax, [ebx]               ; AX = Valor do Número 1 (16 bits)
    
    cwd                         ; Estende o sinal de AX para DX:AX (Prepara para IDIV)
    
    mov ebx, [ebp+12]           ; EBX = Ponteiro do Número 2 (Divisor)[cite: 2]
    mov cx, [ebx]               ; CX = Valor do Número 2
    idiv cx                     ; Divide DX:AX por CX. Quociente -> AX, Resto -> DX.
    
    mov ebx, [ebp+16]           ; EBX = Ponteiro do Resultado[cite: 2]
    mov [ebx], dx               ; Salva o QUOCIENTE de 16 bits na memória[cite: 2]

.end_mod:
    leave                       ; Restaura o frame da pilha[cite: 2]
    ret                         ; Retorna à rotina chamadora[cite: 2]