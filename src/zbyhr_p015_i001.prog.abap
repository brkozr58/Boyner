*&---------------------------------------------------------------------*
*& Include          ZBYHR_P015_I001
*&---------------------------------------------------------------------*
TABLES : pernr.

INFOTYPES : 0000,0001,0002,0770,2001,2006,0416.

CLASS : gr_report DEFINITION DEFERRED.
DATA  : go_report TYPE REF TO gr_report.


DATA : gt_out   TYPE TABLE OF zbyhr_s005.

DATA : gt_t549t TYPE TABLE OF t549t,
       gt_t001p TYPE TABLE OF t001p,
       gt_t513s TYPE TABLE OF t513s,
       gt_cskt  TYPE TABLE OF cskt.

DATA : gv_fyear TYPE sy-datum,
       gv_lyear TYPE sy-datum.

DATA : gv_betpe TYPE betrg.
