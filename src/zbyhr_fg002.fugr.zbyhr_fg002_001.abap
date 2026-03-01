FUNCTION zbyhr_fg002_001.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_PERNR) TYPE  PA0001-PERNR OPTIONAL
*"     REFERENCE(IV_SEQUENCE) TYPE  BAPI7004_RL-SEQUENCENUMBER
*"     REFERENCE(IV_PYVAR) TYPE  BAPI7004-PAYSLIP_VARIANT
*"     REFERENCE(IV_MONTH) TYPE  CHAR10
*"     REFERENCE(IV_YEAR) TYPE  CHAR04
*"     REFERENCE(IV_SAVE) TYPE  CHAR1
*"     REFERENCE(IV_SVFL) TYPE  STRING
*"     REFERENCE(IV_FORML) TYPE  FORMU_514D
*"     VALUE(IT_PERNR) TYPE  HRPADUN_AAP_PERSONS OPTIONAL
*"     REFERENCE(IV_SPOOL) TYPE  CHAR1
*"     REFERENCE(IT_DATE) TYPE  HRPBSDEZV_FPPER
*"     REFERENCE(IV_LOW) TYPE  FPPER
*"     REFERENCE(IV_HIGH) TYPE  FPPER
*"----------------------------------------------------------------------
  DATA: lv_xstring    TYPE xstring.
  DATA: lo_http_client    TYPE REF TO if_http_client,
        lv_url            TYPE string,
        lv_response       TYPE string,
        lv_uname          TYPE string VALUE 'TESTUSER',
        lv_username       TYPE string,
        lv_password       TYPE string,
        lv_pdf_base64     TYPE string,
        lv_soap           TYPE string,
        lv_user           TYPE string,
        lv_pass           TYPE string,
        lv_status         TYPE i,
        lv_reason         TYPE string,
        lv_base64_result  TYPE string,
        lv_xstring_result TYPE xstring,
        lt_binary_tab     TYPE TABLE OF solisti1, " PDF için SOLIX (binary) daha uygundur
        lv_bin_len        TYPE i,
        lv_base64         TYPE string,
        lv_binary         TYPE xstring,
        it_attach         TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE.
  DATA : ltt_soli  TYPE soli_tab,
         ltt_solix TYPE solix_tab,
         bin_file2 TYPE xstring.

  DATA: lv_current   TYPE i,
        lv_year      TYPE i,
        lv_month     TYPE i,
        lt_periods   TYPE TABLE OF string,
        lv_text      TYPE string,
        lv_month_str TYPE string,
        lv_index     TYPE i,
        lv_joined    TYPE string.

  DATA bin_file TYPE xstring. "TUGUR
  DATA : lv_email    LIKE pa0105-usrid_long,
         lt_tline    TYPE TABLE OF tline WITH HEADER LINE,
         lv_zarf     TYPE xstring,
         ls_return   TYPE bapireturn1,
         lv_pdf_size TYPE i,
         lv_size     TYPE i.
  DATA :  lt_record LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  DATA :  wa_buffer TYPE string.
  DATA : i_reclist    LIKE somlreci1  OCCURS 0 WITH HEADER LINE,
         wa_objhead   TYPE soli_tab, w_ctrlop TYPE ssfctrlop,
         i_objpack    LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
         i_objtxt     LIKE solisti1    OCCURS 0 WITH HEADER LINE,
         wa_doc_chng  TYPE sodocchgi1, w_data TYPE sodocchgi1,
         lv_lines_txt TYPE i,
         lt_lines     LIKE tline       OCCURS 0 WITH HEADER LINE,
         i_objbin     LIKE solisti1    OCCURS 0 WITH HEADER LINE.
  DATA : lv_strlen TYPE i.
  DATA: lv_string TYPE  string,
        l_data    TYPE  string.
  DATA: ls_return1 TYPE bapireturn1,
        p_info     LIKE  pc407,
        p_form     LIKE pc408         OCCURS 0 WITH HEADER LINE.
  DATA: m_xstring TYPE xstring.
  DATA :  lt_record1 LIKE solisti1 OCCURS 0 WITH HEADER LINE.
  "*---- get mail adres for pers
  DATA : lv_ename TYPE emnam.
  DATA : lv_lpdf    TYPE i,
         lv_pdfname TYPE string.
  DATA : ls_0001 TYPE p0001 .
  DATA :
    ls_print_parameters TYPE pri_params,
    lv_listname         TYPE pri_params-plist VALUE 'PUBLIC PAYROLL'.
  DATA  : list_text2 TYPE pri_params-prtxt.

  DATA:
    l_lay   TYPE pri_params-paart,
    l_lines TYPE pri_params-linct,
    l_cols  TYPE pri_params-linsz,
    l_val   TYPE c.
