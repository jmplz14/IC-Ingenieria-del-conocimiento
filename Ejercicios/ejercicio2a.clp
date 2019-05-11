(deftemplate TTT
   (slot SSS (type NUMBER))
)

(deffunction minxit ()
  (bind ?menor 0)
  (bind ?indice 0)
  (do-for-all-facts ((?T TTT)) TRUE
    (if (= ?indice 0)
    then
      (bind ?menor ?T:SSS)
      (bind ?indice 1)
    else
      (if (> ?menor ?T:SSS)
      then
        (bind ?menor ?T:SSS)
      )
    )

  )
?menor
)

(deffacts pruebas_valores
 (TTT (SSS 3))
 (TTT (SSS 1))
 (TTT (SSS 2))
 (TTT (SSS 2))
 (TTT (SSS 4))
 (TTT (SSS 3))
)
