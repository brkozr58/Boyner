*&---------------------------------------------------------------------*
*& Include          ZBYHR_P021_I003
*&---------------------------------------------------------------------*
CLASS lcl_report DEFINITION.

  PUBLIC SECTION.
    METHODS :
      get_data,
*      data,
      batch,
      prepare_alv,
      display_alv.
*
*
  PROTECTED SECTION.
    DATA : gr_alv       TYPE REF TO cl_salv_table,
           gr_past      TYPE REF TO cl_salv_table,
           gr_display   TYPE REF TO cl_salv_display_settings,
           gr_columns   TYPE REF TO cl_salv_columns_table,
           gr_column    TYPE REF TO cl_salv_column_table,
           gr_functions TYPE REF TO cl_salv_functions_list,
           gr_selection TYPE REF TO  cl_salv_selections,
           gr_layout    TYPE REF TO cl_salv_layout,
           gr_events    TYPE REF TO cl_salv_events_table,
           gr_exp_msg   TYPE REF TO cx_salv_msg.

*
  PRIVATE SECTION.
    METHODS :
      create_alv,
      set_pf_status,
      set_alv_properties,
      set_column_text
        IMPORTING i_fname TYPE lvc_fname
                  i_text  TYPE any.
*
    METHODS : on_user_command
      FOR EVENT added_function OF cl_salv_events
      IMPORTING e_salv_function.

ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
*  METHOD data.
**    SELECT * FROM pa0000 INTO TABLE gt_00
**                          WHERE begda LE @s_datum-high
**                            AND endda GE @s_datum-low.
**                            AND stat2 EQ '3'.
*     SELECT * FROM pa0105 INTO TABLE gt_105
*                          WHERE begda LE @s_datum-high
*                            AND endda GE @s_datum-low.
*  ENDMETHOD.
  METHOD get_data.

    TYPES: BEGIN OF ty_request,
             sicilNo   TYPE string,
             baslangic TYPE string,
             bitis     TYPE string,
           END OF ty_request.

    DATA: ls_request TYPE ty_request,
          lv_json    TYPE string.

    DATA: lo_http_client TYPE REF TO if_http_client,
          lv_url         TYPE string,
          lv_response    TYPE string,
          lv_uname       TYPE string VALUE 'TESTUSER',
          lv_username    TYPE string,
          lv_password    TYPE string.
    DATA : lv_saat TYPE string.
    DATA: lt_mapping TYPE /ui2/cl_json=>name_mappings,
          ls_mapping LIKE LINE OF lt_mapping.

    DATA: lv_status TYPE i,
          lv_reason TYPE string.
    DATA lv_len TYPE i.
    DATA lv_son2 TYPE anzhl.
    TYPES: BEGIN OF ty_data,
             txt TYPE string,
           END OF ty_data.

    TYPES: ty_data_tab TYPE STANDARD TABLE OF ty_data WITH EMPTY KEY.

    TYPES: BEGIN OF ty_response,
             data TYPE ty_data_tab,
           END OF ty_response.
    DATA: ls_response TYPE ty_response.
    DATA lv_txt TYPE string.
    ls_mapping-abap = 'sicilNo'.
    ls_mapping-json = 'sicilNo'.

    INSERT ls_mapping INTO TABLE lt_mapping.
    lv_url = 'https://integration-suite-boyner-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/http/meyerGetPuantaj' .

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

    lo_http_client->request->set_method( if_http_request=>co_request_method_get ).

    lo_http_client->request->set_header_field(
      name  = 'Content-Type'
      value = 'application/json'
    ).

    " Basic Auth
    lv_username = 'sb-d2368223-0848-475f-9a23-af554aba692e!b550443|it-rt-integration-suite-boyner-dev!b182722'.
    lv_password = '02189b29-d15c-4c84-9ee0-1bae741de3e7$_N3xcbMxDxXjAh8NZMn7dFxNBcOCccvS7fgEVJxkENM='.
    lo_http_client->authenticate(
      username = lv_username
      password = lv_password
    ).

    CONCATENATE s_datum-low(4) s_datum-low+4(2) s_datum-low+6(2) INTO ls_request-baslangic
                                                                    SEPARATED BY '-'.

    CONCATENATE s_datum-high(4) s_datum-high+4(2) s_datum-high+6(2) INTO ls_request-bitis
                                                                    SEPARATED BY '-'.
    CONCATENATE '00' '00' '00' INTO lv_saat
                                                                    SEPARATED BY ':'.