*Types
  TYPES:
    t_pripar TYPE pri_params,
    t_arcpar TYPE arc_params.
  "Work areas
  DATA:
    lw_pripar TYPE t_pripar,
    l_valid   TYPE string,
    lw_arcpar TYPE t_arcpar.

  DATA : lt_rspar TYPE TABLE OF rsparams,
         ls_rspar TYPE rsparams.

  DATA: lt_rgdir  TYPE STANDARD TABLE OF pc261 WITH HEADER LINE,
        ls_result TYPE pay99_result,
        gt_msg    TYPE TABLE OF bapiret2 WITH HEADER LINE.

  CLEAR: lv_email,lv_zarf,ls_return,lv_pdf_size,lv_ename,wa_buffer.
  REFRESH : lt_tline,lt_record,i_objpack,
            wa_objhead,i_objbin,
            i_objtxt,i_reclist.

  SET LANGUAGE 'TR'.
  SET LOCALE LANGUAGE 'T'.

  DATA : month TYPE pnppabrj .

  DATA: ls_t247 TYPE t247.

  SELECT SINGLE * FROM  t247 INTO ls_t247
         WHERE  spras  EQ 'TR'
         AND    ltx    EQ iv_month.

  IF it_pernr[] IS NOT INITIAL.
    LOOP AT it_pernr ASSIGNING FIELD-SYMBOL(<wa>).
      ls_rspar-selname = 'PNPPERNR'.
      ls_rspar-kind    = 'S'.
      ls_rspar-sign    = 'I'.
      ls_rspar-option  = 'EQ'.
      ls_rspar-low     = <wa>-pernr.
      APPEND ls_rspar TO lt_rspar.
    ENDLOOP.
    CLEAR : list_text2.
*    CONCATENATE 'ALL' iv_year iv_month  INTO list_text2 SEPARATED BY '+'
    .
  ELSE.
    ls_rspar-selname = 'PNPPERNR'.
    ls_rspar-kind    = 'S'.
    ls_rspar-sign    = 'I'.
    ls_rspar-option  = 'EQ'.
    ls_rspar-low     = iv_pernr.
    APPEND ls_rspar TO lt_rspar.

*    LOOP AT it_date.
*
*    ENDLOOP.

    CLEAR : list_text2.
*    CONCATENATE iv_pernr iv_year iv_month INTO list_text2 SEPARATED BY
*    '+' .
  ENDIF.

  CONCATENATE iv_pernr 'BORDROZARFI' INTO list_text2 SEPARATED BY  '+' .
  CONCATENATE list_text2 sy-uzeit INTO list_text2.
*  CONCATENATE list_text2   sy-uzeit INTO list_text2 .
  l_lay   = 'X_65_200'.
  l_lines = 65.
  l_cols  = 177.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = lw_arcpar
      in_parameters          = lw_pripar
      layout                 = l_lay
      line_count             = l_lines
      line_size              = l_cols
      abap_list              = 'X'
      list_name              = lv_listname
      list_text              = list_text2
*     list_text              = list_text2
*     mode                   = 'OKPRI1'
      no_dialog              = 'X'
    IMPORTING
      out_archive_parameters = lw_arcpar
      out_parameters         = ls_print_parameters
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  TYPES: BEGIN OF linetype,
           sign   TYPE c LENGTH 1,
           option TYPE c LENGTH 2,
           low    TYPE spmon,
           high   TYPE spmon,
         END OF linetype.


  DATA : lr_range TYPE RANGE OF linetype.
  DATA : ls_range LIKE LINE OF lr_range.


  IF iv_low  IS NOT INITIAL AND
     iv_high IS NOT INITIAL.
    ls_range-low = iv_low.
    ls_range-high = iv_high.
    ls_range-sign = 'I'.
    ls_range-option = 'BT'.


    APPEND ls_range TO lr_range.

  ELSEIF iv_low  IS NOT INITIAL AND
         iv_high IS INITIAL.

    ls_range-low = iv_low.
    ls_range-high = iv_high.
    ls_range-sign = 'I'.
    ls_range-option = 'EQ'.


    APPEND ls_range TO lr_range.
  ENDIF.

  REFRESH: lt_rgdir.
  CALL FUNCTION 'CA_CU_READ_RGDIR_NEW'
    EXPORTING
      persnr                   = iv_pernr
    TABLES
      cu_ca_rgdir              = lt_rgdir
    EXCEPTIONS
      import_mismatch_error_cu = 1
      import_mismatch_error_ca = 2
      no_read_authority_ca     = 3
      no_read_authority_cu     = 4
      error_reading_cu         = 5
      error_reading_ca         = 6
      no_record_found          = 7
      OTHERS                   = 8.

  IF sy-subrc EQ 0.
