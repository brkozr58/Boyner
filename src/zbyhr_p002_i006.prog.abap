*&---------------------------------------------------------------------*
*& Include          ZBYHR_P002_I006
*&---------------------------------------------------------------------*

FORM write_to_screen .

  SET PF-STATUS 'STATUS_02'  .
*  SORT GT_KOSTL ASCENDING BY KOSTL.
  DELETE gt_kostl WHERE val01 EQ space.
  SORT gt_kostl ASCENDING BY val01 val02 .

  SORT : hd01 ASCENDING BY val01 val02,
         hd02 ASCENDING BY val01 val02,
         hd03 ASCENDING BY val01 val02,
         hd04 ASCENDING BY val01 val02,
         hd05 ASCENDING BY val01 val02,
         hd06 ASCENDING BY val01 val02.

*  PERFORM heading_write_01. " HEADER 1 Dönem


  LOOP AT gt_kostl.

    READ TABLE sub_t WITH KEY val01 = gt_kostl-val01
                              val02 = gt_kostl-val02.
    PERFORM heading_write_02. " HEADER 2 Isletme
    IF pnpkostl[] IS NOT INITIAL.
      PERFORM heading_write_04. " Cost Header
    ENDIF.
    PERFORM heading_write_03. " HEADER 3 Toplam
    PERFORM group_of_head   .
    NEW-PAGE.
  ENDLOOP.

ENDFORM.                    " write_to_screen
*&---------------------------------------------------------------------*
*&      Form  heading_write 01
*&---------------------------------------------------------------------*
FORM heading_write_01.

*  DATA : gv_space TYPE char2.
*
**----
*  IF s_fpper-high IS INITIAL.
*    WRITE :   /60 s_fpper-low CENTERED NO-GAP,
*                  gv_space,
*            (37)  TEXT-005    NO-GAP .
**             150 text-042, ' ' , sy-datum .
*  ELSE.
*    WRITE :   /60 s_fpper-low CENTERED NO-GAP, 68 s_fpper-high
*CENTERED NO-GAP,
*                gv_space,
*          (37)  TEXT-005    NO-GAP.
*  ENDIF.
*  WRITE : /140 TEXT-043, sy-uzeit .
*  WRITE : /140 TEXT-042, sy-datum .
*----
ENDFORM.                    " heading_write_01
*&---------------------------------------------------------------------*
*&      Form  heading_write 02
*&---------------------------------------------------------------------*
FORM heading_write_02.
  DATA : gv_fpper1 TYPE char7.
  DATA : gv_fpper2 TYPE char7.
  DATA : lv_btext(250) TYPE c.
  DATA : lv_donem(250) TYPE c.


  gv_tabix = gv_tabix + 1.
  READ TABLE gt_kostl INTO DATA(ls_kostl) INDEX gv_tabix.
  IF sy-subrc EQ 0.
    lv_btext = ls_kostl-txt02.
  ENDIF.

*
  IF lv_btext IS NOT INITIAL.
    CONCATENATE gt_kostl-txt01 lv_btext INTO lv_btext
    SEPARATED BY space.
    CLEAR ssort .
    READ TABLE ssort INDEX 1 .
  ELSE.
    CLEAR ssort .
    READ TABLE ssort INDEX 1 .
    lv_btext = gt_kostl-txt01.
  ENDIF.


