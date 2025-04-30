# ATTPFROMLST.lsp – Block Attribute Importer for AutoCAD

**Author (original):** Thomas Gail Haws (2006)  
**Modified and extended by:** Ing. Franklin Rodriguez (2024–2025)  
**License:** GNU General Public License v2 

---

## 📌 Description

`ATTPFROMLST.lsp` is an enhanced AutoLISP application that **imports and inserts AutoCAD blocks with attributes and optional visibility states from a structured CSV or TXT file**.

Originally developed by [Thomas Gail Haws](https://autocad.fandom.com/wiki/Attribute_Importer_(AutoLISP_application)), this version retains the spirit of open software while integrating **enhancements** for stability, compatibility, and flexibility in real-world engineering workflows.


---

## 🚀 Features

- Reads and parses structured CSV (or whitespace-delimited) files.
- Inserts blocks with attribute data at specified X, Y (and optional Z) coordinates.
- Supports `MTEXT` attributes and visibility states (`VISIBILITY`).
- Automatically creates required layers if they don’t exist.
- Uses `command-s` for safer block insertion and attribute control.
- Validates field names and handles unexpected input with clear alerts.
- Includes error recovery and environment cleanup routines.

---

## 🔧 How to Use

1. **Load the LISP** into AutoCAD using `APPLOAD`.

2. **Prepare a CSV/TXT file** with the following **required fields**:
   - `X` (insertion X coordinate)
   - `Y` (insertion Y coordinate)
   - `BLOCK` (block name)
   - (optional) `Z`, `LAYER`, attribute tags, `VISIBILITY`

3. **Run the command**: `ATTPFROMLST`

4. **Choose delimiter** (comma, tab, or whitespace) and comment characters.

5. **The script will**:
- Validate the file structure.
- Parse all data lines.
- Create layers if necessary.
- Insert each block with the specified attribute values and properties.

---

**⚠️ Notes:**

- If BLOCK field is missing, the script prompts for a block name.

- If VISIBILITY is provided, the script attempts to apply it via dynamic block properties.

- Fields are case-insensitive.

- Comments in the file (e.g., starting with # or :) are ignored.

---

**📜 License**

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 2 of the License.

You may not incorporate this code into any proprietary product.

Read the full license at: https://www.gnu.org/licenses/old-licenses/gpl-2.0.html

---

**🤝 Credits**

Original concept and base code by Thomas Gail Haws
AutoCAD Wiki – Attribute Importer

Enhancements and modern implementation by [Ing. Franklin Rodriguez.](https://www.linkedin.com/in/franklinrodriguezacosta) 

---

## 📄 Example Input (CSV)

```csv
X,Y,BLOCK,NAME,CODE,VISIBILITY
100,200,MyBlock,Valve-01,VAL001,Open
110,210,MyBlock,Valve-02,VAL002,Closed
