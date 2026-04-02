; terzo esercizio: sequenza  
;*****************************     
;Date 2 costanti: 

;    pippo=02Dh
;    pluto=18Dh

;Fare la somma. Somma nella parte alta del registro

data segment
    pippo EQU 02Dh
    pluto EQU 18Dh  
    somma DW ?
ends

stack segment
    
ends

code segment
start:
; imposto il registri DS:
    mov AX, data
    mov DS, AX

    ; aggiungo il codice:
            
    mov AX,pippo
    add AX,pluto
    mov somma, AX     
    
    ; restituisco il controllo al sistema operativo.
    mov ax, 4c00h 
    int 21h    
ends

end start 
