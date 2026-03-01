*&---------------------------------------------------------------------*
*& Include          ZBYHR_P021_I001
*&---------------------------------------------------------------------*

TABLES : pernr, pa0000, pa0001.

CLASS lcl_report DEFINITION DEFERRED.
DATA : gr_report TYPE REF TO lcl_report.


*DATA : gs_data   TYPE zrequest1,
*       gs_auth   TYPE zauth1,
*       gs_input  TYPE  zISAMPLE_SERVICE_PUANTAJ_WCF_2,
*       gs_output TYPE  zISAMPLE_SERVICE_PUANTAJ_WCF_1.

DATA : gt_alv TYPE TABLE OF zbyhr_s006,
       gs_alv TYPE zbyhr_s006,
       gt_00  TYPE TABLE OF pa0000,
       gt_2010 TYPE TABLE OF pa2010.
