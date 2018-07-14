; Created by: Juliocarlos Velez
.model small

.data
table db 81 dup('!')
bit   db 81 dup(0)
text  db 'Congratulations!'
crlf  db 0Ah,0Dh,'$'
fwin  db 0

.stack 100h

.code
start:
	mov ax,@data
	mov ds,ax
	mov es,ax
	
	;set text videomode
	mov ah,0
	mov al,3
	int 10h

	call DrawTable
	call Place
	call View
	call Press
	
	cmp fwin,0
	jne exit
	
	call Winner
	
	exit:
	xor ah,ah
	int 16h

    mov ah,4Ch
    mov al,00h
    int 21h
    
;procedure for creating a table
DrawTable proc
    ;set beginning cursor offset
    mov ah,2
    mov bh,0
    mov dh,1
    mov dl,1
    int 10h

    ;number of rows
    mov cx,9
    rows:
  	    push cx
		   
		;number of cols
		mov cx,9
		cell:
			push cx
			
			;write space
			mov ah,9
			mov al,20h		;character
			mov bh,0
			mov bl,47h		;colour
			mov cx,1
			int 10h
			
			;move cursor to next col
			mov ah,2
			mov bh,0
			add dl,2
			int 10h 

			pop cx
		loop cell

        ;set cursor to next row
	    mov ah,2
		mov bh,0
		add dh,2
		mov dl,1
		int 10h

 	    pop cx
    loop rows
    
    ;exit procedure
    ret
DrawTable endp

Place proc
	;assign beginning offsets
	lea si,table
	lea di,bit
	
	;get random number using clock ticking
	xor ah,ah
	int 1Ah
	
	;random time delay
	mov cx,dx
	delay1:
		nop
	loop delay1
	
	mov ax,1	
	mov cx,9
	SetNumber:
			push cx
			push si
			push di
			
			push ax
			
			;get random number using clock ticking
			xor ah,ah
			int 1Ah
			
			;random time delay
			mov cx,dx
			delay2:
				nop
			loop delay2
			
			;get random number using ticking
			xor ah,ah
			int 1Ah
			
			;get a random row
			mov ax,dx
			xor dx,dx
			mov bx,9
			div bx
			
			;calculate offset of random row beginning
			mov al,9
			mul dl
			
			;change offset according to row begin
			add si,ax
			add di,ax
			
			;get random number using clock ticking
			xor ah,ah
			int 1Ah
			
			;random time delay
			mov cx,dx
			delay3:
				push cx
				
				xor ah,ah
				int 1Ah
				
				mov ax,dx
				xor dx,dx
				mov bx,3
				div bx
				
				mov cx,dx
				delay4:
					nop
				loop delay4
				
				pop cx
			loop delay3	
			
			;get random number using clock ticking				
			xor ah,ah
			int 1Ah
			
			;calculate offset of random col beginning
			mov ax,dx
			xor dx,dx
			mov bx,9
			div bx
			
			;change offset according to row and col beginning
			add si,dx
			add di,dx
			
			cmp byte ptr [si],'!'
			je SaveNum
			
			xor ah,ah
			int 1Ah
				
			mov cx,dx
			delay5:
				nop
			loop delay5
			
			pop ax
			
			pop di
			pop si
			pop cx
			
			jmp SetNumber
			
			SaveNum:
			pop ax
			
			;set current number
			mov byte ptr [si],al
			mov byte ptr [di],1
			
			inc ax
			
			pop di
			pop si
			pop cx
	loop SetNumber
	
	;exit procedure
	ret
Place endp

View proc
	;assign offset table beginning
	lea si,table

	;move cursor first cell
	mov ah,2
	mov bh,0
	mov dh,1
	mov dl,1
	int 10h

	;table rows
    mov cx,9
    row:
        push cx
    
		;table cols
        mov cx,9
        col:
			push cx
        
			;get current digit
			mov ah,9
			mov al,byte ptr [si]
			
			;check for digit absence
			cmp al,'!'
			je ChgColCur
			
			;output digit into current cell
			or al,30h
			mov bh,0
			mov bl,47h
			mov cx,1
			int 10h
			
			ChgColCur:
			;move cursor to next cell in current row
			mov ah,2
			mov bh,0
			add dl,2
			int 10h
			
			;move offset to new digit in table
			inc si
			
			pop cx
        loop col
        
        ;move cursor to next row
        mov ah,2
        mov bh,0
        add dh,2
        mov dl,1
        int 10h
    
        pop cx
    loop row
    
    ;set cursor to begin
    mov ah,2
	mov bh,0
	mov dh,1
	mov dl,1
	int 10h
    
    ;exit procedure
    ret
View endp

