FUNCTION ZBYHR_FG002_004.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(P_PERNR) LIKE  PERNR-PERNR
*"     VALUE(P_TCLAS) LIKE  PSPAR-TCLAS DEFAULT 'A'
*"     VALUE(P_BEGDA) TYPE  D DEFAULT '18000101'
*"     VALUE(P_ENDDA) TYPE  D DEFAULT '99991231'
*"  EXPORTING
*"     VALUE(P_EXISTS) TYPE  C
*"     VALUE(P_CONNECT_INFO) LIKE  TOAV0 STRUCTURE  TOAV0
*"  EXCEPTIONS
*"      ERROR_CONNECTIONTABLE
*"----------------------------------------------------------------------

DATA: L_SAP_OBJECT LIKE TOAOM-SAP_OBJECT,
        L_OBJ_INFO LIKE SAPB-SAPOBJID,
        DATE TYPE D,
        AR_DATE TYPE D,                                     "XPSK002254
        NUMBER_HITS TYPE I,
        L_AR_OBJECT_PASSBILD LIKE TOAV0-AR_OBJECT.          "XYVK013144
  DATA: CONNECT_INFO LIKE TOAV0 OCCURS 3 WITH HEADER LINE.
  DATA: ARCHIVOBJECT LIKE DOCS OCCURS 3 WITH HEADER LINE.
*
  CONCATENATE P_PERNR '*' INTO L_OBJ_INFO.
  IF P_TCLAS = 'B'.
    L_SAP_OBJECT = C_SAP_OBJECT_APPLICANT.
  ELSE.
    L_SAP_OBJECT = C_SAP_OBJECT_EMPLOYEE.
  ENDIF.

  PERFORM DOCUMENT_GET_FROM_CUSTOMIZING                     "XYVK013144
    in PROGRAM SAPLHRPAD00IMAGE
    CHANGING L_AR_OBJECT_PASSBILD.                          "XYVK013144

* Bei Customizingproblemen hoeren wir sofort auf.
  IF NOT SY-SUBRC IS INITIAL.                            "XYVPH9K000327
    CLEAR P_EXISTS.                                      "XYVPH9K000327
    EXIT.                                                "XYVPH9K000327
  ENDIF.  " NOT SY-SUBRC IS INITIAL.                     "XYVPH9K000327

  CALL FUNCTION 'ARCHIV_CONNECTINFO_GET_META'
       EXPORTING
*           ARCHIV_ID             = ' '
           AR_OBJECT              = L_AR_OBJECT_PASSBILD    "XYVK013144
*            DOC_TYPE              = ''                     "XYVK013144
            OBJECT_ID             = L_OBJ_INFO
            SAP_OBJECT            = L_SAP_OBJECT
       IMPORTING
            NUMBER                = NUMBER_HITS
       TABLES
            CONNECT_INFO          = CONNECT_INFO
       EXCEPTIONS
            ERROR_CONNECTIONTABLE = 1
            OTHERS                = 2.
  IF SY-SUBRC = 1.                    " Fehler Erzeugen Trefferliste
    CLEAR P_EXISTS.                                      "XYVPH9K000327
    EXIT.  "no document
  ELSEIF SY-SUBRC = 2.
    CLEAR P_EXISTS.                                      "XYVPH9K000327
    EXIT.  "no document
  ENDIF.
  CHECK NUMBER_HITS > 0.

  if number_hits > 1.                                    "SERN0731628
    perform sort_photos IN PROGRAM SAPLHRPAD00IMAGE
     changing connect_info[].         "SERN0731628
  endif.                                                 "SERN0731628

  CLEAR AR_DATE.                                            "XPSK002254
  LOOP AT CONNECT_INFO.
    DATE = CONNECT_INFO-OBJECT_ID+18(8).
    CHECK DATE BETWEEN P_BEGDA AND P_ENDDA OR DATE CO '0 '.
    CHECK CONNECT_INFO-AR_DATE GT AR_DATE.                  "XPSK002254
    MOVE CONNECT_INFO-AR_DATE TO AR_DATE.                   "XPSK002254
    P_CONNECT_INFO = CONNECT_INFO.
    P_EXISTS = '1'.
*   EXIT.                                                   "XPSK002254
  ENDLOOP.



ENDFUNCTION.
