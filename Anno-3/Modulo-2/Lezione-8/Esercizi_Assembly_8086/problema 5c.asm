;Definire la somma dei numeri da 10 a 19 (estremi compresi) e memorizzare il risultato in somma. 
;Il problema deve calcolare 10+11+12+13+14+15+16+17+18+19 = 145
                                
data segment
     i db 20d
     C db 29d
     somma db 0
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov al, i                 ;copio i in al
    mov somma,al              ;copio 10 in somma 
ciclo:                        ;ciclo while
    
    cmp al, C                 ;confronto l'indice i con il numero massimo (19)
    jge fine                  ;se i e' >= 19 -->  fine                   
    inc i                     ; incremento i
    mov al,i                  ;copio i in al
    add somma,al              ;aggiungo al a somma
    jmp ciclo                 ;continuo il ciclo
    
      
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
