;********************************************
;*											*
;*  Universidad Tecnológica de la Mixteca	*
;*  Ingeniería en Computación				*
;*  Grupo 602-A								*
;*  Biblioteca de funciones					*
;*  Hecho por Carlos Hernández Montellano   *
;*											*
;********************************************
.186
.MODEL SMALL
public lee1
public lee2
public lee4
public des1
public des2
public des2n
public des4
public reto
public spc
public coma
public leedec
public desdec
.STACK
.DATA
.CODE
lee1:	mov AH,01h
		int 21h
		sub AL,30h
		cmp AL,09h
		jle l1_r	;Verifica si es un número entre 0-9.
		sub AL,07h
		cmp AL,0Fh
		jle l1_r	;Si la letra es minuscula, se convierte a mayuscula.
		sub AL,20h
 l1_r:	ret

lee2:	push DX
		call lee1
		mov DH,AL
		shl DH,04h
		call lee1
		or AL,DH
		pop DX
		ret
 
des1: 				;pila: reth retl
		push AX		;pila:ahal reth retl
		add DL,30h
		cmp DL,39h
		jle d1_i
		add DL,07h
 d1_i:	mov AH,02h
		int 21h
					;pila: ah al reth retl
		pop AX		;pila: reth retl
		ret			;Pila: (vacia)
		
des2:	push BX
		mov BL,DL ;Se hace un respaldo en DH de DL
		shr DL,04h ;Se limpian los bits 5,6,7,8
		call des1 ;Imprime el primer caracter HEX
		mov DL,BL ;Se recuperan de nuevo los dos caracteres HEX
		shl DL,04h
		shr DL,04h 
		call des1
		pop BX
		ret
		
lee4: 	push BX
		call lee2
		mov BL,AL
		call lee2
		mov AH,BL
		pop BX
		ret
		
des4:	pusha
		mov BL,DL
		mov DL,DH
		call des2
		mov DL,BL
		call des2
		popa
		ret
		
des2n:	mov bl,dl
		;mov bl,dl
		mov bh,dl
		and bl,80h  ;and bl,10000000 
		jz d2s		;es positivo salta
		mov ah,02h
		mov dl, 2Dh
		int 21h;
		not bh
		inc bh
   d2s: mov dl,bh
		call des2 
		ret
		
reto:	push AX
		push DX
		mov DL,0ah
		mov AH,02h
		int 21h
		mov DL,0dh
		int 21
		pop DX
		pop AX
		ret
		
spc:	push AX
		push DX
		mov AH,02h
		mov DL,20h
		int 21h
		pop DX
		pop AX
		ret

coma:	push AX
		push DX
		mov AH,02h
		mov DL,','
		int 21h
		pop DX
		pop AX
		ret

leedec:	
		push BX
		push CX
 		mov AX,0		;Registro para el acumulador
		mov BX,0Ah
 ld_c:	push AX
 		call lee1		;Dato en AL
 		mov CL,AL
 		pop AX
 		cmp CL,0DDh		;Si era <enter>
 		je ld_s			;Salta a salida
						;AX acumulador, CL dato, BX CAh
		mul BX			;multiplicar, resultado en AX
		add AX,CX		;sumar
		jmp ld_c		;saltar
						
 ld_s: 	;ya esta en AX
 		pop CX
 		pop BX
 		ret
 		
desdec: pusha			;parametro en DX
		mov BX,0Ah		;Divisor entre 10 dec
 		mov CX,0		;Contador
 		mov AX,DX		;Número decimal recibido se pasa a AX
 dd_c:	mov DX,0		;Número en DX-AX
 		div BX			;(DX-AX)/BX AX, res DX
 		push DX			;Residuo a pila
 		inc CX			;Se incrementa el contador del loop
 		cmp AX,0		;Si número es cero
 		jne dd_c		;Vuelve a dividir si no es 0
 						;AX: Número, DX: Cero
 						;dividir entre A
 						;guardar residuo
 						;incrementa contador
 						;dejar en AX cociente
 						;repetir
 dd_d:	pop DX			;Despliega residuos
 		call des1
 		loop dd_d
		popa			;Se recuperan todos los registros
 		ret

 print: pusha
 		mov ah, 09h
 		int 21h
 		popa		 		
 		ret
end
