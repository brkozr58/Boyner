FUNCTION ZBYHR_FG002_002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PERNR) TYPE  PA0001-PERNR
*"     REFERENCE(IV_SEQUENCE) TYPE  BAPI7004_RL-SEQUENCENUMBER
*"     REFERENCE(IV_PYVAR) TYPE  BAPI7004-PAYSLIP_VARIANT
*"     REFERENCE(IV_MONTH) TYPE  CHAR10
*"     REFERENCE(IV_YEAR) TYPE  CHAR04
*"----------------------------------------------------------------------

  DATA lv_email    LIKE pa0105-usrid_long.
  DATA : lt_tline  TYPE TABLE OF tline WITH HEADER LINE.
  DATA lt_html     TYPE TABLE OF bapi7004_html WITH HEADER LINE.
  DATA lt_bordro   TYPE TABLE OF bapi7004_payslip.
  DATA ls_return   TYPE bapireturn1.
  DATA lv_pdf_size TYPE i.
  DATA lv_zarf     TYPE xstring.
  DATA :  lt_record LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA :   wa_buffer TYPE string.
  DATA :  i_reclist    LIKE somlreci1 OCCURS 0 WITH HEADER LINE,
          wa_objhead   TYPE soli_tab, w_ctrlop TYPE ssfctrlop,
          i_objpack    LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
          i_objtxt     LIKE solisti1 OCCURS 0 WITH HEADER LINE,
          wa_doc_chng  TYPE sodocchgi1, w_data TYPE sodocchgi1,
          lv_lines_txt TYPE i,
          lt_lines     LIKE tline OCCURS 0 WITH HEADER LINE,
          i_objbin     LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA : lv_strlen TYPE i.
  DATA : lv_ename TYPE emnam.

  CLEAR: lv_email,lv_zarf,ls_return,lv_pdf_size,lv_ename,wa_buffer.
  REFRESH : lt_tline,lt_record,i_objpack,
            wa_objhead,i_objbin,
            i_objtxt,i_reclist.
  "*---- get mail adres for pers
  SELECT SINGLE ename FROM pa0001 INTO lv_ename
  WHERE pernr EQ iv_pernr.

  SELECT SINGLE usrid_long INTO lv_email FROM pa0105
           WHERE pernr EQ iv_pernr AND
                 begda LE sy-datum AND
                 usrty EQ '0006'  AND   " şirket maili
                 endda GE sy-datum.
  IF sy-subrc NE 0.
    FORMAT COLOR COL_NEGATIVE.
    WRITE :/ 'Pernr. = ',iv_pernr,'Ad Soyad = ' ,lv_ename, 'personelin mail verilerini kontrol edin'.
    EXIT.
  ENDIF.
*--- call bapi for pdf

  "CALL FUNCTION 'BAPI_GET_PAYSLIP'
  "  EXPORTING
  "    EMPLOYEENUMBER = IV_PERNR
  "    SEQUENCENUMBER = IV_SEQUENCE
  "    PAYSLIPVARIANT = IV_PYVAR
  "  IMPORTING
  "    RETURN         = ls_return
  "  TABLES
  "    PAYSLIP        = lt_bordro.

  CALL FUNCTION 'BAPI_GET_PAYSLIP_HTML'
    EXPORTING
      employeenumber = iv_pernr
      sequencenumber = iv_sequence
      payslipvariant = iv_pyvar
*     PAGETEMPLATE   =
*     TEMPLATE       =
    IMPORTING
      return         = ls_return
    TABLES
      payslip_html   = lt_html.

