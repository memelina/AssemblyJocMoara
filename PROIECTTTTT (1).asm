.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 900
area_height EQU 700
area DD 0
careu dd 0,0,0,0,0,0,0,0,0
counter DD 0 ; numara evenimentele de tip timer
counter_ok DD 0
ball_x dw 67
ball_y dw 64

player_move DB 0
oprire dd 0
buttonfolosit dd 0

v1 dd 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mori_verif DB 0 DUP(16)

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
bgcolor equ  0EEB587h


symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

button_x equ 38
button_y equ 68
button_size equ 20

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters

draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0EEB587h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret 

make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
fundal macro x,y,len,color
local bucla_linie
    mov eax, y
	mov ebx, area_height
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
	mov ecx,len

bucla_linie:
     mov dword ptr[eax],color
	 add eax,4
	 loop bucla_linie

endm

patrat_v macro x,y,len,color

	line_v x+1, y, len, color
	line_v x+2, y, len, color
	line_v x+3, y, len, color
	line_v x+4, y, len, color
	line_v x+5, y, len, color
	line_v x+6, y, len, color
	line_v x+7, y, len, color
	line_v x+8, y, len, color
	line_v x+9, y, len, color
	line_v x+10, y, len, color
	line_v x+11, y, len, color
	line_v x+12, y, len, color
	line_v x+13, y, len, color
	line_v x+14, y, len, color
	line_v x+15, y, len, color
	line_v x+16, y, len, color
	line_v x+17, y, len, color
	line_v x+18, y, len, color
	line_v x+19, y, len, color
	line_v x+20, y, len, color
endm



line_h macro x,y,len,color
local bucla_linie
    mov eax, y
	mov ebx, area_width
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
	mov ecx,len
bucla_linie:
     mov dword ptr[eax],color
	 add eax,4
	 loop bucla_linie



endm
line_v macro x,y,len,color
local bucla_linie
    mov eax, y
	mov ebx, area_width
    mul ebx
    add eax, x
    shl eax,2
    add eax, area
	mov ecx,len
bucla_linie:
     mov dword ptr[eax],color
     add eax, area_width*4
	 loop bucla_linie
endm

click macro x,y,len ;functie care determina cand da click primul jucator
local final_click

	
    mov eax, [ebp+arg2]
	cmp eax, x
	jl final_click
	cmp eax, x+len
	jg final_click
	mov eax, [ebp+arg3]
	cmp eax, y
	jl final_click
	cmp eax, y+len
	jg final_click
	
	;s-a dat click in buton_x
    patrat_v x, y, len, 0EE6565h
	afisare_turn1 ;se afiseaza pentru player2 "your turn" dupa ce player1 a dat click
  
    

	
	mov player_move, 1 ;dupa ce player1 a dat click punem in variabila player_move 1 pentru a putea compara  in evt_click  randul carui jucator este
	
	
    final_click:
 
   
endm

click2 macro x,y,len ;functie care determina cand da click player2
local final_click2
	
    mov eax, [ebp+arg2]
	cmp eax, x
	jl final_click2
	cmp eax, x+len
	jg final_click2
	mov eax, [ebp+arg3]
	cmp eax, y
	jl final_click2
	cmp eax, y+len
	jg final_click2
	
	;s-a dat click in buton_x
    patrat_v x, y, len, 06D65EEh
	afisare_turn2  ;afisare "your turn" pt  player1 

	mov player_move, 0 ; cand in player_move este 0 stim ca a dat click si urmeaza player1
	;mov counter_ok, 0
    add oprire,1 ; crestem acest counter de 9 ori pentru a se opri cand se pun cele 18 piese
	
   
	
    final_click2:


endm

