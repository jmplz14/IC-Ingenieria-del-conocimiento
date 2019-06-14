;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;; FUNCIONES UTILES PARA MANEJAR LA HORA EN CLIPS  ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;se ofrecen para facilitar el proceso de añadir timestamp a eventos ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; DEPENDERA DEL SISTEMA OPERATIVO (elegir comentando o descomentando a continuacion ;;;;;;;

;(defglobal ?*SO* = 1)              ;;; Windows (valor 1)    comentar si tu SO es linux o macos

(defglobal ?*SO* = 0)             ;;; Linux o MacOs (valor 0)    descoemntar si tu SO es linux o macos


;; Funcion que transforma ?h:?m:?s  en segundos transcurridos desde las 0h en punto ;;;

(deffunction totalsegundos (?h ?m ?s)
   (bind ?rv (+ (* 3600 ?h) (* ?m 60) ?s))
   ?rv)

;;;;;; Funcion que devuelve la salida de ejecutar  ?arg en linea de comandos del sistema ;;;

   (deffunction system-string (?arg)
   (bind ?arg (str-cat ?arg " > temp.txt"))
   (system ?arg)
   (open "temp.txt" temp "r")
   (bind ?rv (readline temp))
   (close temp)
   ?rv)

;;;;;; Funcion que devuelve el nº de horas de la hora del sistema, si en el sistema son las ?h:?m:?s, devuelve ?h  ;;;;;;;;;;;;

   (deffunction horasistema ()
   (if (= ?*SO* 1)
      then
         (bind ?rv (integer (string-to-field (sub-string 1 2  (system-string "time /t")))))
	   else
	     (bind ?rv (string-to-field  (system-string "date +%H")))
         )
   ?rv)

;;;;;; Funcion que devuelve el nº de minutos de la hora del sistema, si en el sistema son las ?h:?m:?s, devuelve ?m  ;;;;;;;;;;;;

   (deffunction minutossistema ()
   (if (= ?*SO* 1)
       then
          (bind ?rv (integer (string-to-field (sub-string 4 5  (system-string "time /t")))))
	   else
	     (bind ?rv (string-to-field  (system-string "date +%M")))	  )
   ?rv)

;;;;;; Funcion que devuelve el nº de segundos de la hora del sistema, si en el sistema son las ?h:?m:?s, devuelve ?s  ;;;;;;;;;;;;

   (deffunction segundossistema ()
   (if (= ?*SO* 1)
       then
          (bind ?rv (integer (string-to-field (sub-string 7 8  (system-string "@ECHO.%time:~0,8%")))))
	   else
	     (bind ?rv (string-to-field  (system-string "date +%S")))	  )
   ?rv)

;;;;;; Funcion que devuelve el valor de ?h  al pasar ?t segundos al formato ?h:?m:?s  ;;;;;;;;;;

    (deffunction hora-segundos (?t)
   (bind ?rv  (div ?t 3600))
   ?rv)

;;;;;; Funcion que devuelve el valor de ?m  al pasar ?t segundos al formato ?h:?m:?s  ;;;;;;;;;;
   (deffunction minuto-segundos (?t)
   (bind ?rv (- ?t (* (hora-segundos ?t) 3600)))
   (bind ?rv (div ?rv 60))
   ?rv)

;;;;;; Funcion que devuelve el valor de ?s  al pasar ?t segundos al formato ?h:?m:?s  ;;;;;;;;;;
   (deffunction segundo-segundos (?t)
   (bind ?rv (- ?t (* (hora-segundos ?t) 3600)))
   (bind ?rv (- ?rv (* (minuto-segundos ?t) 60)))
   ?rv)




;habitaciones
(deffacts habitaciones
  (habitacion cocina 3)
  (habitacion salontv 3)
  (habitacion salon 2)
  (habitacion recibidor 4)
  (habitacion bestidor 1)
  (habitacion comedor 2)
  (habitacion pasillo 5)
  (habitacion bano 1)
  (habitacion dormitorio 1)
  (habitacion cochera 2)
  (Manejo_inteligente_luces salon)
  (Manejo_inteligente_luces pasillo)
  (Manejo_inteligente_luces comedor)
  )

;ventanas
(deffacts ventanas
  (ventana v_cocina cocina)
  (ventana v_salontv1 salontv)
  (ventana v_salontv2 salontv)
  (ventana v_salon salon)
  (ventana v_comedor comedor)
  (ventana v_cochera cochera)
  (ventana v_dormitorio dormitorio))

;puertas exterior
(deffacts puertasExteriores
  (puertaExterior pe_salontv salontv)
  (puertaExterior pe_recibidor recibidor)
  (puertaExterior pe_cochera cochera)
  (puertaExterior pe_pasillo pasillo))

;puertas interiores
(deffacts puertasInterior
  (puertaInterior pi_pasillo1 pasillo bano)
  (puertaInterior pi_pasillo2 pasillo cochera)
  (puertaInterior pi_pasillo3 pasillo dormitorio)
  (puertaInterior pi_recibidor recibidor bestidor))

;pasos habitaciones
(deffacts pasos
  (paso paso_cocina1 cocina pasillo)
  (paso paso_cocina2 cocina salontv)
  (paso paso_salontv salontv salon)
  (paso paso_salon salon recibidor)
  (paso paso_recibidor recibidor comedor)
  (paso paso_cocina comedor cocina))

;regla habitacionInterior
(defrule habitacionInterior
  (habitacion ?nombre ?)
  (not (ventana ? ?nombre))
  (not (puertaExterior ? ?nombre))
  =>
  (assert (habitacion_interior ?nombre))

  )

;regla para añadir posiblePasar
(defrule posiblePasarPuertaInterior
  (habitacion ?habitacion1 ?)
  (puertaInterior ? ?habitacion1 ?habitacion2)
  =>
  (assert (posible_pasar ?habitacion1 ?habitacion2))
  )

;regla para añadir posiblePasar
(defrule posiblePasarPaso
  (habitacion ?habitacion1 ?)
  (paso ? ?habitacion1 ?habitacion2)
  =>
  (assert (posible_pasar ?habitacion1 ?habitacion2))
  )

;regla para ver habitaciones que solo estan comunicadas con otra
(defrule necesarioPasar
  (habitacion ?habitacion1 1)
  (or (paso ? ?habitacion1 ?habitacion2 )
  (paso ? ?habitacion2 ?habitacion1 )
  (puertaInterior ? ?habitacion1 ?habitacion2)
  (puertaInterior ? ?habitacion2 ?habitacion1))
  =>
  (assert (necesario_pasar ?habitacion1 ?habitacion2))
  )

  ;añade el tipo valor_registrado
  (defrule registrar_evento_inicial
    (valor ?tipo ?habitacion ?estado)
    =>
    ;(printout t crlf "Registrando valor")
    (assert (valor_registrado (totalsegundos (horasistema) (minutossistema) (segundossistema)) ?tipo ?habitacion ?estado))

  )

  ;se queda con el ultimo evento de cada habitacion del mismo tipo borrando los
  ;demas
  (defrule borrar_ultimo_evento
    (ultimo_registro ?tipo ?habitacion ?tiempo)
    ?Borrar <- (ultimo_registro ?tipo ?habitacion ?tiempo2)
    (test (> ?tiempo ?tiempo2))
    =>
    ;(printout t crlf "Borrar:" ?tipo ":" ?habitacion  ":" ?tiempo2)
    (retract ?Borrar)


  )

  ;añade un nuevo ultimo registro
  (defrule anadir_ultimo_evento
    (valor_registrado ?tiempo ?tipo ?habitacion ?estado)
    (test (neq ?tipo movimiento))
    =>
    (assert (ultimo_registro ?tipo ?habitacion ?tiempo))


  )

;decicir si se tiene que mandar un nuevo cambio de activacio a desasctivacion o al contrario

;(defrule primer_OFF
;  (valor_registrado ?tiempo movimiento ?habitacion off)
;  (not(ultima_desactivacion movimiento ?habitacion ?))
;  (not(ultima_activacion movimiento ?habitacion ?))
;  =>
;  (printout t crlf "primer off")
;  (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))
;)