*  ls_print_parameters-pdest = 'Z_SB'.
    SUBMIT zbyhr_p020
*          WITH rueckd EQ 'X'
*          WITH rueckr EQ 'J'
*          WITH sort_rr EQ '1'
*          WITH sprache EQ 'B'
*          WITH andruck EQ 'A'
*          WITH bondt EQ space
**          WITH prt_prot EQ 'X'
*          WITH cur_fp EQ 'X'
            WITH formular EQ '-BOY'"'MCD3'
*          WITH payid EQ space
*          WITH payty EQ space
*          WITH pnpxabkr EQ '01'
*          WITH pnptimra EQ 'X'
*          WITH pnppabrp EQ ls_t247-mnr
*          WITH pnppabrj EQ iv_year
*          WITH prt_prot EQ space
*           WITH s_fpper-low  EQ iv_low
*           WITH s_fpper-high EQ iv_high
             WITH s_fpper IN  lr_range
            WITH SELECTION-TABLE lt_rspar
               AND RETURN TO SAP-SPOOL
                SPOOL PARAMETERS ls_print_parameters WITHOUT SPOOL DYNPRO
                .
  ENDIF.
  DATA :
        lv_spool_nr TYPE rspoid.

  DATA(lv_rqcretime) = sy-datum+0(8) && '%'.
*rqident
*  SELECT * FROM tsp01 INTO TABLE @DATA(lt_tsp01)
*    WHERE
*      rqclient  = @sy-mandt   AND
*      rq2name   = @lv_listname AND
*      rqowner   = @sy-uname   AND
*      rqcretime LIKE @lv_rqcretime.

  SELECT * FROM tsp01 INTO TABLE @DATA(lt_tsp01)
    WHERE
      rqclient  = @sy-mandt  AND
      rqtitle   = @list_text2 AND
      rq2name   = @lv_listname AND
      rqowner   = @sy-uname
*      rqcretime LIKE @lv_rqcretime
    .
  CHECK sy-subrc EQ 0 .

  SORT lt_tsp01 DESCENDING BY rqcretime.
  READ TABLE lt_tsp01 ASSIGNING FIELD-SYMBOL(<tsp01>)
  INDEX 1.
  lv_spool_nr = <tsp01>-rqident.

  DATA :
        lt_pdf TYPE TABLE OF tline.

*  DATA : lv_dst_device LIKE  tsp03-padest VALUE 'I9PDF'.
*  DATA : lv_dst_device LIKE  tsp03-padest VALUE 'ZI9SWIN'.
  DATA : lv_dst_device LIKE  tsp03-padest VALUE 'Z_SB'.
  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = lv_spool_nr
      dst_device               = lv_dst_device
      no_dialog                = 'X'
    TABLES
      pdf                      = lt_pdf
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.

  DATA :
    ls_line     TYPE tline,
    lv_buffer   TYPE xstring,
    l_xline     TYPE xstring,
    l_pdfstring TYPE xstring.
