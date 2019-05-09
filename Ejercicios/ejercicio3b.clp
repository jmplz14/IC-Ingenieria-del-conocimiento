(defrule leerInforme
  ?borrar <- (leer informe)
  =>
  (open "fichero.txt" data "r")
  (bind ?data (readline data))
  (while (neq ?data EOF)
    (assert(TTT (explode$ ?data)))
     ;(printout t (explode$ ?data) crlf)
     (bind ?data (readline data)))
  (close data)
  (retract ?borrar)

)

(deffacts pruebas_valores
    (leer informe)



)
