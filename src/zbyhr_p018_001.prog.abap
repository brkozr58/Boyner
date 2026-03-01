*&---------------------------------------------------------------------*
*& Include          ZBYHR_P018_001
*&---------------------------------------------------------------------*

DATA  : go_report TYPE REF TO gr_report.

DATA : BEGIN OF gt_grnt OCCURS 0,
         ename  LIKE p0001-ename,
         merni  TYPE ptr_merni,
         bankl  TYPE bankl,
         subkod TYPE zbyhr_de002,
         bankn  TYPE bankn,
         iban   TYPE iban,
         betrg  TYPE maxbt,
         bizah  TYPE zbyhr_bizah,
         aizah  TYPE zbyhr_aizah,
       END OF gt_grnt.

CLASS gr_report DEFINITION.

  PUBLIC SECTION .
    DATA : gt_out TYPE TABLE OF zbyhr_s011,
           gr_alv TYPE REF TO cl_salv_table.

    METHODS : set_date,
      set_init,
      get_data,
      display_alv,
      prepare_alv,

      on_user_command
        FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
**
  PROTECTED SECTION.
    DATA : "gr_alv       TYPE REF TO cl_salv_table,
      gr_past      TYPE REF TO cl_salv_table,
      gr_display   TYPE REF TO cl_salv_display_settings,
      gr_columns   TYPE REF TO cl_salv_columns_table,
      gr_column    TYPE REF TO cl_salv_column_table,
      gr_functions TYPE REF TO cl_salv_functions_list,
      gr_selection TYPE REF TO cl_salv_selections,
      gr_layout    TYPE REF TO cl_salv_layout,
      gr_events    TYPE REF TO cl_salv_events_table,
      go_selection TYPE REF TO cl_salv_selections,
      gr_exp_msg   TYPE REF TO cx_salv_msg.

    DATA : gs_key     TYPE salv_s_layout_key,
           gs_variant TYPE slis_vari.
**
  PRIVATE SECTION.
    METHODS :
      create_alv,
      set_pf_status,
      set_top_of_page,
      set_alv_properties,
      set_column_text
        IMPORTING i_fname TYPE lvc_fname
                  i_text  TYPE any.


ENDCLASS.
*&---------------------------------------------------------------------*
*&       Class (Implementation)  gr_report
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS gr_report IMPLEMENTATION.
  METHOD set_date.

    SELECT SINGLE * FROM t001 INTO t001 WHERE bukrs IN pnpbukrs[].
    SELECT * FROM zbyhr_t001 INTO TABLE gt_t001 WHERE bukrs IN pnpbukrs[].
    SELECT * FROM zbyhr_t002 INTO TABLE gt_t002 WHERE bukrs IN pnpbukrs[].
    SELECT * FROM dd07t INTO TABLE gt_izah
      WHERE domname    EQ 'ZHRBY_ODTIP'
        AND ddlanguage EQ sy-langu.


    PERFORM set_date  .
  ENDMETHOD.

  METHOD set_init.
    REFRESH pnpstat2.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '3' ) TO pnpstat2.
    REFRESH pnpbukrs.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '5000' ) TO pnpbukrs.

    pnpxabkr = '53'          .

  ENDMETHOD.

  METHOD get_data.
    PERFORM get_data  .
  ENDMETHOD.

  METHOD set_pf_status.
    gr_alv->set_screen_status(
      pfstatus      = 'GUI'
      report        = sy-repid
      set_functions = gr_alv->c_functions_all ).
  ENDMETHOD.                    "set_pf_status

  METHOD set_top_of_page.

    DATA : lo_header      TYPE REF TO cl_salv_form_layout_grid,
           lo_grid_bottom TYPE REF TO cl_salv_form_layout_grid,
           lo_logo        TYPE REF TO cl_salv_form_layout_logo,
           lo_text        TYPE REF TO cl_salv_form_text,
           lo_label       TYPE REF TO cl_salv_form_label.

    DATA : lv_date  TYPE text10.

    CREATE OBJECT lo_header.

    lo_header->create_header_information(
      row    = 1
      column = 1
      text   = TEXT-h01 ). " Rapor ismi
    lo_header->add_row( ).

    lo_grid_bottom = lo_header->create_grid(
      row    = 3
      column = 1 ).

    lo_label = lo_grid_bottom->create_label(
      row     = 1
      column  = 1
      text    = TEXT-h02
      tooltip = TEXT-h02 ). " Tarih

    WRITE sy-datum TO lv_date DD/MM/YYYY.
    lo_text = lo_grid_bottom->create_text(
      row     = 1
      column  = 2
      text    = lv_date
      tooltip = lv_date ). " Tarih

    lo_label = lo_grid_bottom->create_label(
      row     = 2
      column  = 1
      text    = TEXT-h03
      tooltip = TEXT-h03 ). " Kullanıcı

    lo_text = lo_grid_bottom->create_text(
      row     = 2
      column  = 2
      text    = sy-uname
      tooltip = sy-uname ). " Kullanıcı

    lo_label->set_label_for( lo_text ).

  ENDMETHOD.                    "set_top_of_page

  METHOD create_alv.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = gr_alv
          CHANGING
            t_table      = gt_out ).
      CATCH
        cx_salv_msg INTO gr_exp_msg.
    ENDTRY.

  ENDMETHOD.                    "create_alv


  METHOD set_alv_properties.

    DEFINE visible_column.
      gr_column ?= gr_columns->get_column( &1 ).
      gr_column->set_visible( &2 ).
    END-OF-DEFINITION.


    gr_display = gr_alv->get_display_settings( ).

* Zebra sytle..
    gr_display->set_striped_pattern( cl_salv_display_settings=>true ).

    gr_columns = gr_alv->get_columns( ).
* Set optimize..
    gr_columns->set_optimize( abap_true ).

    gr_layout = gr_alv->get_layout( ).
