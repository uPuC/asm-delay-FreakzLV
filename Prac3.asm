;------------- definiciones e includes ------------------------------
.INCLUDE "m1280def.inc" ; Incluir definiciones de Registros para 1280
;.INCLUDE "m2560def.inc" ; Incluir definiciones de Registros para 2560

.equ INIT_VALUE = 0 ; Valor inicial R24

;------------- inicializar ------------------------------------------
ldi R24,INIT_VALUE
ldi R25,INIT_VALUE
ldi R26,INIT_VALUE
;------------- implementar ------------------------------------------
;call delay20uS
;call delay4mS
;call delay1S
;call myRand ; Retorna valor en R25
;------------- ciclo principal --------------------------------------

;------------- call delay20uS ----------------------
; 1 - 20uS @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 20uS = N*(1/16Mhz)
; N = (20uS)(16Mhz) = 320
; --------------------------------
call delay20uS ;5
nop

delay20uS:
	ldi R24, 51    ;1
	nxt: nop       ;1n
		 nop	   ;1n
		 nop	   ;1n
		 dec R24   ;1n
		 brne nxt  ;2n-1
	nop			   ;1
	nop			   ;1
	nop			   ;1
	nop			   ;1
	ret			   ;5

;---------------------------------------------------
; 1+1n+1n+1n+1n+2n-1+1+1+1+1+5(ret)+5(call) -> 6n+14
; 6n+14 = 320
; 6n = 320 - 14 = 306
; n = 306/6 = 51
;---------------------------------------------------


;------------- call delay4mS ----------------------
; 1 - 4mS @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 4mS = N*(1/16Mhz)
; N = (4mS)(16Mhz) = 64,000
; --------------------------------
call delay4mS ;5
nop

delay4mS:
	ldi R24, 90    		;1
	nxt: 
		ldi R25, 236    ;n
		nxt2:
			dec R25		;m*n
			brne nxt2	;(2m-1)*n
		dec R24			;n
		brne nxt		;2n-1
	ret					;5

;---------------------------------------------------------------
; 1+n+m*n+(2m-1)*n+n+2n-1+5(ret)+5(call) -> 2n+n+2mn+mn+10
; 2n+n+2mn+mn+10 -> 3n+3mn+10
; 3n+3mn+10 = 64,000
; 3n+3mn = 64,000-10 = 63,990
; n(3+3m) = 63,990
; 3+3m = 63,990/n   -> 63,990/2 -> 31,995/5 -> 6,399/9 -> 711  
;						  2     *     5     * 	  9    -> 90 (n)
;
; 3+3m = 63,990/90 = 711
; 3m = 711-3 = 708
; m = 708/3 = 236 (sigue siendo menor a 256 asi que es valido)
;---------------------------------------------------------------


;-------------- call delay1S ----------------------
; 1 - 1S @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 1S = N*(1/16Mhz)
; N = (1S)(16Mhz) = 16,000,000
; --------------------------------
call delay1S ;5
nop


delay1S:
    ldi r26, 250        ; 1
loop1s:
    call delay4mS      ; 64,000*n
    dec r26             ; 1n
    brne loop1s         ; 2n -1
ret                     ; 5

;---------------------------------------------------------------
; 1+64,000*n+1n+2n-1+5+5 -> 64.003n+10
; 64,003n+10 = 16,000,000
; 64,0003n = 16,000,000-10 = 15,999,990
; n = 15,999,990/64,0003 = 249.9881 -> 250 (aprox) -> 1.0000475 S
;---------------------------------------------------------------

;-------- 4mS para usar en el 1S  --------------              
delay4mS:
	ldi R24, 90    		;1
	nxt: 
		ldi R25, 236    ;n
		nxt2:
			dec R25		;m*n
			brne nxt2	;(2m-1)*n
		dec R24			;n
		brne nxt		;2n-1
	ret					;5
;-----------------------------------------------
