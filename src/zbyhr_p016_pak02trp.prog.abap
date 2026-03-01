*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_pak02trp                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  KIDEMTARIHLERI
*&---------------------------------------------------------------------*
FORM kidemtarihleri USING    p_kidendda
                             p_kidbegda.
  DATA : i_kidendda LIKE kidendda,
         i_kidbegda LIKE kidbegda.
  i_kidendda = p_kidendda.
  i_kidendda+4(2) = i_kidendda+4(2) + 1.
  IF i_kidendda+4(2) > 12 .
    i_kidendda+0(4) =   i_kidendda+0(4) + 1.
    i_kidendda+4(2) =   '01'.
  ENDIF.
  i_kidendda+6(2) = '01'.
  i_kidbegda = i_kidendda = i_kidendda - 1.
  i_kidbegda+6(2) = '01'.
  p_kidendda = i_kidendda.
  p_kidbegda = i_kidbegda.
ENDFORM.                               " KIDEMTARIHLERI
*&---------------------------------------------------------------------*
*&      Form  HATATABLOSU
*&---------------------------------------------------------------------*
FORM hatatablosu USING    p_hatatext
                          p_hataturu
                          p_aciklama.
  DATA $text(85).
  IF hatadety EQ space AND p_hataturu EQ 'N'.
    fatalerr = 'X'.
  ENDIF.
  $text+0(52) = p_hatatext.
  $text+53(1) = ':'.
  $text+54 = p_aciklama.

  hatatab-pernr = iper-pernr.
  hatatab-ename = iper-ename.
  hatatab-werks = iper-werks.
  hatatab-btrtl = iper-btrtl.
  hatatab-htext = $text.
  hatatab-norml = p_hataturu.          " N : normal W : Uyar#
  hatatab-fatal = fatalerr.
  APPEND hatatab.
ENDFORM.                               " HATATABLOSU
*&---------------------------------------------------------------------*
*&      Form  tarihfarki
*&---------------------------------------------------------------------*
FORM tarihfarki USING   p_begda        "value(p_begda)
                        p_endda        "value(p_endda)
                        p_fark.
  DATA: gunfarki LIKE sy-datum,
        p0endda  LIKE sy-datum,
        p0begda  LIKE sy-datum,
        tempdat  LIKE sy-datum.
  DATA: gun TYPE i,
        ay  TYPE i,
        yil TYPE i.
  p0endda = p_endda.
  p0begda = p_begda.
  IF artikyil EQ space.
    gun = p0endda+6(2) - p0begda+6(2).
    ay  = p0endda+4(2) - p0begda+4(2).
    yil = p0endda+0(4) - p0begda+0(4).
    IF  gun LT 0.
      ay  =   ay - 1.
      gun = 30 + gun.
    ENDIF.
    IF  ay  LT 0.
      yil =  yil - 1.
      ay  =  12 + ay.
    ENDIF.
    IF  yil LE 0.
      hataturu = 'Y'.
    ENDIF.
    gunfarki+0(4) = yil.
    gunfarki+4(2) = ay.
    gunfarki+6(2) = gun.
  ELSE.

*___Yukarıdaki işlem ileriye taşındı.  TP. 13.01.2003
    gunfarki =  p0endda - p0begda.
  ENDIF.
  p_fark = gunfarki.
ENDFORM.                               " tarihfarki
*&---------------------------------------------------------------------*
*&      Form  TARIHTOPLAMI
*&---------------------------------------------------------------------*
FORM tarihtoplami USING tarih1
                        tarih2.
  DATA: p_tarih1 LIKE sy-datum,
        p_tarih2 LIKE sy-datum.
  DATA: gun TYPE i,
        ay  TYPE i,
        yil TYPE i.
  p_tarih1 = tarih1.
  p_tarih2 = tarih2.
  gun = p_tarih1+6(2) + p_tarih2+6(2).
  ay  = p_tarih1+4(2) + p_tarih2+4(2).
  yil = p_tarih1+0(4) + p_tarih2+0(4).
  PERFORM tarihecevir USING gun ay yil p_tarih1.
  tarih1 = p_tarih1.

ENDFORM.                               " TARIHTOPLAMI
*&---------------------------------------------------------------------*
*&      Form  TARIHECEVIR
*&---------------------------------------------------------------------*
FORM tarihecevir USING    gun1
                          ay1
                          yil1
                          p_tarih1.
  DATA gun    TYPE i.
  DATA ay     TYPE i.
  DATA yil    TYPE i.
  DATA tarih1 LIKE sy-datum.
  gun = gun1.
  ay  = ay1.
  yil = yil1.
  IF gun GE 30.
    ay  = ay  + ( gun DIV 30 ).
    gun = gun MOD 30.
  ENDIF.
  IF ay GE 12.
    yil = yil + ( ay DIV 12 ).
    ay  = ay MOD 12.
  ENDIF.
  tarih1+6(2) = gun.
  tarih1+4(2) =  ay.
  tarih1+0(4) = yil.
  p_tarih1 = tarih1.
ENDFORM.                               " TARIHECEVIR
*&---------------------------------------------------------------------*
*&      Form  TARIHECEVIR2
*&---------------------------------------------------------------------*
FORM tarihecevir2 USING    gun
                           gunfarki.
  DATA: ay(2)  TYPE n, yil(4) TYPE n.
  yil = ( gun * 100  ) DIV 36525.
  gun = gun - ( yil * 36525  / 100   ).
  ay  = ( gun * 10000 ) DIV 304375.
  gun = gun - ( ay  * 304375 / 10000 ).
  gunfarki+6(2) = gun.
  gunfarki+4(2) = ay.
  gunfarki+0(4) = yil.
ENDFORM.                               " TARIHECEVIR2

*&---------------------------------------------------------------------*
*&      Form  COMPARE_BETRG_RT
*&---------------------------------------------------------------------*
FORM compare_betrg_rt USING    p_betrg
                               p_pernr
                               i_fire.
  DATA i_betrg LIKE ppbwla-betrg.
  DATA i_betre LIKE ppbwla-betrg.
  DATA i_lgart LIKE ppbwla-lgart.
  DATA temptarh LIKE sy-datum.

  temptarh = i_fire(6).
  LOOP AT ppbwla.
    SELECT * FROM t541n
    WHERE molga EQ calcmolga "HC 14.11.2000
      AND lgart EQ ppbwla-lgart
      AND endda GT i_fire
    ORDER BY PRIMARY KEY.
    ENDSELECT.
    IF sy-subrc EQ 0.                  "HC 14.11.2000
      i_lgart = t541n-lga01.           "Net üctet
* Read: Aylık ücreti RT / Monthly wage
      PERFORM loop_at_rgdir USING p_pernr temptarh i_betrg i_lgart.

    ELSE.
      i_lgart = ppbwla-lgart.          "Brüt ücret
*-> SerenK 07012009 - Brüt ise, 0008'den okumalı!
      IF h_abart = '3' ."Beyaz Yaka
        i_betrg = ppbwla-betrg .
      ELSEIF h_abart = '1' ."Mavi Yaka
        i_betrg = ppbwla-betrg .
      ENDIF .
*-< SerenK 07012009
    ENDIF.
*-> SerenK 07012009 - Brüt isede bordrodan okuyor idi, commentlendi!
** Read: Aylık ücreti RT / Monthly wage
*    perform loop_at_rgdir using p_pernr temptarh i_betrg i_lgart.
*-> SerenK 07012009

* Compare: 0008 ile RT
    IF i_betrg LT ppbwla-betrg.
      i_betrg = ppbwla-betrg.
    ENDIF.
  ENDLOOP.
* IF i_betrg NE p_betrg .
*   PERFORM fill_err USING 'P'.
* ENDIF.
  p_betrg = i_betrg.

  IF kpklo EQ 'X'.
    p_betrg = ( p_betrg * p0008-bsgrd ) / 100 .
  ENDIF.

ENDFORM.                               " COMPARE_BETRG_RT
*&---------------------------------------------------------------------*
*&      Form  RE512T
*&---------------------------------------------------------------------*
FORM re512t USING    p_molga
                     p_lgart.
  CHECK t512t-sprsl NE sy-langu OR t512t-molga NE p_molga OR
        t512t-lgart NE p_lgart.
  SELECT SINGLE * FROM t512t WHERE sprsl EQ sy-langu AND
                                 molga EQ p_molga AND
                                 lgart EQ p_lgart.
  IF sy-subrc NE 0.
    CLEAR t512t.
  ENDIF.
ENDFORM.                                                    " RE512T
*&---------------------------------------------------------------------*
*&      Form  RE7TRG04
*&---------------------------------------------------------------------*
FORM re7trg04 USING    $werks
                     $btrtl.
  CHECK t7trg04-werks NE $werks OR t7trg04-btrtl NE $btrtl.
  SELECT SINGLE * FROM t7trg04 WHERE werks EQ $werks
                             AND   btrtl EQ $btrtl.
  IF sy-subrc NE 0.
    CLEAR t7trg04.
  ENDIF.

ENDFORM.                                                    " RE9Y1P
*&---------------------------------------------------------------------*
*&      Form  LOOP_AT_RGDIR
*&---------------------------------------------------------------------*
FORM loop_at_rgdir USING  p_pernr p_temprtarh i_betrg i_lgart.
  DATA firedate LIKE rgdir-fpper.      "SY-DATUM.
  DATA: h_tage(2) TYPE n, h_lin TYPE i."HC 14.11.2000

  h_fire =  p_temprtarh+0(6).
  SORT rgdir BY fpper DESCENDING.

  WHILE stoploop EQ space.
    LOOP AT rgdir.
      CHECK rgdir-fpper EQ h_fire.
      CHECK: rgdir-srtza EQ stand OR stand EQ space.
* Çıkış: Ay ortasında olup olmadığını kontrol eder
*        Yarım aylık hesaba dahil edilmemesi gerek.
*      READ TABLE py_wpbp WITH KEY aktivjn = space
*                               stat2 = '0'.
      READ TABLE py_result-inter-wpbp INTO py_wpbp
      WITH KEY  aktivjn = ' '.
      IF py_wpbp-aktivjn NE space AND py_wpbp-stat2 NE 3.
        READ TABLE py_result-inter-rt INTO py_rt WITH KEY lgart =
                  i_lgart.
        IF h_abart EQ '1'.
          i_betrg = i_betrg + py_rt-betpe.
        ELSE.
          i_betrg = i_betrg + py_rt-betrg.
        ENDIF.
        stoploop = 'X'.
      ELSE.
* Net ücret alıp ay ortası ayrılanlar için.... TP 27.12.2002
* Eğer Bordrolarında Net ücretin tamamını getirecek uyarlama
* yapılmışsa ekrandan girilen ücret tipini alır.

        IF NOT netu IS INITIAL.
          i_lgart = netu.
        ENDIF.
* Net ücretlerde bu kısmı getirmiyordu. "TP 24.10.2002
        READ TABLE py_result-inter-rt INTO py_rt WITH KEY lgart =
        i_lgart.
        IF sy-subrc = 0.
          i_betrg = py_rt-betrg.
        ELSE.
          i_betrg = 0.
        ENDIF.
* Eğer kişinin net ücreti uyarlama ile gelmiyorsa.
* kişinin RT'sinden çektiği ücret miktarını çalışılan güne bölüp
* 30 ile çarptırır.    TP 27.12.2002.
        IF netu IS INITIAL.
          READ TABLE py_result-inter-rt INTO py_rt WITH KEY lgart =
                  '/104'.
          IF py_rt-anzhl NE 0.
*            IF h_abart NE 1."0. SerenK 31122008
* Eger part-time kisi net ücretli ise ve 8 no'lu ücrette
* degerlenirse bu if'in olmamasi gerekiyor.
* Teshis : Aktas : 06.02.2011.

            i_betrg = ( i_betrg * 30 ) / py_rt-anzhl.
*            ENDIF.
          ENDIF.

        ENDIF.
        IF h_fire+4(2) GT 1.
          h_fire = h_fire - 1.
        ELSE.
          h_fire+0(4) = h_fire+0(4) - 1.
          h_fire+4(2) = '12'.
        ENDIF.
        stoploop = 'X'.                "is 26.09.2002
      ENDIF.
    ENDLOOP.
*   TR'da data olmazsa sonsuz döngüye giriyor.
    stoploop = 'X'.                "is 26.09.2002
  ENDWHILE.
ENDFORM.                               " LOOP_AT_RGDIR
*&---------------------------------------------------------------------*
*&      Form  APPEND_RTAB
*&---------------------------------------------------------------------*
FORM append_rtab USING    p_lgart
                          p_betrg
                          p_wtext.
  CLEAR: t512t, rtab.


  PERFORM ikramiye_zam USING p_betrg p_lgart.


  IF p_lgart NE space.
    PERFORM re512t USING calcmolga p_lgart.
  ENDIF.
  IF t512t-lgtxt IS INITIAL.
    rtab-lgtxt = p_wtext.
  ELSE.
    rtab-lgtxt = t512t-lgtxt.
  ENDIF.
  IF rtab-lgtxt IS INITIAL.
    PERFORM hatatablosu USING TEXT-erw 'W' p_lgart.
  ENDIF.
  rtab-pernr = pernr-pernr.
  rtab-betrg = p_betrg.


  IF p_lgart NE '1100'.

* E#er ki#i saat ücretliyse saat ücreti 0008 girilen tutar#n#n
* ayl#k çal##ma program#nda gelen miktar#yla çarp#m#d#r. "TP 23.10.2002
    "IS 22.01.2003
    IF h_abart EQ '1' AND p_lgart EQ space.

* önyüzdeki  saat ücretlileri yıl üzerinden hesap işaretlendiğinde
*  [SU*7,5)*365]/12 şeklinde bir hesaplama yapar.
* 03.01.2006 oks ist.

      IF saat365 EQ 'X'.
        rtab-betrg = ( rtab-betrg * ( p0008-divgv / 30 )  *  365 ) / 12 .
      ELSE.
        rtab-betrg = rtab-betrg * p0008-divgv.
      ENDIF.
    ENDIF.
  ENDIF.

* E#er ki#i günlük ücretliyse 0008'de girilen ücretin
* 30 ile çarp#m#d#r.  "TP 23.10.2002
*  IF H_ABART EQ '2'.                       "IS 22.01.2003
*    RTAB-BETRG = RTAB-BETRG * 30.
*  ENDIF.
  rtab-lgart = p_lgart.
  CHECK rtab-betrg > 0.
  APPEND rtab.
ENDFORM.                               " APPEND_RTAB
*&---------------------------------------------------------------------*
*&      Form  WRITE_T9YD1
*&---------------------------------------------------------------------*
FORM write_t7trg01.
  PERFORM satirformati USING 2.
  WRITE: / sy-vline NO-GAP ,
           m1 AS CHECKBOX NO-GAP, sy-vline NO-GAP,
           it7trg01-werks   NO-GAP, sy-vline NO-GAP,
           it7trg01-btrtl   NO-GAP, sy-vline NO-GAP,
           it7trg01-sskno   NO-GAP, sy-vline NO-GAP,
*           it7trg01-ttfno   NO-GAP, sy-vline NO-GAP,
           it7trg01-name1   NO-GAP, '     ', sy-vline.
  HIDE: it7trg01.
ENDFORM.                    "write_t7trg01
*&---------------------------------------------------------------------*
*&      Form  SATIRFORMATI
*&---------------------------------------------------------------------*
FORM satirformati USING  col_type.
  IF satirtip EQ 'X'.
    satirtip = space.
    FORMAT INTENSIFIED ON  COLOR = col_type.
  ELSE.
    satirtip = 'X'.
    FORMAT INTENSIFIED OFF COLOR = col_type.
  ENDIF.
ENDFORM.                               " SATIRFORMATI
*&---------------------------------------------------------------------*
*&      Form  CHECK_UNCHECK_LINE
*&---------------------------------------------------------------------*
FORM check_uncheck_line USING lineflag.
  DO.
    READ LINE sy-index FIELD VALUE m1.
    IF sy-subrc > 0. EXIT. ENDIF.
    IF m1 NE lineflag.
      MOVE lineflag TO m1.
    ENDIF.
    MODIFY LINE sy-index FIELD VALUE m1.
  ENDDO.
ENDFORM.                               " CHECK_UNCHECK_LINE
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_LINE
*&---------------------------------------------------------------------*
FORM  top_of_page_line.
  NEW-PAGE.
  CASE sy-ucomm.
    WHEN 'TRAN'.

      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /(c_259).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- TRANSFER LİSTESİ', AT c_259 sy-vline.
        ULINE AT /(c_259).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'    NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'SSK Numarası      '   NO-GAP,
                   sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, '      Aylık Brüt' NO-GAP,
                   sy-vline NO-GAP, '       Yan Gelir' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' İhbar Tazminatı' NO-GAP,
                   sy-vline.
        ULINE AT /(c_259).
      ELSE.
        ULINE AT /(c_208).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- TRANSFER LİSTESİ', AT c_208 sy-vline.
        ULINE AT /(c_208).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'    NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'SSK Numarası      '   NO-GAP,
                   sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' İhbar Tazminatı' NO-GAP,
                   sy-vline.
        ULINE AT /(c_208).

      ENDIF.


    WHEN 'MALM'.
      ULINE AT /(c_i05).
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
      WRITE : / sy-vline, kidendda,
             'TARİHİNE GÖRE POTANSİYEL KIDEM TAZMİNATI',
             '- MALİYET MERKEZİ', 103 sy-vline.
      ULINE AT /(c_i05).
      WRITE:/ sy-vline NO-GAP,
         (31) 'Maliyet  Merkezi' NO-GAP, sy-vline NO-GAP,
*         (20) 'Bordro Alt Birimi' NO-GAP, sy-vline NO-GAP,
         (11) 'Topl.Kişi' RIGHT-JUSTIFIED NO-GAP, sy-vline NO-GAP,
         (11) 'Ort.Yıl'   RIGHT-JUSTIFIED NO-GAP, sy-vline NO-GAP,
         (11) 'Ort.Ay '   RIGHT-JUSTIFIED NO-GAP, sy-vline NO-GAP,
         (11) 'Ort.Gün'   RIGHT-JUSTIFIED NO-GAP, sy-vline NO-GAP,
         (21) 'Kıdem Tazminatı' RIGHT-JUSTIFIED NO-GAP, sy-vline.
      ULINE AT /(c_i05).
    WHEN 'NORM' OR 'DETY'.
      ULINE AT /(69).
      FORMAT COLOR COL_KEY INTENSIFIED OFF.
      WRITE: / sy-vline, iper-pernr, iper-ename(30),
            47 sy-datum, 69 sy-vline.
      ULINE AT /(69).


    WHEN 'WTYP' OR 'PERS' OR 'BUKR'.

      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /(c_259).
        IF sy-ucomm EQ 'WTYP'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- PERSONEL ALT ALANI', 259 sy-vline.
        ELSEIF sy-ucomm EQ 'BUKR'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ŞİRKET', AT 259 sy-vline.
        ELSEIF sy-ucomm EQ 'PERS'.

          WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSİYEL KIDEM TAZMİNATI',
                 '- ÇALIŞAN ALT GRUBU', 259 sy-vline.
        ELSEIF sy-ucomm EQ 'COSC'.
          WRITE : / sy-vline, kidendda,
                         'TARİHİNE GÖRE POTANSİYEL KIDEM TAZMİNATI',
                         '- MASRAF YERİ', 259 sy-vline.

        ENDIF.
      ELSE.
        ULINE AT /(c_208).
        IF sy-ucomm EQ 'WTYP'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- PERSONEL ALT ALANI', 208 sy-vline.
        ELSEIF sy-ucomm EQ 'BUKR'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ŞİRKET', AT 208 sy-vline.
        ELSEIF sy-ucomm EQ 'PERS'.

          WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSİYEL KIDEM TAZMİNATI',
                 '- ÇALIŞAN ALT GRUBU', 208 sy-vline.
        ELSEIF sy-ucomm EQ 'COSC'.
          WRITE : / sy-vline, kidendda,
                         'TARİHİNE GÖRE POTANSİYEL KIDEM TAZMİNATI',
                         '- MASRAF YERİ', 208 sy-vline.
        ENDIF.
      ENDIF.

*      ULINE AT /(199).

      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /(c_259).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'    NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'SSK Numarası      '   NO-GAP,
                   sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, '      Aylık Brüt' NO-GAP,
                   sy-vline NO-GAP, '       Yan Gelir' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' İhbar Tazminatı' NO-GAP,
                   sy-vline.
        ULINE AT /(c_259).
      ELSE.
        ULINE AT /(c_208).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'    NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'SSK Numarası      '   NO-GAP,
                   sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' İhbar Tazminatı' NO-GAP,
                   sy-vline.
        ULINE AT /(c_208).

      ENDIF.
