global bit_size

extern add_int
extern sub_int
extern div_int
extern mul_int
extern mod_int
extern exp_int

section .data
    welcome         db  "Bem-vindo. Digite seu nome: "
    welcome_len     equ $ - welcome
    hello_1         db  "Ola, "
    hello_1_len     equ $ - hello_1
    hello_2         db  ", bem-vindo ao programa de CALC IA-32", 0xA
    hello_2_len     equ $ - hello_2
    question        db  "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32): "
    question_len    equ $ - question
    menu            db "ESCOLHA UMA OPÇÃO:", 0xA
                    db "- 1: SOMA", 0xA
                    db "- 2: SUBTRACAO", 0xA
                    db "- 3: MULTIPLICACAO", 0xA
                    db "- 4: DIVISAO", 0xA
                    db "- 5: EXPONENCIACAO", 0xA
                    db "- 6: MOD", 0xA
                    db "- 7: SAIR", 0xA
    menu_len        equ $ - menu
    ask_1 db  "Digite o primeiro número: "
    ask_1_len equ $ - ask_1
    ask_2 db  "Digite o segundo número: "
    ask_2_len equ $ - ask_2
    newline         db  0xA
    newline_len     equ $ - newline
    msgOverflow     db  "OCORREU OVERFLOW"
    msgOverflow_len equ $ - msgOverflow
section .bss
    name        resb 50
    name_len    resd 1
    bit_size    resb 2
    operation   resb 2
    result_num  resd 1
section .text
global _start

; ========================================================
; PONTO DE ENTRADA: _start
; Fluxo: pede o nome do usuário, pede se vai trabalhar com 16 ou 32
; bits, e entra no loop do menu, repetindo até a opção "7: SAIR".
; ========================================================
_start:

    ;print(welcome)
    push welcome_len
    push welcome
    call print
    add esp, 8
    
    ;read(name)
    push 50
    push name
    call read_str
    dec eax
    mov [name_len], eax
    add esp, 8

    ;print(hello)
    push hello_1_len
    push hello_1
    call print
    add esp, 8

    push dword [name_len]
    push name
    call print
    add esp, 8

    push hello_2_len
    push hello_2
    call print
    add esp, 8

    ;print(question)
    push question_len
    push question
    call print
    add esp, 8

    ;read(bit_size)
    push 2
    push bit_size
    call read_str
    add esp, 8

    jmp skip_enter

menu_loop:

    ;read(enter)
    push 1
    push result_num
    call read_str
    add esp, 8

skip_enter:

    ;print(menu)
    push menu_len
    push menu
    call print
    add esp, 8

    ;read(operation)
    push 2
    push operation
    call read_char
    add esp, 8

    ;menu[operation]
    mov al, [operation]

    cmp al, '1'
    je menu_add

    cmp al, '2'
    je menu_sub

    cmp al, '3'
    je menu_mul

    cmp al, '4'
    je menu_div

    cmp al, '5'
    je menu_exp

    cmp al, '6'
    je menu_mod

    cmp al, '7'
    je exit

    jmp menu_loop

; ========================================================
; ROTINA: exit
; Descrição: Encerra o processo (sys_exit) com código de saída 0.
; ========================================================
exit:
    mov eax, 1
    mov ebx, 0
    int 80h

; ========================================================
; FUNÇÃO: print
; Descrição: Escreve uma sequência de bytes em stdout (sys_write).
; Parâmetros:
;   [ebp+8]  -> Ponteiro para o buffer/string a imprimir.
;   [ebp+12] -> Quantidade de bytes a imprimir.
; Retorno: Nenhum (EAX fica com o valor de retorno da syscall,
;          não é usado pelo chamador).
; ========================================================
print:
 
    push ebp
    mov ebp, esp
    
    mov eax, 4
    mov ebx, 1
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    int 80h
    
    leave
    ret

; ========================================================
; FUNÇÃO: read_str
; Descrição: Lê até N bytes de stdin (sys_read) e grava crus no buffer,
; sem qualquer conversão ou processamento.
; Parâmetros:
;   [ebp+8]  -> Ponteiro para o buffer de destino.
;   [ebp+12] -> Tamanho máximo do buffer (quantos bytes ler no máximo).
; Retorno: EAX = quantidade de bytes efetivamente lidos (inclui o '\n'
;          se ele coube dentro do limite pedido).
; ========================================================
read_str:

    push ebp
    mov ebp, esp
    
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    int 80h
    
    leave
    ret

; ========================================================
; FUNÇÃO: read_char
; Descrição: Idêntica a read_str (chama sys_read cru); existe como
; função separada apenas para deixar claro, no local da chamada, que a
; intenção é ler um caractere/opção curta (ex.: opção de menu).
; Parâmetros:
;   [ebp+8]  -> Ponteiro para o buffer de destino.
;   [ebp+12] -> Tamanho máximo do buffer. Deve incluir espaço para o
;               '\n' que o usuário digita ao pressionar Enter, senão
;               esse '\n' fica pendente no stdin e é consumido pela
;               PRÓXIMA leitura (bug clássico de leitura de 1 byte).
; Retorno: EAX = quantidade de bytes efetivamente lidos.
; ========================================================
read_char:

    push ebp
    mov ebp, esp

    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    int 80h

    leave
    ret

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

; ========================================================
; FUNÇÃO: print_num
; Descrição: Converte um inteiro assinado (16 ou 32 bits, conforme
; [bit_size]) para texto decimal e imprime, seguido de uma quebra de
; linha. Suporta números negativos (imprime o sinal '-').
; Parâmetros:
;   [ebp+8] -> Ponteiro para o número a imprimir. Se [bit_size]=='0',
;              é lido como word (16 bits, sign-extend); caso contrário
;              é lido como dword (32 bits).
; Retorno: Nenhum. Apenas escreve o texto em stdout.
; ========================================================
print_num:

    push ebp
    mov ebp, esp
    sub esp, 32

    mov ecx, [ebp+8]
    cmp byte [bit_size], '0'
    je .read_word
    mov eax, [ecx]              ; modo 32 bits: carrega o dword direto
    jmp .begin

