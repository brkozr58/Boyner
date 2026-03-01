*&---------------------------------------------------------------------*
*& Include          ZBYHR_P014_I001
*&---------------------------------------------------------------------*
TABLES: PA9910, PA0000.

PARAMETER: DATE DEFAULT SY-DATUM LIKE P2010-BEGDA,
           ABKRS LIKE P0001-ABKRS.


DATA: MAPNAME LIKE RPTAXXXX-MAP_NAME.
DATA: FNAME(128), FTYPE(3), FSIZE TYPE I.
DATA: TARIH(10),
      W_TARIH LIKE PA0000-BEGDA,
      WW_TARIH(10),
      W_ZZPRF(16).

DATA: BEGIN OF INT_TAB OCCURS 10,
       DER_UYE_NO(06)      ,
       SIR_KODU(06)        ,
       SIR_SIC_NO(10)      ,
       YIL(04)             ,
       AY(02)              ,
       KATKI_PAYI(15)      ,
       BORC_G_ODEME(15)    ,
       DER_YIL_AIDATI(10)  ,
       DER_GIR_AIDATI(10)  ,
       SAN_GIR_AIDATI(10)  ,
       SAP_SICIL_NO(08)    ,
       TOPL_BIRIKIM(15)    ,
       SON_ALINAN_BORC(15) ,
       KALAN_BORC(15)      ,
       WAERS LIKE P0015-WAERS  ,
       NEMA_BIRIKIM(15)    .
DATA : END OF INT_TAB.

DATA: BEGIN OF BDCDATA OCCURS 20.
        INCLUDE STRUCTURE BDCDATA.
DATA: END OF BDCDATA.

* inserted by koksal.
DATA :
    XKATKI_PAYI(15),
    XBORC_G_ODEME(15),
    XDER_YIL_AIDATI(15),
    XDER_GIR_AIDATI(15),
    XSAN_GIR_AIDATI(15),
    XTOPL_BIRIKIM(15),
    XNEMA_BIRIKIM(15),
    XSON_ALINAN_BORC(15),
    XKALAN_BORC(15).
