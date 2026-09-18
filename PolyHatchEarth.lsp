(defun c:PolyHatchEarth (/ ent dist side p1 p2 p3 p4 ent2 L1 L2 finalBound oldLayer)
  (vl-load-com)
  
  (setq oldLayer (getvar "CLAYER"))

  ;; Layer Check/Creation
  (if (not (tblsearch "LAYER" "S-ANNO-NONPLOT"))
    (command "-layer" "M" "S-ANNO-NONPLOT" "C" "6" "" "")
  )
  (if (not (tblsearch "LAYER" "S-HATCH-SOIL"))
    (command "-layer" "M" "S-HATCH-SOIL" "C" "42" "" "")
  )

  (setq ent (car (entsel "\nSelect polyline to offset: ")))
  
  (if ent
    (progn
      (setq dist (getdist "\nSpecify offset distance: "))
      (setq side (getpoint "\nSpecify side to offset: "))
      
      (setvar "CLAYER" "S-ANNO-NONPLOT")
      
      ;; 1. Offset
      (command "._offset" dist ent side "")
      (setq ent2 (entlast))
      
      ;; 2. Get coordinates
      (setq p1 (vlax-curve-getStartPoint ent))
      (setq p2 (vlax-curve-getEndPoint ent))
      (setq p3 (vlax-curve-getStartPoint ent2))
      (setq p4 (vlax-curve-getEndPoint ent2))
      
      ;; 3. Draw caps
      (command "._line" "_non" p1 "_non" p3 "")
      (setq L1 (entlast))
      (command "._line" "_non" p2 "_non" p4 "")
      (setq L2 (entlast))
      
      ;; 4. Move original to Non-Plot and Join
      (command "._chprop" ent "" "LA" "S-ANNO-NONPLOT" "")
      (command "._pedit" ent "J" ent2 L1 L2 "" "")
      (setq finalBound (entlast))
      
      ;; 5. Hatch - Layer S-HATCH-SOIL | Pattern EARTH | Scale 10 | Angle 45
      (setvar "CLAYER" "S-HATCH-SOIL")
      (setvar "HPCOLOR" "ByLayer")
      
      ;; Parameters: Pattern, Scale 10, Angle 45
      (command "-hatch" "P" "EARTH" "10.0" "45" "S" finalBound "" "")
      
      (setvar "CLAYER" oldLayer)
      (princ "\nSoil hatch (Scale 10, Angle 45) created on S-HATCH-SOIL.")
    )
    (progn
      (setvar "CLAYER" oldLayer)
      (princ "\nNo object selected.")
    )
  )
  (princ)
)