*      ULINE AT /(199).

    WHEN 'HATA'.
      ULINE AT /(95).
      FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE : / sy-vline,
             'İŞLENEN PERSONELLER İÇİN UYARI LİSTESi', 95 sy-vline.
    WHEN 'ERRO'.
      ULINE AT /(95).
      FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE : / sy-vline,
       'SEÇİM SIRASINDA OLUŞAN HATALARIN LİSTESİ', 95 sy-vline.
    WHEN 'BTC2'.
      ULINE AT /(95).
      FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE : / sy-vline,
             'TOPLU GİRDİ SIRASINDA OLUŞAN UYARILAR' CENTERED
             , 95 sy-vline.


    WHEN 'OLDD' .
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
      ULINE AT /(c_143).
      WRITE : / sy-vline,
             'Geçmiş Devamsızlık Verileri', 145 sy-vline.

      ULINE AT /(c_143).
      WRITE : /  sy-vline NO-GAP, 'Sicil No'    NO-GAP,
                 sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                 sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                 sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                 sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                 sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                 sy-vline NO-GAP, (14) 'Başlangıç Tr '       NO-GAP,
                 sy-vline NO-GAP, (14) 'Bitiş Tr'       NO-GAP,
                 sy-vline NO-GAP, (30) 'Devamsızlık türü.'       NO-GAP ,
                 sy-vline.
      ULINE AT /(c_143).

    WHEN 'OLDK' .
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
      ULINE AT /(c_121).
      WRITE : / sy-vline,
             'Geçmiş Kıdem Verileri', 129 sy-vline.
      ULINE AT /(c_121).
      WRITE : /  sy-vline NO-GAP, 'Sicil No'    NO-GAP,
                 sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                 sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                 sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                 sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                 sy-vline NO-GAP, 'Cinsiyet'         NO-GAP,
                 sy-vline NO-GAP, (14) 'Başlangıç Tr '       NO-GAP,
                 sy-vline NO-GAP, (14) 'Bitiş Tr'       NO-GAP,
                 sy-vline NO-GAP, (14) 'Çalışma Tipi.'       NO-GAP ,
                 sy-vline.
      ULINE AT /(c_121).



  ENDCASE.

ENDFORM.                               " TOP_OF_PAGE_LINE
*&---------------------------------------------------------------------*
*&      Form  CLEAR_WAS
*&---------------------------------------------------------------------*
FORM clear_was.

  CLEAR: iper.
  CLEAR: kidprimt,kidpernr, kidlgart, grevtarh,
         fatalerr, normlerr, stoploop.
ENDFORM.                               " CLEAR_WAS
*&---------------------------------------------------------------------*
*&      Form  CHECK_P9005
*&---------------------------------------------------------------------*
FORM check_p0776.
  CLEAR p0776.                         "IS 27.01.2003
*  "0776 kıdem bilgi tipi kontrolü
  rp-provide-from-last p0776 space kidbegda kidendda.
  IF p0776[] IS INITIAL.
    WRITE kidbegda TO hatatext+0(10) DD/MM/YYYY.
    WRITE kidendda TO hatatext+12(10) DD/MM/YYYY.
    IF potkidem EQ 'X'.
      PERFORM hatatablosu USING TEXT-erd 'W' hatatext.
    ELSE.
      PERFORM hatatablosu USING TEXT-erd 'N' hatatext.
    ENDIF.
  ELSE.
    MOVE-CORRESPONDING p0776 TO i0776.
    APPEND i0776.
  ENDIF.
ENDFORM.                               " CHECK_P9005

*&---------------------------------------------------------------------*
*&      Form  CHECK_P0001
*&---------------------------------------------------------------------*
FORM check_p0001.
* En son organizasyon kayd#n# kontrol eder.
  PROVIDE * FROM p0001 BETWEEN kidbegda AND kidendda
                         WHERE p0001-bukrs IN pnpbukrs
                           AND p0001-werks IN pnpwerks
                           AND p0001-btrtl IN pnpbtrtl
                           AND p0001-persg IN pnppersg
                           AND p0001-persk IN pnppersk.
  ENDPROVIDE.
  IF sy-subrc NE 0.
*   CONCATENATE kidbegda ' - ' kidendda INTO hatatext.
    WRITE kidbegda TO hatatext+0(10) DD/MM/YYYY.
    WRITE kidendda TO hatatext+12(10) DD/MM/YYYY.
    PERFORM hatatablosu USING TEXT-erx 'N' hatatext.
  ENDIF.
*    check p0001-bukrs in pnpbukrs.
  IF NOT p0001-bukrs IN pnpbukrs.
    fatalerr = 'X'.
  ENDIF.
* Seçim kriterlerindeki seçim kodu için.

ENDFORM.                               " CHECK_P0001
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH1
*&---------------------------------------------------------------------*
FORM check_tarih1.
* Tarih başlangıç değerlerinin kontrolü / Control BEGDA of firing
  IF potkidem NE space.
    IF h_fire LT kidendda.             " çıkış kıdemden önce (pot)
      WRITE h_fire TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-erc 'N' hatatext.
    ENDIF.
  ELSE.
    IF h_fire LT kidbegda.             " çıkış kıdemden önce
      WRITE h_fire TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-erf 'N' hatatext.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECH_TARIH1
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH2
*&---------------------------------------------------------------------*
FORM check_tarih2.
*__Başlangıç tarih değerlerinin itab'a atanması
*__Transfer BEGDA to ITAB

  iper-fire = kidendda.
  iper-hire = h_hire.
  IF norkidem = 'X'.
    iper-fire = h_fire.
    IF ( h_fire LT kidbegda ) OR ( h_fire GT kidendda ).
      CLEAR hatatext.
      WRITE kidbegda TO hatatext+0(10) DD/MM/YYYY.
      WRITE kidendda TO hatatext+12 DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-erg 'N' hatatext.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECK_TARIH2
*&---------------------------------------------------------------------*
*&      Form  COUNT_P0023
*&---------------------------------------------------------------------*
FORM count_p0023.
*___Eski işyerindeki çalışma süresinin kontrolü /
*___Control of previous working place
*___Komod 0750 no'lu bilgi tipine taşındı / KOMOD was transfered to 0750
  LOOP AT p0750 WHERE ptr_komod EQ 'E'.
    PERFORM tarihfarki USING p0023-begda p0023-endda temptarh.
    IF p0750-ptr_fpmod EQ 'P'.
      PERFORM tarihtoplami  USING iper-ptime temptarh.
    ELSE.
      PERFORM tarihtoplami  USING iper-ftime temptarh.
    ENDIF.
    PERFORM tarihtoplami  USING iper-eskit temptarh.
  ENDLOOP.
ENDFORM.                               " COUNT_P0023

*&---------------------------------------------------------------------*
*&      Form  COUNT_P0001
*&---------------------------------------------------------------------*
FORM count_p0001.
  DATA : lv_days       TYPE i,
         lv_pday       TYPE i,
         lv_fday       TYPE i,
         lv_carp       LIKE rt-anzhl VALUE '0.6',
         lv_start_date TYPE d VALUE '00010101',
         lv_ftime      LIKE p0001-endda,
         lv_end_date   TYPE d,
         lv_index      TYPE i,
         lv_begda      TYPE begda.

  DATA: temptarh2 TYPE sy-datum.

  DEFINE convert_xtime.
    IF &1 EQ 'PART'.
*      &2 = &2 * lv_carp.
    ENDIF.
    IF &2 IS NOT INITIAL .
      " Gün ekle
      lv_end_date = lv_start_date + &2.
      " Yıl farkı
      &3(4) = lv_end_date(4) - lv_start_date(4).
      " Ay farkı
      &3+4(2) = lv_end_date+4(2) - lv_start_date+4(2).
      " Gün farkı
      &3+6(2) = lv_end_date+6(2) - lv_start_date+6(2).
    ENDIF.

  END-OF-DEFINITION.

*___Çalışan Alt Grubu Part Time'a tabi ise part time sürelerini toplar
*___Calculates part-time days if it is a PART-TIME Employee Subgroup

  CLEAR : iper-ftime, iper-ptime, iper-ktime.

  DATA : lt_t028 TYPE TABLE OF zbyhr_t028 WITH HEADER LINE .
  DATA: lv_diff  TYPE i.

  lv_begda = iper-hire.
  SELECT * FROM zbyhr_t028 INTO  TABLE lt_t028
      WHERE pernr EQ pernr-pernr
        AND begda LE '20260101' .
  IF sy-subrc EQ 0 .
    SORT lt_t028 ASCENDING BY begda endda .
    LOOP AT lt_t028  .
      IF sy-tabix EQ 1 .
        iper-fchire = lt_t028-begda.
      ENDIF.
      CASE lt_t028-persk.
        WHEN 'P'.
          IF lt_t028-begda LT lt_t028-endda.
            lv_pday = lv_pday + ( lt_t028-endda - lt_t028-begda ) + 1 .
          ENDIF.
        WHEN OTHERS.
          IF lt_t028-begda LT lt_t028-endda.
            lv_fday = lv_fday + ( lt_t028-endda - lt_t028-begda ) + 1 .
          ENDIF.
      ENDCASE.
      lv_begda = lt_t028-endda.
    ENDLOOP.
  ENDIF.

  PROVIDE * FROM p0001 BETWEEN lv_begda AND iper-fire.
    ADD 1 TO lv_index .
    LOOP AT lt_t028 WHERE begda LE p0001-begda AND endda GE p0001-begda.ENDLOOP.
    IF sy-subrc EQ 0  .
      p0001-begda = lt_t028-endda.
    ELSE.
      " 41 deki işe giriş tarihi ile zli tablodaki uyuşmuyorsa veya zli tabloda yoksa.
      " 41 kıdem tarihini al.
      LOOP AT lt_t028 WHERE begda LE iper-hire AND endda GE iper-hire.ENDLOOP.
      IF sy-subrc NE 0 AND lv_index EQ 1 AND p0001-begda GT iper-hire.
        p0001-begda = iper-hire.
      ENDIF.
    ENDIF.
    CASE p0001-persk.
      WHEN '13' OR '14'.
        SELECT SINGLE * FROM t7trg03 WHERE persg EQ p0001-persg
                                     AND persk EQ p0001-persk.
        IF sy-subrc EQ 0.
          IF p0001-begda LT p0001-endda.
         lv_pday = lv_pday + ( p0001-endda - p0001-begda ) + 1 .
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        IF p0001-begda LT p0001-endda.
          lv_fday = lv_fday + ( p0001-endda - p0001-begda ) + 1 .
        ENDIF.
    ENDCASE.
  ENDPROVIDE.

  convert_xtime : 'PART' lv_pday iper-ptime.

  convert_xtime : 'FULL' lv_fday iper-ftime.


  IF cikisgun EQ 'X'.
    IF artikyil EQ 'X'.
      iper-ftime = iper-ftime + 1.
    ELSE.
      IF iper-ftime+6(2) LT 30.
        iper-ftime+6(2) = iper-ftime+6(2) + 1.
      ELSE.
        iper-ftime+4(2) = iper-ftime+4(2) + 1.
        iper-ftime+6(2) = iper-ftime+6(2) - 30.

      ENDIF.
    ENDIF.
  ENDIF.

*  "<<--------  Kıdeme esas süreyi revize et
  PERFORM tarihtoplami USING iper-ktime iper-ftime.
  PERFORM tarihtoplami USING iper-ktime iper-ptime.
  "<<-------------->>
ENDFORM.                               " COUNT_P0001
*&---------------------------------------------------------------------*
*&      Form  COUNT_GREVG
*&---------------------------------------------------------------------*
FORM count_grevg.

  DATA : lt_t027 TYPE TABLE OF zbyhr_t027.
*  iper-GTIME.
  SELECT * FROM zbyhr_t027 INTO  TABLE lt_t027
      WHERE pernr EQ pernr-pernr
        AND begda LE '20260101'
        AND awart IN wty_ubz[].

  LOOP AT lt_t027 INTO DATA(ls_t027).
    grevtarh = grevtarh + ( ls_t027-endda - ls_t027-begda ).
  ENDLOOP.


*___Grev günlerinin hesaplanıp kıdem süresinden çıkartılması
*___Calculate strike days and subtrack from Seniority days
  PROVIDE * FROM p2001 BETWEEN h_hire AND h_fire.
    CHECK NOT wty_ubz[] IS INITIAL.   "p_streik.
    CHECK p2001-awart IN wty_ubz.     "p_streik.

*_User-exit_________________________________________*
*    PERFORM on_calc_2001_user_exit.
    grevtarh = grevtarh + p2001-kaltg.
  ENDPROVIDE.

  IF grevtarh NE 0.
    PERFORM tarihecevir2 USING grevtarh iper-gtime.
  ENDIF.

  IF iper-gtime < iper-ftime.
    iper-esast = iper-ftime.
    PERFORM tarihfarki USING iper-gtime iper-ftime iper-ftime.
*     PERFORM tarihfarki USING iper-gtime iper-esast iper-esast.
  ENDIF.

* Kıdem hesaplamasının bir yıl = 365 gün üzerinden hesaplanması
* Seniority calculation 1 year = 365 days.    TP 14.01.2003

  IF artikyil NE space.
    IF iper-ftime+0(4) LE 1.
      iper-ftime+0(4) = '0000'.
      iper-ftime+4(2) = iper-ftime+4(2) - 1.
      iper-esast+0(4) = '0000'.
      iper-esast+4(2) = iper-esast+4(2) - 1.
    ELSE.
      iper-ftime = iper-ftime - 397.
      iper-esast = iper-esast - 397.
    ENDIF.
* 397 = 1 yıl + 1 ay + 1 gün
    PERFORM tarihecevir USING iper-ftime+6(2)
                              iper-ftime+4(2)
                              iper-ftime+0(4)
                              iper-ftime.
  ENDIF.

  temptarh = iper-ftime.
  PERFORM tarihtoplami USING temptarh iper-ptime.
  iper-ktime = temptarh.
  IF norkidem NE space.
    IF iper-ktime LT '00010000'.
      WRITE iper-ktime TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-ern 'W' hatatext.
    ENDIF.
  ENDIF.
ENDFORM.                               " COUNT_GREVG

*&---------------------------------------------------------------------*
*&      Form  COUNT_UCRET
*&---------------------------------------------------------------------*
FORM count_ucret.
*  TABLES: t7trk03.
  DATA: it7trk03 LIKE t7trk03 OCCURS 10 WITH HEADER LINE.

*___Temel Ödemelerini bulur, bunlar net ise brut karşılık. RT'den alır
*___Finds basic salary (if they are netto finds brutto accrual) Gets
*___from RT
  SORT p0008 BY begda ASCENDING.
  DELETE rgdir WHERE srtza NE 'A'.
  SORT rgdir BY fpper DESCENDING.

  LOOP AT rgdir WHERE fpper LE iper-fire+0(6).
    EXIT.
  ENDLOOP.
  IF sy-subrc EQ 0.
    CLEAR py_result.
    PERFORM read_payroll USING rgdir-fpper r_srtza
                      CHANGING py_result.

    READ TABLE py_result-inter-rt INTO DATA(ls_rt) WITH KEY lgart = '1100'.
    IF sy-subrc EQ 0 .
      iper-betrg = ls_rt-betrg.
*      iper-bazms =  iper-betrg .
*      iper-mcurr =  ls_rt-amt_curr.
    ENDIF.
*    PERFORM gesamt_p0008 USING kidbetrg pernr-pernr
*                          rgdir-fpbeg rgdir-fpend.

*    READ TABLE ppbwla INDEX 1 .
*    iper-bazms =  ppbwla-betrg .
*    iper-mcurr =  ppbwla-waers.

*    PERFORM compare_betrg_rt USING  iper-bazms
*                                   pernr-pernr rgdir-fpbeg.

    LOOP AT p0008. ENDLOOP.
    iper-bazms = p0008-bet01.
    iper-mcurr = p0008-waers.

    SELECT SINGLE * FROM t512t WHERE sprsl EQ sy-langu AND
                                   molga EQ 47 AND
                                   lgart EQ p0008-lga01.
    IF sy-subrc NE 0.
      CLEAR t512t.
    ELSE.
      iper-maastx = t512t-lgtxt.
    ENDIF.


  ELSE.
    hatatext+0(2) = iper-fire+4(2).
    hatatext+2(1) = '.'.
    hatatext+3(4) = iper-fire+0(4).
    PERFORM hatatablosu USING TEXT-ers 'N' hatatext.
    CHECK fatalerr EQ space.           "Check Point
  ENDIF.

*___Pot. Kıdemde T7TRK03 tablosuna göre olası maas artışı dikkate alınır
*___In potential seniority planned salary increase is taken into account
*___(T7TRK03)
  IF potkidem NE space.
* Body içinden otomatik gelmesi gerekiyordu. Eğer istenirse
* aşağıdaki değerler body içerisinden değiştirilebilir.
    i0776-pernr = pernr-pernr.
    i0776-knorm = 0.
    i0776-fprtg = 0.
    i0776-prznt = 100.
    i0776-kidpr = 100.
    i0776-kidtg = 30.
    i0776-fagan = 1.
    APPEND i0776.

* BADI
    DATA: l_badi_01 TYPE REF TO if_ex_hrpaytr_kidem_01.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = ''             " beklan checkman
        null_instance_accepted = '' " beklan checkman
      CHANGING
        instance               = l_badi_01.
    DATA : ls_iper TYPE ptr07 .
    MOVE-CORRESPONDING iper TO ls_iper .

    CALL METHOD l_badi_01->change_values
      CHANGING
        iper = ls_iper.

    MOVE-CORRESPONDING ls_iper TO iper .

* BADI
    DATA: l_badi_05 TYPE REF TO if_ex_hrpaytr_kidem_05.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = ''             " beklan checkman
        null_instance_accepted = '' " beklan checkman
      CHANGING
        instance               = l_badi_05.

    CALL METHOD l_badi_05->change_values
      CHANGING
        h_ue_artis_flag = h_ue_artis_flag.
*

*    PERFORM ue_artis_flag.
    IF h_ue_artis_flag EQ space.
      REFRESH it7trk03. CLEAR it7trk03.
      SELECT * FROM t7trk03 INTO TABLE it7trk03
             WHERE persg EQ p0001-persg
             AND   btrtl EQ p0001-btrtl
             AND werks EQ p0001-werks
             AND   persk EQ p0001-persk
             AND   datum GT rgdir-fpend.
      SORT it7trk03 BY datum ASCENDING.
      DATA lv_artis LIKE iper-betrg.
      CLEAR lv_artis.
      LOOP AT it7trk03.
        IF NOT it7trk03-prznt IS INITIAL.
          IF pottarih GE it7trk03-datum.
            IF it7trk03-prznt GT 1.
              "lv_artis = iper-betrg * it7trk03-prznt .
              iper-betrg = iper-betrg * it7trk03-prznt .
            ELSE.
              iper-betrg = ( iper-betrg * ( h_fact + it7trk03-prznt ) ) /
              h_fact.
            ENDIF.
          ENDIF.
        ENDIF.
        IF NOT it7trk03-betrg IS INITIAL.
          IF pottarih GE it7trk03-datum.
            iper-betrg = iper-betrg + it7trk03-betrg.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
*      PERFORM ue_custom_artis.

* BADI
      DATA: l_badi_04 TYPE REF TO if_ex_hrpaytr_kidem_04.

      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name              = ''             " beklan checkman
          null_instance_accepted = '' " beklan checkman
        CHANGING
          instance               = l_badi_04.

*      DATA : ls_iper TYPE ptr07 .
      MOVE-CORRESPONDING iper TO ls_iper .

      CALL METHOD l_badi_04->change_values
        CHANGING
          iper = ls_iper.

      MOVE-CORRESPONDING ls_iper TO iper .
      MODIFY iper.

    ENDIF.
  ENDIF.
  IF iper-betrg NE 0.
    PERFORM append_rtab USING '1100'  iper-betrg 'Esas Ücret '.
*    PERFORM append_rtab USING space iper-betrg 'Esas Ücret - BT 0008'.
  ELSE.
    PERFORM hatatablosu USING TEXT-erm 'N' ppbwla-lgart.
  ENDIF.
ENDFORM.                               " COUNT_UCRET
*&---------------------------------------------------------------------*
*&      Form  COUNT_T9YKD_BETRG_0
*&---------------------------------------------------------------------*
FORM count_t7trk02_betrg_0.
  DATA: BEGIN OF l_it7trk02 OCCURS 10.
          INCLUDE STRUCTURE t7trk02.
  DATA:   cnt TYPE i.
  DATA: END OF l_it7trk02.
  DATA: k_beg        LIKE rgdir-fpper, k_end LIKE rgdir-fpper,
        k_fpper      LIKE rgdir-fpper,
        k_cnt_dif(2) TYPE n.
  DATA :
        lv_sgkgn TYPE anzhl.
  DATA p_fark TYPE i.

  p_fark = iper-fire - iper-hire + 1.
  PERFORM re7trg04 USING iper-werks iper-btrtl.

  REFRESH l_it7trk02. CLEAR l_it7trk02.
  PERFORM re7trg03 USING iper-persg iper-persk.
* Badi 15 20.09.2019 .
* Changing senioriy grouping according to infotype 0041 .

*PROVIDE * FROM p0771 BETWEEN iper-hire AND iper-fire.
  rp-provide-from-last p0776 space iper-hire iper-fire.

  DATA: l_badi_15 TYPE REF TO hrpaytr_kidem_15 .

  GET BADI l_badi_15.
  CALL BADI l_badi_15->change_grouping  "Change Seniority Groupins.
    EXPORTING
      is_p0041   = p0041
      ls_p0771   = p0771
      ls_p0001   = p0001
    CHANGING
      ch_sen_grp = t7trg03-kidem.

* Changing senioriy grouping according to infotype 0041 .

*  CLEAR iper-betrg. "IS 20.04.2004
*  APPEND iper.
*  LOOP AT iper WHERE pernr EQ pernr-pernr.
  LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                   AND   betrg EQ 0           "IS 19.04.2004
                   AND werks EQ iper-werks
                   AND btrtl EQ iper-btrtl.
    CLEAR l_it7trk02.
    MOVE-CORRESPONDING it7trk02 TO l_it7trk02.
    APPEND l_it7trk02.
  ENDLOOP.
