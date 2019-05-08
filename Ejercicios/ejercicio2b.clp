(deffunction test ($?c)
(bind ?menor (expand$ (first$ ?c)))
(foreach ?field ?c
    (if (> ?menor ?field)
    then
      (bind ?menor ?field))
    ;printout t "--> " ?field " " ?field-index " <--"  ?menor crlf
  )
  (printout t ?menor)
crlf)
