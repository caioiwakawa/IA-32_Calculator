## SOFTWARE BÁSICO - PROJETO 2

### TURMA 2 - 2026.1

#### Caio Eduardo da Silva - 231034298
#### Marcos Alexandre da Silva Neres - 211055334

## Ferramentas necessárias

Para compilar e executar este programa em Assembly IA-32, você precisa ter instaladas as seguintes ferramentas:

- NASM: montador para arquivos .asm
- ld: linker para gerar o executável final
- Se estiver no Windows, o projeto pode ser compilado via WSL/Ubuntu

## Como compilar e executar

Abra o terminal na pasta do projeto e execute os comandos abaixo:

```bash
nasm -f elf32 -o CALCULADORA.o CALCULADORA.asm
nasm -f elf32 -o SOMA.o SOMA.asm
nasm -f elf32 -o SUBTRACAO.o SUBTRACAO.asm
nasm -f elf32 -o DIVISAO.o DIVISAO.asm
nasm -f elf32 -o MODULO.o MODULO.asm
nasm -f elf32 -o MULTIPLICACAO.o MULTIPLICACAO.asm
nasm -f elf32 -o EXPONENCIACAO.o EXPONENCIACAO.asm

ld -m elf_i386 -o calculadora CALCULADORA.o SOMA.o SUBTRACAO.o DIVISAO.o MODULO.o MULTIPLICACAO.o EXPONENCIACAO.o
```

## Executar o programa

```bash
./calculadora
```

### Exemplo usando WSL no Windows

```bash
wsl.exe -e bash -lc 'cd /mnt/c/Users/caioi/OneDrive/Área\ de\ Trabalho/coding/assembly-calc && nasm -f elf32 -o CALCULADORA.o CALCULADORA.asm && nasm -f elf32 -o SOMA.o SOMA.asm && nasm -f elf32 -o SUBTRACAO.o SUBTRACAO.asm && nasm -f elf32 -o DIVISAO.o DIVISAO.asm && nasm -f elf32 -o MODULO.o MODULO.asm && nasm -f elf32 -o MULTIPLICACAO.o MULTIPLICACAO.asm && nasm -f elf32 -o EXPONENCIACAO.o EXPONENCIACAO.asm && ld -m elf_i386 -o calculadora CALCULADORA.o SOMA.o SUBTRACAO.o DIVISAO.o MODULO.o MULTIPLICACAO.o EXPONENCIACAO.o && ./calculadora'
```