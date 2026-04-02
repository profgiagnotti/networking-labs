;Definire la somma dei quadrati dei numeri da 1 a 4 e memorizzare il risultato in somma. 
;Il problema deve calcolare 1*1 + 2*2 +3*3 + 4*4 = 30
                                
data segment
     i db 1d
     C db 4d
     somma db 0
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    
ciclo:                        ;ciclo while
    mov al, i
    cmp al, C                 ;confronto l'indice i con il numero massimo (4)
    jg fine                   ;se i e' >= 4 -->
    mov bl,i                  ;copio i in bl
    mul bl                    ;moltiplico i*i
    add somma,al              ;metto il risultato parziale in somma
    inc i                     ;incremento i
    
    jmp ciclo                 ;continuo il ciclo
    
      
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
