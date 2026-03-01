*&---------------------------------------------------------------------*
*& Report ZBYHR_P015
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p015.

INCLUDE zbyhr_p015_i001.
INCLUDE zbyhr_p015_i002.
INCLUDE zbyhr_p015_i003.

INITIALIZATION.

  CREATE OBJECT go_report.
  go_report->set_init( ).

AT SELECTION-SCREEN OUTPUT.

  pnpstat2-option = 'EQ'.
  pnpstat2-sign = 'I'.
  pnpstat2-low = '3'.
  APPEND pnpstat2.

START-OF-SELECTION.

  go_report->set_date( ).

  rp_set_data_interval 'P0000' gv_fyear s_date-low .
  rp_set_data_interval 'P0001' gv_fyear s_date-low .
  rp_set_data_interval 'P0002' gv_fyear s_date-low .
  rp_set_data_interval 'P0770' gv_fyear s_date-low .
  rp_set_data_interval 'P2001' gv_fyear s_date-low .
  rp_set_data_interval 'P2006' gv_fyear s_date-low .
  rp_set_data_interval 'P0416' gv_fyear s_date-low .

GET pernr.

  rp_provide_from_last p0000 space gv_fyear s_date-low .
  rp_provide_from_last p0001 space gv_fyear s_date-low .
  rp_provide_from_last p0002 space gv_fyear s_date-low .
  rp_provide_from_last p0770 space gv_fyear s_date-low .
  rp_provide_from_last p2001 space gv_fyear s_date-low .
  rp_provide_from_last p2006 space gv_fyear s_date-low .
  rp_provide_from_last p0416 space gv_fyear s_date-low .

  go_report->get_data( ).

END-OF-SELECTION.

  go_report->prepare_alv( ).
