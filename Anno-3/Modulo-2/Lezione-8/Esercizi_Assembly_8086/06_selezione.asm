; secondo esercizio selezione.

data segment
     v1 DW 0x234     ;564d
     v2 DW 0xA45     ;2629d
     C EQU 0x77       ;119d  
     D EQU 0xC2       ;194d
     par_int_a DB ?
     par_int_b DB ?
     resto_a DB ?
     resto_b DB ? 
     ris_par_int DB ?
     ris_resto DB ?
     
ends

stack segment
    
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax 
    
    mov ax, v1
    mov bl, C
    div bl  
    mov par_int_a, al  ;0x04 --> quoziente = 4d
    mov resto_a, ah    ;0x58 --> resto = 88d  
    
    mov ax, v2
    mov bl, D
    div bl  
    mov par_int_b, al  ;0x0D --> quoziente = 13d
    mov resto_b, ah    ;0x6B --> resto = 107d    
    
    mov al,par_int_a
    cmp al, par_int_b  
    mov bl, par_int_b
    JG maggiore1
    JLE minore1
    
minore1:
    mul bl     
    mov ris_par_int, al    ; al = 0x34 = 4d*13d=52d
    JMP prosegui
    
maggiore1:
    
    div bl
    mov ris_par_int, al  
    JMP prosegui
    
prosegui: 
    mov al,resto_b
    cmp al, resto_a  
    mov bl, resto_a
    JG maggiore2
    JLE minore2  
    
minore2:
    mul bl    
    mov ris_resto, al
    JMP fine
    
maggiore2:
    
    div bl  
    mov ris_resto, al          ;al = 0x01 = 1d; ah = 0x13 = 19d
    JMP fine                                  
                                              
fine:
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