*  SELECT SINGLE sskno FROM t7trg01 INTO @DATA(lv_sskno)
*    WHERE btrtl = @gt_kostl-val01.
*  IF sy-subrc EQ 0 .
*    CONCATENATE lv_sskno '-' lv_btext INTO lv_btext.
*  ENDIF.

  CLEAR : gv_fpper1 , gv_fpper2.
  IF s_fpper-high IS INITIAL.
    s_fpper-high = s_fpper-low.
  ENDIF.
  gv_fpper1 = s_fpper-low+4(2)  && '.' && s_fpper-low(4).
  gv_fpper2 = s_fpper-high+4(2) && '.' && s_fpper-high(4).

  CLEAR : lv_donem.
  WRITE : /(177) sy-uline.

  FORMAT COLOR COL_GROUP INTENSIFIED ON.
  CONCATENATE gv_fpper1 '-' gv_fpper2 TEXT-005
         INTO lv_donem SEPARATED BY space.

  WRITE :   /
  sy-vline NO-GAP, 2 lv_btext          NO-GAP,
                  45 sy-vline          NO-GAP,
                  66 lv_donem          NO-GAP,
                 133 sy-vline          NO-GAP,
                 140 TEXT-042          NO-GAP,
                 147 sy-datum          NO-GAP,
                 160 TEXT-043          NO-GAP,
                 167 sy-uzeit          NO-GAP,
                 177 sy-vline          NO-GAP.
  FORMAT COLOR OFF.

  WRITE : /(177) sy-uline.


ENDFORM.                    " heading_write_01
*&---------------------------------------------------------------------*
*&      Form  heading_write 02
*&---------------------------------------------------------------------*
FORM heading_write_04.


  WRITE: /  TEXT-034 CENTERED NO-GAP, 15 cskt-ltext,
            160 TEXT-035 CENTERED NO-GAP, sy-pagno.
*----

ENDFORM.                    " heading_write_01
*&---------------------------------------------------------------------*
*&      Form  heading_write 03
*&---------------------------------------------------------------------*
FORM heading_write_03.

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
                                133 sy-vline    NO-GAP,
                                134 TEXT-082    NO-GAP,
                                159 hd04-say_01 NO-GAP,
                                177 sy-vline    NO-GAP.

  WRITE :   /
  sy-vline NO-GAP,                2 TEXT-009 NO-GAP,
                                 27 hd02-say_01 NO-GAP,
                                 45 sy-vline    NO-GAP,
                                 46 TEXT-074    NO-GAP,
                                 71 hd03-say_02 NO-GAP,
                                 89 sy-vline    NO-GAP,
                                 90 TEXT-075    NO-GAP,
                                115 hd03-say_05 NO-GAP,
                                133 sy-vline    NO-GAP,
                                134 TEXT-078    NO-GAP,
                                159 hd04-say_02 NO-GAP,
                                177 sy-vline    NO-GAP.

  WRITE :   /
  sy-vline NO-GAP,                2 TEXT-010 NO-GAP,
                                 27 hd02-say_02 NO-GAP,
                                 45 sy-vline    NO-GAP,
                                 46 TEXT-076    NO-GAP,
                                 71 hd03-say_03 NO-GAP,
                                 89 sy-vline    NO-GAP,
                                 90 TEXT-077    NO-GAP,
                                115 hd03-say_06 NO-GAP,
                                133 sy-vline    NO-GAP,
                                134 TEXT-079    NO-GAP,
                                159 hd04-say_03 NO-GAP,
                                177 sy-vline    NO-GAP.

  WRITE :   /
  sy-vline NO-GAP,                2 TEXT-072 NO-GAP,
                                 27 hd05-say_01 NO-GAP,
                                 45 sy-vline    NO-GAP,
                                 46 TEXT-073    NO-GAP,
                                 71 hd05-say_02 NO-GAP,
                                 89 sy-vline    NO-GAP,
                                 90 TEXT-080    NO-GAP,
                                115 hd05-say_03 NO-GAP,
                                133 sy-vline    NO-GAP,
                                134 TEXT-081    NO-GAP,
                                159 hd05-say_04 NO-GAP,
                                177 sy-vline    NO-GAP.

  FORMAT COLOR OFF.

  WRITE : /(177) sy-uline.

