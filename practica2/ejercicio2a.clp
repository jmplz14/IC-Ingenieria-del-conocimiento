;(deftemplate ultima_activacion
;   (slot tiempo (type NUMBER))
;   (slot habitacion)
;   (slot tipo)
;)


(deffunction count-facts-2 (?template)
(length (find-all-facts ((?fct ?template)) TRUE)))

(defrule prueba
  (iniciar)
  =>
  (printout t (count-facts-2 ultima_activacion) crlf)
)

(deffacts pruebas_valores
 ;(TTT (SSS 3))
 ;(TTT (SSS 1))
 ;(TTT (SSS 2))
 ;(TTT (SSS 2))
 ;(TTT (SSS 4))
 ;(TTT (SSS 3))
 ;(ultima_activacion (tiempo 2) (habitacion dormitorio) (tipo movimiento))
 ;(ultima_activacion (tiempo 5) (habitacion dormitorio) (tipo movimiento))
 ;(ultima_activacion (tiempo 6) (habitacion dormitorio) (tipo movimiento))
 ;(ultima_activacion (tiempo 3) (habitacion dormitorio) (tipo movimiento))
 (ultima_activacion 2 dormitorio movimiento)
 (ultima_activacion 4 dormitorio movimiento)
 (ultima_activacion 5 dormitorio movimiento)
 (ultima_activacion 6 dormitorio movimiento)
 ;(count-facts-2 boy)
 (iniciar)
)
