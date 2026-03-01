*&---------------------------------------------------------------------*
*& Include          ZBYHR_P021_I002
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS : s_pernr FOR pa0001-pernr MATCHCODE OBJECT prem NO INTERVALS.
*                   s_stat2 FOR pa0000-stat2 NO INTERVALS.
*                   s_bukrs FOR pa0001-bukrs NO INTERVALS,
*                   s_abkrs FOR pa0001-abkrs NO INTERVALS,
*                   s_werks FOR pa0001-werks NO INTERVALS,
*                   s_btrtl FOR pa0001-btrtl NO INTERVALS,
*                   s_persg FOR pa0001-persg NO INTERVALS,
*                   s_persk FOR pa0001-persk NO INTERVALS.
*                   s_persk FOR pa0001-persk NO INTERVALS.
*                   s_datum FOR sy-datum OBLIGATORY NO-EXTENSION.
*  PARAMETERS     : cb_cikis  AS CHECKBOX .
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-003.
  SELECT-OPTIONS : s_datum FOR sy-datum OBLIGATORY NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b2.
