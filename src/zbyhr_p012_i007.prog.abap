*----------------------------------------------------------------------*
***INCLUDE ZBYHR_P012_I007.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form write_to_screen2
*&---------------------------------------------------------------------*
FORM write_to_screen2 .

  DATA fcode TYPE TABLE OF sy-ucomm.
*      fcode = VALUE #(
*    ( '&ZEXC' )   ).
  SET PF-STATUS 'STATUS_02' EXCLUDING fcode .
*  SORT GT_KOSTL ASCENDING BY KOSTL.
  DELETE gt_kostl WHERE val01 EQ space.
  SORT gt_kostl ASCENDING BY val01 val02 .

  SORT : hd01 ASCENDING BY val01 val02,
         hd02 ASCENDING BY val01 val02,
         hd03 ASCENDING BY val01 val02,
         hd04 ASCENDING BY val01 val02,
         hd05 ASCENDING BY val01 val02,
         hd06 ASCENDING BY val01 val02.

  gt_w[] = w[].

  LOOP AT gt_kostl.

    READ TABLE sub_t WITH KEY val01 = gt_kostl-val01
                              val02 = gt_kostl-val02
                            .
    PERFORM heading_write_end.
    WRITE : /(197) sy-uline.
    PERFORM heading_write_03_end.
    PERFORM group_of_end   .
    NEW-PAGE.
  ENDLOOP.

ENDFORM.                    " WRITE_TO_SCREEN
*&---------------------------------------------------------------------*
*&      FORM  HEADING_WRITE_end
*&---------------------------------------------------------------------*
FORM heading_write_end.
  DATA : gv_fpper1 TYPE char7.
  DATA : gv_fpper2 TYPE char7.
*  DATA : lv_btext(250) TYPE c.
  DATA : lv_btext1(250) TYPE c.
  DATA : lv_btext2(250) TYPE c.
  DATA : lv_donem(250) TYPE c.

  IF gt_kostl-val01 IS NOT INITIAL .
    CONCATENATE gt_kostl-val01 gt_kostl-txt01 INTO lv_btext1 SEPARATED BY space.
  ENDIF.
  IF gt_kostl-val02 IS NOT INITIAL .
    CONCATENATE gt_kostl-val02 gt_kostl-txt02 INTO lv_btext2 SEPARATED BY space.
  ENDIF.

  CLEAR : gv_fpper1 , gv_fpper2.
  IF s_fpper-high IS INITIAL.
    s_fpper-high = s_fpper-low.
  ENDIF.
  gv_fpper1 = s_fpper-low+4(2)  && '.' && s_fpper-low(4).
  gv_fpper2 = s_fpper-high+4(2) && '.' && s_fpper-high(4).

  CLEAR : lv_donem.
  WRITE : /(197) sy-uline.

  FORMAT COLOR COL_GROUP INTENSIFIED ON.
  CONCATENATE gv_fpper1 '-' gv_fpper2 TEXT-005 INTO lv_donem SEPARATED BY space.

  WRITE :   / sy-vline NO-GAP,
            2 lv_btext1          NO-GAP,
            45 sy-vline          NO-GAP,
            66 lv_donem          NO-GAP,
           135 sy-vline          NO-GAP,
           150 TEXT-042          NO-GAP,
           147 sy-datum          NO-GAP,
           160 TEXT-043          NO-GAP,
           167 sy-uzeit          NO-GAP,
           197 sy-vline          NO-GAP.


  FORMAT COLOR OFF.

  FORMAT COLOR COL_GROUP INTENSIFIED ON.

  WRITE :   /
                    sy-vline NO-GAP,
                  2
                  lv_btext2          NO-GAP,
                  45 sy-vline          NO-GAP,
                  66 space            NO-GAP,
                 135 sy-vline          NO-GAP,
                 150 space          NO-GAP,
                 147 space          NO-GAP,
                 156 TEXT-035          NO-GAP,
                 167 sy-pagno          NO-GAP,
                 197 sy-vline          NO-GAP.
  FORMAT COLOR OFF.