(defrule primer_ON
  (valor_registrado ?tiempo movimiento ?habitacion on)
  (not(ultima_desactivacion movimiento ?habitacion ?))
  (not(ultima_activacion movimiento ?habitacion ?))
  =>
  ;(printout t crlf "primer on")
  (assert (ultima_activacion movimiento ?habitacion ?tiempo))
)

(defrule OFF_sin_OFF
  (valor_registrado ?tiempo movimiento ?habitacion off)
  (not(ultima_desactivacion movimiento ?habitacion ?))
  (ultima_activacion movimiento ?habitacion ?)
  =>
  ;(printout t crlf "primer off depues de varios on")
  (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))

)

(defrule ON_sin_ON
  (valor_registrado ?tiempo movimiento ?habitacion on)
  (not(ultima_activacion movimiento ?habitacion ?))
  (ultima_desactivacion movimiento ?habitacion ?)
  =>
  ;(printout t crlf "primer on depues de varios off")
  (assert (ultima_activacion movimiento ?habitacion ?tiempo))

)

(defrule OFF_completo
  (valor_registrado ?tiempo movimiento ?habitacion off)
  (ultima_activacion movimiento ?habitacion ?t_activacion)
  (test (> ?tiempo ?t_activacion))
  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))
  =>
  ;(printout t crlf "primer off completo")
  (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))
)

