;********************************************
;*											*
;*  Universidad Tecnológica de la Mixteca	*
;*  Ingeniería en Computación				*
;*  Grupo 602-A								*
;*  Proyecto final de Lenguaje Ensamblador  *
;*  Editor hexadecima "Hexed"				*
;*  Hecho por Carlos Hernández Montellano   *
;*											*
;********************************************
.model small
.386
extrn desdec:near
extrn des2:near
extrn des4:near
extrn reto:near
extrn spc:near
extrn leedec:near
extrn lee1:near
extrn lee2:near
extrn lee4:near
extrn c
.stack
.data
narchivo	db		"archivo.txt", 0h
buffer		db		0ffh dup(?)
fid 		dw		?
sizer		dw		?	;Tamaño de bytes leidos del archivo [0 - FFh]
;Mensajes para el usuario
cabecera	db		"Pos  00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 0123456789ABCDEF", 0Ah, 0Dh, 24h
cad1		db		"Introduzca la posicion del valor que desee cambiar. Ej 0001, 00A1:", 0Ah, 0Dh, 24h
cad2		db		"Usted ha elejido cambiar el valor $:"
cad3		db		"Introduzca el nuevo valor. Ej 41, A0, FF, 01:", 0Ah, 0Dh, 24h
cad4		db		"Bienvenido a Hexed, hecho por Carlos Hernandez Montellano.", 0Ah, 0Dh, "Elija una de las siguientes opciones:", 0Ah, 0Dh, "0. Modificar un valor" , 0Ah, 0Dh, "1. Mostrar contenido hexadecimal" , 0Ah, 0Dh, "2. Guardar archivo", 0Ah, 0Dh, "3. Salir del programa", 24h
cad5		db		0Ah, 0Dh, "Se ha guardado el archivo correctamente.", 24h
position	dw		?	;Aqui se guarda la posicion que se elijio para modificar
caderr		db		"Hubo un error al intentar abrir, guardar o cerrar el archivo 'archivo.txt'." , 0Ah, 0Dh, "Codigo de error: $" 
.code

main:	mov ax, @data
		mov ds, ax
		mov es, ax
		
		mov ah, 3Dh
		mov al, 2	;Lectura y escritura
		mov dx, offset narchivo
		int 21h
		jc error
		mov fid, ax
		mov ah, 3Fh
		mov bx, fid
		mov cx, 0ffh
		mov dx, offset buffer
		int 21h
		jc error
		mov [sizer], ax ;Guardar bytes leidos [0 - FFh]
u_des:	mov cx, [sizer] ;Recuperar bytes leidos desde variable. Cuando el usario decide desplegar, empieza desde aqui
		;Se imprime cabecera
		mov ah, 09
		mov dx, offset cabecera
		int 21h
		call reto
		mov bl, 0 ;Contador de renglones
		mov bh, 0 ;Contador de indice
		mov dx, 0
		call des4
		call spc
		cld
		mov si, offset buffer
h_des1:	lodsb
		mov dl, al
		call des2
		mov dl, ' '
		mov ah, 02
		int 21h
		inc bl
		inc bh
		cmp bl, 16
		je h_resbl
h_rloop:loop h_des1
		cmp bl, 0
		je exit
		;Ultima impresion ascii, se dan los espacios necesarios para que este se despliegue correctamente
		mov ch, 0
		mov bh, 16
		sub bh, bl
		mov al, bh
		mov bh, 03
		mul bh
		mov cl, al
h_spclp:call spc
		loop h_spclp
		mov dx, si
		mov bh, 0
		sub dx, bx
		call ascii
		
		;Aqui empieza interaccion con el usuario
u_menu:	call reto
		call reto
		mov ah, 09h
		mov dx, offset cad4
		int 21h
		call reto
		call lee1
		call reto
		cmp al, 0
		jne u_nomod
		call modify
u_nomod:cmp al, 1
		je u_des
		cmp al, 2
		jne u_nosav
		call save
		call save
		mov ah, 09
		mov dx, offset cad5
		int 21h
u_nosav:cmp al, 3
		je exit
		jmp u_menu ;Si no se elijio salir del programa, se vuelve a mostrar el menu
		;Cerrar archívo
exit:	mov ah, 3Eh
		mov bx, fid
		int 21h
		jc error
		.exit 0
		
error:	mov ah, 09
		mov dx, offset caderr
		int 21h
		mov ah, 0
		mov dx, ax
		call des4
		.exit 1
		
h_resbl:mov dx, si
		sub dx, 10h
		call ascii
		call reto
		mov bl, 0
		mov dx, si
		sub dx, offset buffer
		call des4
		call spc
		jmp h_rloop
		
		;Despliega caracteres ASCII o si no un '.', Rango [21h ~ 7Eh]
		;Recibe dirección inicial en DX
ascii:	pusha
		mov ch, 0
		mov cl, bl
		mov si, dx
		cld
		mov ah, 02
ascloop:lodsb
		cmp al, 21h
		jl aprintp
		cmp al, 7eh
		jg aprintp
		mov dl, al
		int 21h
		jmp asiglp
aprintp:mov dl, '.'
		int 21h
asiglp:	loop ascloop
ascex:	popa
		ret
		
;Funcion para modificar un valor del buffer
modify:	pusha
		mov ah, 09h	;Se le pidel al usuario la posición
		mov dx, offset cad1
		int 21h
		call lee4 ;Se lee la posición que ingresó el usuario
		mov [position], ax
		mov ah, 02
		mov dl, 0Ah
		int 21h
		mov dl, 0Dh
		int 21h
		mov bx, offset buffer
		add bx, [position]
		mov [position], bx ;Se guarda la posición absoluta en memoria
		mov dx, offset cad2 
		mov ah, 09
		int 21h
		mov dx, [bx]
		call des2 ; Se le notifica al usuario el valor de esa posición
		call reto
		mov dx, offset cad3 ; Se le pide al usuario que ingrese el nuevo valor
		int 21h
		call lee2
		cld
		mov di, [position]
		stosb ;Se copia el nuevo valor dentro del bufer. No se guarda en archivo
		mov ah, 02
		mov dl, 0Ah
		int 21h
		mov dl, 0Dh
		int 21h
		popa
		ret
;Funcion que se encarga de guardar el buffer en el archivo.
save:	pusha
		mov ah, 42h ;Con este servicio se retorna al apuntador principio del
		mov al, 0h  ;archivo para que el apuntador sobreescriba el texto
		mov bx, fid
		mov cx, 0h
		mov dx, 0h
		int 21h
		mov ah, 40h ;Se utiliza el archivo de escritura
		mov bx, fid
		mov cx, [sizer] ;Se indica el tamaño del buffer
		mov dx, offset buffer ;Se indica la dirección del buffer
		int 21h
		jc error ;Si hay error, se despliega mensaje de error y aborta el programa
		popa
		ret
	
end
