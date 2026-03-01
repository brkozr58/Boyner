*&---------------------------------------------------------------------*
*& Include          ZBYHR_P004_I002
*&---------------------------------------------------------------------*


CLASS gc_main DEFINITION.
  PUBLIC SECTION .
    " - ALV DEFINATION
    DATA: o_alv        TYPE REF TO cl_salv_table,
          go_display   TYPE REF TO cl_salv_display_settings,
          go_columns   TYPE REF TO cl_salv_columns_table,
          go_column    TYPE REF TO cl_salv_column_table,
          go_events    TYPE REF TO cl_salv_events_table,
          go_functions TYPE REF TO cl_salv_functions_list,
          go_selection TYPE REF TO cl_salv_selections,
          go_layout    TYPE REF TO cl_salv_layout,
          go_sorts     TYPE REF TO cl_salv_sorts,
          go_agg       TYPE REF TO cl_salv_aggregations.
    DATA: color TYPE lvc_s_colo.

    METHODS :
      set_init,
      set_data,
      set_sel_screen,
      at_selection_screen ,
      get_sample_excel_file ,
      ins_batch   EXPORTING rows    TYPE int4 ,
      prepare_alv EXPORTING tables TYPE char10,
      on_user_command
        FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function,
      set_column_text
        IMPORTING i_fname TYPE lvc_fname
                  i_text  TYPE any          ,
      set_color
        IMPORTING i_fname TYPE lvc_fname
                  i_color TYPE any          ,
      set_visible
        IMPORTING i_fname TYPE lvc_fname,
      set_pf_status CHANGING co_alv TYPE REF TO cl_salv_table.

ENDCLASS.                    "gc_main DEFINITION

*----------------------------------------------------------------------*
*       CLASS gc_main IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS gc_main IMPLEMENTATION .

  METHOD set_data.
    gv_gui = 'GUI'.
    DATA : raw      TYPE truxs_t_text_data .

*    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*      EXPORTING
*        I_FIELD_SEPERATOR    = 'X'
*        I_LINE_HEADER        = 'X'
*        I_TAB_RAW_DATA       = RAW
*        I_FILENAME           = P_FNAME
*      TABLES
*        I_TAB_CONVERTED_DATA = GT_ALV
*      EXCEPTIONS
*        CONVERSION_FAILED    = 1
*        OTHERS               = 2.


    lv_fnam = p_fname.
    cl_gui_frontend_services=>gui_upload(
  EXPORTING
    filename                = lv_fnam "SPACE    " Name of file
    filetype                = 'BIN'
  IMPORTING
    filelength              =  lv_filelength " File Length
    header                  =  lv_headerxstring   " File Hea
  CHANGING
    data_tab                = lt_records  " Transfer table
  EXCEPTIONS
    file_open_error         = 1
    file_read_error         = 2
    no_batch                = 3
    gui_refuse_filetransfer = 4
    invalid_type            = 5
    no_authority            = 6
    unknown_error           = 7
    bad_data_format         = 8
    header_not_allowed      = 9
    separator_not_allowed   = 10
    header_too_long         = 11
    unknown_dp_error        = 12
    access_denied           = 13
    dp_out_of_memory        = 14
    disk_full               = 15
    dp_timeout              = 16
    not_supported_by_gui    = 17
    error_no_gui            = 18
    OTHERS                  = 19 ).

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_filelength
      IMPORTING
        buffer       = lv_headerxstring
      TABLES
        binary_tab   = lt_records
      EXCEPTIONS
        failed       = 1
        OTHERS       = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                            document_name = lv_fnam
                            xdocument     = lv_headerxstring ).


    lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
      IMPORTING
        worksheet_names = DATA(lt_wsname)
    ).

    READ TABLE lt_wsname INTO DATA(lv_wsname) INDEX 1.

    DATA(lo_data_ref) =
   lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
    worksheet_name  = lv_wsname
    ).

    ASSIGN lo_data_ref->* TO <l_data>.
    DELETE <l_data> INDEX 1.


    LOOP AT <l_data> ASSIGNING FIELD-SYMBOL(<l_data2>) .

      ASSIGN COMPONENT 'A' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell1>).
      ASSIGN COMPONENT 'B' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell2>).
      ASSIGN COMPONENT 'C' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell3>).
      ASSIGN COMPONENT 'D' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell4>).
      ASSIGN COMPONENT 'E' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell5>).
      ASSIGN COMPONENT 'F' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell6>).
      ASSIGN COMPONENT 'G' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell7>).
      ASSIGN COMPONENT 'H' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell8>).
      ASSIGN COMPONENT 'I' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell9>).
      ASSIGN COMPONENT 'J' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell10>).
      ASSIGN COMPONENT 'K' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell11>).
      ASSIGN COMPONENT 'L' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell12>).
      ASSIGN COMPONENT 'M' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell13>).
      ASSIGN COMPONENT 'N' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell14>).
      ASSIGN COMPONENT 'O' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell15>).
      ASSIGN COMPONENT 'P' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell16>).
      ASSIGN COMPONENT 'Q' OF STRUCTURE <l_data2> TO FIELD-SYMBOL(<l_cell17>).

      IF <l_cell1> IS ASSIGNED .
        gs_alv-pernr = <l_cell1>.
