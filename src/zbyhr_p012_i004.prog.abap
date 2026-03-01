*&---------------------------------------------------------------------*
*& Include          ZBYHR_P002_I004
*&---------------------------------------------------------------------*

FORM set_initial_conditions .
  PERFORM calculate_periods_values.
  PERFORM set_wage_type_proporties.


  rp-set-data-interval 'P0000' pn-begda pn-endda.
  rp-set-data-interval 'P0001' pn-begda pn-endda.
  rp-set-data-interval 'P0008' pn-begda pn-endda.
  rp-set-data-interval 'P0002' pn-begda pn-endda.
  rp-set-data-interval 'P0027' pn-begda pn-endda.
  rp-set-data-interval 'P0769' pn-begda pn-endda.

  LOOP AT s_fnams.
    READ TABLE csort WITH KEY fnam = s_fnams-low.
    CHECK sy-subrc EQ 0.
    READ TABLE ssort WITH KEY fnam = s_fnams-low.
    CHECK sy-subrc NE 0 .
    APPEND csort TO ssort.
  ENDLOOP.
  CHECK ssort[] IS INITIAL .
  ssort-fnam = 'P-BUKRS' .
  ssort-ftxt = TEXT-041 . "'Şirket Kodu'.
  APPEND ssort .
ENDFORM.                    " set_initial_conditions
*&---------------------------------------------------------------------*
*&      Form  calculate_periods_values
*&---------------------------------------------------------------------*
FORM calculate_periods_values .

  CLEAR : period, period[].

*--- Set Period Values
  MOVE  s_fpper-low TO  period-fpper.

  CONCATENATE period-fpper '01' INTO period-begda.

  PERFORM get_last_day_of_month USING period-begda
                                      period-endda.
  APPEND period.

  pn-begps = pnpbegps = pn-begda = pnpbegda = period-begda.

*---
  WHILE s_fpper-high GT period-fpper.
    IF  period-fpper+4(2) EQ '12'.
      period-fpper+4(2) = '01' . ADD 1 TO period-fpper(4) .
    ELSE.
      ADD 1 TO period-fpper+4(2) .
    ENDIF.
    CONCATENATE period-fpper '01' INTO period-begda.

    PERFORM get_last_day_of_month USING period-begda
                                        period-endda.

    APPEND period.
  ENDWHILE.
*---

  pn-endps = pnpendps = pn-endda = pnpendda = period-endda.

* Get Data Cluster
  CLEAR t500l .
  SELECT SINGLE * FROM t500l
                      WHERE molga = gv_molga.
*
  SELECT * FROM t001 INTO TABLE gt_t001
          WHERE spras EQ sy-langu .

  SELECT * FROM t500p INTO TABLE gt_t500p
          WHERE molga EQ '47' .

  SELECT * FROM t501t INTO TABLE gt_t501t
          WHERE sprsl EQ sy-langu .

  SELECT * FROM t503t INTO TABLE gt_t503t
          WHERE sprsl EQ sy-langu .

  SELECT * FROM t001p INTO TABLE gt_t001p
          WHERE molga EQ '47' .

  SELECT * FROM t549t INTO TABLE gt_t549t
          WHERE sprsl EQ sy-langu .

  SELECT * FROM cskt INTO TABLE gt_cskt
          WHERE spras EQ sy-langu .

  SELECT * FROM t542t INTO TABLE gt_t542t
          WHERE spras EQ sy-langu
            AND molga EQ '47' .
ENDFORM.                    " calculate_periods_values
*&---------------------------------------------------------------------*
*&      Form  get_last_day_of_month
*&---------------------------------------------------------------------*
FORM get_last_day_of_month USING    p_begda p_endda.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_begda
    IMPORTING
      last_day_of_month = p_endda.

ENDFORM.                               " get_last_day_of_month
*&---------------------------------------------------------------------*
*&      Form  set_wage_type_proporties
*&---------------------------------------------------------------------*
FORM set_wage_type_proporties .

*   Gerekli olan dataların çekilmesi
  SELECT * FROM zbyhr_t012 INTO CORRESPONDING FIELDS OF TABLE gt003.
  SELECT * FROM zbyhr_t013 INTO CORRESPONDING FIELDS OF TABLE gt004.
  SELECT * FROM zbyhr_t014 INTO CORRESPONDING FIELDS OF TABLE gt005.
  SELECT * FROM zbyhr_t015 INTO CORRESPONDING FIELDS OF TABLE gt006.

  SORT gt004 ASCENDING BY anagr altgr seqno.
  SORT gt005 ASCENDING BY anagr altgr slga siran ddntk.
  SORT gt006 ASCENDING BY anagr altgr slga siran lgart  .