*
*CALL FUNCTION 'CONVERT_PAYSLIP_TO_PDF'
* " EXPORTING
**   P_INFO            =
*  IMPORTING
*   PDF_CONTENT       = lv_zarf
*   PDF_FSIZE         = lv_pdf_size
*  TABLES
*    P_FORM            = lt_bordro
*  EXCEPTIONS
*    EMPTY_FORM        = 1
*  OTHERS            = 2.
*          .
*IF SY-SUBRC <> 0.
** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
**         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*ENDIF.
*CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*       EXPORTING buffer = lv_zarf TABLES binary_tab = lt_tline.
*
*  LOOP AT lt_tline into lt_tline.
*    TRANSLATE lt_tline USING '~'. CONCATENATE wa_buffer lt_tline INTO wa_buffer.
*  ENDLOOP.
*  TRANSLATE wa_buffer USING '~'.
*  DO.
*    lt_record = wa_buffer.
*    APPEND lt_record. SHIFT wa_buffer LEFT BY 255 PLACES.
*    IF wa_buffer IS INITIAL. EXIT. ENDIF.
*  ENDDO.
*--- send mail

  CONCATENATE 'Sayın' lv_ename ',<br/>' INTO i_objtxt SEPARATED BY space.
  APPEND i_objtxt.
  i_objtxt = '<br/>'.
  APPEND i_objtxt.
  CONCATENATE iv_month iv_year 'dönemine ait maaş bordronuz ekte bilginize sunulmuştur.<br/>' INTO i_objtxt SEPARATED BY space.
  APPEND i_objtxt.
  i_objtxt = '<br/>'.
  APPEND i_objtxt.
  i_objtxt = 'Saygılarımızla,<br/>'.
  APPEND i_objtxt.
  i_objtxt = 'İnsan Kaynakları<br/>'.
  APPEND i_objtxt.

  wa_doc_chng-obj_name = 'Maaş Zarfı'.
  wa_doc_chng-expiry_dat = sy-datum + 10.
  i_reclist-rec_type = 'U'.
  i_reclist-express = 'X'.
  i_reclist-receiver = lv_email.
  APPEND i_reclist.
  i_objbin[] = lt_html[].
*  I_OBJTXT[] = LT_HTML[].
  ""APPEND i_objtxt.

  DESCRIBE TABLE i_objbin LINES lv_pdf_size.
  DESCRIBE TABLE i_objtxt LINES lv_lines_txt.
  READ TABLE i_objtxt INDEX lv_lines_txt.
  " * Main Text
  CLEAR i_objpack-transf_bin.
  i_objpack-head_start = 1.
  i_objpack-head_num = 0.
  i_objpack-body_start = 1.
  i_objpack-body_num = lv_lines_txt.
  i_objpack-doc_type = 'HTM'.
  APPEND i_objpack.

  DESCRIBE TABLE i_objbin LINES lv_pdf_size.
  READ TABLE i_objbin  INDEX lv_pdf_size.
  i_objpack-doc_size =   lv_pdf_size  * 255 .
  i_objpack-transf_bin = 'X'.
  i_objpack-head_start = 1.
  i_objpack-head_num = 0.
  i_objpack-body_start = 1.
  i_objpack-body_num = lv_pdf_size.
  i_objpack-doc_type = 'HTM' .
  i_objpack-obj_name = 'Maas Zarfi'.
  i_objpack-obj_descr = 'Maas Zarfi'.
  APPEND i_objpack.

** Attachment (pdf-Attachment)
*  i_objpack-transf_bin = 'X'.
*  i_objpack-head_start = 1.
*  i_objpack-head_num = 0.
*  i_objpack-body_start = 1.
*  DESCRIBE TABLE i_objbin LINES lv_pdf_size.
*  READ TABLE i_objbin INDEX lv_pdf_size.
*  i_objpack-doc_size = lv_pdf_size * 255 .
*  i_objpack-body_num = lv_pdf_size.
*  i_objpack-doc_type = 'PDF'.
*  i_objpack-obj_name = 'T1'.
*  i_objpack-obj_descr = 'T1'.
*  APPEND i_objpack.
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = wa_doc_chng
      put_in_outbox              = 'X'
      commit_work                = 'X'
    TABLES
      packing_list               = i_objpack
      object_header              = wa_objhead
      contents_bin               = i_objbin
      contents_txt               = i_objtxt
      receivers                  = i_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
*  write sy-subrc.
*  commit work.
*FORMAT COLOR COL_KEY.
  IF sy-subrc EQ 0.
    FORMAT COLOR COL_POSITIVE.
    WRITE :/ 'Pernr. = ',iv_pernr,'Ad Soyad = ' ,lv_ename,'personelin bordrosu mail ile gönderildi'.
  ELSE.
    FORMAT COLOR COL_NEGATIVE.
    WRITE :/ 'Pernr. = ',iv_pernr,'Ad Soyad = ' ,lv_ename, 'personelin bordrosu mail ile gönderilemedi'.

  ENDIF.
*  WRITE SY-SUBRC.
*  COMMIT WORK AND WAIT.
  WAIT UP TO 1 SECONDS.

ENDFUNCTION.
