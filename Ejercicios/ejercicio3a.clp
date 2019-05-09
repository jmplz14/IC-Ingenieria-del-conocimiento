(defrule inicio
  (escribir informe)
  (TTT $?numeros)
  (not (listado $?numeros))
  =>
  (assert (listado ?numeros))

)

(defrule limpiar
  ?borrar <- (escribir informe)
  (not
    (and(TTT $?numeros)
      (not (listado $?numeros))
    )
  )
  =>
  (retract ?borrar)
)

(defrule imprimeInforme
  (not (escribir informe))
  ?Borrar <- (listado $?numeros)
  (not (listado $?numeros2&: (> (nth$ 1 $?numeros2) (nth$ 1 $?numeros))))
  =>
  (open "fichero.txt" datos "a")
  ;(printout datos $?numeros crlf)
  (foreach ?field ?numeros

      (printout datos ?field " ")
    )
    (printout datos crlf)
  (retract ?Borrar)
  (close datos)
)

(deffacts pruebas_valores
    (TTT 15 44 7 8 33)
    (TTT 10 22 3 6 88)
    (TTT 2 6 8 11 5)
    (TTT 9 6 33 5 44)
    (TTT 6 88 99 66 5)
    (escribir informe)



)