Check proc
	push si
	push di
	
	mov fwin,0

	lea si,table
	mov cx,81
	Emptiness:
		cmp byte ptr [si],'!'
		jne next
		
		mov fwin,1
		
		jmp ExitCheck
		
		next:
		inc si
	loop Emptiness
	
	lea si,table
	lea di,table
	mov cx,9
	SameInRow:
		push cx
		push si
		push di
				
		inc di
		mov cx,8
		RowItem:
		mov al,byte ptr [si]
				
		push cx
		push si
		push di
		
		repne scasb
		je PresentInRow
		
		AbsentInRow:
		pop di
		pop si
		pop cx
		
		inc si
		inc di
		dec cx
		
		jcxz NextRow
		
		jmp RowItem
				
		PresentInRow:
		pop di
		pop si
		pop cx
		
		mov fwin,1
		
		pop di
		pop si
		pop cx
		
		jmp ExitCheck
		
		NextRow:
		pop di
		pop si
		
		add di,9
		add si,9
	
		pop cx
	loop SameInRow
	
	lea si,table
	lea di,table
	mov cx,9
	SameInCol:
		push cx
		push si
		push di
				
		add di,9
		mov cx,8
		ItemInCol:
		mov al,byte ptr [si]
				
		push cx
		push si
		push di
		
		StepInCol:
			cmp al,byte ptr [di]
			jne NextStep
			
			jmp PresentInCol
			
			NextStep:
			add di,9
		loop StepInCol
		
		AbsentInCol:
		pop di
		pop si
		pop cx
		
		add si,9
		add di,9
		dec cx
		
		jcxz NextCol
		
		jmp ItemInCol
				
		PresentInCol:
		pop di
		pop si
		pop cx
		
		mov fwin,1
		
		pop di
		pop si
		pop cx
		
		jmp ExitCheck
		
		NextCol:
		pop di
		pop si
		
		inc di
		inc si
	
		pop cx
	loop SameInCol
		
	ExitCheck:
	pop di
	pop si
	
	ret
Check endp

Press proc
	;assign begin offsets
	lea si,table
	lea di,bit

	GetKey:
	;waiting a key press
	mov ah,0
	int 16h
	
	ChkQuit:
	cmp al,'q'
	jne ChkDel
	
	mov fwin,1
	
	jmp FinKey
	
	ChkDel:
	cmp al,'d'
	jne NewGame 
	
	jmp Delete
	
	NewGame:
	;cmp al,'n'
	;je Start

	ChkUp:
	;checking key up press
    cmp ah,48h
    jne ChkLeft
    
    jmp up

	ChkLeft:
    ;checking key left press
    cmp ah,4Bh
    jne ChkRight
    
    jmp left

	ChkRight:
    ;checking key right press
    cmp ah,4Dh
    jne ChkDown
    
    jmp right

	ChkDown:
    ;checking key down press
    cmp ah,50h
    jne ChkDigit
    
    jmp down
    
    ChkDigit:
    ;checking digit key
    cmp al,'1'
    jb GetKey
    cmp al,'9'
    ja GetKey
    
    ;remember pressed digit
    mov bl,al
    
    ;read symbol in current cursor position
    mov ah,8
    mov bh,0
    int 10h
    
    ;check if cell is empty
    cmp al,' '
    jne GetKey
        
    push dx
    
    ;calculate current position in table
    sub dh,1
    shr dh,1
    
    sub dl,1
    shr dl,1
    
    mov al,9
    mul dh
    
    add al,dl
    adc ah,0
    
    pop dx
    
    push bx
    
    mov cl,bl
    sub cl,30h
    
    ;save current table position
    mov bx,ax
    
    ;set digit into current table position
    mov byte ptr [si+bx],cl
    
    pop bx
    
    ;if cell is empty, then display digit in current cell
    mov ah,9
    mov al,bl
    mov bh,0
    mov bl,40h
    mov cx,1
    int 10h
    
    call Check
    
    cmp fwin,0
    jne AnyErr
    
    jmp FinKey 
    
    AnyErr:
    jmp GetKey
    
    up:
    ;check up limit
    cmp dh,1
    jne UpFree
    
    jmp GetKey
    
    UpFree:
    ;move cursor up
    mov ah,2
    mov bh,0    
    sub dh,2
    int 10h
    
    jmp GetKey
        
    down:
    ;check down limit
    cmp dh,17
    jne DownFree
    
    jmp GetKey
    
    DownFree:
    ;move cursor down
    mov ah,2
    mov bh,0    
    add dh,2
    int 10h
    
    jmp GetKey
    
    left:
    ;check left limit
    cmp dl,1
    jne LeftFree
    
    jmp GetKey
    
    LeftFree:
    ;move cursor left
    mov ah,2
    mov bh,0    
    sub dl,2
    int 10h
    
    jmp GetKey
    
    right:
    ;check right limit
    cmp dl,17
    jne RightFree
    
    jmp GetKey
    
    RightFree:
    ;move cursor right
    mov ah,2
    mov bh,0    
    add dl,2
    int 10h
    
    jmp GetKey
    
    Delete:
    push dx
    
    ;calculate current position in bitmask
    sub dh,1
    shr dh,1
    
    sub dl,1
    shr dl,1
    
    mov al,9
    mul dh
    
    add al,dl
    adc ah,0
    
    pop dx
    
    ;save position in bitmask
    mov bx,ax
    
    ;check cell access in bitmask
    cmp byte ptr [di+bx],1
    jne DelNum
    
    jmp GetKey
    
    DelNum:
    mov byte ptr [si+bx],'!'
    
    ;display cleared cell
    mov ah,9
    mov al,' '
    mov bh,0
    mov bl,47h
    mov cx,1
    int 10h
    
    jmp GetKey    

	FinKey:
	ret
Press endp

Winner proc
	;set start cursor position
	mov ah,2
	mov bh,0
	mov dh,20
	mov dl,1
	int 10h
	
	lea si,text
	mov cx,16
	abc:
		push cx
	
		;write current letter
		mov ah,9
		mov al,byte ptr [si]
		mov bh,0
		mov bl,47h
		mov cx,1
		int 10h
		
		;move cursor position
		mov ah,2
		mov bh,0
		inc dl
		int 10h
		
		inc si
		
		pop cx
	loop abc
	
	;hide cursor
	mov ah,2
	mov bh,0
	mov dh,25
	mov dl,80
	int 10h
	
	ret
Winner endp  
end start