* Set variant..
    gs_key-report = sy-repid.
    gr_layout->set_key( gs_key ).
    gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).


* Sort
*    go_report->set_sort( i_fname = 'PERNR'    ).

*    gs_variant = p_layout.
*    gr_layout->set_initial_layout( gs_variant ).

* Alv default settings..
    gr_layout->set_default( if_salv_c_bool_sap=>true ).

* Set selection..
    gr_selection = gr_alv->get_selections( ).
    gr_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    gr_events = gr_alv->get_event( ).
* Set ALV Events.
    SET HANDLER on_user_command FOR gr_events.

* Set Column Texts.
    me->set_column_text( i_fname = 'ZCOUN'      i_text = 'Kişi sayısı' ).
    me->set_column_text( i_fname = 'ENAME'      i_text = 'Adı Soyadı' ).


*Hide columns.
    visible_column : 'VORNA' if_salv_c_bool_sap=>false,
                     'NACHN' if_salv_c_bool_sap=>false,
                     'FIBAN' if_salv_c_bool_sap=>false,
                     'KURKOD' if_salv_c_bool_sap=>false,
                     'VBETRG' if_salv_c_bool_sap=>false,
                     'HSPNO' if_salv_c_bool_sap=>false ,
                     'WERKS' if_salv_c_bool_sap=>false ,
                     'BTRTL' if_salv_c_bool_sap=>false .

  ENDMETHOD.                    "set_alv_properties

  METHOD set_column_text.

    DATA : lv_ltext TYPE scrtext_l,
           lv_mtext TYPE scrtext_m,
           lv_stext TYPE scrtext_s.

    gr_column ?= gr_columns->get_column( i_fname ).
    MOVE : i_text TO lv_ltext.
    gr_column->set_long_text( lv_ltext ).
    MOVE : i_text TO lv_mtext.
    gr_column->set_medium_text( lv_mtext ).
    MOVE : i_text TO lv_stext.
    gr_column->set_short_text( lv_stext  ).

  ENDMETHOD.                    "set_column_text

  METHOD display_alv.
    gr_alv->display( ).
  ENDMETHOD.

  METHOD prepare_alv.
    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
    me->set_top_of_page( ).
    me->display_alv( ).
  ENDMETHOD.                 "display_alv

  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'TEXT'.
        PERFORM download_text .

      WHEN 'EXCEL'.
        PERFORM download_excel .
*
*        PERFORM download_excel_oaor TABLES gt_grnt
*                                    USING 'ZBYHR_P018'
*                                          'Garanti Bankası'.
      WHEN 'SFTP'.
        PERFORM send_document .
    ENDCASE.
    gr_alv->refresh(  ).
  ENDMETHOD.                    "on_user_command

ENDCLASS.               "gr_report




*&---------------------------------------------------------------------*
*& Form set_date
*&---------------------------------------------------------------------*
FORM set_date .
  DATA : lv_begda TYPE begda,
         lv_endda TYPE endda.

  lv_begda = pn-begda.                     .
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_begda
    IMPORTING
      last_day_of_month = lv_endda
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  pn-begps = pnpbegps = pn-begda = pnpbegda = lv_begda .
  pn-endps = pnpendps = pn-endda = pnpendda = lv_endda .


  rp-set-data-interval 'P0000' pn-begda pn-endda.
  rp-set-data-interval 'P0001' pn-begda pn-endda.
  rp-set-data-interval 'P0015' pn-begda pn-endda.
  rp-set-data-interval 'P0009' pn-begda pn-endda.
  rp-set-data-interval 'P0772' pn-begda pn-endda.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data .
  DATA : ls_out TYPE zbyhr_s011.

  AUTHORITY-CHECK OBJECT 'P_ORGIN'
  ID 'INFTY' FIELD '0008'
  ID 'AUTHC' FIELD '*'
  ID 'PERSA' FIELD pernr-werks
  ID 'PERSG' FIELD pernr-persg
  ID 'PERSK' FIELD pernr-persk .
  CHECK sy-subrc EQ 0.

  rp-provide-from-last p0000 space pnpbegda pnpendda.
  rp-provide-from-last p0001 space pnpbegda pnpendda.
  rp-provide-from-last p0009 space pnpbegda pnpendda.
  rp-provide-from-last p0014 space pnpbegda pnpendda.
  rp-provide-from-last p0015 space pnpbegda pnpendda.
  rp-provide-from-last p0770 space pnpbegda pnpendda.

  CASE 'X'.
    WHEN r_brd.
      PERFORM read_payroll CHANGING ls_out .

    WHEN r_eko.
      PERFORM read_ekodeme CHANGING ls_out.
  ENDCASE.

  PERFORM append_person USING ls_out .


ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_payroll
*&---------------------------------------------------------------------*
FORM read_payroll  CHANGING cs_out TYPE zbyhr_s011 .

  DATA: result   TYPE pay99_result,
        wa_rt    TYPE pc207,
        in_rgdir TYPE TABLE OF  pc261,
        gs_rgdir TYPE pc261.


  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      persnr          = pernr-pernr
    TABLES
      in_rgdir        = in_rgdir
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  READ TABLE in_rgdir INTO gs_rgdir WITH KEY fpper = pn-paper.
*  IF sy-subrc NE 0 .
*    SORT in_rgdir DESCENDING BY fpper.
*    READ TABLE in_rgdir INTO gs_rgdir INDEX 1.
*  ENDIF.
  CHECK sy-subrc = 0.
  CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
    EXPORTING
      clusterid                    = 'TR'
      employeenumber               = pernr-pernr
      sequencenumber               = gs_rgdir-seqnr
      read_only_international      = 'X'
    CHANGING
      payroll_result               = result
    EXCEPTIONS
      illegal_isocode_or_clusterid = 1
      error_generating_import      = 2
      import_mismatch_error        = 3
      subpool_dir_full             = 4
      no_read_authority            = 5
      no_record_found              = 6
      versions_do_not_match        = 7
      OTHERS                       = 8.


  LOOP AT result-inter-rt INTO wa_rt WHERE lgart EQ p_lgart .
    IF wa_rt-betrg LT 0 .
      wa_rt-betrg = wa_rt-betrg * -1.
    ENDIF.
    ADD wa_rt-betrg TO cs_out-betrg.
    cs_out-waers = result-inter-versc-waers.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_ekodeme
