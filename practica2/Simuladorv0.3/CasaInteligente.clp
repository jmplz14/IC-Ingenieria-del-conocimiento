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
    ?f <- (valor ?tipo ?habitacion ?estado)
    =>
    ;(printout t crlf "Registrando valor")
    (assert (valor_registrado ?*transcurrido* ?tipo ?habitacion ?estado))
    (retract ?f)

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


;---------------------Modulo baño muchas veces----------------------------------
;Esta funcon cuenta el nuemro de templates que existen. Se le pasa por parametro
(deffunction count-facts-2 (?template)
(length (find-all-facts ((?fct ?template)) TRUE)))

(defrule anadir_ir_bano

  ;(ultimo_registro movimiento ?habitacion ?tiempo)
  ;(valor_registrado ?tiempo movimiento bano off)
  (ultima_activacion movimiento bano ?tiempo)
  =>
  ;(printout t crlf "primer on completo")
  (assert (fuebano ?tiempo))
  (assert (contarbano))
)
(defrule borrar_veces_bano
  (fuebano ?tiempo)
  ?Borrar <- (fuebano ?tiempo2)
  (test (< 10800 (- ?tiempo ?tiempo2)))
  =>
  ;(printout t "Borrando" crlf)
  (retract ?Borrar)
)

(defrule contar_veces_bano
  (declare (salience -10))
  ?f <- (contarbano)
  =>
  (if (< 4 (count-facts-2 fuebano) )
  then
    (printout t ?*hora* ":" ?*minutos* ":" ?*segundos* ": La persona fue " (count-facts-2 fuebano) " veces al baño" crlf)
  )
  (retract ?f)
)










;-------------------------------------------------------------------------------

;---------------------Modulo detectar si sale de casa---------------------------
(defrule activar_modulo_abandono_casa

  ;(ultimo_registro magnetico ?puertaExterior ?tiempo)
  (valor_registrado ?tiempo magnetico ?puertaExterior off)
  =>
  (assert (HoraInicioAbandonoCasa ?*transcurrido*))
  (assert (modulo salircasa))

)

(defrule bucle_modulo_abandono_casa
   (declare (salience -10))
   ?h <- (modulo salircasa)
   (HoraActualizada ?t)
   ?g <- (HoraInicioAbandonoCasa ?inicio)

   =>

   (if (< 60 (- ?*transcurrido* ?inicio))
   then

     (printout t ?*hora* ":" ?*minutos* ":" ?*segundos* ": La persona salio de casa." crlf)
     (retract ?g)
     (retract ?h)

   )

)

(defrule error_al_detectar_abandono
   ?h <- (modulo salircasa)
   (ultima_activacion movimiento salontv ?tiempo)

   ?g <- (HoraInicioAbandonoCasa ?inicio)
   =>
   (if (< ?inicio ?tiempo)
   then
     ;(printout t "Falsa alarma salida" crlf)
     (retract ?g)
     ;(retract ?f)
     (retract ?h)
   )

)
;-------------------------------------------------------------------------------


;---------------------Modulo no movimiento en 3 horas---------------------------

(defrule activar_modulo_no_movimiento
  (valor_registrado ?tiempo movimiento ?habitacion off)
  =>
  (if (and (<= 9 ?*hora*) (>= 21 ?*hora*) )
  then
    (assert (IncioNoMovimiento ?*transcurrido*))
    ;(assert (PasadaActualNoMovimiento))
    (assert (modulo nomovimiento))
  )

)

(defrule bucle_modulo_no_movimiento

   ;(declare (salience -15))
   ?h <- (modulo nomovimiento)
   (HoraActualizada ?t)
   ?g <- (IncioNoMovimiento ?inicio)

   =>
   (if (< 10800 (- ?*transcurrido* ?inicio))
   then

     (printout t ?*hora* ":" ?*minutos* ":" ?*segundos* ": La persona lleva 3 horas sin moverse." crlf)
     ;(printout t ?*transcurrido* crlf)
     (retract ?g)
     (retract ?h)

   )
)

(defrule error_al_detectar_movimiento

   ?h <- (modulo nomovimiento)
   (ultima_activacion movimiento ?habitacion ?tiempo)

   ?g <- (IncioNoMovimiento ?inicio)
   =>
   (if (< ?inicio ?tiempo)
   then
     ;(printout t "Falsa alarma se movio" crlf)
     (retract ?g)
     (retract ?h)
   )
)



;-------------------------------------------------------------------------------



;---------------------Modulo no ir al bano 12 horas-----------------------------

(defrule activar_modulo_no_ir_bano_12_horas
  (valor_registrado ?tiempo movimiento bano off)
  =>
  (assert (IncioNoIrBano ?*transcurrido*))
  (assert (modulo noirbano))
)

(defrule bucle_modulo_no_ir_bano
   (declare (salience -15))
   ?h <- (modulo noirbano)
   (HoraActualizada ?t)
   ?g <- (IncioNoIrBano ?inicio)

   =>

   (if (< 43200 (- ?*transcurrido* ?inicio))
   then

     (printout t ?*hora* ":" ?*minutos* ":" ?*segundos* ": La persona lleva 12 horas sin ir al baño." crlf)
     (retract ?g)
     (retract ?h)
   )

)

(defrule error_fue_al_bano_antes

   ?h <- (modulo noirbano)
   (ultima_activacion movimiento bano ?tiempo)
   (HoraActualizada ?t)
   ?g <- (IncioNoIrBano ?inicio)
   =>
   (if (< ?inicio ?tiempo)
   then
     (retract ?g)
     (retract ?h)
   )


)



;-------------------------------------------------------------------------------

;---------------------Modulo en el baño 20 minutos------------------------------
(defrule activar_modulo_en_el_bano
  (ultima_activacion movimiento bano ?tiempo)
  =>
  (assert (IncioNoIrBano ?*transcurrido*))
  (assert (modulo solobano))
)

(defrule bucle_modulo_en_el_bano
   (declare (salience -15))
   ?h <- (modulo solobano)
   (HoraActualizada ?t)
   ?g <- (IncioNoIrBano ?inicio)

   =>

   (if (< 1200 (- ?*transcurrido* ?inicio))
   then

     (printout t ?*hora* ":" ?*minutos* ":" ?*segundos* ": La persona lleva 20 minutos en el baño." crlf)
     (retract ?g)
     (retract ?h)
   )

)

(defrule error_salio_bano

   ?h <- (modulo solobano)
   (ultima_desactivacion movimiento bano ?tiempo)
   ?g <- (IncioNoIrBano ?inicio)
   =>
   (if (< ?inicio ?tiempo)
   then
     (retract ?g)
     (retract ?h)
   )


)

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


     ;(valor_registrado 5 movimiento salon off)
     ;(valor_registrado 50 movimiento salon on)
     ;(valor_registrado 12 luminosidad salon 500)
     ;(valor_registrado luminosidad salon 525)
     ;(valor magnetico salon off)
     ;(valor movimiento bano off)
     ;(valor movimiento bano on)
     ;(valor magnetico salon off)
     ;(valor movimiento salon on)



)