click_first macro ;de aici primul jucator poate alege orice patrat pentru a da click verificandu se in evt_click daca patratul e liber sau nu
  
  ;verificam daca patratl este dja colorat 
  
	 
	click button_x, button_y, button_size
	click button_x+240, button_y, button_size
	click button_x+480, button_y, button_size	
	click button_x+480, button_y+240, button_size 
	click button_x+480, button_y+480, button_size 
	click button_x, button_y+480, button_size 
	click button_x+240, button_y+480, button_size 
	click button_x, button_y+480, button_size
	click button_x, button_y+240, button_size 
	
	click button_x+80, button_y+80, button_size 
	click button_x+240, button_y+80, button_size 
	click button_x+400, button_y+80, button_size 
	click button_x+400, button_y+240, button_size 
	click button_x+400, button_y+400, button_size 
	click button_x+240, button_y+400, button_size 
    click button_x+80, button_y+400, button_size
    click button_x+80, button_y+240, button_size 
    click button_x+160, button_y+160, button_size 
    click button_x+240, button_y+160, button_size 
    click button_x+320, button_y+160, button_size 
    click button_x+320, button_y+240, button_size 
    click button_x+320, button_y+320, button_size 
    click button_x+240, button_y+320, button_size 
	click button_x+160, button_y+320, button_size 
    click button_x+160, button_y+240, button_size 
endm

click_next  macro
  
	click2 button_x, button_y, button_size
	click2 button_x+240, button_y, button_size
	click2 button_x+480, button_y, button_size 
	click2 button_x+480, button_y+240, button_size 
	click2 button_x+480, button_y+480, button_size 
	click2 button_x, button_y+480, button_size 
	click2 button_x+240, button_y+480, button_size 
	click2 button_x, button_y+480, button_size
	click2 button_x, button_y+240, button_size 
	
	click2 button_x+80, button_y+80, button_size 
	click2 button_x+240, button_y+80, button_size 
	click2 button_x+400, button_y+80, button_size 
	click2 button_x+400, button_y+240, button_size 
	click2 button_x+400, button_y+400, button_size 
	click2 button_x+240, button_y+400, button_size 
    click2 button_x+80, button_y+400, button_size
    click2 button_x+80, button_y+240, button_size 
    click2 button_x+160, button_y+160, button_size 
    click2 button_x+240, button_y+160, button_size 
    click2 button_x+320, button_y+160, button_size 
    click2 button_x+320, button_y+240, button_size 
    click2 button_x+320, button_y+320, button_size 
    click2 button_x+240, button_y+320, button_size 
	click2 button_x+160, button_y+320, button_size 
    click2 button_x+160, button_y+240, button_size
endm
afisare_turn2 macro

    make_text_macro ' ', area, 730, 350
	make_text_macro ' ', area, 740, 350
	make_text_macro ' ', area, 750, 350
	make_text_macro ' ', area, 760, 350
	make_text_macro ' ', area, 780, 350
	make_text_macro ' ', area, 790, 350
	make_text_macro ' ', area, 800, 350
	make_text_macro ' ', area, 810, 350
	
	make_text_macro 'Y', area, 610, 350
	make_text_macro 'O', area, 620, 350
	make_text_macro 'U', area, 630, 350
	make_text_macro 'R', area, 640, 350
	make_text_macro 'T', area, 660, 350
	make_text_macro 'U', area, 670, 350
	make_text_macro 'R', area, 680, 350
	make_text_macro 'N', area, 690, 350 
endm	
afisare_turn1 macro
    make_text_macro ' ', area, 610, 350
	make_text_macro ' ', area, 620, 350
	make_text_macro ' ', area, 630, 350
	make_text_macro ' ', area, 640, 350
	make_text_macro ' ', area, 660, 350
	make_text_macro ' ', area, 670, 350
	make_text_macro ' ', area, 680, 350
	make_text_macro ' ', area, 690, 350
	
	make_text_macro 'Y', area, 730, 350
	make_text_macro 'O', area, 740, 350
	make_text_macro 'U', area, 750, 350
	make_text_macro 'R', area, 760, 350
	make_text_macro 'T', area, 780, 350
	make_text_macro 'U', area, 790, 350
	make_text_macro 'R', area, 800, 350
	make_text_macro 'N', area, 810, 350
endm