*  ENDLOOP.

* "IS 19.04.2004

  SORT l_it7trk02 BY rtdiv.
* Yukaridaki sort olmadiginda ikramiye
* tipi ücretler hatali geliyordu.
* Taner 29.05.2006

  LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                  AND   betrg EQ 0           "IS 19.04.2004
                  AND werks IS INITIAL
                  AND btrtl IS INITIAL.
    CLEAR l_it7trk02.
    MOVE-CORRESPONDING it7trk02 TO l_it7trk02.
    APPEND l_it7trk02.
  ENDLOOP.

* Changing notice grouping according to infotype 0041 .

  DATA: l_badi_16 TYPE REF TO hrpaytr_kidem_16 .

  GET BADI l_badi_16.
  CALL BADI l_badi_16->change_notice_grouping  "Change Notice Groupins.
    EXPORTING
      is_p0041       = p0041
      is_p0771       = p0771
      is_p0001       = p0001
    CHANGING
      ch_notice_grup = t7trg04-ihbar.

* Changing notice grouping according to infotype 0041 .

  SELECT  * FROM t7trk01 WHERE ihbar  EQ t7trg04-ihbar
                           AND ihbfr LE p_fark
                           AND ihfto GE p_fark
                           AND begda  LE iper-fire
                           AND endda  GE iper-fire.
  ENDSELECT.
  iper-tavan = t7trk01-kdtav * h_fact.

* Ek ücretler
* loop at l_it9ykd.       "IS 22.01.2003
  CLEAR l_it7trk02.
  LOOP AT l_it7trk02.
    IF l_it7trk02-rtkum GT 12.
      l_it7trk02-rtkum = 12.
    ENDIF.
    IF l_it7trk02-rtkum GT 0.
* Prim gibi ücretler (T9YKD-BETRG = 0, T9YKD-RTKUM > 0)
      IF zsonbrd EQ space.
        k_beg = k_end = iper-fire+0(6). "E.B.-REM
        k_fpper = iper-fire+0(6).
      ELSE.
        SORT rgdir BY fpper DESCENDING.
        READ TABLE rgdir INDEX 1.
        k_fpper = rgdir-fpper.
        k_beg = k_end = k_fpper.
      ENDIF.
      IF k_beg+4(2) LE l_it7trk02-rtkum.
* Bordro sonucunun bir ay öncesi kullanılır.
        k_beg+0(4) = k_beg+0(4) - 1.
        k_beg+4(2) = k_beg+4(2) + 12.
      ENDIF.
      k_beg = k_beg - l_it7trk02-rtkum + 1.
      IF k_beg+5(1) EQ space.          "not relevant
        k_beg+5(1) = k_beg+4(1).
        k_beg+4(1) = '0'.
      ENDIF.
      CLEAR k_cnt_dif.
      LOOP AT rgdir. " WHERE fpper EQ k_fpper. "geriye sayim.
*        check l_it9ykd-rtkum ge sy-tabix.
        CHECK rgdir-fpper GE k_beg.
        CHECK rgdir-fpper EQ k_fpper.
        CHECK: rgdir-srtza EQ stand OR stand EQ space.
        rx-key-pernr = iper-pernr. "IS
        UNPACK rgdir-seqnr TO rx-key-seqno.
        rp-imp-c2-tr.
        CHECK rp-imp-tr-subrc EQ 0.
* Yan Ödemeleri okurken hata çıkıyordu.
*        READ TABLE py_result-inter-rt INTO py_rt WITH KEY lgart =
*        l_it7trk02-lgart.
*     LOOP AT py_result-inter-rt WHERE lgart EQ l_it7trk02-lgart.

*        CHECK sy-subrc EQ 0.  "is

*---SGK Günü
        CLEAR lv_sgkgn.
        LOOP AT py_result-inter-rt INTO rt
                WHERE lgart EQ '/NDY'
                OR    lgart EQ '5445'
                OR    lgart EQ '5450'.
          lv_sgkgn = lv_sgkgn + rt-anzhl.
        ENDLOOP.


        LOOP AT rt WHERE lgart EQ l_it7trk02-lgart.
          l_it7trk02-cnt = l_it7trk02-cnt + 1.
* YTL Çevrimi için
          IF rgdir-fpper LE '200412' .
            CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
              EXPORTING
                client           = sy-mandt
                date             = '20050101'
                foreign_amount   = rt-betrg
                foreign_currency = 'TRL'
                local_currency   = ypb
              IMPORTING
                local_amount     = rt-betrg.

          ENDIF.
*---Kıstelli Ücret ise 30 güne tamamla.
          IF rt-lgart IN w_kistel AND lv_sgkgn NE 0.
            rt-betrg = rt-betrg / lv_sgkgn * 30.
          ENDIF.
*         l_it7trk02-betrg = l_it7trk02-betrg + py_rt-betrg.
          l_it7trk02-betrg = l_it7trk02-betrg + rt-betrg.
* Taner 14.02.2007
* bordrodan gelen değerin değiştirilmesi için badi

          DATA: l_badi_12 TYPE REF TO if_ex_hrpaytr_kidem_12.

          CALL METHOD cl_exithandler=>get_instance
            EXPORTING
              exit_name              = ''             " beklan checkman
              null_instance_accepted = '' " beklan checkman
            CHANGING
              instance               = l_badi_12.

          CALL METHOD l_badi_12->change_values
            EXPORTING
              rt    = rt[]
              lgart = l_it7trk02-lgart
            CHANGING
              betrg = l_it7trk02-betrg.

          MODIFY l_it7trk02 INDEX sy-tabix.
*        MODIFY l_it7trk02.
        ENDLOOP.
        IF k_fpper+4(2) GT 1.
          k_fpper = k_fpper - 1.
        ELSE.
          k_fpper+0(4) = k_fpper+0(4) - 1.
          k_fpper+4(2) = 12.
        ENDIF.
        IF k_fpper LT k_beg.
          EXIT.
        ENDIF.
      ENDLOOP.
* Bu k#sma dikkat.
      IF l_it7trk02-rtkum GT l_it7trk02-cnt.
      ENDIF.
      IF l_it7trk02-betrg GT 0.
        IF l_it7trk02-cnt LE l_it7trk02-rtdiv.
* A#a##daki sat#r case'de yanl## çal##t### için y#ld#zland#.
*Yerine ba#ka sat#r yaz#ld#.  "TP 23.10.2002
*         l_it9ykd-betrg = l_it9ykd-betrg / l_it9ykd-cnt.
          l_it7trk02-betrg = l_it7trk02-betrg / l_it7trk02-rtdiv.
        ELSE.
          IF l_it7trk02-rtdiv GT 0.
            l_it7trk02-betrg = l_it7trk02-betrg / l_it7trk02-rtdiv.
          ENDIF.
        ENDIF.
        PERFORM re512t USING calcmolga l_it7trk02-lgart.
        PERFORM append_rtab USING
           l_it7trk02-lgart l_it7trk02-betrg t512t-lgtxt.
      ENDIF.
    ELSE.
* Ikramiye ( T9YKD-BETRG = 0 & T9YKD-RTKUM = 0 olmali. )
      PERFORM re512t USING calcmolga l_it7trk02-lgart.
      IF l_it7trk02-rtdiv GT 0.
        l_it7trk02-betrg = iper-betrg / l_it7trk02-rtdiv.
*        l_it7trk02-betrg = rtab-betrg / l_it7trk02-rtdiv.
      ELSE.
*       l_it7trk02-betrg = iper-betrg.   "Basic Pay
        l_it7trk02-betrg = rtab-betrg.   "Basic Pay
      ENDIF.
      PERFORM append_rtab USING
             l_it7trk02-lgart l_it7trk02-betrg t512t-lgtxt.
    ENDIF.
  ENDLOOP.

* Sabit degerli (Tt7trk02-BETRG > 0) Ek gelirler.
* loop at it7trk02 where kidem eq t9y1e-kidem      "IS 22.1.2003
  LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                 AND werks EQ pernr-werks       "IS 22.1.2003
                 AND btrtl EQ pernr-btrtl       "IS 22.1.2003
                 AND   betrg GT 0.
    PERFORM re512t USING calcmolga it7trk02-lgart.
    IF NOT it7trk02-waers EQ h_curr.
      PERFORM convert_to_local_currency
      USING it7trk02-betrg rgdir-fpbeg it7trk02-waers
            h_curr it7trk02-betrg.
    ENDIF.
    PERFORM append_rtab USING
           it7trk02-lgart it7trk02-betrg t512t-lgtxt.
  ENDLOOP.

* t9yd1 tablosunda werks ve btrtl boş olduğunda okunması gerekli.
  IF sy-subrc EQ 4.                       "IS 05.02.2003
    LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                   AND   betrg GT 0
                   AND werks IS INITIAL
                   AND btrtl IS INITIAL .
      PERFORM re512t USING calcmolga it7trk02-lgart.
      IF NOT it7trk02-waers EQ h_curr.
        PERFORM convert_to_local_currency
        USING it7trk02-betrg rgdir-fpbeg it7trk02-waers
              h_curr it7trk02-betrg.
      ENDIF.
      PERFORM append_rtab USING
             it7trk02-lgart it7trk02-betrg t512t-lgtxt.
    ENDLOOP.
  ENDIF.


* Ihbar hesaplamas#.
*  CLEAR i0776.                         "IS 27.01.2003
*Yukarısı yıldızlanmadığında bazı durumlarda kıdem ve ihbar hesaplması
*hiç yapılmıyardu

  PERFORM count_iper USING iper-werks iper-btrtl.
  IF i0776-fagan NE 0.
    iper-ihgun = t7trk01-multi.
* "IS 22.10.2002 9005' eklenen yeni Gün alan#.
    IF i0776-ihbtg NE 0.
      iper-ihgun = i0776-ihbtg.
    ENDIF.
    iper-ihbar = iper-topla / 30 * iper-ihgun.
* 9005'de oran çal##m#yordu - "TP 22.10.2002
    IF i0776-prznt NE 100.
      iper-ihbar = ( iper-ihbar * i0776-prznt ) / h_fact.
    ENDIF.

    DATA: l_badi_11 TYPE REF TO if_ex_hrpaytr_kidem_11.

    CALL METHOD cl_exithandler=>get_instance
      EXPORTING
        exit_name              = ''             " beklan checkman
        null_instance_accepted = '' " beklan checkman
      CHANGING
        instance               = l_badi_11.

    DATA : ls_iper TYPE ptr07 .
    MOVE-CORRESPONDING iper TO ls_iper .

    CALL METHOD l_badi_11->change_values
      CHANGING
        iper = ls_iper.
    MOVE-CORRESPONDING ls_iper TO iper .

*    MODIFY iper.

*    PERFORM on_calc_ihbar_user_exit.
*    iper-ihbar = iper-topla / 30 * iper-ihgun.
    IF i0776-fagan EQ 2.
      iper-ihbar = iper-ihbar * -1.
    ENDIF.
  ENDIF.

ENDFORM.                               " COUNT_PRIMS

*&---------------------------------------------------------------------*
*&      Form  APPEND_IPER
*&---------------------------------------------------------------------*
FORM append_iper.
*___Hata testi yapar; yoksa personeli IPER'e ekler.
*___Checks personel and transfer it to IPER

  CLEAR hatatab.
  LOOP AT hatatab WHERE werks EQ pernr-werks
                    AND btrtl EQ pernr-btrtl
                    AND pernr EQ pernr-pernr
                    AND norml EQ 'N'.
  ENDLOOP.
  IF sy-subrc NE 0.
    COLLECT iper.
  ENDIF.

ENDFORM.                               " APPEND_IPER
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.
  IF it7trg01[] IS INITIAL.
    ULINE AT /(95).
    FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
    WRITE : / sy-vline,
     'SEÇİM SIRASINDA OLUŞAN HATALARIN LİSTESİ', 95 sy-vline.
  ELSE.
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    ULINE AT /(75).
    WRITE: / sy-vline                       NO-GAP,
                              ' '           , "NO-GAP,
           'PeAl PeAA'(pbe)                 , "NO-GAP,
           'SSK Numarası            '         , "NO-GAP,
           '             İşyerinin Adı          '   NO-GAP,
             sy-vline.
    ULINE AT /(75).
  ENDIF.
ENDFORM.                               " TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  END_OF_SELECTION
*&---------------------------------------------------------------------*
FORM end_of_selection.
  IF potkidem NE space.
    PERFORM set_gui_00.
  ELSE.
    PERFORM set_gui_10.
  ENDIF.

* Toplama dahil olup olmama kontrolü - "IS 20.01.2003
  CLEAR iper.
  LOOP AT iper WHERE ktime GE '00010000'.
*    if iper-ktime ge '00010000'.
    MOVE '1' TO iper-topdahil.
    MODIFY iper.
*      exit.
*    endif.
  ENDLOOP.

* Volkan AYHAN - PA-PAA-Masraf Yeri ... 10.08.08
  LOOP AT iper.
    READ TABLE it7trg01 WITH KEY werks = iper-werks
                                 btrtl = iper-btrtl.
    IF sy-subrc NE 0.
      DELETE iper.
    ENDIF.
  ENDLOOP.
*

  LOOP AT it7trg01.
    READ TABLE iper WITH KEY werks = it7trg01-werks
                             btrtl = it7trg01-btrtl.
    IF sy-subrc EQ 0.
      PERFORM write_t7trg01.
    ELSE.
      DELETE it7trg01.
    ENDIF.
  ENDLOOP.

  IF it7trg01[] IS INITIAL.
    PERFORM set_gui_02.
    PERFORM write_hatatablosu USING '' 'N'.
  ELSE.
    ULINE AT /1(75).
  ENDIF.

ENDFORM.                               " END_OF_SELECTION
*&---------------------------------------------------------------------*
*&      Form  TABLES_TO_ITABS
*&---------------------------------------------------------------------*
FORM tables_to_itabs.
*  PERFORM get_currency USING calcmolga
*                             h_curr

* "IS 05.04.2004 grev
*  SELECT * FROM t9ypf INTO TABLE it9ypf WHERE
*                            dtart EQ 'PF' OR dtart EQ 'FP'.
* "IS 05.04.2004 grev
  SELECT * FROM t7trg01 INTO TABLE it7trg01 WHERE
                                  werks IN pnpwerks AND
                                  btrtl IN pnpbtrtl AND
                                  begda LE kidendda AND
                                  endda GE kidendda
  ORDER BY werks btrtl.

  SELECT * FROM t7trk02 INTO TABLE it7trk02
                      WHERE begda LE kidendda AND endda GE kidendda.

ENDFORM.                               " TABLES_TO_ITABS
*&---------------------------------------------------------------------*
*&      Form  AT_USER_COMMAND
*&---------------------------------------------------------------------*
FORM at_user_command.

  DATA: BEGIN OF lt_b OCCURS 10,
          bukrs TYPE bukrs,
        END OF lt_b.
  DATA: BEGIN OF lt_p OCCURS 10,
          pernr TYPE persno,
        END OF lt_p.
*        hrpaymx_cfdi_total

  DATA: topbetrg    TYPE ptr_amaas, gentopbetrg TYPE ptr_amaas,
        topekucr    TYPE ptr_amaas, gentopekucr TYPE ptr_amaas,
        toptopla    TYPE ptr_amaas, gentoptopla TYPE ptr_amaas,
        topk1yil    TYPE ptr_amaas, gentopk1yil TYPE ptr_amaas,
        topkidem    TYPE ptr_amaas, gentopkidem TYPE ptr_amaas,
        topihbar    TYPE ptr_amaas, gentopihbar TYPE ptr_amaas,
        topkiton    TYPE ptr_amaas, gentopkiton TYPE ptr_amaas .

  CASE sy-ucomm.
    WHEN 'OLDK'.
      PERFORM old_kidem .
    WHEN 'OLDD'.
      PERFORM old_devam .
    WHEN 'RW'.
      SET SCREEN 0.  LEAVE SCREEN.
    WHEN 'LEAV'.
      SET SCREEN 0.  LEAVE SCREEN.
    WHEN 'CANC'.
      LEAVE SCREEN.
    WHEN 'MALL'.
      PERFORM check_uncheck_line USING 'X'.
    WHEN 'MDEL'.
      PERFORM check_uncheck_line USING space.
    WHEN 'ERRO'.
      PERFORM write_hatatablosu USING '' 'N'.
    WHEN 'HATA'.
      PERFORM write_hatatablosu USING '' 'W'.
*    WHEN 'WTYP' OR 'BUKR' OR 'PERS' OR 'NORM'.
    WHEN 'WTYP' OR 'BUKR'   OR 'NORM'.
      CLEAR h_pers ."SerenK 22012009
      PERFORM chk_flg.
      IF h_flg = c_on.
        CLEAR: kidemtop.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            MOVE sy-lisel+3(4) TO iperw-werks.
            MOVE sy-lisel+8(4) TO iperw-btrtl.
            APPEND iperw.
            DELETE ADJACENT DUPLICATES FROM iperw.
            m1 = space.
            CASE sy-ucomm.
              WHEN 'WTYP'.
                PERFORM set_gui_02.

                PERFORM write_potkidembtrtl_is USING it7trg01-werks
                                                     it7trg01-btrtl
                CHANGING gentopbetrg gentopekucr gentoptopla gentopk1yil
                         gentopkidem gentopkiton gentopihbar.

              WHEN 'BUKR'.
                PERFORM set_gui_02.
                SELECT SINGLE bukrs INTO lt_b-bukrs
                FROM t500p WHERE persa EQ it7trg01-werks.
                IF sy-subrc EQ 0.
                  COLLECT lt_b.
                ENDIF.

                LOOP AT lt_b.
                  PERFORM write_potkidembukrs USING lt_b-bukrs
                          CHANGING gentopbetrg gentopekucr
                                   gentoptopla gentopk1yil
                                   gentopkidem gentopihbar
                                   gentopkiton.
                ENDLOOP.

              WHEN 'NORM'.
                PERFORM set_gui_01.
                PERFORM write_norkidem2 USING it7trg01-werks
                                              it7trg01-btrtl.

            ENDCASE.
          ENDIF.
        ENDDO.




        IF NOT gentopbetrg IS INITIAL.

          IF potkidem = 'X' AND ozet NE 'X'.
            ULINE AT /1(c_259).
          ELSE.
            ULINE AT /1(c_208).
          ENDIF.
*          ULINE AT /1(199).
          FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
          PERFORM write_potkidem_gt USING 'GENEL TOPLAM'
          CHANGING gentopbetrg gentopekucr gentoptopla
                   gentopk1yil gentopkidem gentopihbar gentopkiton.


          IF potkidem = 'X' AND ozet NE 'X'.
            ULINE AT /1(c_259).
          ELSE.
            ULINE AT /1(c_208).
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE w010.                  " bitte belege markieren.
      ENDIF.




    WHEN 'PERS'.
* "IS  burası ipery olmalı!!!! 22.04.2004
      CLEAR iperw.REFRESH iperw.
      PERFORM chk_flg.
      IF h_flg = c_on.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            MOVE sy-lisel+3(4) TO iperw-werks.
            MOVE sy-lisel+8(4) TO iperw-btrtl.
            APPEND iperw.
            DELETE ADJACENT DUPLICATES FROM iperw.
            m1 = space.
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE w010.
      ENDIF.
*      clear: iper  "IS 25.10.2002 - çalışan grubunda detay göstermiyor?
      CLEAR: iper, iperc.
      PERFORM set_gui_02.

      SORT iper BY werks btrtl pernr.
      CLEAR: iperc,ipery.
      REFRESH: iperc.

* "IS 24.10.2002 - 2.giri#lede problem ç#k#yordu  -   ipery.

      PERFORM persb.
      h_pers = 'X' ."SerenK 22012009

    WHEN 'COSC'.
      CLEAR h_pers ."SerenK 22012009
      CLEAR iperw.REFRESH iperw.
      PERFORM chk_flg.
      IF h_flg = c_on.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            MOVE sy-lisel+3(4) TO iperw-werks.
            MOVE sy-lisel+8(4) TO iperw-btrtl.
            APPEND iperw.
            DELETE ADJACENT DUPLICATES FROM iperw.
            m1 = space.
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE w010.
      ENDIF.
*      clear: iper  "IS 25.10.2002 - çalışan grubunda detay göstermiyor?

      CLEAR: iper, iperc,iperk.
      PERFORM set_gui_01.
      PERFORM set_gui_02.
      SORT iper BY kostl pernr.
      PERFORM kostl.

    WHEN 'DETY'.
      PERFORM chk_flg.
      IF h_flg = c_on.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            CHECK iper-pernr NE space.
            PERFORM set_gui_01.
*            perform write_norkidem using iper-pernr.
* "IS 30.10.2002 - CAG da yanl## personel
            PERFORM write_norkidem USING sy-lisel+5(8).
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE w010.                  " bitte belege markieren.
      ENDIF.

    WHEN 'BATC'.
      PERFORM set_gui_03.
      IF batchcnt EQ 0.
        batchcnt = 1.
        PERFORM write_batchinput.
      ENDIF.
      PERFORM write_hatatablosu USING '' 'B'.
      ULINE /1(95).
      PERFORM satirformati USING 7.
      WRITE:/ sy-vline, '     TOPLU GİRDİ DOSYASININ İŞLENMESİ İÇİN',
             'TOPLU GİRDİ DOSYASINI İŞLE BASIN', 95 sy-vline.
      ULINE /1(95).
      CLEAR batchcnt.
