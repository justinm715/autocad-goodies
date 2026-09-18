;;; =====================================================================
;;; DASHBETWEEN.LSP
;;;
;;; AutoCAD / AutoCAD LT 2026
;;;
;;; COMMAND:
;;;   DASHBETWEEN
;;;
;;; PURPOSE:
;;;   Makes portions of selected LINEs / LWPOLYLINEs HIDDEN where they
;;;   lie between selected boundary objects.
;;;
;;; WORKS WITH:
;;;   - LINE
;;;   - LWPOLYLINE
;;;   - RECTANGLE (closed LWPOLYLINE)
;;;
;;; IMPORTANT:
;;;   Straight polyline segments only.
;;;   Bulged/arc polyline segments are not supported.
;;;
;;; HOW IT WORKS:
;;;   1. Select boundary objects.
;;;   2. Select objects to modify.
;;;   3. Each straight segment of each selected object is processed
;;;      independently.
;;;   4. Intersection points are sorted along that segment.
;;;   5. Alternating portions between intersections become HIDDEN.
;;;
;;; EXAMPLE:
;;;
;;;        |                 +-----+
;;;   -----+-----       -----+-----+-----
;;;        |                 :     :
;;;   -----+-----       -----+-----+-----
;;;        |                 +-----+
;;;
;;;   A vertical LINE works.
;;;   A vertical RECTANGLE works on BOTH vertical sides.
;;;
;;; NOTE:
;;;   A polyline must be separated into individual LINE pieces because
;;;   AutoCAD cannot assign a different linetype to only part of one
;;;   LWPOLYLINE entity.
;;;
;;; =====================================================================


(defun c:DASHBETWEEN
  (
    /
    *error*
    oldecho
    oldosmode
    bss
    oss
    i
    ent
  )

  ;; ---------------------------------------------------------------
  ;; Save settings
  ;; ---------------------------------------------------------------

  (setq oldecho  (getvar "CMDECHO"))
  (setq oldosmode (getvar "OSMODE"))


  ;; ---------------------------------------------------------------
  ;; Error handler
  ;; ---------------------------------------------------------------

  (defun *error* (msg)

    (setvar "CMDECHO" oldecho)
    (setvar "OSMODE" oldosmode)

    (if
      (and
        msg
        (/= msg "Function cancelled")
        (/= msg "quit / exit abort")
      )
      (princ (strcat "\nError: " msg))
    )

    (princ)
  )


  ;; ---------------------------------------------------------------
  ;; Settings
  ;; ---------------------------------------------------------------

  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)


  ;; ---------------------------------------------------------------
  ;; Make sure HIDDEN exists
  ;; ---------------------------------------------------------------

  (DB:LoadHidden)


  ;; ---------------------------------------------------------------
  ;; Select boundaries
  ;; ---------------------------------------------------------------

  (prompt
    "\nSelect boundary LINE(s), polyline(s), or rectangle(s): "
  )

  (setq bss
    (ssget
      '(
        (-4 . "<OR")
        (0 . "LINE")
        (0 . "LWPOLYLINE")
        (-4 . "OR>")
       )
    )
  )


  ;; ---------------------------------------------------------------
  ;; Continue only if boundaries selected
  ;; ---------------------------------------------------------------

  (if bss

    (progn

      ;; -----------------------------------------------------------
      ;; Select objects to dash
      ;; -----------------------------------------------------------

      (prompt
        "\nSelect LINE(s), polyline(s), or rectangle(s) to dash: "
      )

      (setq oss
        (ssget
          '(
            (-4 . "<OR")
            (0 . "LINE")
            (0 . "LWPOLYLINE")
            (-4 . "OR>")
           )
        )
      )


      (if oss

        (progn

          (command "_.UNDO" "_Begin")

          (setq i 0)

          (repeat (sslength oss)

            (setq ent (ssname oss i))
            (setq i (1+ i))

            ;; Don't modify boundary geometry
            (if (not (ssmemb ent bss))

              (DB:ProcessEntity ent bss)

            )

          )

          (command "_.UNDO" "_End")

          (princ "\nDASHBETWEEN complete.")

        )

        (princ "\nNo objects selected.")

      )

    )

    (princ "\nNo boundary objects selected.")

  )


  ;; ---------------------------------------------------------------
  ;; Restore settings
  ;; ---------------------------------------------------------------

  (setvar "CMDECHO" oldecho)
  (setvar "OSMODE" oldosmode)

  (princ)
)



;;; =====================================================================
;;; DB:LoadHidden
;;; =====================================================================

(defun DB:LoadHidden ()

  (if (not (tblsearch "LTYPE" "HIDDEN"))

    (progn

      ;; Try imperial file first

      (command
        "_.-LINETYPE"
        "_Load"
        "HIDDEN"
        "acad.lin"
        ""
      )


      ;; Try ISO file if needed

      (if (not (tblsearch "LTYPE" "HIDDEN"))

        (command
          "_.-LINETYPE"
          "_Load"
          "HIDDEN"
          "acadiso.lin"
          ""
        )

      )

    )

  )

)