(defrule ON_completo
  (valor_registrado ?tiempo movimiento ?habitacion on)
  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
  (test (> ?tiempo ?t_desactivacion))
  (ultima_activacion movimiento ?habitacion ?t_activacion)
  (test (< ?t_activacion ?t_desactivacion))
  =>
  ;(printout t crlf "primer on completo")
  (assert (ultima_activacion movimiento ?habitacion ?tiempo))
)

(defrule borrar_ultima_desactivacion
  (ultima_desactivacion ?tipo ?habitacion ?tiempo)
  ?Borrar <- (ultima_desactivacion ?tipo ?habitacion ?tiempo2)
  (test (> ?tiempo ?tiempo2))
  =>
  (retract ?Borrar)


)

(defrule borrar_ultima_activacion
  (ultima_activacion ?tipo ?habitacion ?tiempo)
  ?Borrar <- (ultima_activacion ?tipo ?habitacion ?tiempo2)
  (test (> ?tiempo ?tiempo2))
  =>
  (retract ?Borrar)


)


;---------------------Modulo detectar si sale de casa---------------------------
(defrule activar_modulo_abandono_casa
  (ultimo_registro magnetico ?puertaExterior ?tiempo)
  (valor_registrado ?tiempo magnetico ?puertaExterior off)
  =>
  (assert (HoraInicio (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
  (assert (HoraActual (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
  (assert (modulo salircasa))

)

(defrule bucle_modulo_abandono_casa
   (declare (salience -10))
   ?h <- (modulo salircasa)
   ?f <- (HoraActual ?actual)
   ?g <- (HoraInicio ?inicio)

   =>
   (retract ?f)

   (if (< 15 (- (totalsegundos (horasistema) (minutossistema) (segundossistema)) ?inicio))
   then

     (printout t "La persona salio de casa." crlf)
     (retract ?g)
     (retract ?h)

   )

   (assert (HoraActual (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
)

(defrule error_al_detectar_abandono

   ?h <- (modulo salircasa)
   (valor_registrado ?tiempo movimiento ?habitacion on)
   ?f <- (HoraActual ?actual)
   ?g <- (HoraInicio ?inicio)
   =>
   (printout t "Falsa alarma" crlf)
   (retract ?g)
   (retract ?f)
   (retract ?h)


)
;-------------------------------------------------------------------------------


;---------------------Modulo no movimiento en 3 horas---------------------------

(defrule activar_modulo_no_movimiento
  (valor_registrado ?tiempo movimiento ?habitacion off)
  =>
  (if (and (<= 9 (horasistema)) (>= 21 (horasistema)) )
  then

    (assert (IncioNoMovimiento (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
    (assert (HoraActualNoMovimiento (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
    (assert (modulo nomovimiento))
  )


)

(defrule bucle_modulo_no_movimiento
   (declare (salience -15))
   ?h <- (modulo nomovimiento)
   ?f <- (HoraActualNoMovimiento ?actual)
   ?g <- (IncioNoMovimiento ?inicio)

   =>
   (retract ?f)

   (if (< 10800 (- (totalsegundos (horasistema) (minutossistema) (segundossistema)) ?inicio))
   then

     (printout t "La persona lleva 3 horas sin moverse." crlf)
     (retract ?g)
     (retract ?h)

   )

   (assert (HoraActualNoMovimiento (totalsegundos (horasistema) (minutossistema) (segundossistema) )))
)

(defrule error_al_detectar_movimiento

   ?h <- (modulo nomovimiento)
   (valor_registrado ?tiempo movimiento ? on)
   ?f <- (HoraActualNoMovimiento ?actual)
   ?g <- (IncioNoMovimiento ?inicio)
   =>
   (printout t "Falsa alarma se movio" crlf)
   (retract ?g)
   (retract ?f)
   (retract ?h)


)



;-------------------------------------------------------------------------------

;---------------------Modulo despierto de noche---------------------------------


;-------------------------------------------------------------------------------


(defrule informe
  (informe ?habitacion)
  (valor_registrado ?tiempo ?tipo ?habitacion ?estado)
  (not (listado ?tiempo ?tipo ?habitacion ?estado))
  =>
  (assert (listado ?tiempo ?tipo ?habitacion ?estado))
)

(defrule limpiar
  ?Borrar <- (informe ?habitacion)
  (not
    (and(valor_registrado ?tiempo ?tipo ?habitacion ?valor)
      (not (listado ?tiempo ?tipo ?habitacion ?valor))
    )
  )
  =>
  (retract ?Borrar)
  (printout t "Mostrar informe de : "  ?habitacion crlf)
)

(defrule imprimeInforme
  (not (informe ?habitacion))
  ?Borrar <- (listado ?tiempo1 ?tipo ?habitacion ?valor)
  (not (listado ?tiempo2 &: (> ?tiempo2 ?tiempo1) ? ?habitacion ?))
  =>
  (printout t "Tiempo: " ?tiempo1 " tipo: " ?tipo " valor: " ?valor crlf)
  (retract ?Borrar)
)


;listar datos introducidos

;listar habitaciones interiores
;(defrule listarInterior
;  (habitacion_interior ?nombre)
;  =>
;  (printout t crlf ?nombre " son internas")
;  )
;(defrule posiblePasar
;  (posible_pasar ?habitacion1 ?habitacion2)
;  =>
;  (printout t crlf ?habitacion1 ":" ?habitacion2 " tienen paso")
;  )



;  (defrule necesarioPasar
;    (necesario_pasar ?habitacion1 ?habitacion2)
;    =>
;    (printout t crlf ?habitacion2 ":" ?habitacion1 " unico paso")
;    )

;(defrule ultimoValorMostrar
;  (ultimo_registro ?tipo ?habitacion ?tiempo)
;  =>
;  (printout t crlf "prueba" ?tipo ":" ?habitacion ":" ?tiempo)
;)

;(defrule ultimoValorMostrar
;  (ultima_activacion ?tipo ?habitacion ?tiempo)
;  =>
;  (printout t crlf "activacion:" ?tipo ":" ?habitacion ":" ?tiempo)
;)
;(defrule ultimoValorDesactivacion
;  (ultima_desactivacion ?tipo ?habitacion ?tiempo)
;  =>
;  (printout t crlf "desactivacion:" ?tipo ":" ?habitacion ":" ?tiempo )
;)

(deffacts pruebas_valores


     (valor_registrado 5 movimiento salon off)
     ;(valor_registrado 50 movimiento salon on)
     ;(valor_registrado 12 luminosidad salon 500)
     ;(valor_registrado luminosidad salon 525)
     ;(valor magnetico salon off)
      ;(valor movimiento salon on)
     ;(valor magnetico salon off)
     ;(valor movimiento salon on)



)