ENDFORM.                    " HEADING_WRITE_end
*&---------------------------------------------------------------------*
*&      FORM  heading_write_03_end
*&---------------------------------------------------------------------*
FORM heading_write_03_end.

  DATA : gv_space TYPE numc5  .


  CLEAR: hd01, hd02, hd03, hd04, hd05.

  READ TABLE hd01 WITH KEY val01 = gt_kostl-val01
                           val02 = gt_kostl-val02 BINARY SEARCH.
  READ TABLE hd02 WITH KEY val01 = gt_kostl-val01
                           val02 = gt_kostl-val02 BINARY SEARCH.
  READ TABLE hd03 WITH KEY val01 = gt_kostl-val01
                           val02 = gt_kostl-val02 BINARY SEARCH.
  READ TABLE hd04 WITH KEY val01 = gt_kostl-val01
                           val02 = gt_kostl-val02 BINARY SEARCH.
  READ TABLE hd05 WITH KEY val01 = gt_kostl-val01
                           val02 = gt_kostl-val02 BINARY SEARCH..

  FORMAT COLOR COL_GROUP INTENSIFIED ON.

  WRITE :   /
  sy-vline NO-GAP,                2 TEXT-006 NO-GAP,
                                 27 hd01-say_01 NO-GAP,
                                 45 sy-vline    NO-GAP,
                                 46 TEXT-070    NO-GAP,
                                 71 hd03-say_01 NO-GAP,
                                 89 sy-vline    NO-GAP,
                                 90 TEXT-071    NO-GAP,
                                115 hd03-say_04 NO-GAP,
                                135 sy-vline    NO-GAP,
*                                136 TEXT-082    NO-GAP,
*                                159 hd04-say_01 NO-GAP,
                                136 TEXT-083    NO-GAP,
                                159 hd04-say_04 NO-GAP,
                                197 sy-vline    NO-GAP.
  WRITE :   /
  sy-vline NO-GAP,                2 space       NO-GAP,
                                 27 space       NO-GAP,
                                 45 sy-vline    NO-GAP,
                                 46 space       NO-GAP,
                                 71 space       NO-GAP,
                                 89 sy-vline    NO-GAP,
                                 90 space       NO-GAP,
                                115 space       NO-GAP,
                                135 sy-vline    NO-GAP,
                                136 space       NO-GAP,
                                159 space       NO-GAP,
                                197 sy-vline    NO-GAP.

  FORMAT COLOR OFF.

  WRITE : /(197) sy-uline.

ENDFORM.                    " HEADING_WRITE_03_N
*&---------------------------------------------------------------------*
*& Form group_of_end
*&---------------------------------------------------------------------*
FORM group_of_end .

* YAN CIZGILERDE KESILMELERIN ÖNLENMESI
  DATA: a01      TYPE c,
        a02      TYPE c,
        a03      TYPE c,
        a04      TYPE c,
        a05      TYPE c,
        a06      TYPE c,
        a07      TYPE c,
        a08      TYPE c,
        lv_exit  TYPE c,

* TUTARLARIN YAZDIRILMASI
        kisi     TYPE char4,
        gun      TYPE char9,
        saat     TYPE char10,
        tutar    TYPE char15,
        matrah   TYPE char15,

        lv_kest  TYPE i,
        lv_isml  TYPE i,
        lv_vergi TYPE i,
        lv_asgr  TYPE i,
        v_matrh  TYPE i,
        v_odnen  TYPE i,
        lv_tabix TYPE sy-tabix,

        lt_t013  TYPE TABLE OF zbyhr_t013 WITH HEADER LINE,
        ls_t013  TYPE zbyhr_t013,
        lv_lgtxt TYPE text40.

  DEFINE write_list .
    LOOP AT w
        WHERE val01 EQ gt_kostl-val01
          AND val02 EQ gt_kostl-val02
          AND anagr EQ &1 .
      lv_tabix = sy-tabix.
      IF w-count IS  NOT INITIAL.
        kisi  = w-count.
      ELSE.
        CLEAR : kisi.
      ENDIF.

      IF w-num   IS  NOT INITIAL.
        gun   = w-num.
*        WRITE w-num TO gun.
      ELSE.
        CLEAR : gun.
      ENDIF.

      IF w-saat  IS  NOT INITIAL.
        saat   = w-saat.
*        WRITE w-saat TO saat.
      ELSE.
        CLEAR : saat.
      ENDIF.

      IF w-amt   IS  NOT INITIAL.
        WRITE w-amt TO tutar.
      ELSE.
        CLEAR : tutar.
      ENDIF.

      IF w-mat IS   NOT INITIAL.
        WRITE w-mat TO matrah .
      ELSE.
        CLEAR matrah.
      ENDIF.

      SHIFT :