ENDFORM.                    " set_wage_type_proporties
*&---------------------------------------------------------------------*
*&      Form  GET_WAGE_TYPE_DEF gerekli tablolardan veri çekilmesi
*&---------------------------------------------------------------------*
FORM get_wage_type_def .

  SELECT * FROM t512t INTO CORRESPONDING FIELDS OF TABLE gt_t512t
          WHERE sprsl EQ gv_spras
            AND molga EQ gv_molga.

  SORT gt_t512t ASCENDING BY sprsl molga lgart.
  CLEAR toplam_net.
  SELECT * FROM zbyhr_t017 INTO TABLE gt_t008 .
  SELECT * FROM zbyhr_t018 INTO TABLE gt_t007 .
ENDFORM.                    " GET_WAGE_TYPE_DEF
*&---------------------------------------------------------------------*
*&    Gruplanması
*&---------------------------------------------------------------------*
FORM last_process .

  DATA : seqno LIKE w-seqno.


  SORT w     ASCENDING BY val01 val02 anagr altgr seqno.
  SORT total ASCENDING BY val01 val02 anagr altgr.


  DATA : lt_w LIKE w OCCURS 0 WITH HEADER LINE.

  LOOP AT w.

    MOVE-CORRESPONDING w TO lt_w.
    APPEND lt_w.


    ON CHANGE OF w-val01 OR w-val02 OR w-anagr OR w-altgr  .

      READ TABLE total WITH KEY val01 = w-val01
                                val02 = w-val02
                                anagr = w-anagr
                                altgr = w-altgr  .
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING total TO lt_w.

        MOVE '250' TO lt_w-seqno.
        CLEAR lt_w-slga.
*        CLEAR lt_w-mat.
        APPEND lt_w.

      ENDIF.
    ENDON.

  ENDLOOP.

  CLEAR : w,w[].
  w[] = lt_w[].
  CLEAR : lt_w,lt_w[].


  SORT w ASCENDING BY val01 val02 anagr altgr seqno   .

  CHECK s_fnams[] IS INITIAL .
  IF pnpbukrs[] IS NOT INITIAL.
    DELETE w        WHERE val01 NOT IN pnpbukrs.
    DELETE gt_kostl WHERE val01 NOT IN pnpbukrs.
  ENDIF.
ENDFORM.                    " LAST_PROCESS
*&---------------------------------------------------------------------*
*&      Form  FIND_SUB_TOTAL ücret bazında toplamlar
*&---------------------------------------------------------------------*
FORM find_sub_total .

  LOOP AT gt_kostl.

*    sub_t-kostl = gt_kostl-kostl.
    sub_t-val01 = gt_kostl-val01.
    sub_t-val02 = gt_kostl-val02.

    LOOP AT total

            WHERE val01 EQ gt_kostl-val01
              AND val02 EQ gt_kostl-val02
*             AND kostl EQ gt_kostl-kostl
               .

      CASE total-anagr.
        WHEN '01'. " Yasal Gelirler
          CASE total-altgr.
            WHEN '01'." Normal Çalışma Toplamı.
              sub_t-brut = sub_t-brut + total-amt.
            WHEN '02'." Fazla Mesailer Toplamı.
              sub_t-brut = sub_t-brut + total-amt.
            WHEN '03'." Ek Ödemeler Toplamı.
              sub_t-brut = sub_t-brut + total-amt.
          ENDCASE.

        WHEN '02'. " Yasal Kesintiler
          CASE total-altgr.
            WHEN '01' ."Kanuni Kesintiler Toplamı.
              sub_t-kesg = sub_t-kesg + total-amt.
            WHEN '02' ."Özel Kesintiler Toplamı.
              sub_t-kesg = sub_t-kesg + total-amt.
            WHEN OTHERS.
          ENDCASE.

        WHEN '03'. " İşveren Maliyeti
          CASE total-altgr.
            WHEN '01'. " İşveren Maliyet Toplamı
              sub_t-tmal = sub_t-tmal + total-amt.
            WHEN '02'. " Teşvikler Toplamı
              sub_t-tmalt = sub_t-tmalt + sub_t-tmal.
          ENDCASE.

        WHEN '04'. " Vergi Muafiyetleri
        WHEN '05'. " Asgari/Diğer Ücretliler
        WHEN '06'.
      ENDCASE.
    ENDLOOP.

    sub_t-neto  = sub_t-brut  - sub_t-kesg .
    CLEAR w.
    LOOP AT w
            WHERE val01 EQ gt_kostl-val01
              AND val02 EQ gt_kostl-val02