; primul_careu macro 
	; mov eax, button_y
	; mov ebx, area_width
	; mul ebx
	; add eax,button_x
	; shl eax,2
	; add eax, area
	; mov ecx, button_size
	; cmp dword ptr [eax], 0EE6565h
	; je next
	; next:
	; mov eax, button_y
	; mov ebx, area_width
	; mul ebx
	; add eax,button_x+240
	; shl eax,2
	; add eax, area
	; mov ecx, button_size
	; cmp dword ptr [eax], 0EE6565h
	; je next1
	; next1:
	; mov eax, button_y+240
	; mov ebx, area_width
	; mul ebx
	; add eax, button_x+480
	; shl eax,2
	; add eax, area
	; mov ecx,button_size
	; cmp dword ptr [eax], 0EE6565h
	; je moara
	
	; moara:
    ; patrat_v button_x, button_y,button_size, 0EEB587h
;endm

a_doua_linie_sus macro cul
local final, final_final

check_cul_patrat button_x+83, button_y+83, cul
cmp eax, 1
jne final
;bton are culoarea cul

check_cul_patrat button_x+243, button_y+83, cul
cmp eax, 1
jne final
;verificam al treilea patrat 
check_cul_patrat button_x+403, button_y+83, cul
cmp eax, 1
jne final
mov edx, 1
jmp final_final
final:
mov edx, 0
final_final:

endm

prima_linie_sus macro cul
local final, final_final
check_cul_patrat button_x+3, button_y+3, cul
cmp eax, 1
jne final
;bton are culoarea cul

check_cul_patrat button_x+243, button_y+3, cul
cmp eax, 1
jne final
;verificam al treilea patrat 
check_cul_patrat button_x+483, button_y+3, cul
cmp eax, 1
jne final
mov edx, 1
jmp final_final
final:
mov edx, 0
final_final:

endm

