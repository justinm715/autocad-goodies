(defun c:KillBlock (/ blk blkName blkList sortedList ss count target)
  (setq blk (tblnext "BLOCK" T))
  (setq blkList '())

  ;; 1. Collect all non-anonymous block names
  (while blk
    (setq blkName (cdr (assoc 2 blk)))
    ;; Filter out anonymous blocks and Xrefs (names starting with * or containing |)
    (if (and (not (wcmatch blkName "`**"))
             (not (vl-string-search "|" blkName)))
      (setq blkList (cons blkName blkList))
    )
    (setq blk (tblnext "BLOCK"))
  )

  ;; 2. Sort names alphabetically
  (setq sortedList (acad_strlsort blkList))

  ;; 3. Print the report to the Command Line
  (princ "\n\n--- BLOCK INVENTORY ---")
  (foreach n sortedList
    (if (setq ss (ssget "X" (list (cons 0 "INSERT") (cons 2 n))))
      (setq count (sslength ss))
      (setq count 0)
    )
    (princ (strcat "\n" (if (< count 10) " " "") (itoa count) "x \t" n))
  )
  (princ "\n-----------------------\n")

  ;; 4. Prompt for the kill target
  (setq target (getstring T "\nEnter block name to remove (or Esc to exit): "))

  (if (and target (/= target ""))
    (progn
      (if (setq ss (ssget "X" (list (cons 0 "INSERT") (cons 2 target))))
        (progn
          (command "._ERASE" ss "")
          (princ (strcat "\nErased " (itoa (sslength ss)) " instances of '" target "'."))
        )
        (princ (strcat "\nNo instances of '" target "' to erase."))
      )
      (command "._-PURGE" "B" target "N")
      (princ (strcat "\nDefinition for '" target "' has been purged."))
    )
    (princ "\nRoutine cancelled.")
  )
  (princ)
)