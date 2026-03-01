*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_YPCTABCO                                                   *
*----------------------------------------------------------------------*
*

*&---------------------------------------------------------------------*
*&      Form  TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM table_control TABLES $itab $fnames USING $title $filen.
  CALL FUNCTION 'HR_DISPLAY_BASIC_LIST'
    EXPORTING
      basic_list_title = $title
      file_name        = $filen
*     head_line1       = ' '
*     head_line2       = ' '
*     foot_note1       = ' '
*     FOOT_NOTE2       = ' '
*     FOOT_NOTE3       = ' '
*     LAY_OUT          = 0
*     DYN_PUSHBUTTON_TEXT1 =
*     DYN_PUSHBUTTON_TEXT2 =
*     DYN_PUSHBUTTON_TEXT3 =
*     DYN_PUSHBUTTON_TEXT4 =
*     DYN_PUSHBUTTON_TEXT5 =
*     DYN_PUSHBUTTON_TEXT6 =
*     DATA_STRUCTURE   = ' '
*     head_line3       = 'BEG.DATE'
*     head_line4       = 'END.DATE'
*     CURRENT_REPORT   =
*     LIST_LEVEL       = ' '
*     ADDITIONAL_OPTIONS   = ' '
*     WORD_DOCUMENT    =
    IMPORTING
      return_code      = ret_code
    TABLES
      data_tab         = $itab
      fieldname_tab    = $fnames
*     select_tab       =
*     ERROR_TAB        =
    EXCEPTIONS
      download_problem = 1
*     no_data_tab_entiries = 2
      table_mismatch   = 3
      print_problems   = 4
      OTHERS           = 5.
*

ENDFORM.                    " TABLE_CONTROL
*