*              AND kostl EQ gt_kostl-kostl
              AND
                 slga = '9VFO' .
      CASE w-slga.
        WHEN '/700'. " Toplam Maliyet
*          sub_t-tmal = sub_t-tmal + w-amt.
        WHEN '9VFO'. " GV fark odemesi
          sub_t-noze = sub_t-noze + w-amt.

      ENDCASE.

    ENDLOOP.
    IF sy-subrc NE 0 .
      sub_t-noze = sub_t-neto + w-amt.
      sub_t-asgi = sub_t-asgi + w-amt.
    ENDIF.

    COLLECT sub_t.
    CLEAR sub_t.
  ENDLOOP.

ENDFORM.                    " FIND_SUB_TOTAL
*&---------------------------------------------------------------------*
*&      Form  SET_TEXT
*&---------------------------------------------------------------------*
FORM set_text USING if_field if_val if_txt .
*
  CASE if_field  .
    WHEN 'BUKRS' .
      CLEAR gt_t001 .
      READ TABLE gt_t001 WITH KEY bukrs = if_val .
      if_txt = gt_t001-butxt .
    WHEN 'WERKS' .
      CLEAR gt_t500p .
      READ TABLE gt_t500p WITH KEY persa = if_val .
      if_txt = gt_t500p-name1 .
    WHEN 'BTRTL' .
      CLEAR gt_t001p .
      READ TABLE gt_t001p WITH KEY werks = p0001-werks
                                   btrtl = if_val .
      if_txt = gt_t001p-btext .
    WHEN 'KOSTL' .
      CLEAR gt_cskt .
      READ TABLE gt_cskt WITH KEY kokrs = pernr-bukrs
                                  kostl = if_val .
      IF sy-subrc NE 0.
        READ TABLE gt_cskt WITH KEY kostl = if_val .
      ENDIF .
      if_txt = gt_cskt-ltext .
    WHEN 'ORGEH' .
      PERFORM hrp1000_text USING 'O' if_val if_txt .
    WHEN 'STELL' .
      PERFORM hrp1000_text USING 'C' if_val if_txt .
    WHEN 'ABKRS' .
      CLEAR gt_t549t .
      READ TABLE gt_t549t WITH KEY abkrs = if_val .
      if_txt = gt_t549t-atext .
    WHEN 'ANSVH' .
      CLEAR gt_t542t .
      READ TABLE gt_t542t WITH KEY ansvh = if_val .
      if_txt = gt_t542t-atx .
    WHEN 'PERSG' .
      CLEAR gt_t501t .
      READ TABLE gt_t501t WITH KEY persg = if_val .
      if_txt = gt_t501t-ptext .
    WHEN 'PERSK' .
      CLEAR gt_t503t .
      READ TABLE gt_t503t WITH KEY persk = if_val .
      if_txt = gt_t503t-ptext .
    WHEN 'PLANS' .
      PERFORM hrp1000_text USING 'S' if_val if_txt .
  ENDCASE        .

ENDFORM.                    " SET_TEXT
*&---------------------------------------------------------------------*
*&      Form  HRP1000_TEXT
*&---------------------------------------------------------------------*
FORM hrp1000_text USING if_type if_objid cf_txt .
*
  SELECT SINGLE stext FROM hrp1000 INTO cf_txt
                     WHERE plvar EQ '01'
                       AND otype EQ if_type
                       AND objid EQ if_objid
                       AND istat EQ '1'
                       AND begda LE sy-datum
                       AND endda GE sy-datum
                       AND langu EQ sy-langu .

ENDFORM.                    " HRP1000_TEXT
*&---------------------------------------------------------------------*
*& Form USER_COMM
*&---------------------------------------------------------------------*
FORM user_comm .
  CASE sy-ucomm.
    WHEN '&PDF'.
      PERFORM create_pdf .

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM screen_output .
  LOOP AT SCREEN.
    IF screen-group1 EQ 'M01'.
      screen-invisible = 1.
      screen-active    = 0.
    ENDIF.
