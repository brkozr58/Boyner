*----------------------------------------------------------------------*
*   INCLUDE PAGENTRP                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  read_rgdir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_rgdir.

  DATA  : lv_formn TYPE string.


  CALL FUNCTION 'CU_READ_RGDIR'
       EXPORTING
            persnr          = p0001-pernr
       IMPORTING
            molga           = c_molga
       TABLES
            in_rgdir        = rgdir
       EXCEPTIONS
            no_record_found = 1
            OTHERS          = 2.


  IF sy-subrc = 1.
    IF sy-cprog EQ 'ZBYHR_P016'.
      lv_formn = 'HATATABLOSU'.
      PERFORM (lv_formn) IN PROGRAM (sy-cprog) USING text-001 'W' ''
        IF FOUND.
    ELSE.
      WRITE: / 'No records found for '(001) , pernr-pernr.
    ENDIF.
  ENDIF.

ENDFORM.                    " read_rgdir
*&---------------------------------------------------------------------*
*&      Form  read_payroll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PY_PERIO_FPPER  text
*      -->P_R_SRTZA  text
*      <--P_PY_RESULT  text
*----------------------------------------------------------------------*
FORM read_payroll USING py_fpper py_srtza
               CHANGING py_result TYPE paytr_result.

  DATA : lv_formn TYPE string.

  DATA : seqnr LIKE pc261-seqnr.

  LOOP AT rgdir WHERE fpper EQ py_fpper
                  AND srtza EQ py_srtza.

    seqnr = rgdir-seqnr.
    CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
         EXPORTING
              clusterid                    = c_relid
              employeenumber               = pernr-pernr
              sequencenumber               = seqnr
              check_read_authority         = 'X'
         CHANGING
              payroll_result               = py_result
         EXCEPTIONS
              illegal_isocode_or_clusterid = 1
              error_generating_import      = 2
              import_mismatch_error        = 3
              subpool_dir_full             = 4
              no_read_authority            = 5
              no_record_found              = 6
              versions_do_not_match        = 7
              OTHERS                       = 8.

    IF sy-subrc = 0.
*      PERFORM print_rx.
    ELSE.
      IF sy-cprog EQ 'ZBYHR_P016'.
        lv_formn = 'HATATABLOSU'.
        PERFORM (lv_formn) IN PROGRAM (sy-cprog) USING text-002 'W' ''
          IF FOUND.
      ELSE.
        WRITE: / 'Result could not be read '.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " read_payroll
