; definire le variabili v1 = 0xD7 e v2 = 51o e tre variabili per il risultato: prodotto,quoziente e resto
; calcolare il prodotto v1 * v2 e memorizzarlo nella variabile prodotto, calcolare il quoziente v1/v2 e memorizzarlo 
; nella variabile quoziente. Infine memorizzare il resto della divisione nella variabile resto

data segment
     v1 db 0xC7
     v2 db 41o
     prodotto dw ?
     quoziente db ? 
     resto db ?
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov al, v1     ; copio v1 in al
    mov bl, v2     ; copio v2 in bl
    mul bl         ; moltiplico v1 per v2
    mov prodotto, ax   ;copio il risultato della moltiplicazione in prodotto
    
    mov ah, 0h     ; azzero la parte alta di ax
    mov al, v1     ;copio v1 in al
    mov bl, v2     ;copio v2 in bl
    div bl         ; divido v1 /v2
    mov quoziente, al  ;copio al in quoziente 
    mov resto, ah      ;copio ah in resto
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