*
        CONCATENATE <l_cell2>+0(4) <l_cell2>+5(2) <l_cell2>+8(2)
         INTO gs_alv-begda.
        CONCATENATE <l_cell3>+0(4) <l_cell3>+5(2) <l_cell3>+8(2)
         INTO gs_alv-endda.
*
        gs_alv-mslks  = <l_cell4>.
        gs_alv-cttyp  = <l_cell5>.
        gs_alv-avans  = <l_cell6>.
        gs_alv-ikram  = <l_cell7>.
        gs_alv-borde0 = <l_cell8>.
        gs_alv-borde1 = <l_cell9>.
        gs_alv-borde2 = <l_cell10>.
        gs_alv-borde3 = <l_cell11>.
        gs_alv-borde4 = <l_cell12>.
        gs_alv-borde5 = <l_cell13>.
        gs_alv-borde6 = <l_cell14>.
        gs_alv-borde7 = <l_cell15>.
        gs_alv-borde8 = <l_cell16>.
        gs_alv-borde9 = <l_cell17>.



        APPEND gs_alv TO gt_alv.
        CLEAR: gs_alv, <l_data2>,<l_cell1>,<l_cell2>,<l_cell3>,
           <l_cell4>, <l_cell5>,<l_cell6>,<l_cell7>,<l_cell8>,<l_cell9>,
           <l_cell10>,<l_cell11>,<l_cell12>,<l_cell13>,<l_cell14>,
           <l_cell15>, <l_cell16>, <l_cell17>.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.                    "set_data
  METHOD ins_batch.
    DATA : return   TYPE  bapireturn1 .
    DATA : nocommit TYPE  bapi_stand-no_commit.
    DATA : state,
           infotype TYPE prelp-infty VALUE '0771'.

    DATA : s0771 TYPE p0771.
    CLEAR: s0771.

    IF p_upd EQ 'X'.
      SELECT SINGLE * FROM pa0771 INTO @DATA(ls_0771)
                                 WHERE pernr EQ @gs_alv-pernr
                                   AND endda EQ '99991231'.
      s0771 = CORRESPONDING #( ls_0771 ).

      IF gs_alv-pernr  IS NOT INITIAL . s0771-pernr  = gs_alv-pernr . ENDIF.
      IF gs_alv-begda  IS NOT INITIAL . s0771-begda  = gs_alv-begda . ENDIF.
      IF gs_alv-endda  IS NOT INITIAL . s0771-endda  = gs_alv-endda . ENDIF.
      IF gs_alv-mslks  IS NOT INITIAL . s0771-mslks  = gs_alv-mslks . ENDIF.
      IF gs_alv-avans  IS NOT INITIAL . s0771-avans  = gs_alv-avans . ENDIF.
      IF gs_alv-ikram  IS NOT INITIAL . s0771-ikram  = gs_alv-ikram . ENDIF.
      IF gs_alv-cttyp  IS NOT INITIAL . s0771-cttyp  = gs_alv-cttyp . ENDIF.
      IF gs_alv-borde0 IS NOT INITIAL . s0771-borde0 = gs_alv-borde0. ENDIF.
      IF gs_alv-borde1 IS NOT INITIAL . s0771-borde1 = gs_alv-borde1. ENDIF.
      IF gs_alv-borde2 IS NOT INITIAL . s0771-borde2 = gs_alv-borde2. ENDIF.
      IF gs_alv-borde3 IS NOT INITIAL . s0771-borde3 = gs_alv-borde3. ENDIF.
      IF gs_alv-borde4 IS NOT INITIAL . s0771-borde4 = gs_alv-borde4. ENDIF.
      IF gs_alv-borde5 IS NOT INITIAL . s0771-borde5 = gs_alv-borde5. ENDIF.
      IF gs_alv-borde6 IS NOT INITIAL . s0771-borde6 = gs_alv-borde6. ENDIF.
      IF gs_alv-borde7 IS NOT INITIAL . s0771-borde7 = gs_alv-borde7. ENDIF.
      IF gs_alv-borde8 IS NOT INITIAL . s0771-borde8 = gs_alv-borde8. ENDIF.
      IF gs_alv-borde9 IS NOT INITIAL . s0771-borde9 = gs_alv-borde9. ENDIF.
    ENDIF.

    SELECT SINGLE * FROM pa0001 INTO @DATA(ls_0001)
                               WHERE pernr EQ @gs_alv-pernr
                                 AND begda LE @gs_alv-endda
                                 AND endda GE @gs_alv-begda.

    IF sy-subrc EQ 0 OR p_upd EQ 'X'.


      s0771-infty = infotype.

      IF p_upd NE 'X'.
        s0771 = CORRESPONDING #( gs_alv ).
        IF s0771-avans IS INITIAL OR s0771-avans EQ  0.
          s0771-avans = 1.
        ELSE.
          s0771-avans = 0.
        ENDIF.

        IF s0771-ikram IS INITIAL OR s0771-ikram EQ  0.
          s0771-ikram = 1.
        ELSE.
          s0771-ikram = 0.
        ENDIF.

      ENDIF.

      CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = s0771-pernr.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'HR_INFOTYPE_OPERATION'
          EXPORTING
            infty         = infotype
            number        = s0771-pernr
            subtype       = s0771-subty
            validityend   = s0771-begda
            validitybegin = s0771-endda
            record        = s0771
            operation     = 'INS'
            tclas         = 'A'
            dialog_mode   = '0'
            nocommit      = nocommit
          IMPORTING
            return        = return
          EXCEPTIONS
            OTHERS        = 0.

        IF return IS INITIAL.
          gs_alv-durum = 'Kayıt Başarıyla Atıldı'.
          gs_alv-icon = '@2K@'.
        ELSE.
          gs_alv-durum = return-message.
          gs_alv-icon = '@8O@'.
        ENDIF.

      ELSE.
        gs_alv-durum = 'Personel Blokeli Durumda'.
        gs_alv-icon = '@8O@'.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = gs_alv-pernr.

    ELSE.
      gs_alv-durum = 'Personel bulunamadı!'.
      gs_alv-icon  = '@8O@'.
    ENDIF.
    MODIFY gt_alv FROM gs_alv INDEX rows.
    CLEAR : ls_0771, s0771,gs_alv.

  ENDMETHOD.                    "ins_batch

  METHOD set_sel_screen.