*&---------------------------------------------------------------------*
FORM read_ekodeme  CHANGING cs_out TYPE zbyhr_s011.

  LOOP AT p0015 WHERE subty EQ p_lgart
                  AND begda LE pnpendda
                  AND begda GE pnpbegda.
    IF p0015-betrg LT 0 .
      p0015-betrg = p0015-betrg * -1.
    ENDIF.
    ADD p0015-betrg TO cs_out-betrg.
    cs_out-waers = p0015-waers.
  ENDLOOP.
  LOOP AT p0014 WHERE subty EQ p_lgart
                  AND begda LE pnpendda
                  AND begda GE pnpbegda .
    IF p0014-betrg LT 0 .
      p0014-betrg = p0014-betrg * -1.
    ENDIF.
    ADD p0014-betrg TO cs_out-betrg.
    cs_out-waers = p0014-waers.
  ENDLOOP.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_person
*&---------------------------------------------------------------------*
FORM append_person USING ps_out TYPE zbyhr_s011 .
  IF ps_out-betrg IS NOT INITIAL.
*    READ TABLE gt_t001 INTO DATA(ls_t001) WITH KEY bukrs = pernr-bukrs.
    READ TABLE gt_t001 INTO DATA(ls_t001) WITH KEY bukrs = pernr-bukrs werks = pernr-werks btrtl = pernr-btrtl.
    IF sy-subrc NE 0 .
      READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pernr-bukrs werks = pernr-werks.
      IF sy-subrc NE 0 .
        READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pernr-bukrs.
      ENDIF.
    ENDIF.
    IF sy-subrc EQ 0 .
      MOVE-CORRESPONDING ls_t001 TO gt_filter.
      COLLECT gt_filter.CLEAR gt_filter.
    ENDIF.

    READ TABLE gt_t002 INTO DATA(ls_t002) WITH KEY bukrs = pernr-bukrs werks = ls_t001-werks btrtl = ls_t001-btrtl.
    READ TABLE gt_izah INTO DATA(ls_izah) WITH KEY domvalue_l = p_odtip.
    ps_out-zcoun    = 1.
    ps_out-pernr    = pernr-pernr.
    ps_out-ename    = p0001-ename.
    ps_out-vorna    = p0002-vorna.
    ps_out-nachn    = p0002-nachn.
    ps_out-merni    = p0770-merni.
    ps_out-bankl    = p0009-bankl.
    ps_out-iban     = p0009-iban.
    ps_out-bankn    = p0009-bankn.
    ps_out-bizah    = ls_izah-ddtext.
    ps_out-aizah    = ls_izah-ddtext.
    ps_out-lgart    = p_lgart.
    ps_out-fiban    = ls_t001-iban.
    ps_out-kurkod   = ls_t001-kurkod.
    ps_out-subkod   = ls_t001-subkod.
    ps_out-hspno    = ls_t001-hspno .
    ps_out-bukrs    = p0001-bukrs .
    ps_out-werks    = p0001-werks .
    ps_out-btrtl    = p0001-btrtl .

    MOVE-CORRESPONDING ps_out TO gt_grnt.

    APPEND gt_grnt .CLEAR gt_grnt .

    WRITE ps_out-betrg TO ps_out-vbetrg CURRENCY ps_out-waers.
    SHIFT ps_out-vbetrg LEFT DELETING LEADING space.

    APPEND ps_out TO go_report->gt_out .
  ENDIF.
  CLEAR ps_out .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_excel
*&---------------------------------------------------------------------*
FORM download_excel .
  DATA: ld_filename TYPE string,
        ld_path     TYPE string,
        ld_fullpath TYPE string,
        ld_result   TYPE i,
        l_filename  TYPE string.

  DATA: xml_table TYPE STANDARD TABLE OF string .

  l_filename = 'Garanti Bankası.xls'.
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_extension = 'XLS'
      default_file_name = l_filename
      initial_directory = 'C:\'
    CHANGING
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  CHECK ld_result EQ '0'.


  LOOP AT gt_filter.
    REFRESH xml_table.
    PERFORM set_excel TABLES xml_table
                         USING gt_filter-bukrs
                               gt_filter-werks
                               gt_filter-btrtl .
    SPLIT ld_filename AT '.' INTO ld_filename DATA(lv2).

    CONCATENATE ld_path
                ld_filename   '_'
                gt_filter-bukrs '_'
                gt_filter-werks '_'
                gt_filter-btrtl '.' lv2 INTO ld_fullpath.
    .
    CHECK xml_table[] IS NOT INITIAL  .
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = ld_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
        confirm_overwrite     = 'X'
        codepage              = '4100'
      TABLES
        data_tab              = xml_table[]
      EXCEPTIONS
        file_open_error       = 1
        file_write_error      = 2
        OTHERS                = 3.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_excel_oaor
*&---------------------------------------------------------------------*
FORM download_excel_oaor TABLES pt_banka
                          USING pv_objekey
                                pv_filename.

  DATA : lo_xl         TYPE REF TO zbyhr_disket,
         lt_sign       TYPE sbdst_signature,
         lt_cont       TYPE sbdst_content,
         lt_urls       TYPE sbdst_uri,
         lt_lines      TYPE ty_t_clipdata,
         lv_temp_dir   TYPE string,
         lv_filename   TYPE text255,
         lv_row        TYPE i,
         lv_count      TYPE i,
         lv_count_char TYPE char4,
         lv_prtxt      TYPE text100,
         lv_length     TYPE i,
         lv_rc         TYPE i,
         lv_allcnt     TYPE char4,
         lv_betrg      TYPE maxbt.


  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Dosyanın indirileceği klasörü seçiniz'
    CHANGING
      selected_folder      = lv_temp_dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.


  CHECK lv_temp_dir IS NOT INITIAL.
