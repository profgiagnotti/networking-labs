;Definire due costanti: C1=0xDA e C2=0x1A. Calcolare C1 / C2 e memorizzare il resto nella variabile resto. Se il resto e' < 10d sommare 
;le costanti e memorizzare la somma nella variabile somma, se il resto e' > 10d calcolare C1 - C2 e memorizzare il risultato 
;nella variabile differenza, se il resto vale 10d moltiplicare C1*C2 e memorizzare il risultato nella variabile prodotto 
 
                                
data segment
     C1 db 0xB4
     C2 db 0x32
     differenza db ?
     somma db ?
     prodotto dw ?
     resto db ? 
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov ah, 0x00            ; azzero la parte alta di A
    mov al, C1              ; copio C1 in al
    mov bl, C2              ; copio C2 in bl 
    div bl                  ; divido C1 / C2
    mov resto, ah           ; copio il resto nella variabile resto
    
                            ; match con 10
                            ; da qui in poi faccio gli altri match
    cmp resto, 30d         
    jl minore               ;salta a maggiore se il resto < zero 
    jg maggiore             ;salta a zero se il resto > zero
    je zero                 ;salta a zero se il resto e' zero
    
    
minore:
    mov al, C1              ;copio C1 in al
    add al, C2              ;aggiungo C2
    mov somma, al           ;copio il risultato in somma 
    jmp fine
                            
maggiore:    
    mov al, C1              ;copio C1 in al
    sub al, C2              ;sottraggo C2
    mov differenza, al           ;copio il risultato in differenza 
    jmp fine
        
zero:                       
    mov ah, 000h            ;azzero la parte alta di a
    mov al, C1              ;copio C1 in al
    mov bl, C2              ;copio C2 in bl
    mul bl                  ;moltiplico C1 * C2
    mov prodotto, ax        ;copio il risultato in prodotto
      
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
