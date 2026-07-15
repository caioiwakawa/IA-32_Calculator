global bit_size
global print

extern ask_nums
extern add_int
extern sub_int
extern div_int
extern mod_int

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
    newline         db  0xA
    newline_len     equ $ - newline
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

menu_loop:
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
    je menu_add

    cmp al, '4'
    je menu_div

    cmp al, '5'
    je menu_add

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