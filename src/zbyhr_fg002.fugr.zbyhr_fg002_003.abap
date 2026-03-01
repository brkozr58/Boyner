FUNCTION zbyhr_fg002_003.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PERNR) TYPE  PA0001-PERNR OPTIONAL
*"     VALUE(IV_SEND) TYPE  CHAR1 OPTIONAL
*"     VALUE(IV_SAVE) TYPE  CHAR1 OPTIONAL
*"     VALUE(IV_SVFL) TYPE  STRING OPTIONAL
*"     VALUE(IT_PERNR) TYPE  HRPADUN_AAP_PERSONS OPTIONAL
*"     VALUE(IV_LOW) TYPE  SPMON OPTIONAL
*"     VALUE(IV_HIGH) TYPE  SPMON OPTIONAL
*"----------------------------------------------------------------------
  DATA : lt_person TYPE TABLE OF ts_person,
         lt_record LIKE solisti1 OCCURS 0 WITH HEADER LINE,
         return    TYPE string,
         pass_file TYPE xstring,
         password  TYPE i.

  PERFORM get_person_payroll_pdf TABLES lt_person[]
                                        it_pernr[]
                                  USING iv_pernr
                                        iv_low
                                        iv_high
                                         .
  CHECK lt_person[] IS NOT INITIAL .

  CASE 'X'.
    WHEN iv_save. " Dosya indir.
      PERFORM download_pdf TABLES lt_person[] USING iv_svfl iv_low iv_high iv_pernr.
    WHEN iv_send.
      " üretilen pdf şifrelenir.
      PERFORM set_pdf_password_service TABLES lt_person[] .
      " şifreli pdfi kişiye mail gönder
      PERFORM send_mail_pdf TABLES lt_person[]
                                    USING
                                          iv_low
                                          iv_high.
      PERFORM send_mail_pass_service TABLES lt_person[].
    WHEN OTHERS.
  ENDCASE.

ENDFUNCTION.
