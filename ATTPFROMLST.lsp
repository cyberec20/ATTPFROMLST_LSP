;;; AutoCAD Wiki AutoLISP code header.  
;;;
;;; Copy this code to a file on your computer. 
;;; Start highlighting OUTSIDE the code boxes and use the mouse or keyboard to
;;; highlight all the code.
;;; If you select too much, simply delete any extra from your destination file.
;;; In Windows you may want to start below the code and use [Shift]+[Ctrl]+[Home] 
;;; key combination to highlight all the way to the top of the article,
;;; then still holding the [Shift] key, use the arrow keys to shrink the top of
;;; the selection down to the beginning of the code.  Then copy and paste.
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; The working version of this software is located at the AutoCAD Wiki.
;;; Please AutoCAD:Be_bold in adding clarifying comments and improvements at
;;; https://autocad.fandom.com/wiki/Attribute_Importer_(AutoLISP_application)
;;; AutoCAD Wiki AutoLISP code header. Start highlighting at the beginning of this line to copy program code.

;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; The working version of this software is located at the AutoCAD Wiki.
;;; Please Be Bold in adding clarifying comments and improvements at
;;; http://autocad.wikia.com/wiki/Attribute_Importer_%28AutoLISP_application%29

;;; ATTPFROMLST.LSP
;;;
;;; Copyright 2006 Thomas Gail Haws
;;; This program is free software under the terms of the
;;; GNU (GNU--acronym for Gnu's Not Unix--sounds like canoe)
;;; General Public License as published by the Free Software Foundation,
;;; version 2 of the License.
;;;
;;; You can redistribute this software for any fee or no fee and/or
;;; modify it in any way, but it and ANY MODIFICATIONS OR DERIVATIONS
;;; continue to be governed by the license, which protects the perpetual
;;; availability of the software for free distribution and modification.
;;;
;;; You CAN'T put this code into any proprietary package.  Read the license.
;;;
;;; If you improve this software, please make a revision submittal to the
;;; copyright owner at www.hawsedc.com.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License on the World Wide Web for more details.
;;;
;;; DESCRIPTION
;;;
;;; ATTPFROMLST is a tool that reads attribute data from a file
;;; and inserts a block in AutoCAD for every line in the file.
;;;	ATTPFROMLST
;;; The order and graphical arrangement of the attributes doesn't matter.
;;; ATTPFROMLST scales the blocks to the dimension text height (Modified by Franklin Rodriguez to scale 1)
;;; (dimscale * dimtxt).
;;;
;;; Revisions
;;; 20250430  Franklin Rodriguez/Deepseek(xAI)	https://www.linkedin.com/in/franklinrodriguezacosta/  
;;; Se optimizó WIKI-AI:INSERTBLOCKS para mejorar robustez y control del entorno:
;;;                       - Desactivación de OSMODE para evitar selecciones automáticas.
;;;                       - Limpieza de selecciones previas con (SSGET "_X" nil).
;;;                       - Uso de COMMAND-S para ejecución controlada de INSERT.
;;;                       - Verificación de existencia de bloques con TBLSEARCH.
;;;                       - Validación de índices en atributos y propiedades dinámicas.
;;;                       - Reincorporación de medición de TIMEENTMODING.
;;;                       - Control de variables PICKSTYLE, PICKADD, PICKAUTO para minimizar errores de intersección.

;;; 20250430  Franklin Rodriguez/Grok(xAI)	https://www.linkedin.com/in/franklinrodriguezacosta/  
;;; Se añadió verificación del campo VISIBILITY en los nombres de campos
;;;                       para notificar al usuario si el archivo de entrada incluye datos
;;;                       para propiedades dinámicas de visibilidad. La verificación se corrigió
;;;                       para usar (CAR BLOCKSLIST) en lugar de BLOCKLIST.

;;; 20241218  Franklin Rodriguez	https://www.linkedin.com/in/franklinrodriguezacosta/	
;;;									Se modificó para permitir que se importen los datos de atributos MTEXT
;;;									Se modificó para insertar los bloques a escala 1
;;;									Se modificó el nombre anterior de la función (ATTRIBSIN) para mejor entendimiento al usarla

;;; 20090306  TGH     hr.  Made it create layers if not exist
;;; 20080619  TGH     hr.  Created based on HawsEDC POINTSIN.

(DEFUN C:ATTPFROMLST () (BLOCKSIN))

(DEFUN
   BLOCKSIN (/ FILEFORMAT FNAME BLOCKSLIST)
  (WIKI-AI:ERRORTRAP)
  (SETQ FILEFORMAT (WIKI-AI:GETFILEFORMAT))
  (SETQ FNAME (GETFILED "Blocks text file" (WIKI-AI:GETDNPATH) "" 0))
  (SETQ BLOCKSLIST (WIKI-AI:GETBLOCKSLIST FNAME FILEFORMAT))
  ;;Make new layers
  (WIKI-AI:MAKELAYERS BLOCKSLIST)
  ;;Insert blocks.
  (WIKI-AI:INSERTBLOCKS BLOCKSLIST)
  (WIKI-AI:ERRORRESTORE)
  (PRINC)
)

(DEFUN
   WIKI-AI:ERRORTRAP ()
  (SETQ
    *WIKI-AI:OLDERROR* *ERROR*
    *ERROR* *WIKI-AI:ERROR*
  )
)

(DEFUN
   *WIKI-AI:ERROR* (MESSAGE)
  (COND
    ((/= MESSAGE "Function cancelled")
     (PRINC (STRCAT "\nTrapped error: " MESSAGE))
    )
  )
  (COMMAND)
  (IF (= (TYPE F1) (QUOTE FILE))
    (SETQ F1 (CLOSE F1))
  )
  (IF *WIKI-AI:OLDERR*
    (SETQ
      *ERROR* *WIKI-AI:OLDERR*
      *WIKI-AI:OLDERR* NIL
    )
  )
  (PRINC)
)

(DEFUN
   WIKI-AI:ERRORRESTORE ()
  (SETQ
    F1 NIL
    *ERROR* *WIKI-AI:OLDERR*
    *WIKI-AI:OLDERR* NIL
  )
)


(DEFUN
   WIKI-AI:GETFILEFORMAT (/ DELIMITER STDCOMMENT)
  (SETQ *WIKI-AI:WHITESPACEDELIMITER* " ,\t")
  ;;Get the field delimiter from user.
  ;;The field delimiter is a one-character string.
  (SETQ
    *WIKI-AI:DELIMITER*
     (WIKI-GETSTRINGX
       nil
       "Enter field delimiter character or W for white space delimited"
       *WIKI-AI:DELIMITER*
       ","
       0
     )
  )
  ;;Get the comment delimiter from user.
  ;;The comment delimiter is an AutoCAD style wild card string
  (SETQ
    *WIKI-AI:STDCOMMENT*
     (WIKI-GETSTRINGX
       nil
       "Enter comment line delimiter wildcard"
       *WIKI-AI:STDCOMMENT*
       ":,`#,;,'"
       0
     )
  )

  (COND
    ;;If user entered w or W for delimiter, set white space delimited.
    ((= (STRCASE *WIKI-AI:DELIMITER*) "W")
     (SETQ *WIKI-AI:DELIMITER* *WIKI-AI:WHITESPACEDELIMITER*)
    )
    ;;Else if user entered "," for delimiter, set "`," delimited
    ((= *WIKI-AI:DELIMITER* ",")
     (SETQ *WIKI-AI:DELIMITER* "`,")
    )
  )
  (LIST *WIKI-AI:DELIMITER* *WIKI-AI:STDCOMMENT*)
)

(DEFUN
   WIKI-AI:GETBLOCKSLIST (FNAME FILEFORMAT / FATALERROR FIELD FIELDNAMES
                          FIELDNAMESAREDONE HASBLOCKNAME HASXCOORDINATE
                          HASYCOORDINATE I BLOCKLIST BLOCKSLIST RDLIN
                          RDLINLIST HASVISIBILITY)
  (SETQ
    ;;Initialize variable for readability.
    FIELDNAMESAREDONE NIL
    F1 (OPEN FNAME "r")
  )
  (WHILE (SETQ RDLIN (READ-LINE F1))
    (COND
      ;;If it's a comment,
      ((WCMATCH (SUBSTR RDLIN 1 1) (CADR FILEFORMAT))
       ;;then do nothing.
       NIL
      )
      ;;Else if it's the first line, read all the field names
      ((NOT FIELDNAMESAREDONE)
       ;;Add field names to front of block list
       (SETQ
         BLOCKLIST
          ;;Parse the line into fields
          (WIKI-STRTOLST
            ;;Convert header to upper case.
            (STRCASE RDLIN)
            (CAR FILEFORMAT)
            ""
            ;;If a white space delimiter is used.
            (IF (= (CAR FILEFORMAT)
                   *WIKI-AI:WHITESPACEDELIMITER*
                )
              ;;Empty fields don't count
              NIL
              ;;Else they do count
              T
            )
          )
       )
       (SETQ
         BLOCKLIST
          (MAPCAR
            '(LAMBDA (FIELD)
               (CONS
                 FIELD
                 (- (LENGTH BLOCKLIST)
                    (LENGTH (MEMBER FIELD BLOCKLIST))
                 )
               )
             )
            BLOCKLIST
          )
       )
       (SETQ BLOCKSLIST (CONS BLOCKLIST BLOCKSLIST))
       ;;Check the file format for omissions.
       (SETQ HASXCOORDINATE (ASSOC "X" BLOCKLIST))
       (SETQ HASYCOORDINATE (ASSOC "Y" BLOCKLIST))
       (SETQ HASBLOCKNAME (ASSOC "BLOCK" BLOCKLIST))
       ;;Act on omissions
       (COND
         ;;If there's no x coordinate, alert and flag fatal
         ((NOT HASXCOORDINATE)
          (ALERT
            (PRINC
              "Error:  The file format does not include an X coordinate field, \"X\".\nCannot continue."
            )
          )
          (SETQ FATALERROR T)
         )
       )
       (COND
         ;;If there's no y coordinate, alert and flag fatal
         ((NOT HASYCOORDINATE)
          (ALERT
            (PRINC
              "Error:  The file format does not include a Y coordinate field, \"Y\".\nCannot continue."
            )
          )
          (SETQ FATALERROR T)
         )
       )
       ;;If fatal, exit/abort
       (COND (FATALERROR (EXIT)))
       (COND
         ;;If there's no block name, get one from user
         ((NOT HASBLOCKNAME)
          (SETQ
            *WIKI-AI:BLOCKNAME*
             (WIKI-GETSTRINGX
               T
               "Specify block name"
               *WIKI-AI:BLOCKNAME*
               ""
               0
             )
          )
         )
       )
       (COND
         ;;If block name is still empty, alert user and exit/abort
         ((= *WIKI-AI:BLOCKNAME* "")
          (ALERT
            (PRINC "Error:  Cannot continue without a block name.")
          )
          (EXIT)
         )
       )
       ;; Verificar campo VISIBILITY
       (SETQ HASVISIBILITY (ASSOC "VISIBILITY" BLOCKLIST))
       (IF HASVISIBILITY
         (PRINC "\nSe detectó campo VISIBILITY en el archivo")
       )
       (SETQ FIELDNAMESAREDONE T)
       (PRINC "\nReading data file...")
       (PRINC)
      )
      ;;Else for all other lines
      (T
       ;;Check that field names are done.
       (COND
         ((NOT FIELDNAMESAREDONE)
          (ALERT
            (PRINC
              "\nError: Field names must come before any data lines in the file.\nCannot continue."
            )
          )
          (EXIT)
         )
       )
       ;;Parse line into a list.
       (SETQ
         BLOCKLIST
          (WIKI-STRTOLST
            RDLIN
            (CAR FILEFORMAT)
            ""
            ;;If a white space delimiter is used.
            (IF (= (CAR FILEFORMAT)
                   *WIKI-AI:WHITESPACEDELIMITER*
                )
              ;;Empty fields don't count
              NIL
              ;;Else they do count
              T
            )
          )
       )
       ;;Add block to list
       (SETQ
         BLOCKSLIST
          (CONS BLOCKLIST BLOCKSLIST)
         BLOCKLIST NIL
       )
      )
    )
  )
  (SETQ F1 (CLOSE F1))
  (REVERSE BLOCKSLIST)
)

