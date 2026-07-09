*----------------------------------------------------------------------*
***INCLUDE LZBYHR_FG002F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_person_payroll_pdf
*&---------------------------------------------------------------------*
FORM get_person_payroll_pdf  TABLES   it_person TYPE  tt_person
                                      it_pernr  TYPE hrpadun_aap_persons
                             USING    iv_pernr
                                      iv_low
                                      iv_high
                                      p_merg .
*Types
  TYPES : t_pripar TYPE pri_params,
          t_arcpar TYPE arc_params,
          BEGIN OF linetype,
            sign   TYPE c LENGTH 1,
            option TYPE c LENGTH 2,
            low    TYPE spmon,
            high   TYPE spmon,
          END OF linetype.


  DATA : lr_range            TYPE RANGE OF linetype,
         lt_record           TYPE TABLE OF  solisti1,
         lt_pdf              TYPE TABLE OF tline,
*         lv_dst_device       LIKE tsp03-padest VALUE 'Z_SB',
         lv_dst_device       LIKE tsp03-padest VALUE 'PDF_YAZICI',
         lt_tline            TYPE TABLE OF tline WITH HEADER LINE,
         lt_rgdir            TYPE STANDARD TABLE OF pc261 WITH HEADER LINE,
         gt_msg              TYPE TABLE OF bapiret2 WITH HEADER LINE,
         lv_listname         TYPE pri_params-plist VALUE 'PUBLIC PAYROLL',
         ls_range            LIKE LINE OF lr_range,
         lv_pernr            TYPE persno,
         wa_buffer           TYPE string,
         lv_spool_nr         TYPE rspoid,
         ls_result           TYPE pay99_result,
*         ls_t247             TYPE t247,
         ls_print_parameters TYPE pri_params,
         lt_rspar            TYPE TABLE OF rsparams,
         lw_pripar           TYPE t_pripar,
         lw_arcpar           TYPE t_arcpar,
         list_text           TYPE pri_params-prtxt,
         ls_rspar            TYPE rsparams.

