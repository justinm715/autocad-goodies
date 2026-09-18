(defun c:DEBLOCK (/ ss prevCount currCount)
  (setvar "CMDECHO" 0)
  (setvar "QAFLAGS" 1)

  (princ "\nExploding all named blocks recursively...")

  (setq prevCount -1)

  (while
    (progn
      (setq ss (ssget "_X" '((0 . "INSERT") (-4 . "<NOT") (2 . "`**") (-4 . "NOT>"))))
      (setq currCount (if ss (sslength ss) 0))

      (and ss (/= currCount prevCount))
    )
    (setq prevCount currCount)
    (command "_.explode" ss "")
  )

  (setvar "QAFLAGS" 32)
  (princ "\nExplosion complete.")
  (princ)
)