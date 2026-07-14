section .data
    welcome         db  "Bem-vindo. Digite seu nome: "
    welcome_len     equ $ - welcome
    hello_1         db  "Ola, "
    hello_1_len     equ $ - hello_1
    hello_2         db  ", bem-vindo ao programa de CALC IA-32", 10
    hello_2_len     equ $ - hello_2
    question        db  "Vai trabalhar com 16 ou 32 bits (digite 0 para 16, e 1 para 32):"
    question_len    equ $ - question
section .bss
    name        resb 50
    name_len    resd 1
section .text
global _start

_start:

    push welcome_len
    push welcome
    call print
    add esp, 8
    
    push 50
    push name
    call read
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

    mov eax, 1                  ; sys_exit system call ID
    mov ebx, 0                  ; Exit code 0
    int 80h

print:
 
    push ebp                    ; Save caller's base pointer[cite: 1]
    mov ebp, esp                ; Set base pointer for this stack frame[cite: 1]
    
    mov eax, 4                  ; op1 <- op2: Move system call ID for sys_write[cite: 1]
    mov ebx, 1                  ; op1 <- op2: Move file handler (stdout)[cite: 1]
    mov ecx, [ebp+8]            ; op1 <- op2: Load the string pointer from the stack[cite: 1]
    mov edx, [ebp+12]           ; op1 <- op2: Load the string size from the stack[cite: 1] 
    int 80h                     ; Performs the interrupt indicated by the operand[cite: 1]
    
    leave                       ; Restores the previous stack frame[cite: 1]
    ret                         ; Jumps while popping the return address off the stack[cite: 1]

read:

    push ebp                    ; Save caller's base pointer[cite: 1]
    mov ebp, esp                ; Set base pointer for this stack frame[cite: 1]
    
    mov eax, 3                  ; op1 <- op2: Move system call ID for sys_read (3)[cite: 1]
    mov ebx, 0                  ; op1 <- op2: Move file handler for stdin (0)[cite: 1]
    mov ecx, [ebp+8]            ; op1 <- op2: Load the buffer pointer from the stack[cite: 1]
    mov edx, [ebp+12]           ; op1 <- op2: Load the max buffer size from the stack[cite: 1] 
    int 80h                     ; Performs the interrupt indicated by the operand[cite: 1]
    
    leave                       ; Restores the previous stack frame[cite: 1]
    ret