*
    CALL FUNCTION 'F4_FILENAME'
      EXPORTING
        field_name = 'P_FILE'
      IMPORTING
        file_name  = p_fname.
*

  ENDMETHOD.                    "set_sel_screen
  METHOD set_column_text.

    DATA : lv_ltext TYPE scrtext_l,
           lv_mtext TYPE scrtext_m,
           lv_stext TYPE scrtext_s.

    go_column ?= go_columns->get_column( i_fname ).
    MOVE : i_text TO lv_ltext.
    go_column->set_long_text( lv_ltext ).
    MOVE : i_text TO lv_mtext.
    go_column->set_medium_text( lv_mtext ).
    MOVE : i_text TO lv_stext.
    go_column->set_short_text( lv_stext  ).

  ENDMETHOD.                    "set_column_text
  METHOD set_visible.
    go_column ?= go_columns->get_column( i_fname ).
    go_column->set_visible( ' '  ).
  ENDMETHOD.                    "set_column_text
  METHOD set_color.

    go_column ?= go_columns->get_column( i_fname ).
    color-col = i_color.
    color-int = '1'.
    color-inv = '0'.
    go_column->set_color( color ).

  ENDMETHOD.                    "set_color

  METHOD prepare_alv.

    FIELD-SYMBOLS <table> TYPE table.
    ASSIGN (tables) TO <table>.

    DATA: lc_msg TYPE REF TO cx_salv_msg.
    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = o_alv
          CHANGING
            t_table      = <table>.
      CATCH cx_salv_msg INTO lc_msg .
    ENDTRY.

    o_alv->get_columns( RECEIVING value = go_columns ).

    o_alv->set_screen_status(
           pfstatus      = gv_gui
           report        = sy-repid
           set_functions = o_alv->c_functions_all ).

    go_display = o_alv->get_display_settings( ).

