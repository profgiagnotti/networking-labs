;ciclo while: 


data segment
     numero      db 5           ; Numero di partenza (5)
     risultato   dw 1           ; Risultato iniziale (1)     
ends

stack segment
    
ends

code segment 
    
start:
; set segment registers:
    mov ax, data
    mov ds, ax 
    
    mov cl, numero             ; CL = 5 (numero)
    mov ax, 1                  ; AX = risultato (iniziale a 1)

ciclo_while:
    cmp cl, 1
    jl fine_ciclo        ; if i < 1 then exit

    mul cl               ; AX = AX * CL ? risultato *= i
    dec cl               ; i--

    jmp ciclo_while

fine_ciclo:
    ; AX contiene il fattoriale
    mov risultato, ax
    
    ; uscita dal programma
    mov ax, 4C00h
    int 21h


end start ; set entry point and stop the assembler.
