;ciclo for: 


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

calcolo_fattoriale:
    mul cl                     ; AX = AX * CL
    dec cl                     ; CL = CL - 1
    cmp cl, 1
    jge calcolo_fattoriale     ; Continua finché CL >= 1

    mov risultato, ax          ; Salva il risultato nella variabile  
    
    ; uscita dal programma
    mov ax, 4C00h
    int 21h


end start ; set entry point and stop the assembler.
