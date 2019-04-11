

;habitaciones
(deffacts habitaciones
  (habitacion cocina 3)
  (habitacion salontv 3)
  (habitacion salon 2)
  (habitacion recibidor 4)
  (habitacion bestidor 1)
  (habitacion comedor 2)
  (habitacion pasillo 5)
  (habitacion baño 1)
  (habitacion dormitorio 1)
  (habitacion cochera 2))

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
  (puertaInterior pi_pasillo1 pasillo baño)
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
    (assert (valor_registrado 10 ?tipo ?habitacion ?estado))

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
  (defrule añadir_ultimo_evento
    (valor_registrado ?tiempo ?tipo ?habitacion ?estado)
    (test (neq ?tipo movimiento))
    =>
    (assert (ultimo_registro ?tipo ?habitacion ?tiempo))


  )

  ;añade una nuevo ultima_activacion
  (defrule añadir_ultima_activacion_borrando
    (valor_registrado ?tiempo movimiento ?habitacion ON)
    ?Borrar <- (sinmovimiento ?habitacion)
    (ultima_activacion movimiento ?habitacion ?tiempo2)
    (test (> ?tiempo ?tiempo2))

    =>
    (retract ?Borrar)
    (printout t "borrar sin movimiento" crlf)
    (assert (ultima_activacion movimiento ?habitacion ?tiempo))


  )
  (defrule añadir_ultima_activacion
    (valor_registrado ?tiempo movimiento ?habitacion ON)
    (not (sinmovimiento ?habitacion))
    =>
    (assert (ultima_activacion movimiento ?habitacion ?tiempo))


  )

  ;se queda con la ultima activacion
  (defrule borrar_ultima_activacion
    (ultima_activacion ?tipo ?habitacion ?tiempo)
    ?Borrar <- (ultima_activacion ?tipo ?habitacion ?tiempo2)
    (test (> ?tiempo ?tiempo2))
    =>
    (retract ?Borrar)


  )

  ;añade una nueva utlima_desactivacion
  (defrule añadir_ultima_desactivacion
    (valor_registrado ?tiempo movimiento ?habitacion OFF)
    =>
    (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))


  )

  ;se queda con la ultima desactivacion
  (defrule borrar_ultima_desactivacion
    (ultima_desactivacion ?tipo ?habitacion ?tiempo)
    ?Borrar <- (ultima_desactivacion ?tipo ?habitacion ?tiempo2)
    (test (> ?tiempo ?tiempo2))
    =>
    (retract ?Borrar)


  )

;  (deffunction obtener_max (?habitacion)
;    (valor_registrado ?tiempo ?tipo ?habitacion ?estado)
;    (not (valor_registrado ?tiempo2&:(> ?tiempo2 ?tiempo) ?tipo2 ?habitacion ?estado2))

;    tiempo
;  )


  (defrule informe
    (informe ?habitacion)
    (valor_registrado ?tiempo ?tipo ?habitacion ?estado)
    =>
    (printout t "tiempo: " ?tiempo " tipo: " ?tipo " habitacion: " ?habitacion " estado:" ?estado crlf)
  )


;encender luz

;encender luz cuando sensor on y luminosidad superior a 300
(defrule apagar_luz_luminosidad
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor )
  (test (> ?valor 300))
  (ultima_activacion ? ?habitacion ?t_activacion)
  (ultima_desactivacion ? ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))

  =>
  (printout t crlf "Apagar luz en " ?habitacion "con luminosidad " ?valor)

)

(defrule encender_luz_luminosidad
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor )
  (test (<= ?valor 300))
  (ultima_activacion ? ?habitacion ?t_activacion)
  (ultima_desactivacion ? ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))
  =>
  (printout t "Encender luz en " ?habitacion " con luminosidad " ?valor crlf)
)

(defrule apagar_luz_tiempo
  (ultima_desactivacion ? ?habitacion ?t_desactivacion)
  (ultima_activacion ? ?habitacion ?t_activacion)

  (test (< ?t_activacion ?t_desactivacion))
  (not (sinmovimiento ?habitacion))
  (not (parece_desconectado ? ?))

  =>
  (assert (parece_desconectado ?habitacion ?t_desactivacion))
  (printout t "Iniciamos desactivacion" crlf)

)

(defrule comprobar_parece_apagado
  (ultima_desactivacion ? ?habitacion ?t_desactivacion)
  (ultima_activacion ? ?habitacion ?t_activacion)
  (test (< ?t_activacion ?t_desactivacion))
  (not (sinmovimiento ?habitacion))
  ?Borrar <- (parece_desconectado ?habitacion ?t_inicial)
  (test (<= 15 (- ?t_desactivacion ?t_inicial)))
  =>
  (retract ?Borrar)
  (assert (sinmovimiento ?habitacion))
  (printout t "Ahora tocaria desactivar" crlf)

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

;(deffacts pruebas_valores


;    (valor_registrado 5 movimiento salon OFF)
;    (valor_registrado 10 movimiento salon ON)
;    (valor_registrado 12 luminosidad salon 500)
;    (valor_registrado 16 luminosidad salon 525)
;    (valor_registrado 16 luminosidad salon 550)




; )
