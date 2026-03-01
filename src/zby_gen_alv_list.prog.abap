*&---------------------------------------------------------------------*
*& Subroutine pool   ZBY_GEN_ALV_LIST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

PROGRAM  ZBY_GEN_ALV_LIST.
*---type-pools
TYPE-POOLS: slis, kkblo.

*---data definitions
DATA: it_initial_fieldcat   TYPE slis_t_fieldcat_alv.
DATA: repid LIKE syst-repid.

*&---------------------------------------------------------------------
*&      Form  LIST_MESSAGE
*&---------------------------------------------------------------------
*       list message
*----------------------------------------------------------------------
FORM list_message USING p_message.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
*     percentage = 0
      text   = p_message
    EXCEPTIONS
      OTHERS = 1.
ENDFORM.                               " LIST_MESSAGE
*&---------------------------------------------------------------------
*&      Form  LIST_initialization
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM list_initialization USING p_repid.
  repid = p_repid.

ENDFORM.                               " LIST_initialization
*&---------------------------------------------------------------------
*&      Form  LIST_STANDARD_SETTINGS
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM list_standard_settings USING ps_layout TYPE slis_layout_alv
                                  ps_print TYPE slis_print_alv
                                  ps_variant LIKE disvariant.

  ps_layout-colwidth_optimize = 'X'.
  ps_layout-max_linesize = 1023.
  ps_layout-get_selinfos = 'X'.
  ps_print-no_print_listinfos = 'X'.
  ps_layout-detail_popup = 'X'.

  IF ps_variant-report IS INITIAL.
    ps_variant-report = repid.
  ENDIF.
ENDFORM.                               " LIST_STANDARD_SETTINGS
*----------------------------------------------------------------------
*       FORM list_merge_fieldcat
*----------------------------------------------------------------------
*       ........
*----------------------------------------------------------------------
FORM list_merge_fieldcat
                TABLES pt_fieldcat TYPE slis_t_fieldcat_alv
                 USING p_tabname TYPE slis_tabname.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = repid
      i_internal_tabname     = p_tabname
      i_inclname             = repid  "
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = pt_fieldcat[]
    EXCEPTIONS
      OTHERS                 = 3.


ENDFORM.                    "list_merge_fieldcat
*----------------------------------------------------------------------
*       form list_set_attribute
*--------------------------------------------------------------------
*       ........
*----------------------------------------------------------------------
FORM list_set_attribute
                TABLES pt_fieldcat TYPE slis_t_fieldcat_alv
                 USING p_tabname   TYPE slis_tabname
                       p_fieldnames
                       p_attributes
                       p_value.

  DATA: li_fieldnames TYPE STANDARD TABLE OF
                              slis_fieldname WITH HEADER LINE,
        li_attributes TYPE STANDARD TABLE OF
                               slis_fieldname WITH HEADER LINE.

  FIELD-SYMBOLS: <f_attribute>.

  SPLIT p_fieldnames AT '/' INTO TABLE li_fieldnames.
  SPLIT p_attributes AT '/' INTO TABLE li_attributes.

  LOOP AT li_fieldnames.
    READ TABLE pt_fieldcat WITH KEY tabname   = p_tabname
                                    fieldname = li_fieldnames.
    IF sy-subrc = 0.
      LOOP AT li_attributes.
        ASSIGN COMPONENT li_attributes OF
                              STRUCTURE pt_fieldcat TO <f_attribute>.
        IF sy-subrc EQ 0.
          <f_attribute> = p_value.
        ENDIF.
      ENDLOOP.
      MODIFY pt_fieldcat INDEX sy-tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "list_set_attribute
*&---------------------------------------------------------------------
*&      Form  list_f4_for_variant
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM list_f4_for_variant USING p_vari  LIKE disvariant-variant.

  DATA: e_variant LIKE disvariant.
  DATA: exit.

  e_variant-report     = repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant    = e_variant
      i_save        = 'A'
    IMPORTING
      e_exit        = exit
      es_variant    = e_variant
    EXCEPTIONS
      not_found     = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc <> 2.
    IF exit = space.
      p_vari = e_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                               " list_f4_for_variant
