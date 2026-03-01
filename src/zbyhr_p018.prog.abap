*&---------------------------------------------------------------------*
*& Report ZBYHR_P018
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p018.

TYPE-POOLS : slis .
TYPE-POOLS : slis .
CLASS : gr_report DEFINITION DEFERRED.


* Tables
TABLES : pernr   ,
         pcl1   ,
         pcl2   ,
         zbyhr_t001   ,
         zbyhr_t002   ,
         t512t  ,
         t001.


*INFOTYPES
INFOTYPES : 0000 ,
            0001 ,
            0014 ,
            0015 ,
            0002 ,
            0009 ,
            0770 ,
            0772 .

TYPES: BEGIN OF ty_s_clipdata,
         data TYPE c LENGTH 1000,
       END   OF ty_s_clipdata.

TYPES: ty_t_clipdata TYPE TABLE OF ty_s_clipdata.

DATA : gt_t001 TYPE TABLE OF zbyhr_t001 .
DATA : gt_t002 TYPE TABLE OF zbyhr_t002 .
DATA : gt_izah TYPE TABLE OF dd07t .


DATA : BEGIN OF gt_filter OCCURS 0 ,
         bukrs LIKE p0001-bukrs,
         werks LIKE p0001-werks,
         btrtl LIKE p0001-btrtl,
       END OF gt_filter .


DATA: ld_filename TYPE string,
      ld_path     TYPE string,
      ld_fullpath TYPE string,
      ld_result   TYPE i,
      l_filename  TYPE string.
* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-bl1     .
  PARAMETERS : p_pdate LIKE pa0015-begda OBLIGATORY,
               p_lgart LIKE p0015-lgart OBLIGATORY DEFAULT '/559',
               p_odtip TYPE zhrby_odtip OBLIGATORY DEFAULT 'M',
               r_brd   RADIOBUTTON GROUP rad1 DEFAULT 'X',
               r_eko   RADIOBUTTON GROUP rad1,
               p_iban  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF  BLOCK b1.

INCLUDE zbyhr_p018_001.



INITIALIZATION .
  CREATE OBJECT go_report.
  go_report->set_init( ).


AT SELECTION-SCREEN OUTPUT.
  PERFORM selection-screen_output.

START-OF-SELECTION  .
  go_report->set_date( ).

GET pernr           .
  go_report->get_data( ).

END-OF-SELECTION .
  SORT gt_filter ASCENDING BY bukrs werks btrtl.
  DELETE ADJACENT DUPLICATES FROM gt_filter.
  go_report->prepare_alv( ).






*&---------------------------------------------------------------------*
*& Form SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM selection-screen_output .

  LOOP AT SCREEN.
    IF screen-name EQ '%_PNPBUKRS_%_APP_%-OPTI_PUSH'.
      screen-output = 0.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ '%_PNPBUKRS_%_APP_%-VALU_PUSH'.
      screen-output = 0.
      screen-input = 0.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

*  LOOP AT SCREEN.
    IF screen-name EQ 'PNPBUKRS-LOW'.
      screen-required = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.
