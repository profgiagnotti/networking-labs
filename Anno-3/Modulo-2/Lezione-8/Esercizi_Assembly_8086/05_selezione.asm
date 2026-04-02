; primo esercizio: selezione  
;*****************************     
;dati due numeri 
; n1= 345o e n2=76h
;determinare il maggiore di essi.
;Se n1>n2 calcola la somma e memorizzala in "somma"
;Altrimenti calcola la differenza e memorizzala in "differenza"

data segment
    n1 DW 345o
    n2 DW 76h 
    somma DW 0h 
    differenza DW 0h
ends

stack segment
    
ends

code segment
start:
; imposto il registri DS:
    mov AX, data
    mov DS, AX

    ; aggiungo il codice:
            
    mov AX,n1
    cmp AX,n2  
    JG maggiore  
    
    minore:
    sub AX, n2
    mov differenza, AX 
    JMP fine
    
    maggiore:
        add AX,n2
        mov somma,AX   
    
    fine:
    ; restituisco il controllo al sistema operativo.
    mov ax, 4c00h 
    int 21h    
ends

end start 
