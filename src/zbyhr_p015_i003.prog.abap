*&---------------------------------------------------------------------*
*& Include          ZBYHR_P015_I003
*&---------------------------------------------------------------------*

CLASS gr_report DEFINITION.
  PUBLIC SECTION .
    METHODS : set_date,
      set_init,
      get_data,
      read_payroll,
      display_alv,
      prepare_alv.
**
  PROTECTED SECTION.
    DATA : gr_alv       TYPE REF TO cl_salv_table,
           gr_past      TYPE REF TO cl_salv_table,
           gr_display   TYPE REF TO cl_salv_display_settings,
           gr_columns   TYPE REF TO cl_salv_columns_table,
           gr_column    TYPE REF TO cl_salv_column_table,
           gr_functions TYPE REF TO cl_salv_functions_list,
           gr_selection TYPE REF TO cl_salv_selections,
           gr_layout    TYPE REF TO cl_salv_layout,
           gr_events    TYPE REF TO cl_salv_events_table,
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
    gv_fyear = s_date-low(4) && '01' && '01'.
  ENDMETHOD.
  METHOD set_init.

    SELECT * FROM t549t INTO TABLE gt_t549t WHERE sprsl EQ sy-langu.
    SELECT * FROM t001p INTO TABLE gt_t001p.
    SELECT * FROM t513s INTO TABLE gt_t513s WHERE sprsl EQ sy-langu AND
                                                  endda EQ '99991231'.
    SELECT * FROM cskt  INTO TABLE gt_cskt.

  ENDMETHOD.
  METHOD get_data.

    DATA : ls_out LIKE LINE OF gt_out.
    DATA : lt_absence TYPE TABLE OF bapip2001l.
    DATA : lv_fdate TYPE datum.
    DATA : lv_ldate TYPE sy-datum.

    CHECK p0000-stat2 IN pnpstat2.

    ls_out-pernr = pernr-pernr.
    ls_out-ename = p0001-ename.
    ls_out-merni = p0770-merni.
    ls_out-gbdat = p0002-gbdat.

    CALL FUNCTION 'RP_GET_HIRE_DATE'
      EXPORTING
        persnr          = pernr-pernr
        check_infotypes = '0041'
        datumsart       = '01'
      IMPORTING
        hiredate        = ls_out-hiredate.

    CALL FUNCTION 'RP_GET_FIRE_DATE'
      EXPORTING
        persnr   = pernr-pernr
        status2  = '0'
      IMPORTING
        firedate = lv_fdate.

    CALL FUNCTION 'RP_GET_HIRE_DATE'
      EXPORTING
        persnr          = pernr-pernr
        check_infotypes = '0041'
        datumsart       = '04'
      IMPORTING
        hiredate        = ls_out-sapdate.

    IF ls_out-sapdate EQ '99991231'.
      ls_out-sapdate = space.
    ENDIF.

    READ TABLE gt_t549t INTO DATA(ls_t549t) WITH KEY abkrs = p0001-abkrs.
    IF sy-subrc IS INITIAL.
      ls_out-atext = ls_t549t-atext.
    ENDIF.
    READ TABLE gt_t001p INTO DATA(ls_t001p) WITH KEY werks = p0001-werks
                                                     btrtl = p0001-btrtl.
    IF sy-subrc IS INITIAL.
      ls_out-btext = ls_t001p-btext.
    ENDIF.
    READ TABLE gt_t513s INTO DATA(ls_t513s) WITH KEY stell = p0001-stell.
    IF sy-subrc IS INITIAL.
      ls_out-stltx = ls_t513s-stltx.
    ENDIF.
    READ TABLE gt_cskt INTO DATA(ls_cskt) WITH KEY kostl = p0001-kostl.
    IF sy-subrc IS INITIAL.
      ls_out-ktext = ls_cskt-ktext.
    ENDIF.

    LOOP AT p2006 INTO DATA(ls_2006) WHERE subty EQ '01' AND
                                           begda LE s_date-low AND
                                           endda GE gv_fyear.
      ls_out-anzhl = ls_out-anzhl + ls_2006-anzhl.

    ENDLOOP.

    LOOP AT p2001 INTO p2001 WHERE subty EQ '0500'
                                OR subty EQ '0100'
