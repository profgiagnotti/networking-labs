; definire due costanti: C1=245o e C2=123h. Confrontare questi valori. Se C1 e' minore di C2 calcolare la differenza e memorizzarla
; nella variabile differenza1_2 altrimenti calcolare la differenza C2-C1 e memorizzare il risultato nella variabile differenza2_1
                                
data segment
     C1 db 245o
     C2 db 0xA3
     differenza1_2 db 0
     differenza2_1 db 0 
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov al, C1               ;copio C1 in al
    cmp al, C2               ;confronto C1 con C2
    jge maggiore             ;se C1 > C2 salto a maggiore altrimenti proseguo 
    sub C2, al
    mov differenza1_2, al    ;(C1<=C2 -> copio al in differenza1_2)
    jmp fine                 ;salta alla fine
    
maggiore:
    mov bl, C2               ;(C1>C2 -> copio C2 in bl
    sub al,bl                ;sottraggo C1-C2
    mov differenza2_1, al    ; copio il risultato in differenza2_1
    
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