sterge_cul macro cul
local check_patrat1, check_patrat2, check_patrat3, check_patrat4, check_patrat5, check_patrat6, check_patrat7, check_patrat8, check_patrat9, check_patrat10, check_patrat11, check_patrat12, check_patrat13, check_patrat14, check_patrat15, check_patrat16, check_patrat17, check_patrat18, check_patrat19, check_patrat20, check_patrat21, check_patrat22, check_patrat23, check_patrat24, final 
;verificam fiecare patrat 
;patrat1

	check_cul_patrat button_x+3, button_y+3, cul
	cmp eax, 1
	jne check_patrat2
		;patrat este egal -- 1
		patrat_v button_x, button_y, button_size, 0FFFFFFh
		jmp final
	check_patrat2:
	check_cul_patrat button_x+243, button_y+3, cul
	cmp eax, 1
	jne check_patrat3
		;patrat este egal -- 2
		patrat_v button_x+240, button_y, button_size, 0FFFFFFh
		jmp final
	check_patrat3:
	check_cul_patrat button_x+483, button_y+3, cul
	cmp eax, 1
	jne check_patrat4
		;patrat este egal -- 3
		patrat_v button_x+480, button_y, button_size, 0FFFFFFh
		jmp final
	check_patrat4:
	check_cul_patrat button_x+83, button_y+83, cul
	cmp eax, 1
	jne check_patrat5
		;patrat este egal -- 4
		patrat_v button_x+80, button_y+80, button_size, 0FFFFFFh
		jmp final
	check_patrat5:
	check_cul_patrat button_x+243, button_y+83, cul
	cmp eax, 1
	jne check_patrat6
		;patrat este egal -- 5
		patrat_v button_x+240, button_y+80, button_size, 0FFFFFFh
		jmp final
	check_patrat6:
	check_cul_patrat button_x+403, button_y+83, cul
	cmp eax, 1
	jne check_patrat7
		;patrat este egal -- 6
		patrat_v button_x+400, button_y+80, button_size, 0FFFFFFh
		jmp final
	check_patrat7:
		check_cul_patrat button_x+163, button_y+163, cul
	cmp eax, 1
	jne check_patrat8
		;patrat este egal -- 7
		patrat_v button_x+160, button_y+160, button_size, 0FFFFFFh
		jmp final
	check_patrat8:
			check_cul_patrat button_x+243, button_y+163, cul
	cmp eax, 1
	jne check_patrat9
		;patrat este egal -- 8
		patrat_v button_x+240, button_y+160, button_size, 0FFFFFFh
		jmp final
	check_patrat9:
			check_cul_patrat button_x+323, button_y+163, cul
	cmp eax, 1
	jne check_patrat10
		;patrat este egal -- 9
		patrat_v button_x+320, button_y+160, button_size, 0FFFFFFh
		jmp final
	check_patrat10:
	 	check_cul_patrat button_x+3, button_y+243, cul
	cmp eax, 1
	jne check_patrat11
		;patrat este egal -- 10
		patrat_v button_x, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat11:
		 	check_cul_patrat button_x+83, button_y+243, cul
	cmp eax, 1
	jne check_patrat12
		;patrat este egal -- 11
		patrat_v button_x+80, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat12:
			 	check_cul_patrat button_x+83, button_y+243, cul
	cmp eax, 1
	jne check_patrat13
		;patrat este egal -- 12
		patrat_v button_x+160, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat13:
		 	check_cul_patrat button_x+323, button_y+243, cul
	cmp eax, 1
	jne check_patrat14
		;patrat este egal -- 13
		patrat_v button_x+320, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat14:
		 	check_cul_patrat button_x+403, button_y+243, cul
	cmp eax, 1
	jne check_patrat15
		;patrat este egal -- 14
		patrat_v button_x+400, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat15:
		check_cul_patrat button_x+483, button_y+243, cul
			cmp eax, 1
		jne check_patrat16
		;patrat este egal -- 15
		patrat_v button_x+480, button_y+240, button_size, 0FFFFFFh
		jmp final
	check_patrat16:
		check_cul_patrat button_x+163, button_y+323, cul
		cmp eax, 1
		jne check_patrat17
		;patrat este egal -- 16
		patrat_v button_x+160, button_y+320, button_size, 0FFFFFFh
		jmp final
	check_patrat17:
			check_cul_patrat button_x+243, button_y+323, cul
		cmp eax, 1
		jne check_patrat18
		;patrat este egal -- 17
		patrat_v button_x+240, button_y+320, button_size, 0FFFFFFh
		jmp final
	check_patrat18:
			check_cul_patrat button_x+323, button_y+323, cul
		cmp eax, 1
		jne check_patrat19
		;patrat este egal -- 18
		patrat_v button_x+320, button_y+320, button_size, 0FFFFFFh
		jmp final
	check_patrat19:
			check_cul_patrat button_x+83, button_y+403, cul
		cmp eax, 1
		jne check_patrat20
		;patrat este egal -- 19
		patrat_v button_x+80, button_y+400, button_size, 0FFFFFFh
		jmp final
	check_patrat20:
			check_cul_patrat button_x+243, button_y+403, cul
		cmp eax, 1
		jne check_patrat21
		;patrat este egal -- 20
		patrat_v button_x+240, button_y+400, button_size, 0FFFFFFh
		jmp final
	check_patrat21:
			check_cul_patrat button_x+403, button_y+403, cul
		cmp eax, 1
		jne check_patrat22
		;patrat este egal -- 21
		patrat_v button_x+400, button_y+400, button_size, 0FFFFFFh
		jmp final
	check_patrat22:
			check_cul_patrat button_x+3, button_y+483, cul
		cmp eax, 1
		jne check_patrat23
		;patrat este egal -- 22
		patrat_v button_x, button_y+480, button_size, 0FFFFFFh
		jmp final
	check_patrat23:
			check_cul_patrat button_x+243, button_y+483, cul
		cmp eax, 1
		jne check_patrat24
		;patrat este egal -- 23
		patrat_v button_x+240, button_y+480, button_size, 0FFFFFFh
		jmp final
	check_patrat24:
			check_cul_patrat button_x+483, button_y+483, cul
		cmp eax, 1
		jne final
		;patrat este egal -- 24
		patrat_v button_x+480, button_y+480, button_size, 0FFFFFFh

	final:
		