*                                OR subty EQ '1100'
*                                OR subty EQ '1120'
                    .
      CASE p2001-begda+4(2).
        WHEN '01'.
          ls_out-ay1 = ls_out-ay1   + p2001-abwtg.
        WHEN '02'.
          ls_out-ay2 = ls_out-ay2   + p2001-abwtg.
        WHEN '03'.
          ls_out-ay3 = ls_out-ay3   + p2001-abwtg.
        WHEN '04'.
          ls_out-ay4 = ls_out-ay4   + p2001-abwtg.
        WHEN '05'.
          ls_out-ay5 = ls_out-ay5   + p2001-abwtg.
        WHEN '06'.
          ls_out-ay6 = ls_out-ay6   + p2001-abwtg.
        WHEN '07'.
          ls_out-ay7 = ls_out-ay7   + p2001-abwtg.
        WHEN '08'.
          ls_out-ay8 = ls_out-ay8   + p2001-abwtg.
        WHEN '09'.
          ls_out-ay9 = ls_out-ay9   + p2001-abwtg.
        WHEN '10'.
          ls_out-ay10 = ls_out-ay10 + p2001-abwtg.
        WHEN '11'.
          ls_out-ay11 = ls_out-ay11 + p2001-abwtg.
        WHEN '12'.
          ls_out-ay12 = ls_out-ay12 + p2001-abwtg.
        WHEN OTHERS.
          CLEAR p2001.
      ENDCASE.
    ENDLOOP.

    ls_out-abwtg = ls_out-ay1 + ls_out-ay2 + ls_out-ay3 + ls_out-ay4  + ls_out-ay5  + ls_out-ay6 +
                   ls_out-ay7 + ls_out-ay8 + ls_out-ay9 + ls_out-ay10 + ls_out-ay11 + ls_out-ay12.

    DATA : lv_odeme TYPE ptm_qsettled.

    LOOP AT p0416 INTO DATA(ls_416) WHERE subty EQ '1000'.
      lv_odeme = lv_odeme + ls_416-numbr.
    ENDLOOP.

    ls_out-bakiye = ls_out-anzhl - ls_out-abwtg - lv_odeme.
    go_report->read_payroll( ).
    ls_out-betpe = ( ( gv_betpe *  100000 ) / 30 ) /  100000 .
    ls_out-yuk = ls_out-bakiye * ls_out-betpe.
    ls_out-sayi = 1.

    CALL FUNCTION 'HRPAD_GET_LAST_DAY_OF_MONTH'
      EXPORTING
        iv_date     = lv_fdate
      IMPORTING
        ev_last_day = lv_ldate.

    IF lv_fdate IS INITIAL.
      APPEND ls_out TO gt_out.
    ELSE.
      IF lv_fdate NE lv_ldate.
        IF lv_fdate GT s_date-low.
          APPEND ls_out TO gt_out.
        ENDIF.
      ELSE.
        IF lv_fdate GT s_date-low.
          APPEND ls_out TO gt_out.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR : ls_out,   ls_t549t, ls_t001p,
            ls_t513s, ls_cskt,  gv_betpe.

  ENDMETHOD.
  METHOD read_payroll.

    DATA: result TYPE pay99_result,
          wa_rt  TYPE pc207.

    DATA: in_rgdir TYPE TABLE OF  pc261,
          gs_rgdir TYPE pc261.

    CALL FUNCTION 'CU_READ_RGDIR'
      EXPORTING
        persnr          = pernr-pernr
      TABLES
        in_rgdir        = in_rgdir
      EXCEPTIONS
        no_record_found = 1
        OTHERS          = 2.


    READ TABLE in_rgdir INTO gs_rgdir WITH KEY fpper = s_date-low(6).
    IF sy-subrc IS INITIAL.

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

      LOOP AT result-inter-rt INTO wa_rt.
        CASE wa_rt-lgart.
*          WHEN '9100'.
          WHEN '1100'.
            ADD  wa_rt-betrg TO gv_betpe.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

    ELSEIF sy-subrc IS NOT INITIAL.

      SORT in_rgdir DESCENDING BY fpper.
      READ TABLE in_rgdir INTO gs_rgdir INDEX 1.
      IF sy-subrc = 0.

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

        LOOP AT result-inter-rt INTO wa_rt.
          CASE wa_rt-lgart.
*            WHEN '9100'.
            WHEN '1100'.
              ADD  wa_rt-betrg TO gv_betpe.
            WHEN OTHERS.
          ENDCASE.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.
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
  METHOD set_alv_properties.

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
*    SET HANDLER go_report->on_user_command FOR gr_events.

* Set Column Texts.
    me->set_column_text( i_fname = 'ANZHL'      i_text = s_date-low(4) && TEXT-h04 ).
    me->set_column_text( i_fname = 'AY1'        i_text = TEXT-h05 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY2'        i_text = TEXT-h06 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY3'        i_text = TEXT-h07 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY4'        i_text = TEXT-h08 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY5'        i_text = TEXT-h09 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY6'        i_text = TEXT-h10 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY7'        i_text = TEXT-h11 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY8'        i_text = TEXT-h12 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY9'        i_text = TEXT-h13 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY10'       i_text = TEXT-h14 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY11'       i_text = TEXT-h15 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'AY12'       i_text = TEXT-h16 && s_date-low+2(2) ).
    me->set_column_text( i_fname = 'ABWTG'      i_text = s_date-low(4) && TEXT-h17   ).
    me->set_column_text( i_fname = 'SAPDATE'    i_text = TEXT-h18   ).
    me->set_column_text( i_fname = 'SAYI'    i_text = 'Kişi Sayısı'   ).
*Hide columns.
*    gr_column ?= gr_columns->get_column( 'T_COLOR' ).
*    gr_column->set_visible( if_salv_c_bool_sap=>false ).

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

ENDCLASS.               "gr_report