*    CONCATENATE sy-uzeit(2) sy-uzeit+2(2) sy-uzeit+4(2) INTO lv_saat
*                                                                    SEPARATED BY ':'.

    CONCATENATE ls_request-baslangic lv_saat INTO ls_request-baslangic SEPARATED BY space.
    CONCATENATE '23' '59' '59' INTO lv_saat
                                                                    SEPARATED BY ':'.
    CONCATENATE ls_request-bitis     lv_saat INTO ls_request-bitis     SEPARATED BY space.

    IF s_pernr-low IS INITIAL.
      SELECT pernr FROM pa0000 INTO TABLE @DATA(lt_00)
                                WHERE begda LE @s_datum-high
                                  AND endda GE @s_datum-low
                                  AND stat2 EQ '3'.


      LOOP AT lt_00 INTO DATA(ls_00).

        CLEAR s_pernr.
        s_pernr-sign   = 'I'.
        s_pernr-option = 'EQ'.
        s_pernr-low    = ls_00-pernr.

        APPEND s_pernr TO s_pernr. CLEAR: ls_00.
      ENDLOOP.

    ENDIF.

    SELECT * FROM pa2010 INTO TABLE @gt_2010
                         WHERE pernr IN @s_pernr
                           AND begda LE @s_datum-high
                           AND endda GE @s_datum-low.

    LOOP AT s_pernr INTO DATA(ls_pernr).

*      CONDENSE ls_pernr-low NO-GAPS.
      ls_request-sicilNo   = ls_pernr-low. CLEAR ls_pernr-low.
*      CONDENSE ls_request-sicilNo NO-GAPS.
      " JSON dönüşüm
      /ui2/cl_json=>serialize(
        EXPORTING
          data   = ls_request
          pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          name_mappings = lt_mapping
        RECEIVING
          r_json = lv_json ).

      lo_http_client->request->set_cdata( lv_json ).

      CALL METHOD lo_http_client->send
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          OTHERS                     = 4.

      CALL METHOD lo_http_client->receive
        EXCEPTIONS
          http_communication_failure = 1
          http_invalid_state         = 2
          http_processing_failed     = 3
          OTHERS                     = 4.


      lv_response = lo_http_client->response->get_cdata( ).
      lo_http_client->response->get_status( IMPORTING code = lv_status reason = lv_reason ).

      /ui2/cl_json=>deserialize(
        EXPORTING
       json = lv_response
        CHANGING
       data = ls_response
).

      LOOP AT ls_response-data INTO DATA(ls_data).

        gs_alv-pernr = ls_data-txt+0(8).
        gs_alv-lgart = ls_data-txt+8(4).

        lv_len = strlen( ls_data-txt ).
        lv_len = lv_len - 12.
        REPLACE ALL OCCURRENCES OF ',' IN ls_data-txt WITH '.'.
        gs_alv-anzhl = ls_data-txt+12(lv_len).
*        gs_alv-anzhl = ls_data-txt+17(lv_len).
        APPEND gs_alv TO gt_alv.
      ENDLOOP.

      CLEAR lv_json.
    ENDLOOP.

  ENDMETHOD.

  METHOD create_alv.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = gr_alv
          CHANGING
            t_table      = gt_alv ).
      CATCH
        cx_salv_msg INTO gr_exp_msg.
    ENDTRY.

  ENDMETHOD.

  METHOD set_alv_properties.

    gr_display = gr_alv->get_display_settings( ).
*
** Zebra sytle..
    gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
*
    gr_columns = gr_alv->get_columns( ).
** Set optimize..
    gr_columns->set_optimize( abap_true ).
*
    gr_layout = gr_alv->get_layout( ).
** Set variant..
*    gs_key-report = sy-repid.
*    gr_layout->set_key( gs_key ).
    gr_layout->set_save_restriction( cl_salv_layout=>restrict_none ).
*
** Set selection..
    gr_selection = gr_alv->get_selections( ).
    gr_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    gr_events = gr_alv->get_event( ).

    gr_alv->get_columns( RECEIVING value = gr_columns ).

    gr_display = gr_alv->get_display_settings( ).

*     Zebra sytle..
    gr_display->set_striped_pattern( cl_salv_display_settings=>true ).
    gr_columns = gr_alv->get_columns( ).

    gr_columns->set_optimize( abap_true ).
    gr_layout = gr_alv->get_layout( ).

* Set Selection
    gr_selection = gr_alv->get_selections( ).
    gr_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

    gr_events = gr_alv->get_event( ).

* Set selection..
    gr_selection = gr_alv->get_selections( ).
    gr_selection->set_selection_mode( if_salv_c_selection_mode=>cell ).

* Set ALV EVENTS..
    SET HANDLER gr_report->on_user_command FOR gr_events.