*  dosyayı lokale indir
  lv_filename = lv_temp_dir && '\' && pv_filename &&
                '_' && pnpxabkr && '_' &&
                p_pdate(6)  &&  '.xls'.


  CREATE OBJECT lo_xl
    EXPORTING
      iv_visible  = '0'
      iv_filename = lv_filename.


  APPEND VALUE #( prop_name = 'DESCRIPTION' prop_value = pv_objekey  ) TO lt_sign.

  CALL METHOD cl_bds_document_set=>get_with_url
    EXPORTING
      classname = lo_xl->mv_classname
      classtype = lo_xl->mv_classtype
    CHANGING
      uris      = lt_urls
      signature = lt_sign.

  CALL METHOD cl_bds_document_set=>get_with_table
    EXPORTING
      classname       = lo_xl->mv_classname
      classtype       = lo_xl->mv_classtype
      client          = sy-mandt
      object_key      = CONV #( pv_objekey )
    CHANGING
      content         = lt_cont
      signature       = lt_sign
    EXCEPTIONS
      error_kpro      = 1
      internal_error  = 2
      nothing_found   = 3
      no_content      = 4
      parameter_error = 5
      not_authorized  = 6
      not_allowed     = 7
      OTHERS          = 8.

  CALL FUNCTION 'SCMS_DOWNLOAD'
    EXPORTING
      filename = lv_filename
      filesize = lv_length
    TABLES
      data     = lt_cont
    EXCEPTIONS
      error    = 1
      OTHERS   = 2.
*
  "Progress indicator
  CALL METHOD cl_progress_indicator=>progress_indicate
    EXPORTING
      i_text = 'Banka dosyası hazırlanıyor. Lütfen bekleyiniz...'.


  PERFORM generate_clipboard_table USING pt_banka[] lt_lines[].

  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = lt_lines[]
    CHANGING
      rc                   = lv_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  CHECK sy-subrc = 0.

  CALL METHOD lo_xl->paste_clipboard
    EXPORTING
      iv_worksheets = 1
      iv_cell1      = 'A13'
      iv_cell2      = 'I13'.


*  lo_xl->select_area( iv_row1 = 1
*                      iv_row2 = lv_row
*                      iv_col1 = 'A'
*                      iv_col2 = 'I'
*                      ).

  lo_xl->set_autofit( ).

  lo_xl->set_visibility( '1' ).

  lo_xl->save( ).




ENDFORM.
*&---------------------------------------------------------------------
*& Form generate_clipboard_table
*&---------------------------------------------------------------------*
FORM generate_clipboard_table  USING it_tab TYPE STANDARD TABLE
                                     et_lines TYPE ty_t_clipdata.
  DATA ls_line     TYPE ty_s_clipdata.
  DATA lv_curfl    TYPE sy-tabix.
  DATA lv_fldvl    TYPE text255.
  DATA lv_fldty.
  CONSTANTS gc_tab      TYPE c VALUE cl_bcs_convert=>gc_tab.

  FIELD-SYMBOLS: <fv_val> TYPE any.
  FIELD-SYMBOLS: <fs_tab> TYPE any.

  LOOP AT it_tab ASSIGNING <fs_tab>.
    CLEAR ls_line.
    lv_curfl = 1.
    DO.
      CLEAR: lv_fldty, lv_fldvl.
      UNASSIGN <fv_val>.
      ASSIGN COMPONENT lv_curfl OF STRUCTURE <fs_tab> TO <fv_val>.
      IF <fv_val> IS ASSIGNED.
        DESCRIBE FIELD <fv_val> TYPE lv_fldty.
        IF lv_fldty EQ 'D'.
          IF <fv_val> IS NOT INITIAL.
            WRITE <fv_val> TO lv_fldvl DD/MM/YYYY.
          ENDIF.
        ELSE.
          lv_fldvl = <fv_val>.
        ENDIF.
        CONDENSE lv_fldvl.
        IF lv_curfl = 1.
          ls_line-data = lv_fldvl.
        ELSE.
          ls_line-data = ls_line-data && gc_tab && lv_fldvl.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
      ADD 1 TO lv_curfl.
    ENDDO.
    APPEND ls_line TO et_lines.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form download_text
*&---------------------------------------------------------------------*
FORM download_text .

  DATA : BEGIN OF lt_text OCCURS 0  ,
           line(1024),
         END OF lt_text.


  l_filename = 'Garanti Bankası.txt'.
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      default_extension = 'TXT'
      default_file_name = l_filename
      initial_directory = 'C:\'
    CHANGING
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  CHECK ld_result EQ '0'.
  LOOP AT gt_filter.
    REFRESH lt_text.CLEAR lt_text.
    PERFORM create_txt2 TABLES lt_text[]
                         USING gt_filter-bukrs
                               gt_filter-werks
                               gt_filter-btrtl .
    SPLIT ld_filename AT '.' INTO ld_filename DATA(lv2).

    CONCATENATE ld_path
                ld_filename     '_'
                gt_filter-bukrs '_'
                gt_filter-btrtl '.' lv2 INTO ld_fullpath.

    CHECK lt_text[] IS NOT INITIAL .

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename              = ld_fullpath
        filetype              = 'ASC'
        write_field_separator = 'X'
*       confirm_overwrite     = 'X'
*       codepage              = '4100'
      TABLES
        data_tab              = lt_text[]
      EXCEPTIONS
        file_open_error       = 1
        file_write_error      = 2
        OTHERS                = 3.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_txt
