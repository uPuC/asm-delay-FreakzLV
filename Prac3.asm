;------------- definiciones e includes ------------------------------
.INCLUDE "m1280def.inc" ; Incluir definiciones de Registros para 1280
;INCLUDE "m2560def.inc" ; Incluir definiciones de Registros para 2560

.equ INIT_VALUE = 0 ; Valor inicial R24

;------------- inicializar ------------------------------------------
ldi R20, INIT_VALUE
ldi R21, INIT_VALUE
ldi R22, INIT_VALUE
ldi R23, INIT_VALUE
ldi R25, INIT_VALUE
;------------- implementar ------------------------------------------
call delay20uS ;5
call delay4mS  ;5
call delay1S   ;5

ldi R20, 0xA5 ; Semilla
ldi R24, 0x05 ; Prueba de la subrutina 5 veces
nxt:
	call myRand ; Retorna valor en R25
	dec R24
	brne nxt
nop

;------------- ciclo principal --------------------------------------

;------------- call delay20uS ----------------------
; 1 - 20uS @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 20uS = N*(1/16Mhz)
; N = (20uS)(16Mhz) = 320
; --------------------------------

delay20uS:
	ldi R21, 51    ;1
	nxt: nop       ;1n
		 nop	   ;1n
		 nop	   ;1n
		 dec R21   ;1n
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
; 2 - 4mS @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 4mS = N*(1/16Mhz)
; N = (4mS)(16Mhz) = 64,000
; --------------------------------

delay4mS:
	ldi R21, 90    		;1
	nxt: 
		ldi R22, 236    ;n
		nxt2:
			dec R22		;m*n
			brne nxt2	;(2m-1)*n
		dec R21			;n
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
; m = 708/3 = 236 (sigue siendo menor a 255 asi que es valido)
;---------------------------------------------------------------

;----------------- call delay1S -------------------
; 3 - 1S @ 16Mhz
; --------------------------------
; T = N*Tcpu -> 1S = N*(1/16Mhz)
; N = (1S)(16Mhz) = 16,000,000
; --------------------------------

delay1S:
    ldi R21, 241            			;1
	nxt:
    	ldi R22, 71             		;n
    	nop                    			;n
		nxt2:
    		ldi R23, 232            	;m*n
    		nop                     	;m*n
    		nop                     	;m*n
    		nop                     	;m*n
			nxt3:
    			dec R23                 ;p*m*n
    			cpi R23, 0              ;p*m*n
    			brne nxt3               ;(2p-1)*m*n
    		dec R22                 	;m*n
    		cpi R22, 0              	;m*n
    	brne nxt2              			;(2m-1)*n
    dec R21                 			;n
    cpi R21, 0              			;n
    brne nxt              				;2n-1
ret                         			;5

;---------------------------------------------------------------------------
; 1+n+n+mn+mn+mn+mn+pmn+pmn+(2p-1)mn+mn+mn+(2m-1)n+n+n+(2n-1)+5(ret)+5(call)
; -> 4pmn + 7mn + 5n + 10
;
; Fijando p=232 (tomando valor de referencia para tener 2 incognitas):
; 4(232)mn + 7mn + 5n + 10 = 16,000,000
; n(928m + 7m + 5) + 10 = 16,000,000
; n(935m + 5) = 15,999,990
;
; Buscando n,m <= 255 tal que n*(935m+5) = 15,999,990:
; Factorizando 15,999,990 = 2 x 3 x 5 x 11 x 17 x 71 x 241
; n*(935m + 5) = n*5*(187m + 1) = 15,999,990
;				 n*(187m + 1) = 3,199,998
; Probando n=71:  187m+1 = 3,199,998/71 = 45,070
;				  187m = 45,069 -> m = 241 (< 255, valido)
;---------------------------------------------------------------------------

;---------------------------------------------------------------
; myRand - Generador pseudoaleatorio de 8 bits (LFSR Galois)
;---------------------------------------------------------------
; R20 = estado interno (semilla, inicializar != 0 una sola vez)
; R25 = valor retornado
; Polinomio: x^8+x^6+x^5+x^4+1  ?  mascara 0xB8 (10111000b) - (No obligatoriamente tiene que ser esa)
; Ciclo maximo: 255 valores unicos
;---------------------------------------------------------------

myRand:
    lsr  R20            ; desplazar R20 a la derecha, LSB -> Carry
    brcc skip           ; Carry=0: sin feedback
    ldi  R25, 0xB8      ; Carry=1: mascara del polinomio
    eor  R20, R25       ; XOR = retroalimentacion
skip:
    mov  R25, R20       ; R25 = resultado
    ret

;---------------------------------------------------------------
; Ejemplo de secuencia con semilla 0xA5:
;   0xA5 ? 0xD3 ? 0x9A ? 0xCD ? ... (255 valores) ... ? 0xA5
; R20 (estado interno), R25 (retorno)
; Funciona mientras R20 no se modifique entre llamadas.
;---------------------------------------------------------------
arriba: inc R24
	cpi R24,10
	breq abajo
	out PORTA,R24
	rjmp arriba

abajo: dec R24
	cpi R24,0
	breq arriba
	out PORTA,R24
	rjmp abajoa