*    IF screen-name EQ 'PNPBUKRS-LOW' .
*      screen-required = '1' .
*    ENDIF .
*
    READ TABLE s_fnams TRANSPORTING NO FIELDS WITH KEY low = 'P-KOSTL'.
    IF sy-subrc EQ 0 .
      IF screen-group1 EQ 'P27'.
        screen-active    = 1.
      ENDIF.
    ELSE.
      IF screen-group1 EQ 'P27'.
        screen-active    = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_pdf
*&---------------------------------------------------------------------*
FORM create_pdf .

  FIELD-SYMBOLS <x> TYPE any.
  DATA: lt_pdf TYPE TABLE OF tline.
  DATA: bindata TYPE solix_tab.
  DATA: ls_pdf TYPE  tline.
  DATA: lv_string TYPE  xstring.
  DATA: pdf_xstring TYPE  xstring.

  DATA: BEGIN OF i_rsparams OCCURS 0.
          INCLUDE STRUCTURE rsparams.
  DATA: END OF i_rsparams.


  DATA params LIKE pri_params.
  DATA lw_arcpar LIKE arc_params.

  DATA: days(1)    TYPE n VALUE 2,
        count(3)   TYPE n VALUE 1,
        valid      TYPE c,
        w_spool_nr LIKE tsp01-rqident,
        fstring    TYPE string.

  DATA: lv_linsz LIKE pri_params-linsz,
        lv_linct LIKE pri_params-linct.
  DATA : pdf_bytecount TYPE  i .
  DATA:filename TYPE string.
  DATA:path TYPE string.
  DATA:fullpath TYPE string.
  DATA:l_field TYPE string.

**  lv_linsz = '-177'. "'65'.
*  lv_linsz = '-187'. "'65'.
  lv_linsz = '-197'. "'65'.
  lv_linct = '65' .


  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = lw_arcpar
      in_parameters          = params
      immediately            = ''
      layout                 = 'X_65_255'
      line_count             = lv_linct
      line_size              = lv_linsz
      list_name              = 'ZICMAL'
      list_text              = 'ZHR_ICMAL_RAPORU'
      mode                   = 'CURRENT'
      abap_list              = 'X'
    IMPORTING
      out_archive_parameters = lw_arcpar
      out_parameters         = params
      valid                  = valid.

  CHECK params IS NOT INITIAL .


  IF valid EQ 'X'.
    params-prrel = space.
    params-primm = space.
*    params-pdest = 'ZPDF'.
  ENDIF.

  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-repid
    TABLES
      selection_table = i_rsparams
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  SUBMIT zbyhr_p012 WITH SELECTION-TABLE i_rsparams
                          TO SAP-SPOOL
                          SPOOL PARAMETERS params
                          WITHOUT SPOOL DYNPRO
                          AND RETURN.
  COMMIT WORK AND WAIT .

  SELECT MAX( rqident ) INTO w_spool_nr FROM tsp01
         WHERE rqclient = sy-mandt
         AND rqowner = sy-uname.
  REFRESH lt_pdf.


  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = w_spool_nr
*     pdf_destination          = 'A'
      no_dialog                = 'X'
    IMPORTING
      pdf_bytecount            = pdf_bytecount
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
  CHECK sy-subrc EQ 0 .
  CLEAR  :pdf_xstring.
  LOOP AT lt_pdf INTO ls_pdf.
    lv_string = ls_pdf.
    UNASSIGN <x>.
    ASSIGN ls_pdf TO <x> CASTING TYPE x.
    IF <x> IS ASSIGNED .
      CONCATENATE pdf_xstring <x> INTO pdf_xstring
      IN BYTE MODE.
    ENDIF.
  ENDLOOP.

  IF w_spool_nr IS NOT INITIAL .
    DATA : spoolid TYPE tsp01_sp0r-rqid_char .
    spoolid = w_spool_nr.
    CALL FUNCTION 'RSPO_R_RDELETE_SPOOLREQ'
      EXPORTING
        spoolid = spoolid.
  ENDIF.

*  lv_file = 'icmal raporu.pdf'.

*  **converting xstring to the binary format
  REFRESH bindata.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = pdf_xstring
    IMPORTING
      output_length = pdf_bytecount
    TABLES
      binary_tab    = bindata.


  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title         = 'Dosya nereye indirilsin? '
      default_extension    = 'PDF'
      default_file_name    = 'Kapak İcmal'
    CHANGING
      filename             = filename
      path                 = path
      fullpath             = fullpath
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize            = pdf_bytecount
      filename                = fullpath
      filetype                = 'BIN'
    TABLES
      data_tab                = bindata
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

ENDFORM.
