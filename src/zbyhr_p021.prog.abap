*&---------------------------------------------------------------------*
*& Report ZBYHR_P021
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBYHR_P021.

INCLUDE ZBYHR_P021_I001.
INCLUDE ZBYHR_P021_I002.
INCLUDE ZBYHR_P021_I003.

INITIALIZATION.

AT SELECTION-SCREEN.
  IF s_datum-low IS INITIAL OR s_datum-high IS INITIAL.
    MESSAGE 'Tarih Aralığı Giriniz!' TYPE 'E'.
  ENDIF.

  CREATE OBJECT gr_report.

START-OF-SELECTION.

  IF s_datum-high IS INITIAL.
    s_datum-high = s_datum-low.
  ENDIF.

  gr_report->get_data( ).

END-OF-SELECTION.

  gr_report->prepare_alv( ).
