(defun c:QQ (/ cat opt pt old_osnap)
  ;; --- GLOBAL RESET ---
  (setvar "NOMUTT" 0) 
  (setvar "PLINEWID" 0)
  (setvar "CELTYPE" "ByLayer")
  (setvar "CECOLOR" "ByLayer")

  ;; LEVEL 1: Main Categories
  (initget "1 2 3")
  (setq cat (getkword "\nQuickDraw: [1-Lines/2-Blocks/3-Hatches]: "))

  (cond
    ;; --- 1: LINES ---
    ((= cat "1")
     (initget "1 2 3")
     (setq opt (getkword "\nLines: [1-Finishes/2-Membrane/3-Rebar]: "))
     (cond
       ((= opt "1") ;; FINISHES
        (setvar "CLAYER" "S-ARCH-FINISHES")
        (command "_.pline"))
       
       ((= opt "2") ;; MEMBRANE
        (setvar "CLAYER" "S-MEMBRANE")
        (setvar "CELTYPE" "HIDDEN2")
        (setvar "CECOLOR" "4")       ; Cyan Override
        (setvar "PLINEWID" 0.25)     ; 1/4" Width
        (princ "\nDrawing Cyan Membrane...")
        (command "_.pline")
        (while (> (getvar "CMDACTIVE") 0) (command pause))
        (setvar "CELTYPE" "ByLayer")
        (setvar "CECOLOR" "ByLayer")
        (setvar "PLINEWID" 0))

       ((= opt "3") ;; REBAR
        (setvar "CLAYER" "S-REBAR")
        (command "_.pline"))
     )
    )

    ;; --- 2: BLOCKS ---
    ((= cat "2")
     (initget "1 2 3 4")
     (setq opt (getkword "\nBlocks: [1-PLY-0.5/2-PLY-0.75/3-Chair/4-Desk]: "))
     (cond
       ((= opt "1") ;; PLYWOOD 0.5
        (setq old_osnap (getvar "OSMODE"))
        (setq pt (getpoint "\nPick insertion point for PLY-0.5: "))
        (if pt
          (progn
            (setvar "OSMODE" 0)
            (command "-insert" "PLY-0.5" pt "1" "1" pause)
            (setvar "OSMODE" old_osnap))))

       ((= opt "2") ;; PLYWOOD 0.75
        (setq old_osnap (getvar "OSMODE"))
        (setq pt (getpoint "\nPick insertion point for PLY-0.75: "))
        (if pt
          (progn
            (setvar "OSMODE" 0)
            (command "-insert" "PLY-0.75" pt "1" "1" pause)
            (setvar "OSMODE" old_osnap))))
       
       ((= opt "3") (command "-insert" "CHAIR_BLOCK" pause "1" "1" "0"))
       ((= opt "4") (command "-insert" "DESK_BLOCK" pause "1" "1" "0"))
     )
    )

    ;; --- 3: HATCHES ---
    ((= cat "3")
     (initget "1 2")
     (setq opt (getkword "\nHatches: [1-Concrete/2-Sand]: "))
     (cond
       ((= opt "1") 
        (setvar "CLAYER" "S-HATCH")
        (command "-bhatch" "p" "AR-CONC" "1" "0"))
       ((= opt "2") 
        (setvar "CLAYER" "S-HATCH")
        (command "-bhatch" "p" "AR-SAND" "1" "0"))
     )
    )
  )
  (princ)
)