;;; =====================================================================
;;; DB:ProcessEntity
;;;
;;; Process every straight segment independently.
;;; =====================================================================

(defun DB:ProcessEntity
  (ent bss / ed typ segs seg originalED)

  (setq originalED (entget ent))
  (setq typ        (cdr (assoc 0 originalED)))


  ;; ---------------------------------------------------------------
  ;; LINE
  ;; ---------------------------------------------------------------

  (if (= typ "LINE")

    (DB:ProcessSegment
      ent
      (cdr (assoc 10 originalED))
      (cdr (assoc 11 originalED))
      originalED
      bss
      T
    )


    ;; -------------------------------------------------------------
    ;; LWPOLYLINE
    ;;
    ;; Process each side separately.
    ;; The original is removed after its replacement pieces are made.
    ;; -------------------------------------------------------------

    (if (= typ "LWPOLYLINE")

      (progn

        (setq segs (DB:GetSegments ent))

        ;; Create replacements for every segment.

        (foreach seg segs

          (DB:ProcessRawSegment
            (car seg)
            (cadr seg)
            originalED
            bss
          )

        )

        ;; Remove original polyline only after all replacement
        ;; geometry has been successfully created.

        (entdel ent)

      )

    )

  )

)



;;; =====================================================================
;;; DB:ProcessSegment
;;;
;;; Used for a LINE entity.
;;; =====================================================================

(defun DB:ProcessSegment
  (ent a b ed bss deleteOriginal / pts)

  (setq pts
    (DB:GetSegmentBoundaryPoints a b bss)
  )

  (if (>= (length pts) 2)

    (progn

      (setq pts
        (DB:SortPointsOnSegment a pts)
      )

      ;; Delete original before replacing it

      (if deleteOriginal
        (entdel ent)
      )

      (DB:CreateSplitSegment
        a
        b
        pts
        ed
      )

    )

    ;; No useful boundary pair.
    ;; Leave LINE untouched.

  )

)



;;; =====================================================================
;;; DB:ProcessRawSegment
;;;
;;; Used for individual sides of a polyline.
;;; Always creates replacement geometry because the original polyline
;;; will ultimately be removed.
;;; =====================================================================

(defun DB:ProcessRawSegment
  (a b ed bss / pts)

  (setq pts
    (DB:GetSegmentBoundaryPoints a b bss)
  )

  (if (>= (length pts) 2)

    (progn

      (setq pts
        (DB:SortPointsOnSegment a pts)
      )

      (DB:CreateSplitSegment
        a
        b
        pts
        ed
      )

    )

    ;; No two intersections:
    ;; simply recreate this side unchanged.

    (DB:CreateLineLike
      ed
      a
      b
      nil
    )

  )

)



;;; =====================================================================
;;; DB:GetSegmentBoundaryPoints
;;;
;;; Find all intersections between one straight segment and all selected
;;; boundary entities.
;;; =====================================================================

(defun DB:GetSegmentBoundaryPoints
  (a b bss / pts i bent bsegs bs ip)

  (setq pts '())
  (setq i 0)

  (repeat (sslength bss)

    (setq bent (ssname bss i))
    (setq i (1+ i))

    (setq bsegs
      (DB:GetSegments bent)
    )

    (foreach bs bsegs

      (setq ip
        (inters
          a
          b
          (car bs)
          (cadr bs)
          T
        )
      )

      (if ip

        (setq pts
          (DB:AddUniquePoint ip pts)
        )

      )

    )

  )

  pts
)



;;; =====================================================================
;;; DB:SortPointsOnSegment
;;; =====================================================================

(defun DB:SortPointsOnSegment
  (start pts)

  (vl-sort
    pts
    '(lambda (p1 p2)
       (<
         (distance start p1)
         (distance start p2)
       )
     )
  )

)



;;; =====================================================================
;;; DB:CreateSplitSegment
;;;
;;; Given:
;;;
;;;   A -------- P1 -------- P2 -------- B
;;;
;;; creates:
;;;
;;;   A -> P1       original linetype
;;;   P1 -> P2      HIDDEN
;;;   P2 -> B       original linetype
;;;
;;; With more intersections:
;;;
;;;   A-P1 = solid
;;;   P1-P2 = hidden
;;;   P2-P3 = solid
;;;   P3-P4 = hidden
;;;   etc.
;;; =====================================================================