ENDFORM.                    " heading_write_01
*&---------------------------------------------------------------------*
*&      Form  heading_write 01
*&---------------------------------------------------------------------*
FORM group_of_head.

  DATA: lv_kest  TYPE i,
        lv_okes  TYPE i,
        lv_okes1 TYPE i,
        kest_top LIKE w-amt,
        lv_tabix TYPE sy-tabix.

* Yan cizgilerde kesilmelerin önlenmesi
  DATA: a01 TYPE c,
        a02 TYPE c,
        a03 TYPE c,
        a04 TYPE c,
        a05 TYPE c,
        a06 TYPE c.

* Tutarlarin yazdirilmasi
  DATA: kisi   TYPE char4,
        gun    TYPE char9,
        saat   TYPE char10,
        tutar  TYPE char15, "selinay 16.05.2025
        matrah TYPE char15.

  PERFORM find_header_text.

  FORMAT COLOR  COL_HEADING  INTENSIFIED ON.

*----
  WRITE : sy-vline NO-GAP,
          TEXT-022  NO-GAP, " Kişi
          10  anagr_01                ,
          38 TEXT-023  NO-GAP,
          50 TEXT-024  NO-GAP,
          66 TEXT-025  NO-GAP,
          71 sy-vline NO-GAP ,
          73  anagr_03                ,
          102  TEXT-044               ,
          118  TEXT-045               ,
          125 sy-vline NO-GAP,
          140 anagr_05                ,
          177 sy-vline NO-GAP.

  FORMAT COLOR OFF.

  DATA : gv_space TYPE numc5 VALUE '123',
         lv_exit  TYPE c.

  DO.

    IF lv_exit EQ 'X'.
      EXIT.
    ENDIF.

    CLEAR: kisi, gun, saat, tutar.

* Kazançlar
    LOOP AT w

        WHERE val01 EQ gt_kostl-val01
          AND val02 EQ gt_kostl-val02
          AND anagr EQ '01' .

      lv_tabix = sy-tabix.

      IF w-count IS  NOT INITIAL.
        kisi  = w-count.
      ELSE.
        CLEAR : kisi.
      ENDIF.
      IF w-num   IS  NOT INITIAL.
        gun   = w-num.
      ELSE.
        CLEAR : gun.
      ENDIF.
      IF w-saat  IS  NOT INITIAL.
        saat  = w-saat.
      ELSE.
        CLEAR : saat.
      ENDIF.
      IF w-amt   IS  NOT INITIAL.
        WRITE w-amt TO tutar.
      ELSE.
        CLEAR : tutar.
      ENDIF.

      SHIFT : kisi  LEFT DELETING LEADING space,
              gun   LEFT DELETING LEADING space,
              saat  LEFT DELETING LEADING space,
              tutar LEFT DELETING LEADING space.

      IF w-slga EQ space.
        CLEAR: kisi, gt004.
        READ TABLE gt004 WITH KEY anagr = w-anagr
                                  altgr = w-altgr BINARY SEARCH.
        w-lgtxt = gt004-descr.
        FORMAT COLOR COL_KEY INTENSIFIED OFF.
      ENDIF.

      WRITE :
      sy-vline NO-GAP, kisi LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
      10  w-lgtxt        LEFT-JUSTIFIED NO-GAP   INTENSIFIED OFF,
      35  gun            RIGHT-JUSTIFIED NO-GAP  INTENSIFIED OFF ,
      44  saat           RIGHT-JUSTIFIED NO-GAP  INTENSIFIED OFF ,
      56  tutar          RIGHT-JUSTIFIED NO-GAP  INTENSIFIED OFF,
      71 sy-vline NO-GAP .

      IF w-slga EQ space.
        FORMAT COLOR OFF.
      ENDIF.

      DELETE w INDEX lv_tabix.
      EXIT.
    ENDLOOP.
    IF sy-subrc NE 0 .
      a01 = 'X'.
      ADD 1 TO lv_okes.
      CLEAR tutar.

      CASE lv_okes.
        WHEN 1.
          FORMAT COLOR COL_HEADING INTENSIFIED ON.
          WRITE : sy-vline NO-GAP,
                  10  anagr_02 ,
                  71 sy-vline NO-GAP.
          FORMAT COLOR COL_HEADING INTENSIFIED OFF. "deneme selinay
          FORMAT COLOR OFF.
        WHEN OTHERS.

