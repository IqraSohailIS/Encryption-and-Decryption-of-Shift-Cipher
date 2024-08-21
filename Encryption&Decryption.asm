include emu8086.inc
org 100h

.data
  Alpha db 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
  PlainText db 100 dup(?)  ; Increase the size of the PlainText buffer to accommodate more characters
  CipherText db 100 dup(?)
  ShiftKey db ?
  First dw ?
  Last dw ?
    
.code
  
  printn "      This Program does Encryption/Decryption using Caesar Cipher"
  printn
  
Repeat:
  printn
  printn
  printn "Select one option"
  printn
  printn "1. Encryption"
  printn "2. Decryption"
  printn "0. Exit"
  
  mov bl,0
  call scan_num
  mov bl,cl
  cmp bl, 1h
  je ENCRYPTION
  cmp bl, 2h
  je DECRYPTION 
  jg Error
  cmp bl, 0h
  je Exit
  jl Error
  
  Error:
  printn 
  printn 'You entered an Invalid Option!' 
  printn 'Option should be between 0 & 2'
  JMP Repeat
  
  
ENCRYPTION:
    printn 
    printn
    printn "           ENCRYPTION"
    printn
    mov si, 0
    mov di, 0
    printn
    print "Enter plain text: "
    inputPT:
    mov ah, 1
    int 21h
    cmp al, 13  ; Check for the Enter key
    je exitLoop  ; Jump to exitLoop label if Enter key is pressed

    cmp al, 96
    JA lower
    add al, 32  ; converts uppercase to lowercase

    lower:
    mov PlainText[si], al
    inc si

    ; Continue looping for additional input
    jmp inputPT

    exitLoop:
    ; Store null terminator at the end of the PlainText
    mov byte ptr PlainText[si], 0

    mov si, 0
    printn
    print "Entered plain text is: "
    displayPT:
    mov al, PlainText[si]
    putc al
    print
    inc si

    ; Check for an exit condition
    cmp byte ptr PlainText[si], 0  ; Check if the current character is a null terminator (end of string)
    jnz displayPT  ; If not null terminator, continue looping

    ; Enter key between 0 & 25
    printn
    KEY:
    printn
    print 'Enter value for shift key: '
    call scan_num
    mov ShiftKey, cl
    xor ch, ch

    mov al, 25
    cmp ShiftKey, al   ; Condition for key to be less than 25
    JA KEY_AGAIN       ; loop to enter key again
    mov al, 0
    cmp al, ShiftKey    ; Condition for key to be positive
    JG KEY_AGAIN       ; loop to enter key again
    JMP NEXT

    KEY_AGAIN:
    printn
    printn 'You entered an Invalid Key!'
    printn 'Key should be between 0 & 25'
    JMP KEY

    ; Finding Index and Encrypting Data
    NEXT:
    mov ax, 0
    mov first, 0
    mov last, 19h
    mov cl, PlainText[di]

    binary_search:
    mov ax, first
    add ax, last
    shr ax, 1
    mov si,ax

    cmp Alpha[si],cl

    je ENCRYPT  ; Found the index, jump to ENCRYPT

    jl less
    jg greater

    less:
    inc si
    mov first, si
    cmp cl,Alpha[si]
    je ENCRYPT
    dec si
    jmp binary_search

    greater:
    dec si
    mov last, si
    cmp cl,Alpha[si]
    je ENCRYPT
 
    jmp binary_search

    ENCRYPT:
    mov ax, si
    xor ah, ah
    add al, ShiftKey
    cmp al, 26
    jge mode
    jmp continue

    ; Number is greater than 25
    mode:
    xor ah, ah
    mov bx, 26
    div bx
    mov al, dl

    continue:
    add al, 'a'  ; Converting number to lowercase alphabet
    mov CipherText[di], al
    inc di

    ; Check for null character in plaintext
    mov al, PlainText[di]
    cmp al, 0
    jnz NEXT  ; If not null character, continue encryption
    
    mov byte ptr CipherText[di], 0 
    
    ; Displaying Ciphertext
    mov si, 0
    printn
    print "Corresponding Ciphertext is: "
    displayCT:
    mov al, CipherText[si]
    putc al
    print
    inc si

    ; Check for an exit condition
    cmp byte ptr CipherText[si], 0  ; Check if the next character is a null terminator (end of string)
    jnz displayCT  ; If not null terminator, continue displaying
    
    jmp Repeat
      