*              kisi   LEFT DELETING LEADING space,
              gun    LEFT DELETING LEADING space,
              saat   LEFT DELETING LEADING space,
              tutar  LEFT DELETING LEADING space,
              matrah LEFT DELETING LEADING space.
      READ TABLE lt_t013 INTO ls_t013
            WITH KEY anagr = w-anagr
                     altgr = w-altgr.
      IF sy-subrc EQ 0 .      " Alt grup tanımı renki bas tutarları yazma
        TRANSLATE ls_t013-descr TO UPPER CASE.
        FORMAT COLOR COL_HEADING INTENSIFIED ON.

*        IF &2 IS NOT INITIAL .
        IF &1  EQ '01' .
          WRITE : sy-vline, &3 ls_t013-descr LEFT-JUSTIFIED NO-GAP.
        ELSE.
          WRITE : &3  ls_t013-descr LEFT-JUSTIFIED NO-GAP.
        ENDIF.
        WRITE :  &9 sy-vline NO-GAP.
        FORMAT COLOR COL_HEADING INTENSIFIED OFF.
        FORMAT COLOR OFF.
        DELETE lt_t013 WHERE anagr = w-anagr
                         AND altgr = w-altgr.
        EXIT.
      ENDIF.

      IF w-slga EQ space.
        CLEAR: kisi, gt004.
        READ TABLE gt004 WITH KEY anagr = w-anagr altgr = w-altgr BINARY SEARCH.
        lv_lgtxt = gt004-descr.
        CONCATENATE lv_lgtxt TEXT-tot INTO lv_lgtxt SEPARATED BY space.
        FORMAT COLOR COL_KEY INTENSIFIED OFF.
      ELSE.
        lv_lgtxt = w-lgtxt.
      ENDIF.

      IF &2  EQ 1  .
        WRITE : sy-vline,  kisi LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF.
      ELSE.
        WRITE : &2 kisi   INTENSIFIED OFF.
      ENDIF.

      IF w-slga EQ space.
        IF &1  EQ '01' .
          WRITE : space  ,  &3  lv_lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF.
        ELSE.
          WRITE : &3  lv_lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF.
        ENDIF.
      ELSE.
        WRITE : &3  w-slga LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF.
        WRITE : &4  lv_lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF.
      ENDIF.


      IF &5 NE 0.
        WRITE : &5  gun   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF .
      ENDIF.

      IF &6 NE 0.
        WRITE &6  saat    RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF .
      ENDIF.

      IF &7 NE 0.
        WRITE &7  matrah   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF.
      ENDIF.

      IF &8 NE 0.
        WRITE &8  tutar   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF.
      ENDIF.

      IF &9 NE 0.
        WRITE &9 sy-vline NO-GAP .
      ENDIF.


      IF w-slga EQ space.
        FORMAT COLOR OFF.
      ENDIF.

      DELETE w INDEX lv_tabix.
      EXIT.
    ENDLOOP.
  END-OF-DEFINITION.

  PERFORM find_header_text.

  SELECT * FROM zbyhr_t013 INTO TABLE lt_t013
        WHERE   ( NOT ( anagr EQ '01' AND altgr EQ '01' )
          AND     NOT ( anagr EQ '02' AND altgr EQ '01' )
          AND     NOT ( anagr EQ '03' AND altgr EQ '01' )
          AND     NOT ( anagr EQ '04' AND altgr EQ '01' )
*          AND     NOT ( anagr EQ '05' AND altgr EQ 'AU' )
        ).
  SORT lt_t013 ASCENDING BY anagr altgr.

  FORMAT COLOR  COL_HEADING  INTENSIFIED ON.

*----
  WRITE : sy-vline NO-GAP,
               TEXT-022  NO-GAP   , " KIŞI
          10   anagr_01           ,
          43   TEXT-023  NO-GAP   ,
          55   TEXT-024  NO-GAP   ,
          71   TEXT-025  NO-GAP   ,
          76   sy-vline  NO-GAP   ,
          77   TEXT-022  NO-GAP   ,
          82   anagr_02           ,
          124  TEXT-044           ,
          140  TEXT-025           ,
          145  sy-vline  NO-GAP   ,
          146  TEXT-022  NO-GAP   ,
          152  anagr_04           ,
          191  TEXT-025           ,
          197  sy-vline  NO-GAP   .

  FORMAT COLOR OFF.

  DO.
    IF lv_exit EQ 'X'.
      EXIT.
    ENDIF.

    CLEAR: kisi, gun, saat, tutar.

**********************************************************************
**********************************************************************
**********************************************************************
    "<<--------İLK BÖLÜM  BEGIN CODE------>>
