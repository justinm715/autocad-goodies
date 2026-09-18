(defun c:ZOOMTOXREF (/ xref_name ss)
  (setvar "CMDECHO" 0)
  
  ;; 1. Ask for the Xref name
  (setq xref_name (getstring T "\nEnter Xref name to find (wildcards * allowed): "))

  (if (/= xref_name "")
    (progn
      ;; 2. Select only 'INSERT' objects (Xrefs) that match the name
      ;; We use (0 . "INSERT") because Xrefs are technically insertions
      (setq ss (ssget "_X" (list '(0 . "INSERT") (cons 2 xref_name))))
      
      (if ss
        (progn
          ;; 3. Highlight/Grip the Xref
          (sssetfirst nil ss)
          
          ;; 4. Zoom to fit the Xref on screen
          (command "_.zoom" "_object" ss "")
          
          (princ (strcat "\nLocated " (itoa (sslength ss)) " instance(s) of Xref: " xref_name))
        )
        (princ (strcat "\nCould not find an Xref named: " xref_name))
      )
    )
    (princ "\nNo name entered.")
  )
  (princ)
)