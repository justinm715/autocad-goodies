(defun c:GOODIES ()
  (princ "\nOpening AutoCAD Goodies folder...")
  (startapp "explorer" "C:\\Users\\justin\\Desktop\\01 Files\\02 Goodies\\AutoCAD")
  (princ)
)

(defun c:JMGOODIES (/ folder goodies file entry)
  ;; Print a command cheat sheet for the LISP files in the Goodies folder.
  (setq folder "C:\\Users\\justin\\Desktop\\01 Files\\02 Goodies\\AutoCAD\\")
  (setq goodies
    '(
      ("DASHBETWEEN" "DashBetween.lsp" "Makes selected linework hidden between boundary objects.")
      ("DEBLOCK" "Deblock.lsp" "Recursively explodes all named blocks in the drawing.")
      ("GOODIES" "JMGoodies.lsp" "Opens the AutoCAD Goodies folder in Windows Explorer.")
      ("KILLBLOCK" "KillBlock.lsp" "Selects and deletes named block definitions from the drawing.")
      ("OUTLINEHATCH" "OutlineHatch.lsp" "Creates a closed outline around selected hatch objects.")
      ("POLYHATCHEARTH" "PolyHatchEarth.lsp" "Creates an earth hatch inside a selected closed boundary.")
      ("QUICKREPLACE" "QuickReplace.lsp" "Replaces case-sensitive text within selected text and attributes.")
      ("QQ" "QuickDraw.lsp" "Provides quick-access tools for lines, blocks, and hatches.")
      ("QSW" "QuickSwitchLayers.lsp" "Switches quickly between commonly used structural layers.")
      ("XREFPATH" "XrefPath.lsp" "Copies the full file path of a selected external reference.")
      ("ZERO" "Zero.lsp" "Unlocks, thaws, and turns on layers, then recursively explodes blocks.")
      ("ZOOMTOXREF" "ZoomToXref.lsp" "Finds and zooms to external references by name or wildcard.")
    )
  )

  (princ "\n\nAUTOCAD GOODIES COMMANDS")
  (princ "\n------------------------")
  (foreach entry goodies
    (setq file (findfile (strcat folder (cadr entry))))
    (if file
      (princ
        (strcat
          "\n- " (car entry) ": " (caddr entry)
        )
      )
    )
  )
  (princ "\n------------------------")
  (princ "\nType any command above at the AutoCAD command line.")
  (princ)
)
