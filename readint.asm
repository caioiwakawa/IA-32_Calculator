global ask_nums

extern print
extern bit_size

section .data
    ask_1 db  "Digite o primeiro número: "
    ask_1_len equ $ - ask_1
    ask_2 db  "Digite o segundo número: "
    ask_2_len equ $ - ask_2
section .text

; ========================================================
; FUNÇÃO: ask_nums
; Descrição: Imprime os dois prompts ("Digite o primeiro/segundo
; número") e lê os dois valores digitados pelo usuário, escrevendo-os
; diretamente nos endereços fornecidos pelo chamador. O tamanho lido
; (16 ou 32 bits) depende da variável global [bit_size].
; Parâmetros:
;   [ebp+8]  -> Ponteiro para onde gravar o primeiro número.
;   [ebp+12] -> Ponteiro para onde gravar o segundo número.
;               (Cabe ao chamador reservar espaço do tamanho certo:
;               2 bytes se for usar modo 16 bits, 4 bytes se 32 bits.)
; Retorno: Nenhum (os resultados são gravados via ponteiro, não em EAX).
; ========================================================
ask_nums:

    push ebp
    mov ebp, esp
    ; [ebp+8]  = pointer to store num1
    ; [ebp+12] = pointer to store num2

    push ask_1_len
    push ask_1
    call print
    add esp, 8

    cmp byte [bit_size], '0'
    je .read_first_16

    push dword [ebp+8]
    call read_int32
    add esp, 4
    jmp .after_first

.read_first_16:

    push dword [ebp+8]
    call read_int16
    add esp, 4

.after_first:

    push ask_2_len
    push ask_2
    call print
    add esp, 8

    cmp byte [bit_size], '0'
    je .read_second_16

    push dword [ebp+12]
    call read_int32
    add esp, 4
    jmp .after_second

.read_second_16:

    push dword [ebp+12]
    call read_int16
    add esp, 4

.after_second:

    leave
    ret

; ========================================================
; FUNÇÃO: read_int16
; Descrição: Lê do stdin e converte para inteiro assinado de 16-bits.
; Parâmetros:
;   [ebp+8] -> Ponteiro para onde gravar o resultado (word, 16 bits).
; Retorno: Nenhum (o resultado é salvo via ponteiro, não em EAX).
; ========================================================
read_int16:
    
    push ebp
    mov ebp, esp

    ; Variáveis Locais da Função:
    ; [ebp-2]  = Acumulador (16 bits)
    ; [ebp-4]  = Flag de Negativo (16 bits)
    ; [ebp-54] = Buffer de leitura (50 bytes)
    sub esp, 54
    
    mov word [ebp-2], 0         ; Inicializa variáveis locais em 0
    mov word [ebp-4], 0
    
    ; 1. Leitura (sys_read)
    mov eax, 3                  
    mov ebx, 0                  
    mov ecx, ebp
    sub ecx, 54                 ; Ponteiro para o buffer local [ebp-54]
    mov edx, 50                 
    int 80h                     ; Executa sys_read. EAX recebe total de bytes.
    
    ; Ponteiro de leitura no buffer
    mov ebx, ebp
    sub ebx, 54
    
    ; 2. Checar Sinal Negativo '-' (ASCII 45)
    mov cx, 0                   ; Zera CX por completo para evitar lixo
    mov cl, [ebx]               
    cmp cl, 45                  ; CMP: Atualiza as FLAGS[cite: 1]
    jne .loop_16                ; Pula se não igual (JNE)[cite: 1]
    mov word [ebp-4], 1         ; Marca flag de negativo
    inc ebx                     ; op1 <- op1 + 1 (Avança ponteiro)[cite: 1]
    dec eax                     ; op1 <- op1 - 1 (Diminui contagem de bytes)[cite: 1]

.loop_16:
    cmp eax, 0
    je .end_16                  ; Se EAX == 0, encerra (JE/JZ)[cite: 1]
    
    mov cx, 0
    mov cl, [ebx]
    cmp cl, 10                  ; Checa 'Enter' (\n)
    je .end_16
    
    sub cl, 48                  ; ASCII para numérico (0-9)
    
    ; Matemática de 16-bits (Acessando o registrador AX)
    push eax                    ; Protege EAX (que controla os bytes restantes)
    mov ax, [ebp-2]             ; Traz o valor atual
    mov dx, 10
    mul dx                      ; MUL OP1: Multiplicação sem sinal (AX * DX), resultado em DX.AX[cite: 1]
    add ax, cx                  ; Soma o novo dígito ao total
    mov [ebp-2], ax             ; Salva no acumulador local
    pop eax                     ; Restaura EAX
    
    inc ebx
    dec eax
    jmp .loop_16                ; Pulo incondicional[cite: 1]

.end_16:
    mov ax, [ebp-2]             ; Pega o valor calculado
    cmp word [ebp-4], 1         ; Checa a flag
    jne .store_16
    neg ax                      ; NEG OP1: Recebe negação em complemento de 2 (aplica o sinal)[cite: 1]

.store_16:
    mov ebx, [ebp+8]            ; Carrega o ponteiro da variável local do Caller
    mov [ebx], ax               ; Escreve o resultado de 16-bits na memória
    
    leave                       ; Restaura frame da pilha[cite: 1]
    ret                         ; Pula retirando endereço de retorno[cite: 1]


; ========================================================
; FUNÇÃO: read_int32
; Descrição: Lê do stdin e converte para inteiro assinado de 32-bits.
; Parâmetros:
;   [ebp+8] -> Ponteiro para onde gravar o resultado (dword, 32 bits).
; Retorno: Nenhum (o resultado é salvo via ponteiro, não em EAX).
; ========================================================
read_int32:
    
    push ebp
    mov ebp, esp

    ; Variáveis Locais da Função:
    ; [ebp-4]  = Acumulador (32 bits)
    ; [ebp-8]  = Flag de Negativo (32 bits)
    ; [ebp-58] = Buffer de leitura (50 bytes)
    sub esp, 58
    
    mov dword [ebp-4], 0
    mov dword [ebp-8], 0
    
    ; 1. Leitura (sys_read)
    mov eax, 3
    mov ebx, 0
    mov ecx, ebp
    sub ecx, 58
    mov edx, 50
    int 80h                     
    
    mov ebx, ebp
    sub ebx, 58                 
    
    ; 2. Checar Sinal Negativo
    mov ecx, 0
    mov cl, [ebx]
    cmp cl, 45                  
    jne .loop_32
    mov dword [ebp-8], 1        
    inc ebx                     
    dec eax                     

.loop_32:
    cmp eax, 0
    je .end_32
    
    mov ecx, 0
    mov cl, [ebx]
    cmp cl, 10                  
    je .end_32
    
    sub cl, 48                  
    
    ; Matemática de 32-bits (Acessando o registrador EAX)
    push eax                    
    mov eax, [ebp-4]
    mov edx, 10
    mul edx                     ; MUL OP1: Multiplicação sem sinal (EAX * EDX), resultado em EDX.EAX[cite: 1]
    add eax, ecx                
    mov [ebp-4], eax
    pop eax
    
    inc ebx
    dec eax
    jmp .loop_32

.end_32:
    mov eax, [ebp-4]
    cmp dword [ebp-8], 1
    jne .store_32
    neg eax                     ; Op1 recebe a negação em complemento de 2[cite: 1]

.store_32:
    mov ebx, [ebp+8]            ; Pega o ponteiro do Caller
    mov [ebx], eax              ; Salva resultado de 32-bits na memória
    
    leave                       
    ret