(defun DB:CreateSplitSegment
  (a b pts ed / allpts idx p1 p2 hidden)

  ;; Include original endpoints

  (setq allpts
    (append
      (list a)
      pts
      (list b)
    )
  )

  (setq idx 0)

  (while (> (length allpts) 1)

    (setq p1 (car allpts))
    (setq p2 (cadr allpts))


    ;; -------------------------------------------------------------
    ;; Interval 0 = normal
    ;; Interval 1 = hidden
    ;; Interval 2 = normal
    ;; Interval 3 = hidden
    ;; etc.
    ;; -------------------------------------------------------------

    (setq hidden
      (= (rem idx 2) 1)
    )


    ;; Avoid zero-length pieces

    (if (> (distance p1 p2) 1e-8)

      (if hidden

        (DB:CreateLineLike
          ed
          p1
          p2
          "HIDDEN"
        )

        (DB:CreateLineLike
          ed
          p1
          p2
          nil
        )

      )

    )


    (setq idx (1+ idx))
    (setq allpts (cdr allpts))

  )

)



;;; =====================================================================
;;; DB:GetSegments
;;;
;;; Converts LINE or LWPOLYLINE to straight segments.
;;;
;;; Bulged/arc polyline segments are treated as straight chords.
;;; =====================================================================

(defun DB:GetSegments
  (ent / ed typ verts closed segs first work)

  (setq ed   (entget ent))
  (setq typ  (cdr (assoc 0 ed)))
  (setq segs '())


  (cond


    ;; -------------------------------------------------------------
    ;; LINE
    ;; -------------------------------------------------------------

    ((= typ "LINE")

      (setq segs
        (list
          (list
            (cdr (assoc 10 ed))
            (cdr (assoc 11 ed))
          )
        )
      )

    )


    ;; -------------------------------------------------------------
    ;; LWPOLYLINE
    ;; -------------------------------------------------------------

    ((= typ "LWPOLYLINE")

      (setq verts '())

      ;; Collect vertices

      (foreach x ed

        (if (= (car x) 10)

          (setq verts
            (append
              verts
              (list (cdr x))
            )
          )

        )

      )


      (if (> (length verts) 1)

        (progn

          (setq first (car verts))
          (setq work verts)

          ;; Consecutive segments

          (while (> (length work) 1)

            (setq segs
              (append
                segs
                (list
                  (list
                    (car work)
                    (cadr work)
                  )
                )
              )
            )

            (setq work (cdr work))

          )


          ;; Closed flag

          (setq closed
            (= 1
               (logand
                 1
                 (cdr (assoc 70 ed))
               )
            )
          )


          ;; Last vertex back to first

          (if closed

            (setq segs
              (append
                segs
                (list
                  (list
                    (car work)
                    first
                  )
                )
              )
            )

          )

        )

      )

    )

  )

  segs
)



;;; =====================================================================
;;; DB:AddUniquePoint
;;; =====================================================================

(defun DB:AddUniquePoint
  (p lst / found q tol)

  (setq tol 1e-8)
  (setq found nil)

  (foreach q lst

    (if (< (distance p q) tol)
      (setq found T)
    )

  )

  (if found
    lst
    (append lst (list p))
  )

)



;;; =====================================================================
;;; DB:CreateLineLike
;;;
;;; Creates a LINE while preserving:
;;;   layer
;;;   color
;;;   lineweight
;;;   linetype
;;;   linetype scale
;;;   thickness
;;;   extrusion
;;;
;;; newLT:
;;;   nil      = preserve original
;;;   "HIDDEN" = force HIDDEN
;;; =====================================================================

(defun DB:CreateLineLike
  (ed p1 p2 newLT / data)

  (setq data
    (list
      '(0 . "LINE")
      (cons 10 p1)
      (cons 11 p2)
    )
  )


  ;; Layer

  (if (assoc 8 ed)

    (setq data
      (append
        data
        (list (assoc 8 ed))
      )
    )

  )


  ;; Color

  (if (assoc 62 ed)

    (setq data
      (append
        data
        (list (assoc 62 ed))
      )
    )

  )


  ;; Lineweight

  (if (assoc 370 ed)

    (setq data
      (append
        data
        (list (assoc 370 ed))
      )
    )

  )


  ;; Linetype

  (if newLT

    (setq data
      (append
        data
        (list (cons 6 newLT))
      )
    )

    (if (assoc 6 ed)

      (setq data
        (append
          data
          (list (assoc 6 ed))
        )
      )

    )

  )


  ;; Linetype scale

  (if (assoc 48 ed)

    (setq data
      (append
        data
        (list (assoc 48 ed))
      )
    )

  )


  ;; Thickness

  (if (assoc 39 ed)

    (setq data
      (append
        data
        (list (assoc 39 ed))
      )
    )

  )


  ;; Extrusion

  (if (assoc 210 ed)

    (setq data
      (append
        data
        (list (assoc 210 ed))
      )
    )

  )


  ;; Create entity

  (entmakex data)

)



;;; =====================================================================
;;; Loaded message
;;; =====================================================================

(princ
  "\nDASHBETWEEN.LSP loaded. Type DASHBETWEEN to run."
)

(princ)