* Yasal Gelirler
    write_list: '01'
                1      " KIŞI
                10     " Ücret türü
                15     " TANıM
                40     " GÜN
                49     " SAAT
                0      " MATRAH YAZMAMASı IÇIN 0 GÖNDER
                61     " TUTAR
                76     "SY-VLINE
                 .
    IF sy-subrc NE 0 .
      a01 = 'X'.
      WRITE : sy-vline NO-GAP, 76 sy-vline NO-GAP.
    ENDIF.
    "<<--------İLK BÖLÜM  END CODE------>>
**********************************************************************
**********************************************************************
**********************************************************************
    "<<--------ORTA BÖLÜM BEGIN CODE------>>
* Yasal Kesintiler
    write_list '02'
               77       " KIŞI
               82       " Ücret türü
               87       " TANıM
               0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
               0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
               115       " MATRAH
               130      " TUTAR
               145      "SY-VLINE
               .
    IF sy-subrc NE 0 .
      a02 = 'X'.
      ADD 1 TO lv_isml.
      CASE lv_isml.
        WHEN 1.
          FORMAT COLOR COL_HEADING INTENSIFIED ON.
          WRITE : 82  anagr_03 LEFT-JUSTIFIED NO-GAP,
                  145 sy-vline NO-GAP.
          FORMAT COLOR COL_HEADING INTENSIFIED OFF.
          FORMAT COLOR OFF.
        WHEN OTHERS.
* İşveren Maliyeti
          write_list '03'
                      77       " KIŞI
                      82       " Ücret türü
                      87       " TANıM
                      0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
                      0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
                      115      " MATRAH
                      130      " TUTAR
                      145      "SY-VLINE
                        .
          IF sy-subrc NE 0.
            WRITE :145 sy-vline NO-GAP.
            a03 = 'X'.
          ENDIF.
      ENDCASE.
    ENDIF.
    "<<--------ORTA BÖLÜM END CODE------>>
**********************************************************************
**********************************************************************
**********************************************************************
    "<<--------SON KıSıM BEGIN CODE------>>
* Vergi Muafiyetleri
    write_list '04'
               146       " KIŞI
               151      " Ücret türü
               157      " TANıM
               0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
               0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
               0        " MATRAH YAZMAMASı IÇIN 0 GÖNDER
               181      " TUTAR
               197      "SY-VLINE
                 .
    IF sy-subrc NE 0 .
      a04 = 'X'.
      ADD 1 TO lv_asgr.
      CASE lv_asgr.
        WHEN 1.
          FORMAT COLOR COL_HEADING INTENSIFIED ON.
          WRITE : 157  anagr_05 LEFT-JUSTIFIED NO-GAP,
                  197 sy-vline NO-GAP.
          FORMAT COLOR COL_HEADING INTENSIFIED OFF.
          FORMAT COLOR OFF.
        WHEN OTHERS.
* ASGARI/DIĞER ÜCRETLILER
          write_list '05'
                     146       " KIŞI
                     151      " Ücret türü
                     157      " TANıM
                     0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
                     0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
                     0        " MATRAH YAZMAMASı IÇIN 0 GÖNDER
                     181      " TUTAR
                     197      "SY-VLINE
                       .
          IF sy-subrc NE 0 .
            a05 = 'X'.
            ADD 1 TO v_matrh.
* Matrahlar
            write_list '06'
                       146       " KIŞI
                       151      " Ücret türü
                       157      " TANıM
                       0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
                       0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
                       0        " MATRAH YAZMAMASı IÇIN 0 GÖNDER
                       181      " TUTAR
                       197      "SY-VLINE
                         .
            IF sy-subrc NE 0 .
              a06 = 'X'.
* Matrahlar
              write_list '07'
                       146       " KIŞI
                       151      " Ücret türü
                       157      " TANıM
                       0        " GÜN YAZMAMASı IÇIN 0 GÖNDER
                       0        " SAAT YAZMAMASı IÇIN 0 GÖNDER
                       0        " MATRAH YAZMAMASı IÇIN 0 GÖNDER
                       181      " TUTAR
                       197      "SY-VLINE
                           .
              IF sy-subrc NE 0 .
                WRITE :197 sy-vline NO-GAP.
                a07 = 'X'.
                a08 = 'X'.
              ENDIF.
*                  ENDCASE.
            ENDIF.
*            ENDCASE.
          ENDIF.
      ENDCASE.
    ENDIF.
    "<<--------SON KıSıM END CODE------>>
**********************************************************************
**********************************************************************
**********************************************************************


