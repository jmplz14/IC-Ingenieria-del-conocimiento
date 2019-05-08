(defrule resetear
  ?borrar <- (ContarHechos ?tipo)
  ?borrar2 <- (NumeroHechos ?tipo ?)
  =>
  (retract ?borrar)
  (retract ?borrar2)
  (assert (IniciarCuenta ?tipo))

)

(defrule resetear2
  ?borrar <- (ContarHechos ?tipo)
  (not (NumeroHechos ?tipo ?))
  =>
  (retract ?borrar)
  (assert (IniciarCuenta ?tipo))

)

(defrule anadirPrimero
  (IniciarCuenta ?tipo)
  (hecho ?tipo $?)
  =>
  (assert (Contar ?tipo))

)

(defrule eliminarIniciar
  ?borrar <-(IniciarCuenta ?tipo)
  =>
  (retract ?borrar)
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



(deffacts pruebas_valores
    (hecho casa 5)
    (hecho piso 147)
    (hecho casa 6)
    (hecho piso 1)
    (hecho piso 6)
    (hecho piso 8)
    (hecho piso 66)
    (hecho piso 2)
    (ContarHechos piso)
    (hecho piso 665)
    (hecho piso 22)




)
