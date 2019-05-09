(deffunction minxit ($?c)
(bind ?menor (expand$ (first$ ?c)))
(foreach ?field ?c
    (if (> ?menor ?field)
    then
      (bind ?menor ?field))
    ;printout t "--> " ?field " " ?field-index " <--"  ?menor crlf
  )
  (printout t "El menor de " ?c " es " ?menor crlf)
)

(defrule pruebaFuncion
  (TTT $?numeros)
  =>
  (minxit $?numeros)

)

(deffacts pruebas_valores
    (TTT 5 6 7 9 6 9 6 9 6 9 6 9 6 9 47 2)






)
