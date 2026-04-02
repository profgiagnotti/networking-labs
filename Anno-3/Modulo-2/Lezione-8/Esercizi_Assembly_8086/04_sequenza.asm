; quarto esercizio: sequenza  
;*****************************     
;Date 2 variabili: 

;    op1=02546o
;    op2=1236o

;Fare la differenza

data segment
    op1 DW 02546o
    op2 DW 1236o  
    differenza DW ?
ends

stack segment
    
ends

code segment
start:
; imposto il registri DS:
    mov AX, data
    mov DS, AX

    ; aggiungo il codice:
            
    mov AX,op1
    sub AX,op2
    mov differenza, AX     
    
    ; restituisco il controllo al sistema operativo.
    mov ax, 4c00h 
    int 21h    
ends

end start 