*  SELECT SINGLE * FROM t247 INTO ls_t247 WHERE spras EQ 'TR' AND ltx EQ iv_month.

  IF it_pernr[] IS NOT INITIAL.
    LOOP AT it_pernr ASSIGNING FIELD-SYMBOL(<wa>).
      APPEND VALUE #( selname = 'PNPPERNR' kind    = 'S' sign    = 'I' option  = 'EQ' low     = <wa>-pernr ) TO lt_rspar.
    ENDLOOP.
  ELSE.
    APPEND VALUE #( selname = 'PNPPERNR' kind    = 'S' sign    = 'I' option  = 'EQ' low     = iv_pernr ) TO lt_rspar.
  ENDIF.

  CASE 'X'.
    WHEN p_merg.
      APPEND  INITIAL LINE TO it_person ASSIGNING FIELD-SYMBOL(<fs_person>).
      <fs_person>-ename = 'Boyner'.
      CONCATENATE 'ÇOKLU' 'BORDROZARFI' INTO list_text SEPARATED BY  '+' .
      CONCATENATE list_text sy-uzeit INTO list_text.
      CALL FUNCTION 'GET_PRINT_PARAMETERS'
        EXPORTING
          in_archive_parameters  = lw_arcpar
          in_parameters          = lw_pripar
          layout                 = 'X_65_200'
          line_count             = 65
          line_size              = 177
          abap_list              = 'X'
          list_name              = lv_listname
          list_text              = list_text
          no_dialog              = 'X'
        IMPORTING
          out_archive_parameters = lw_arcpar
          out_parameters         = ls_print_parameters
        EXCEPTIONS
          archive_info_not_found = 1
          invalid_print_params   = 2
          invalid_archive_params = 3
          OTHERS                 = 4.
      IF sy-sysid EQ 'JBE'.
        ls_print_parameters-pdest = 'PDF_YAZICI'.
      ELSE.
        ls_print_parameters-pdest = 'ZPDF'.
      ENDIF.
      IF iv_low  IS NOT INITIAL AND iv_high IS NOT INITIAL.
        APPEND VALUE #( sign  = 'I' option = 'BT' low = iv_low high = iv_high ) TO lr_range.
      ELSEIF iv_low  IS NOT INITIAL AND iv_high IS INITIAL.
        APPEND VALUE #( sign  = 'I' option = 'EQ' low = iv_low high = iv_low ) TO lr_range.
      ENDIF.

      SUBMIT zbyhr_p020
              WITH formular EQ '-BOY'
               WITH s_fpper IN  lr_range
              WITH SELECTION-TABLE lt_rspar
                 AND RETURN TO SAP-SPOOL
                  SPOOL PARAMETERS ls_print_parameters WITHOUT SPOOL DYNPRO
                  .

      SELECT * FROM tsp01 INTO TABLE @DATA(lt_tsp01)
        WHERE rqclient  EQ @sy-mandt
          AND rqtitle   EQ @list_text
          AND rq2name   EQ @lv_listname
          AND rqowner   EQ @sy-uname .

      CHECK sy-subrc EQ 0 .

      SORT lt_tsp01 DESCENDING BY rqcretime.
      READ TABLE lt_tsp01 ASSIGNING FIELD-SYMBOL(<tsp01>) INDEX 1.
      lv_spool_nr = <tsp01>-rqident.

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
      <fs_person>-tpdf[] = lt_tline[] = lt_pdf[].

      LOOP AT lt_tline.
        TRANSLATE lt_tline USING '~'.
        CONCATENATE wa_buffer lt_tline INTO wa_buffer.
      ENDLOOP.
      TRANSLATE wa_buffer USING '~'.
      DO.
        APPEND wa_buffer TO lt_record.
        SHIFT wa_buffer LEFT BY 255 PLACES.
        IF wa_buffer IS INITIAL.
          EXIT.
        ENDIF.
      ENDDO.

      <fs_person>-trecord[] = lt_record[].
    WHEN OTHERS.

      LOOP AT lt_rspar ASSIGNING FIELD-SYMBOL(<fs_wa>).
        APPEND  INITIAL LINE TO it_person ASSIGNING <fs_person>.
        lv_pernr = <fs_person>-pernr = <fs_wa>-low.

        SELECT SINGLE ename FROM pa0001 INTO <fs_person>-ename
            WHERE pernr EQ <fs_person>-pernr
              AND endda GE sy-datum .

        CONCATENATE lv_pernr 'BORDROZARFI' INTO list_text SEPARATED BY  '+' .
        CONCATENATE list_text sy-uzeit INTO list_text.

        CALL FUNCTION 'GET_PRINT_PARAMETERS'
          EXPORTING
            in_archive_parameters  = lw_arcpar
            in_parameters          = lw_pripar
            layout                 = 'X_65_200'
            line_count             = 65
            line_size              = 177
            abap_list              = 'X'
            list_name              = lv_listname
            list_text              = list_text
            no_dialog              = 'X'
          IMPORTING
            out_archive_parameters = lw_arcpar
            out_parameters         = ls_print_parameters
          EXCEPTIONS
            archive_info_not_found = 1
            invalid_print_params   = 2
            invalid_archive_params = 3
            OTHERS                 = 4.

        IF sy-sysid EQ 'JBE'.
          ls_print_parameters-pdest = 'PDF_YAZICI'.
        ELSE.
          ls_print_parameters-pdest = 'ZPDF'.
        ENDIF.
        IF iv_low  IS NOT INITIAL AND iv_high IS NOT INITIAL.
          APPEND VALUE #( sign  = 'I' option = 'BT' low = iv_low high = iv_high ) TO lr_range.
        ELSEIF iv_low  IS NOT INITIAL AND iv_high IS INITIAL.
          APPEND VALUE #( sign  = 'I' option = 'EQ' low = iv_low high = iv_low ) TO lr_range.
        ENDIF.

        REFRESH: lt_rgdir.
        CALL FUNCTION 'CA_CU_READ_RGDIR_NEW'
          EXPORTING
            persnr                   = lv_pernr
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
        LOOP AT lt_rgdir WHERE fpper BETWEEN iv_low AND iv_high. ENDLOOP.
        CHECK sy-subrc EQ 0.
        SUBMIT zbyhr_p020
                WITH formular EQ '-BOY'
                 WITH s_fpper IN  lr_range
                WITH SELECTION-TABLE lt_rspar
                   AND RETURN TO SAP-SPOOL
                    SPOOL PARAMETERS ls_print_parameters WITHOUT SPOOL DYNPRO
                    .

        SELECT * FROM tsp01 INTO TABLE lt_tsp01
          WHERE rqclient  EQ sy-mandt
            AND rqtitle   EQ list_text
            AND rq2name   EQ lv_listname
            AND rqowner   EQ sy-uname .

        CHECK sy-subrc EQ 0 .

        SORT lt_tsp01 DESCENDING BY rqcretime.
        READ TABLE lt_tsp01 ASSIGNING <tsp01> INDEX 1.
        lv_spool_nr = <tsp01>-rqident.

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
        <fs_person>-tpdf[] = lt_tline[] = lt_pdf[].

        LOOP AT lt_tline.
          TRANSLATE lt_tline USING '~'.
          CONCATENATE wa_buffer lt_tline INTO wa_buffer.
        ENDLOOP.
        TRANSLATE wa_buffer USING '~'.
        DO.
          APPEND wa_buffer TO lt_record.
          SHIFT wa_buffer LEFT BY 255 PLACES.
          IF wa_buffer IS INITIAL.
            EXIT.
          ENDIF.
        ENDDO.

        <fs_person>-trecord[] = lt_record[].
      ENDLOOP.
  ENDCASE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_pdf