.read_word:
    movsx eax, word [ecx]       ; modo 16 bits: carrega a word e estende
                                 ; o sinal para 32 bits (preserva negativos)

.begin:
    ; Converte o valor absoluto em EAX para dígitos ASCII, empilhando-os
    ; do menos significativo para o mais significativo (algoritmo
    ; clássico de divisões sucessivas por 10).
    ; ECX = contador de caracteres a imprimir (dígitos + sinal, se houver)
    ; EDI = flag: 1 se o número era negativo, 0 caso contrário
    mov ebx, 10
    xor ecx, ecx
    xor edi, edi
    cmp eax, 0
    jge .loop
    neg eax
    mov edi, 1

.loop:
    xor edx, edx
    div ebx                     ; EAX = EAX / 10, EDX = EAX % 10
    add dl, 48                  ; converte o resto para dígito ASCII
    push edx                    ; empilha o dígito (LIFO: sai na ordem inversa)
    inc ecx
    cmp eax, 0
    jne .loop

    cmp edi, 1
    jne .copy_to_buffer
    push 45                     ; empilha o '-' por ÚLTIMO, para que ele
    inc ecx                     ; seja o PRIMEIRO a ser retirado (pop) abaixo

.copy_to_buffer:
    ; Retira os caracteres da pilha (ordem: sinal, depois dígitos do mais
    ; para o menos significativo) e monta a string final no buffer local
    ; [ebp-32].
    mov esi, ebp
    sub esi, 32
    mov edx, ecx

.copy_loop:
    cmp edx, 0
    je .print_buffer
    pop eax
    mov [esi], al
    inc esi
    dec edx
    jmp .copy_loop

.print_buffer:
    ; ECX ainda guarda a contagem original de caracteres (EDX foi
    ; zerado no .copy_loop acima, por isso é recalculado aqui a partir
    ; de ECX em vez de reaproveitar EDX).
    mov edx, ecx
    mov eax, ebp
    sub eax, 32
    push edx
    push eax
    call print
    add esp, 8

    push newline_len
    push newline
    call print
    add esp, 8

    leave
    ret

; ========================================================
; ROTINA: menu_add
; Descrição: Trata a opção "SOMA" (e, atualmente, também 2-6, já que o
; menu ainda não tem rotinas próprias de subtração/multiplicação/etc.).
; Pede dois números ao usuário, soma-os e imprime o resultado.
; Não é uma função "call/ret" — é acessada via jmp/je a partir de
; menu_loop e retorna a ele também via jmp, por isso usa seu próprio
; frame de pilha (push ebp / mov ebp,esp) só para ter onde guardar
; num1 e num2, mas não usa "ret" no final.
; Parâmetros: nenhum (lê de stdin, usa a variável global [bit_size]).
; Retorno: nenhum (imprime o resultado; resultado também fica
;          disponível em [result_num]).
; ========================================================
menu_add:

    push ebp
    mov ebp, esp
    sub esp, 8              ; [ebp-4] = num1, [ebp-8] = num2

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    ; add_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1+num2
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside add_int)
    call add_int
    add esp, 12

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_sub:

    push ebp
    mov ebp, esp
    sub esp, 8              ; [ebp-4] = num1, [ebp-8] = num2

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    ; sub_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1-num2
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside sub_int)
    call sub_int
    add esp, 12

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_mul:

    push ebp
    mov ebp, esp
    sub esp, 12              ; [ebp-4] = num1, [ebp-8] = num2, [ebp-12] = overflow

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    mov dword [ebp-12], 0 ; overflow = 0

    ; mul_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1*num2
    mov eax, ebp
    sub eax, 12
    push eax                ; ptr to overflow
   
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside mul_int)
    call mul_int
    add esp, 16

    cmp dword [ebp-12], 1
    je overflow

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_div:

    push ebp
    mov ebp, esp
    sub esp, 8              ; [ebp-4] = num1, [ebp-8] = num2

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    ; div_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1/num2
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside div_int)
    call div_int
    add esp, 12

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_mod:

    push ebp
    mov ebp, esp
    sub esp, 8              ; [ebp-4] = num1, [ebp-8] = num2

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    ; mod_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1%num2
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside mod_int)
    call mod_int
    add esp, 12

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_exp:

    push ebp
    mov ebp, esp
    sub esp, 12              ; [ebp-4] = num1, [ebp-8] = num2, [ebp-12] = overflow

    ; ask_nums(ptr_num1, ptr_num2) -> preenche [ebp-4] e [ebp-8]
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside ask_nums)
    call ask_nums
    add esp, 8

    mov dword [ebp-12], 0 ; overflow = 0

    ; exp_int(ptr_num1, ptr_num2, ptr_result) -> [result_num] = num1**num2
    mov eax, ebp
    sub eax, 12
    push eax                ; ptr to overflow
   
    push dword result_num
    mov eax, ebp
    sub eax, 8
    push eax                ; ptr to num2
    mov eax, ebp
    sub eax, 4
    push eax                ; ptr to num1 (ends up at ebp+8 inside exp_int)
    call exp_int
    add esp, 16

    cmp dword [ebp-12], 1
    je overflow

    ; print_num(ptr_result) -> imprime [result_num]
    push dword result_num
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

overflow:

    ;print(overflow)
    push msgOverflow_len
    push msgOverflow
    call print
    add esp, 8

    jmp exit
    