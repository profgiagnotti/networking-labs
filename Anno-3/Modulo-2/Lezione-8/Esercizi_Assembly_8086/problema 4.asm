;Definire due costanti: C1=2Ah e C2=28h. Calcolare la differenza e memorizzarla nella variabile differenza. Se differenza e' 0 sommare 
;le costanti e memorizzare la somma nella variabile somma, se la differenza vale 1 moltiplicare le costanti e memorizzare il risultato 
;nella variabile prodotto, se la differenza vale 2 dividere C1/C2 e memorizzare il quoziente nella variabile quoziente e il resto nella 
;variabile resto 
                                
data segment
     C1 db 2Ah
     C2 db 28h
     differenza db ?
     somma db ?
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
    
    mov al, C1              ; copio C1 in al
    sub al, C2              ; sottraggo C1-C2
    mov differenza, al      ; copio il risultato della differenza nella variabile differenza
    
                            ; match con 0
                            ; da qui in poi faccio il match con 0, 1 e 2 eseguendo sempre:
    cmp differenza, 0
    jne dif1                ;salto se non c'e' match
    mov al, C1              ;copio C1 in al
    add al, C2              ;aggiungo C2
    mov somma, al           ;copio il risultato in somma
    jmp fine
                            ; match con 1
dif1:    
    cmp differenza, 1
    jne dif2
    mov al, C1
    mov bl, C2 
    mul bl
    mov prodotto, ax
    jmp fine
        
dif2:                       ; match con 2
    cmp differenza, 2
    mov ah, 000h     
    mov al, C1
    mov bl, C2
    div bl
    mov quoziente, al
    mov resto, ah
      
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