* Ek Ödemeler
          LOOP AT w
*                 WHERE KOSTL EQ GT_KOSTL-KOSTL
                  WHERE val01 EQ gt_kostl-val01
                    AND val02 EQ gt_kostl-val02
                    AND anagr EQ '02'.

            lv_tabix = sy-tabix.

            IF w-count IS NOT INITIAL.
              kisi  = w-count.
            ELSE.
              CLEAR : kisi.
            ENDIF.
            IF w-amt   IS  NOT INITIAL.
              WRITE w-amt TO tutar.
            ELSE.
              CLEAR : tutar.
            ENDIF.
            IF w-num   IS  NOT INITIAL.
              gun   = w-num.
            ELSE.
              CLEAR : gun.
            ENDIF.
            IF w-saat  IS  NOT INITIAL.
              saat  = w-saat.
            ELSE.
              CLEAR : saat.
            ENDIF.

            FORMAT COLOR COL_HEADING INTENSIFIED OFF.
            FORMAT COLOR OFF.

            SHIFT : kisi  LEFT DELETING LEADING space,
                    tutar LEFT DELETING LEADING space,
                    gun   LEFT DELETING LEADING space,
                    saat  LEFT DELETING LEADING space.

            IF w-slga EQ space.
              CLEAR: kisi, gt004.
              READ TABLE gt004 WITH KEY anagr = w-anagr
                                        altgr = w-altgr BINARY SEARCH.
              w-lgtxt = gt004-descr.
              FORMAT COLOR COL_KEY INTENSIFIED OFF.
            ENDIF.

            WRITE :
            sy-vline NO-GAP, kisi LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
            10  w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
            35  gun     RIGHT-JUSTIFIED NO-GAP   INTENSIFIED OFF,
            44  saat    RIGHT-JUSTIFIED NO-GAP   INTENSIFIED OFF,
            56  tutar   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
            71 sy-vline NO-GAP .


            IF w-slga EQ space.
              FORMAT COLOR OFF.
            ENDIF.

            DELETE w INDEX lv_tabix.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            WRITE : sy-vline NO-GAP,
                    71 sy-vline NO-GAP.
            a05 = 'X'.
          ENDIF.
      ENDCASE.
    ENDIF.

* Matrah ve Kesintiler
    LOOP AT w
*            WHERE KOSTL EQ GT_KOSTL-KOSTL
             WHERE val01 EQ gt_kostl-val01
               AND val02 EQ gt_kostl-val02
               AND anagr EQ '03'.

      lv_tabix = sy-tabix.
      kisi     = w-count.
      SHIFT : kisi  LEFT DELETING LEADING space.
      IF w-amt   IS  NOT INITIAL.
        WRITE w-amt TO tutar.
      ELSE.
        CLEAR : tutar.
      ENDIF.
      IF w-num IS   NOT INITIAL.
        gun = w-num.
      ELSE.
        CLEAR : gun.
      ENDIF.
      IF w-mat IS   NOT INITIAL.
        WRITE w-mat TO matrah .
      ELSE.
        CLEAR matrah.
      ENDIF.

      CASE w-slga.
        WHEN '/NDY'.  CLEAR tutar.WRITE w-num TO tutar.
      ENDCASE.

      SHIFT : tutar LEFT DELETING LEADING space.
      SHIFT : matrah LEFT DELETING LEADING space.

      IF w-slga EQ space.
        CLEAR: kisi, gt004.
        READ TABLE gt004 WITH KEY anagr = w-anagr
                                  altgr = w-altgr BINARY SEARCH.
        w-lgtxt = gt004-descr.
        FORMAT COLOR COL_KEY INTENSIFIED OFF.
      ENDIF.
