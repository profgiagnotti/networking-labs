; primo esempio: sequenza  
;*****************************     
;dati due numeri determinare 
;a + D e scrivere il risultato nella variabile x
;b + C e scrivere il risultato nella variabile y
;x-y e scrivere il risultato nella variabile ris</li>

data segment
    a DB 67d
    b DB 53o
    C EQU 4h
    D EQU 1001b
    x DB ?
    y DB ?
    ris DB ?
ends

stack segment
    
ends

code segment
start:
; imposto il registri DS:
    mov AX, data
    mov DS, AX

    ; aggiungo il codice:
            
    mov AL,a
    add AL,D
    mov x, AL  
    
    mov AL, b
    add AL, c
    mov y, AL   
    
    mov AL, x
    sub AL, y
    mov ris, AL
    
    
    
    ; restituisco il controllo al sistema operativo.
    mov ax, 4c00h 
    int 21h    
ends

end start 