*    lv_string   TYPE string.

  FIELD-SYMBOLS: <x> TYPE any.

  DATA l_mimetype TYPE mimetypes-type.
  DATA i_mime_type  TYPE string .
  CALL FUNCTION 'SDOK_MIMETYPE_GET'
    EXPORTING
      extension = 'PDF'
    IMPORTING
      mimetype  = l_mimetype.
  i_mime_type = l_mimetype.

  lt_tline[] = lt_pdf[].

  LOOP AT lt_tline.
    TRANSLATE lt_tline USING '~'.
    CONCATENATE wa_buffer lt_tline INTO wa_buffer.
  ENDLOOP.
  TRANSLATE wa_buffer USING '~'.
  DO.
    lt_record = wa_buffer.
    APPEND lt_record.
    SHIFT wa_buffer LEFT BY 255 PLACES.
    IF wa_buffer IS INITIAL.
      EXIT.
    ENDIF.
  ENDDO.

  IF iv_spool IS NOT INITIAL AND lt_record[] IS NOT INITIAL.
    DATA : ls_soli  TYPE soli,
           lt_soli  TYPE soli_tab,
           lt_solix TYPE solix_tab.
    CLEAR : ls_soli, bin_file.
    REFRESH : lt_soli, lt_solix.

    lt_soli[] = lt_record[].
*    loop at lt_record.
*      ls_soli-line = lt_record-line.
*      append ls_soli to lt_soli.
*    endloop.

    TRY.
        CALL METHOD cl_bcs_convert=>soli_to_solix
          EXPORTING
            it_soli  = lt_soli
          RECEIVING
            et_solix = lt_solix.
      CATCH cx_bcs .
    ENDTRY.

    CALL METHOD cl_bcs_convert=>solix_to_xstring
      EXPORTING
        it_solix   = lt_solix
*       iv_size    =
      RECEIVING
        ev_xstring = bin_file.

    EXPORT bin_file = bin_file TO MEMORY ID 'ZPAYROLL_PDF'.
  ENDIF.


  CLEAR: ltt_soli,ltt_solix,bin_file2.
  ltt_soli[] = lt_record[].
  TRY.
      CALL METHOD cl_bcs_convert=>soli_to_solix
        EXPORTING
          it_soli  = ltt_soli
        RECEIVING
          et_solix = ltt_solix.
    CATCH cx_bcs .
  ENDTRY.

  CALL METHOD cl_bcs_convert=>solix_to_xstring
    EXPORTING
      it_solix   = ltt_solix
*     iv_size    =
    RECEIVING
      ev_xstring = bin_file2.
**********************************************************************
**********************************************************************
  CHECK iv_spool IS INITIAL.
  IF iv_save EQ 'X'.
*    CONCATENATE iv_svfl '\' iv_month '_' iv_year
*                '_Bordro_Zarfı_' sy-uzeit '.pdf'
*           INTO lv_pdfname.

    CONCATENATE iv_svfl '\'
             iv_low+4(2) '_' iv_low(4) '-'
             iv_high+4(2) '_' iv_high(4) '_'
             iv_pernr '_Bordro_Zarfı.pdf'
*                '_Bordro_Zarfı_' sy-uzeit '.pdf'
          INTO lv_pdfname.


    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_pdfname
        filetype                = 'BIN'
      TABLES
        data_tab                = lt_record
*       FIELDNAMES              =
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    WAIT UP TO 1 SECONDS.

  ENDIF.
**********************************************
  CHECK iv_save EQ space.
  DATA lv_sayac TYPE i.
  DATA lt_p1 TYPE TABLE OF pa0001.
  DATA ls_p1 TYPE pa0001.
  DATA lv_lines TYPE i.
  DATA lv_begda TYPE sy-datum.
  DATA lv_endda TYPE sy-datum.
  DATA lv_line TYPE char3.
  DATA lv_mesaj TYPE char70.
  DATA lt_p1a TYPE TABLE OF pa0001.
  DATA ls_p1a TYPE          pa0001.
  DATA lv_toplam TYPE i.
  DATA lv_rand TYPE i.


  " Şifreleme
  CALL FUNCTION 'QF05_RANDOM_INTEGER'
    EXPORTING
      ran_int_max = 9999
      ran_int_min = 1000
    IMPORTING
      ran_int     = lv_rand.

  lv_url = 'https://integration-suite-boyner-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/cxf/SFBordroEncryption'.
  lv_pdf_base64 = cl_http_utility=>encode_x_base64( bin_file2 ).

  CLEAR lv_soap.
  lv_soap = |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" |
            && |xmlns:tem="http://tempuri.org/">|
            && |<soapenv:Header/>|
            && |<soapenv:Body>|
            && |<tem:setEncryption>|
            && |<tem:LineArray>{ lv_pdf_base64 }</tem:LineArray>|
              && |<tem:Password>12345</tem:Password>|