*&---------------------------------------------------------------------
*&      Form  LIST_COLLECT_OUTTAB
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM list_collect_outtab TABLES pt_doc pt_out
                          USING p_refresh p_callback_form.

  PERFORM collect_outtab TABLES pt_doc pt_out
                        USING p_refresh p_callback_form
                              'REUSE_ALV_LIST_LAYOUT_INFO_GET'.


ENDFORM.                               " LIST_COLLECT_OUTTAB
*&---------------------------------------------------------------------
*&      Form  grid_collect_outtab
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM grid_collect_outtab  TABLES pt_doc pt_out
                          USING p_refresh p_callback_form.


  PERFORM collect_outtab TABLES pt_doc pt_out
                         USING p_refresh p_callback_form
                               'REUSE_ALV_GRID_LAYOUT_INFO_GET'.

ENDFORM.                    " grid_collect_outtab
*&---------------------------------------------------------------------
*&      Form  LIST_COLLECT_OUTTAB
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM collect_outtab TABLES pt_doc pt_out
                          USING p_refresh p_callback_form
                                p_function.
  STATICS  et_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.
  FIELD-SYMBOLS: <f_it_doc> TYPE ANY TABLE,
                 <f_w_doc>,
                 <f_it_out> TYPE ANY TABLE,
                 <f_w_out>.
  FIELD-SYMBOLS: <f_source>,
                 <f_target>.

  PERFORM check_layout  TABLES et_fieldcat
                        USING p_refresh p_function.

  CHECK p_refresh EQ 'X'.
* collect işlemi yapılıyor.
  ASSIGN: pt_doc[] TO <f_it_doc> ,
          pt_doc   TO <f_w_doc>.
  ASSIGN: pt_out[] TO <f_it_out> ,
          pt_out   TO <f_w_out>.

  CLEAR <f_it_out>.

  LOOP AT <f_it_doc> INTO <f_w_doc>.
    CLEAR <f_w_out>.

    LOOP AT et_fieldcat WHERE ( no_out EQ space AND
                                tech   EQ space )
                           OR sp_group EQ '@'.
      ASSIGN COMPONENT et_fieldcat-fieldname
                      OF STRUCTURE <f_w_out> TO <f_target>.
      IF sy-subrc EQ 0.
        ASSIGN COMPONENT et_fieldcat-fieldname
                        OF STRUCTURE <f_w_doc> TO <f_source>.
        IF sy-subrc EQ 0.
          <f_target> = <f_source>.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF NOT p_callback_form IS INITIAL.
      PERFORM (p_callback_form) IN PROGRAM (repid) IF FOUND.

      LOOP AT et_fieldcat WHERE ( no_out NE space OR
                                  tech   NE space )
                            AND sp_group EQ space.
        ASSIGN COMPONENT et_fieldcat-fieldname
                        OF STRUCTURE <f_w_out> TO <f_target>.
        IF sy-subrc EQ 0.
          CLEAR <f_target>.
        ENDIF.
      ENDLOOP.
    ENDIF.

    COLLECT <f_w_out> INTO <f_it_out>.
  ENDLOOP.

ENDFORM.                               " COLLECT_OUTTAB
*&---------------------------------------------------------------------
*&      Form  CHECK_LAYOUT
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM check_layout TABLES pt_fieldcat TYPE slis_t_fieldcat_alv
                  USING p_new_layout p_function.
  DATA lt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.

  lt_fieldcat[] = pt_fieldcat[].

  CALL FUNCTION p_function
    IMPORTING
      et_fieldcat   = pt_fieldcat[]
    EXCEPTIONS
      no_infos      = 1
      program_error = 2
      OTHERS        = 3.

  IF sy-subrc <> 0 OR
     pt_fieldcat[] IS INITIAL.
    pt_fieldcat[] = it_initial_fieldcat.
  ENDIF.

  IF lt_fieldcat[] IS INITIAL.
    p_new_layout = 'X'.
  ELSE.
    LOOP AT pt_fieldcat.
      LOOP AT lt_fieldcat WHERE fieldname EQ pt_fieldcat-fieldname
                            AND tabname EQ pt_fieldcat-tabname.
        EXIT.
      ENDLOOP.
      IF  pt_fieldcat-no_out NE lt_fieldcat-no_out OR
          pt_fieldcat-tech   NE lt_fieldcat-tech.
        p_new_layout = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF p_new_layout = 'X'.
