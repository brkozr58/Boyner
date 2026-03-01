*&---------------------------------------------------------------------*
*& Include          ZBYHR_P003_I002
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK main WITH FRAME TITLE TEXT-001.
  PARAMETER : p_ins RADIOBUTTON GROUP gr1 DEFAULT 'X'
                                   USER-COMMAND test,
              p_del  RADIOBUTTON GROUP gr1 ,
              p_upd  RADIOBUTTON GROUP gr1 .
SELECTION-SCREEN END OF BLOCK main.

**ekle paramereleri*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
  PARAMETERS : p_file LIKE rlgrap-filename MODIF ID mg1 OBLIGATORY
                                          DEFAULT 'C:\Book1.xlsx'.
  PARAMETERS : p_mode LIKE ctu_params-dismode MODIF ID mg1
                                    DEFAULT 'N' OBLIGATORY .
SELECTION-SCREEN END OF BLOCK b1.
*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME  TITLE TEXT-003.
*  SELECTION-SCREEN PUSHBUTTON 25(60) but1 USER-COMMAND excl
*    MODIF ID mg1.
*SELECTION-SCREEN   END OF BLOCK b2.

**silme parametreleri*
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE TEXT-004 .
  SELECT-OPTIONS: s_pernr FOR pa0001-pernr NO INTERVALS MODIF ID mg2,
                  s_werks FOR pa0001-werks NO INTERVALS MODIF ID mg2,
                  s_btrtl FOR pa0001-btrtl NO INTERVALS MODIF ID mg2,
                  s_persk FOR pa0001-persk NO INTERVALS MODIF ID mg2,
                  s_persg FOR pa0001-persg NO INTERVALS MODIF ID mg2.
  PARAMETERS     : p_begda LIKE pa0001-begda MODIF ID mg2,
                   p_endda LIKE pa0001-endda MODIF ID mg2.
  PARAMETERS: p_aedtm TYPE pa0769-aedtm OBLIGATORY DEFAULT sy-datum
                                                   MODIF ID mg2,
              p_uname TYPE pa0769-uname OBLIGATORY DEFAULT sy-uname
                                                   MODIF ID mg2.
SELECTION-SCREEN END OF BLOCK b3 .
