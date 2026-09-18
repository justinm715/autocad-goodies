(defun c:ZERO (/ ss i ent)
  (setvar "CMDECHO" 0)
  (setvar "QAFLAGS" 1)
  
  ;; 1. Force everything to be visible and editable
  (princ "\nUnlocking and Thawing all layers...")
  (command "_.layer" "_unl" "*" "_thaw" "*" "_on" "*" "")

  ;; 2. Explode Blocks individually (Safety First)
  (princ "\nRecursively exploding blocks...")
  (setq continue T)
  (while continue
    (setq continue nil)
    (if (setq ss (ssget "_X" '((0 . "INSERT"))))
      (progn
        (setq i 0)
        (repeat (sslength ss)
          (setq ent (ssname ss i))
          (setq name (cdr (assoc 2 (entget ent))))
          ;; Skip Anonymous Blocks (Hatches/Dimensions)
          (if (and name (not (wcmatch name "`**")))
            (progn
              (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-explode (list (vlax-ename->vla-object ent))))
                (princ (strcat "\nSkipped non-explodable block: " name))
                (progn 
                  (entdel ent) ;; Delete original after exploding
                  (setq continue T)
                )
              )
            )
          )
          (setq i (1+ i))
        )
      )
    )
  )

  ;; 3. Massive Property Reset
  (princ "\nMoving all objects to Layer 0 and setting ByLayer...")
  (if (setq ss (ssget "_X"))
    (progn
      ;; We use "All" instead of passing the variable to avoid the 'Invalid Selection' error
      (command "_.CHPROP" "_ALL" "" "_LA" "0" "_C" "BYLAYER" "_LT" "BYLAYER" "_LW" "BYLAYER" "")
      
      ;; 4. SetByLayer (The Revit-override killer)
      (princ "\nStripping hardcoded colors...")
      (command "_.SETBYLAYER" "_ALL" "" "_Yes" "_Yes")
    )
  )

  (setvar "QAFLAGS" 32)
  (command "_.AUDIT" "_Y")
  (princ "\n--- CLEANUP COMPLETE ---")
  (setvar "CMDECHO" 1)
  (princ)
)