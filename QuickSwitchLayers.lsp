(defun c:QSW (/ choice layer)
  (initget "1 2 3 4 5 6 7 8 9")
  (setq choice
    (getkword
      "\nSelect Layer [1=DESIGNER COMMENTS / 2=S-WOOD / 3=S-STEEL / 4=S-CONC / 5=S-SIMPSON / 6=S-ARCH / 7=S-ARCH-FINISHES / 8=S-ANNO-DIMS / 9=S-XREF-BACKGROUND]: "
    )
  )

  (setq layer
    (cond
      ((= choice "1") "DESIGNER COMMENTS")
      ((= choice "2") "S-WOOD")
      ((= choice "3") "S-STEEL")
      ((= choice "4") "S-CONC")
      ((= choice "5") "S-SIMPSON")
      ((= choice "6") "S-ARCH")
      ((= choice "7") "S-ARCH-FINISHES")
      ((= choice "8") "S-ANNO-DIMS")
      ((= choice "9") "S-XREF-BACKGROUND")
    )
  )

  (if layer
    (progn
      (command "_.-layer" "_make" layer "")
      (setvar "CLAYER" layer)
      (princ (strcat "\nSwitched to layer: " layer))
    )
  )
  (princ)
)