* Taner 22.09.2005
* Online işlemler için geliştirildi.
* Herkesin sm35 yetkisi olmayabilir.

    WHEN 'ONLI'.
      PERFORM set_gui_03.
* Birden fazla kişiye online batch atması
      CLEAR iper.
      LOOP AT iper.
        PERFORM write_onlineinput.
*                                using hataturu hatatext.

      ENDLOOP.
      PERFORM write_hatatablosu USING '' 'B'.
      ULINE /1(95).
      PERFORM satirformati USING 7.
      IF kidemtop = 0.
        WRITE:/ sy-vline, '     VERİLERİNİZ SİSTEME ONLİNE OLARAK',
                'ATILMIŞTIR.', 95 sy-vline.
      ELSE.
        WRITE:/ sy-vline, '     VERİLERİNİZ SİSTEME ONLİNE OLARAK',
                kidemtop, 'HATA ILE ATILMIŞTIR.', 95 sy-vline.
      ENDIF.
      ULINE /1(95).



    WHEN 'BAT1'.

      PERFORM set_gui_04.
      IF batchcnt EQ 0.
        batchcnt = 1.
        PERFORM write_batchinput_776.
      ENDIF.
      PERFORM write_hatatablosu USING '' 'B'.
      ULINE /1(95).
      PERFORM satirformati USING 7.
      WRITE:/ sy-vline, '     TOPLU GİRDİ DOSYASININ İŞLENMESİ İÇİN',
             'TOPLU GİRDİ DOSYASINI İŞLE BASIN', 95 sy-vline.
      ULINE /1(95).
      CLEAR batchcnt.


    WHEN 'DOWN'.
      REFRESH eiper.
      PERFORM chk_flg.
      IF h_flg = c_on.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            IF h_pers = 'X' ."SerenK 22012009
              CHECK iperc-pernr NE space."SerenK 22012009
              MOVE-CORRESPONDING iperc TO eiper."SerenK 22012009
            ELSE ."SerenK 22012009
              CHECK iper-pernr NE space.
              MOVE-CORRESPONDING iper TO eiper.
            ENDIF ."SerenK 22012009
            APPEND eiper.
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE w010.                  " bitte belege markieren.
      ENDIF.
      PERFORM call_list_viewer.

    WHEN 'BTC2'.
      REFRESH bdcdata.
      CLEAR bdcdata.
      bdcdata-program  = 'SAPMSBDC'.
      bdcdata-dynpro   = '0100'.
      bdcdata-dynbegin = 'X'.
      APPEND bdcdata. CLEAR bdcdata.
      bdcdata-fnam   = 'D0100-MAPN'.
      bdcdata-fval   = 'HR KIDEM'.
      APPEND bdcdata.
      bdcdata-fnam   = 'D0100-VON'.
      WRITE sy-datum TO bdcdata-fval DD/MM/YYYY.
      APPEND bdcdata. CLEAR bdcdata.
      CALL TRANSACTION 'SM35' USING bdcdata MODE 'N'.
      LEAVE TO TRANSACTION 'SM35' AND SKIP FIRST SCREEN.
    WHEN 'WITB'.
      PERFORM user_command_witb.

    WHEN 'TRAN'.
      CLEAR: kidemtop.
      DO.
        CLEAR: m1.
        READ LINE sy-index FIELD VALUE m1.
        IF sy-subrc NE 0.
          EXIT.
        ELSE.
          CHECK m1 = 'X'.
          m1 = space.
          PERFORM set_gui_02.
          PERFORM write_transfer_list
                  USING it7trg01-werks it7trg01-btrtl.
        ENDIF.
      ENDDO.

      gv_current_screen = sy-ucomm.

    WHEN 'MALM'.
      REFRESH mmer. CLEAR mmer.
      PERFORM set_gui_02.
      DO.
        CLEAR: m1.
        READ LINE sy-index FIELD VALUE m1.
        IF sy-subrc NE 0.
          EXIT.
        ELSE.
          CHECK m1 = 'X'.
          m1 = space.
          PERFORM mmer_topla USING it7trg01-werks it7trg01-btrtl.
        ENDIF.
      ENDDO.
      PERFORM mmer_yaz.
    WHEN OTHERS.
      MESSAGE w012.
  ENDCASE.
ENDFORM.                               " AT_USER_COMMAND

*---------------------------------------------------------------------*
*       FORM set_gui_00                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_00.
  REFRESH xfcode. CLEAR xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'ONLI' TO xfcode.
  APPEND 'BAT1' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'DETY' TO xfcode.
*  APPEND 'OLDK' TO xfcode.
*  APPEND 'OLDD' TO xfcode.
  PERFORM edit_excluding_tab TABLES xfcode USING '00' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].
ENDFORM.                                                    "set_gui_00

*---------------------------------------------------------------------*
*       FORM set_gui_01                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_01.
  REFRESH xfcode. CLEAR xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'MALL' TO xfcode.
  APPEND 'MDEL' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  IF kidmtest NE space OR sy-ucomm EQ 'DETY'.
    APPEND 'BATC' TO xfcode.
    APPEND 'BAT1' TO xfcode.
    APPEND 'DOWN' TO xfcode.
    APPEND 'ONLI' TO xfcode.
    APPEND 'OLDK' TO xfcode.
    APPEND 'OLDD' TO xfcode.
  ENDIF.
  PERFORM edit_excluding_tab TABLES xfcode USING '01' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].
ENDFORM.                                                    "set_gui_01

*---------------------------------------------------------------------*
*       FORM set_gui_02                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_02.
  REFRESH xfcode. CLEAR xfcode.
  IF sy-ucomm NE 'WTYP' AND sy-ucomm NE 'PERS' AND sy-ucomm NE 'TRAN'
     AND sy-ucomm NE 'BUKR'.
    APPEND 'MALL' TO xfcode.
    APPEND 'MDEL' TO xfcode.
    APPEND 'DOWN' TO xfcode.
    APPEND 'HATA' TO xfcode.
    APPEND 'ERRO' TO xfcode.
    APPEND 'DETY' TO xfcode.
    APPEND 'OLDK' TO xfcode.
    APPEND 'OLDD' TO xfcode.
  ELSE.
    APPEND 'OLDK' TO xfcode.
    APPEND 'OLDD' TO xfcode.
  ENDIF.
  APPEND 'TRAN' TO xfcode.
  APPEND 'MALM' TO xfcode.
  APPEND 'BUKR' TO xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'ONLI' TO xfcode.
  APPEND 'BAT1' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'COSC' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  PERFORM edit_excluding_tab TABLES xfcode USING '02' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].
ENDFORM.                                                    "set_gui_02

*---------------------------------------------------------------------*
*       FORM set_gui_03                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_03.
  REFRESH xfcode. CLEAR xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'HATA' TO xfcode.
  APPEND 'MALL' TO xfcode.
  APPEND 'MDEL' TO xfcode.
  APPEND 'ERRO' TO xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'ONLI' TO xfcode.
  APPEND 'BAT1' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'COSC' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'TRAN' TO xfcode.
  APPEND 'BUKR' TO xfcode.
  APPEND 'OLDK' TO xfcode.
  APPEND 'OLDD' TO xfcode.
  PERFORM edit_excluding_tab TABLES xfcode USING '03' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].
ENDFORM.                                                    "set_gui_03

*---------------------------------------------------------------------*
*       FORM set_gui_10                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_10.
  REFRESH xfcode. CLEAR xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'ONLI' TO xfcode.
  APPEND 'BAT1' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'COSC' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  APPEND 'TRAN' TO xfcode.
  APPEND 'BUKR' TO xfcode.
*  APPEND 'OLDK' TO xfcode.
*  APPEND 'OLDD' TO xfcode.
  PERFORM edit_excluding_tab TABLES xfcode USING '10' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].
ENDFORM.                                                    "set_gui_10

*&---------------------------------------------------------------------*
*&      Form  set_gui_04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_gui_04.

  REFRESH xfcode. CLEAR xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'HATA' TO xfcode.
  APPEND 'MALL' TO xfcode.
  APPEND 'MDEL' TO xfcode.
  APPEND 'ERRO' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'COSC' TO xfcode.
  APPEND 'DETY' TO xfcode.
  PERFORM edit_excluding_tab TABLES xfcode USING '04' .
  SET PF-STATUS 'ZBYHR_P016_G' EXCLUDING xfcode[].


ENDFORM.                    " set_gui_04


*---------------------------------------------------------------------*
*       FORM call_list_viewer                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM call_list_viewer.
  IF NOT iper[] IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = g_repid
        i_structure_name   = 'IKID'
        it_fieldcat        = gt_kidem[]
*--- begin of change 04022007
        i_save             = 'A'
*--- end of change 04022007
      TABLES
*       t_outtab           = iper.
        t_outtab           = eiper.
  ENDIF.
ENDFORM.                    "call_list_viewer


*&---------------------------------------------------------------------*
*&      Form  WRITE_HATATABLOSU
*&---------------------------------------------------------------------*
FORM write_hatatablosu USING p_btrtl p_norml.
  DATA hatpernr LIKE hatatab-pernr.
  DATA hatatmp LIKE hatatab OCCURS 0 WITH HEADER LINE.

  PERFORM set_gui_02.
  LOOP AT hatatab WHERE norml EQ p_norml.
    IF p_btrtl NE space.
      CHECK hatatab-btrtl EQ p_btrtl.
    ENDIF.
    MOVE-CORRESPONDING hatatab TO hatatmp.
    APPEND hatatmp.
  ENDLOOP.
  SORT hatatmp BY werks btrtl pernr.
  LOOP AT hatatmp.

    AT NEW btrtl.
      NEW-PAGE.
      ULINE /1(95).
      FORMAT COLOR COL_NORMAL.
      WRITE: / sy-vline, hatatmp-werks COLOR COL_HEADING,
                         hatatmp-btrtl COLOR COL_GROUP,
               it7trg01-name1, it7trg01-name2, 95 sy-vline.
      ULINE AT /1(95).
    ENDAT.
    WRITE: / sy-vline NO-GAP, '           ' RESET.

    IF hatatmp-pernr NE hatpernr.
      kidcount = kidcount + 1.
      kidemtop = kidemtop + 1.
      hatpernr = hatatmp-pernr.
      PERFORM satirformati USING 2.
      WRITE:1 sy-vline , hatatmp-pernr COLOR COL_KEY.
    ENDIF.

    WRITE: 12 sy-vline NO-GAP, (77) hatatmp-htext, 95 sy-vline.
    AT END OF btrtl.
      satirtip = 'X'.
      PERFORM satirformati USING 5.
      ULINE /(95).
      WRITE: / sy-vline, 'Bu Personel Alanında Hata',
                         'Oluşan Personel Sayısı: '  , kidcount,
            95 sy-vline.
      CLEAR kidcount.
      ULINE AT /1(95).
    ENDAT.

    AT LAST.
      FORMAT COLOR COL_GROUP.
      WRITE: / sy-vline, 'Toplam Hata Oluşan Personel Sayısı: ',
               kidemtop,  95 sy-vline.
      ULINE AT /1(95).
    ENDAT.
  ENDLOOP.
* ENDIF.
ENDFORM.                               " WRITE_HATATABLOSU
*&---------------------------------------------------------------------*
*&      Form  RE9Y1E
*&---------------------------------------------------------------------*
FORM re7trg03 USING $persg $persk.
  CHECK t7trg03-persg NE $persg OR t7trg03-persk NE $persk.
  SELECT SINGLE * FROM t7trg03 WHERE persg EQ $persg
                             AND   persk EQ $persk.
  IF sy-subrc NE 0.
    CLEAR t7trg03.
  ENDIF.
ENDFORM.                                                    " RE9Y1E
*&---------------------------------------------------------------------*
*&      Form  COUNT_IPER
*&---------------------------------------------------------------------*
FORM count_iper USING $werks $btrtl.
  DATA p_fark TYPE i.

  CLEAR iper-ekucr.
  LOOP AT rtab WHERE pernr EQ iper-pernr.
    IF rtab-lgart IS INITIAL OR rtab-lgart EQ '1100'.
*    IF rtab-lgart IS INITIAL.
      iper-betrg = rtab-betrg * h_fact.
    ELSE.
      iper-ekucr = iper-ekucr + rtab-betrg * h_fact.
    ENDIF.
  ENDLOOP.
  iper-topla = iper-betrg + iper-ekucr.
  IF iper-topla > iper-tavan.
    iper-k1yil = iper-tavan.
  ELSE.
    iper-k1yil = iper-topla.
  ENDIF.

  READ TABLE i0776 WITH KEY pernr = iper-pernr.
  IF sy-subrc EQ 0.

    IF potkidem NE space.
      DATA: l_badi_10 TYPE REF TO if_ex_hrpaytr_kidem_10.

      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name              = ''             " beklan checkman
          null_instance_accepted = '' " beklan checkman
        CHANGING
          instance               = l_badi_10.

      CALL METHOD l_badi_10->change_values
        CHANGING
          i0776 = i0776.

*      PERFORM on_potantial_wo0776_user_exit.
    ELSE.
      PERFORM hatatablosu USING
'0776 de kayıt bulunamadığı için standart değerler ile işlem yapılacak'
      'W' space.

      DATA: l_badi_09 TYPE REF TO if_ex_hrpaytr_kidem_09.

      CALL METHOD cl_exithandler=>get_instance
        EXPORTING
          exit_name              = ''             " beklan checkman
          null_instance_accepted = '' " beklan checkman
        CHANGING
          instance               = l_badi_09.

      CALL METHOD l_badi_09->change_values
        CHANGING
          i0776 = i0776.

*      PERFORM on_normal_wo0776_user_exit.
    ENDIF.
  ENDIF.
  IF i0776-knorm EQ 0.
    IF i0776-fprtg EQ 0 AND i0776-kidtg GT 30.
      iper-k1yil = iper-k1yil / 30 * i0776-kidtg.
    ELSEIF i0776-fprtg EQ 1 AND i0776-kidpr GT 100.
      iper-k1yil = iper-k1yil / 100 * i0776-kidpr.
    ENDIF.
    IF iper-k1yil > t7trk01-kdtav.
      iper-kikek = iper-k1yil - iper-tavan.
      iper-k1yil = iper-tavan.
    ENDIF.

* ZPEKIDE0 include'unun içerisini ta##nd# "TP 30.10.2002
* E#er artiky#l seçene#i i#aretlenirse k#dem hesab# 365 gün üzerinden
* yap#l#r.       TP 14.01.2003
    IF hesap NE space.
      iper-kidem = iper-kidem + ( iper-ktime+0(4) *   iper-k1yil ).
      iper-kidem = iper-kidem + ( iper-ktime+4(2) * ( iper-k1yil / 12  )
      ).
      iper-kidem = iper-kidem + ( iper-ktime+6(2) * ( iper-k1yil / 365 )
      ).
      iper-kidem = iper-kidem - ( iper-grevzar ) .
    ELSE.
      iper-kidem = iper-kidem + ( iper-ktime+0(4) *   iper-k1yil ).
      iper-kidem = iper-kidem + ( iper-ktime+4(2) * ( iper-k1yil / 12  )
      ).
      iper-kidem = iper-kidem + ( iper-ktime+6(2) * ( iper-k1yil / 360 )
      ).
      iper-kidem = iper-kidem - ( iper-grevzar ) .
    ENDIF.
  ENDIF.

  IF  biryil = 'X' AND iper-ktime+0(4) < 1 .
    iper-kidem = 0.
  ENDIF.

* Kıdem tazminatının 0'lanması.
  DATA: l_badi_08 TYPE REF TO if_ex_hrpaytr_kidem_08.

  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    CHANGING
      instance               = l_badi_08.

  DATA : ls_iper TYPE ptr07 .
  MOVE-CORRESPONDING iper TO ls_iper .
  CALL METHOD l_badi_08->change_values
    CHANGING
      iper = ls_iper.
  MOVE-CORRESPONDING ls_iper TO iper .

*  PERFORM on_compensation_user_exit.
ENDFORM.                               " COUNT_KIDEM
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTLINE
*&---------------------------------------------------------------------*
FORM write_potline.

  DATA: lv_atext TYPE abktx.


  SELECT SINGLE atext INTO lv_atext FROM t549t
            WHERE sprsl EQ sy-langu
             AND abkrs EQ iper-abkrs.

  WRITE: / sy-vline       , m1             AS CHECKBOX ,
           sy-vline NO-GAP, iper-pernr     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-kostl     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, lv_atext       NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-gbdat     NO-GAP COLOR COL_KEY,
* Geliştirme Taner 23.12.2005
           sy-vline NO-GAP, iper-sskno(18) NO-GAP COLOR COL_KEY.
  IF iper-gesch EQ '1'.
    WRITE: sy-vline NO-GAP, ' Erkek  '     NO-GAP COLOR COL_KEY.
  ELSE.
    WRITE: sy-vline NO-GAP, ' Kadın  '     NO-GAP COLOR COL_KEY.
  ENDIF.
  WRITE :  sy-vline NO-GAP, iper-hire      NO-GAP,
           sy-vline NO-GAP, iper-gtime     NO-GAP,
           sy-vline NO-GAP, iper-ktime     NO-GAP, sy-vline NO-GAP.

  IF potkidem = 'X' AND ozet NE 'X'.
    IF h_fact EQ 100.
      WRITE:
             (16) iper-betrg CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-ekucr CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-topla CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-k1yil CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-kiton CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-ihbar CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
    ELSE.
      WRITE:  (16) iper-betrg CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-ekucr CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-topla CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-k1yil CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-kidem CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-kiton CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-ihbar CURRENCY h_curr NO-GAP, sy-vline.
    ENDIF.

  ELSE.
    IF h_fact EQ 100.
      WRITE:
*             (16) iper-betrg CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
*             (16) iper-ekucr CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
*             (16) iper-topla CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-k1yil CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-kiton CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iper-ihbar CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
    ELSE.
      WRITE:
*              (16) iper-betrg CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
*              (16) iper-ekucr CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
*              (16) iper-topla CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-k1yil CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-kidem CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-kiton CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iper-ihbar CURRENCY h_curr NO-GAP, sy-vline.
    ENDIF.
  ENDIF .
  HIDE iper.
ENDFORM.                               " WRITE_POTLINE
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
FORM write_pottoplam USING  p_tptext p_kisi
                  CHANGING  $betrg
                            $ekucr
                            $topla
                            $k1yil
                            $kidem
                            $kiton
                            $ihbar.

  IF potkidem = 'X' AND ozet NE 'X'.
    IF h_fact EQ 100.
      WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
          AT c_140(1)  ''  NO-GAP,
             (16) $betrg CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $ekucr CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $topla CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $k1yil CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $kidem CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $kiton CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $ihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_259 sy-vline.
    ELSE.
      WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
          AT c_140(1)  ''  NO-GAP,
              (16) $betrg CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $ekucr CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $topla CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $k1yil CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $kidem CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $kiton CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $ihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_259 sy-vline.
    ENDIF.

    ULINE AT /1(c_259).
  ELSE.
    IF h_fact EQ 100.
      WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
          AT c_140(1) '' NO-GAP,
*             (16) iper-betrg CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
*             (16) iper-ekucr CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
*             (16) iper-topla CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) $k1yil CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $kidem CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $kiton CURRENCY h_curr NO-ZERO NO-GAP,
             (16) $ihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_208 sy-vline.
    ELSE.
      WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
          AT c_140(1) '' NO-GAP,
*              (16) iper-betrg CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
*              (16) iper-ekucr CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
*              (16) iper-topla CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) $k1yil CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $kidem CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $kiton CURRENCY h_curr NO-ZERO NO-GAP,
              (16) $ihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_208 sy-vline.
    ENDIF.
    ULINE AT /1(c_208).
  ENDIF .

ENDFORM.                               " WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
*&      Form  WRITE_NORKIDEM
*&---------------------------------------------------------------------*
FORM write_norkidem USING   p_pernr.

  DATA ip_pernr LIKE pnppernr OCCURS 1 WITH HEADER LINE.
  RANGES ip_hired FOR pnpbegda.


  IF p_pernr NE space.
    ip_pernr-sign   = 'I'.
    ip_pernr-option = 'EQ'.
    ip_pernr-low    =  p_pernr.
    APPEND ip_pernr.
  ENDIF.

*  IF p_hired NE space.
*    ip_hired-sign   = 'I'.
*    ip_hired-option = 'EQ'.
*    ip_hired-low    =  p_hired.
*    APPEND ip_hired.
*  ENDIF.

  IF gv_current_screen EQ 'TRAN'.
    LOOP AT ipersum WHERE pernr IN ip_pernr
                    AND   hire IN ip_hired.

      iper = ipersum. "Add by VS on 08.01.2014

      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      READ TABLE it7trg01 WITH KEY werks = iper-werks
                                 btrtl = iper-btrtl.
      PERFORM write_blokkidem.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      PERFORM write_blokbetrg.
    ENDLOOP.
  ELSE.
    LOOP AT iper WHERE pernr IN ip_pernr.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      PERFORM write_blokkidem.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      PERFORM write_blokbetrg.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " WRITE_NORKIDEM