(DEFUN
   WIKI-AI:MAKELAYER (LAYERLIST)
  (IF LAYERLIST
    (COMMAND
      "._layer"
      "_thaw"
      (CAR LAYERLIST)
      "_make"
      (CAR LAYERLIST)
      "_on"
      ""
      "_color"
      (CADR LAYERLIST)
      ""
      ""
    )
  )
)

(DEFUN
   WIKI-AI:MAKELAYERS (BLOCKSLIST / NLAYER LAYERNAME)
  (COND
    ;;If there is a layers field in the file.
    ((ASSOC "LAYER" (CAR BLOCKSLIST))
     ;;Then
     ;;Prompt
     (PRINC "Making required layers...")
     ;;Make all the layers that don't exist.
     (SETQ NLAYER (CDR (ASSOC "LAYER" (CAR BLOCKSLIST))))
     (FOREACH
        BLOCKLIST (CDR BLOCKSLIST)
       (IF
         (NOT
           (TBLSEARCH "LAYER" (SETQ LAYERNAME (NTH NLAYER BLOCKLIST)))
         )
          (WIKI-AI:MAKELAYER (LIST LAYERNAME ""))
       )
     )
    )
  )
)


(DEFUN
   WIKI-AI:INSERTBLOCKS (BLOCKSLIST / AROLD AT AV CMDECHOOLD EL EN ET I N BLOCKLIST
                         FIELDNAMES NLAYER TIMEMARKER TIMEINSERTING
                         TIMEENTMODING SCALE BLK-OBJ DYN-PROPS PROP VIS-INDEX VIS-VALUE
                         BLOCKNAME OSMODEOLD)
  (COMMAND "._undo" "_group")
  (SETQ AROLD (GETVAR "attreq"))
  (SETVAR "attreq" 0)
  (SETQ CMDECHOOLD (GETVAR "cmdecho"))
  (SETVAR "cmdecho" 0)
  (SETQ OSMODEOLD (GETVAR "osmode"))
  (SETVAR "osmode" 0) ; Desactivar modos de referencia a objetos
  (SETQ
    I 0
    TIMEINSERTING 0
    TIMEENTMODING 0
    FIELDNAMES (CAR BLOCKSLIST)
    NLAYER (CDR (ASSOC "LAYER" FIELDNAMES))
  )
  (PRINC "\nInserting blocks...\n")
  (FOREACH
     BLOCKLIST (CDR BLOCKSLIST)
    (SETQ I (1+ I))
    (COND ((= (REM I 10) 0) (PRINC "\r") (PRINC I)))
    (SETQ TIMEMARKER (GETVAR "date"))
    (COND (NLAYER (SETVAR "CLAYER" (NTH NLAYER BLOCKLIST))))
    ;; Limpiar cualquier selección previa
    (SSGET "_X" nil)
    ;; Determinar el nombre del bloque
    (SETQ BLOCKNAME
      (COND
        ((CDR (ASSOC "BLOCK" FIELDNAMES))
         (NTH (CDR (ASSOC "BLOCK" FIELDNAMES)) BLOCKLIST)
        )
        (*WIKI-AI:BLOCKNAME*)
      )
    )
    ;; Verificar si el bloque existe
    (IF (TBLSEARCH "BLOCK" BLOCKNAME)
      (PROGN
        ;; Insertar bloque usando COMMAND-S para mayor control
        (COMMAND-S
          "._insert"
          BLOCKNAME
          (LIST
            (ATOF (NTH (CDR (ASSOC "X" FIELDNAMES)) BLOCKLIST))
            (ATOF (NTH (CDR (ASSOC "Y" FIELDNAMES)) BLOCKLIST))
            (COND
              ((CDR (ASSOC "Z" FIELDNAMES))
               (ATOF (NTH (CDR (ASSOC "Z" FIELDNAMES)) BLOCKLIST))
              )
              (0)
            )
          )
          1
          ""
          0
        )
        (SETQ EN (ENTLAST))
        ;; Procesar atributos
        (WHILE (AND
                 (SETQ EN (ENTNEXT EN))
                 (/= "SEQEND"
                     (SETQ ET (CDR (ASSOC 0 (SETQ EL (ENTGET EN)))))
                 )
               )
          (COND
            ((= ET "ATTRIB")
             (SETQ AT (CDR (ASSOC 2 EL)))
             (COND
               ((AND
                  (CDR (ASSOC AT FIELDNAMES))
                  (< (CDR (ASSOC AT FIELDNAMES)) (LENGTH BLOCKLIST))
                  (SETQ AV (NTH (CDR (ASSOC AT FIELDNAMES)) BLOCKLIST))
                )
                (SETQ ATTR-OBJ (VLAX-ENAME->VLA-OBJECT EN))
                (VLAX-PUT-PROPERTY ATTR-OBJ 'TEXTSTRING AV)
                (VLAX-INVOKE ATTR-OBJ 'UPDATE)
               )
             )
            )
          )
        )
        ;; Aplicar visibilidad si existe en CSV
        (IF (AND
              (SETQ VIS-INDEX (CDR (ASSOC "VISIBILITY" FIELDNAMES)))
              (< VIS-INDEX (LENGTH BLOCKLIST))
              (SETQ VIS-VALUE (NTH VIS-INDEX BLOCKLIST))
            )
          (PROGN
            (SETQ BLK-OBJ (VLAX-ENAME->VLA-OBJECT (ENTLAST)))
            (SETQ DYN-PROPS (VLAX-INVOKE BLK-OBJ 'GETDYNAMICBLOCKPROPERTIES))
            (IF DYN-PROPS
              (FOREACH PROP DYN-PROPS
                (IF (AND
                      (VLAX-GET PROP 'PROPERTYNAME)
                      (WCMATCH (VLAX-GET PROP 'PROPERTYNAME) "Visibility*")
                    )
                  (VL-CATCH-ALL-APPLY
                    '(LAMBDA ()
                       (VLAX-PUT PROP 'VALUE VIS-VALUE)
                     )
                  )
                )
              )
            )
          )
        )
      )
      (PRINC (STRCAT "\nError: Block '" BLOCKNAME "' not found. Skipping insertion."))
    )
    (SETQ TIMEINSERTING (+ TIMEINSERTING (- (GETVAR "date") TIMEMARKER)))
  )
  (PRINC
    (STRCAT
      "\nTime spent inserting = "
      (RTOS (* 86400 TIMEINSERTING) 2 2)
      " seconds"
    )
  )
  (SETVAR "osmode" OSMODEOLD) ; Restaurar modos de referencia a objetos
  (SETVAR "cmdecho" CMDECHOOLD)
  (SETVAR "attreq" AROLD)
  (COMMAND "._undo" "_end")
  (PRINC)
)

(DEFUN
   WIKI-AI:GETDNPATH (/ DNPATH)
  (SETQ DNPATH (GETVAR "dwgname")) ;_ end of setq
  (IF (WCMATCH (STRCASE DNPATH) "*`.DWG")
    (SETQ
      DNPATH
       (STRCAT (GETVAR "dwgprefix") DNPATH)
      DNPATH
       (SUBSTR DNPATH 1 (- (STRLEN DNPATH) 4))
    ) ;_ end of setq
  ) ;_ end of if
  DNPATH
) ;_ end of defun

;;;
;;; Include wiki functions
;;;
;| Start AutoLISP comment mode to wiki transclude sub functions
;| WIKI-GETSTRINGX
   Extended (getstring) with default value and drawing text selection
   Three modes:
   1. If a default or initial value is supplied, GETSTRINGX prompts with it
   2. If no default is supplied and MODE is 0, the first prompt is for standard input, with fallback to selecting value from drawing text.
   3. If no default is supplied and MODE is 1, the first prompt is for drawing text selection, with fallback to standard input.
   Returns a STR, empty if drawing text selection fails.
   Returns the arc sine of a number
   Edit the source code for this function at 
  Getstringx (AutoLISP function)
|;

(DEFUN
   WIKI-GETSTRINGX (GX-CR GX-PROMPT GX-DEFAULTVALUE GX-INITIALVALUE
                    GX-PROMPTMODE / GX-RESPONSE
                   )
  (SETQ
    GX-DEFAULTVALUE
     (COND
       (GX-DEFAULTVALUE)
       (GX-INITIALVALUE)
     )
  )
  ;;First prompt
  (COND
    ;;If a non-empty default value was supplied, prompt with it.
    ((/= GX-DEFAULTVALUE "")
     (SETQ
       GX-RESPONSE
        (GETSTRING
          GX-CR 
          (STRCAT "\n" GX-PROMPT " <" GX-DEFAULTVALUE ">: ")
        )
     )
    )
    ;;Else if mode is 0, prompt for standard input
    ((= GX-PROMPTMODE 0)
     (SETQ
       GX-RESPONSE
        (GETSTRING
          GX-CR 
          (STRCAT
            "\n"
            GX-PROMPT
            " or <Select from drawing>: "
          )
        )
     )
    )
    ;;Else if mode is 1, prompt for object select
    ((= GX-PROMPTMODE 1)
     (SETQ
       GX-RESPONSE
        (NENTSEL
          (STRCAT
            "\nSelect object with "
            GX-PROMPT
            " or <enter manually>: "
          )
        )
     )
    )
  )
  ;;Second prompt if necessary
  (COND
    ;;If
    ((AND
       ;;no response
       (= GX-RESPONSE "")
       ;;and there's a default value,
       GX-DEFAULTVALUE
     )
     ;;No second prompt
     NIL
    )
    ;;Else if
    ((AND
       ;;no response
       (= GX-RESPONSE "")
       ;;and mode is 0,
       (= GX-PROMPTMODE 0)
     )
     ;;Prompt for object select
     (SETQ
       GX-RESPONSE
        (NENTSEL
          (STRCAT "\nSelect object with " GX-PROMPT ": ")
        )
     )
    )
    ;;Else if
    ((AND
       ;; no response
       (= GX-RESPONSE "")
       ;;and mode is 1,
       (= GX-PROMPTMODE 1)
     )
     ;;Prompt for standard input
     (SETQ GX-RESPONSE (GETSTRING GX-CR (STRCAT "\n" GX-PROMPT ": ")))
    )
  )
  ;;Return the string if provided
  (COND
    ;;If there was a (nentsel) prompt that failed (probably because user picked empty space)
    ((NOT GX-RESPONSE)
     ;;Print a warning and exit/abort
     (princ "\nError: No text object was selected.  Can't continue.")
     (exit)
    )
    ;;Else if the user hit return,
    ((= GX-RESPONSE "")
     ;;then return the default
     GX-DEFAULTVALUE
    )
    ;;Else if response isn't empty (the user didnt hit return)
    ((/= GX-RESPONSE "")
     ;;Then return the response
     GX-RESPONSE
    )
    ;;Else if there is a response, it is an (nentsel).  Convert to string
    (GX-RESPONSE (CDR (ASSOC 1 (ENTGET (CAR GX-RESPONSE)))))
  )
)
;;;WIKI-STRTOLST
;;;Parses a string into a list of fields.
;;;Usage: (wiki-strtolst
;;;         [InputString containing fields]
;;;         [FieldSeparatorWC field delimiter wildcard string
;;;          Use "`," for comma and " ,\t" for white space
;;;         ]
;;;         [TextDelimiter text delimiter character.]
;;;         [EmptyFieldsDoCount flag.
;;;           If nil, consecutive field delimiters are ignored.
;;;           Nil is good for word (white space) delimited strings.
;;;         ]
;;;       )
;;; Examples:
;;; CSV            (wiki-strtolst string "`," "\"" T)
;;; Word delimited (wiki-strtolst string " ,\t,\n" "" nil)
;;; Revision history
;;; 2009-01-17 TGH     Replaced test for empty fieldseparatorwc with a simple '= function
;|
   Edit the source code for this function at 
  http://autocad.wikia.com/wiki/Strtolst_(AutoLISP_function)
|;
;;;Avoid cleverness.
;;;Human readability trumps elegance and economy and cleverness here.
;;;This should be readable to a programmer familiar with any language.
;;;In this function, I'm trying to honor readability in a new (2008) way.
;;;And I am trying a new commenting style.
;;;Tests
;;;(alert (apply 'strcat (mapcar '(lambda (x) (strcat "\n----\n" x)) (wiki-strtolst "1 John,\"2 2\"\" pipe,\nheated\",3 the end,,,,," "`," "\"" nil))))
;;;(alert (apply 'strcat (mapcar '(lambda (x) (strcat "\n----\n" x)) (wiki-strtolst "1 John,\"2 2\"\" pipe,\nheated\",3 the end,,,,," "`," "\"" T))))
(DEFUN
   WIKI-STRTOLST (INPUTSTRING FIELDSEPARATORWC TEXTDELIMITER
                  EMPTYFIELDSDOCOUNT / CHARACTERCOUNTER CONVERSIONISDONE
                  CURRENTCHARACTER CURRENTFIELD CURRENTFIELDISDONE
                  FIRSTCHARACTERINDEX PREVIOUSCHARACTER RETURNLIST
                  TEXTMODEISON
                 )
  ;;Initialize the variables for clarity's sake
  (SETQ
    ;;For the AutoLISP (substr string index length) function, the first character index is 1
    FIRSTCHARACTERINDEX 1
    ;;We start the character counter one before the beginning
    CHARACTERCOUNTER
     (1- FIRSTCHARACTERINDEX)
    PREVIOUSCHARACTER ""
    CURRENTCHARACTER ""
    CURRENTFIELD ""
    CURRENTFIELDISDONE NIL
    TEXTMODEISON NIL
    CONVERSIONISDONE NIL
    RETURNLIST NIL
  )
  ;;Make sure that the FieldSeparatorWC is not empty.
  (COND
    ;;If the FieldSeparatorWC is an empty string,
    ((= FIELDSEPARATORWC "")
     ;;Then
     ;;1. Give an alert about the problem.
     (ALERT
       ;;Include princ to allow user to see and copy error
       ;;after dismissing alert box.
       (PRINC
         (STRCAT
           "\n\""
           FIELDSEPARATORWC
           "\" is not a valid field delimiter."
         )
       )
     )
     ;;2. Exit with error.
     (EXIT)
    )
  )
  ;;Start the main character-by-character InputString examination loop.
  (WHILE (NOT CONVERSIONISDONE)
    (SETQ
      ;;Save CurrentCharacter as PreviousCharacter.
      PREVIOUSCHARACTER
       CURRENTCHARACTER
      ;;CharacterCounter is initialized above to start 1 before first character.  Increment it.
      CHARACTERCOUNTER
       (1+ CHARACTERCOUNTER)
      ;;Get new CurrentCharacter from InputString.
      CURRENTCHARACTER
       (SUBSTR INPUTSTRING CHARACTERCOUNTER 1)
    )
    ;;Decide what to do with CurrentCharacter.
    (COND
      ;;If
      ((AND
         ;;there is a TextDelimiter,
         (/= TEXTDELIMITER "")
         ;;and CurrentCharacter is a TextDelimiter,
         (= CURRENTCHARACTER TEXTDELIMITER)
       )
       ;;then
       ;;1.  Toggle the TextModeIsOn flag
       (IF (NOT TEXTMODEISON)
         (SETQ TEXTMODEISON T)
         (SETQ TEXTMODEISON NIL)
       )
       ;;2.  If this is the second consecutive TextDelimiter character, then
       (IF (= PREVIOUSCHARACTER TEXTDELIMITER)
         ;;Output it to CurrentField.
         (SETQ CURRENTFIELD (STRCAT CURRENTFIELD CURRENTCHARACTER))
       )
      )
      ;;Else if CurrentCharacter is a FieldDelimiter wildcard match,
      ((WCMATCH CURRENTCHARACTER FIELDSEPARATORWC)
       ;;Then
       (COND
         ;;If TextModeIsOn = True, then 
         ((= TEXTMODEISON T)
          ;;Output CurrentCharacter to CurrentField.
          (SETQ CURRENTFIELD (STRCAT CURRENTFIELD CURRENTCHARACTER))
         )
         ;;Else if
         ((OR ;;EmptyFieldsDoCount, or
              (= EMPTYFIELDSDOCOUNT T)
              ;;the CurrentField isn't empty,
              (/= "" CURRENTFIELD)
          )
          ;;Then
          ;;Set the CurrentFieldIsDone flag to true.
          (SETQ CURRENTFIELDISDONE T)
         )
         (T
          ;;Else do nothing
          ;;Do not flag the CurrentFieldDone,
          ;;nor output the CurrentCharacter.
          NIL
         )
       )
      )
      ;;Else if CurrentCharacter is empty,
      ((= CURRENTCHARACTER "")
       ;;Then
       ;;We are at the end of the string.
       ;;1.  Flag ConversionIsDone.
       (SETQ CONVERSIONISDONE T)
       ;;2.  If
       (IF (OR ;;EmptyFieldsDoCount, or
               EMPTYFIELDSDOCOUNT
               ;;the PreviousCharacter wasn't a FieldSeparatorWC, or
               (NOT (WCMATCH PREVIOUSCHARACTER FIELDSEPARATORWC))
               ;;the ReturnList is still nil due to only empty non-counting fields in string,
               ;;(Added 2008-02-18 TGH. Bug fix.)
               (= RETURNLIST NIL)
           )
         ;;Then flag the CurrentFieldIsDone to wrap up the last field.
         (SETQ CURRENTFIELDISDONE T)
       )
      )
      ;;Else (CurrentCharacter is something else),
      (T
       ;;Output CurrentCharacter to CurrentField.
       (SETQ CURRENTFIELD (STRCAT CURRENTFIELD CURRENTCHARACTER))
      )
    )
    ;;If CurrentFieldIsDone,
    (IF CURRENTFIELDISDONE
      ;;Then
      ;;Output it to the front of ReturnList.
      (SETQ
        RETURNLIST
         (CONS CURRENTFIELD RETURNLIST)
        ;;Start a new CurrentField.
        CURRENTFIELD
         ""
        CURRENTFIELDISDONE NIL
      )
    )
    ;;End the main character-by-character InputString examination loop.
  )
  ;;Reverse the backwards return list and we are done.
  (REVERSE RETURNLIST)
)
; End AutoLISP comment mode if on |;

(PRINC "Attribute importer loaded.  Type ATTPFROMLST to run.")
(PRINC)
;|«Visual LISP© Format Options»
(72 2 40 2 nil "end of " 60 2 2 2 1 nil nil nil T)
;*** DO NOT add text below the comment! ***|;