*            && |<tem:Password>{ lv_rand }</tem:Password>|
            && |</tem:setEncryption>|
            && |</soapenv:Body>|
            && |</soapenv:Envelope>|.


  CALL METHOD cl_http_client=>create_by_url
    EXPORTING
      url                = lv_url
    IMPORTING
      client             = lo_http_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4.

  lv_user = 'sb-d2368223-0848-475f-9a23-af554aba692e!b550443|it-rt-integration-suite-boyner-dev!b182722'.
  lv_pass = '02189b29-d15c-4c84-9ee0-1bae741de3e7$_N3xcbMxDxXjAh8NZMn7dFxNBcOCccvS7fgEVJxkENM='.
  " Basic Auth
  lv_username = lv_user.
  lv_password = lv_pass.
  lo_http_client->authenticate(
    username = lv_username
    password = lv_password
  ).

  lo_http_client->request->set_method( 'POST' ).
  lo_http_client->request->set_header_field(
    name  = 'Content-Type'
    value = 'text/xml; charset=utf-8'
  ).

  lo_http_client->request->set_cdata( lv_soap ).
  lo_http_client->send( ).
  lo_http_client->receive( ).
  lv_response = lo_http_client->response->get_cdata( ).

  lo_http_client->response->get_status( IMPORTING code = lv_status reason = lv_reason ).


  FIND FIRST OCCURRENCE OF REGEX '<setEncryptionResult>(.*)</setEncryptionResult>'
    IN lv_response
    IGNORING CASE
    SUBMATCHES lv_base64_result.

  lv_binary = cl_http_utility=>decode_x_base64( lv_base64_result ).

  CLEAR: it_attach[],it_attach.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer          = lv_binary
      append_to_table = 'X' "Do not clear/refresh table
    TABLES
      binary_tab      = it_attach.
  " Şifreleme

  LOOP AT lt_rspar ASSIGNING FIELD-SYMBOL(<rspar>)
      WHERE selname = 'PNPPERNR'.

    CLEAR wa_doc_chng.
    CLEAR i_objpack.
    REFRESH : i_objpack,
              wa_objhead,
              i_objbin,
              i_objtxt,
              i_reclist.
    lv_sayac = 1 + lv_sayac.
    SELECT SINGLE ename FROM pa0001 INTO lv_ename
    WHERE pernr EQ <rspar>-low.

    SELECT SINGLE * FROM pa0001 INTO CORRESPONDING FIELDS OF ls_0001
          WHERE pernr EQ <rspar>-low
            AND endda GE sy-datum .
    "Düzeltme! 14.01.2025 sy

    SELECT SINGLE usrid_long INTO lv_email FROM pa0105
             WHERE pernr EQ <rspar>-low AND
                   begda LE sy-datum AND
*                   usrty EQ '0030'  AND   " şirket maili
                   usrty EQ '0010'  AND   " şirket maili
                   endda GE sy-datum.

    IF sy-subrc NE 0.
      SELECT SINGLE usrid_long INTO lv_email FROM pa0105
               WHERE pernr EQ <rspar>-low AND
                     begda LE sy-datum AND
                     usrty EQ '0030'  AND   " şirket maili
                     endda GE sy-datum.
      IF sy-subrc NE 0.
        FORMAT COLOR COL_NEGATIVE.
        WRITE :/ 'Pernr. = ',iv_pernr,'Ad Soyad = ' ,lv_ename,
        'personelin mail verilerini kontrol edin'.
        EXIT.
      ENDIF.
    ENDIF.

    CONCATENATE 'Sayın' lv_ename ',' INTO i_objtxt SEPARATED BY space.
    APPEND i_objtxt.
    i_objtxt = ''.
    APPEND i_objtxt.

    lv_current = iv_low.
    CLEAR lt_periods.

    WHILE lv_current <= iv_high.
      lv_year = lv_current DIV 100.
      lv_month = lv_current MOD 100.

      " Ayı 2 hane sıfırla doldur
      IF lv_month < 10.
        lv_month_str = |0{ lv_month }|.
      ELSE.
        lv_month_str = |{ lv_month }|.
      ENDIF.

      APPEND |{ lv_month_str }.{ lv_year }| TO lt_periods.

      " Sonraki aya geç
      IF lv_month = 12.
        lv_month = 1.
        lv_year = lv_year + 1.
      ELSE.
        lv_month = lv_month + 1.
      ENDIF.

      lv_current = lv_year * 100 + lv_month.
    ENDWHILE.

    CLEAR lv_joined.

    LOOP AT lt_periods INTO DATA(lv_period).
      lv_index = sy-tabix.
      IF lv_index = 1.
        lv_joined = lv_period.
      ELSE.
        lv_joined = lv_joined && ', ' && lv_period.
      ENDIF.
    ENDLOOP.

    lv_text = |{ lv_joined } dönemine ait bordronuz ekte bilgilerinize sunulmuştur.|.
    IF iv_high IS NOT INITIAL.
      i_objtxt = lv_text.
      APPEND i_objtxt.
    ELSE.
      CONCATENATE iv_low+4(2) iv_low(4)
    'dönemine ait maaş bordronuz ekte bilginize sunulmuştur.' INTO
    i_objtxt SEPARATED BY space.
      APPEND i_objtxt.
    ENDIF.


    i_objtxt = ''.
    APPEND i_objtxt.
    i_objtxt = 'Saygılarımızla,'.
    APPEND i_objtxt.
    i_objtxt = 'İnsan Kaynakları'.
    APPEND i_objtxt.