*&---------------------------------------------------------------------*
*&      Form  WRITE_KIDEMBLOK
*&---------------------------------------------------------------------*
FORM write_blokkidem.
  NEW-PAGE.
  WRITE: / sy-vline, 'Personel Sicil No :', iper-pernr  ,
        69 sy-vline.


  WRITE: / sy-vline, 'Adı ve Soyadı     :', iper-ename  ,
        69 sy-vline.

  IF iper-gesch EQ '1'.
    WRITE: / sy-vline, 'Cinsiyeti         :', 'Erkek' ,
          69 sy-vline.
  ELSE.
    WRITE: / sy-vline, 'Cinsiyeti         :', 'Kadın' ,
          69 sy-vline.

  ENDIF.


  WRITE: / sy-vline, 'Ücret Tutarı      :', iper-bazms LEFT-JUSTIFIED , iper-mcurr LEFT-JUSTIFIED,
  iper-maastx LEFT-JUSTIFIED,
         69 sy-vline.


  WRITE: / sy-vline, 'TC Kimlik No      :', iper-merni  ,
         69 sy-vline.


* Taner Yeni bilgiler Eklendi. 26.09.2005

  WRITE: / sy-vline, 'Görevi            :', iper-plstx  ,
          69 sy-vline.

  IF norkidem EQ 'X'.
    WRITE: / sy-vline, 'Çıkış Sebebi      :', iper-mgtxt  ,
             69 sy-vline.
  ENDIF.

  WRITE: / sy-vline, 'İşyeri            :', it7trg01-name1,
        69 sy-vline.
  WRITE: / sy-vline, 'İşyeri Ünvanı     :', it7trg01-name2,
        69 sy-vline.
  WRITE: / sy-vline, 'İşyeri Adresi     :', it7trg01-stras,
        69 sy-vline.
  WRITE: / sy-vline,                        it7trg01-stret
                                      UNDER it7trg01-name1,
        69 sy-vline.

  DATA: BEGIN OF l_dd07v OCCURS 100.
          INCLUDE STRUCTURE dd07v.
  DATA: END OF l_dd07v.
  DATA : d_city(4).

  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      domname         = 'PTR_CITY'
      text            = 'X'
      fill_dd07l_tab  = ''
    TABLES
      values_tab      = l_dd07v
    EXCEPTIONS
      no_values_found = 1
      OTHERS          = 2.

  d_city = it7trg01-city.
  READ TABLE l_dd07v WITH KEY domvalue_l = d_city.
  .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "özal fazladan boşluk
  DATA lv_city TYPE char15.
  lv_city  = l_dd07v-ddtext.

  WRITE: / sy-vline,                        it7trg01-pfach
                                      UNDER it7trg01-name1,
                                            it7trg01-sdist,
                                            lv_city ,
        69 sy-vline.
  ULINE AT /(69).

  WRITE:/  sy-vline, 6  'Ücret Tipi',
                        'Ücret Tipi Açıklaması',
                     54 'Ü.Tipi Tutarı',
        69 sy-vline.
  ULINE AT /(69).
  LOOP AT rtab WHERE pernr EQ iper-pernr.
    WRITE: / sy-vline, 12 rtab-lgart,
                          rtab-lgtxt, '   ',
                          rtab-betrg  CURRENCY h_curr,
             sy-vline.
  ENDLOOP.
  ULINE AT /(69).
  WRITE: / sy-vline, 'Toplam miktar', iper-topla  UNDER rtab-betrg
                                      CURRENCY h_curr,
         69 sy-vline.
  WRITE: / sy-vline, 'Kıdem tavanı   ', 47 iper-tavan
                                      CURRENCY h_curr,
         69 sy-vline.
  WRITE: / sy-vline, 'Kidem hesaplamasına esas miktar',
                                      iper-k1yil UNDER rtab-betrg
                                      CURRENCY h_curr,
        69 sy-vline.
  ULINE AT /(69).
  IF iper-fchire IS NOT INITIAL .
    WRITE: / sy-vline, 'Çalıştığı zaman dilimi:',
                                     44 iper-fchire, '-' , iper-fire,
          69 sy-vline.

  ELSE.
    WRITE: / sy-vline, 'Çalıştığı zaman dilimi:',
                                     44 iper-hire, '-' , iper-fire,
          69 sy-vline.

  ENDIF.
  WRITE: / sy-vline, 'Part-Time süresi   :'  ,
                                   42 iper-ptime+0(4) NO-ZERO, 'Yıl',
                                      iper-ptime+4(2) NO-ZERO, 'Ay ',
                                      iper-ptime+6(2) NO-ZERO, 'Gün',
        69 sy-vline.
* Yanlış anlamaları anlamak için
*esast = fultime zamanı
*ftime = esast - gtime. Kıdem süresi - Kıdeme Esas Alınmayan süre

  WRITE: / sy-vline, 'Full-Time süresi   :'  ,
*                                   42 iper-ftime+0(4) NO-ZERO, 'Yıl',
*                                      iper-ftime+4(2) NO-ZERO, 'Ay ',
*                                      iper-ftime+6(2) NO-ZERO, 'Gün',
                                   42 iper-esast+0(4) NO-ZERO, 'Yıl',
                                      iper-esast+4(2) NO-ZERO, 'Ay ',
                                      iper-esast+6(2) NO-ZERO, 'Gün',

        69 sy-vline.
  WRITE: / sy-vline,  'Esas alınmayan süre:'  ,
                                   42 iper-gtime+0(4) NO-ZERO, 'Yıl' ,
                                    iper-gtime+4(2) NO-ZERO, 'Ay ' ,
                                      iper-gtime+6(2) NO-ZERO, 'Gün' ,
        69 sy-vline.

*___Kıdemden çıkartılan miktarı göstermek için yapılmıştır.
*___Shows the deducted part from seniority amount

  WRITE: / sy-vline,  'Kıdemden çıkartılan(Grev / Lokavt):'  ,
                        39 iper-grevzar  CURRENCY h_curr, h_curr,
   69 sy-vline.
  ULINE AT /(69).


  WRITE: / sy-vline,  'Kıdeme esas Süre:'  ,
                                   42 iper-ktime+0(4) NO-ZERO, 'Yıl',
                                      iper-ktime+4(2) NO-ZERO, 'Ay ',
                                      iper-ktime+6(2) NO-ZERO, 'Gün',
*  WRITE: / sy-vline,  'Kıdeme esas Süre:'  ,
*                                   42 iper-ftime+0(4) NO-ZERO, 'Yıl',
*                                      iper-ftime+4(2) NO-ZERO, 'Ay ',
*                                      iper-ftime+6(2) NO-ZERO, 'Gün',
*



   69 sy-vline.
  ULINE AT /(69).

ENDFORM.                               " WRITE_KIDEMBLOK
*&---------------------------------------------------------------------*
*&      Form  WRITE_BLOKBETRG
*&---------------------------------------------------------------------*
FORM write_blokbetrg.
  DATA: gunlktop LIKE rt-betrg,
        ayliktop LIKE rt-betrg,
        yillktop LIKE rt-betrg.
  DATA: gunlk LIKE rt-betrg,
        aylik LIKE rt-betrg.
* Program artıkyıl seçeneği seçildiğinde hesaplamaları 365 gün
* üzerinden yapması gerekiyor.
  IF hesap NE space.
    gunlktop = iper-ktime+6(2) * ( iper-k1yil / 365 ) / h_fact.
    ayliktop = iper-ktime+4(2) * ( iper-k1yil / 12  ) / h_fact.
    yillktop = iper-ktime+0(4) *   iper-k1yil / h_fact.
    aylik    = ( iper-k1yil / 12 ).
    gunlk    = ( iper-k1yil / 365 ).
  ELSE.
    gunlktop = iper-ktime+6(2) * ( iper-k1yil / 360 ) / h_fact.
    ayliktop = iper-ktime+4(2) * ( iper-k1yil / 12  ) / h_fact.
    yillktop = iper-ktime+0(4) *   iper-k1yil / h_fact  .
    aylik    = ( iper-k1yil / 12 ).
    gunlk    = ( iper-k1yil / 360 ).
  ENDIF.

*___Kıdemden damga vergisinin düşülmesi
  DATA: net_kidem      LIKE iper-kidem,
        damga_kidem    LIKE iper-kidem,
        damga_vergi    LIKE iper-kidem,
        kullanilan_vrg LIKE iper-kidem,
        brut_kidem     LIKE iper-kidem,
        damga_muaf     LIKE iper-kidem.
  DATA  ls_rt           TYPE  pc207.

  IF p_net EQ 'X'.
    SELECT SINGLE * FROM t7trp02 WHERE begda LE kidendda
                             AND endda GE kidendda.

    SELECT SINGLE * FROM t7trg04 WHERE werks = iper-werks
                                   AND btrtl = iper-btrtl.

    SELECT SINGLE * FROM t7trs02 WHERE grssk = t7trg04-grssk
                                   AND ssgrp = p0769-ssgrp
                                   AND sskod = p0769-sskod
                                   AND begda LE kidendda
                                   AND endda GE kidendda.

*   damga_kidem = iper-kidem * t7trp02-bonst. STAMP
    damga_kidem = iper-kidem * t7trp02-stamp.
    damga_vergi = t7trs02-asucr * t7trp02-stamp.
    rt[] = py_result-inter-rt[].

    IF kidendda+0(4) => '2022'.
      READ TABLE rt INTO ls_rt WITH KEY lgart = kidu.
      IF sy-subrc = 0.
        LOOP AT rt WHERE lgart = '/103'.
          brut_kidem = brut_kidem + rt-betrg.
        ENDLOOP.
        kullanilan_vrg = ( brut_kidem - iper-kidem ) * t7trp02-stamp.

        IF kullanilan_vrg > damga_vergi.
          kullanilan_vrg = damga_vergi.
        ENDIF.

      ELSE.
        LOOP AT rt WHERE lgart = '/DMM'.
          kullanilan_vrg = kullanilan_vrg + rt-betrg.
        ENDLOOP.
      ENDIF.


      damga_muaf  = damga_vergi - kullanilan_vrg.
      damga_kidem = damga_kidem - damga_muaf.
      IF damga_kidem < 0.
        damga_kidem = 0.
      ENDIF.
    ENDIF.

    net_kidem   = iper-kidem - damga_kidem.
  ENDIF.

* iper-kidem


  WRITE: / sy-vline, '    Yıl:', iper-ktime+0(4), 19 '*',
                                 iper-k1yil
                                          CURRENCY h_curr, '=',
                       47 yillktop        CURRENCY h_curr,
        69 sy-vline.

  WRITE: / sy-vline, '     Ay:', iper-ktime+4(2), 19 '*',
                          aylik           CURRENCY h_curr, '=',
                       47 ayliktop        CURRENCY h_curr,
        69 sy-vline.

  WRITE: / sy-vline, '    Gün:', iper-ktime+6(2), 19 '*',
                          gunlk           CURRENCY h_curr, '=',
                       47 gunlktop        CURRENCY h_curr,
        69 sy-vline.
  ULINE AT /(69).

  IF iper-ktime GE '00010000' .
    FORMAT COLOR COL_TOTAL.
    PERFORM write_footer1 USING gunlktop net_kidem damga_kidem kullanilan_vrg damga_muaf.
  ELSE.
    FORMAT COLOR COL_NEGATIVE.
    PERFORM write_footer1 USING gunlktop net_kidem damga_kidem kullanilan_vrg damga_muaf.
  ENDIF.
  ULINE AT /(69).

  IF iper-ihgun GT 0 AND iper-ihbar NE 0.                   "gt

    WRITE: / sy-vline, 'İhbar hesaplamasına esas miktar',
                     47 iper-topla            CURRENCY h_curr,
          69 sy-vline.
    WRITE: / sy-vline, 'İhbar günü',
                        iper-ihgun RIGHT-JUSTIFIED
                                   UNDER iper-topla NO-ZERO,
          69 sy-vline.
    ULINE AT /(69).

    IF iper-ktime GE '00010000' .
      FORMAT COLOR COL_TOTAL.
      PERFORM write_footer2.
    ELSE.
      FORMAT COLOR COL_NEGATIVE.
      PERFORM write_footer2.
    ENDIF.
  ENDIF.

ENDFORM.                               " WRITE_BLOKBETRG
*&---------------------------------------------------------------------*
*&      Form  LOOP_FOR_BATCH
*&---------------------------------------------------------------------*
FORM loop_for_batch_0776.
  LOOP AT iper.
    READ TABLE i0776 WITH KEY pernr = iper-pernr.
    IF sy-subrc EQ 0.
      IF iper-kidem GT 0.
*        IF recalckd EQ 'X'.
        IF iper-ktime GE '00010000' .
          PERFORM batch_input_0776 USING 'K'
                                  iper-kidem iper-pernr
                                  iper-hire iper-fire
                                  h_curr.

          PERFORM hatatablosu USING
          'KIDEM: Kıdem Ücreti Eklendi:' 'B' iper-kidem.
        ENDIF.

        IF iper-ihgun GT 0 AND iper-ihbar NE 0.
          PERFORM batch_input_0776 USING 'I'
                                 iper-kidem iper-pernr
                                  iper-hire iper-fire
                                  h_curr.

          PERFORM hatatablosu USING
                  'IHBAR: İhbar Turarı Eklendi:' 'B' iper-ihbar.
          PERFORM hatatablosu USING
          'IHBAR: Toplu Girdi Oluşturuldu:' 'B' ihblgart.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " LOOP_FOR_BATCH


*&---------------------------------------------------------------------*
*&      Form  WRITE_BATCHINPUT
*&---------------------------------------------------------------------*
FORM write_batchinput.
  IF potkidem IS INITIAL.
    IF kidmtest IS INITIAL.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'Y'
          titel         = '(0015) Kayıt Yaratılsın mı?'
          textline1     = 'Seçilen Pesoneller için Bilgi Tipi 0015 de'
          textline2     = 'Kayıt yaratmak istediğinize Emin misiniz?'
        IMPORTING
          answer        = p_confrm.

      IF p_confrm EQ 'J' OR p_confrm EQ 'Y'.
        PERFORM batch_open USING 'HR KIDEM'.
        LOOP AT iper.
          IF iper-ihbar LT 0.
            iper-ihbar = iper-ihbar * -1.
            MODIFY iper.
          ENDIF.
        ENDLOOP.
*        PERFORM ue_vor_batch_mappe.

* BADI
        DATA: l_badi_03 TYPE REF TO if_ex_hrpaytr_kidem_03.

        CALL METHOD cl_exithandler=>get_instance
          EXPORTING
            exit_name              = ''             " beklan checkman
            null_instance_accepted = '' " beklan checkman
          CHANGING
            instance               = l_badi_03.

        DATA : ls_iper TYPE ptr07 .
        MOVE-CORRESPONDING iper TO ls_iper .
        CALL METHOD l_badi_03->change_values
          CHANGING
            iper = ls_iper.
*
        MOVE-CORRESPONDING ls_iper TO iper .
        PERFORM loop_for_batch.
        CALL FUNCTION 'BDC_CLOSE_GROUP'.
        MESSAGE i030 WITH 'HR KIDEM'.
      ENDIF.
    ELSE.
      MESSAGE w031.
    ENDIF.
  ELSE.
    MESSAGE w037.
  ENDIF.
ENDFORM.                               " WRITE_BATCHINPUT
*&---------------------------------------------------------------------*
*&      Form  F4_POPUP_FOR_PERIOD
*&---------------------------------------------------------------------*
FORM f4_popup_for_period.
  DATA: BEGIN OF xdynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF xdynpfields.
  DATA: returncode LIKE sy-subrc,
        monat      LIKE isellist-month,
        hlp_repid  LIKE sy-repid.
  FIELD-SYMBOLS: <feld>.

  GET CURSOR FIELD xdynpfields-fieldname.
  APPEND xdynpfields.
  hlp_repid = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = hlp_repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = xdynpfields.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_TRPER_INPUT'
      EXPORTING
        input  = xdynpfields-fieldvalue
      IMPORTING
        output = monat.
    IF monat IS INITIAL.
      monat = sy-datlo(6).
    ENDIF.
    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        actual_month   = monat
      IMPORTING
        selected_month = monat
        return_code    = returncode.
    IF sy-subrc = 0 AND returncode = 0.
      ASSIGN (xdynpfields-fieldname) TO <feld>.
      <feld> = monat.
    ENDIF.
  ENDIF.

ENDFORM.                               " F4_POPUP_FOR_PERIOD
*&---------------------------------------------------------------------*
*&      Form  WRITE_FOOTER1
*&---------------------------------------------------------------------*
FORM write_footer1 USING gunlktop net_kidem damga_kidem kullanilan_vrg damga_muaf.
  WRITE: / sy-vline,      'Kidem       : '  ,
        47 iper-kidem                   CURRENCY h_curr,
        69 sy-vline.
  IF p_net EQ 'X'.
    WRITE: / sy-vline,      'Kidem damga : '  ,
          47 damga_kidem                  CURRENCY h_curr,
          69 sy-vline.
*    IF kidendda+0(4) => '2022'.
*      WRITE: / sy-vline,      'Bordroda kullanilan damga   : '  ,
*         47 kullanilan_vrg              CURRENCY h_curr,
*         69 sy-vline.
*      WRITE: / sy-vline,      'Damga vergisi muafiyet   : '  ,
*         47 damga_muaf                  CURRENCY h_curr,
*         69 sy-vline.
*    ENDIF.
    WRITE: / sy-vline,      'Kidem net   : '  ,
          47 net_kidem                   CURRENCY h_curr,
          69 sy-vline.
  ENDIF.
  IF iper-kikek GT 0.
    WRITE: / sy-vline,    'Ek Ücret: '  ,
                        21 gunlktop     ,
                        47 iper-kikek   CURRENCY h_curr,
          69 sy-vline.
  ENDIF.
ENDFORM.                               " WRITE_FOOTER1

*&---------------------------------------------------------------------*
*&      Form  WRITE_FOOTER2
*&---------------------------------------------------------------------*
FORM write_footer2.
  WRITE: / sy-vline, 'İhbar   : ' ,
                      iper-ihbar             CURRENCY h_curr
                                             UNDER iper-topla,
       69 sy-vline.
  ULINE AT /(69).
ENDFORM.                               " WRITE_FOOTER2
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH3
*&---------------------------------------------------------------------*
FORM check_tarih3.

  rp-provide-from-last p0041 space h_hire h_fire.
  DATA: dat00 LIKE p0041-dat01,
        dar00 LIKE p0041-dar01.
  DO VARYING dat00 FROM p0041-dat01 NEXT p0041-dat02
       VARYING dar00 FROM p0041-dar01 NEXT p0041-dar02.
    IF dar00 NE space.
      IF dar00 = inf41.
        h_hire = dat00.
        CLEAR dat00.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                               " CHECK_TARIH3

*---------------------------------------------------------------------*
*       FORM FIELDCAT_INIT                                            *
*---------------------------------------------------------------------*
FORM fieldcat_init USING rt_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  CONSTANTS: c_len TYPE i VALUE 15.
* Initialization of additional fields and attributes to structure field
*   Additional  key field(s)
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'WERKS'.
  ls_fieldcat-key             =  'X'.
  ls_fieldcat-seltext_l       =  'Per.A'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   5.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'BTRTL'.
  ls_fieldcat-key             =  'X'.
  ls_fieldcat-seltext_l       =  'Pe.AA'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   5.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'PERSG'.
  ls_fieldcat-key             =  'X'.
  ls_fieldcat-seltext_l       =  'C.G'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   3.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'PERSK'.
  ls_fieldcat-key             =  'X'.
  ls_fieldcat-seltext_l       =  'CAG'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   3.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'KOSTL'.
  ls_fieldcat-key             =  'X'.
  ls_fieldcat-seltext_l       =  'Masraf Yeri'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   10.
  APPEND ls_fieldcat TO rt_fieldcat.

*   Hidden field(s)
* Taner 26.01.2006
* Asagısı kaldırılmaz ıse 5.0 versıyonunda hata cikiyor.
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname       =  'PROVI'.
*  ls_fieldcat-no_out          =  'X'.
*  ls_fieldcat-no_sum          =  'X'.
*  ls_fieldcat-seltext_l       =  'Sehir'.
*  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'PERNR'.
  ls_fieldcat-seltext_l       =  'Pers.no:'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'ENAME'.
  ls_fieldcat-seltext_l       =  'Adi ve Soyadi'.
  ls_fieldcat-no_sum          =  'X'.
  ls_fieldcat-outputlen       =   40.
  APPEND ls_fieldcat TO rt_fieldcat.
* Yeni alan eklenmesi Taner 28.12.2005
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'SSKNO'.
  ls_fieldcat-seltext_l       =  'SSK numarası'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'CINS'.
  ls_fieldcat-seltext_l       =  'Cinsiyet'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.


  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'HIRE'.
  ls_fieldcat-seltext_l       =  'Ise giris t'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'FIRE'.
  ls_fieldcat-seltext_l       =  'Is.ayrilis'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'PTIME'.
  ls_fieldcat-seltext_l       =  'Part-Time'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'FTIME'.
  ls_fieldcat-seltext_l       =  'Full-Time'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'KTIME'.
  ls_fieldcat-seltext_l       =  'Kidem-Time'.
  ls_fieldcat-no_sum          =  'X'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'GTIME'.
  ls_fieldcat-seltext_l       =  'Grev-Time'.
  APPEND ls_fieldcat TO rt_fieldcat.
