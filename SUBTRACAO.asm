global sub_int

extern bit_size

section .text

; ========================================================
; FUNÇÃO: sub_int
; Descrição: Subtrai dois inteiros assinados (16 ou 32 bits, conforme a
; variável global [bit_size]) e grava o resultado no destino indicado.
; Parâmetros:
;   [ebp+8]  -> Ponteiro para o primeiro número (num1).
;   [ebp+12] -> Ponteiro para o segundo número (num2).
;   [ebp+16] -> Ponteiro para onde gravar o resultado (num1 + num2).
;               Deve ter o mesmo tamanho de num1/num2 (word ou dword,
;               conforme [bit_size]).
; Retorno: Nenhum (o resultado é gravado via ponteiro, não em EAX).
; ========================================================
sub_int:
    
    push ebp
    mov ebp, esp

    cmp byte [bit_size], '0'
    je .sub_int16

    cmp byte [bit_size], '1'
    je .sub_int32

.sub_int32:
    ; ----------------------------------------------------
    ; MODO 32 BITS (Usa registradores EAX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]            
    mov eax, [ebx]             
    
    mov ebx, [ebp+12]          
    sub eax, [ebx]            
    
    mov ebx, [ebp+16]          
    mov [ebx], eax             
    jmp .end_sub              

.sub_int16:
    ; ----------------------------------------------------
    ; MODO 16 BITS (Usa registradores AX)
    ; ----------------------------------------------------
    mov ebx, [ebp+8]           
    mov ax, [ebx]              
    
    mov ebx, [ebp+12]          
    sub ax, [ebx]              
    
    mov ebx, [ebp+16]         
    mov [ebx], ax             

.end_sub:
    leave                      
    ret                       