* YAZDIRILACAK TÜM ÜCRET TÜRLERI BITTIYSE CIK
    IF    a01 EQ 'X' AND a02 EQ 'X'
      AND a03 EQ 'X' AND a04 EQ 'X'
      AND a05 EQ 'X' AND a06 EQ 'X'
      AND a07 EQ 'X' AND a08 EQ 'X'  .
      lv_exit = 'X'.
    ELSE.
      NEW-LINE.
    ENDIF.
  ENDDO.

  WRITE : /(197) sy-uline.
  PERFORM  write_sub_total2.
  WRITE : /(197) sy-uline.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form write_sub_total2
*&---------------------------------------------------------------------*
FORM write_sub_total2  .

  DATA : tutar_agi     TYPE char15,
         tutar_agitplm TYPE char15.
  DATA : lv_top03 LIKE total-amt.



  FORMAT COLOR COL_GROUP INTENSIFIED ON.

  " 1.Boş satır
  WRITE :
              sy-vline NO-GAP,
          71  sy-vline NO-GAP ,
          135 sy-vline NO-GAP,
          136 space LEFT-JUSTIFIED NO-GAP ,
          172 space RIGHT-JUSTIFIED NO-GAP  ,
          197 sy-vline NO-GAP.

  "<<--------2.  satır------>>
* TOPLAM BRÜT
  WRITE sub_t-brut TO tutar_s.
  WRITE : sy-vline        NO-GAP,
                TEXT-028 LEFT-JUSTIFIED NO-GAP,
            56  tutar_s  RIGHT-JUSTIFIED NO-GAP,
            71  sy-vline NO-GAP .

* TOPLAM MALİYET
  WRITE sub_t-tmal TO tutar_s.
  WRITE :
          72  TEXT-029 LEFT-JUSTIFIED NO-GAP,
          120 tutar_s RIGHT-JUSTIFIED NO-GAP ,
          135 sy-vline NO-GAP.

* TOPLAM MALİYET TEŞVİKSİZ
  WRITE sy-vline LEFT-JUSTIFIED NO-GAP.
*  WRITE sub_t-tmalt TO tutar_s.
  "<<--------BEGIN CODE------>>
  CLEAR lv_top03.
  LOOP AT total WHERE val01 = w-val01
                  AND val02 = w-val02
                  AND anagr EQ '03'.
    CASE total-altgr.
      WHEN '01'. " İşveren Maliyet toplamı
      WHEN '02'. " Teşvikler toplamı
        total-amt = total-amt * -1.
      WHEN OTHERS.
    ENDCASE.
    ADD total-amt TO lv_top03.
  ENDLOOP.
  WRITE lv_top03 TO tutar_s.
  "<<--------END CODE------>>
  WRITE :  71 sy-vline NO-GAP,
           72  TEXT-902 LEFT-JUSTIFIED NO-GAP,
           120 tutar_s RIGHT-JUSTIFIED NO-GAP ,
           135 sy-vline NO-GAP.

*KESİNTİ GENEL TOPLAMI
  WRITE sub_t-kesg TO tutar_s.
  WRITE : 136 TEXT-032 LEFT-JUSTIFIED NO-GAP ,
          172 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
          197 sy-vline NO-GAP.
  "<<--------END CODE------>>

  "<<--------3. SAtır------>>
  "" FARK """""""""""""""
  READ TABLE col WITH KEY fld01 = w-val01
                          fld02 = w-val02
                          lgart = '/551'.
  IF sy-subrc = 0.
    "  IF NOT FARK_UCRETI551 IS INITIAL.
    WRITE : sy-vline NO-GAP.
    WRITE col-betrg TO tutar_s   .
    WRITE : 136 TEXT-039 LEFT-JUSTIFIED NO-GAP ,
            172 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
            197 sy-vline NO-GAP.
    WRITE : 71 sy-vline NO-GAP  ,135 sy-vline NO-GAP. .
  ENDIF.

  READ TABLE col WITH KEY fld01 = w-val01
                          fld02 = w-val02
                          lgart = '/552'.
  IF sy-subrc = 0.
    "IF NOT FARK_UCRETI552 IS INITIAL.
    WRITE : sy-vline NO-GAP.
    WRITE col-betrg TO tutar_s   .
    WRITE : 136 TEXT-040 LEFT-JUSTIFIED NO-GAP ,
            172 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
            197 sy-vline NO-GAP.
    WRITE : 71 sy-vline NO-GAP  ,135 sy-vline NO-GAP. .
  ENDIF.

  """""""""""""""""""""""

  WRITE :  197 sy-vline NO-GAP.
  "<<--------END CODE------>>

  FORMAT COLOR OFF.
ENDFORM." write_sub_total
