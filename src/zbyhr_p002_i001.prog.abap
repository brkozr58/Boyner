*&---------------------------------------------------------------------*
*& Include          ZBYHR_P002_I001
*&---------------------------------------------------------------------*

TABLES: pernr , " HR ana verileri raporlaması için standart seçimler
        pcl1  ,                                         " HR küme 1
        pcl2  ,                                         " HR küme 2
        t512t , " Ücret ve maaş türleri metni
        s001  ,
        t500l ,
        t500p ,
        t001p ,
        sscrfields ,
        cskt.


*----------------------------------------------------------------------
*     Info Types
*----------------------------------------------------------------------
INFOTYPES: 0000 ,
           0001 ,
           0002 ,
           0027 ,
           0769 ,
           0008 .

*----------------------------------------------------------------------
*     Data Definition for Period
*----------------------------------------------------------------------
DATA : BEGIN OF period OCCURS 0,
         fpper LIKE   s001-spmon,
         begda LIKE   p0001-begda,
         endda LIKE   p0001-begda,
       END OF period.


DATA : BEGIN OF gt_rt OCCURS 0,
         table TYPE char10.
         INCLUDE TYPE pc207  .
DATA : END OF  gt_rt.
*----------------------------------------------------------------------
*     Data Definition for FIELD CHOICE
*----------------------------------------------------------------------
DATA : gt003 LIKE zbyhr_t012 OCCURS 0 WITH HEADER LINE,
       gt004 LIKE zbyhr_t013 OCCURS 0 WITH HEADER LINE,
       gt005 LIKE zbyhr_t014 OCCURS 0 WITH HEADER LINE,
       gt006 LIKE zbyhr_t015 OCCURS 0 WITH HEADER LINE,
       t009  LIKE zbyhr_t016 OCCURS 0 WITH HEADER LINE.
*----------------------------------------------------------------------
*     RANGES
*----------------------------------------------------------------------
RANGES : r_slga  FOR zbyhr_t014-slga.

*----------------------------------------------------------------------
*     TABLE and DATA DEFINITON FOR WAGE TYPES
*----------------------------------------------------------------------
DATA : gv_molga TYPE t500l-molga VALUE '47',
       gv_spras TYPE t512t-sprsl VALUE 'TR'.

DATA: BEGIN OF gt_t512t OCCURS 0,
        sprsl TYPE t512t-sprsl,
        molga TYPE t512t-molga,
        lgart TYPE t512t-lgart,
        lgtxt TYPE t512t-lgtxt,
      END OF gt_t512t.
*----------------------------------------------------------------------
*     HEADER TEXT
*----------------------------------------------------------------------
* Ana Basliklar
DATA : anagr_01 TYPE char20,
       anagr_02 TYPE char20,
       anagr_03 TYPE char20,
       anagr_04 TYPE char20,
       anagr_05 TYPE char20,
       anagr_07 TYPE char20.


DATA : toplam_net LIKE pc207-betrg,
       tahsil_edl LIKE pc207-betrg.

DATA : gv_tabix TYPE sy-tabix.
*----------------------------------------------------------------------
*     MACROS
*----------------------------------------------------------------------
* Intensified macro
DEFINE change_intensified.
  IF int IS INITIAL.
    FORMAT INTENSIFIED OFF COLOR = 2 . int = 'X'.
  ELSE.
    FORMAT INTENSIFIED ON  COLOR = 2 . int = ' '.
  ENDIF.
END-OF-DEFINITION.
