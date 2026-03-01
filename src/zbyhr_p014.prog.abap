*&---------------------------------------------------------------------*
*& Report ZBYHR_P014
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p014.

INCLUDE zbyhr_p014_i001.
INCLUDE zbyhr_p014_i002.

START-OF-SELECTION.

  PERFORM get_data.

END-OF-SELECTION.

AT LINE-SELECTION.

  CALL TRANSACTION 'SM35' AND SKIP FIRST SCREEN.
  FORMAT HOTSPOT ON. CALL TRANSACTION 'SM37' AND SKIP FIRST SCREEN.
