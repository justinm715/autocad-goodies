# Blocks

---



---


Your workspace configuration is built on two pillars: your **AutoLISP scripts** (the logic) and your **CUIx/Workspace settings** (the interface). Following these steps ensures your structural drafting environment is portable and protected.

# 🏗️ AutoCAD LT 2026: Workspace & LISP Readme

## 1. Saving Your Configuration
To prevent losing your custom commands and interface layout, perform these three backups:

### A. Export the Interface (CUIx)
1. Type `CUI` in the command line.
2. Click the **Transfer** tab.
3. In the right-hand pane ("New File"), click the **Save** icon.
4. Save the file as `Justin_Structural.cuix` to your `02 Goodies` folder.

### B. Save the Workspace Layout
1. Click the **Workspace Switching** (gear icon) in the bottom-right status bar.
2. Select **Save Current As...** and name it `Structural_Production`.
3. In the same menu, click **Workspace Settings** and ensure **"Automatically save workspace changes"** is checked.

### C. Export the Profile (.ARG)
1. Type `OPTIONS` and navigate to the **Profiles** tab.
2. Select your current profile and click **Export**.
3. Save this `.arg` file. This stores your file paths, crosshair size, and background colors.

---

## 2. Loading on a New Machine
If you need to restore your environment or move to a new workstation:

### Step 1: Restore the Scripts (Auto-Load)
1. Type `APPLOAD`.
2. Click the **Contents** button (under the Briefcase icon).
3. Click **Add** and select:
   * `PolyHatchEarth.lsp`
   * `OutlineHatch.lsp`
4. Close the dialog. These will now load automatically every time you open a drawing.

### Step 2: Import the Interface
1. Type `CUI` and go to the **Transfer** tab.
2. In the right-hand pane, click **Open** and select your `Justin_Structural.cuix`.
3. Drag your custom Toolbars or Ribbon Tabs from the right pane to the left pane (Main Customization File).
4. Click **Apply** and **OK**.

---

## 3. Command Cheat Sheet
* **`PolyHatchEarth`**: Selects a polyline, offsets it, closes the boundary on `S-ANNO-NONPLOT`, and applies an `EARTH` hatch on `S-HATCH-SOIL` (Scale: 10, Angle: 45).
* **`OutlineHatch`**: Recreates a closed polyline boundary around an existing hatch and moves that boundary to `S-ANNO-NONPLOT`.

---

**Maintenance Tip:** Always keep a copy of your `.lsp` files and `.cuix` in your personal cloud or VPS. Since you use **Obsidian** for technical documentation, consider pasting these LISP code blocks into a "CAD Standards" note for quick recovery.