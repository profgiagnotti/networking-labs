;Calcolare la divisione 100d / 10d utilizzando dieci decrementi e memorizzare il risultato nella variabile risultato. 
;Il problema deve calcolare: 100-10 (prima iterazione), 90-10(seconda iterazione) e cosi' via fino ad ottenere come risultato 10
                                
data segment
     k db 1d  
     step db 10d
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
    mov al,100d            ;copio il numero 100 in al
    mov bl,step            ;copio lo step in bl
    
ciclo:       
    cmp k, bl              ;confronto l'indice k con lo step
    jge fine               ;se k>=step termina il ciclo altrimenti:
    sub al,step            ;sottrai da al lo step
    inc k                  ;incrementa l'indice k
    
    jmp ciclo              ;ripeti il ciclo
    
      
fine:  
mov risultato, al  
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
