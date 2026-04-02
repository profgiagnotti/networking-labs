; Definire le variabili v1 = 0x341 e v2 = 2567o e due variabili per il risultato: somma e diffrenza.
; Calcolare la somma v1 + v2 e memorizzarla nella variabile somma, calcolare la differenza v1-v2 e memorizzarla 
; nella variabile differenza. 

data segment
     v1 dw 0x341
     v2 dw 2567o
     somma dw ?
     differenza dw ?
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov ax, v1   ; copio v1 in ax
    add ax, v2   ; aggiungo v2
    mov somma, ax     ; copio ax in somma
    
    mov ax, v1         ; copio v1 in ax
    sub ax, v2         ; sottraggo v2
    mov differenza, ax   ; copio ax in differenza
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