*&---------------------------------------------------------------------*
FORM download_pdf  TABLES   it_person TYPE  tt_person
                   USING    iv_svfl
                            iv_low
                            iv_high
                            iv_pernr.
  DATA : lv_pdfname TYPE string.

  LOOP AT it_person ASSIGNING FIELD-SYMBOL(<wa>).

*    CONCATENATE iv_svfl  '\'  iv_month '_' iv_year '_Bordro_Zarfı_' sy-uzeit '.pdf' INTO lv_pdfname.
    IF <wa>-pernr IS INITIAL .
      CONCATENATE iv_svfl '\' iv_low+4(2) '_' iv_low(4) '-' iv_high+4(2) '_'
                  iv_high(4) '_' <wa>-ename '_Bordro_Zarfı.pdf' INTO lv_pdfname.

    ELSE.
      CONCATENATE iv_svfl '\' iv_low+4(2) '_' iv_low(4) '-' iv_high+4(2) '_'
                  iv_high(4) '_' <wa>-pernr '_Bordro_Zarfı.pdf' INTO lv_pdfname.
    ENDIF.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_pdfname
        filetype                = 'BIN'
        codepage                = '4100'
      TABLES
        data_tab                = <wa>-trecord
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

    WAIT UP TO 1 SECONDS.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_pdf_password_service
*&---------------------------------------------------------------------*
FORM set_pdf_password_service  TABLES it_person TYPE  tt_person  .

  DATA : lt_rspar         TYPE TABLE OF rsparams,
         lo_http_client   TYPE REF TO if_http_client,
         ls_rspar         TYPE rsparams,
         ltt_soli         TYPE soli_tab,
         ltt_solix        TYPE solix_tab,
         lv_url           TYPE string,
         lv_soap          TYPE string,
         lv_user          TYPE string,
         lv_pass          TYPE string,
         lv_pdf_base64    TYPE string,
         lv_base64_result TYPE string,
         lv_status        TYPE i,
         lv_reason        TYPE string,
         lv_response      TYPE string.

  DATA : lo_encrypt TYPE REF TO zbyhr_cl_encryption.
  CREATE OBJECT lo_encrypt.


  LOOP AT it_person ASSIGNING FIELD-SYMBOL(<wa>).
    TRY.
        REFRESH : ltt_solix.
        FREE : lo_http_client.
        CLEAR : lv_pdf_base64.
        ltt_soli[] = <wa>-trecord[].
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
          RECEIVING
            ev_xstring = <wa>-bin_file.

        " Şifreleme
        CALL FUNCTION 'QF05_RANDOM_INTEGER'
          EXPORTING
            ran_int_max = 9999
            ran_int_min = 1000
          IMPORTING
            ran_int     = <wa>-password.

        lv_pdf_base64 = cl_http_utility=>encode_x_base64( <wa>-bin_file ).
        PERFORM encrpt_values USING <wa>-password
                           CHANGING <wa>-pass_xst
                                    <wa>-bin_file
                                    lv_pdf_base64
                                    <wa>-str_pass.

        "şifreyi aes yapmadan gönder
        <wa>-str_pass = <wa>-password.

