;;; QUICKREPLACE.LSP
;;; Replaces case-sensitive text within selected TEXT, MTEXT, and attributes.

(setq *JMQR-LAST-FIND* nil)

(defun jmqr:replace-all (source find replace / pos result start)
  (setq result "")
  (setq start 1)
  (while (setq pos (vl-string-search find source (1- start)))
    (setq result (strcat result (substr source start (- (+ pos 1) start)) replace))
    (setq start (+ pos (strlen find) 1))
  )
  (strcat result (substr source start))
)

(defun jmqr:update-entity (ent find replace / data old new count)
  (setq data (entget ent))
  (setq old (cdr (assoc 1 data)))
  (if old
    (progn
      (setq new (jmqr:replace-all old find replace))
      (if (/= old new)
        (progn
          (setq count 0)
          (while (vl-string-search find old count)
            (setq count (1+ (vl-string-search find old count)))
          )
          (entmod (subst (cons 1 new) (assoc 1 data) data))
          count
        )
        0
      )
    )
    0
  )
)

(defun jmqr:update-attributes (insert find replace / ent data count)
  (setq count 0)
  (if (= 1 (cdr (assoc 66 (entget insert))))
    (progn
      (setq ent (entnext insert))
      (while ent
        (setq data (entget ent))
        (if (= "SEQEND" (cdr (assoc 0 data)))
          (setq ent nil)
          (progn
            (if (= "ATTRIB" (cdr (assoc 0 data)))
              (setq count (+ count (jmqr:update-entity ent find replace)))
            )
            (setq ent (entnext ent))
          )
        )
      )
    )
  )
  count
)

(defun c:QUICKREPLACE (/ ss find replace i ent type total)
  (princ "\nQUICKREPLACE - case-sensitive text replacement")
  (setq ss (ssget "_I"))
  (if (not ss)
    (progn
      (princ "\nSelect text, mtext, attributes, or block references: ")
      (setq ss (ssget))
    )
  )
  (if ss
    (progn
      (if *JMQR-LAST-FIND*
        (progn
          (setq find
            (getstring T
              (strcat "\nString to find <" *JMQR-LAST-FIND* ">: " )
            )
          )
          (if (= find "")
            (setq find *JMQR-LAST-FIND*)
          )
        )
        (setq find (getstring T "\nString to find: "))
      )
      (if (= find "")
        (princ "\nThe search string cannot be empty.")
        (progn
          (setq *JMQR-LAST-FIND* find)
          (setq replace (getstring T "\nReplacement string: "))
          (setq i 0)
          (setq total 0)
          (while (< i (sslength ss))
            (setq ent (ssname ss i))
            (setq type (cdr (assoc 0 (entget ent))))
            (cond
              ((member type '("TEXT" "MTEXT" "ATTRIB"))
                (setq total (+ total (jmqr:update-entity ent find replace)))
              )
              ((= type "INSERT")
                (setq total (+ total (jmqr:update-attributes ent find replace)))
              )
            )
            (setq i (1+ i))
          )
          (princ (strcat "\nReplaced " (itoa total) " occurrence(s)."))
        )
      )
    )
    (princ "\nNothing selected.")
  )
  (princ)
)
