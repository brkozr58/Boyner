*&---------------------------------------------------------------------*
*& Include          ZBYHR_P004_I001
*&---------------------------------------------------------------------*


TABLES : pernr      ,
         sscrfields ,
         pcl1       ,
         pcl2       ,
         t511p,
         s001.

CLASS gc_main DEFINITION DEFERRED .
DATA : go_report   TYPE REF TO gc_main.

DATA : gv_gui TYPE sypfkey.
DATA : gv_alv TYPE char10 VALUE 'GT_ALV'.

INFOTYPES: 0000 , 0771.


DATA : BEGIN OF gs_alv ,
         pernr      LIKE pa0771-pernr,
         begda      LIKE pa0771-begda,
         endda      LIKE pa0771-endda,
         mslks      LIKE pa0771-mslks, "Meslek Kodu
         cttyp      LIKE pa0771-cttyp , "Sözleşme türü
         avans(1), "Meslek Kodu
         ikram(1), "Meslek Kodu
         borde0(02)                  , "Kira Yardımı
         borde1(02)                  , "İkramiye
         borde2(02)                  , "Yol Yardımı
         borde3(02)                  , "Enerji Yardımı
         borde4(02)                  , "Aile Yardımı
         borde5(02)                  , "Görev Tazminatı
         borde6(02)                  , "Kasa Tazminatı
         borde7(02)                  , "Bayram İkramiyesi
         borde8(02)                  , "Yılbaşı Kartı
         borde9(02)                  , "Bayram Kartı
         icon(4)    TYPE c,
         durum      TYPE char100,
       END OF gs_alv.
DATA : gt_alv       LIKE TABLE OF gs_alv.

DATA : sc_fc01  TYPE smp_dyntxt.
" dosya adı
DATA : gv_sample_file LIKE rlgrap-filename.

" oluşturulacak örnek dosyanın head kısmı
DATA : BEGIN OF gs_head,
         header(100),                     " Header Data
       END OF gs_head,
       gt_head LIKE TABLE OF gs_head.

" oluşturulacak örnek dosyanın veri kısmı
DATA : BEGIN OF gs_temp, " sample file data
         pernr(8),
         begda(10),
         endda(10),
*         cttyp(2), "Sözleşme Türü
*         sgdp1(1), "Tüm Sigorta Kolları
*         trtsk(1), "Tüm Tercih Kolları
         mslks(8), "Meslek Kodu
         avans(1),
         ikram(1),
         cttyp(2),
         borde0(02), "Kira Yardımı
         borde1(02), "İkramiye
         borde2(02), "Yol Yardımı
         borde3(02), "Enerji Yardımı
         borde4(02), "Aile Yardımı
         borde5(02), "Görev Tazminatı
         borde6(02), "Kasa Tazminatı
         borde7(02), "Bayram İkramiyesi
         borde8(02), "Yılbaşı Kartı
         borde9(02), "Bayram Kartı
       END OF gs_temp .

DATA : gt_temp LIKE TABLE OF gs_temp .


DATA : lt_records       TYPE solix_tab.
DATA : lt_records2      TYPE TABLE OF string,
       lv_headerxstring TYPE xstring,
       lv_filelength    TYPE i.

DATA : lv_fname    TYPE  rlgrap-filename,
       lv_fnam     TYPE string,
       lv_hiredate TYPE p0000-begda,
       lv_firedate TYPE p0000-begda.

DATA : lt_line_split TYPE TABLE OF string.
DATA : ls_line_split1 TYPE string.
DATA : ls_line_split2 TYPE string.
DATA : ls_line_split3 TYPE string.
DATA : ls_line_split4 TYPE string.
DATA : lv_lenght TYPE i.
DATA : lv_lenght2 TYPE i.
DATA : lv_date(10).
DATA : gs_line2(20).
DATA : lv_tut TYPE string.

DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.
FIELD-SYMBOLS : <l_data> TYPE STANDARD TABLE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS : p_fname LIKE rlgrap-filename,
               p_upd   AS CHECKBOX.
  SELECTION-SCREEN SKIP.
  SELECTION-SCREEN : FUNCTION KEY 1.
SELECTION-SCREEN END OF BLOCK b1     .
