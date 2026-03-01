*&---------------------------------------------------------------------*
*& Report ZBYHR_P013                                                   *
*& SAP Counsultant : Emre Can Küçüksarı                                *
*&---------------------------------------------------------------------*
*&  Module       : HCM - HUMAN CAPITAL MANAGEMENT                      *
*&  Title        : HR: Bordro Alt Birim Düzenleme Ekranı               *
*&  Date         : 29.09.2025                                          *
*&  Version      : 1.0                                                 *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT ZBYHR_P013.

INCLUDE ZBYHR_P013_top.
INCLUDE ZBYHR_P013_f01.

INITIALIZATION.
  PERFORM init.
*&---------------------------------------------------------------------*
*&      Form  INIT
*&---------------------------------------------------------------------*
FORM init .

  DATA: lt_t569v TYPE TABLE OF t569v,
        ls_t569v TYPE t569v,
        lv_statu TYPE char15.

  CLEAR: lv_statu, lt_t569v, ls_t569v.

  SELECT * FROM t569v INTO TABLE lt_t569v.

  LOOP AT lt_t569v INTO ls_t569v.
    IF ls_t569v-state EQ '1'."release
      lv_statu = 'Canlı Bordro'.
    ELSEIF ls_t569v-state EQ '2'."correct
      lv_statu = 'Ana Veri Düzeltme'.
    ELSEIF ls_t569v-state EQ '3'."exit
      lv_statu = 'Bordrodan Çıkış'.
    ENDIF.

    IF ls_t569v-abkrs EQ '01'.
      CONCATENATE '01 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk01 SEPARATED BY space.
    ELSEIF ls_t569v-abkrs EQ '05'.
      CONCATENATE '05 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk02 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '08'.
      CONCATENATE '08 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk03 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '09'.
      CONCATENATE '09 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk04 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '17'.
      CONCATENATE '17 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk05 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '19'.
      CONCATENATE '19 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk06 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '51'.
      CONCATENATE '51 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk07 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '52'.
      CONCATENATE '52 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk08 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '53'.
      CONCATENATE '53 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk09 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '54'.
      CONCATENATE '54 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk10 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '57'.
      CONCATENATE '57 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk11 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '75'.
      CONCATENATE '75 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk12 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '88'.
      CONCATENATE '88 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk13 SEPARATED BY space.
        ELSEIF ls_t569v-abkrs EQ '15'.
"      CONCATENATE '15 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk15 SEPARATED BY space.
"        ELSEIF ls_t569v-abkrs EQ '16'.
"      CONCATENATE '16 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk16 SEPARATED BY space.
"        ELSEIF ls_t569v-abkrs EQ '17'.
"      CONCATENATE '17 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk17 SEPARATED BY space.
"        ELSEIF ls_t569v-abkrs EQ '18'.
"      CONCATENATE '18 BAB. için'  ls_t569v-uabrp ls_t569v-uabrj 'Dönemi' lv_statu 'Statüsünde' INTO lv_abk18 SEPARATED BY space.
    ENDIF.
  ENDLOOP.

ENDFORM.

START-OF-SELECTION .
  PERFORM get_data .