*--- send mail
    wa_doc_chng-obj_descr = 'BORDRO'
        && '(' && iv_low+4(2) && '.' && iv_low(4) && ')'."necip reha 07.05.25
    wa_doc_chng-obj_name = 'Maaş Zarfı'.
    wa_doc_chng-expiry_dat = sy-datum + 10.
*      DATA: w_cnt TYPE i.
    DESCRIBE TABLE it_attach LINES lv_pdf_size.
    READ TABLE it_attach INDEX lv_pdf_size.
    wa_doc_chng-doc_size = ( lv_pdf_size - 1 ) * 255 + strlen( it_attach ).
    i_reclist-rec_type = 'U'.
    i_reclist-express = 'X'.
    i_reclist-receiver = lv_email.
    APPEND i_reclist.
    DATA lv_sender TYPE soextreci1-receiver.
    lv_sender = 'boyner@boyner.com'.
    "eklendi sy 15.01.2025
****    clear lt_tline.
****    clear lt_record.
****    clear lt_record[].
****    read table lt_tline index lv_sayac.
****    if sy-subrc = 0.
****     MOVE-CORRESPONDING i_objbin to lt_record.
****     append lt_record.
****     endif.
    "kapatıldı 15.01.2025 sy
*    i_objbin[] = lt_record[].
*    i_objbin[] = it_attach[].
*  I_OBJTXT = 'Maas Zarfi'.
*  APPEND I_OBJTXT.

    DESCRIBE TABLE i_objtxt LINES lv_lines_txt.
    READ TABLE i_objtxt INDEX lv_lines_txt.
    " * Main Text
    CLEAR i_objpack-transf_bin.
    i_objpack-head_start = 1.
    i_objpack-head_num = 0.
    i_objpack-body_start = 1.
    i_objpack-body_num = lv_lines_txt.
    i_objpack-doc_type = 'RAW'.
    APPEND i_objpack.
* Attachment (pdf-Attachment)
    i_objpack-transf_bin = 'X'.
    i_objpack-head_start = 1.
    i_objpack-head_num = 0.
    i_objpack-body_start = 1.

    DESCRIBE TABLE it_attach LINES lv_pdf_size.
    READ TABLE it_attach INTO DATA(ls_sol) INDEX lv_pdf_size.
    i_objpack-doc_size = lv_pdf_size * 255 .
    i_objpack-body_num = lv_pdf_size.
    i_objpack-doc_type = 'PDF'.
    i_objpack-obj_name = 'Maas Zarfi'.


    IF iv_high IS INITIAL.
      i_objpack-obj_descr = 'Maas Zarfi'
      && '(' && iv_low+4(2) && '.' && iv_low(4) && ')'.
    ELSE.
      READ TABLE lt_periods INTO DATA(ls_per) INDEX 1.
      DATA(per1) = ls_per.
      DESCRIBE TABLE lt_periods LINES DATA(lv_ind).
      READ TABLE lt_periods INTO ls_per INDEX lv_ind.
      i_objpack-obj_descr = 'Maas Zarfi'
      && '(' && per1 && '-' && ls_per && '_' && iv_pernr && ')'.
    ENDIF.

    .
    APPEND i_objpack.

    "Revize! 20.01.2025 SY

    CLEAR ls_p1.
    CLEAR lt_p1.
    CLEAR lv_lines.
    CLEAR lv_toplam.
    CLEAR: ls_p1a, lt_p1a, lv_begda, lv_endda, lv_line, lv_mesaj.

    lv_begda = iv_low && '01'.
    lv_endda = iv_low && '31'.

    SELECT  * FROM pa0001 INTO CORRESPONDING FIELDS OF TABLE lt_p1
          WHERE pernr EQ ls_rspar-low
            AND begda <= lv_endda
            AND endda >= lv_begda.
