section .data
    welcome         db  "Bem-vindo. Digite seu nome: "
    welcome_len     equ $ - welcome
    hello_1         db  "Ola, "
    hello_1_len     equ $ - hello_1
    hello_2         db  ", bem-vindo ao programa de CALC IA-32", 0xA
    hello_2_len     equ $ - hello_2
    question        db  "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32):"
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
section .bss
    name        resb 50
    name_len    resd 1
    bit_size    resb 1
    operation   resb 1
section .text
global _start

_start:

    ;print(welcome)
    push welcome_len
    push welcome
    call print
    add esp, 8
    
    ;read(name)
    push 50
    push name
    call read
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
    push 1
    push bit_size
    call read
    add esp, 8

    ;print(menu)
    push menu_len
    push menu
    call print
    add esp, 8

    ;read(operation)
    push 1
    push operation
    call read
    add esp, 8

    ;exit
    mov eax, 1
    mov ebx, 0
    int 80h

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

read:

    push ebp
    mov ebp, esp
    
    mov eax, 3
    mov ebx, 0
    mov ecx, [ebp+8]
    mov edx, [ebp+12]
    int 80h
    
    leave
    ret