*&---------------------------------------------------------------------*
FORM create_txt  TABLES   pt_txt.

  DATA: lv_count      TYPE int4,
        lv_zeros(18),
        lv_zerosd(16),
        lv_lngth      TYPE int2,
        lv_betrg      TYPE maxbt.

  DATA: BEGIN OF ls_baslik,
          tip(1),
          kurumkod(9),
          subekod(5),
          hesap(7),
          doviz(3),
          odemetip(1),
          sirket(25),
          izahat(38),
        END OF ls_baslik.

  DATA: BEGIN OF ls_detay_hsp,
          tip(1)                ,
          boslk1(1)      TYPE n,
          hdf_bank(9)    TYPE n,
          hdf_sube(19)   TYPE n,
*          sirket(25)    ,
          hdf_iban(26),
          alici_unv(30)         ,
          alc_tcno(11)   TYPE n,
          alc_pn(10)     TYPE n,
          tarih(8)       TYPE n,
          tutar(16) ,
          muh_izahat(38),
          alc_izahat(38) ,
        END OF ls_detay_hsp   .

  DATA: BEGIN OF ls_sonuc,
          tip,
          dty_kyt(5) TYPE n,
          toplam(18),
        END OF ls_sonuc.

  SELECT * FROM t247 INTO TABLE @DATA(lt_month)
     WHERE spras EQ @sy-langu.

*
  SELECT SINGLE * FROM t001 INTO t001 WHERE bukrs IN pnpbukrs[].
  LOOP AT go_report->gt_out INTO DATA(ls_out). ENDLOOP.
*  LOOP AT gt_t001 INTO DATA(ls_t001) WHERE bukrs IN pnpbukrs[]. ENDLOOP.
  IF pnpwerks[] IS NOT INITIAL AND pnpbtrtl[] IS NOT INITIAL.
    LOOP AT gt_t001 INTO DATA(ls_t001) WHERE werks IN pnpwerks[]
                                         AND btrtl IN pnpbtrtl[]. ENDLOOP.
  ELSE.
    LOOP AT gt_t001 INTO ls_t001 WHERE bukrs IN pnpbukrs[]
                                   AND werks EQ ls_out-werks
                                   AND btrtl EQ ls_out-btrtl. ENDLOOP.
  ENDIF.

  LOOP AT gt_t002 INTO DATA(ls_t002) WHERE bukrs IN pnpbukrs[]. ENDLOOP.
  READ TABLE gt_izah INTO DATA(ls_izah) WITH KEY domvalue_l = p_odtip .
  READ TABLE lt_month INTO DATA(ls_month) WITH KEY mnr = p_pdate+4(2).

  "<<--------HEADER------>>

  ls_baslik-tip       = 'H'.
  ls_baslik-kurumkod  = ls_t001-kurkod.
  ls_baslik-subekod   = ls_t001-subkod.
  ls_baslik-hesap     = ls_t001-hspno.
  ls_baslik-odemetip  = p_odtip.
  ls_baslik-sirket    = t001-butxt.
  IF ls_out-waers EQ 'TRY'.
    ls_baslik-doviz     = 'TL'.
  ELSE.
    ls_baslik-doviz     = ls_out-waers.
  ENDIF.
  CONCATENATE p_pdate(4) ls_month-ltx ls_izah-ddtext INTO ls_baslik-izahat
      SEPARATED BY space.
  DATA : gv_blank TYPE c VALUE cl_abap_char_utilities=>backspace.
  gv_blank = cl_abap_conv_in_ce=>uccp( '00a0' ).
  DO 26 TIMES.
    CONCATENATE  ls_baslik-izahat gv_blank INTO ls_baslik-izahat.
  ENDDO.
  APPEND ls_baslik TO pt_txt.
  "<<-------- ------>>

  "<<--------line------>>

  DATA : lv_ver(8),
         lv_ver2(7).
  LOOP AT go_report->gt_out INTO ls_out.
    ADD 1 TO lv_count.
    ADD ls_out-betrg TO lv_betrg.
    SPLIT ls_out-bankl AT '-' INTO lv_ver lv_ver2.


    ls_detay_hsp-tip          = 'D'.
    CONCATENATE lv_ver lv_ver2 INTO ls_detay_hsp-hdf_bank.
    ls_detay_hsp-boslk1     = 0.
    ls_detay_hsp-hdf_sube     = ls_out-bankn.
    ls_detay_hsp-hdf_iban     = ls_out-iban.
    ls_detay_hsp-alici_unv    = ls_out-ename.
    ls_detay_hsp-alc_tcno     = ls_out-merni.
    ls_detay_hsp-tarih        = p_pdate.
    ls_detay_hsp-tutar        = ls_out-betrg .
    SHIFT ls_detay_hsp-tutar LEFT DELETING LEADING space.

    lv_lngth = strlen( ls_detay_hsp-tutar ).
    lv_lngth = 16 - lv_lngth.
    DO lv_lngth TIMES.
      CONCATENATE '0' lv_zerosd INTO lv_zerosd.
    ENDDO.
    CONCATENATE lv_zerosd ls_detay_hsp-tutar INTO ls_detay_hsp-tutar.


    CONCATENATE ls_out-ename p_pdate(4) ls_month-ltx ls_izah-ddtext INTO ls_detay_hsp-muh_izahat SEPARATED BY space.
    CONCATENATE ls_out-ename p_pdate(4) ls_month-ltx ls_izah-ddtext INTO ls_detay_hsp-muh_izahat SEPARATED BY space.
    DO 26 TIMES.
      CONCATENATE  ls_detay_hsp-alc_izahat gv_blank
        INTO ls_detay_hsp-alc_izahat.
    ENDDO.



    APPEND ls_detay_hsp TO pt_txt.
    CLEAR lv_zerosd.
  ENDLOOP.
  "<<-------------->>


  "<<--------Total------>>

  ls_sonuc-tip = 'T'.
  ls_sonuc-dty_kyt = lv_count.
  ls_sonuc-toplam  = lv_betrg.
  SHIFT ls_sonuc-toplam LEFT DELETING LEADING space.
  lv_lngth = strlen( ls_sonuc-toplam ).
  lv_lngth = 18 - lv_lngth.
  DO lv_lngth TIMES.
    CONCATENATE '0' lv_zeros INTO lv_zeros.
  ENDDO.
  CONCATENATE lv_zeros ls_sonuc-toplam INTO ls_sonuc-toplam.
  APPEND ls_sonuc TO pt_txt.
  "<<-------------->>

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_document
*&---------------------------------------------------------------------*
FORM send_document.
  DATA : lo_sftp TYPE REF TO zbyhr_cl001."Banka Disketleri SFTP
  DATA : text_question TYPE text100.
  DATA : s_file	TYPE zbyhr_s001.
  DATA : popup_return.
  DATA : gv_name(10).
  DATA: lv_xstring    TYPE xstring.
  DATA : BEGIN OF lt_text OCCURS 0  ,
           line(1024),
         END OF lt_text.
  DATA: xml_table TYPE STANDARD TABLE OF string,
        xml       TYPE string.

  CREATE OBJECT lo_sftp
    EXPORTING
      tcode = sy-tcode. "Garanti Bankası Disketi

  READ TABLE gt_t001 INTO DATA(ls_t001) WITH KEY bukrs = pernr-bukrs werks = pernr-werks btrtl = pernr-btrtl.
  IF sy-subrc NE 0 .
    READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pernr-bukrs werks = pernr-werks.
    IF sy-subrc NE 0 .
      READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pernr-bukrs.

    ENDIF.
  ENDIF.
  READ TABLE lo_sftp->mt_t002 INTO DATA(ls_t002) WITH KEY bukrs = pernr-bukrs werks = ls_t001-werks btrtl = ls_t001-btrtl.
  IF sy-subrc NE 0 OR ls_t002-pfile IS INITIAL .
    s_file-return = 'Dosya yolunu uyarlama tablosuna giriniz.'.
    MESSAGE s_file-return TYPE 'E' DISPLAY LIKE 'I'.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM t000 INTO @DATA(ls_t000)
      WHERE mandt EQ @sy-mandt.
  IF sy-subrc EQ 0 AND ls_t000-cccategory NE 'P'.
    s_file-return = 'Dosya gönderimi yalnızca canlı sistemde yapılmalıdır.'.
    MESSAGE s_file-return TYPE 'E' DISPLAY LIKE 'I'.
    EXIT.
  ENDIF.

  text_question = 'Bilgiler bankaya iletilecek. Devam edilsin mi?'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Uyarı ! '
      text_question         = text_question
      text_button_1         = 'Evet'
      text_button_2         = 'Hayır'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = popup_return
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF popup_return EQ '1'.

    LOOP AT gt_filter .

      CASE ls_t001-ftype.
        WHEN 'T'.
          PERFORM create_txt2 TABLES lt_text[]
                               USING gt_filter-bukrs
                                     gt_filter-werks
                                     gt_filter-btrtl .

          s_file-pname = ls_t002-pname &&
                         p_pdate &&
                         gv_name &&
                         gt_filter-bukrs &&
                         gt_filter-werks &&
                         gt_filter-btrtl &&
                         '.txt'.
          lo_sftp->file_convert_binary(
            EXPORTING
              t_data   = lt_text[]
            IMPORTING
              e_binary = s_file-bin_file
*            e_data   = s_file-data_file
          ).
        WHEN 'E'.
          PERFORM set_excel TABLES xml_table
                               USING gt_filter-bukrs
                                     gt_filter-werks
                                     gt_filter-btrtl.
          CHECK xml_table[] IS NOT INITIAL  .
          READ TABLE xml_table INTO xml INDEX 1 .
          CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
            EXPORTING
              text     = xml
              encoding = 'UTF-8'
