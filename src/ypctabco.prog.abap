*----------------------------------------------------------------------*
*   INCLUDE ZPCTABCO                                                   *
*----------------------------------------------------------------------*
*

*&---------------------------------------------------------------------*
*&      Form  TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM TABLE_CONTROL TABLES $ITAB $FNAMES USING $TITLE $FILEN.
  CALL FUNCTION 'HR_DISPLAY_BASIC_LIST'
       EXPORTING
           BASIC_LIST_TITLE     = $TITLE
           FILE_NAME            = $FILEN
*           head_line1           = ' '
*           head_line2           = ' '
*           foot_note1           = ' '
*           FOOT_NOTE2           = ' '
*           FOOT_NOTE3           = ' '
*           LAY_OUT              = 0
*           DYN_PUSHBUTTON_TEXT1 =
*           DYN_PUSHBUTTON_TEXT2 =
*           DYN_PUSHBUTTON_TEXT3 =
*           DYN_PUSHBUTTON_TEXT4 =
*           DYN_PUSHBUTTON_TEXT5 =
*           DYN_PUSHBUTTON_TEXT6 =
*           DATA_STRUCTURE       = ' '
*           head_line3           = 'BEG.DATE'
*           head_line4           = 'END.DATE'
*           CURRENT_REPORT       =
*           LIST_LEVEL           = ' '
*           ADDITIONAL_OPTIONS   = ' '
*           WORD_DOCUMENT        =
       IMPORTING
            RETURN_CODE          =  RET_CODE
       TABLES
            DATA_TAB             =  $ITAB
            FIELDNAME_TAB        =  $FNAMES
*           select_tab           =
*           ERROR_TAB            =
       EXCEPTIONS
            DOWNLOAD_PROBLEM     = 1
*           no_data_tab_entiries = 2
            TABLE_MISMATCH       = 3
            PRINT_PROBLEMS       = 4
            OTHERS               = 5.
*

ENDFORM.                    " TABLE_CONTROL
*
