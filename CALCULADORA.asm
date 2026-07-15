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
section .text
global _start

; ========================================================
; PONTO DE ENTRADA: _start
; Fluxo: pede o nome do usuário, pede se vai trabalhar com 16 ou 32
; bits, e entra no loop do menu, repetindo até a opção "7: SAIR".
; ========================================================
_start:

    push welcome_len
    push welcome
    call print
    add esp, 8

    push 50
    push name
    call read_str
    dec eax
    mov [name_len], eax
    add esp, 8

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

    push question_len
    push question
    call print
    add esp, 8

    push 2
    push bit_size
    call read_str
    add esp, 8

    jmp skip_enter

menu_loop:

    ;read(enter)
    push 1
    push operation
    call read_str
    add esp, 8

skip_enter:

    push menu_len
    push menu
    call print
    add esp, 8

    push 2
    push operation
    call read_char
    add esp, 8

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
    sub esp, 54

    mov word [ebp-2], 0
    mov word [ebp-4], 0

    mov eax, 3
    mov ebx, 0
    mov ecx, ebp
    sub ecx, 54
    mov edx, 50
    int 80h

    mov ebx, ebp
    sub ebx, 54

    mov cx, 0
    mov cl, [ebx]
    cmp cl, 45
    jne .loop_16
    mov word [ebp-4], 1
    inc ebx
    dec eax

.loop_16:
    cmp eax, 0
    je .end_16

    mov cx, 0
    mov cl, [ebx]
    cmp cl, 10
    je .end_16

    sub cl, 48

    push eax
    mov ax, [ebp-2]
    mov dx, 10
    mul dx
    add ax, cx
    mov [ebp-2], ax
    pop eax

    inc ebx
    dec eax
    jmp .loop_16

.end_16:
    mov ax, [ebp-2]
    cmp word [ebp-4], 1
    jne .store_16
    neg ax

.store_16:
    mov ebx, [ebp+8]
    mov [ebx], ax

    leave
    ret


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
    sub esp, 58

    mov dword [ebp-4], 0
    mov dword [ebp-8], 0

    mov eax, 3
    mov ebx, 0
    mov ecx, ebp
    sub ecx, 58
    mov edx, 50
    int 80h

    mov ebx, ebp
    sub ebx, 58

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

    push eax
    mov eax, [ebp-4]
    mov edx, 10
    mul edx
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
    neg eax

.store_32:
    mov ebx, [ebp+8]
    mov [ebx], eax

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
    mov eax, [ecx]
    jmp .begin

.read_word:
    movsx eax, word [ecx]

.begin:
    mov ebx, 10
    xor ecx, ecx
    xor edi, edi
    cmp eax, 0
    jge .loop
    neg eax
    mov edi, 1

.loop:
    xor edx, edx
    div ebx
    add dl, 48
    push edx
    inc ecx
    cmp eax, 0
    jne .loop

    cmp edi, 1
    jne .copy_to_buffer
    push 45
    inc ecx

.copy_to_buffer:
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
; ROTINAS: menu_add, menu_sub, menu_mul, menu_div, menu_mod, menu_exp
; Descrição: Tratam as opções do menu (SOMA, SUBTRACAO, MULTIPLICACAO,
; DIVISAO, MOD, EXPONENCIACAO). Cada uma pede dois números ao usuário,
; aplica a operação correspondente e imprime o resultado. Não são
; funções "call/ret" — são acessadas via jmp/je a partir de menu_loop
; e retornam a ele também via jmp; usam seu próprio frame de pilha só
; para guardar num1, num2, overflow (quando aplicável) e o resultado.
; Parâmetros: nenhum (lêem de stdin, usam a variável global [bit_size]).
; Retorno: nenhum (imprimem o resultado).
; ========================================================
menu_add:

    push ebp
    mov ebp, esp
    sub esp, 12

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov eax, ebp
    sub eax, 12
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call add_int
    add esp, 12

    mov eax, ebp
    sub eax, 12
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_sub:

    push ebp
    mov ebp, esp
    sub esp, 12

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov eax, ebp
    sub eax, 12
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call sub_int
    add esp, 12

    mov eax, ebp
    sub eax, 12
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_mul:

    push ebp
    mov ebp, esp
    sub esp, 16

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov dword [ebp-12], 0

    mov eax, ebp
    sub eax, 12
    push eax

    mov eax, ebp
    sub eax, 16
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call mul_int
    add esp, 16

    cmp dword [ebp-12], 1
    je overflow

    mov eax, ebp
    sub eax, 16
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_div:

    push ebp
    mov ebp, esp
    sub esp, 12

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov eax, ebp
    sub eax, 12
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call div_int
    add esp, 12

    mov eax, ebp
    sub eax, 12
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_mod:

    push ebp
    mov ebp, esp
    sub esp, 12

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov eax, ebp
    sub eax, 12
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call mod_int
    add esp, 12

    mov eax, ebp
    sub eax, 12
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

menu_exp:

    push ebp
    mov ebp, esp
    sub esp, 16

    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call ask_nums
    add esp, 8

    mov dword [ebp-12], 0

    mov eax, ebp
    sub eax, 12
    push eax

    mov eax, ebp
    sub eax, 16
    push eax
    mov eax, ebp
    sub eax, 8
    push eax
    mov eax, ebp
    sub eax, 4
    push eax
    call exp_int
    add esp, 16

    cmp dword [ebp-12], 1
    je overflow

    mov eax, ebp
    sub eax, 16
    push eax
    call print_num
    add esp, 4

    mov esp, ebp
    pop ebp
    jmp menu_loop

; ========================================================
; ROTINA: overflow
; Descrição: Imprime a mensagem de overflow e encerra o programa.
; ========================================================
overflow:

    push msgOverflow_len
    push msgOverflow
    call print
    add esp, 8

    jmp exit