endm

check_cul_patrat macro x, y, cul
local not_eq, final

	xor edx, edx
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	cmp dword ptr [eax], cul
	jne not_eq
	mov eax, 1
	jmp final
	not_eq:
	mov eax, 0
	final:

endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x4
; arg3 - y

draw proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	fundal 0,0,area_width*area_height,0EEB587h
	jmp afisare_litere




evt_click:

	; mov eax, [ebp+arg3]
	; mov ebx, area_width
    ; mul ebx
    ; add eax, [ebp+arg2]
    ; shl eax,2
    ; add eax, area
    ; mov  dword ptr[eax],0FF00h
    ; mov dword ptr[eax+4],0FF00h
	; mov dword ptr[eax-4],0FF00h
	; mov dword ptr[eax+4*area_width],0FF00h
	; mov dword ptr[eax-4*area_width],0FF00h
	; mov eax, [ebp+arg2]
	; cmp eax, button_x3
	; jl button_fail
	; cmp eax, button_x +button_size
	; jg button_fail
	; mov eax, [ebp+arg3]
	; cmp eax, button_y
	; jl button_fail
	; cmp eax, button_Y + button_size
	; jg button_fail
	;s-a dat click in buton_x
    ; patrat button_x, button_y, button_size, 0
	; patrat button_x+240, button_y, button_size, 0
    ; mov counter_ok, 0
    ; jmp afisare_litere
	
	;coord matrice click

	
    
    mov eax, [ebp+arg3]
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg2]
	shl eax, 2
	
	add eax, area
	
	cmp dword ptr [eax], 0EEB587h ;aici se compara patratele cu culoarea fundalului si daca sunt diferite inseamna ca acolo a fost deja plasata o piesa
	jne player_over
	
	
	
	mov edx, 9 ; aici comparam oprire cu 9 pentru a se opri la 18 executand de 9 ori ambele culori de piese
	cmp edx, oprire
	je player_over
	cmp player_move, 0 ;daca nu dat click player2 atunc sare la player_next unde da click player1 altfel da click player2
	jne player_next
	;first player	
	click_first
	jmp player_over
	player_next:
	
	click_next
   
	player_over: 
	
 
  
    jmp afisare_litere
	
	
	
	
	
    ; button_fail:
    ; make_text_macro ' ', area, button_x + button_size/2-5, button_y + button_size + 10
    ; make_text_macro ' ', area, button_x + button_size/2+5, button_y + button_size + 10

    ; jmp afisare_litere
evt_timer:
	inc counter
    inc counter_ok
    ;cmp counter_ok, 15
    ;je evt_click
	