DECRYPTION:
    printn
    printn
    printn "           DECRYPTION"
    printn
    mov si, 0
    mov di, 0
    printn
    print "Enter cipher text: "
    inputCT:
    mov ah, 1
    int 21h
    cmp al, 13  ; Check for the Enter key
    je exitLoopD  ; Jump to exitLoop label if Enter key is pressed

    cmp al, 96
    JA lowerD
    add al, 32  ; converts uppercase to lowercase

    lowerD:
    mov CipherText[si], al
    inc si

    ; Continue looping for additional input
    jmp inputCT

    exitLoopD:
    ; Store null terminator at the end of the Ciphertext
    mov byte ptr CipherText[si], 0

    mov si, 0
    printn
    print "Entered cipher text is: "
    displayCTD:
    mov al, CipherText[si]
    putc al
    print
    inc si

    ; Check for an exit condition
    cmp byte ptr CipherText[si], 0  ; Check if the current character is a null terminator (end of string)
    jnz displayCTD  ; If not null terminator, continue looping

    ; Enter key between 0 & 25
    printn
    KEYD:
    printn
    print 'Enter value for shift key: '
    call scan_num
    mov ShiftKey, cl
    xor ch, ch

    mov al, 25
    cmp ShiftKey, al   ; Condition for key to be less than 25
    JA KEY_AGAIND       ; loop to enter key again
    mov al, 0
    cmp al, ShiftKey    ; Condition for key to be positive
    JG KEY_AGAIND       ; loop to enter key again
    JMP NEXTD

    KEY_AGAIND:
    printn
    printn 'You entered an Invalid Key!'
    printn 'Key should be between 0 & 25'
    JMP KEYD

    ; Finding Index and Decrypting Data
    NEXTD:
    mov ax, 0
    mov first, 0
    mov last, 19h
    mov cl, CipherText[di]

    binary_searchD:
    mov ax, first
    add ax, last
    shr ax, 1
    mov si,ax

    cmp Alpha[si],cl

    je DECRYPT  ; Found the index, jump to DECRYPT

    jl lessD
    jg greaterD

    lessD:
    inc si
    mov first, si
    cmp cl,Alpha[si]
    je DECRYPT
    dec si
    jmp binary_searchD

    greaterD:
    dec si
    mov last, si
    cmp cl,Alpha[si]
    je DECRYPT
 
    jmp binary_searchD

    DECRYPT:
    mov ax, si
    xor ah, ah
    sub al, ShiftKey  ; Subtract the ShiftKey from al
    cmp al, 0
    jl modeD          ; Jump to mode if al is less than 0

    jmp continueD

    modeD:
    xor ah, ah
    add al,26

    continueD:
    add al, 'a'  ; Converting number to lowercase alphabet
    mov PlainText[di], al
    inc di

    ; Check for null character in ciphertext
    mov al, CipherText[di]
    cmp al, 0
    jnz NEXTD  ; If not null character, continue decryption
    
    mov byte ptr PlainText[di], 0
    ; Displaying Plaintext
    mov si, 0
    printn
    print "Corresponding Plaintext is: "
    displayPTD:
    mov al, PlainText[si]
    putc al
    print
    inc si

    ; Check for an exit condition
    cmp byte ptr PlainText[si], 0  ; Check if the next character is a null terminator (end of string)
    jnz displayPTD  ; If not null terminator, continue displaying
    
    jmp Repeat
    
    
Exit:
 printn
 print "Program is being exited!"
    
ret
DEFINE_SCAN_NUM
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS    