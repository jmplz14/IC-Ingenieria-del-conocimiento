(defrule anadirPrimero
  (hecho ?tipo $?)
  =>
  (assert (Contar ?tipo))
)

(defrule contarPrimerHecho
  ?borrar <- (Contar ?tipo)
  (not (NumeroHechos ?tipo ?))
  =>
  (assert (NumeroHechos ?tipo 1))
  (retract ?borrar)
)

(defrule aumentar
  ?borrar <- (Contar ?tipo)
  ?borrar2 <- (NumeroHechos ?tipo ?num)
  =>
  (assert (NumeroHechos ?tipo (+ ?num 1)))
  (retract ?borrar)
  (retract ?borrar2)

)

(defrule contar
  (ContarHechos ?tipo)
  (NumeroHechos ?tipo ?n)
  =>
  (printout t "Existen " ?n " de tipo " ?tipo crlf)
)



(deffacts pruebas_valores
    (hecho casa 5)
    (hecho piso 147)
    (hecho casa 6)
    (hecho piso 1)
    (hecho piso 6)
    (hecho piso 8)
    (hecho piso 66)
    (hecho piso 2)
    ;(ContarHechos piso)
    ;(NumeroHechos piso 1)
    ;(ContarHechos piso)
)