*      WRITE : 72  w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
*              95  matrah  RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
*              110 tutar   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
*              125 sy-vline NO-GAP.

      WRITE : 72  kisi INTENSIFIED OFF,
              77  w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
              95  matrah  RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
              110 tutar   RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
              125 sy-vline NO-GAP.

      IF w-slga EQ space.
        FORMAT COLOR OFF.
      ENDIF.

      DELETE w INDEX lv_tabix.
      EXIT.

    ENDLOOP.

    IF sy-subrc NE 0 .

      a02 = 'X'.
      ADD 1 TO lv_kest.
      CLEAR tutar.
      IF kest_top IS NOT INITIAL. WRITE kest_top TO tutar. ENDIF.

      CASE lv_kest.
        WHEN 1.
          FORMAT COLOR COL_HEADING INTENSIFIED ON.
          WRITE : 72  anagr_04 LEFT-JUSTIFIED NO-GAP,
                  125 sy-vline NO-GAP.
          FORMAT COLOR OFF.
        WHEN OTHERS.

* İş Veren Paylari
          LOOP AT w
*            WHERE KOSTL EQ GT_KOSTL-KOSTL
       WHERE val01 EQ gt_kostl-val01
         AND val02 EQ gt_kostl-val02
         AND anagr EQ '04'.

            lv_tabix = sy-tabix.
            kisi     = w-count.
            IF w-amt   IS  NOT INITIAL. WRITE w-amt TO tutar.   ENDIF.
            IF w-mat IS   NOT INITIAL.
              WRITE w-mat TO matrah .
****        MATRAH = W-MAT. "selinay 16.05.2025
            ELSE.
              CLEAR matrah.
            ENDIF.
            SHIFT : tutar LEFT DELETING LEADING space.

            IF w-slga EQ space.
              CLEAR: kisi, gt004.
              READ TABLE gt004 WITH KEY anagr = w-anagr
                                        altgr = w-altgr BINARY SEARCH.
              w-lgtxt = gt004-descr.
              FORMAT COLOR COL_KEY INTENSIFIED OFF.

            ENDIF.
            SHIFT : kisi  LEFT DELETING LEADING space.
            WRITE : 77  w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    95  matrah RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    110 tutar RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    125 sy-vline NO-GAP.

            WRITE : 72  kisi INTENSIFIED OFF,
                    77  w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    95  matrah RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    110 tutar RIGHT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    125 sy-vline NO-GAP.

            IF w-slga EQ space.
              FORMAT COLOR OFF.
            ENDIF.

            DELETE w INDEX lv_tabix.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            WRITE :125 sy-vline NO-GAP. a04 = 'X'.
          ENDIF.
      ENDCASE.

    ENDIF.

* Özel Kesintiler
    LOOP AT w
