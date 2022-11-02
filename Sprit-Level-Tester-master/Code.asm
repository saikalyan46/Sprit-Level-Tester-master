.model tiny
.data

;_______________________________
; assigning address for counters
; ------------------------------
count1 		db	 3
count2 		dw 	 0
count3		dw	 0
flag 		db	 0
seed 		dw 	 0deafh,0abbah,9876h,0fafah,8e34h,3847h,9218h,0fadeh

;-------------------------
; Actual and entered word
; -----------------------

randomdata 		db	 12	 dup(0)
inputs 			db 	 12 dup(0)
random			dw 	 0

;-------------------------------
;assigning port addresses 8255-1
; -------------------------------
porta 		equ 	10h
portb 		equ 	12h
portc 		equ 	14h
creg 		equ 	16h

; ___________________________________
; assigning port addresses for 8255-2
; -----------------------------------

porta2 		equ 20h
portb2 		equ 22h
portc2 		equ 24h
creg2 		equ 26h
	
table_keys  db        0eeh,0edh,0ebh,0e7h
			db		  0deh,0ddh,0dbh,0d7h
			db		  0beh,0bdh,0bbh,0b7h
			db 		  07eh,07dh,07bh,077h

; --------------------------------------
; CODE 
; --------------------------------------

.code
.startup
		call port_initialization
		call port2_initialization
		call lcd_initialization

try:	;Attempts Left=Count1
		dec count1
		
		lea si,seed
		add si,count2
		mov dx,[si]
		add count2,2
		
		;generating random string length
		call random_integer
		
		mov cx,[random]
		
		lea si,seed                                                       
		add si,count2
		mov dx,[si]
		add count2,2                                                        
		
		call random_string
		call write_pattern
		call delay
		call delay_2000
		call cls
		
		call keypad_interface	
		
		call comparison
		cmp flag,1
		jz reactiontime
		
		cmp count1,0
		jnz try

		;if reaches here then he/she is drunk.

      	;call buzzer
		mov al,00000001b
		out porta2,al
		mov al,00000001b
		out portb2,al
		call cls
		call write_d
		call delay_2000
		call cls
		jmp eop	

reactiontime: 

	
		mov al,00000001b
		out portb2,al


		call write_nd
		call cls

		;display reaction time on lcd
		call delay_2000
		call delay_2000
		call delay_2000
		call delay_2000
		call delay_2000

eop:

.exit

;------------------------------
;Initialising port 1 and port 2
;-------------------------------

; port 1

port_initialization proc near
	
	mov al,10001000b
	out creg,al
	
	ret

port_initialization endp

; port 2

port2_initialization proc near

	mov al,10000000b
	out creg2,al

	mov al,00000000b
	out porta2,al

	mov al,00000000b
	out portb2,al
	
	ret
port2_initialization endp

; -------------------------------
; Delay Functions
; -------------------------------

;delay in the circuit here the delay of 20 millisecond is produced

delay proc
		mov cx, 1325 ;1325*15.085 usec = 20 msec

	w1: nop
		nop
		nop
		nop
		nop
	
		loop w1
		
		ret

delay endp

;delay in the circuit here the delay of 2000 millisecond is 

delay_2000 proc
	
		mov cx,2220
	t1: loop t1
	
		ret

delay_2000 endp

;-----------------------------
;Input from Keyboard
;------------------------------

keypad_interface proc near

		mov al,00000001b
		out portb2,al
		
		; counter 3 used for randomized counter can hold any initial value

		mov cx,12
		lea di,inputs
		mov al,00h

cl0:	stosb
		loop cl0

		mov	al,0
		lea di,count3
		stosb

		mov al,88h
		out creg,al

		mov al,0ffh
		out portb,al

		; control word for counter0-mode2
		; control word for counter 1- mode2
		; control word for counter2 - mode0
		; loading words to counters
		; -------------------------
		; cascaded counter 0 and 1 count till 2 seconds
		; input frequency to clock = 5 MHZ
		; output frequency = 0.5HZ
		; therefore counter 0 loaded with 10000 = 2710h and counter1 with 1000 = 03E8	
		; to give final N factor of 10^(7) thus reducing frequency to 0.5 hz
		; --------------------------------------------------------------------------

x0: 	mov al,00h
	    out portc,al

x1:     in  al, portc

		and al,0f0h
		cmp al,0f0h
		jnz x1

		call d20ms

		mov al,00h
		out portc ,al

x2:     in al, portc
		and al,0f0h
		cmp al,0f0h
		jz x2

		call d20ms

		mov al,00h
		out portc ,al

		in al, portc

		and al,0f0h
		cmp al,0f0h
		jz x2

		mov al, 0eh
		mov bl,al
		out portc,al

		in al,portc

		and al,0f0h
		cmp al,0f0h
		jnz x3

		mov al, 0dh
		mov bl,al
		out portc ,al

		in al,portc

		and al,0f0h
		cmp al,0f0h
		jnz x3

		mov al, 0bh
		mov bl,al
		out portc,al

		in al,portc

		and al,0f0h
		cmp al,0f0h
		jnz x3

		mov al, 07h
		mov bl,al
		out portc,al

		in al,portc

		and al,0f0h
		cmp al,0f0h
		jz x2