*        DATA: lt_text TYPE STANDARD TABLE OF string.
*        APPEND lv_pdf_base64 TO lt_text.
*        CALL METHOD cl_gui_frontend_services=>gui_download
*          EXPORTING
*            filename = 'C:\TEMP\encrypted.pdf'
*            filetype = 'ASC'
*          CHANGING
*            data_tab = lt_text.

        lv_url = 'https://integration-suite-boyner-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/cxf/SFBordroEncryption'.
*        lv_pdf_base64 = cl_http_utility=>encode_x_base64( <wa>-bin_file ).
        CLEAR lv_soap.

        lv_soap = |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" |
                  && |xmlns:tem="http://tempuri.org/">|
                  && |<soapenv:Header/>|
                  && |<soapenv:Body>|
                  && |<tem:setEncryption>|
                  && |<tem:LineArray>{ lv_pdf_base64 }</tem:LineArray>|
                  && |<tem:Password>{ <wa>-str_pass }</tem:Password>|
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
        lo_http_client->authenticate(
          username = lv_user
          password = lv_pass
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
        CHECK lv_status EQ 200.
        FIND FIRST OCCURRENCE OF REGEX '<setEncryptionResult>(.*)</setEncryptionResult>'
          IN lv_response
          IGNORING CASE
          SUBMATCHES lv_base64_result.
*        <wa>-bin_file = cl_http_utility=>decode_x_base64( lv_base64_result ).

        IF lv_base64_result IS NOT INITIAL .

          <wa>-bin_file = cl_http_utility=>decode_x_base64( lv_base64_result ).
          lo_encrypt->decrypt_text(
            EXPORTING
              i_key              = 'BOYNER_ZARF_2026'
              i_iv               = '2026010120260101'
              i_encoded_text_xst = <wa>-bin_file
            IMPORTING
              err_text           = DATA(lv_error)
              e_text_str         = DATA(e_text_str)
              e_text_xstr        = DATA(e_text_xstr)
          ).

          <wa>-bin_file = e_text_xstr.
          <wa>-return = CONV text100( lv_error ) .
          CLEAR lv_error.

        ELSE.
          <wa>-return = 'Dosya alınamadı'.
        ENDIF.

        CALL METHOD lo_http_client->close
          EXCEPTIONS
            http_invalid_state = 1
            OTHERS             = 2.

      CATCH cx_ai_system_fault INTO DATA(lo_cx) .
        <wa>-return = CONV text100( lo_cx->get_text( ) ) .
    ENDTRY.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_mail_pdf
*&---------------------------------------------------------------------*
FORM send_mail_pdf  TABLES    it_person TYPE  tt_person
                     USING    iv_low
                              iv_high
                              iv_kisi.

  DATA : i_reclist   LIKE somlreci1  OCCURS 0 WITH HEADER LINE,
         wa_objhead  TYPE soli_tab, w_ctrlop TYPE ssfctrlop,
         lv_sender   TYPE soextreci1-receiver VALUE 'boynerpeople@hr.boyner.com.tr',
         wa_doc_chng TYPE sodocchgi1, w_data TYPE sodocchgi1,
         i_objtxt    LIKE solisti1   OCCURS 0 WITH HEADER LINE,
         i_objpack   LIKE sopcklsti1 OCCURS 0 WITH HEADER LINE,
         it_attach   TYPE STANDARD TABLE OF solisti1 INITIAL SIZE 0 WITH HEADER LINE.

  DATA : lv_year      TYPE i,
         lv_month     TYPE i,
         lv_current   TYPE i,
         lv_text      TYPE string,
         lt_periods   TYPE TABLE OF string,
         lv_joined    TYPE string,
         lv_month_str TYPE string.

  DATA: lt_months TYPE TABLE OF t247,
        ls_month  TYPE t247.

  LOOP AT it_person ASSIGNING FIELD-SYMBOL(<wa>) WHERE return IS INITIAL .
    CLEAR: it_attach[],it_attach.
    TRY.

        CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
          EXPORTING
            input  = <wa>-bin_file
          IMPORTING
            output = <wa>-bin_file.

        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer          = <wa>-bin_file
            append_to_table = 'X'
          TABLES
            binary_tab      = it_attach.

        SELECT SINGLE usrid_long INTO i_reclist-receiver FROM pa0105
                 WHERE pernr EQ <wa>-pernr
                   AND usrty EQ '0010'
                   AND begda LE sy-datum
                   AND endda GE sy-datum.
        IF sy-subrc NE 0.
          SELECT SINGLE usrid_long INTO i_reclist-receiver FROM pa0105
                   WHERE pernr EQ <wa>-pernr
                     AND usrty EQ '0030'
                     AND begda LE sy-datum
                     AND endda GE sy-datum.
          IF sy-subrc NE 0.
            FORMAT COLOR COL_NEGATIVE.
            WRITE :/ 'Pernr. = ',<wa>-pernr,'Ad Soyad = ' ,<wa>-ename, 'personelin mail verilerini kontrol edin'.
            iv_kisi = 'E'.
            CONTINUE.
          ENDIF.
        ENDIF.
        i_reclist-rec_type = 'U'.
        i_reclist-express = 'X'.
        APPEND i_reclist.


        CONCATENATE 'Sevgili' <wa>-ename ',' INTO i_objtxt SEPARATED BY space.
        APPEND i_objtxt.
        i_objtxt = ''.
        APPEND i_objtxt.

        lv_current = iv_low.

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

        LOOP AT lt_periods INTO DATA(lv_period).
          IF sy-tabix = 1.
            lv_joined = lv_period.
          ELSE.
            lv_joined = lv_joined && ', ' && lv_period.
          ENDIF.
        ENDLOOP.

        CLEAR lv_text.

        IF iv_high IS NOT INITIAL.
          lv_text = |{ lv_joined } bordron ektedir.Bordronu üçüncü şahıslarla paylaşmamanı rica ederiz. Ayrıca BoynerPeople sistemine giriş yaparak bordronu görüntüleyebilirsin|.
          i_objtxt = lv_text.
          APPEND i_objtxt.
        ELSE.
          CONCATENATE iv_low+4(2) iv_low(4)
        'bordron ektedir.Bordronu üçüncü şahıslarla paylaşmamanı rica ederiz. Ayrıca BoynerPeople sistemine giriş yaparak bordronu görüntüleyebilirsin.' INTO
        i_objtxt SEPARATED BY space.
          APPEND i_objtxt.
        ENDIF.

        i_objtxt = ''.
        APPEND i_objtxt.
        i_objtxt = 'İyi günler dileriz,'.
        APPEND i_objtxt.
*        i_objtxt = 'Saygılarımızla,'.
*        APPEND i_objtxt.
*        i_objtxt = 'İnsan Kaynakları'.
*        APPEND i_objtxt.

        CALL FUNCTION 'MONTH_NAMES_GET'
          TABLES
            month_names = lt_months.

        IF iv_high IS NOT INITIAL.
          DESCRIBE TABLE lt_periods LINES DATA(ls_per2).
*          wa_doc_chng-obj_descr = ls_per2 && ' ' && 'Aylık Bordro'.
          wa_doc_chng-obj_descr = |{ ls_per2 } Aylık Bordro|.
        ELSE.
          wa_doc_chng-obj_descr = 'Aylık Bordro'.
        ENDIF.
        wa_doc_chng-obj_name = 'Maaş Zarfı'.
        wa_doc_chng-expiry_dat = sy-datum + 10.

        DESCRIBE TABLE it_attach LINES DATA(lv_pdf_size).
        READ TABLE it_attach INDEX lv_pdf_size.
        wa_doc_chng-doc_size = ( lv_pdf_size - 1 ) * 255 + strlen( it_attach ).

        DESCRIBE TABLE i_objtxt LINES DATA(lv_lines_txt).
        READ TABLE i_objtxt INDEX lv_lines_txt.

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
          && '(' && per1 && '-' && ls_per && '_' && <wa>-pernr && ')'.
        ENDIF.

        APPEND i_objpack.

        CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
          EXPORTING
            document_data              = wa_doc_chng
            put_in_outbox              = 'X'
            sender_address             = lv_sender
            sender_address_type        = 'SMTP'
            commit_work                = 'X'
          TABLES
            packing_list               = i_objpack[]
            object_header              = wa_objhead[]
            contents_bin               = it_attach[]
            contents_txt               = i_objtxt[]
            receivers                  = i_reclist[]
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
          WRITE :/ 'Pernr. = ',<wa>-pernr,'Ad Soyad = ' ,<wa>-ename, 'personelin bordrosu mail ile gönderildi'.
          iv_kisi = 'S'.
        ELSE.
          FORMAT COLOR COL_NEGATIVE.
          WRITE :/ 'Pernr. = ',<wa>-pernr,'Ad Soyad = ' ,<wa>-ename,  'personelin bordrosu mail ile gönderilemedi'.
          iv_kisi = 'E'.
        ENDIF.
        WAIT UP TO 1 SECONDS.
      CATCH cx_ai_system_fault INTO DATA(lo_cx) .
        <wa>-return = CONV text100( lo_cx->get_text( ) ) .
    ENDTRY.
  ENDLOOP.

ENDFORM.

FORM send_mail_pass_service  TABLES it_person TYPE  tt_person.
  DATA: lv_json        TYPE string,
        lv_auth        TYPE string,
        lv_rand2       TYPE string,
        lv_url         TYPE string,
        lo_http_client TYPE REF TO if_http_client,
        lv_smstxt      TYPE string,
        lv_smsx        TYPE xstring.

  DATA : lv_user TYPE string,
         lv_pass TYPE string.
  DATA : lo_encrypt TYPE REF TO zbyhr_cl_encryption.
  CREATE OBJECT lo_encrypt.



  LOOP AT it_person ASSIGNING FIELD-SYMBOL(<wa>) WHERE return IS INITIAL .
    CLEAR: lv_json,lv_rand2.
    TRY.
        SELECT SINGLE usrid INTO @DATA(lv_tel) FROM pa0105
                 WHERE pernr EQ @<wa>-pernr AND
                       begda LE @sy-datum AND
                       usrty EQ 'CELL'  AND
                       endda GE @sy-datum.
        lv_rand2 = <wa>-password.
*        lv_rand2 = <wa>-pass_xst.

        CONCATENATE TEXT-001 TEXT-002 lv_rand2 INTO lv_smstxt SEPARATED BY space.

*
*        lo_encrypt->encrypt_text(
*          EXPORTING
*            i_key         = 'BOYNER_ZARF_2026'
*            i_iv          = '2026010120260101'
*            i_text        = CONV #( lv_smstxt )
*          RECEIVING
*            e_text_enc    = lv_smstxt
*        ).

*        lv_smstxt = cl_http_utility=>encode_x_base64( unencoded = lv_smsx ).

        CONCATENATE lv_json '{ '
                 '"PhoneNumber":'           '"' lv_tel '",'
                 '"SmsContent":' '"' lv_smstxt '",'
*                 '"SmsContent":' '"' TEXT-001 '' TEXT-002 '' lv_rand2 '",'
*                 '"SmsContent":' '"Sifreniz:' lv_rand2 '",'
                 '"Originator": 1,'
                 '"SmsDeliveryType": 2,'
                 '"MessageSubject": "Eba OTP",'
                 '"PermissionFilter": false' INTO lv_json.

        CONCATENATE lv_json ' }' INTO lv_json.


        " Endpoint URL
*        lv_url = 'https://sms-manager-api.aks01.marketplace-ecom.prod.boynercloud.io/sms'.
        lv_url = 'https://integration-suite-boyner-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/bordroZarfiSMS '.

        " Basic Authorization Base64 (kendi kullanıcı:şifre değiştir)
*        lv_auth = 'Basic TWVyc3VzOmx5cFdsbU1KNnAzNA=='.

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

        lv_user = 'sb-d2368223-0848-475f-9a23-af554aba692e!b550443|it-rt-integration-suite-boyner-dev!b182722'.
        lv_pass = '02189b29-d15c-4c84-9ee0-1bae741de3e7$_N3xcbMxDxXjAh8NZMn7dFxNBcOCccvS7fgEVJxkENM='.
        " Basic Auth
        lo_http_client->authenticate(
          username = lv_user
          password = lv_pass
        ).

        " HTTP Header'ları ayarla
*        lo_http_client->request->set_header_field( name = 'Authorization' value = lv_auth ).
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

      CATCH cx_ai_system_fault INTO DATA(lo_cx) .
        <wa>-return = CONV text100( lo_cx->get_text( ) ) .
    ENDTRY.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form encrpt_values
*&---------------------------------------------------------------------*
FORM encrpt_values  USING p_pass
                 CHANGING c_pass
                          c_bin_file
                          c_base64
                          c_srt_pass  .
  DATA : lo_encrypt TYPE REF TO zbyhr_cl_encryption.
  DATA : lv_key TYPE xstring .
  DATA : lv_kiv TYPE xstring .
  CREATE OBJECT lo_encrypt.


  lo_encrypt->encrypt_text(
    EXPORTING
      i_key         = 'BOYNER_ZARF_2026'
      i_iv          = '2026010120260101'
      i_text        = c_base64
*      i_xstring     = c_bin_file
    RECEIVING
*      e_text_enc    = c_bin_file
      e_text_enc    = c_base64
  ).
*  c_base64 = cl_http_utility=>encode_x_base64( unencoded = c_bin_file ).

  lo_encrypt->encrypt_text(
    EXPORTING
      i_key         = 'BOYNER_ZARF_2026'
      i_iv          = '2026010120260101'
      i_text        = CONV #( p_pass )
    RECEIVING
*      e_text_enc    = c_pass
      e_text_enc    = c_srt_pass
  ).

*  c_srt_pass = cl_http_utility=>encode_x_base64( unencoded = c_pass ).



ENDFORM.
*&---------------------------------------------------------------------*
*& Form DECRYPT_values
*&---------------------------------------------------------------------*
FORM decrypt_values  CHANGING c_pass
                             c_bin_file   .

  DATA : lv_key TYPE xstring .
  DATA : lv_kiv TYPE xstring .

  lv_key = cl_bcs_convert=>string_to_xstring( iv_string  = 'BOYNER_ZARF' ).
  lv_kiv = cl_bcs_convert=>string_to_xstring( iv_string  = '2026010120260101' ).

  cl_sec_sxml_writer=>decrypt(
    EXPORTING
      ciphertext = c_bin_file
      key        = lv_key
      algorithm  = cl_sec_sxml_writer=>co_aes256_algorithm
    IMPORTING
      plaintext  = c_bin_file
  ).

  cl_sec_sxml_writer=>decrypt(
    EXPORTING
      ciphertext = c_pass
      key        = lv_key
      algorithm  = cl_sec_sxml_writer=>co_aes256_algorithm
    IMPORTING
      plaintext  = c_pass
  ).

ENDFORM.