*      WHERE KOSTL EQ GT_KOSTL-KOSTL
        WHERE val01 EQ gt_kostl-val01
          AND val02 EQ gt_kostl-val02
          AND anagr EQ '05'.

      lv_tabix = sy-tabix.

      kisi  = w-count.
      WRITE w-amt TO tutar.

      SHIFT : kisi  LEFT DELETING LEADING space,
              tutar LEFT DELETING LEADING space.

      IF w-slga EQ space.
        CLEAR: kisi, gt004.
        READ TABLE gt004 WITH KEY anagr = w-anagr
                                  altgr = w-altgr BINARY SEARCH.
        w-lgtxt = gt004-descr.
        FORMAT COLOR COL_KEY INTENSIFIED OFF.
      ENDIF.

      WRITE : 126 kisi INTENSIFIED OFF,
              132 w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
              161 tutar RIGHT-JUSTIFIED NO-GAP  INTENSIFIED OFF,
              177 sy-vline NO-GAP INTENSIFIED OFF.
      FORMAT COLOR OFF.
      IF w-slga EQ space.
        FORMAT COLOR OFF.
      ENDIF.

      DELETE w INDEX lv_tabix.
      EXIT.
    ENDLOOP.

    IF sy-subrc NE 0 .

      a06 = 'X'.
      ADD 1 TO lv_okes1.
      CLEAR tutar.

      CASE lv_okes1.
        WHEN 1.
          FORMAT COLOR COL_HEADING INTENSIFIED ON.
          WRITE :
                  140  anagr_07 ,
                  177 sy-vline NO-GAP.
          FORMAT COLOR OFF.

        WHEN OTHERS.

          "Yeni ana başlık eklendi 16.05.2025 selinay
          "vergi indirimleri

          LOOP AT w

            WHERE val01 EQ gt_kostl-val01
                AND val02 EQ gt_kostl-val02
                AND anagr EQ '07' .


            lv_tabix = sy-tabix.

            kisi  = w-count.
            WRITE w-amt TO tutar.

            SHIFT : kisi  LEFT DELETING LEADING space,
                    tutar LEFT DELETING LEADING space.

            IF w-slga EQ space.
              CLEAR: kisi, gt004.
              READ TABLE gt004 WITH KEY anagr = w-anagr
                                        altgr = w-altgr BINARY SEARCH.
              w-lgtxt = gt004-descr.
              FORMAT COLOR COL_KEY INTENSIFIED OFF.
            ENDIF.

            WRITE : 126 kisi INTENSIFIED OFF,
                    132 w-lgtxt LEFT-JUSTIFIED NO-GAP INTENSIFIED OFF,
                    161 tutar RIGHT-JUSTIFIED NO-GAP  INTENSIFIED OFF,
                    177 sy-vline NO-GAP INTENSIFIED OFF.
            FORMAT COLOR OFF.
            IF w-slga EQ space.
              FORMAT COLOR OFF.
            ENDIF.

            DELETE w INDEX lv_tabix.
            EXIT.
          ENDLOOP.
          IF sy-subrc NE 0.
            WRITE :125 sy-vline NO-GAP. a06 = 'X'.
          ENDIF.
      ENDCASE.
    ENDIF.

    DATA : lv_cnt TYPE i.

    IF sy-subrc NE 0 .

      ADD 1 TO lv_cnt .

      CASE lv_cnt.
        WHEN '1'.

        WHEN '2'.
          WRITE :177 sy-vline NO-GAP.
        WHEN '3'. " GV fark odemesi
          READ TABLE w WITH KEY slga = '9VFO'.
          IF sy-subrc = 0.
            WRITE w-amt TO tutar_s.
            WRITE :
            132 TEXT-036 LEFT-JUSTIFIED NO-GAP ,
            162 tutar_s RIGHT-JUSTIFIED NO-GAP .
          ENDIF.
          WRITE :
          177 sy-vline NO-GAP.
        WHEN OTHERS.
          WRITE :177 sy-vline NO-GAP. a03 = 'X'.
      ENDCASE.
    ENDIF.

* Yazdirilacak tüm ücret türleri bittiyse cik
    IF  a01 EQ 'X' AND a02 EQ 'X'
    AND a03 EQ 'X' AND a04 EQ 'X'
    AND a05 EQ 'X' .
      lv_exit = 'X'.
    ELSE.
      NEW-LINE.
    ENDIF.

  ENDDO.

  PERFORM  write_sub_total.

  WRITE : /(177) sy-uline.