x3:     or al,bl
		mov cx,0fh
		mov di,00h

x4:     cmp al,table_keys[di]
		jz x5

		inc di
		loop x4

x5:		mov ax,di
		and ax,000ffh

		cmp al,0ah
		jae atofkey

		add al,48
		jmp display

atofkey:
		add al,55
		jmp display

display:
		lea di,inputs
		add di,count3
		stosb
		
		mov al,[di-1]
		
		call datwrit
		
		inc count3

		mov bx,count3
		cmp bx,random
		jz donewithinput
		
		jmp x0

d20ms:  ;delay generated will be approx 0.45 secs
		mov cx,220

xn:     loop xn

donewithinput:
		mov al,00000000b
		out portb2,al
	
	ret

keypad_interface endp


comparison proc near

		lea si,randomdata
		lea di,inputs
		mov cx,random

c1:		mov al,[si]
		mov bl,[di]
		cmp al,bl
		jnz eoproc
		
		inc si
		inc di
		loop c1
		
		mov flag,1

eoproc:
		ret

comparison endp

;-------------------------
;Random Generatoor
;-------------------------


;random no generator, value of 'n' is in cx, dx value should also be initialized with a different seed everytime

random_integer proc
	
	lea di,random
	mov ax,dx
	mov bx,31
	mul bx
	
	add ax,13
	mov bx,19683
	div bx
	mov ax,dx
	
	mov cl,07h
	and ax,00ffh
	div cl
	
	mov al,ah
	add al,6
	
	stosb
	ret

random_integer endp
	


random_string proc
	
		mov cx,random
		lea di,randomdata

r1:		mov ax,dx
		mov bx,31
		mul bx
		add ax,13
		mov bx,19683
		div bx
	
		mov bx,dx
		and bx,000fh
		mov al,bl
	
		cmp al,0ah
		jae atof
	
		add al,48
		jmp store

atof: 	add al,55

store:	stosb	
		loop r1

	ret

random_string endp

;---------------------------------------
;LCD Functions
;---------------------------------------

;Initialise

lcd_initialization proc near
	
	mov al, 38h 			;initialize lcd for 2 lines & 5*7 matrix
	
	call comndwrt 			;write the command to lcd
	call delay 				;wait before issuing the next command
	call delay 				;this command needs lots of delay
	call delay
	
	mov al, 0eh 			;send command for lcd on, cursor on	
	
	call comndwrt
	call delay
	
	mov al, 01  			;clear lcd
	
	call comndwrt	
	call delay
	
	mov al, 06  			;command for shifting cursor right
	
	call comndwrt
	call delay
	
	ret

lcd_initialization endp

; Clear 

cls proc 
	mov al, 01  				
	
	call comndwrt
	call delay
	call delay
	
	ret

cls endp

; Writing a command

comndwrt proc 					
	
	mov dx, porta
	out dx, al  				;send the code to port a
	
	mov dx, portb 	
	mov al, 00000100b 			;rs=0,r/w=0,e=1 for h-to-l pulse
	out dx, al
	
	nop
	nop	
	
	mov al, 00000000b 			;rs=0,r/w=0,e=0 for h-to-l pulse
	out dx, al
	
	ret

comndwrt endp	

; Write drunk

write_d proc near
	
	call cls
	
	mov al, 'd' 			
	call datwrit 
	call delay 
	call delay 
	
	mov al, 'r' 
	call datwrit 
	call delay 
	call delay 
	
	mov al, 'u' 
	call datwrit 
	call delay 
	call delay 
	
	mov al, 'n' 
	call datwrit 
	call delay 
	call delay 
	
	mov al, 'k' 
	call datwrit 
	call delay 
	call delay 
	
	ret

write_d endp

; Write not drunk

write_nd proc near
	call cls
	mov al, 'n' 
	call datwrit 
	call delay 
	call delay

	mov al, 'o' 
	call datwrit 
	call delay 
	call delay

	mov al, 't' 
	call datwrit 
	call delay 
	call delay

	mov al, 'd' 
	call datwrit 
	call delay 
	call delay

	mov al, 'r' 
	call datwrit 
	call delay 
	call delay 

	mov al, 'u' 
	call datwrit 
	call delay 
	call delay

	mov al, 'n' 
	call datwrit 
	call delay 
	call delay

	mov al, 'k' 
	call datwrit 
	call delay 
	call delay 
	
	ret

write_nd endp

; ---------------------------------
; Other Functions
; ---------------------------------
	
write_pattern proc near 
	
		lea di,randomdata
		call cls

		mov cx,random
		mov si,cx

x10:	mov al, [di] 
		
		call datwrit 
		call delay 
		call delay 
	
		inc di
		dec si
	
		jnz x10
	
	ret

write_pattern endp


datwrit proc
	
	push dx  				;save dx
	
	mov dx,porta  			;dx=port a address
	out dx, al 				;issue the char to lcd
	
	mov al, 00000101b 		;rs=1, r/w=0, e=1 for h-to-l pulse
	mov dx, portb 			;port b address
	out dx, al  			;make enable high
	
	mov al, 00000001b 		;rs=1,r/w=0 and e=0 for h-to-l pulse
	out dx, al
	
	pop dx
	
	ret

datwrit endp ;writing on the lcd ends 


end