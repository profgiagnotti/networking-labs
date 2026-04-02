; definire due costanti: 0x529 e C2=0x4C0. Confrontare questi valori. Se C1 e' maggiore di C2 calcolare la differenza e memorizzarla
; nella variabile differenza1_2 altrimenti calcolare la differenza C2-C1 e memorizzare il risultato nella variabile differenza2_1
                                
data segment
     C1 dw 0x519
     C2 dw 0x5C0
     differenza1_2 dw 0
     differenza2_1 dw 0 
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    
    mov ax, C1               ;copio C1 in al
    cmp ax, C2               ;confronto C1 con C2
    jg maggiore 
    mov bx, c2            ;se C1 > C2 salto a maggiore altrimenti proseguo 
    sub bx, ax
    mov differenza2_1, bx    ;(C1<=C2 -> copio al in differenza1_2)
    jmp fine                 ;salta alla fine
    
maggiore:
    mov bx, C2               ;(C1>C2 -> copio C2 in bl
    sub ax,bx                ;sottraggo C1-C2
    mov differenza1_2, ax    ; copio il risultato in differenza2_1
    
fine:    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