ENDFORM.                    " group_of_head
*&---------------------------------------------------------------------*
*&      Form  FIND_HEADER_TEXT
*&---------------------------------------------------------------------*
FORM find_header_text .

  SORT gt003 ASCENDING BY anagr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '01' BINARY SEARCH.
  anagr_01 = gt003-descr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '02' BINARY SEARCH.
  anagr_02 = gt003-descr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '03' BINARY SEARCH.
  anagr_03 = gt003-descr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '04' BINARY SEARCH.
  anagr_04 = gt003-descr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '05' BINARY SEARCH.
  anagr_05 = gt003-descr.

  CLEAR gt003.
  READ TABLE gt003 WITH KEY anagr = '07' BINARY SEARCH.
  anagr_07 = gt003-descr.

ENDFORM.                    " FIND_HEADER_TEXT
*&---------------------------------------------------------------------*
*&      Form  WRITE_SUB_TOTAL
*&---------------------------------------------------------------------*
FORM write_sub_total .

  DATA : tutar_agi     TYPE char15,
         tutar_agitplm TYPE char15.

  CLEAR hd06 .
  READ TABLE hd06 WITH KEY val01 = w-val01
                           val02 = w-val02 .

  FORMAT COLOR COL_GROUP INTENSIFIED ON.


  WRITE sub_t-kesg TO tutar_s.
  WRITE :
           sy-vline NO-GAP,
        71 sy-vline NO-GAP ,
        125 sy-vline NO-GAP.



  READ TABLE w[] INTO DATA(ls_w) WITH  KEY val01 = w-val01
                                           val02 = w-val02
                                           anagr = '97'
                                           altgr = '97'
                                           slga  = '/AGI'.

  WRITE ls_w-amt TO tutar_agi.


  READ TABLE w[] INTO DATA(ls_wa) WITH  KEY val01 = w-val01
                                         val02 = w-val02
                                         anagr = '99'
                                         altgr = '99'.
*                                         seqno = '250' .

  WRITE ls_wa-amt TO tutar_agitplm.

  "AGI
*WRITE : 72 TEXT-033 LEFT-JUSTIFIED NO-GAP ,
*       108 tutar_agi RIGHT-JUSTIFIED NO-GAP ,
*         125 sy-vline NO-GAP.
* Kesinti genel toplam
  WRITE : 126 TEXT-032 LEFT-JUSTIFIED NO-GAP ,
          162 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
          177 sy-vline NO-GAP.


* TOPLAM BRÜT
  WRITE sub_t-brut TO tutar_s.
  WRITE : sy-vline NO-GAP,
          TEXT-028 LEFT-JUSTIFIED NO-GAP,
            56  tutar_s    RIGHT-JUSTIFIED NO-GAP,
            71 sy-vline NO-GAP .


* TOPLAM MALİYET
  WRITE sub_t-tmal TO tutar_s.
  WRITE :
          72  TEXT-029 LEFT-JUSTIFIED NO-GAP,
          108 tutar_s RIGHT-JUSTIFIED NO-GAP ,
          125 sy-vline NO-GAP.

*  * NET ÖDENECEK
  WRITE : 126 TEXT-030 LEFT-JUSTIFIED NO-GAP ,
*          162 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
          162 tutar_agitplm RIGHT-JUSTIFIED NO-GAP  ,
          177 sy-vline NO-GAP.


* TOPLAM MALİYET TEŞVİKSİZ

  WRITE sy-vline LEFT-JUSTIFIED NO-GAP.
  WRITE sub_t-tmalt TO tutar_s.
  WRITE :  71 sy-vline NO-GAP,
           72  TEXT-902 LEFT-JUSTIFIED NO-GAP,
           108 tutar_s RIGHT-JUSTIFIED NO-GAP ,
           125 sy-vline NO-GAP.

*  WRITE sub_t-neto TO tutar_s.
*  CLEAR hd06 .
*  READ TABLE hd06 WITH KEY val01 = w-val01
*                           val02 = w-val02 .
  WRITE hd06-toplam_net TO tutar_s .