* unit ve currency alanları korunuyor
    LOOP AT pt_fieldcat WHERE no_out EQ space
                          AND tech EQ space
                          AND ( qfieldname NE space OR
                                cfieldname NE space ).
      pt_fieldcat-sp_group = '@'.
      MODIFY pt_fieldcat TRANSPORTING sp_group
                      WHERE fieldname EQ pt_fieldcat-qfieldname
                         OR fieldname EQ pt_fieldcat-cfieldname.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " CHECK_LAYOUT
*&---------------------------------------------------------------------
*&      Form  LT_VARIANT_LOAD
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM lt_variant_load
            USING VALUE(pt_fieldcat) TYPE slis_t_fieldcat_alv
                  p_tabname TYPE kkblo_tabname
                  p_default
                  p_save
                  VALUE(ps_variant) STRUCTURE disvariant.

  DATA: l_user_specific,
        lt_fieldcat     TYPE kkblo_t_fieldcat,
        s_layout        TYPE kkblo_layout.

  CASE p_save.
    WHEN 'A' OR 'U'.
      l_user_specific = 'X'.
    WHEN 'X' OR space.
      l_user_specific = space.
  ENDCASE.

  CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA'
    EXPORTING
      it_fieldcat = pt_fieldcat
    IMPORTING
      et_fieldcat = lt_fieldcat
    EXCEPTIONS
      OTHERS      = 1.

  CALL FUNCTION 'LT_VARIANT_LOAD'
    EXPORTING
      i_tabname           = p_tabname
      i_dialog            = 'N'
      i_user_specific     = l_user_specific
      i_default           = p_default
    IMPORTING
      et_fieldcat         = lt_fieldcat
    CHANGING
      cs_layout           = s_layout
      ct_default_fieldcat = lt_fieldcat
      cs_variant          = ps_variant
    EXCEPTIONS
      wrong_input         = 1
      fc_not_complete     = 2
      not_found           = 3
      OTHERS              = 4.

  IF sy-subrc = 0.
    REFRESH pt_fieldcat.
    CALL FUNCTION 'REUSE_ALV_TRANSFER_DATA_BACK'
      EXPORTING
        it_fieldcat = lt_fieldcat
      IMPORTING
        et_fieldcat = pt_fieldcat
      EXCEPTIONS
        OTHERS      = 1.
  ENDIF.

  it_initial_fieldcat = pt_fieldcat[].

ENDFORM.                               " LT_VARIANT_LOAD
*&---------------------------------------------------------------------
*&      Form  BUILD_RANGE
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM build_range TABLES p_range
                        p_data
                 USING  p_field_name TYPE c.
  DATA:
    z_check(128),
    z_csame(128),
    z_prev(128),
    z_test(128).

  DATA:
      z_length  TYPE i.

  FIELD-SYMBOLS:
    <fs_check>,
    <fs_csame>,
    <fs_prev>,
    <fs_test>,
    <fs_key>,
    <fs_r_low>,
    <fs_r_high>,
    <fs_r_sign>,
    <fs_r_opt>.

