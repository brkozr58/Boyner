*&---------------------------------------------------------------------*
*& Include          ZUNHR_P002_I002
*&---------------------------------------------------------------------*
DATA : check_p.
DATA :BEGIN OF hd01  OCCURS 0        ,
*        KOSTL LIKE PERNR-KOSTL, " Masraf Yeri
        val01  LIKE zbyhr_s004-val01,
        txt01  LIKE zbyhr_s004-txt01,
        val02  LIKE zbyhr_s004-val02,
        txt02  LIKE zbyhr_s004-txt02,
        say_01 TYPE i                , " Toplam Calışan Sayisi
        say_02 TYPE i                , " S.Harici Sayisi-Sigortasiz
        say_03 TYPE i                , " S.Harici Sayisi-Sigortali
      END OF hd01                    .

DATA :BEGIN OF hd02  OCCURS 0        ,
        val01  LIKE zbyhr_s004-val01,
        txt01  LIKE zbyhr_s004-txt01,
        val02  LIKE zbyhr_s004-val02,
        txt02  LIKE zbyhr_s004-txt02,
        say_01 TYPE i                , " Kadin
        say_02 TYPE i                , " Erkek
      END OF hd02                    .


DATA :BEGIN OF hd03  OCCURS 0        ,
        val01  LIKE zbyhr_s004-val01,
        txt01  LIKE zbyhr_s004-txt01,
        val02  LIKE zbyhr_s004-val02,
        txt02  LIKE zbyhr_s004-txt02,
        say_01 TYPE i                , " İşe Giren T
        say_02 TYPE i                , " İşe Giren E
        say_03 TYPE i                , " İşe Giren K

        say_04 TYPE i                , " İşe Çıkan T
        say_05 TYPE i                , " İşe Çıkan E
        say_06 TYPE i                , " İşe Çıkan K
      END OF hd03                    .

DATA :BEGIN OF hd04  OCCURS 0        ,
        val01  LIKE zbyhr_s004-val01,
        txt01  LIKE zbyhr_s004-txt01,
        val02  LIKE zbyhr_s004-val02,
        txt02  LIKE zbyhr_s004-txt02,
        say_01 TYPE i                , " BY
        say_02 TYPE i                , " MY
        say_03 TYPE i                , " Stajyer
      END OF hd04                    .

DATA :BEGIN OF hd05  OCCURS 0        ,
        val01  LIKE zbyhr_s004-val01,
        txt01  LIKE zbyhr_s004-txt01,
        val02  LIKE zbyhr_s004-val02,
        txt02  LIKE zbyhr_s004-txt02,
        say_01 TYPE i                , " Asgari Ücretli Erkek Sayısı
        say_02 TYPE i                , " Asgari Ücretli Kadın Sayısı
        say_03 TYPE i                , " Engelli Erkek Sayısı
        say_04 TYPE i                , " Engelli Kadın Sayısı
      END OF hd05                    .

DATA :BEGIN OF hd06 OCCURS 0            ,
        val01      LIKE zbyhr_s004-val01,
        val02      LIKE zbyhr_s004-val02,
        toplam_net TYPE pad_amt7s,
        tahsil_edl TYPE pad_amt7s,
      END OF hd06                       .

* Masraf Yeri Gruplamasi
DATA :BEGIN OF gt_kostl  OCCURS 0       ,
        val01 LIKE zbyhr_s004-val01,
        txt01 LIKE zbyhr_s004-txt01,
        val02 LIKE zbyhr_s004-val02,
        txt02 LIKE zbyhr_s004-txt02,
      END OF gt_kostl                   .