*             mimetype = 'application/xml'
            IMPORTING
              buffer   = s_file-bin_file.
          s_file-pname = ls_t002-pname &&
                         p_pdate &&
                         gv_name &&
                         gt_filter-bukrs &&
                         gt_filter-werks &&
                         gt_filter-btrtl && '.xls'.
      ENDCASE.
      IF s_file-bin_file IS NOT INITIAL .
        s_file-bukrs = gt_filter-bukrs.
        s_file-spmon = p_pdate.
        CALL METHOD lo_sftp->rest_trasnport_file
          CHANGING
            s_file = s_file.
        IF s_file-return IS NOT INITIAL .
          MESSAGE s_file-return TYPE 'I' DISPLAY LIKE 'I'.
        ENDIF.

      ELSE.
        MESSAGE 'Veri bulunamadı ' TYPE 'E' DISPLAY LIKE 'I'.
      ENDIF.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_txt2
*&---------------------------------------------------------------------*
FORM create_txt2  TABLES   pt_txt
                    USING pv_bukrs
                          pv_werks
                          pv_btrtl      .
  DATA : BEGIN OF ls_header ,
           kytip(1),         "Kayıt Tipi 01 A  Sabit saha. Değeri = ‘H’.
           krmkd(9)  TYPE n, "Kurum Kodu 09 N  Şube tarafından bildirilecek.
           krmsk(5)  TYPE n, "Kurum Hesabı Şube Kodu 05 N
           krmhs(7)  TYPE n, "Kurum Hesap Numarası 07 N
           doviz(3) ,        "Döviz Kodu 03 A  Ödemelerin döviz cinsi. TL, EUR, USD vb.
           odmtp(1),         "Ödeme Tipi 1 A
           bizah(50),        "Toplu Muhasebe Borç İzahat 38 A
         END OF ls_header.

  DATA : BEGIN OF ls_detail,
           kytip(1),         "Kayıt Tipi 01 A  Sabit saha. Değeri = ‘D’. (Zorunlu)
           phbkd(5)   TYPE n, "Personel Hes. Banka Kodu 05 N  Garanti Bankası için “0” ile doldurunuz. (IBAN yazılması durumda Zorunlu değil)
           phskd(5)   TYPE n, "Personel Hes. Şube Kodu  05 N  Personel hesabının bulunduğu şube kodu. (IBAN yazılması durumda Zorunlu değil)
           phesp(19),        "Personel Hesap Numarası  19 A  Personelin hesabı. (IBAN yazılması durumda Zorunlu değil)
           piban(26),        "Personel IBAN No 26A
           ename(30),        "Personelin Adı/Soyadı  30 A  Personelin adı soyadı. (Zorunlu)
           merni(11),        "Personelin TCKN’si 11 N  Eğer TCKN girilmeyecek ise boşluk (space) veya “0” karakteri ile doldurunuz.
           pernr(10)  TYPE n, "Personelin Sicil Nosu  10N Eğer Sicil no girilmeyecek ise boşluk (space) karakteri ile doldurunuz.
           odtrh(8),         "Ödeme Tarihi 08 N  Ödemenin yapılacağı tarih. YYYYaaGG formatında olmalı. (Zorunlu)
           betrg(16),        "Ödeme Tutarı 13.2 N  Ödenecek net maaş tutarıdır. (Zorunlu) Örnek : 999.99 YTL için 0000000000999.99 yazılmalıdır.