* sadece karakter ve numerIk alanlardan range olusturur
  ASSIGN COMPONENT p_field_name OF STRUCTURE p_data TO <fs_key>.
  IF sy-subrc <> 0.
    EXIT.
  ELSE.
    SORT p_data BY (p_field_name).
    DESCRIBE FIELD <fs_key> LENGTH z_length IN CHARACTER MODE.
    ASSIGN z_check(z_length) TO <fs_check>.
    ASSIGN z_csame(z_length) TO <fs_csame>.
    ASSIGN z_test(z_length)  TO <fs_test> .
    ASSIGN z_prev(z_length)  TO <fs_prev> .

    ASSIGN COMPONENT 'LOW' OF STRUCTURE p_range TO <fs_r_low>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    ASSIGN COMPONENT 'HIGH' OF STRUCTURE p_range TO <fs_r_high>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    ASSIGN COMPONENT 'SIGN' OF STRUCTURE p_range TO <fs_r_sign>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    ASSIGN COMPONENT 'OPTION' OF STRUCTURE p_range TO <fs_r_opt>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    CLEAR p_range.
    FREE  p_range.
    <fs_r_sign> = 'I'.
    <fs_r_opt> = 'BT'.
    LOOP AT p_data.
      IF sy-tabix = 1.
        <fs_r_low> = <fs_r_high> = <fs_key>.
      ELSE.
        IF NOT <fs_prev> CO '0123456789 '.
          IF <fs_prev> NE <fs_key>.
            APPEND p_range.
            IF <fs_r_low> = <fs_r_high>.
              <fs_r_opt> = 'EQ'.
            ELSE.
              <fs_r_opt> = 'BT'.
            ENDIF.
            <fs_r_low> = <fs_r_high> = <fs_key>.
          ENDIF.
        ELSE.
          <fs_csame> = <fs_prev>.
          SHIFT <fs_csame> LEFT DELETING LEADING '0'.
          SHIFT <fs_csame> LEFT DELETING LEADING ' '.
          <fs_check> = <fs_prev> + 1.
          SHIFT <fs_check> LEFT DELETING LEADING '0'.
          SHIFT <fs_check> LEFT DELETING LEADING ' '.
          <fs_test> = <fs_key>.
          SHIFT <fs_test> LEFT DELETING LEADING '0'.
          SHIFT <fs_test> LEFT DELETING LEADING ' '.
          IF <fs_test> = <fs_check> OR <fs_test> = <fs_csame>.
            <fs_r_high> = <fs_key>.
          ELSE.
            IF <fs_r_low> = <fs_r_high>.
              <fs_r_opt> = 'EQ'.
            ELSE.
              <fs_r_opt> = 'BT'.
            ENDIF.
            APPEND p_range.
            <fs_r_low> = <fs_r_high> = <fs_key>.
          ENDIF.
        ENDIF.
      ENDIF.
      <fs_prev> = <fs_key>.
    ENDLOOP.

    IF <fs_r_low> = <fs_r_high>.
      <fs_r_opt> = 'EQ'.
    ELSE.
      <fs_r_opt> = 'BT'.
    ENDIF.
    APPEND p_range.

  ENDIF.                           " range alanı ham tabloda mevcut?
ENDFORM.                               " BUILD_RANGE
*&---------------------------------------------------------------------
*&      Form  VALUE_FOR_PATH
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
FORM value_for_path USING p_path.
  DATA l_mask(255).

  CONCATENATE ',Texts (*.txt),*.txt'
              ',All Documents (*.*),*.*'
              '.'
              INTO l_mask.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_path         = p_path
      mask             = l_mask
      mode             = 'S'
      title            = 'Dosyalar'
    IMPORTING
      filename         = p_path
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

ENDFORM.                               " VALUE_FOR_PATH
*&---------------------------------------------------------------------
*&      Form  UPLOAD_DATA
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM upload_data TABLES p_tab
                  USING p_path p_filetype.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename                = p_path
      filetype                = p_filetype
    TABLES
      data_tab                = p_tab
    EXCEPTIONS
      conversion_error        = 1
      file_open_error         = 2
      file_read_error         = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      OTHERS                  = 10.

  IF sy-subrc <> 0.
    EXIT.
  ENDIF.

  LOOP AT p_tab.
    CHECK p_tab IS INITIAL.
    DELETE p_tab.
  ENDLOOP.

  IF p_tab[] IS INITIAL.
    sy-subrc = 4.
  ENDIF.

ENDFORM.                               " UPLOAD_DATA
*&---------------------------------------------------------------------*
*&      Form  GET_GESCH_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_gesch_text  USING    iv_gesch
                     CHANGING ev_cinsiyet.
  CLEAR ev_cinsiyet.
  SELECT SINGLE atext
        INTO ev_cinsiyet
              FROM t522t
              WHERE anred EQ iv_gesch
              AND   sprsl EQ 'T' .

