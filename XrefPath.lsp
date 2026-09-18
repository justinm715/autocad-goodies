(defun c:XREFPATH (/ ent blk pth full)
  (setq ent (car (entsel "\nSelect Xref to copy FULL path: ")))
  ;; Check if user selected something and get the block name
  (if (and ent (setq blk (cdr (assoc 2 (entget ent)))))
    (progn
      ;; Get the path stored in the block table
      (setq pth (cdr (assoc 1 (tblsearch "BLOCK" blk))))
      (if pth
        (progn
          ;; findfile resolves relative paths to absolute paths
          (setq full (findfile pth))
          (if full
            (progn
              ;; Send to Windows Clipboard
              (startapp "cmd.exe" (strcat "/c echo " full " | clip"))
              (princ (strcat "\nAbsolute path copied: " full))
            )
            (princ "\nError: Could not resolve full path. Is the Xref missing?")
          )
        )
        (princ "\nObject is a block, not an Xref.")
      )
    )
  )
  (princ)
)