*  WRITE TOPLAM_NET TO TUTAR_S.
* NET ÖDENECEK
*  WRITE : 126 TEXT-030 LEFT-JUSTIFIED NO-GAP ,
*          162 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
*          177 sy-vline NO-GAP.



  "" fark """""""""""""""
  READ TABLE col WITH KEY fld01 = w-val01
                          fld02 = w-val02
                          lgart = '/551'.
  IF sy-subrc = 0.
    "  IF NOT fark_ucreti551 IS INITIAL.
    WRITE : sy-vline NO-GAP.
*    IF p_ort EQ 'X'.
*      col-betrg = col-betrg / ok_ortm."Ortalama Maliyet
*    ENDIF.
    "   WRITE fark_ucreti551 TO tutar_s   .
    WRITE col-betrg TO tutar_s   .
    WRITE : 126 TEXT-039 LEFT-JUSTIFIED NO-GAP ,
            162 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
            177 sy-vline NO-GAP.
    WRITE : 71 sy-vline NO-GAP  ,125 sy-vline NO-GAP. .
  ENDIF.

  READ TABLE col WITH KEY fld01 = w-val01
                          fld02 = w-val02
                          lgart = '/552'.
  IF sy-subrc = 0.
    "IF NOT fark_ucreti552 IS INITIAL.
    WRITE : sy-vline NO-GAP.
*    IF p_ort EQ 'X'.
*      col-betrg = col-betrg / ok_ortm."Ortalama Maliyet
*    ENDIF.
    "    WRITE fark_ucreti552 TO tutar_s   .
    WRITE col-betrg TO tutar_s   .
    WRITE : 126 TEXT-040 LEFT-JUSTIFIED NO-GAP ,
            162 tutar_s RIGHT-JUSTIFIED NO-GAP  ,
            177 sy-vline NO-GAP.
    WRITE : 71 sy-vline NO-GAP  ,125 sy-vline NO-GAP. .
  ENDIF.

  """""""""""""""""""""""

  WRITE :  177 sy-vline NO-GAP.

  FORMAT COLOR OFF.

ENDFORM.                    " WRITE_SUB_TOTAL

*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*& başlangıç değerlerinin set edilmesi
*&---------------------------------------------------------------------*
FORM initialization .
  SELECT * FROM zbyhr_t016 INTO TABLE t009
          WHERE spras EQ sy-langu .
  LOOP AT t009 .
    CHECK NOT ( t009-nam = 'P-SETNA' OR
                t009-nam = 'P-PERNR' ).
    MOVE : t009-nam   TO csort-fnam,
           t009-txt_t TO csort-ftxt.
    APPEND csort.
  ENDLOOP .
ENDFORM.                    " INITIALIZATION

*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM at_selection_screen .

  CHECK sy-ucomm EQ 'SORT'.
  PERFORM function_hr_field_choice .
ENDFORM.                    " AT_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  FUNCTION_HR_FIELD_CHOICE
*& Alan seçimi yapmak için HR_FIELD_CHOICE fonsk ile fieldlar set edilir
*&---------------------------------------------------------------------*
FORM function_hr_field_choice .
  REFRESH ssort.
  LOOP AT s_fnams.
    READ TABLE csort WITH KEY fnam = s_fnams-low.
    CHECK sy-subrc EQ 0.  APPEND csort TO ssort.
  ENDLOOP.
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields                 = 2
      titel1                    = TEXT-001
      titel2                    = TEXT-002
      popuptitel                = TEXT-003
    TABLES
      fieldtabin                = csort
      selfields                 = ssort
    EXCEPTIONS
      no_tab_field_input        = 1
      to_many_selfields_entries = 2
      OTHERS                    = 3.
*-----Fill S_LGART
  REFRESH s_fnams.
  MOVE : 'I'          TO   s_fnams-sign,
         'EQ'         TO   s_fnams-option.
  LOOP AT ssort.
    MOVE : ssort-fnam     TO   s_fnams-low.
    APPEND s_fnams.
  ENDLOOP.
ENDFORM.                    " FUNCTION_HR_FIELD_CHOICE
