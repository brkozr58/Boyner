*&---------------------------------------------------------------------*
*& REPORT ZBYHR_P004
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p004.

*TABLES : zbyhr_t024.
INCLUDE zbyhr_p004_i001.
INCLUDE zbyhr_p004_i002.

INITIALIZATION .
  CREATE OBJECT go_report.

*  CLEAR zbyhr_t024.
*  SELECT SINGLE * FROM zbyhr_t024 WHERE uname EQ sy-uname .


  go_report->set_init( ).

AT SELECTION-SCREEN.
  go_report->at_selection_screen( ).

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname .

  go_report->set_sel_screen( ).

START-OF-SELECTION.

  go_report->set_data( ).

END-OF-SELECTION.
  go_report->prepare_alv( IMPORTING tables = gv_alv ).
