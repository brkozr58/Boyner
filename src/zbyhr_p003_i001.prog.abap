*&---------------------------------------------------------------------*
*& Include          ZBYHR_P003_I001
*&---------------------------------------------------------------------*


TYPE-POOLS: slis,truxs,ole2.

TABLES: pa0769, pa0001, sscrfields,zbyhr_t024.

INFOTYPES: 0769, 0001.

DATA: bdcdata      LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA: gt_mtab      TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
DATA: it_raw      TYPE truxs_t_text_data,
      gs_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE LINE OF slis_t_fieldcat_alv,
      gv_repid    LIKE sy-repid VALUE sy-repid.

DATA: gv_outer_index    LIKE sy-index,
      gv_sheet_name(15) VALUE 'Sablon',
      gv_line_cntr      TYPE i , "line counter
      h_zl              TYPE ole2_object,
      h_f               TYPE ole2_object,
      gs_excel          TYPE ole2_object,
      gs_wbooklist      TYPE ole2_object,
      gs_application    TYPE ole2_object,
      gs_wbook          TYPE ole2_object,
      gs_activesheet    TYPE ole2_object.

DATA: BEGIN OF gt_excl OCCURS 0 ,
        pernr LIKE p0769-pernr,
        begda LIKE p0769-begda,
        endda LIKE p0769-endda,
        kanun LIKE p0769-kanun,
        sskod LIKE p0769-sskod,
        ssgrp LIKE p0769-ssgrp,
        bkodu LIKE p0769-bkodu,
        sskno LIKE p0769-sskno,
        is_ay LIKE p0769-is_ay,
        asucc LIKE p0769-asucc,
        sptxd LIKE p0769-sptxd,
*        sptxd LIKE p0769-sptxd,
        child LIKE p0769-child,
        disab LIKE p0769-disab,
        glrve LIKE p0769-glrve,


      END OF gt_excl.

CONSTANTS:
  con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
  con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.

DATA: BEGIN OF gt_main OCCURS 0 ,
        pernr LIKE p0769-pernr,
        ename LIKE p0001-ename,
        begda LIKE p0769-begda,
        endda LIKE p0769-begda,
        kanun LIKE p0769-kanun,
        sskod LIKE p0769-sskod,
        is_ay LIKE p0769-is_ay,
        ssgrp LIKE p0769-ssgrp,
        bkodu LIKE p0769-bkodu,
        sskno LIKE p0769-sskno,
        asucc LIKE p0769-asucc,
        sptxd LIKE p0769-sptxd,
        child LIKE p0769-child,
        disab LIKE p0769-disab,
        glrve LIKE p0769-glrve,
        mtext LIKE bapireturn1-message,
        mark         ,
      END OF   gt_main.

DATA: gt_0001 TYPE TABLE OF pa0001 WITH HEADER LINE.
DATA: gt_0769 TYPE TABLE OF pa0769 WITH HEADER LINE.

DATA : return   LIKE  bapireturn1,
       key      LIKE  bapipakey,
       nocommit LIKE  bapi_stand-no_commit.
