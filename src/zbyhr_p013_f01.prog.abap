*&---------------------------------------------------------------------*
*& Include          ZBYHR_P013_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA : lt_t596v TYPE TABLE OF t569v,
         ls_linev TYPE  t569v,
         lv_datum TYPE datum,
         lt_t569u TYPE TABLE OF t569u,
         ls_t569u TYPE t569u.

  CLEAR: lt_t596v, ls_linev, lv_datum.

  SELECT * FROM t569v INTO TABLE lt_t596v
                      WHERE abkrs EQ p_abkrs .

  LOOP AT lt_t596v INTO ls_linev.

    IF p_relas EQ 'X'.
      ls_linev-state = '1'.
    ELSEIF p_corre EQ 'X'.
      ls_linev-state = '2'.
    ELSEIF p_exit EQ 'X'.
      ls_linev-state = '3'.
      CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
        EXPORTING
          date      = p_datum
          days      = 0
          months    = 1
          signum    = '+'
          years     = 0
        IMPORTING
          calc_date = lv_datum.
    ENDIF.
    ls_linev-pabrj = p_datum+0(4).
    ls_linev-uabrj = p_datum+0(4).
    ls_linev-pabrp = p_datum+4(2).
    IF p_exit NE 'X'.
      ls_linev-uabrp = p_datum+4(2).
    ELSE.
      ls_linev-uabrp = lv_datum+4(2).
    ENDIF.
    MODIFY t569v FROM ls_linev.
    COMMIT WORK.
    IF sy-subrc EQ 0.
      WRITE :/ ls_linev-abkrs , ls_linev-pabrj , ls_linev-pabrp , ' -> Statü değiştirildi.'.

      SELECT  * FROM t569u  UP TO 1 ROWS
       INTO TABLE  lt_t569u
       WHERE abkrs EQ p_abkrs
*          AND
*              pabrj EQ ls_linev-pabrj AND
*              pabrp EQ ls_linev-pabrp
     ORDER BY aedat ASCENDING uzeit ASCENDING.

      LOOP AT lt_t569u INTO ls_t569u.

        ls_t569u-abkrs = ls_linev-abkrs.
        ls_t569u-vwsaz = '1'.
        ls_t569u-uname = sy-uname.
        ls_t569u-pabrj = ls_linev-pabrj.
        ls_t569u-pabrp = ls_linev-pabrp.
        ls_t569u-state = ls_linev-state.
        CONVERT DATE sy-datum INTO INVERTED-DATE ls_t569u-aedat.
        CONVERT DATE sy-uzeit INTO INVERTED-DATE ls_t569u-uzeit.
        ls_t569u-srtfd = '1'.

        MODIFY t569u FROM ls_t569u.
        COMMIT WORK.

      ENDLOOP.

    ENDIF.

  ENDLOOP.

ENDFORM.
