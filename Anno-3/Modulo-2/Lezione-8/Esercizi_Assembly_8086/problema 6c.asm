;Calcolare la moltiplicazione 10d * 10d utilizzando dieci incrementi di 10d e memorizzare il risultato nella variabile risultato. 
;Il problema deve calcolare: 10+10 (prima iterazione), 20+10(seconda iterazione) e cosi' via fino ad ottenere come risultato 100
                                
data segment
     k db 1d  
     step db 5d
     risultato db 0
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
                           ;ciclo for
    mov al,5d              ;copio il numero 5 in al
    mov bl,step            ;copio lo step in bl
    
ciclo:       
    cmp k, 10d             ;confronto l'indice k con le iterazioni
    jge fine               ;se k>=10 termina il ciclo altrimenti:
    add al,step            ;aggiungi 5
    inc k                  ;incrementa l'indice k
    
    jmp ciclo              ;ripeti il ciclo
    
      
fine:  
mov risultato, al  
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