afisare_litere:
     

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10

	; scriem un mesaj
	; make_text_macro 'P', area, 110, 100
	; make_text_macro 'R', area, 120, 100
	; make_text_macro 'O', area, 130, 100
	; make_text_macro 'I', area, 140, 100
	; make_text_macro 'E', area, 150, 100
	; make_text_macro 'C', area, 160, 100
	; make_text_macro 'T', area, 170, 100

	; make_text_macro 'L', area, 130, 120
	; make_text_macro 'A', area, 140, 120

	; make_text_macro 'A', area, 100, 140
	; make_text_macro 'S', area, 110, 140
	; make_text_macro 'A', area, 120, 140
	; make_text_macro 'M', area, 130, 140
	; make_text_macro 'B', area, 140, 140
	; make_text_macro 'L', area, 150, 140
	; make_text_macro 'A', area, 160, 140
	; make_text_macro 'R', area, 170, 140
	; make_text_macro 'E', area, 180, 140

	

	;primul patrat din map
	
	
	
	
	 line_h button_x, button_y, button_size, 0
	 line_h button_x, button_y+button_size, button_size, 0
	 line_v button_x, button_y, button_size,0
	 line_v button_x+button_size, button_y, button_size,0
	 
	 line_h button_x+20, button_y+10, button_size+200, 0
   



	 line_h button_x+240, button_y, button_size, 0
	 line_h button_x+240, button_y+button_size, button_size, 0
	 line_v button_x+240, button_y, button_size,0
	 line_v button_x+button_size+240, button_y, button_size,0
	 line_h button_y+230, button_y+10, button_size+200, 0

	 line_h button_x+480, button_y, button_size, 0
	 line_h button_x+480, button_y+button_size, button_size, 0
	 line_v button_x+480, button_y, button_size,0
	 line_v button_x+button_size+480, button_y, button_size,0
	 line_v button_y+460, button_y+20, button_size+200,0
	 
	 

	 line_h button_x+480, button_y+240, button_size, 0
	 line_h button_x+480, button_y+button_size+240, button_size, 0
	 line_v button_x+480, button_y+240, button_size,0
	 line_v button_x+button_size+480, button_y+240, button_size,0
	 line_v button_x+490, button_y+260, button_size+200,0

	 line_h button_x+480, button_y+480, button_size, 0
	 line_h button_x+480, button_y+button_size+480, button_size, 0
	 line_v button_x+480, button_y+480, button_size,0
	 line_v button_x+button_size+480, button_y+480, button_size,0
	 line_h button_y+230, button_y+490, button_size+200, 0

	 line_h button_x+240, button_y+480, button_size, 0
	 line_h button_x+240, button_y+button_size+480, button_size, 0
	 line_v button_x+240, button_y+480, button_size,0
	 line_v button_x+button_size+240, button_y+480, button_size,0
	 line_h button_y-9, button_y+490, button_size+200, 0

	 line_h button_x, button_y+480, button_size, 0
	 line_h button_x, button_y+button_size+480, button_size, 0
	 line_v button_x, button_y+480, button_size,0
	 line_v button_x+button_size, button_y+480, button_size,0
	 line_v button_y-20, button_y+20, button_size+200,0

	 line_h button_x, button_y+240, button_size, 0
	 line_h button_x, button_y+button_size+240, button_size, 0
	 line_v button_x, button_y+240, button_size,0
	 line_v button_x+button_size, button_y+240, button_size,0
	 line_v button_x+10, button_y+260, button_size+200,0

	 ;al doilea patrat din map

	 line_h button_x+80, button_y+80, button_size, 0
	 line_h button_x+80, button_y+button_size+80, button_size, 0
	 line_v button_x+80, button_y+80, button_size,0
	 line_v button_x+button_size+80, button_y+80, button_size,0
	 line_h button_x+100, button_y+90, button_size+120, 0

	 line_h button_x+240, button_y+80, button_size, 0
	 line_h button_x+240, button_y+button_size+80, button_size, 0
	 line_v button_x+240, button_y+80, button_size,0
	 line_v button_x+button_size+240, button_y+80, button_size,0
	 line_h button_x+260, button_y+90, button_size+120, 0

	 line_h button_x+400, button_y+80, button_size, 0
	 line_h button_x+400, button_y+button_size+80, button_size, 0
	 line_v button_x+400, button_y+80, button_size,0
	 line_v button_x+button_size+400, button_y+80, button_size,0
	 line_v button_x+410, button_y+100, button_size+120,0

	 line_h button_x+400, button_y+240, button_size, 0
	 line_h button_x+400, button_y+button_size+240, button_size, 0
	 line_v button_x+400, button_y+240, button_size,0
	 line_v button_x+button_size+400, button_y+240, button_size,0
	 line_v button_x+410, button_y+260, button_size+120,0

	 line_h button_x+400, button_y+400, button_size, 0
	 line_h button_x+400, button_y+button_size+400, button_size, 0
	 line_v button_x+400, button_y+400, button_size,0
	 line_v button_x+button_size+400, button_y+400, button_size,0
	 line_h button_x+260, button_y+410, button_size+120, 0

	 line_h button_x+240, button_y+400, button_size, 0
	 line_h button_x+240, button_y+button_size+400, button_size, 0
	 line_v button_x+240, button_y+400, button_size,0
	 line_v button_x+button_size+240, button_y+400, button_size,0
	 line_h button_x+100, button_y+410, button_size+120, 0

	 line_h button_x+80, button_y+400, button_size, 0
	 line_h button_x+80, button_y+button_size+400, button_size, 0
	 line_v button_x+80, button_y+400, button_size,0
	 line_v button_x+button_size+80, button_y+400, button_size,0
	 line_v button_x+90, button_y+260, button_size+120,0

	 line_h button_x+80, button_y+240, button_size, 0
	 line_h button_x+80, button_y+button_size+240, button_size, 0
	 line_v button_x+80, button_y+240, button_size,0
	 line_v button_x+button_size+80, button_y+240, button_size,0
	 line_v button_x+90, button_y+100, button_size+120,0

	 ;al treilea patrat din map

	 line_h button_x+160, button_y+160, button_size, 0
	 line_h button_x+160, button_y+button_size+160, button_size, 0
	 line_v button_x+160, button_y+160, button_size,0
	 line_v button_x+button_size+160, button_y+160, button_size,0
	 line_h button_x+180, button_y+170, button_size+40, 0

	 line_h button_x+240, button_y+160, button_size, 0
	 line_h button_x+240, button_y+button_size+160, button_size, 0
	 line_v button_x+240, button_y+160, button_size,0
	 line_v button_x+button_size+240, button_y+160, button_size,0
	 line_h button_x+260, button_y+170, button_size+40, 0

     line_h button_x+320, button_y+160, button_size, 0
	 line_h button_x+320, button_y+button_size+160, button_size, 0
	 line_v button_x+320, button_y+160, button_size,0
	 line_v button_x+button_size+320, button_y+160, button_size,0
	 line_v button_x+330, button_y+180, button_size+40,0

	 line_h button_x+320, button_y+240, button_size, 0
	 line_h button_x+320, button_y+button_size+240, button_size, 0
	 line_v button_x+320, button_y+240, button_size,0
	 line_v button_x+button_size+320, button_y+240, button_size,0
	 line_v button_x+330, button_y+260, button_size+40,0

	 line_h button_x+320, button_y+320, button_size, 0
	 line_h button_x+320, button_y+button_size+320, button_size, 0
	 line_v button_x+320, button_y+320, button_size,0
	 line_v button_x+button_size+320, button_y+320, button_size,0
	 line_h button_x+260, button_y+330, button_size+40, 0

	 line_h button_x+240, button_y+320, button_size, 0
	 line_h button_x+240, button_y+button_size+320, button_size, 0
	 line_v button_x+240, button_y+320, button_size,0
	 line_v button_x+button_size+240, button_y+320, button_size,0
	 line_h button_x+180, button_y+330, button_size+40, 0

	 line_h button_x+160, button_y+320, button_size, 0
	 line_h button_x+160, button_y+button_size+320, button_size, 0
	 line_v button_x+160, button_y+320, button_size,0
	 line_v button_x+button_size+160, button_y+320, button_size,0
	 line_v button_x+170, button_y+260, button_size+40,0

	 line_h button_x+160, button_y+240, button_size, 0
	 line_h button_x+160, button_y+button_size+240, button_size, 0
	 line_v button_x+160, button_y+240, button_size,0
	 line_v button_x+button_size+160, button_y+240, button_size,0
	 line_v button_x+170, button_y+180, button_size+40,0

	 line_v button_x+250, button_y+100, button_size+40,0
	 line_v button_x+250, button_y+20, button_size+40,0

	 line_v button_x+250, button_y+340, button_size+40,0
	 line_v button_x+250, button_y+420, button_size+40,0

	 line_h button_x+420, button_y+250, button_size+40, 0
	 line_h button_x+340, button_y+250, button_size+40, 0

	 line_h button_x+100, button_y+250, button_size+40, 0
	 line_h button_x+20, button_y+250, button_size+40, 0

	 ;afisare playeri
	 ; patrat_v button_x+560, button_y+270, button_size+70, 0EE6565h
	 ; patrat_v button_x+660, button_y+270, button_size+70, 0EE6565h
	 ; patrat_v button_x+580, button_y+270, button_size+70, 0EE6565h
	 ; patrat_v button_x+600, button_y+270, button_size+70, 0EE6565h
	 ; patrat_v button_x+620, button_y+270, button_size+70, 0EE6565h
	 ; patrat_v button_x+640, button_y+270, button_size+70, 0EE6565h
	 line_h button_x+560, button_y+270, button_size+100, 0
	 line_h button_x+560, button_y+240, button_size+100, 0
	 line_h button_x+560, button_y+button_size+340, button_size+100, 0
	 line_v button_x+560, button_y+240, button_size+100,0
	 line_v button_x+button_size+660, button_y+240, button_size+100,0
	 make_text_macro 'P', area, button_x + 574, button_y+242
     make_text_macro 'L', area, button_x +584, button_y + 242
	 make_text_macro 'A', area, button_x +594, button_y + 242
	 make_text_macro 'Y', area, button_x +604, button_y + 242
	 make_text_macro 'E', area, button_x +614, button_y + 242
	 make_text_macro 'R', area, button_x +624, button_y + 242
	 make_text_macro 'I', area, button_x +644, button_y + 242

	 
	 ;player2
	 
	 ; patrat_v button_x+680, button_y+270, button_size+70, 06D65EEh
	 ; patrat_v button_x+700, button_y+270, button_size+70, 06D65EEh
	 ; patrat_v button_x+720, button_y+270, button_size+70, 06D65EEh
	 ; patrat_v button_x+740, button\_y+270, button_size+70, 06D65EEh
	 ; patrat_v button_x+760, button_y+270, button_size+70, 06D65EEh
	 ; patrat_v button_x+780, button_y+270, button_size+70, 06D65EEh
	 line_h button_x+680, button_y+270, button_size+100, 0
	 line_h button_x+680, button_y+240, button_size+100, 0
	 line_h button_x+680, button_y+button_size+340, button_size+100, 0
	 line_v button_x+button_size+780, button_y+240, button_size+100,0
	 make_text_macro 'P', area, button_x + 690, button_y+242
     make_text_macro 'L', area, button_x +700, button_y + 242
	 make_text_macro 'A', area, button_x +710, button_y + 242
	 make_text_macro 'Y', area, button_x +720, button_y + 242
	 make_text_macro 'E', area, button_x +730, button_y + 242
	 make_text_macro 'R', area, button_x +740, button_y + 242
	 make_text_macro 'I', area, button_x +760, button_y + 242
	 make_text_macro 'I', area, button_x +770, button_y + 242
	 
	;verif moara - roz
	cmp mori_verif[0], 1
	je next_moara
		;pentru roz 
		prima_linie_sus 0EE6565h
		cmp edx, 1
		jne alb_moara_1
		;moara_sus
		mov mori_verif[0], 1
		sterge_cul 06D65EEh
		jmp next_moara
		alb_moara_1:
		;pentru albastru 
		prima_linie_sus 06D65EEh
		cmp edx, 1
		jne next_moara
		mov mori_verif[0], 1
		sterge_cul 0EE6565h
	next_moara:
	
	
		;verif moara - roz
	cmp mori_verif[1], 1
	je next_moara2
		;pentru roz 
		a_doua_linie_sus 0EE6565h
		cmp edx, 1
		jne alb_moara_2
		;moara_sus
		mov mori_verif[1], 1
		sterge_cul 06D65EEh
		jmp next_moara2
		alb_moara_2:
		;pentru albastru 
		a_doua_linie_sus 06D65EEh
		cmp edx, 1
		jne next_moara2
		mov mori_verif[1], 1
		sterge_cul 0EE6565h
	next_moara2:
	
	

	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
	
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20


	;terminarea programului
	push 0
	call exit
end start