* Set Column Texts.
*    me->set_column_text( i_fname = 'MESSAGE' i_text = TEXT-002 ).
*    me->set_column_text( i_fname = 'ENAME'    i_text = TEXT-003 ).
*    me->set_column_text( i_fname = 'TENME'    i_text = TEXT-004 ).


*    me->set_column_styles( ).

* Hide columns.
    gr_column ?= gr_columns->get_column( 'BEGDA' ).
    gr_column->set_visible( if_salv_c_bool_sap=>false ).
    gr_column ?= gr_columns->get_column( 'ENDDA' ).
    gr_column->set_visible( if_salv_c_bool_sap=>false ).
  ENDMETHOD.
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

  ENDMETHOD.                           "set_alv_properties

  METHOD set_pf_status.

    gr_alv->set_screen_status(
      pfstatus      = 'GUI'
      report        = sy-repid
      set_functions = gr_alv->c_functions_all ).

  ENDMETHOD.

  METHOD prepare_alv.
    me->create_alv( ).
    me->set_pf_status( ).
    me->set_alv_properties( ).
*    me->set_top_of_page( ).
    me->display_alv( ).
  ENDMETHOD.

  METHOD display_alv.
    gr_alv->display( ).
  ENDMETHOD.

  METHOD on_user_command.
    DATA : lt_rows  TYPE         salv_t_row,
           lv_rows  TYPE LINE OF salv_t_row,
           lv_subrc TYPE         sy-subrc.

    CASE  e_salv_function.
      WHEN '&KAYIT'.

        lt_rows = gr_selection->get_selected_rows( ).
        LOOP AT lt_rows INTO lv_rows.
          CLEAR gs_alv.
          READ TABLE gt_alv INTO gs_alv INDEX lv_rows.
          IF sy-subrc IS INITIAL.
            PERFORM delete_2010.
            CLEAR gs_alv.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_rows INTO lv_rows.
          CLEAR gs_alv.
          READ TABLE gt_alv INTO gs_alv INDEX lv_rows.
          IF sy-subrc IS INITIAL.
            gr_report->batch( ).
            MODIFY gt_alv FROM gs_alv INDEX lv_rows TRANSPORTING  message.
            CLEAR gs_alv.
          ENDIF.
        ENDLOOP.
        gr_alv->refresh( ).
    ENDCASE.
  ENDMETHOD.
  METHOD batch.

    DATA : ls_2010 TYPE p2010.
    DATA: ls_mess   TYPE bapireturn1.

    SELECT SINGLE * FROM pa0000
                        INTO @DATA(ls_00)
                        WHERE pernr EQ @gs_alv-pernr
                          AND begda LE @s_datum-high
                          AND endda GE @s_datum-low
                          AND stat2 EQ '0'.

    IF ls_00-endda NE '99991231'.

      IF ls_00-begda IS NOT INITIAL.
        ls_2010-begda = ls_00-begda - 1.
      ELSE.
        ls_2010-begda = s_datum-high.
      ENDIF.

      ls_2010-anzhl = gs_alv-anzhl.
      ls_2010-lgart = gs_alv-lgart.
      ls_2010-pernr = gs_alv-pernr.
      ls_2010-infty = '2010'.


      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = ls_2010-pernr
        IMPORTING
          return = ls_mess.
      IF ls_mess IS INITIAL.
        CALL FUNCTION 'HR_INFOTYPE_OPERATION'
          EXPORTING
            infty         = '2010'
            number        = ls_2010-pernr
            validitybegin = ls_2010-begda
            record        = ls_2010
            operation     = 'INS'
          IMPORTING
            return        = ls_mess.

        IF ls_mess IS INITIAL.
          gs_alv-message = 'Başarılı'.
        ELSE.
          gs_alv-message = ls_mess-message.
        ENDIF.

        CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
          EXPORTING
            number = ls_2010-pernr
          IMPORTING
            return = ls_mess.
      ELSE.
        gs_alv-message = ls_mess-message.
      ENDIF.
    ELSE.
      gs_alv-message = 'Kişi Pasif durumdadır'.
    ENDIF.
*    ENDIF.
    CLEAR : ls_mess,ls_2010.
  ENDMETHOD.
ENDCLASS.
FORM delete_2010.

  LOOP AT gt_2010 INTO DATA(s_2010)
                        WHERE pernr EQ gs_alv-pernr
                        AND   begda LE s_datum-high
                        AND   endda GE s_datum-low.
*                          AND   anzhl EQ gs_alv-anzhl
*                          AND   lgart EQ gs_alv-lgart.
    DELETE pa2010 FROM s_2010.
    COMMIT WORK. CLEAR s_2010.
  ENDLOOP.
ENDFORM.
