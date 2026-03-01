FUNCTION zhr_isyeri_sskno_uret.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(SSKNO) TYPE  PTR_SSKNO
*"     REFERENCE(AKODU) TYPE  PTR_AKODU
*"  EXPORTING
*"     REFERENCE(SSK_NO) TYPE  TEXT40
*"----------------------------------------------------------------------

  DATA: lv_sskno TYPE ptr_sskno.
  lv_sskno = sskno.

  IF lv_sskno+1(1) EQ '0'.
    CLEAR lv_sskno+1(1).
  ENDIF.
  CONCATENATE lv_sskno+0(1)
              lv_sskno+1(1)
              lv_sskno+2
              akodu
          INTO ssk_no.



ENDFUNCTION.
