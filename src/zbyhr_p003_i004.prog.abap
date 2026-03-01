*&---------------------------------------------------------------------*
*& Include          ZBYHR_P003_I004
*&---------------------------------------------------------------------*


INITIALIZATION.

  SELECTION-SCREEN FUNCTION KEY 1.
  sscrfields-functxt_01 = 'Örnek Excel'.

  CLEAR zbyhr_t024.
  SELECT SINGLE * FROM zbyhr_t024 WHERE uname EQ sy-uname .


*  PERFORM create_icon_for_button.
**********************************************************************
*                          AT SELECTION-SCREEN
**********************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_file.

AT SELECTION-SCREEN .

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
*      PERFORM create_excel.
*      PERFORM fill_header.
      PERFORM example_excell.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'MG1'  AND p_del EQ 'X'.
      screen-active = '0'.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF screen-group1 = 'MG2'  AND ( p_ins EQ 'X'
                                  OR    p_upd EQ 'X' ) .
      .                            .
      screen-active = '0'.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.
  ENDLOOP.

**********************************************************************
*                          START-OF-SELECTION
**********************************************************************
START-OF-SELECTION.
  gv_repid = sy-repid .

  PERFORM create_fieldcat.

  IF p_ins EQ 'X'.
    PERFORM get_main_data.
  ELSEIF p_del EQ 'X'.
    PERFORM get_0769_data.
  ELSEIF p_upd EQ 'X'.
    PERFORM update.
  ENDIF.

  PERFORM display_alv.