*     Zebra sytle..
    go_display->set_striped_pattern( cl_salv_display_settings=>true ).
    go_columns = o_alv->get_columns( ).

    go_columns->set_optimize( abap_true ).
    go_layout = o_alv->get_layout( ).

* Set Selection
    go_selection = o_alv->get_selections( ).
    go_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    go_events = o_alv->get_event( ).

* Set selection..
    go_selection = o_alv->get_selections( ).
    go_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

* Set ALV EVENTS..
    SET HANDLER go_report->on_user_command FOR go_events.
    go_report->set_column_text( i_fname = 'PERNR'    i_text = TEXT-011 )
    .
    go_report->set_column_text( i_fname = 'BEGDA'    i_text = TEXT-012 )
    .
    go_report->set_column_text( i_fname = 'ENDDA'    i_text = TEXT-013 )
    .
    go_report->set_column_text( i_fname = 'CTTYP'    i_text = TEXT-014 ).
*go_report->set_column_text( i_fname = 'SGDP1'    i_text = TEXT-015 ).
*go_report->set_column_text( i_fname = 'TRTSK'    i_text = TEXT-016 ).
    go_report->set_column_text( i_fname = 'MSLKS'    i_text = TEXT-017 )
    .
    go_report->set_column_text( i_fname = 'AVANS'    i_text = TEXT-030 )
    .
    go_report->set_column_text( i_fname = 'IKRAM'    i_text = TEXT-031 )
    .
    go_report->set_column_text( i_fname = 'BORDE0'   i_text = TEXT-018 )
    .
    go_report->set_column_text( i_fname = 'BORDE1'   i_text = TEXT-019 )
    .
    go_report->set_column_text( i_fname = 'BORDE2'   i_text = TEXT-020 )
    .
    go_report->set_column_text( i_fname = 'BORDE3'   i_text = TEXT-021 )
    .
    go_report->set_column_text( i_fname = 'BORDE4'   i_text = TEXT-022 )
    .
    go_report->set_column_text( i_fname = 'BORDE5'   i_text = TEXT-023 )
    .
    go_report->set_column_text( i_fname = 'BORDE6'   i_text = TEXT-024 )
    .
    go_report->set_column_text( i_fname = 'BORDE7'   i_text = TEXT-025 )
    .
    go_report->set_column_text( i_fname = 'BORDE8'   i_text = TEXT-026 )
    .
    go_report->set_column_text( i_fname = 'BORDE9'   i_text = TEXT-027 )
    .
    go_report->set_column_text( i_fname = 'ICON'     i_text = TEXT-028 )
    .
    go_report->set_column_text( i_fname = 'DURUM'    i_text = TEXT-029 )
    .

    o_alv->display( ).
  ENDMETHOD.                    "prepare_alv

  METHOD on_user_command.
    DATA : lt_rows  TYPE salv_t_row,
           lv_rows  TYPE int4,
           lv_subrc TYPE sy-subrc,
           lv_infty TYPE char4.
    CLEAR: lt_rows[] , lv_rows , lv_infty.
    lt_rows = go_selection->get_selected_rows( ).
    CASE e_salv_function.
      WHEN 'BATCH'.
        LOOP AT lt_rows INTO lv_rows.
          CLEAR gs_alv.
          READ TABLE gt_alv INTO gs_alv INDEX lv_rows.
          IF sy-subrc EQ 0.
            go_report->ins_batch( IMPORTING rows  = lv_rows ).
          ENDIF.
        ENDLOOP.
    ENDCASE.
    o_alv->refresh(  ).
  ENDMETHOD.                    "on_user_command

  METHOD set_pf_status.
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
    lo_functions = co_alv->get_functions( ).
    lo_functions->set_default( abap_true ).
  ENDMETHOD.              "set_pf_status

  METHOD at_selection_screen.
    " selection screen kısmındaki fonksyonel tuşlara basılması
    IF sscrfields-ucomm EQ 'FC01'.
      " Örnek dosyanın oluşturulması
      me->get_sample_excel_file( ).