* Taner 26.01.2006
* Asagısı kaldırılmaz ıse 5.0 versıyonunda hata cikiyor.
*  CLEAR ls_fieldcat.
*  ls_fieldcat-fieldname       =  'ESKID'.
*  ls_fieldcat-seltext_l       =  'Es.Kid'.
*  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
*  ls_fieldcat-datatype         =  'BETRG'.
  ls_fieldcat-fieldname       =  'BETRG'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Temel ücret'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'EKUCR'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Ek Ücretler'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'TOPLA'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Toplamı'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'KIDEM'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Kidemi'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'IHGUN'.
  ls_fieldcat-seltext_l       =  'Ihb.gün'.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'IHBAR'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Ihb.Miktari'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'TAVAN'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Kid.Tavani'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.
  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'K1YIL'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Yil.Kid.mikt.'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname       =  'KIKEK'.
  ls_fieldcat-currency        =  h_curr.
  ls_fieldcat-seltext_l       =  'Ek Kidem'.
  ls_fieldcat-outputlen       =   c_len.
  APPEND ls_fieldcat TO rt_fieldcat.

ENDFORM.                               " fieldcat_init



*
*&---------------------------------------------------------------------*
*&      Form  SET_FIRST_CONDITIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_first_conditions.

*-> SK insertion 18112008
  IF p_papaa NE space.
    selectiontype = 2.
  ELSEIF p_sskno NE space.
    selectiontype = 3.
  ENDIF.
*-< SK insertion 18112008

  h_fper1+0(6) = norkitar.
  h_begda+0(6) = h_fper1.
  h_begda+6(2) = '01'.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = h_begda
    IMPORTING
      last_day_of_month = h_endda.

*---before month
  h_begda = h_begda - 1.
  h_fper0 = h_begda+0(6).
  ADD 1 TO h_begda.

  SELECT * FROM t7trg01 INTO TABLE it7trg01 WHERE
                            werks IN pnpwerks AND
                            btrtl IN pnpbtrtl AND
                            begda LE h_endda AND
                            endda GE h_begda.

ENDFORM.                               " SET_FIRST_CONDITIONS
*&---------------------------------------------------------------------*
*&      Form  REORGANISEIPER
*&---------------------------------------------------------------------*
FORM reorganiseiper.
  LOOP AT iperw.
    LOOP AT iper WHERE werks EQ iperw-werks AND
                       btrtl EQ iperw-btrtl.

      MOVE-CORRESPONDING iper TO iperc.
      APPEND iperc.
      CLEAR iper.
    ENDLOOP.
  ENDLOOP.
  CLEAR iperc.
  SORT iperc BY persg persk .
  LOOP AT iperc.
    ON CHANGE OF iperc-persg.
      MOVE-CORRESPONDING iperc TO ipery.
      APPEND ipery.
      DELETE ADJACENT DUPLICATES FROM ipery.
    ENDON.
  ENDLOOP.

ENDFORM.                               " REORGANISEIPER
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTLINE_CA
*----------------------------------------------------------------------*
FORM write_potline_ca.

  DATA: lv_atext TYPE abktx.
  SELECT SINGLE atext INTO lv_atext FROM t549t
            WHERE sprsl EQ sy-langu
             AND abkrs EQ iperc-abkrs.

  WRITE: / sy-vline       , m1             AS CHECKBOX ,
           sy-vline NO-GAP, iperc-pernr     NO-GAP ,"COLOR COL_KEY,
           sy-vline NO-GAP, iperc-ename(21) NO-GAP ,"COLOR COL_KEY,
           sy-vline NO-GAP, iperc-kostl     NO-GAP ,"COLOR COL_KEY,
           sy-vline NO-GAP, lv_atext        NO-GAP ,"COLOR COL_KEY,
           sy-vline NO-GAP, iperc-gbdat     NO-GAP ,"COLOR COL_KEY,
* Geliştirme Taner 23.12.2005
           sy-vline NO-GAP, iperc-sskno(18) NO-GAP." COLOR COL_KEY.
  IF iperc-gesch EQ '1'.
    WRITE: sy-vline NO-GAP, ' Erkek  '     NO-GAP ." COLOR COL_KEY.
  ELSE.
    WRITE: sy-vline NO-GAP, ' Kadın  '     NO-GAP." COLOR COL_KEY.
  ENDIF.
  WRITE :  sy-vline NO-GAP, iperc-hire      NO-GAP,
           sy-vline NO-GAP, iperc-gtime     NO-GAP,
           sy-vline NO-GAP, iperc-ktime     NO-GAP, sy-vline NO-GAP.

  IF potkidem = 'X' AND ozet NE 'X'.
    IF h_fact EQ 100.
      WRITE:
             (16) iperc-betrg CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-ekucr CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-topla CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-k1yil CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-kiton CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-ihbar CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
    ELSE.
      WRITE:  (16) iperc-betrg CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-ekucr CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-topla CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-k1yil CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-kidem CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-kiton CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-ihbar CURRENCY h_curr NO-GAP, sy-vline.
    ENDIF.

  ELSE.
    IF h_fact EQ 100.
      WRITE:
             (16) iperc-k1yil CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-kiton CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
             (16) iperc-ihbar CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
    ELSE.
      WRITE:
              (16) iperc-k1yil CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-kidem CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-kiton CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
              (16) iperc-ihbar CURRENCY h_curr NO-GAP, sy-vline.
    ENDIF.
  ENDIF .
  HIDE iperc.
ENDFORM.                               " WRITE_POTLINE_PA
*&---------------------------------------------------------------------*
*&      Form  A
*&---------------------------------------------------------------------*
FORM write_potkidem_ca USING p_tptext
                    CHANGING topbetrg
                             topekucr
                             toptopla
                             topk1yil
                             topkidem
                             topihbar
                             topkiton.


  DATA : c_scnb TYPE i.
  IF potkidem = 'X' AND ozet NE 'X'.
    c_scnb = c_259.
  ELSE.
    c_scnb = c_208.
  ENDIF.

  IF potkidem = 'X' AND ozet NE 'X'.
    IF h_fact EQ 100.
      WRITE: / sy-vline, p_tptext,
           AT c_140(1)  ''  NO-GAP,
                   (16) topbetrg CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) topekucr CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) toptopla CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) topk1yil CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) topkidem CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) topkiton CURRENCY h_curr NO-ZERO NO-GAP ,
                   (16) topihbar CURRENCY h_curr NO-ZERO NO-GAP ,
          AT c_scnb sy-vline.
    ELSE.
      WRITE: / sy-vline, p_tptext,
           AT c_140(1)  ''  NO-GAP,
                   (16) topbetrg CURRENCY h_curr   NO-GAP ,
                   (16) topekucr CURRENCY h_curr   NO-GAP ,
                   (16) toptopla CURRENCY h_curr   NO-GAP ,
                   (16) topk1yil CURRENCY h_curr   NO-GAP ,
                   (16) topkidem CURRENCY h_curr   NO-GAP ,
                   (16) topkiton CURRENCY h_curr   NO-GAP ,
                   (16) topihbar CURRENCY h_curr   NO-GAP ,
          AT c_scnb sy-vline.
    ENDIF.

  ELSE.
    IF h_fact EQ 100.
      WRITE: / sy-vline, p_tptext,
           AT c_140(1) '' NO-GAP,
                   (16) topk1yil CURRENCY h_curr NO-ZERO NO-GAP,
                   (16) topkidem CURRENCY h_curr NO-ZERO NO-GAP,
                   (16) topkiton CURRENCY h_curr NO-ZERO NO-GAP,
                   (16) topihbar CURRENCY h_curr NO-ZERO NO-GAP,
          AT c_scnb sy-vline.
    ELSE.
      WRITE: / sy-vline, p_tptext,
           AT c_140(1) '' NO-GAP,
                   (16) topk1yil CURRENCY h_curr  NO-GAP,
                   (16) topkidem CURRENCY h_curr  NO-GAP,
                   (16) topkiton CURRENCY h_curr  NO-GAP,
                   (16) topihbar CURRENCY h_curr  NO-GAP,
          AT c_scnb sy-vline.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " A
*&---------------------------------------------------------------------*
*&      Form  B
*&---------------------------------------------------------------------*
FORM write_potkidem_gt USING p_tptext
                    CHANGING gentopbetrg
                             gentopekucr
                             gentoptopla
                             gentopk1yil
                             gentopkidem
                             gentopihbar
                             gentopkiton.
  DATA : lv_space LIKE iper-betrg.

  IF potkidem = 'X' AND ozet NE 'X'.
    WRITE: / sy-vline, p_tptext,
         AT c_140(1)  ''  NO-GAP,
                 (16) gentopbetrg CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentoptopla CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentopkidem CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentopihbar CURRENCY h_curr NO-ZERO NO-GAP ,
        AT c_259 sy-vline.
    WRITE: / sy-vline, space,
         AT c_140(1)  ''  NO-GAP,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentopekucr CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentopk1yil CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) gentopkiton CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP ,
        AT c_259 sy-vline.
  ELSE.
    WRITE: / sy-vline, p_tptext,
         AT c_140(1) '' NO-GAP,
                 (16) gentopk1yil CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) gentopkiton CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_208 sy-vline.
    WRITE: / sy-vline, space,
         AT c_140(1) '' NO-GAP,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) gentopkidem CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) lv_space    CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) gentopihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_208 sy-vline.

  ENDIF.


ENDFORM.                                                    " b
*&---------------------------------------------------------------------*
*&      Form  PERSB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM persb.
  DATA : c_scnb TYPE i.

  PERFORM reorganiseiper.
* "IS 30.10.2002 read table iper index 1.
  LOOP AT iper.
  ENDLOOP.
  DATA: topbetrg    LIKE iperc-betrg, gentopbetrg LIKE iperc-betrg,
        topekucr    LIKE iperc-ekucr, gentopekucr LIKE iperc-ekucr,
        toptopla    LIKE iperc-topla, gentoptopla LIKE iperc-topla,
        topk1yil    LIKE iperc-k1yil, gentopk1yil LIKE iperc-k1yil,
        topkidem    LIKE iperc-kidem, gentopkidem LIKE iperc-kidem,
        topihbar    LIKE iperc-ihbar, gentopihbar LIKE iperc-ihbar,
        topkiton    LIKE iperc-kiton, gentopkiton LIKE iperc-kiton.

  LOOP AT ipery.
    NEW-PAGE.
    SELECT SINGLE * FROM t501t WHERE sprsl EQ sy-langu AND
                                     persg EQ ipery-persg.
    IF sy-subrc NE 0. CLEAR t501t. ENDIF.


    IF potkidem = 'X' AND ozet NE 'X'.
      c_scnb = c_259.
    ELSE.
      c_scnb = c_208.
    ENDIF.

    ULINE AT /1(c_scnb).
    FORMAT COLOR COL_KEY INTENSIFIED .
    WRITE : / sy-vline,'ÇALIŞAN GRUBU', ipery-persg, t501t-ptext,
            AT c_scnb sy-vline.
    ULINE AT /1(c_scnb).

    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    PERFORM write_potkidempersk
                     USING ipery-persg
                  CHANGING topbetrg
                           topekucr
                           toptopla
                           topk1yil
                           topkidem
                           topihbar
                           topkiton
                           .

    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    ULINE AT /1(c_scnb).
    FORMAT COLOR COL_KEY INTENSIFIED .
    PERFORM write_potkidem_ca
                    USING 'ÇALIŞAN GRUBU TOPLAMI :'
                 CHANGING topbetrg
                          topekucr
                          toptopla
                          topk1yil
                          topkidem
                          topihbar
                          topkiton.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    ULINE AT /1(c_scnb).
    ADD: topbetrg TO  gentopbetrg ,
         topekucr TO  gentopekucr ,
         toptopla TO  gentoptopla ,
         topk1yil TO  gentopk1yil ,
         topkidem TO  gentopkidem ,
         topihbar TO  gentopihbar ,
         topkiton TO  gentopkiton .

    CLEAR : topbetrg , topekucr ,toptopla,
            topk1yil , topkidem, topihbar, topkiton.

  ENDLOOP.
  ULINE AT /1(c_scnb).
  FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
  PERFORM write_potkidem_gt USING 'GENEL TOPLAM'
                         CHANGING gentopbetrg
                                  gentopekucr
                                  gentoptopla
                                  gentopk1yil
                                  gentopkidem
                                  gentopihbar
                                  gentopkiton
                                  .
  ULINE AT /1(c_scnb).

ENDFORM.                               " PERSB
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMPERSK
*&---------------------------------------------------------------------*
FORM write_potkidempersk USING $persg CHANGING
       topbetrg  topekucr  toptopla topk1yil topkidem topihbar topkiton.

  DATA : c_scnb TYPE i.
  DATA: cagbetrg LIKE iperc-betrg,
        cagk1yil LIKE iperc-k1yil,
        cagekucr LIKE iperc-ekucr,
        cagkidem LIKE iperc-kidem,
        cagtopla LIKE iperc-topla,
        cagihbar LIKE iperc-ihbar,
        cagkiton LIKE iperc-kiton.

  SORT iperc BY persg persk pernr.
  CLEAR: iperc.
* Detay göstermede problem   ,iper.                      "IS 25.10.2003
  IF NOT biryil IS INITIAL.
*  "Sadece 1 yılını doldurmuş olanlar "IS 27.01.3
    LOOP AT iperc WHERE  topdahil IS INITIAL.
*      DELETE iperc.
      iperc-kidem = 0 .
    ENDLOOP.
  ENDIF.


  IF potkidem = 'X' AND ozet NE 'X'.
    c_scnb = c_259.
  ELSE.
    c_scnb = c_208.
  ENDIF.

  LOOP AT iperc WHERE  persg EQ $persg .

    ON CHANGE OF iperc-persk.
      IF cagbetrg NE 0 OR cagekucr NE 0 OR cagtopla NE 0
          OR cagk1yil NE 0 OR cagkidem NE 0 OR cagihbar NE 0.
        FORMAT COLOR COL_GROUP INTENSIFIED .
        PERFORM write_potkidem_ca USING 'ÇALIŞAN ALT GRUBU TOPLAMI :'
                               CHANGING cagbetrg
                                        cagekucr
                                        cagtopla
                                        cagk1yil
                                        cagkidem
                                        cagihbar
                                        cagkiton.
      ENDIF.
      SELECT SINGLE * FROM t503t WHERE sprsl EQ sy-langu AND
                                       persk EQ iperc-persk.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
      WRITE : / 'ÇALIŞAN ALT GRUBU', iperc-persk, t503t-ptext.
      ULINE AT /1(c_scnb).
      CLEAR :  cagbetrg , cagekucr , cagtopla , cagk1yil ,
               cagkidem , cagihbar,cagkiton .
    ENDON.

    PERFORM write_potline_ca.


* Toplama dahil olmamal# - 1 y#l#n# doldurmayanlar  "IS 21.1.2003
    IF iperc-topdahil EQ 1.
      ADD:   iperc-betrg TO topbetrg ,
             iperc-ekucr TO topekucr ,
             iperc-topla TO toptopla ,
             iperc-k1yil TO topk1yil ,
             iperc-kidem TO topkidem ,
             iperc-betrg TO cagbetrg ,
             iperc-ekucr TO cagekucr ,
             iperc-topla TO cagtopla ,
             iperc-k1yil TO cagk1yil ,
             iperc-kiton TO cagkiton,
             iperc-kidem TO cagkidem  .
    ENDIF.
    ADD: iperc-ihbar TO topihbar , iperc-ihbar TO cagihbar.
  ENDLOOP.
  FORMAT COLOR COL_GROUP INTENSIFIED .
  PERFORM write_potkidem_ca USING 'ÇALIŞAN ALT GRUBU TOPLAMI :'
                         CHANGING cagbetrg
                                  cagekucr
                                  cagtopla
                                  cagk1yil
                                  cagkidem
                                  cagihbar
                                  cagkiton.

ENDFORM.                               " WRITE_POTKIDEMPERSK
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMPERSK_IS
*&---------------------------------------------------------------------*
FORM write_potkidembtrtl_is USING    $werks
                                     $btrtl
 CHANGING topbetrg  topekucr  toptopla topk1yil topkidem topkiton topihbar.

  DATA: btrbetrg LIKE iper-betrg,
        btrekucr LIKE iper-ekucr,
        btrtopla LIKE iper-topla,
        btrk1yil LIKE iper-k1yil,
        btrkidem LIKE iper-kidem,
        btrkiton LIKE iper-kiton,
        btrihbar LIKE iper-ihbar.

  SORT iper BY werks btrtl pernr.
  CLEAR iper.

  IF NOT biryil IS INITIAL. "Sadece 1 yılını doldurmuş olanlar
    LOOP AT iper WHERE  topdahil IS INITIAL.
*      DELETE iper.
      iper-kidem = 0 .
    ENDLOOP.
  ENDIF.

  LOOP AT iper WHERE werks EQ $werks
                AND btrtl EQ $btrtl.


    AT NEW btrtl.
      SELECT * FROM t001p
             WHERE werks = iper-werks
             AND   btrtl = iper-btrtl.
      ENDSELECT.
      IF sy-subrc NE 0.
        t001p-btext = 'BULUNAMADI'.
      ENDIF.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL .

      IF potkidem = 'X' AND ozet NE 'X'.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
            AT c_259 sy-vline.
        ULINE AT /1(c_259).
      ELSE.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
             AT c_208 sy-vline.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.

    PERFORM write_potline.

    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF btrtl.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.
    AT END OF werks.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.
    AT LAST.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2 USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2 USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.
    IF iper-topdahil EQ 1.
      ADD:   iper-betrg TO btrbetrg ,
             iper-ekucr TO btrekucr ,
             iper-topla TO btrtopla ,
             iper-k1yil TO btrk1yil ,
             iper-kidem TO btrkidem ,
             iper-kiton TO btrkiton ,
             iper-ihbar TO btrihbar .

      ADD:   btrbetrg TO topbetrg , btrekucr TO topekucr ,
             btrtopla TO toptopla , btrk1yil TO topk1yil ,
             btrkidem TO topkidem , btrihbar TO topihbar,
             btrkiton TO topkiton.
    ENDIF.

  ENDLOOP.

  FORMAT COLOR COL_GROUP INTENSIFIED.


ENDFORM.                               " WRITE_POTKIDEMPERSK_IS

*&---------------------------------------------------------------------*
*&      Form  SUM
*&---------------------------------------------------------------------*
FORM sum USING $werks $btrtl $pernr CHANGING
         $betrg $ekucr $topla $k1yil $kidem $ihbar.

  LOOP AT iper WHERE topdahil  EQ 1
        AND werks EQ $werks AND btrtl EQ $btrtl AND pernr EQ $pernr.
    $betrg = $betrg + iper-betrg.
    $ekucr = $ekucr + iper-ekucr.
    $topla = $topla + iper-topla.
    $k1yil = $k1yil + iper-k1yil.
    $kidem = $kidem + iper-kidem.

  ENDLOOP.
  LOOP AT iper WHERE
          werks EQ $werks AND btrtl EQ $btrtl AND pernr EQ $pernr.
    $ihbar = $ihbar + iper-ihbar.
  ENDLOOP.


ENDFORM.                               " SUM
*&---------------------------------------------------------------------*
*&      Form  read_payroll_results
*&---------------------------------------------------------------------*
FORM read_payroll_results.

  DATA : py_months TYPE i,
         say(2).

  DATA : BEGIN OF py_perio OCCURS 0,
           fpper LIKE pc261-fpper,
           begda LIKE p0001-begda,
           endda LIKE p0001-endda,
         END OF py_perio.
  DATA :begda LIKE p0001-begda,
        endda LIKE p0001-endda.

* RGDIR Okuma
  PERFORM read_rgdir.
  SORT rgdir DESCENDING.
  READ TABLE rgdir INDEX 1.

  r_begda = rgdir-fpbeg  .
  r_yendda = r_begda.
  r_yendda+(4) = r_begda+(4) - 1.
  say = 0.

* SON bir yıldaki dönemlerin hesaplanması
* PCL2/TR  Periodların belirlemesi
  CALL FUNCTION 'HR_TR_CALC_MONTHS_AND_PERIODS'
    EXPORTING
      p_begda  = r_yendda
      p_endda  = r_begda
      p_actay  = 'X'
    IMPORTING
      p_months = py_months
    TABLES
      p_fpper  = py_perio.
  LOOP AT py_perio.
*  perform find_begda_endda_for_period using py_perio.
*  loop at py_perio.
    begda(6) = py_perio-fpper(6). begda+6(2) = 01.

    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        day_in            = begda
      IMPORTING
        last_day_of_month = endda.

*py_perio-begda+4(4) = py_perio-fpper(4). py_perio-begda(2) = 01.
*py_perio-begda+2(2) = py_perio-fpper+4(2).
*py_perio-endda+4(4) = endda(4). py_perio-endda(2) = endda+6(2).
*py_perio-endda+2(2) = py_perio-fpper+4(2).
    py_perio-begda = begda.
    py_perio-endda = endda.
    MODIFY py_perio.
  ENDLOOP.
*  SORT py_perio DESCENDING.
  SORT py_perio ASCENDING.
  CLEAR: h_hire, h_fire.
  LOOP AT py_perio.

*______PCL2/TR Okuma

    IF say GE 1. DELETE py_perio. EXIT. ENDIF.
    CLEAR py_result.
    PERFORM read_payroll USING py_perio-fpper r_srtza
                      CHANGING py_result.

*   PCL2/TR Boş/Dolu kontrolü
    CHECK sy-subrc EQ 0.

