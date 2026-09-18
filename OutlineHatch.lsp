(defun c:OutlineHatch (/ oldLayer ss i ent)
  (vl-load-com)
  
  (setq oldLayer (getvar "CLAYER"))

  ;; Ensure the Non-Plot layer exists
  (if (not (tblsearch "LAYER" "S-ANNO-NONPLOT"))
    (command "-layer" "M" "S-ANNO-NONPLOT" "C" "6" "" "")
  )

  (princ "\nSelect hatch(es) to outline: ")
  ;; Filter to ensure only hatches are selected
  (setq ss (ssget '((0 . "HATCH"))))

  (if ss
    (progn
      ;; Switch to Non-Plot layer
      (setvar "CLAYER" "S-ANNO-NONPLOT")
      
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        
        ;; Use HATCHEDIT to recreate the boundary
        ;; B = Boundary, P = Polyline, Y = Associate
        (command "._hatchedit" ent "_B" "_P" "_Y")
        
        (setq i (1+ i))
      )
      
      (setvar "CLAYER" oldLayer)
      (princ (strcat "\nSuccessfully outlined " (itoa (sslength ss)) " hatch(es)."))
    )
    (progn
      (setvar "CLAYER" oldLayer)
      (princ "\nNo hatches selected.")
    )
  )
  (princ)
)