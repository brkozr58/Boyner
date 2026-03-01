*&---------------------------------------------------------------------*
*& Include          ZBYHR_P015_I002
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS : s_date FOR sy-datum NO INTERVALS OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b1.