*            and gsber is not null.
*            and gsber = '01'.
*      delete lt_p1 where gsber = ''.
    lv_lines = lines( lt_p1 ).

    "1den fazla kaydı varsa boş olanları sildirip kaç iş alanı var bakıyoruz
    IF lv_lines > 1.
      DELETE lt_p1 WHERE gsber = ''.
      lv_lines = lines( lt_p1 ).
      lv_line = lv_lines.

      "farklı iş alanı var mı diye bakıyoruz
      lt_p1a[] = lt_p1[].
      CLEAR lv_toplam.
      READ TABLE lt_p1 INTO ls_p1 INDEX 1.
      IF sy-subrc = 0.
        LOOP AT lt_p1a INTO ls_p1a WHERE gsber <> ls_p1-gsber. "farklı  gsber var ise.
          lv_toplam = lv_toplam + 1.
        ENDLOOP.

      ENDIF.

      "birden fazla iş alanı varsa mesaj versin
      IF lv_toplam <> 0.
        lv_toplam = lv_toplam + 1. "kendisini de toplama dahil edicem.
        lv_line = lv_toplam.
        CONCATENATE 'İlgili dönem içerisinde'  lv_line 'farklı iş alanı bulunmaktadır.'
        INTO lv_mesaj SEPARATED BY space.

        FORMAT COLOR COL_NEGATIVE.
        WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename.
        WRITE :/ lv_mesaj.

        "tek bir iş alanı varsa gsber 01 ise mail göndersin.
      ELSEIF lv_toplam = 0.
*        READ TABLE lt_p1 INTO ls_p1 INDEX lv_lines.
*        IF sy-subrc = 0 AND ls_p1-gsber = '01'.

        CALL FUNCTION ' SO_DOCUMENT_SEND_API1'
          EXPORTING
            document_data              = wa_doc_chng
            put_in_outbox              = 'X'
            sender_address             = lv_sender
            sender_address_type        = 'SMTP'
            commit_work                = 'X'
          TABLES
            packing_list               = i_objpack
            object_header              = wa_objhead
            contents_bin               = it_attach
            contents_txt               = i_objtxt
            receivers                  = i_reclist
*           contents_hex               = lt_solix2
          EXCEPTIONS
            too_many_receivers         = 1
            document_not_sent          = 2
            document_type_not_exist    = 3
            operation_no_authorization = 4
            parameter_error            = 5
            x_error                    = 6
            enqueue_error              = 7
            OTHERS                     = 8.

        IF sy-subrc EQ 0.
          FORMAT COLOR COL_POSITIVE.
          WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
          'personelin bordrosu mail ile gönderildi'.
        ELSE.
          FORMAT COLOR COL_NEGATIVE.
          WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
          'personelin bordrosu mail ile gönderilemedi'.

        ENDIF.
*  WRITE SY-SUBRC.
*  COMMIT WORK AND WAIT.
        WAIT UP TO 1 SECONDS.
        "gsber 01 den farklı ise mesaj versin
*        ELSEIF ls_p1-gsber <> '01'.
*          FORMAT COLOR COL_NEGATIVE.
*          WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
*          'personelin iş alanı mavi yaka olmadığı için bordrosu mail ile gönderilemedi'.
*      ENDIF.
      ENDIF.

      "satır sayısı 1 den büyük değilse
    ELSE.

*      READ TABLE lt_p1 INTO ls_p1 INDEX lv_lines.
*      IF sy-subrc = 0 AND ls_p1-gsber = '01'.

      CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
        EXPORTING
          document_data              = wa_doc_chng
          put_in_outbox              = 'X'
          sender_address             = lv_sender
          sender_address_type        = 'SMTP'
          commit_work                = 'X'
        TABLES
          packing_list               = i_objpack
          object_header              = wa_objhead
          contents_bin               = it_attach
          contents_txt               = i_objtxt
          receivers                  = i_reclist