*           waers(2),         "Döviz kodu YTL’den farklı olduğunda da format aynıdır.
           mbizah(50),       "Tekli Muhasebe Borç İzahat 38 A  Zorunlu: Doldurulmadığı takdirde dosya işlenmeyecektir.
           alizah(50),       "Alacak izahat  38 A  Zorunlu: Doldurulmadığı takdirde dosya işlenmeyecektir.
         END OF ls_detail.

  DATA : BEGIN OF ls_total,
           kytip(1),        "Kayıt Tipi 01 A  Sabit saha. Değeri = ‘T’. (Zorunlu)
           count(5)  TYPE n, "Personel Sayısı  05 N  Ödeme yapılacak olan personel sayısı. (Zorunlu)
           total(18),       "Toplam Tutar 15.2 N  Ödenecek toplam tutar. (Zorunlu)
*           waers(2),        "Örnek : 999.99 YTL için 000000000000999.99 yazılmalıdır. Döviz kodu YTL’den farklı olduğunda da format aynıdır.
         END OF ls_total.

  DATA : lv_phbkd(5),
         lv_phskd(5),
         lv_zeros(30), " Total zero
         lv_lngth     TYPE int2,
         lv_count     TYPE int4,
         lv_total     TYPE maxbt.

  DATA : gv_blank TYPE c VALUE cl_abap_char_utilities=>backspace.


  DEFINE add_zero.
    SHIFT &2 LEFT DELETING LEADING space.
    lv_lngth = strlen( &2 ).
    lv_lngth = &1 - lv_lngth.
    DO lv_lngth TIMES.
      CONCATENATE '0' lv_zeros INTO lv_zeros.
    ENDDO.
    CONCATENATE lv_zeros &2 INTO &2.
    CLEAR lv_zeros.
  END-OF-DEFINITION.


  gv_blank = cl_abap_conv_in_ce=>uccp( '00a0' ).


  SELECT * FROM t247 INTO TABLE @DATA(lt_month)
     WHERE spras EQ @sy-langu.
  LOOP AT go_report->gt_out INTO DATA(ls_temp) WHERE bukrs EQ pv_bukrs
                                                AND werks EQ pv_werks
                                                AND btrtl EQ pv_btrtl.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0 .
    LOOP AT go_report->gt_out INTO ls_temp WHERE bukrs EQ pv_bukrs
                                                  AND werks EQ pv_werks .
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0 .
      LOOP AT go_report->gt_out INTO ls_temp WHERE bukrs EQ pv_bukrs .
        EXIT.
      ENDLOOP.
    ENDIF.
  ENDIF.
  LOOP AT gt_t001 INTO DATA(ls_t001) WHERE bukrs  EQ pv_bukrs
                                        AND werks EQ pv_werks
                                        AND btrtl EQ pv_btrtl.
  ENDLOOP.
  READ TABLE lt_month INTO DATA(ls_month) WITH KEY mnr = p_pdate+4(2).
  READ TABLE gt_izah INTO DATA(ls_izah) WITH KEY domvalue_l = p_odtip .

  ls_header-kytip = 'H'.
  ls_header-krmkd = ls_t001-kurkod.
  ls_header-krmsk = ls_t001-subkod.
  ls_header-krmhs = ls_t001-hspno.
  IF ls_temp-waers EQ 'TRY'.
    ls_header-doviz = 'TRY'.
  ELSE.
    ls_header-doviz = ls_temp-waers.
  ENDIF.
  ls_header-odmtp = p_odtip.