*______PCL2/TR Ay içindeki splitler
    LOOP AT py_result-inter-wpbp INTO py_wpbp WHERE aktivjn EQ 'X'.
      CLEAR: h_hire, h_fire.
      LOOP AT rgdir WHERE fpper EQ py_perio-fpper.


*______İş Durumu belirlenmesi - FHE
        PERFORM read_hifi USING py_wpbp-begda py_wpbp-endda
        selectiontype
                  py_wpbp-stat2 py_wpbp-bukrs py_wpbp-werks
                  py_wpbp-btrtl
                                                   CHANGING h_hire
                                                   h_fire.
        SORT tab_phifi DESCENDING.
        IF selectiontype EQ '1'.
          LOOP AT tab_phifi INTO wa_phifi WHERE active EQ 'X' .

            IF  h_begda BETWEEN wa_phifi-begda AND wa_phifi-endda.
              MOVE wa_phifi-begda TO h_hire.
              MOVE wa_phifi-endda TO h_fire.
            ENDIF.
          ENDLOOP.
        ELSEIF selectiontype EQ '2'.
          CHECK : py_wpbp-persg IN pnppersg, py_wpbp-persk IN pnppersk,
                  py_wpbp-werks IN pnpwerks, py_wpbp-btrtl IN pnpbtrtl.
*
        ELSEIF selectiontype EQ '3'.
          LOOP AT tab_phifi INTO wa_phifi WHERE active EQ 'X'.
            IF wa_phifi-begda BETWEEN py_wpbp-begda AND py_wpbp-endda
              OR wa_phifi-endda BETWEEN py_wpbp-begda AND py_wpbp-endda.
              MOVE wa_phifi-begda TO h_hire.
              MOVE wa_phifi-endda TO h_fire.
            ENDIF.

            IF  wa_phifi-begda LT py_wpbp-begda AND wa_phifi-endda GT
                py_wpbp-endda.
              MOVE wa_phifi-begda TO h_hire.
              MOVE wa_phifi-endda TO h_fire.
            ENDIF.

          ENDLOOP.
        ENDIF.

*______Fill HIFINT'in doldurulması
        LOOP AT tab_phifi INTO wa_phifi WHERE active EQ 'X'.
          IF wa_phifi-begda BETWEEN py_perio-begda AND py_perio-endda
            OR wa_phifi-endda BETWEEN py_perio-begda AND py_perio-endda.
            IF p_sskno EQ 'X'.
              LOOP AT it7trg01 WHERE begda LE py_perio-begda AND
                                     endda GE py_perio-endda AND
                                     werks EQ py_wpbp-werks  AND
                                     btrtl EQ py_wpbp-btrtl.
                MOVE: it7trg01-sskno TO hifint-sskno,
                     wa_phifi-begda TO hifint-h_hire,
                     wa_phifi-endda TO hifint-h_fire.

              ENDLOOP.
            ELSE.
              MOVE:   py_wpbp-werks  TO hifint-werks,
                      py_wpbp-btrtl  TO hifint-btrtl,
                      wa_phifi-begda TO hifint-h_hire,
                      wa_phifi-endda TO hifint-h_fire.
            ENDIF.
            DELETE ADJACENT DUPLICATES FROM hifint.
            COLLECT hifint.
          ENDIF.

          IF  wa_phifi-begda LT py_perio-begda AND
                 wa_phifi-endda GT py_perio-endda.
            IF p_sskno EQ 'X'.
              LOOP AT it7trg01 WHERE begda LE py_perio-begda AND
                                     endda GE py_perio-endda AND
                                     werks EQ py_wpbp-werks  AND
                                     btrtl EQ py_wpbp-btrtl.
                MOVE: it7trg01-sskno TO hifint-sskno,
                     wa_phifi-begda TO hifint-h_hire,
                     wa_phifi-endda TO hifint-h_fire.
              ENDLOOP.
            ELSE.
              MOVE:  py_wpbp-werks  TO hifint-werks,
                     py_wpbp-btrtl  TO hifint-btrtl,
                     wa_phifi-begda TO hifint-h_hire,
                     wa_phifi-endda TO hifint-h_fire.
            ENDIF.
            DELETE ADJACENT DUPLICATES FROM hifint.
            COLLECT hifint.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    SORT hifint BY h_hire h_fire DESCENDING.

  ENDLOOP.

ENDFORM.                    " read_payroll_results
*&---------------------------------------------------------------------*
*&      Form  loop_for_batch
*&---------------------------------------------------------------------*
FORM loop_for_batch.

  LOOP AT iper.

    READ TABLE i0776 WITH KEY pernr = iper-pernr.
    IF sy-subrc EQ 0.
      IF iper-kidem GT 0.
        IF iper-ktime GE '00010000' .
          REFRESH bdcdata.

          PERFORM batch_input USING i0776-lgkid iper-kidem iper-pernr
                            iper-hire iper-fire iper-fire
                                     h_curr.
          PERFORM hatatablosu USING
          'KIDEM: Kıdem Ücreti Eklendi:' 'B' iper-kidem.

          IF iper-kikek GT 0.

            PERFORM batch_input USING i0776-lgkek iper-kikek iper-pernr

                               iper-hire iper-fire iper-fire
                               h_curr.
            PERFORM hatatablosu USING
            'KIDEM: Ek Ücretler Eklendi:' 'B' iper-kikek.
          ENDIF.
          PERFORM hatatablosu USING
         'KIDEM: Toplu Girdi Oluşuruldu:' 'B' iper-fire+0(6).
        ENDIF.
      ELSE.
        PERFORM hatatablosu USING
        'KIDEM: Hata Oluştu: Kıdem Tutarı Sıfır.'
        'B' iper-fire+0(6).
      ENDIF.

      IF iper-ihgun GT 0 AND iper-ihbar NE 0.

        PERFORM batch_input USING i0776-lgihb iper-ihbar iper-pernr

                                 iper-hire iper-fire iper-fire
                                 h_curr.
        PERFORM hatatablosu USING
                   'İHBAR: Ek Ücretler Eklendi:' 'B' iper-ihbar.


      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.                    " loop_for_batch
*&---------------------------------------------------------------------*
*&      Form  loop_at_rgdir1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------
FORM kostl.

  DATA : c_scnb TYPE i.

  IF potkidem = 'X' AND ozet NE 'X'.
    c_scnb = c_259.
  ELSE.
    c_scnb = c_208.
  ENDIF.

  LOOP AT iper.
    ON CHANGE OF iper-kostl.
      MOVE-CORRESPONDING iper TO iperk.
      APPEND iperk.
      DELETE ADJACENT DUPLICATES FROM iperk.
    ENDON.
  ENDLOOP.

  LOOP AT iper.
  ENDLOOP.
  DATA: topbetrg    LIKE iperc-betrg, gentopbetrg LIKE iperc-betrg,
        topekucr    LIKE iperc-ekucr, gentopekucr LIKE iperc-ekucr,
        toptopla    LIKE iperc-topla, gentoptopla LIKE iperc-topla,
        topk1yil    LIKE iperc-k1yil, gentopk1yil LIKE iperc-k1yil,
        topkidem    LIKE iperc-kidem, gentopkidem LIKE iperc-kidem,
        topihbar    LIKE iperc-ihbar, gentopihbar LIKE iperc-ihbar,
        topkiton    LIKE iperc-kiton, gentopkiton LIKE iperc-kiton.

  LOOP AT iperk.
    NEW-PAGE.
*    SELECT SINGLE * FROM t501t WHERE sprsl EQ sy-langu AND
*                                     persg EQ ipery-persg.
*    IF sy-subrc NE 0. CLEAR t501t. ENDIF.
*    ULINE AT /1(171).
    FORMAT COLOR COL_KEY INTENSIFIED .
    WRITE : / 'MASRAF YERİ ', iperk-kostl.
*    t501t-ctext.
    ULINE AT /1(c_scnb).

    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    PERFORM write_potkidemkostl USING iperk-kostl
    CHANGING topbetrg topekucr toptopla
                    topk1yil topkidem topihbar topkiton.

    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    ULINE AT /1(c_scnb).
    PERFORM write_potkidem_ca USING 'MASRAF YERİ TOPLAMI :' CHANGING
                 topbetrg topekucr toptopla topk1yil topkidem topihbar topkiton.
    ULINE AT /1(c_scnb).
    ADD: topbetrg TO gentopbetrg , topekucr TO  gentopekucr ,
        toptopla TO  gentoptopla , topk1yil TO  gentopk1yil ,
        topkidem TO  gentopkidem ,topihbar TO  gentopihbar,topkiton TO  gentopkiton.

    CLEAR : topbetrg , topekucr ,toptopla,
           topk1yil , topkidem, topihbar,topkiton.

  ENDLOOP.
  ULINE AT /1(c_scnb).
  FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
  PERFORM write_potkidem_gt USING 'GENEL TOPLAM'
       CHANGING gentopbetrg
   gentopekucr gentoptopla gentopk1yil gentopkidem gentopihbar gentopkiton.

  ULINE AT /1(c_scnb).
ENDFORM.                    " kostl
*
*&---------------------------------------------------------------------*
*&      Form  write_potkidemkostl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IPERK_KOSTL  text
*      <--P_TOPBETRG  text
*      <--P_TOPEKUCR  text
*      <--P_TOPTOPLA  text
*      <--P_TOPK1YIL  text
*      <--P_TOPKIDEM  text
*      <--P_TOPIHBAR  text
*----------------------------------------------------------------------*
FORM write_potkidemkostl USING    $kostl
                         CHANGING
   topbetrg  topekucr  toptopla topk1yil topkidem topihbar topkiton .

  DATA : c_scnb TYPE i.
  DATA: cagbetrg LIKE iper-betrg, cagk1yil LIKE iper-k1yil,
        cagekucr LIKE iper-ekucr, cagkidem LIKE iper-kidem,
        cagtopla LIKE iper-topla, cagihbar LIKE iper-ihbar,
        cagkiton LIKE iper-kiton.

  SORT iper BY kostl pernr.
*  CLEAR: iper.  "IS 26.04.2004
*___Detay göstermede problem
  IF NOT biryil IS INITIAL. "Sadece 1 yılını doldurmuş olanlar
    LOOP AT iper WHERE  topdahil IS INITIAL.
*      DELETE iper.
      iper-kidem = 0 .
    ENDLOOP.
  ENDIF.
  IF potkidem = 'X' AND ozet NE 'X'.
    c_scnb = c_259.
  ELSE.
    c_scnb = c_208.
  ENDIF.

  LOOP AT iper WHERE  kostl EQ $kostl .

    ON CHANGE OF iper-kostl.
      IF cagbetrg NE 0 OR cagekucr NE 0 OR cagtopla NE 0
          OR cagk1yil NE 0 OR cagkidem NE 0 OR cagihbar NE 0.
        FORMAT COLOR COL_GROUP INTENSIFIED .
        PERFORM write_potkidem_ca USING
                     'MASRAF YERİ TOPLAMI :' CHANGING
                  cagbetrg cagekucr cagtopla cagk1yil cagkidem cagihbar cagkiton.
      ENDIF.
*      SELECT SINGLE * FROM t503t WHERE sprsl EQ sy-langu AND
*                                       persk EQ iperc-persk.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
      WRITE : / 'MASRAF YERİ       ', iper-kostl.
*      , t503t-ptext.
      ULINE AT /1(c_scnb).
      CLEAR :  cagbetrg , cagekucr , cagtopla , cagk1yil ,
               cagkidem , cagihbar,cagkiton .
    ENDON.

    PERFORM write_potline_cc.


*___Toplama dahil olmamalı- 1 yılını doldurmayanlar
    IF iper-topdahil EQ 1.
      ADD:   iper-betrg TO topbetrg , iper-ekucr TO topekucr ,
             iper-topla TO toptopla , iper-k1yil TO topk1yil ,
             iper-kidem TO topkidem , iper-kiton TO topkiton,
             iper-betrg TO cagbetrg , iper-ekucr TO cagekucr ,
             iper-topla TO cagtopla , iper-k1yil TO cagk1yil ,
             iper-kidem TO cagkidem   .
    ENDIF.
    ADD: iper-ihbar TO topihbar ,
         iper-ihbar TO cagihbar,
         iper-kiton TO cagkiton
         .
  ENDLOOP.
  FORMAT COLOR COL_GROUP INTENSIFIED .
  PERFORM write_potkidem_ca USING
               'MASRAF YERİ TOPLAMI   :' CHANGING
            cagbetrg cagekucr cagtopla cagk1yil cagkidem cagihbar cagkiton.


ENDFORM.                    " write_potkidemkostl
*&---------------------------------------------------------------------*
*&      Form  write_potline_cc
*&---------------------------------------------------------------------*

FORM write_potline_cc.

  WRITE: / sy-vline       , m1 AS CHECKBOX ,
           sy-vline NO-GAP, iper-pernr NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
* Geliştirme Taner 23.12.2005
           sy-vline NO-GAP, iper-sskno(18) NO-GAP COLOR COL_KEY.
  IF iper-gesch EQ '1'.
    WRITE:     sy-vline NO-GAP, ' Erkek  ' NO-GAP COLOR COL_KEY.
  ELSE.
    WRITE:     sy-vline NO-GAP, ' Kadın  ' NO-GAP COLOR COL_KEY.
  ENDIF.
  WRITE :

         sy-vline NO-GAP, iper-hire NO-GAP,
         sy-vline NO-GAP, iper-gtime NO-GAP,
         sy-vline NO-GAP, iper-ktime NO-GAP, sy-vline NO-GAP.
  IF h_fact EQ 100.
    WRITE : (16) iper-betrg CURRENCY h_curr NO-ZERO NO-GAP, sy-vline
    NO-GAP,
    (16) iper-ekucr CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
    (16) iper-topla CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
    (16) iper-k1yil CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
    (16) iper-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
    (16) iper-kiton CURRENCY h_curr NO-ZERO NO-GAP, sy-vline NO-GAP,
    (16) iper-ihbar CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
  ELSE.
    WRITE : (16) iper-betrg CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-ekucr CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-topla CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-k1yil CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-kidem CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-kiton CURRENCY h_curr NO-GAP, sy-vline NO-GAP,
    (16) iper-ihbar CURRENCY h_curr NO-GAP, sy-vline.
  ENDIF.
  HIDE iper.

ENDFORM.                    " write_potline_cc
*&---------------------------------------------------------------------*
*&      Form  count_cocuk
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM count_cocuk.

* Kıdem Raporuna bilgi amaçlı çeşitli alanların eklenmesi

  rp-read-infotype pernr-pernr 0002 p0769 iper-fire iper-fire.
  iper-gesch = p0002-gesch.


  IF iper-gesch EQ '1'.
    iper-cins = 'Erkek'.
  ELSE.
    iper-cins = 'Kadın'.
  ENDIF.

  rp-read-infotype pernr-pernr 0769 p0769 iper-fire iper-fire.
  iper-sskno = p0769-sskno.
  PERFORM re7trg04 USING p0001-werks p0001-btrtl.
* SELECT * FROM t7trt02 WHERE grtax EQ t7trg04-grtax AND
*                           sskod EQ p0769-sskod AND
*                           ssgrp EQ p0769-ssgrp AND
*                           begda LE iper-fire AND
*                           endda GE iper-fire.
* ENDSELECT.
* IF p0769-child GT 2.
*   p0769-child = 2.
* ENDIF.
* kidbetrg = p0769-child * t7trt02-cocuk.
* gerekirse aşağıdaki badiler vasıtasıyla kidbetrg değiştirilirse
* çocuk parası oluşturulmuş olur.
  kidbetrg = 0.
* Yukarıdaki kod işe yaramıyordu. Kaldırıldı. OKS ist. 04.01.2006
* BADI
  DATA: l_badi_02 TYPE REF TO if_ex_hrpaytr_kidem_02.

  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    CHANGING
      instance               = l_badi_02.

  CALL METHOD l_badi_02->change_values
    EXPORTING
      child   = p0769-child
      exempt  = t7trt02-cocuk
    IMPORTING
      camount = kidbetrg.


*    PERFORM ue_child.
  PERFORM append_rtab USING wty_9chd-low kidbetrg 'Çocuk Parası'.

ENDFORM.                    " count_cocuk


*____________________________________________________________________*

*---------------------------------------------------------------------*
*       FORM CONFIRM_DYN                                              *
*---------------------------------------------------------------------*
FORM confirm_dyn USING $titel1 $titel2 $titel3.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'N'
      titel         = $titel1
      textline1     = $titel2
      textline2     = $titel3
    IMPORTING
      answer        = h_yesno.
ENDFORM.                    "confirm_dyn

*&---------------------------------------------------------------------*
*&      Form  CONFIRM
*&---------------------------------------------------------------------*
FORM confirm.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'N'
      titel         = 'Update ?'(c01)
      textline1     = 'Yes  Y - Enter.'(c02)
      textline2     = 'No   N - Enter.'(c03)
    IMPORTING
      answer        = h_yesno.
ENDFORM.                               " CONFIRM_T9YG1


*&---------------------------------------------------------------------*
*&      Form  CONFIRM_T9YG1
*&---------------------------------------------------------------------*
FORM confirm_t9yg1.
  CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
    EXPORTING
      defaultoption = 'N'
      titel         = 'Update PA9009 ?'(t01)
      textline1     = 'Yes  Y - Enter.'(c02)
      textline2     = 'No   N - Enter.'(c03)
    IMPORTING
      answer        = h_yesno.

ENDFORM.                               " CONFIRM_T9YG1

*---------------------------------------------------------------------*
*       FORM CHK_FLG                                                  *
*---------------------------------------------------------------------*
FORM chk_flg.
  h_flg = c_of.
  DO.
    IF h_flg EQ c_on.   EXIT.  ENDIF.
    READ LINE sy-index FIELD VALUE m1.
    IF sy-subrc > 0.  EXIT.  ENDIF.
    IF m1 EQ 'X'.
      h_flg = c_on.
    ENDIF.
  ENDDO.
ENDFORM.                    "chk_flg



*---------------------------------------------------------------------*
*       FORM WINDOW                                                   *
*---------------------------------------------------------------------*
FORM window.
  IF sy-curow < 14.
    WINDOW STARTING AT 3 14 ENDING AT 70 19.
  ELSE.
    WINDOW STARTING AT 3 03 ENDING AT 70 8.
  ENDIF.
ENDFORM.                    "window

*---------------------------------------------------------------------*
*       FORM MARK_FIELD                                               *
*---------------------------------------------------------------------*
FORM mark_field_1.        " Darf nicht mehr angeklick werden.
  MODIFY CURRENT LINE FIELD VALUE m1 FROM space
                      FIELD FORMAT m1 INPUT OFF.
ENDFORM.                    "mark_field_1

*---------------------------------------------------------------------*
*       FORM MARK_FIELD                                               *
*---------------------------------------------------------------------*
FORM mark_field USING char.
  MODIFY CURRENT LINE
    FIELD VALUE m1 FROM space m FROM  char
    FIELD FORMAT m1 INPUT OFF
                 m INTENSIFIED OFF.
ENDFORM.                    "mark_field

*&---------------------------------------------------------------------*
*&      Form  SET_FORMAT
*&---------------------------------------------------------------------*
FORM set_format USING pernr.
  IF h_pernr NE pernr.
    h_pernr = pernr.
    IF h_zeile EQ c_on.
      h_zeile = c_of.
      FORMAT COLOR COL_NORMAL INTENSIFIED ON.
    ELSE.
      h_zeile = c_on.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    ENDIF.
  ENDIF.
ENDFORM.                               " SET_FORMAT
*

*&---------------------------------------------------------------------*
*&      Form  SET_FORMAT
*&---------------------------------------------------------------------*
FORM set_format_v0.
  IF h_zeile EQ c_on.
    h_zeile = c_of.
    FORMAT COLOR COL_NORMAL INTENSIFIED ON.
  ELSE.
    h_zeile = c_on.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
  ENDIF.
ENDFORM.                               " SET_FORMAT
*
FORM f4_for_period.
  DATA: BEGIN OF xdynpfields OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END   OF xdynpfields.
  DATA: returncode LIKE sy-subrc,
        monat      LIKE isellist-month,
        hlp_repid  LIKE sy-repid.
  FIELD-SYMBOLS: <feld>.

  GET CURSOR FIELD xdynpfields-fieldname.
  APPEND xdynpfields.
  hlp_repid = sy-repid.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname     = hlp_repid
      dynumb     = sy-dynnr
    TABLES
      dynpfields = xdynpfields.

  IF sy-subrc = 0.
    CALL FUNCTION 'CONVERSION_EXIT_TRPER_INPUT'
      EXPORTING
        input  = xdynpfields-fieldvalue
      IMPORTING
        output = monat.
    IF monat IS INITIAL.
      monat = sy-datlo(6).
    ENDIF.
    CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
      EXPORTING
        actual_month   = monat
      IMPORTING
        selected_month = monat
        return_code    = returncode.
    IF sy-subrc = 0 AND returncode = 0.
      ASSIGN (xdynpfields-fieldname) TO <feld>.
      <feld> = monat.
    ENDIF.
  ENDIF.
ENDFORM.                    " F4_FOR_PERIOD