* Dönem ve anagrp, Altgrup, Ücret Tipleri
DATA :BEGIN OF w  OCCURS 0            ,
        val01 LIKE zbyhr_s004-val01,
        txt01 LIKE zbyhr_s004-txt01,
        val02 LIKE zbyhr_s004-val02,
        txt02 LIKE zbyhr_s004-txt02,
        fpper LIKE period-fpper,
        anagr LIKE zbyhr_t012-anagr,
        altgr LIKE zbyhr_t013-altgr,
        seqno LIKE zbyhr_t014-seqno,
        slga  LIKE zbyhr_t014-slga,
        ssgrp LIKE p0769-ssgrp,
        lgtxt LIKE t512t-lgtxt,
        num   LIKE rt-anzhl, " i,
        saat  LIKE rt-anzhl,
        amt   LIKE rt-betrg,
        mat   LIKE rt-betrg          , " Matrah
        count TYPE i  VALUE 1        , " Personel Count
      END OF w                        .

DATA :BEGIN OF total  OCCURS 0        ,
        fpper LIKE period-fpper,
        val01 LIKE zbyhr_s004-val01,
        txt01 LIKE zbyhr_s004-txt01,
        val02 LIKE zbyhr_s004-val02,
        txt02 LIKE zbyhr_s004-txt02,
        anagr LIKE zbyhr_t012-anagr,
        altgr LIKE zbyhr_t015-altgr,
        num   LIKE rt-anzhl,
        saat  LIKE rt-anzhl,
        amt   LIKE rt-betrg,
        mat   LIKE rt-betrg          , " Matrah
        count TYPE i  VALUE 1        , " Personel Count
      END OF total                    .
*----------------------------------------------------------------------
*     SUB TOTAL
*----------------------------------------------------------------------

DATA : BEGIN OF sub_t  OCCURS 0      ,
         val01 LIKE zbyhr_s004-val01,
         txt01 LIKE zbyhr_s004-txt01,
         val02 LIKE zbyhr_s004-val02,
         txt02 LIKE zbyhr_s004-txt02,
         brut  LIKE w-amt,
         tmal  LIKE w-amt,
         tmalt LIKE w-amt,
         neto  LIKE w-amt,
         noze  LIKE w-amt,
         kesg  LIKE w-amt,
         asgi  LIKE w-amt,
       END OF sub_t                      .

DATA : tutar_s TYPE char15.
DATA : fark_ucreti551 LIKE rt-betrg.
DATA : fark_ucreti552 LIKE rt-betrg.
DATA : BEGIN OF col OCCURS 0,
         fld01(50),
         fld02(50),
         lgart     TYPE lgart,
         betrg     TYPE sumha,
       END OF col.

DATA : BEGIN OF personel OCCURS 0 ,
         pernr LIKE pernr-pernr,
         lgart LIKE rt-lgart,
         ddntk TYPE c,
       END OF personel            .

DATA : BEGIN OF csort OCCURS 0,
         ftxt(30),
         fnam(30),
       END OF csort,
       ssort LIKE csort OCCURS 0 WITH HEADER LINE,
       cvari LIKE csort OCCURS 0 WITH HEADER LINE,
       svari LIKE csort OCCURS 0 WITH HEADER LINE.

DATA : gt_t001  LIKE t001  OCCURS 0 WITH HEADER LINE,
       gt_t500p LIKE t500p OCCURS 0 WITH HEADER LINE,
       gt_t501t LIKE t501t OCCURS 0 WITH HEADER LINE,
       gt_t503t LIKE t503t OCCURS 0 WITH HEADER LINE,
       gt_t001p LIKE t001p OCCURS 0 WITH HEADER LINE,
       gt_t549t LIKE t549t OCCURS 0 WITH HEADER LINE,
       gt_t542t LIKE t542t OCCURS 0 WITH HEADER LINE,
       gt_cskt  LIKE cskt  OCCURS 0 WITH HEADER LINE,
       gt_t008  LIKE zbyhr_t017 OCCURS 0 WITH HEADER LINE,
       gt_t007  LIKE zbyhr_t018 OCCURS 0 WITH HEADER LINE.

DATA : lv_text(60).

DATA : BEGIN OF f OCCURS 0          ,
         fpper LIKE   s001-spmon,
         begda LIKE   p0001-begda,
         endda LIKE   p0001-begda,
       END OF f.

DATA : BEGIN OF gs_count,
         pernr TYPE persno,
       END OF gs_count,
       gt_count LIKE TABLE OF gs_count.
