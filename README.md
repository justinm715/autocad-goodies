# Blocks

---



---


# 🏗️ AutoCAD LT 2026: Workspace & LISP Readme

## 1. Loading the Goodies
1. Type `APPLOAD`.
2. Click **Load** and select `JMGoodies.lsp`.
3. At the AutoCAD command line, type `JMGOODIES` to display the available commands and descriptions.
4. Load any individual LISP file with `APPLOAD` when you need to use its command.

### Printer Support File Path
1. Type `OPTIONS` and open the **Files** tab.
2. Expand **Printer Support File Path**.
3. Click **Add**, enter `N:\PLOT STYLES`, and click **Apply**.
4. Click **OK** to save the change.

---

## 2. Command Cheat Sheet
* **`JMGOODIES`**: Prints a bulleted cheat sheet of the available LISP commands and short descriptions. Load `JMGoodies.lsp` first, then type `JMGOODIES` at the command line.
* **`QUICKREPLACE`**: Replaces case-sensitive text within selected TEXT, MTEXT, and block attributes.
* **`PolyHatchEarth`**: Selects a polyline, offsets it, closes the boundary on `S-ANNO-NONPLOT`, and applies an `EARTH` hatch on `S-HATCH-SOIL` (Scale: 10, Angle: 45).
* **`OutlineHatch`**: Recreates a closed polyline boundary around an existing hatch and moves that boundary to `S-ANNO-NONPLOT`.

---

## 3. AutoCAD Tips
* **Enable Quick Properties:** Type `QPMODE`, enter `1`, and press **Enter**. This displays useful object properties when objects are selected.
* **Enable Selection Cycling:** Type `SELECTIONCYCLING`, enter `1`, and press **Enter**. This helps select individual objects when multiple objects overlap.
* **Manually Select Trim/Extend Boundaries:** Type `TRIMEXTENDMODE`, enter `0`, and press **Enter**. This lets you manually select the cutting or boundary edges instead of using the newer automatic mode.

---

**Maintenance Tip:** Always keep a copy of your `.lsp` files in your personal cloud or VPS. Since you use **Obsidian** for technical documentation, consider pasting these LISP code blocks into a "CAD Standards" note for quick recovery.
