

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
    ;(printout t crlf "Registrando valor")
    (assert (valor_registrado ?*transcurrido* ?tipo ?habitacion ?estado))

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

;decicir si se tiene que mandar un nuevo cambio de activacio a desasctivacion o al contrario

;(defrule primer_OFF
;  (valor_registrado ?tiempo movimiento ?habitacion off)
;  (not(ultima_desactivacion movimiento ?habitacion ?))
;  (not(ultima_activacion movimiento ?habitacion ?))
;  =>
;  (printout t crlf "primer off")
;  (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))
;)

;primer on si ninngun on anteiror ni off
(defrule primer_ON
  (valor_registrado ?tiempo movimiento ?habitacion on)
  (not(ultima_desactivacion movimiento ?habitacion ?))
  (not(ultima_activacion movimiento ?habitacion ?))
  =>
  ;(printout t crlf "primer on")
  (assert (ultima_activacion movimiento ?habitacion ?tiempo))
)

;primer off sin que se tenga un off antrior
(defrule OFF_sin_OFF
  (valor_registrado ?tiempo movimiento ?habitacion off)
  (not(ultima_desactivacion movimiento ?habitacion ?))
  (ultima_activacion movimiento ?habitacion ?)
  =>
  ;(printout t crlf "primer off depues de varios on")
  (assert (ultima_desactivacion movimiento ?habitacion ?tiempo))

)
;primer on sin que se tenga un on anterior
(defrule ON_sin_ON
  (valor_registrado ?tiempo movimiento ?habitacion on)
  (not(ultima_activacion movimiento ?habitacion ?))
  (ultima_desactivacion movimiento ?habitacion ?)
  =>
  ;(printout t crlf "primer on depues de varios off")
  (assert (ultima_activacion movimiento ?habitacion ?tiempo))

)

;cuando ya tenemos tanto un off como un on anteriormente
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

;cuando ya tenemos tanto un off como un on anteriormente
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

;Se qued acon la ultima activacion
(defrule borrar_ultima_activacion
  (ultima_activacion ?tipo ?habitacion ?tiempo)
  ?Borrar <- (ultima_activacion ?tipo ?habitacion ?tiempo2)
  (test (> ?tiempo ?tiempo2))
  =>
  (retract ?Borrar)


)

;apagar o encender
;(defrule encender_movimiento_on
;  (ultima_activacion movimiento ?habitacion ?tiempo)
;  (ultimo_registro luminosidad ?habitacion ?t_luminosidad)
;  (valor_registrado ?t_luminosidad luminosidad ?habitacion ?valor)
;  (test (< (- ?valor ?luz) 400))
;  =>
;  (printout t crlf "Encender luz por movimiento")
;  (assert (accion pulsador_luz ?habitacion encender))
;)

;apaga cuando detecta un off
(defrule apagar_movimiento_off
  (ultima_desactivacion movimiento ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultimo_registro estadoluz ?habitacion ?t_luz)
  (valor_registrado ?t_luz estadoluz ?habitacion on)
  =>
  (assert (accion pulsador_luz ?habitacion apagar))
  ;(printout t crlf "parece apagado")

)

;regas para esperar 15 segundos antes de apagar luz
;(defrule esperar_segundos_off
;  (valor_registrado ?tiempo movimiento ?habitacion off)
;  ?Borrar <- (pareceapagado ?habitacion)
;  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
;  (test (> (- ?tiempo ?t_desactivacion) 14))
;  =>
;  ;(printout t crlf "ya no parece apagada lo esta")
;  (assert (accion pulsador_luz ?habitación apagar))
;  (retract ?Borrar)
;)



;Las siguentes reglas son las que se encargar de controlar la luminosidad

;apaga la luz por exceso de luminosidad sin tener un off anteriormente.
(defrule primer_apagar_luz_luminosidad_sin_off
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?)
  (not (ultima_desactivacion movimiento ?habitacion ?))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (>= (- ?valor ?luz) 400))
  (ultimo_registro luminosidad ?habitacion ?t_registro)
  (valor_registrado ?t_registro luminosidad ?habitacion on)
  =>
  (assert (accion pulsador_luz ?habitacion apagar))
  ;(printout t crlf "Luminosidad alta")

)
;apaga la luz teniendo anteriormeente un off
(defrule primer_apagar_luz_luminosidad_con_off
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?t_activacion)
  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (>= (- ?valor ?luz) 400))
  (ultimo_registro luminosidad ?habitacion ?t_registro)
  (valor_registrado ?t_registro luminosidad ?habitacion on)

  =>
  (assert (accion pulsador_luz ?habitacion apagar))
  ;(printout t crlf "Luminosidad alta")
)
;enciende la luz sin tenener antes un off
(defrule primer_encender_luz_luminosidad_sin_off
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?)
  (not (ultima_desactivacion movimiento ?habitacion ?))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (< ?valor 400))
  (not (ultimo_registro estadoluz ?habitacion ?t_luz))
  ;(valor_registrado ?t_luz estadoluz ?habitacion off)
  =>
  ;(printout t crlf "Encender luz luminosidad baja")
  (assert (accion pulsador_luz ?habitacion encender))
)
;enciende la luza teniendo anteriormente teninedo ya un registro de estado de la luz
(defrule primer_encender_luz_luminosidad_sin_off_con_inicio
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?)
  (not (ultima_desactivacion movimiento ?habitacion ?))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (< ?valor 400))
  (ultimo_registro estadoluz ?habitacion ?t_luz)
  (valor_registrado ?t_luz estadoluz ?habitacion off)
  =>
  ;(printout t crlf "Encender luz luminosidad baja")
  (assert (accion pulsador_luz ?habitacion encender))
)


;encender la luz teniendo ya un registro de off
(defrule primer_encender_luz_luminosidad_con_off
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?t_activacion)
  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (< (- ?valor ?luz) 400))
  (not (ultimo_registro estadoluz ?habitacion ?t_luz))
  ;(valor_registrado ?t_luz estadoluz ?habitacion off)
  =>

  ;(printout t crlf "Encender luz luminosidad baja")
  (assert (accion pulsador_luz ?habitacion encender))

)
;encender la luz con un registro de off y con un estadodeluz
(defrule primer_encender_luz_luminosidad_con_off_con_inicio
  (ultimo_registro luminosidad ?habitacion ?tiempo)
  (Manejo_inteligente_luces ?habitacion)
  (ultima_activacion movimiento ?habitacion ?t_activacion)
  (ultima_desactivacion movimiento ?habitacion ?t_desactivacion)
  (test (> ?t_activacion ?t_desactivacion))
  (valor_registrado ?tiempo luminosidad ?habitacion ?valor)
  (bombilla ?habitacion ?luz)
  (test (< (- ?valor ?luz) 400))
  (ultimo_registro estadoluz ?habitacion ?t_luz)
  (valor_registrado ?t_luz estadoluz ?habitacion off)
  =>

  ;(printout t crlf "Encender luz luminosidad baja")
  (assert (accion pulsador_luz ?habitacion encender))

)






;las tres siguientes reglas son par agenerar el informe
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

;(deffacts pruebas_valores


;    (valor_registrado 5 movimiento salon OFF)
;    (valor_registrado 10 movimiento salon ON)
;    (valor_registrado 12 luminosidad salon 500)
;    (valor_registrado 16 luminosidad salon 525)
;    (valor_registrado 16 luminosidad salon 550)




; )