*
*&---------------------------------------------------------------------*
*&      Form  write_onlineinput
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_onlineinput.
*               using p_hataturu
*                     p_hatatext.

  DATA: l_return TYPE bapireturn1,
        l_key    TYPE bapipakey.
  DATA: p_0015 LIKE p0015 OCCURS 0 WITH HEADER LINE.


  p_0015-pernr = iper-pernr.
  p_0015-infty = '0015'.
  p_0015-begda = iper-fire.
  p_0015-endda = iper-fire.

  IF iper-kidem GT 0.
    PERFORM $eqdq(sapfp500) USING 'E' 'PREL' iper-pernr 'E' sy-subrc.
    p_0015-betrg = iper-kidem.
    p_0015-subty = i0776-lgkid.
    p_0015-lgart = i0776-lgkid.



    CALL FUNCTION 'HR_INFOTYPE_OPERATION'
      EXPORTING
        infty         = p_0015-infty
        number        = p_0015-pernr
*       SUBTYPE       =
*       OBJECTID      =
*       LOCKINDICATOR =
        validityend   = p_0015-begda
        validitybegin = p_0015-endda
*       RECORDNUMBER  =
        record        = p_0015
        operation     = 'INS'
*       TCLAS         = 'A'
        dialog_mode   = 'O'
        nocommit      = ''
*       VIEW_IDENTIFIER        =
*       SECONDARY_RECORD       =
      IMPORTING
        return        = l_return
        key           = l_key.
    .


    IF l_return-type EQ 'E'.
      hatatext = 'Kıdem ücreti atılırken hata'.
*     hatatext+7(15)  = l_return+24(15).
      PERFORM hatatablosu USING
      hatatext 'B' iper-kidem.
    ELSE.
      PERFORM satirformati USING 7.
      WRITE:/ sy-vline, 'KIDEM VERİLERİNİZ SİSTEME ONLİNE OLARAK',
             'ATILMIŞTIR.', 95 sy-vline.
      ULINE /1(95).
    ENDIF.

    PERFORM $eqdq(sapfp500) USING 'D' 'PREL' iper-pernr 'E' sy-subrc.

  ENDIF.

  IF iper-kikek GT 0.

    PERFORM $eqdq(sapfp500) USING 'E' 'PREL' iper-pernr 'E' sy-subrc.
    p_0015-betrg = iper-kikek.
    p_0015-subty = i0776-lgkek.
    p_0015-lgart = i0776-lgkek.

    CALL FUNCTION 'HR_INFOTYPE_OPERATION'
      EXPORTING
        infty         = p_0015-infty
        number        = p_0015-pernr
*       SUBTYPE       =
*       OBJECTID      =
*       LOCKINDICATOR =
        validityend   = p_0015-begda
        validitybegin = p_0015-endda
*       RECORDNUMBER  =
        record        = p_0015
        operation     = 'INS'
*       TCLAS         = 'A'
        dialog_mode   = 'O'
        nocommit      = ''
*       VIEW_IDENTIFIER        =
*       SECONDARY_RECORD       =
      IMPORTING
        return        = l_return
        key           = l_key.
    .


    IF l_return-type EQ 'E'.
      hatatext = 'Kıdem ek ücreti atılırken hata'.
*     hatatext+7(15)  = l_return+24(15).
      PERFORM hatatablosu USING
      hatatext 'B' iper-kidem.
    ELSE.
      PERFORM satirformati USING 7.
      WRITE:/ sy-vline, 'KIDEM VERİLERİNİZ SİSTEME ONLİNE OLARAK',
             'ATILMIŞTIR.', 95 sy-vline.
      ULINE /1(95).
    ENDIF.

    PERFORM $eqdq(sapfp500) USING 'D' 'PREL' iper-pernr 'E' sy-subrc.

  ENDIF.

  IF iper-ihgun GT 0 AND iper-ihbar NE 0.

    PERFORM $eqdq(sapfp500) USING 'E' 'PREL' iper-pernr 'E' sy-subrc.
    p_0015-betrg = iper-ihbar.
    p_0015-subty = i0776-lgihb.
    p_0015-lgart = i0776-lgihb.

    CALL FUNCTION 'HR_INFOTYPE_OPERATION'
      EXPORTING
        infty         = p_0015-infty
        number        = p_0015-pernr
*       SUBTYPE       =
*       OBJECTID      =
*       LOCKINDICATOR =
        validityend   = p_0015-begda
        validitybegin = p_0015-endda
*       RECORDNUMBER  =
        record        = p_0015
        operation     = 'INS'
*       TCLAS         = 'A'
        dialog_mode   = 'O'
        nocommit      = ''
*       VIEW_IDENTIFIER        =
*       SECONDARY_RECORD       =
      IMPORTING
        return        = l_return
        key           = l_key.
    .

    IF l_return-type EQ 'E'.
      hatatext = 'İhbar ücreti atılırken hata'.
*     hatatext+7(15)  = l_return+24(15).
      PERFORM hatatablosu USING
      hatatext 'B' iper-kidem.
    ELSE.
      PERFORM satirformati USING 7.
      WRITE:/ sy-vline, 'IHBAR VERİLERİNİZ SİSTEME ONLİNE OLARAK',
             'ATILMIŞTIR.', 95 sy-vline.
      ULINE /1(95).
    ENDIF.


    PERFORM $eqdq(sapfp500) USING 'D' 'PREL' iper-pernr 'E' sy-subrc.
  ENDIF.
ENDFORM.                    " write_onlineinput
*&---------------------------------------------------------------------*
*&      Form  edit_EXCLUDING_tab
*&---------------------------------------------------------------------*
FORM edit_excluding_tab  TABLES pt_xfcode STRUCTURE xfcode
                          USING p_gui_no.

  DATA:l_badi_13 TYPE REF TO if_ex_hrpaytr_kidem_13.
  DATA:lt_fcodes TYPE ddshfcodes.

  APPEND 'WITB' TO pt_xfcode .
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    CHANGING
      instance               = l_badi_13.
  IF l_badi_13 IS NOT INITIAL.
    lt_fcodes = pt_xfcode[] .
    CALL METHOD l_badi_13->change_exclude_tab
      EXPORTING
        gui_no = p_gui_no
      CHANGING
        fcodes = lt_fcodes.

    pt_xfcode[] = lt_fcodes.
  ENDIF.

ENDFORM.                    " edit_EXCLUDING_tab
*&---------------------------------------------------------------------*
*&      Form  user_command_WITB
*&---------------------------------------------------------------------*
FORM user_command_witb .
  DATA:l_badi_13 TYPE REF TO if_ex_hrpaytr_kidem_13.
  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    CHANGING
      instance               = l_badi_13.
  IF l_badi_13 IS NOT INITIAL.
    CALL METHOD l_badi_13->at_user_command
      EXPORTING
        t_iperc = iperc[].
  ENDIF.
ENDFORM.                    " user_command_WITB

*&---------------------------------------------------------------------*
*&      Form  READ_P0770
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM read_p0770 .

  DATA  : lv_ictyp TYPE ictyp VALUE '01'.

  rp_provide_from_last p0770 lv_ictyp kidbegda kidendda.
  CHECK pnp-sw-found EQ '1'.

  iper-merni = p0770-merni.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form write_norkidem2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> IT7TRG01_WERKS
*&      --> IT7TRG01_BTRTL
*&---------------------------------------------------------------------*
FORM write_norkidem2 USING  $werks
                            $btrtl.
  LOOP AT iper WHERE werks EQ $werks AND btrtl EQ $btrtl.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    PERFORM write_blokkidem.
    FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
    PERFORM write_blokbetrg.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ikramiye_zam
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ikramiye_zam  USING p_betrg p_lgart.
  DATA: it7trk03 LIKE t7trk03 OCCURS 10 WITH HEADER LINE.


  IF potkidem NE space AND
    ( p_lgart IN wty_ikrm OR p_lgart IN w_ikrm14 ).
    REFRESH it7trk03. CLEAR it7trk03.
    SELECT * FROM t7trk03 INTO TABLE it7trk03
                       WHERE persg EQ p0001-persg
                         AND werks EQ iper-werks
                         AND btrtl EQ iper-btrtl
                         AND persk EQ p0001-persk
                         AND datum LT pottarih
    ORDER BY datum ASCENDING.
    LOOP AT it7trk03.
      IF NOT it7trk03-prznt IS INITIAL.
        p_betrg = p_betrg + ( p_betrg * it7trk03-prznt / 100 ).
      ENDIF.
      IF NOT it7trk03-betrg IS INITIAL.
        p_betrg = p_betrg + it7trk03-betrg.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " ikramiye_zam
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
FORM write_pottoplam2 USING  p_tptext p_kisi.

  IF potkidem = 'X' AND ozet NE 'X'.
    WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
         AT c_140(1)  ''  NO-GAP,
                 (16) iper-betrg CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-ekucr CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-topla CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-k1yil CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-kidem CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-kiton CURRENCY h_curr NO-ZERO NO-GAP ,
                 (16) iper-ihbar CURRENCY h_curr NO-ZERO NO-GAP ,
        AT c_259 sy-vline.
  ELSE.
    WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
         AT c_140(1) '' NO-GAP,
                 (16) iper-k1yil CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) iper-kidem CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) iper-kiton CURRENCY h_curr NO-ZERO NO-GAP,
                 (16) iper-ihbar CURRENCY h_curr NO-ZERO NO-GAP,
        AT c_208 sy-vline.

  ENDIF.
ENDFORM.                               " WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
*&      Form  MMER_TOPLA
*&---------------------------------------------------------------------*
FORM mmer_topla USING $werks $btrtl.
  LOOP AT iper WHERE werks EQ $werks
                 AND btrtl EQ $btrtl.
    MOVE-CORRESPONDING iper  TO mmer.
    MOVE 1 TO mmer-kisi.
    mmer-kyil = iper-ktime+0(4).
    mmer-kay  = iper-ktime+4(2).
    mmer-kgun = iper-ktime+6(2).
    COLLECT mmer.
    CLEAR mmer.
  ENDLOOP.
ENDFORM.                               " MMER_TOPLA
*&---------------------------------------------------------------------*
*&      Form  MMER_YAZ
*&---------------------------------------------------------------------*
FORM mmer_yaz.
  DATA: gun TYPE i,
        ay  TYPE i,
        yil TYPE i.
  SORT mmer BY kostl ASCENDING.
  LOOP AT mmer.
    SELECT SINGLE * FROM cskt
                WHERE kokrs EQ mmer-bukrs
                AND   kostl EQ mmer-kostl
    AND   datbi GE kidendda.
    CLEAR: gun, ay, yil.
    IF mmer-kgun GT 30.
      ay = mmer-kgun DIV 30 .
      mmer-kgun = mmer-kgun - ( ay * 30 ).
      mmer-kay = mmer-kay + ay .
    ENDIF.
    IF mmer-kay GT 12.
      yil = mmer-kay DIV 12 .
      mmer-kay = mmer-kay - ( yil * 12 ).
      mmer-kyil = mmer-kyil + yil.
    ENDIF.
    yil = mmer-kyil DIV mmer-kisi.
    mmer-kay = mmer-kay + ( ( mmer-kyil - ( yil * mmer-kisi ) ) * 12 ).
    ay = mmer-kay DIV mmer-kisi.
    mmer-kgun = mmer-kgun + ( ( mmer-kay - ( ay * mmer-kisi ) ) * 30 ).
    gun = mmer-kgun DIV mmer-kisi.
    WRITE:/ sy-vline NO-GAP,
            mmer-kostl NO-GAP, sy-vline NO-GAP,
            cskt-ktext NO-GAP, sy-vline NO-GAP,
            mmer-kisi  NO-GAP, sy-vline NO-GAP,
            yil        NO-GAP, sy-vline NO-GAP,
            ay         NO-GAP, sy-vline NO-GAP,
            gun        NO-GAP, sy-vline NO-GAP,
            mmer-kidem CURRENCY h_curr NO-ZERO NO-GAP, sy-vline.
    ULINE AT /(c_i05).
    AT LAST.
      CLEAR: gun, ay, yil.
      SUM.
      IF mmer-kgun GT 30.
        ay = mmer-kgun DIV 30 .
        mmer-kgun = mmer-kgun - ( ay * 30 ).
        mmer-kay = mmer-kay + ay.
      ENDIF.
      IF mmer-kay GT 12.
        yil = mmer-kay DIV 12.
        mmer-kay = mmer-kay - ( yil * 12 ).
        mmer-kyil = mmer-kyil + yil.
      ENDIF.
      yil = mmer-kyil DIV mmer-kisi.
      mmer-kay = mmer-kay +
                      ( ( mmer-kyil - ( yil * mmer-kisi ) ) * 12 ).
      ay = mmer-kay DIV mmer-kisi.
      mmer-kgun = mmer-kgun +
                      ( ( mmer-kay - ( ay * mmer-kisi ) ) * 30 ).
      gun = mmer-kgun DIV mmer-kisi.
      WRITE:/ sy-vline NO-GAP,
          (10) ''     UNDER mmer-kostl NO-GAP, sy-vline NO-GAP,
          (20) 'Toplam' UNDER cskt-ktext RIGHT-JUSTIFIED
                                       NO-GAP, sy-vline NO-GAP,
          mmer-kisi   UNDER mmer-kisi  NO-GAP, sy-vline NO-GAP,
          yil         UNDER yil        NO-GAP, sy-vline NO-GAP,
          ay          UNDER ay         NO-GAP, sy-vline NO-GAP,
          gun         UNDER gun        NO-GAP, sy-vline NO-GAP,
          mmer-kidem CURRENCY h_curr NO-ZERO UNDER mmer-kidem
                                       NO-GAP, sy-vline.
      ULINE AT /(c_i05).
    ENDAT.
  ENDLOOP.
ENDFORM.                               " MMER_YAZ
*&---------------------------------------------------------------------*
*&      Form  WRITE_TRANSFER_LIST
*&---------------------------------------------------------------------*
FORM write_transfer_list USING $werks $btrtl.
*  LOOP AT itemp WHERE secil NE space.
  SORT iper BY werks btrtl pernr.
  LOOP AT ipersum WHERE werks EQ $werks
                    AND btrtl EQ $btrtl.
    iper = ipersum.
    AT NEW btrtl.
      SELECT * FROM t001p
             WHERE werks = iper-werks
             AND   btrtl = iper-btrtl.
      ENDSELECT.
      IF sy-subrc NE 0.
        t001p-btext = 'BULUNAMADI'.
      ENDIF.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL.

      IF potkidem = 'X' AND ozet NE 'X'.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
            AT c_259 sy-vline.
        ULINE AT /1(c_259).
      ELSE.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
             AT c_208 sy-vline.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.

    PERFORM write_potline.

    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF btrtl.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.

    AT END OF werks.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.

    AT LAST.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2 USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam2 USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.

  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_TRANSFER_LIST
*&---------------------------------------------------------------------*
*& Form old_kidem
*&---------------------------------------------------------------------*
FORM old_kidem .

  CLEAR h_pers .
  PERFORM chk_flg.
  IF h_flg = c_on.
    CLEAR: kidemtop.
    DO.
      CLEAR: m1.
      READ LINE sy-index FIELD VALUE m1.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        CHECK m1 = 'X'.
        MOVE sy-lisel+3(4) TO iperw-werks.
        MOVE sy-lisel+8(4) TO iperw-btrtl.
        APPEND iperw.
        DELETE ADJACENT DUPLICATES FROM iperw.
        m1 = space.
        PERFORM set_gui_02.
        PERFORM old_kidem_list USING iperw-werks iperw-btrtl.
      ENDIF.
    ENDDO.
  ELSE.
    MESSAGE w010.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form old_kidem_list
*&---------------------------------------------------------------------*
FORM old_kidem_list  USING    pv_werks
                              pv_btrtl.

  DATA : lt_t028 TYPE TABLE OF zbyhr_t028.


  LOOP AT iper WHERE werks EQ pv_werks AND btrtl EQ pv_btrtl.
    AT NEW btrtl.
      SELECT * FROM t001p
             WHERE werks = iper-werks
             AND   btrtl = iper-btrtl.
      ENDSELECT.
      IF sy-subrc NE 0.
        t001p-btext = 'BULUNAMADI'.
      ENDIF.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL .

      WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                         iper-btrtl COLOR COL_GROUP,
                         t001p-btext,
*                          iT7TRG01-name1,
           AT c_121 sy-vline.
      ULINE AT /1(c_121).
    ENDAT.
    SELECT * FROM zbyhr_t028 INTO TABLE lt_t028
        WHERE pernr EQ iper-pernr.

    LOOP AT lt_t028 INTO DATA(ls_t028).
      PERFORM old_kidem_value USING ls_t028.
    ENDLOOP.

    ULINE AT /(c_121).
  ENDLOOP.

  FORMAT COLOR COL_GROUP INTENSIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form old_kidem_value
*&---------------------------------------------------------------------*
FORM old_kidem_value USING ps_oldk TYPE zbyhr_t028.

  DATA: lv_atext TYPE abktx.


  SELECT SINGLE atext INTO lv_atext FROM t549t
            WHERE sprsl EQ sy-langu
             AND abkrs EQ iper-abkrs.

  WRITE: /
           sy-vline NO-GAP, iper-pernr     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-kostl     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, lv_atext       NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-gbdat     NO-GAP COLOR COL_KEY .
  IF iper-gesch EQ '1'.
    WRITE: sy-vline NO-GAP, ' Erkek  '     NO-GAP COLOR COL_KEY.
  ELSE.
    WRITE: sy-vline NO-GAP, ' Kadın  '     NO-GAP COLOR COL_KEY.
  ENDIF.
  WRITE :  sy-vline NO-GAP, (14) ps_oldk-begda      NO-GAP,
           sy-vline NO-GAP, (14) ps_oldk-endda     NO-GAP.
  CASE ps_oldk-persk.
    WHEN 'F'.
      WRITE: sy-vline NO-GAP, (14) 'Full-Time'     NO-GAP, sy-vline NO-GAP.
    WHEN 'P'.
      WRITE: sy-vline NO-GAP,  (14) 'Part-Time'     NO-GAP, sy-vline NO-GAP.
  ENDCASE.

  HIDE iper.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form old_devam
*&---------------------------------------------------------------------*
FORM old_devam .

  CLEAR h_pers ."SerenK 22012009
  PERFORM chk_flg.
  IF h_flg = c_on.
    CLEAR: kidemtop.
    DO.
      CLEAR: m1.
      READ LINE sy-index FIELD VALUE m1.
      IF sy-subrc NE 0.
        EXIT.
      ELSE.
        CHECK m1 = 'X'.
        MOVE sy-lisel+3(4) TO iperw-werks.
        MOVE sy-lisel+8(4) TO iperw-btrtl.
        APPEND iperw.
        DELETE ADJACENT DUPLICATES FROM iperw.
        m1 = space.
        PERFORM set_gui_02.
        PERFORM old_devam_list USING iperw-werks iperw-btrtl.
      ENDIF.
    ENDDO.
  ELSE.
    MESSAGE w010.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form old_devam_list
*&---------------------------------------------------------------------*
FORM old_devam_list  USING    pv_werks
                              pv_btrtl.

  DATA : lt_t027 TYPE TABLE OF zbyhr_t027.


  LOOP AT iper WHERE werks EQ pv_werks AND btrtl EQ pv_btrtl.
    AT NEW btrtl.
      SELECT * FROM t001p
             WHERE werks = iper-werks
             AND   btrtl = iper-btrtl.
      ENDSELECT.
      IF sy-subrc NE 0.
        t001p-btext = 'BULUNAMADI'.
      ENDIF.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL .

      WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                         iper-btrtl COLOR COL_GROUP,
                         t001p-btext,
*                          iT7TRG01-name1,
           AT c_143 sy-vline.
      ULINE AT /1(c_143).
    ENDAT.
    SELECT * FROM zbyhr_t027 INTO TABLE lt_t027
        WHERE pernr EQ iper-pernr
          AND awart IN wty_ubz[].

    LOOP AT lt_t027 INTO DATA(ls_t027).
      PERFORM old_devam_value USING ls_t027.
    ENDLOOP.

    ULINE AT /(c_143).
  ENDLOOP.

  FORMAT COLOR COL_GROUP INTENSIFIED.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form old_devam_value
*&---------------------------------------------------------------------*
FORM old_devam_value USING ps_oldd TYPE zbyhr_t027.

  DATA: lv_atext TYPE abktx.
  DATA : ls_t554t TYPE t554t.
  DATA : lv_awart_t TYPE text100.


  SELECT SINGLE * FROM t554t INTO ls_t554t
    WHERE sprsl = sy-langu
      AND moabw = '01'
      AND awart = ps_oldd-awart.

  SELECT SINGLE atext INTO lv_atext FROM t549t
            WHERE sprsl EQ sy-langu
             AND abkrs EQ iper-abkrs.

  lv_awart_t = ps_oldd-awart && '-' && ls_t554t-atext.

  WRITE: /
           sy-vline NO-GAP, iper-pernr     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-kostl     NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, lv_atext       NO-GAP COLOR COL_KEY,
           sy-vline NO-GAP, iper-gbdat     NO-GAP COLOR COL_KEY .
  IF iper-gesch EQ '1'.
    WRITE: sy-vline NO-GAP, ' Erkek  '     NO-GAP COLOR COL_KEY.
  ELSE.
    WRITE: sy-vline NO-GAP, ' Kadın  '     NO-GAP COLOR COL_KEY.
  ENDIF.
  WRITE :  sy-vline NO-GAP, (14) ps_oldd-begda      NO-GAP,
           sy-vline NO-GAP, (14) ps_oldd-endda     NO-GAP.
  WRITE: sy-vline NO-GAP, (30) lv_awart_t     NO-GAP, sy-vline NO-GAP.

  HIDE iper.
ENDFORM.