*    ELSE.
*      " Dosya kontrolü
*      me->check_file_name( ).
    ENDIF.
  ENDMETHOD.                    "at_selection_screen
  METHOD get_sample_excel_file.
    DATA : subrc TYPE sy-subrc .
    DATA : fname(128) .
    DATA: ld_filename TYPE string,
          ld_path     TYPE string,
          ld_fullpath TYPE string,
          ld_result   TYPE i,

          l_filename  TYPE string.
*--

    DATA : lt_signat  TYPE TABLE OF bapisignat,
           i_exname   TYPE bds_typeid,
           lt_signat2 TYPE TABLE OF bapisignat.
    DATA : lt_comp TYPE TABLE OF bapicompon.
    DATA : lt_cont TYPE TABLE OF bapiconten.
    DATA : lv_file TYPE string.
    DATA : lv_fold TYPE string.

    CLEAR : i_exname.

    i_exname = 'ZHRP005_771'.



    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_URL'
      EXPORTING
*       LOGICAL_SYSTEM  =
        classname       = 'PICTURES'
        classtype       = 'OT'
        client          = sy-mandt
        object_key      = i_exname
        url_lifetime    = 'T'
      TABLES
        signature       = lt_signat
      EXCEPTIONS
        nothing_found   = 1
        parameter_error = 2
        not_allowed     = 3
        error_kpro      = 4
        internal_error  = 5
        not_authorized  = 6
        OTHERS          = 7.

    IF sy-subrc = 0.
      READ TABLE lt_signat INTO DATA(ls_signat) WITH KEY doc_count = 1.

      IF sy-subrc = 0.

        CALL FUNCTION 'BDS_DOCUMENT_DISPLAY'
          EXPORTING
            client          = sy-mandt
            doc_id          = ls_signat-doc_id
          TABLES
            signature       = lt_signat
          EXCEPTIONS
            nothing_found   = 1
            parameter_error = 2
            not_allowed     = 3
            error_kpro      = 4
            internal_error  = 5
            not_authorized  = 6
            OTHERS          = 7.
        IF sy-subrc <> 0.
          MESSAGE TEXT-m01 TYPE 'S' DISPLAY LIKE 'E'.
        ENDIF.

      ENDIF.
    ENDIF.

  ENDMETHOD.          "get_sample_excel_file

  METHOD set_init.
    " fonksyon tuşuna isim verme
    sc_fc01-icon_id          = '@49@' .
    sc_fc01-quickinfo        = TEXT-101 .
    sc_fc01-icon_text        = TEXT-101 .
    sscrfields-functxt_01    = sc_fc01.
  ENDMETHOD.

ENDCLASS.                    "gc_main IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
FORM init .

ENDFORM.                    "init