*         contents_hex               = lt_solix2
        EXCEPTIONS
          too_many_receivers         = 1
          document_not_sent          = 2
          document_type_not_exist    = 3
          operation_no_authorization = 4
          parameter_error            = 5
          x_error                    = 6
          enqueue_error              = 7
          OTHERS                     = 8.

*FORMAT COLOR COL_KEY.
      IF sy-subrc EQ 0.
        FORMAT COLOR COL_POSITIVE.
        WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
        'personelin bordrosu mail ile gönderildi'.
      ELSE.
        FORMAT COLOR COL_NEGATIVE.
        WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
        'personelin bordrosu mail ile gönderilemedi'.

      ENDIF.
*  WRITE SY-SUBRC.
*  COMMIT WORK AND WAIT.
      WAIT UP TO 1 SECONDS.
*      ELSE.
*        FORMAT COLOR COL_NEGATIVE.
*        WRITE :/ 'Pernr. = ',<rspar>-low,'Ad Soyad = ' ,lv_ename,
*        'personelin iş alanı mavi yaka olmadığı için bordrosu mail ile gönderilemedi'.
*  ENDIF.
    ENDIF.

  ENDLOOP.

  DATA: lv_json  TYPE string,
        lv_auth  TYPE string,
        lv_rand2 TYPE string.

  " JSON Gövdesi (Türkçe karakter içeriyor)
*lv_json = {
*  PhoneNumber = 5375773336,
*  SmsContent": "Türkçe karakter: çşğüöİ",
*  Originator": 1,
*  SmsDeliveryType": 2,
*  MessageSubject": "Eba OTP",
*  PermissionFilter": false
*          }.

  SELECT SINGLE usrid INTO @DATA(lv_tel) FROM pa0105
           WHERE pernr EQ @<rspar>-low AND
                 begda LE @sy-datum AND
                 usrty EQ 'CELL'  AND
                 endda GE @sy-datum.
  lv_rand2 = lv_rand.
  CONCATENATE lv_json '{ '
           '"PhoneNumber":'           '"' lv_tel '",'
           '"SmsContent":' '"Sifreniz:' lv_rand2 '",'
*             '"SmsContent":' '"Sifreniz: 12345,'
           '"Originator": 1,'
           '"SmsDeliveryType": 2,'
           '"MessageSubject": "Eba OTP",'
           '"PermissionFilter": false' INTO lv_json.

  CONCATENATE lv_json ' }' INTO lv_json.


  " Endpoint URL
  lv_url = 'https://sms-manager-api.aks01.marketplace-ecom.prod.boynercloud.io/sms'.

  " Basic Authorization Base64 (kendi kullanıcı:şifre değiştir)
  lv_auth = 'Basic TWVyc3VzOmx5cFdsbU1KNnAzNA=='.

  " HTTP Client Oluşturma
  cl_http_client=>create_by_url(
    EXPORTING
      url                = lv_url
    IMPORTING
      client             = lo_http_client
    EXCEPTIONS
      argument_not_found = 1
      plugin_not_active  = 2
      internal_error     = 3
      OTHERS             = 4 ).

  IF sy-subrc <> 0.
    " Hata yönetimi
    WRITE: / 'HTTP client creation failed'.
    RETURN.
  ENDIF.

  " HTTP Header'ları ayarla
  lo_http_client->request->set_header_field( name = 'Authorization' value = lv_auth ).
  lo_http_client->request->set_header_field( name = 'Content-Type'  value = 'application/json; charset=utf-8' ).

  " HTTP Method POST ayarla
  lo_http_client->request->set_method( if_http_request=>co_request_method_post ).

  " Gövdeye JSON ata (UTF-8 varsayılan)
  lo_http_client->request->set_cdata( lv_json ).

  " İstek gönder
  CALL METHOD lo_http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  " Cevabı al
  CALL METHOD lo_http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.

  CLEAR : lv_response,lv_status,lv_reason.

  lv_response = lo_http_client->response->get_cdata( ).
  lo_http_client->response->get_status( IMPORTING code = lv_status reason = lv_reason ).

ENDFUNCTION.