ENDFORM.                    " GET_GESCH_TEXT
*&---------------------------------------------------------------------
*&      Form  VALUE_FOR_PATH
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------
FORM dynp_values_update USING dyname
                              dynumb
                              p_name
                              filename.

  DATA: BEGIN OF dynp_value_tab OCCURS 0.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF dynp_value_tab.

  REFRESH dynp_value_tab.
  dynp_value_tab-fieldname = p_name.
  dynp_value_tab-fieldvalue = filename.
  APPEND dynp_value_tab.

  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      dyname               = dyname
      dynumb               = dynumb
    TABLES
      dynpfields           = dynp_value_tab
    EXCEPTIONS
      invalid_abapworkarea = 04
      invalid_dynprofield  = 08
      invalid_dynproname   = 12
      invalid_dynpronummer = 16
      invalid_request      = 20
      no_fielddescription  = 24
      undefind_error       = 28.


ENDFORM.                               " VALUE_FOR_PATH
*&---------------------------------------------------------------------
*&      Form  TEL_KONTROL
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM tel_kontrol USING iv_tel
              CHANGING ev_mes.
  DATA: lv_length TYPE i,
        lv_i      TYPE i.

  CONDENSE iv_tel.

  lv_length = strlen( iv_tel ).
  IF lv_length EQ 0.
    CONCATENATE ev_mes
                'BOŞ bırakılamaz!' INTO ev_mes SEPARATED BY space.
    EXIT.
  ENDIF.

  lv_i = 0.
  DO lv_length TIMES.
    IF iv_tel+lv_i(1) CA '0123456789'.
    ELSE.
      IF iv_tel+lv_i(1) EQ space.
        CONCATENATE ev_mes 'Boşluk'
                    'içeremez.Sadece Rakam Kullanılmalı!'
                    INTO ev_mes SEPARATED BY space.
      ELSE.
        CONCATENATE ev_mes '"' iv_tel+lv_i(1)
                    '" karakteri içeremez.Sadece Rakam Kullanılmalı!'
                    INTO ev_mes SEPARATED BY space.
      ENDIF.
      EXIT.
    ENDIF.
    ADD 1 TO lv_i.
  ENDDO.

  IF lv_length NE 10.
    CONCATENATE ev_mes
                '10 hane girilmeli!' INTO ev_mes SEPARATED BY space.
    EXIT.
  ENDIF.

  IF NOT iv_tel+0(1) CA '57'.
    CONCATENATE ev_mes
                'CEP Tel girilmeli!' INTO ev_mes SEPARATED BY space.
    EXIT.
  ENDIF.

ENDFORM.                               " TEL_KONTROL
*&---------------------------------------------------------------------
*&      Form  MAIL_KONTROL
*&---------------------------------------------------------------------
*       text
*----------------------------------------------------------------------
FORM mail_kontrol USING iv_mail
               CHANGING ev_mes.
  DATA: lv_length         TYPE i,
        lv_i              TYPE i,
        lv_ok,
        lv_ad,
        lv_ad_sonra_nokta.

  lv_length = strlen( iv_mail ).
  lv_i = 0.
  CLEAR: lv_ok,
         lv_ad,
         lv_ad_sonra_nokta.

  DO lv_length TIMES.
    IF iv_mail+lv_i(1) CA 'ıöğüşöçĞÜŞİÖÇ/<>":&'.
*    ELSE.
      CONCATENATE 'E-mail "' iv_mail+lv_i(1)
                  '" karakteri içeremez!'
                  INTO ev_mes SEPARATED BY space.
      lv_ok = 'X'.
      EXIT.
    ENDIF.

    IF iv_mail+lv_i(1) EQ '@'.
      lv_ok = 'X'.
      lv_ad = '@'.
    ENDIF.

    IF lv_ad = '@'.
      IF iv_mail+lv_i(1) EQ '.'.
        lv_ad_sonra_nokta = 'X'.
      ENDIF.
    ENDIF.

    ADD 1 TO lv_i.
  ENDDO.

  IF lv_ok NE 'X' AND lv_length NE 0.
    CONCATENATE ev_mes 'E-mail'
                  '@ karakteri içermeli!' INTO ev_mes
                  SEPARATED BY space.
  ENDIF.

  IF lv_ad_sonra_nokta NE 'X' AND lv_length NE 0.
    CONCATENATE ev_mes 'E-mail'
                  '@ karakterinden sonra "." içermeli!' INTO ev_mes
                  SEPARATED BY space.
  ENDIF.


ENDFORM.                               " MAIL_KONTROL