*  CONCATENATE ls_month-ltx p_pdate(4) ls_izah-ddtext INTO ls_header-bizah SEPARATED BY space.
  CONCATENATE t001-butxt ls_izah-ddtext INTO ls_header-bizah SEPARATED BY space.

  DO 38 TIMES.
    CONCATENATE  ls_header-bizah gv_blank
      INTO ls_header-bizah.
  ENDDO.
  APPEND ls_header TO pt_txt. CLEAR ls_header.


  LOOP AT go_report->gt_out INTO DATA(ls_out) .

    IF pv_bukrs IS NOT INITIAL .
      CHECK ls_out-bukrs EQ pv_bukrs.
    ENDIF.
    IF pv_werks IS NOT INITIAL .
      CHECK ls_out-werks EQ pv_werks.
    ENDIF.
    IF pv_btrtl IS NOT INITIAL .
      CHECK ls_out-btrtl EQ pv_btrtl.
    ENDIF.

    ADD 1 TO lv_count.
    ADD ls_out-betrg TO lv_total.

    SPLIT ls_out-bankl AT '-' INTO lv_phbkd lv_phskd.
    ls_detail-kytip    = 'D'.
    ls_detail-phbkd    = lv_phbkd. add_zero : 5 ls_detail-phbkd.
    ls_detail-phskd    = lv_phskd. add_zero : 5 ls_detail-phskd.
    ls_detail-phesp    = ls_out-bankn.add_zero : 19 ls_detail-phesp.
    ls_detail-piban    = ls_out-iban.
    ls_detail-ename    = ls_out-ename.
    ls_detail-merni    = ls_out-merni.
    CONCATENATE '00' ls_out-pernr INTO ls_detail-pernr.
    ls_detail-odtrh    = p_pdate.

    ls_detail-betrg    = ls_out-betrg.
    add_zero : 16 ls_detail-betrg.

*    CONCATENATE ls_out-ename ls_month-ltx p_pdate(4) ls_izah-ddtext INTO ls_detail-mbizah SEPARATED BY space.
*    CONCATENATE ls_month-ltx p_pdate(4) ls_izah-ddtext INTO ls_detail-alizah SEPARATED BY space.

    CONCATENATE t001-butxt ls_izah-ddtext INTO ls_detail-mbizah SEPARATED BY space.
    DO 38 TIMES.
      CONCATENATE  ls_detail-mbizah gv_blank
        INTO ls_detail-mbizah.
    ENDDO.
    DO 38 TIMES.
      CONCATENATE  ls_detail-alizah gv_blank
        INTO ls_detail-alizah.
    ENDDO.
    APPEND ls_detail TO pt_txt. CLEAR ls_detail.
  ENDLOOP.

  ls_total-kytip = 'T'.
  ls_total-count = lv_count.
  ls_total-total = lv_total.

  add_zero : 18 ls_total-total.
*  IF ls_out-waers EQ 'TRY'.
*    ls_total-waers = 'TL'.
*  ELSE.
*    ls_total-waers = ls_out-waers.
*  ENDIF.
  APPEND ls_total TO pt_txt. CLEAR ls_total.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_excel
*&---------------------------------------------------------------------*
FORM set_excel  TABLES   xml_table
                    USING pv_bukrs
                          pv_werks
                          pv_btrtl    .

  DATA : topad TYPE i .
  DATA : tptar TYPE maxbt.

  DATA :
    BEGIN OF ls_head ,
      krmkd TYPE char100, "KRMKD
      sbkod TYPE char100, "SBKOD
      hesap TYPE char100, "HESAP
      topad TYPE char100, "TOPAD
      tptar TYPE char100, "TPTAR
      dvkur TYPE char100, "DVKUR
      odtrh TYPE char100, "ODTRH
      odmtp TYPE char100, "ODMTP
      brciz TYPE char100, "BRCIZ
    END OF ls_head,
    xmlstr TYPE string.

  DATA : lt_out TYPE TABLE OF zbyhr_s011 .


  READ TABLE gt_t001 INTO DATA(ls_t001) WITH KEY bukrs = pv_bukrs werks = pv_werks btrtl = pv_btrtl.
  IF sy-subrc NE 0 .
    READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pv_bukrs werks = pv_werks.
    IF sy-subrc NE 0 .
      READ TABLE gt_t001 INTO ls_t001 WITH KEY bukrs = pv_bukrs.
    ENDIF.
  ENDIF.
  READ TABLE gt_t002 INTO DATA(ls_t002) WITH KEY bukrs = pernr-bukrs werks = ls_t001-werks btrtl = ls_t001-btrtl.
  READ TABLE gt_izah INTO DATA(ls_izah) WITH KEY domvalue_l = p_odtip .
  REFRESH lt_out.
  LOOP AT go_report->gt_out INTO DATA(ls_out).
    IF pv_bukrs IS NOT INITIAL .
      CHECK ls_out-bukrs EQ pv_bukrs.
    ENDIF.
    IF pv_werks IS NOT INITIAL .
      CHECK ls_out-werks EQ pv_werks.
    ENDIF.
    IF pv_btrtl IS NOT INITIAL .
      CHECK ls_out-btrtl EQ pv_btrtl.
    ENDIF.

    ls_head-krmkd    = ls_out-kurkod.
    ls_head-sbkod    = ls_out-subkod.
    ls_head-hesap    = ls_out-hspno.
    ls_head-dvkur    = ls_out-waers.
    ls_head-odmtp    = p_odtip.
    ls_head-brciz    = ls_out-bizah.
    ADD 1 TO topad.
    ADD ls_out-betrg TO tptar.
    APPEND ls_out TO lt_out.

  ENDLOOP.
  ls_head-topad    = topad.
  WRITE tptar TO ls_head-tptar CURRENCY ls_out-waers.
  SHIFT ls_head-topad LEFT DELETING LEADING space.
  SHIFT ls_head-tptar LEFT DELETING LEADING space.
  ls_head-odtrh    = p_pdate+6(2) && p_pdate+4(2) && p_pdate(4).


  CALL TRANSFORMATION zbyhr_p018
       SOURCE
            gt_list   = lt_out[]
              krmkd    = ls_head-krmkd
              sbkod    = ls_head-sbkod
              hesap    = ls_head-hesap
              topad    = ls_head-topad
              tptar    = ls_head-tptar
              dvkur    = ls_head-dvkur
              odtrh    = ls_head-odtrh
              odmtp    = ls_head-odmtp
              brciz    = ls_head-brciz
       RESULT XML xmlstr.

  APPEND xmlstr TO xml_table.
ENDFORM.
