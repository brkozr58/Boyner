* ==================================================================== *
REPORT ZBYHR_P016_OLD LINE-SIZE  260
                NO STANDARD PAGE HEADING MESSAGE-ID yy.

TABLES: pc260, "Cluster Directory for Payroll Results
        pcl1 ,                         "HR Cluster 1
        pcl2 ,                         "HR Cluster 2
        pernr, "HR ana verileri raporlaması için standart verile
        t001,
        t001p,                         "Personel alanları/alt alanları
        t500p,                         "Personel alanları
        cskt,                          "Masraf yeri metinleri
        t501t,                         "Çalışan grubu tanımları
        t503 ,                         "Çalışan grubu/çalışan alt grubu
        t503t,                         "Çalışan alt grubu tanımları
        t512t,                         "Ücret ve maaş türleri metni
        t512w,                         "Wage Type Valuation
        t554s, t554t.                  "DEVAMSİZLİK TÜRLERİ

INFOTYPES:  0000, 0001, 0002, 0007, 0041,
            0008, 0014, 0015, 0023, 0750,
            2001,
*---Add for Upgrade by Vural SÜER on 28.05.2007
           0769,
           0776.
*           9907. "Add by VS on 08.01.2014

*---Add for Upgrade by Vural SÜER on 28.05.2007
INCLUDE pcftbtr0.         " Tables for Turkey


INCLUDE rpc2cd00.
INCLUDE rpc2rxx0.                      "Cluster RX data definition
INCLUDE rpc2rx00.                      "Cluster RX data definition
INCLUDE rpppxd00.                      "Data definition buffer PCL1/PCL2
INCLUDE rpppxd10.                      "Common part buffer PCL1/PCL2
INCLUDE rpppxm00.                      "Buffer handling routine
* TR-Includes
INCLUDE ZBYHR_P016_ypkidtop.             "Kıdem Raporu İçin Top Include
INCLUDE ZBYHR_P016_pekide0.                      "user exit

* Type-pool of ALV
TYPE-POOLS: slis.

*---Add for Upgrade by Vural SÜER on 28.05.2007
DATA: gv_subrc LIKE sy-subrc.
DATA: py_result TYPE paytr_result.
DATA: gv_current_screen(4).
* GUI zu setzen
DATA: BEGIN OF xfcode OCCURS 10,
        fcode(4),
      END OF xfcode.

*DATA: it9y04 LIKE t9y04 OCCURS 100 WITH HEADER LINE.
DATA: h_abart LIKE rt-abart.
** 01.02.2001 H.Cingöz
DATA: h_p0041    LIKE sy-datum,
      h_41dat    LIKE sy-datum,
      h_topay(4) TYPE n.
DATA : ypb LIKE t005-waers.               "Taner YTL Dönüşümü için.
DATA : c_i01 TYPE i VALUE 176. "155
DATA : c_i02 TYPE i VALUE 125. "104
DATA : c_i03 TYPE i VALUE 108. "87
DATA : c_i04 TYPE i VALUE 244. "223
DATA : c_i05 TYPE i VALUE 103.

*---Begin of Add by VS
DATA: p0001temp LIKE p0001 OCCURS 3 WITH HEADER LINE.
*---End of Add by VS

**
INITIALIZATION.
  wty_9ubz-sign   = 'I'.
  wty_9ubz-option = 'EQ'.
  wty_9ubz-low    = '0120'.
  APPEND wty_9ubz.
  wty_9ubz-low    = '0130'.
  APPEND wty_9ubz.
  wty_9ubz-low    = '0200'.
  APPEND wty_9ubz.
*  wty_9ubz-low    = '0180'.
*  APPEND wty_9ubz.

  w_kistel-sign   = 'I'.
  w_kistel-option = 'EQ'.
  w_kistel-low    = '2010'.
  APPEND w_kistel.


AT SELECTION-SCREEN OUTPUT.
*  loop at screen.

  LOOP AT SCREEN.
    IF sy-saprl+0(2) EQ '40'.
      CHECK screen-group4 NE '073'.    "Personel Numaras#
      CHECK screen-group4 NE '080'.    "Personel Alan#
      CHECK screen-group4 NE '081'.    "Personel Alt Alan#
      CHECK screen-group4 NE '082'.    "MA-gruppe
      CHECK screen-group4 NE '083'.    "MA-kreise
    ELSEIF sy-saprl+0(2) EQ '46'.
      CHECK screen-group4 NE '154'.    "Personel Numaras#
      CHECK screen-group4 NE '160'.    "Personel Alan#
      CHECK screen-group4 NE '161'.    "Personel Alt Alan#
      CHECK screen-group4 NE '162'.    "personelteilbereich
      CHECK screen-group4 NE '163'.    "Çal##an Grubu
      CHECK screen-group4 NE '164'.    "MA-kreise
      CHECK screen-group4 NE '168'.    "Personel Numaras#
      CHECK screen-group4 NE '169'.    "Personel Alan#
      CHECK screen-group4 NE '170'.    "Personel Alt Alan#
      CHECK screen-group4 NE '171'.    "Personel Numaras#
      CHECK screen-group4 NE '172'.    "Personel Alan#
      CHECK screen-group4 NE '173'.    "Personel Alt Alan#
      CHECK screen-group4 NE '174'.    "Personel Alt Alan#
      CHECK screen-group4 NE '175'.    "Personel Alt Alan#
    ENDIF.

    IF NOT screen-group1 IS INITIAL.
*      screen-active = '0'."IS 1.3.05
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
*
AT SELECTION-SCREEN ON pottarih.
  IF potkidem NE space.
    IF pottarih IS INITIAL.
      MESSAGE e040 WITH pottarih.
    ENDIF.
  ENDIF.
*
AT SELECTION-SCREEN ON norkitar.
  IF norkidem NE space.
    IF norkitar IS INITIAL.
      MESSAGE e040 WITH norkitar.
    ENDIF.
  ENDIF.
*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR norkitar.
  PERFORM f4_popup_for_period.


START-OF-SELECTION.

  IF potkidem = 'X'.
    kidendda = pottarih.
    PERFORM kidemtarihleri USING kidendda kidbegda.
    kidendda = pottarih.
  ELSE.
    kidendda+0(6) = norkitar.
    kidendda+6(2) = '01'.
    PERFORM kidemtarihleri USING kidendda kidbegda.
  ENDIF.
  PERFORM kidtar_userexit.

  PERFORM tables_to_itabs.

* "IS YTL
  SELECT waers  INTO ypb FROM t500w
                 WHERE land1 = 'TR'
             AND  begda = '20050101' .
  ENDSELECT.

  CALL FUNCTION 'RP_GET_CURRENCY'
    EXPORTING
      molga = '47'
      begda = kidbegda
    IMPORTING
      waers = calc_currency.

  CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
    EXPORTING
      currency = calc_currency
    IMPORTING
      factor   = c_fact.


GET pernr.

  CLEAR: kitonbetrg.
  appendrtab = 'X'.
  ihbarhesapla = 'X'.
  PERFORM calc_kidem.
  IF iper[] IS NOT INITIAL.
    APPEND iper TO ipersum.
  ENDIF.

END-OF-SELECTION.
  PERFORM end_of_selection.

TOP-OF-PAGE.
  PERFORM top_of_page.

TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM top_of_page_line.

AT USER-COMMAND.
  PERFORM at_user_command.



  INCLUDE ZBYHR_P016_ypctabco.
*  include zpcwaers. "IS
  INCLUDE ZBYHR_P016_ypcwaers.

  INCLUDE ZBYHR_P016_ypchire0.
  INCLUDE ZBYHR_P016_ypcbatch.
* INCLUDE ypcform0.
  INCLUDE ZBYHR_P016_ypcform1.

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
  $text+0(55) = p_hatatext.
  $text+56(1) = ':'.
  $text+57 = p_aciklama.

  hatatab-pernr = iper-pernr.
  hatatab-ename = iper-ename.
  hatatab-werks = iper-werks.
  hatatab-btrtl = iper-btrtl.
  hatatab-htext = $text.
  hatatab-norml = p_hataturu.          " N : normal W : Uyarı
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
    gunfarki =  p0endda - p0begda - 397.  "01.01.0001 çıkartılır
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
FORM tarihecevir USING gun1
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
*&      Form  TARIHINYARISI
*&---------------------------------------------------------------------*
FORM tarihinyarisi USING    p_gunfarki.
  DATA: gunfarki LIKE sy-datum.
  DATA: gun TYPE i,
        ay  TYPE i,
        yil TYPE i.
  gunfarki = p_gunfarki.
  gun = gunfarki+6(2).
  ay  = gunfarki+4(2).
  yil = gunfarki+0(4).
  ay  = ( yil * 12 ) + ay.
  gun = gun + ( 30 * ( ay MOD 2 ) ).
  ay  = ay DIV 2 .
  yil = ay DIV 12.
  ay  = ay MOD 12.
  ay  = ay + ( ( gun / 2 ) DIV 30 ).
  gun = ( gun / 2 ) MOD 30.
  gunfarki+0(4) = yil.
  gunfarki+4(2) = ay .
  gunfarki+6(2) = gun.
  p_gunfarki =  gunfarki.
ENDFORM.                               " TARIHINYARISI
*&---------------------------------------------------------------------*
*&      Form  TARIHECEVIR2
*&---------------------------------------------------------------------*
FORM tarihecevir2 USING    gun
                           gunfarki.
  DATA: ay(2)  TYPE n, yil(4) TYPE n.
  yil = ( gun * 100   ) DIV 36525.
  gun = gun - ( yil * 36525  / 100   ).
  ay  = ( gun * 10000 ) DIV 304375.
  gun = gun - ( ay  * 304375 / 10000 ).
  gunfarki+6(2) = gun.
  gunfarki+4(2) = ay.
  gunfarki+0(4) = yil.
ENDFORM.                               " TARIHECEVIR2
*&---------------------------------------------------------------------*
*&      Form  RECUR_AT_BASIC_PAY
*&---------------------------------------------------------------------*
FORM recur_at_basic_pay USING    p_betrg
                                 p_pernr
                                 p_ifire.
ENDFORM.                               " RECUR_AT_BASIC_PAY
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

* "IS 25.02.2005 - YTL problemi

    IF NOT ppbwla-waers EQ calc_currency.
      PERFORM convert_to_local_currency USING
         ppbwla-betrg ppbwla-endda ppbwla-waers
         calc_currency ppbwla-betrg.
    ENDIF.



*    PERFORM RE541N USING CALCMOLGA PPBWLA-LGART I_FIRE I_LGART .
    SELECT * FROM t541n WHERE molga EQ calcmolga "HC 14.11.2000
                          AND lgart EQ ppbwla-lgart
                          AND endda GT i_fire.
    ENDSELECT.
    IF sy-subrc EQ 0.                  "HC 14.11.2000
      i_lgart = t541n-lga01.           "Net üctet
    ELSE.
      i_lgart = ppbwla-lgart.          "Brüt ücret
    ENDIF.
* Read: Aylık ücreti RT.
    PERFORM loop_at_rgdir USING p_pernr temptarh i_betrg i_lgart.
* Compare: 0008 ile RT
*   if i_betrg lt ppbwla-betrg.
*     i_betrg = ppbwla-betrg.
*   endif.
  ENDLOOP.
* IF i_betrg NE p_betrg .
*   PERFORM fill_err USING 'P'.
* ENDIF.
  p_betrg = i_betrg.

ENDFORM.                               " COMPARE_BETRG_RT
*&---------------------------------------------------------------------*
*&      Form  RE541N
*&---------------------------------------------------------------------*
FORM re541n USING    p_calcmolga
                     p_ppbwla_lgart
                     p_fire
                     p_lgart.
  CLEAR t541n.
  CLEAR p_lgart.
  SELECT * FROM t541n WHERE molga =  p_calcmolga
                               AND lgart =  p_ppbwla_lgart
                               AND endda GT p_fire.
  ENDSELECT.
  CHECK sy-subrc EQ 0.
  p_lgart = t541n-lga01.

ENDFORM.                                                    " RE541N
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
**&---------------------------------------------------------------------
**
**&      Form  RE9Y1P
**&---------------------------------------------------------------------
**
*FORM re9y1p USING    $werks
*                     $btrtl.
*  CHECK t9y1p-werks NE $werks OR t9y1p-btrtl NE $btrtl.
*  SELECT SINGLE * FROM t9y1p WHERE werks EQ $werks
*                             AND   btrtl EQ $btrtl.
*  IF sy-subrc NE 0.
*    CLEAR t9y1p.
*  ENDIF.
*
*ENDFORM.                                                    " RE9Y1P
*&---------------------------------------------------------------------*
*&      Form  LOOP_AT_RGDIR
*&---------------------------------------------------------------------*
FORM loop_at_rgdir USING  p_pernr p_temprtarh i_betrg i_lgart.
  DATA firedate LIKE rgdir-fpper.      "SY-DATUM.
  DATA: h_tage(2) TYPE n, h_lin TYPE i."HC 14.11.2000
  DATA: pindex LIKE sy-index.
  DATA aa(2) TYPE n.
  firedate =  p_temprtarh+0(6).
  SORT  rgdir BY fpper DESCENDING.
  WHILE stoploop EQ space AND sy-index LE 12.
    LOOP AT rgdir WHERE fpper EQ firedate+0(6) AND srtza EQ 'A'.
*      rx-key-pernr = p_pernr.
*      UNPACK rgdir-seqnr TO rx-key-seqno.
*      rp-imp-c2-rx.
*      CHECK rp-imp-rx-subrc EQ 0.
* Çıkış: Ay ortasında olup olmadığını kontrol eder
*        Yarım aylık heasba dahil edilmemesi gerek.
*     read table wpbp with key aktivjn = space
*                              stat2 = '0'.
*     if sy-subrc ne 0.                "HC 14.11.2000
*      LOOP AT rt WHERE lgart EQ i_lgart.
*---Add for Upgrade by Vural SÜER on 28.05.2007
      PERFORM read_payroll USING rgdir-fpper pernr-pernr
                        CHANGING py_result . "
*   PCL2/TR Boş/Dolu kontrolü
      CHECK sy-subrc EQ 0.
*              loop at rt where lgart eq '9NDY'.
      LOOP AT py_result-inter-rt INTO rt  WHERE lgart EQ i_lgart.
        IF h_abart EQ '1'.             "HC 14.11.2000
          i_betrg = i_betrg + rt-betpe."HC 14.11.2000
        ELSE.                          "HC 14.11.2000
          i_betrg = i_betrg + rt-betrg.
        ENDIF.                         "HC 14.11.2000
      ENDLOOP.
      stoploop = 'X'.
*      ELSE.
*      CONCATENATE i_lgart 'Ücret Türü'
*      'Bordro Sonuçlarında Yok' INTO hatatext SEPARATED BY ' '.
*      PERFORM hatatablosu USING hatatext 'N' space.
*      ENDIF.
    ENDLOOP.
    IF firedate+4(2) GT 1.
      aa     = firedate+4(2) - 1.
      firedate+4(2) = aa.
    ELSE.
      firedate+0(4) = firedate+0(4) - 1.
      firedate+4(2) = '12'.
    ENDIF.
  ENDWHILE.
ENDFORM.                               " LOOP_AT_RGDIR
*&---------------------------------------------------------------------*
*&      Form  APPEND_RTAB
*&---------------------------------------------------------------------*
FORM append_rtab USING    p_lgart
                          p_betrg
                          p_wtext.
  CHECK appendrtab EQ 'X'. "Add by VS on 08.01.2014
*---İkrmaiyeye maaş kadar zam yapma
  PERFORM ikramiye_zam USING p_betrg p_lgart.

  CLEAR: t512t, rtab.
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
  rtab-lgart = p_lgart.
  CHECK rtab-betrg > 0.
  APPEND rtab.
ENDFORM.                               " APPEND_RTAB
*&---------------------------------------------------------------------*
*&      Form  WRITE_T7TRG01
*&---------------------------------------------------------------------*
FORM write_t7trg01.
  PERFORM satirformati USING 2.
  WRITE: / sy-vline NO-GAP ,
           m1 AS CHECKBOX NO-GAP, sy-vline NO-GAP,
           it7trg01-werks   NO-GAP, sy-vline NO-GAP,
           it7trg01-btrtl   NO-GAP, sy-vline NO-GAP,
           it7trg01-sskno   NO-GAP, sy-vline NO-GAP,
           it7trg01-ttfno   NO-GAP, sy-vline NO-GAP,
           it7trg01-name1(28)   NO-GAP, sy-vline.
  HIDE: it7trg01.
ENDFORM.                               " WRITE_T7TRG01
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
    WHEN 'NORM' OR 'DETY'.
      ULINE AT /(69).
      FORMAT COLOR COL_KEY INTENSIFIED OFF.
      WRITE: / sy-vline, iper-pernr, iper-ename(30),
            47 sy-datum, 69 sy-vline.
      ULINE AT /(69).
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
    WHEN 'WTYP' OR 'PERS' OR 'BUKR'.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /(c_i04).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        IF sy-ucomm EQ 'WTYP'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- PERSONEL ALT ALANI', AT c_i04 sy-vline.
        ELSEIF sy-ucomm EQ 'BUKR'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ŞİRKET', AT c_i04 sy-vline.
        ELSE.
          WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ÇALIŞAN ALT GRUBU', AT c_i04 sy-vline.
        ENDIF.
        ULINE AT /(c_i04).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'     NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'C'                NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, ' Transfer '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, '      Aylık Brüt' NO-GAP,
                   sy-vline NO-GAP, '       Yan Gelir' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' İhbar Tazminatı' NO-GAP,
                   sy-vline.
        ULINE AT /(c_i04).
      ELSE.
        ULINE AT /(c_i01).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        IF sy-ucomm EQ 'WTYP'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- PERSONEL ALT ALANI', AT c_i01 sy-vline.
        ELSEIF sy-ucomm EQ 'BUKR'.
          WRITE : / sy-vline, kidendda,
                 'TARIHINE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ŞİRKET', AT c_i01 sy-vline.
        ELSE.
          WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- ÇALIŞAN ALT GRUBU', AT c_i01 sy-vline.
        ENDIF.
        ULINE AT /(c_i01).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'     NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'C'                NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, ' Transfer '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline.
        ULINE AT /(c_i01).
      ENDIF.

    WHEN 'TRAN'.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /(c_i04).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        WRITE : / sy-vline, kidendda,
                 'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
                 '- TRANSFER LİSTESİ', AT c_i04 sy-vline.
        ULINE AT /(c_i04).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'     NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'C'                NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, ' Transfer '       NO-GAP,
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
        ULINE AT /(c_i04).
      ELSE.
        ULINE AT /(c_i01).
        FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
        WRITE : / sy-vline, kidendda,
               'TARİHİNE GÖRE POTANSIYEL KIDEM TAZMINATI',
               '- TRANSFER LİSTESİ', AT c_i01 sy-vline.
        ULINE AT /(c_i01).
        WRITE : /  sy-vline NO-GAP, '    Sicil No'     NO-GAP,
                   sy-vline NO-GAP, 'Adı ve Soyadı       '   ,
                   sy-vline NO-GAP, 'Masraf Yer'       NO-GAP,
                   sy-vline NO-GAP, (20) 'Bordro Alt Birimi' NO-GAP,
                   sy-vline NO-GAP, ' Doğum Tr '       NO-GAP,
                   sy-vline NO-GAP, 'C'                NO-GAP,
                   sy-vline NO-GAP, ' İşegiriş '       NO-GAP,
                   sy-vline NO-GAP, ' Transfer '       NO-GAP,
                   sy-vline NO-GAP, 'Devamsızlk'       NO-GAP,
                   sy-vline NO-GAP, 'KıdemSüre.'       NO-GAP,
                   sy-vline NO-GAP, ' 1Yıl Kıdem Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Trans.Önce Taz.' NO-GAP,
                   sy-vline NO-GAP, ' Topl.Kıdem Taz.' NO-GAP,
                   sy-vline.
        ULINE AT /(c_i01).
      ENDIF.
    WHEN 'HATA'.
      ULINE AT /(95).
      FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
      WRITE : / sy-vline,
             'İŞLENEN PERSONELLER İÇİN UYARI LİSTESİ', 95 sy-vline.
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
  ENDCASE.

ENDFORM.                               " TOP_OF_PAGE_LINE
*&---------------------------------------------------------------------*
*&      Form  CLEAR_WAS
*&---------------------------------------------------------------------*
FORM clear_was.

  CLEAR: iper.
*---t9ypf, t9ygr artık kullanılmıyor
  "it9ypf, t9ygr.
*---t9ypf, t9ygr artık kullanılmıyor
  CLEAR: kidprimt,kidpernr, kidlgart,fatalerr, normlerr, stoploop.

ENDFORM.                               " CLEAR_WAS
**&---------------------------------------------------------------------
**
**&      Form  CHECK_P9005
**&---------------------------------------------------------------------
**
*form check_p9005.
**  "9005 kıdem bilgi tipi kontrolü
*  rp-provide-from-last p9005 space kidbegda kidendda.
*  if p9005[] is initial.
*    write kidbegda to hatatext+0(10) dd/mm/yyyy.
*    write kidendda to hatatext+12(10) dd/mm/yyyy.
*    if potkidem eq 'X'.
*      perform hatatablosu using text-erd 'W' hatatext.
*    else.
*      perform hatatablosu using text-erd 'N' hatatext.
*    endif.
*  else.
*    move-corresponding p9005 to i9005.
*    append i9005.
*  endif.
*endform.                               " CHECK_P9005
*&---------------------------------------------------------------------*
*&      Form  CHECK_P0776
*&---------------------------------------------------------------------*
FORM check_p0776.
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
ENDFORM.                               " CHECK_P0776
*&---------------------------------------------------------------------*
*&      Form  CHECK_PAYROLL
*&---------------------------------------------------------------------*
FORM check_payroll.
* Bordro sonuçları kotrolü
*  cd-key-pernr = pernr-pernr.
*  rp-imp-c2-cd.
*  if rp-imp-cd-subrc ne 0.
*    perform hatatablosu using text-era 'N' ''.
*  endif.

*---Add for Upgrade by Vural SÜER on 28.05.2007
  PERFORM read_rgdir USING pernr-pernr gv_subrc.
  IF gv_subrc NE 0.
    PERFORM hatatablosu USING TEXT-era 'N' ''.
  ENDIF.

ENDFORM.                               " CHECK_PAYROLL

*&---------------------------------------------------------------------*
*&      Form  CHECK_P0001
*&---------------------------------------------------------------------*
FORM check_p0001.
* En son organizasyon kaydını kontrol eder.
* rp-provide-from-last p0001 space kidbegda kidendda.
* CHECK p0001-werks IN pnpwerks.
* CHECK p0001-btrtl IN pnpbtrtl.
* CHECK p0001-persg IN pnppersg.
* CHECK p0001-persk IN pnppersk.
*  CHECK: p9907-bukrs IS INITIAL,"Add by VS on 08.01.2014
*         p9907-werks IS INITIAL,"Add by VS on 08.01.2014
*         p9907-btrtl IS INITIAL."Add by VS on 08.01.2014
  PROVIDE * FROM p0001 BETWEEN kidbegda AND kidendda
                         WHERE p0001-werks IN pnpwerks
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
ENDFORM.                               " CHECK_P0001
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH1
*&---------------------------------------------------------------------*
FORM check_tarih1.
* Tarih başlangıç değerlerinin kontrolü
  IF potkidem NE space.
    IF firedate LT kidendda.           " çıkışı kıdemden önce (pot)
      WRITE firedate TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-erc 'N' hatatext.
    ENDIF.
  ELSE.
    IF firedate LT kidbegda.           " çıkışı kıdemden önce
      WRITE firedate TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-erf 'N' hatatext.
    ENDIF.
  ENDIF.
ENDFORM.                               " CHECH_TARIH1
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH2
*&---------------------------------------------------------------------*
FORM check_tarih2.
* Başlangıç tarih değerlerinin itab a atanması
  iper-fired = kidendda.
  iper-hired = hiredate.
  IF norkidem = 'X'.
    iper-fired = firedate.
    IF kidmtest EQ 'X'.
      kidbegda+0(4) = kidbegda+0(4) + 1.
      kidendda+0(4) = kidendda+0(4) + 1.
    ENDIF.
    IF ( firedate LT kidbegda ) OR ( firedate GT kidendda ).
*     CONCATENATE kidbegda ' - ' kidendda INTO hatatext.
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
* Eski işyerindeki çalışma süresinin kontrolü
*  LOOP AT p0023 WHERE komod EQ 'E'.
*    PERFORM tarihfarki USING p0023-begda p0023-endda temptarh.
*    IF p0023-fpmod EQ 'P'.
*      PERFORM tarihtoplami  USING iper-ptime temptarh.
**      PERFORM tarihinyarisi USING temptarh.
*    ELSE.
*      PERFORM tarihtoplami  USING iper-ftime temptarh.
*    ENDIF.
*    PERFORM tarihtoplami  USING iper-eskit temptarh.
*  ENDLOOP.
* Komod 0750 no'lu bilgi tipine ta##nd#.
  LOOP AT p0750 WHERE ptr_komod EQ 'E'.
    PERFORM tarihfarki USING p0023-begda p0023-endda temptarh.
    IF p0750-ptr_fpmod EQ 'P'.
      PERFORM tarihtoplami  USING iper-ptime temptarh.
*      PERFORM tarihinyarisi USING temptarh.
    ELSE.
      PERFORM tarihtoplami  USING iper-ftime temptarh.
    ENDIF.
    PERFORM tarihtoplami  USING iper-eskit temptarh.
  ENDLOOP.

ENDFORM.                               " COUNT_P0023

*&---------------------------------------------------------------------*
*&      Form  COUNT_T9YPF
*&---------------------------------------------------------------------*
*FORM count_t9ypf.
** Grev günlerinin hesaba katılması
*  LOOP AT it9ypf WHERE pernr EQ pernr-pernr.
*    IF it9ypf-begda LT it9ypf-endda.
*      PERFORM tarihfarki USING it9ypf-begda it9ypf-endda temptarh.
*      IF it9ypf-dtart EQ 'PF'.
*        PERFORM tarihtoplami USING iper-ptime temptarh.
*      ENDIF.
*    ENDIF.
*  ENDLOOP.
*ENDFORM.                               " COUNT_T9YPF

*&---------------------------------------------------------------------*
*&      Form  COUNT_P0001
*&---------------------------------------------------------------------*
FORM count_p0001.
  DATA: temptarh2 LIKE temptarh.

*---Add for Upgrade by Vural SÜER on 28.05.2007
*---41 deki tarihin etkin olması
  IF h_p0041 IS INITIAL AND h_41dat NE '00000000'.
    iper-hired = h_41dat.
  ENDIF.
*---Add for Upgrade by Vural SÜER on 28.05.2007

*---Begin of Add by VS on 29.01.2014
  LOOP AT p0001 WHERE begda LE iper-hired
                AND   endda GE iper-hired.
  ENDLOOP.
  IF sy-subrc EQ 0.
*  IF ipersum[] IS NOT INITIAL. "Add by VS on 29.01.2014
*---End of Add by VS on 29.01.2014
* Çalışan Alt Grubu Part Time a tabi ise part time sürelerini toplar
    PROVIDE * FROM p0001 BETWEEN iper-hired AND iper-fired.
*    SELECT SINGLE * FROM t9y1e WHERE persg EQ p0001-persg
*                                 AND persk EQ p0001-persk.
      PERFORM re7trg03 USING p0001-persg p0001-persk.
*    IF sy-subrc EQ 0.
      IF NOT ( t7trg03 IS INITIAL ).
        IF p0001-begda LT p0001-endda.
*---t9ypf artık kullanılmıyor
*        IF p0001-begda LT it9ypf-endda.
*          p0001-begda = it9ypf-endda.
*        ENDIF.
*---t9ypf artık kullanılmıyor
          IF p0001-begda LT p0001-endda.
*          IF t9y1e-mossk EQ '02'.  "Part time
            IF p0001-persk EQ '50' OR p0001-persk EQ '55'. "Part time
              CLEAR: temptarh.
              LOOP AT rgdir WHERE fpper GE p0001-begda+0(6)
                              AND fpper LE p0001-endda+0(6).
                CHECK : rgdir-srtza EQ stand OR stand EQ space.
*              rx-key-pernr = iper-pernr.
*              unpack rgdir-seqnr to rx-key-seqno.
*              rp-imp-c2-rx.
*              check rp-imp-rx-subrc eq 0.
*---Add for Upgrade by Vural SÜER on 28.05.2007
                PERFORM read_payroll USING rgdir-fpper pernr-pernr
                                  CHANGING py_result . "
*   PCL2/TR Boş/Dolu kontrolü
                CHECK sy-subrc EQ 0.
                CLEAR: temptarh2.
*              loop at rt where lgart eq '9NDY'.
                LOOP AT py_result-inter-rt INTO rt WHERE lgart EQ '/NDY'
                                                   OR   lgart EQ '9NDY'.
                  PERFORM tarihecevir USING rt-anzhl 0 0 temptarh2.
                  PERFORM tarihtoplami USING temptarh temptarh2.
                ENDLOOP.
              ENDLOOP.
              PERFORM tarihtoplami USING iper-ptime temptarh.
            ELSE.  "Ful Time
              PERFORM tarihfarki USING p0001-begda p0001-endda temptarh.
              PERFORM tarihtoplami USING iper-ftime temptarh.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDPROVIDE.
*    IF sy-subrc NE 0 AND  p9907[] IS NOT INITIAL.  "Add by VS on 08.01.2014
*      PERFORM tarihfarki USING iper-hired iper-fired temptarh.  "Add by VS on 08.01.2014
*      PERFORM tarihtoplami USING iper-ftime temptarh.  "Add by VS on 08.01.2014
*    ENDIF.  "VS
  ELSE. "Add by VS on 29.01.2014
    PERFORM tarihfarki USING iper-hired iper-fired temptarh.  "VS
    PERFORM tarihtoplami USING iper-ftime temptarh.  "VS
  ENDIF. "Add by VS on 29.01.2014
*  PERFORM tarihfarki   USING iper-ptime iper-ftime iper-ftime.
* PERFORM tarihtoplami USING iper-ftime temptarh.
* PERFORM tarihinyarisi USING iper-ptime.
ENDFORM.                               " COUNT_P0001
*&---------------------------------------------------------------------*
*&      Form  COUNT_GREVG
*&---------------------------------------------------------------------*
FORM count_grevg.
  DATA: lv_endda LIKE sy-datum.
** Grev günlerinin hesaplanıp kıdem süresinden çıkartılması
  CLEAR grevtarh.                      " E.B - ADD
*  SELECT * FROM t9ygr WHERE pernr EQ pernr-pernr AND lgart IN wty_9ubz.
*    grevtarh = grevtarh + t9ygr-anzhl.
*  ENDSELECT.

  IF potkidem NE space.
    lv_endda = pottarih.
  ELSE.
    lv_endda = firedate.
  ENDIF.
*
*  PROVIDE * FROM p2001 BETWEEN hiredate AND firedate.
  PROVIDE * FROM p2001 BETWEEN hiredate AND lv_endda.
    CHECK NOT wty_9ubz[] IS INITIAL.   "p_streik.
    CHECK p2001-awart IN wty_9ubz.     "p_streik.
    PERFORM on_calc_2001_user_exit.
    grevtarh = grevtarh + p2001-kaltg.
  ENDPROVIDE.

  IF grevtarh NE 0.
    PERFORM tarihecevir2 USING grevtarh iper-gtime.
  ENDIF.

  IF iper-gtime < iper-ftime.
    PERFORM tarihfarki USING iper-gtime iper-ftime iper-ftime.
  ENDIF.
  temptarh = iper-ftime.
  PERFORM tarihtoplami USING temptarh iper-ptime.
  iper-ktime = temptarh.
  IF norkidem NE space.
    IF iper-ktime LT '00010000'.
      WRITE iper-ktime TO hatatext DD/MM/YYYY.
      PERFORM hatatablosu USING TEXT-ern 'W' hatatext.
      iper-ktime = 0.                  " E.B. ADD
    ENDIF.
  ENDIF.
ENDFORM.                               " COUNT_GREVG

*&---------------------------------------------------------------------*
*&      Form  COUNT_UCRET
*&---------------------------------------------------------------------*
FORM count_ucret.
  TABLES: t7trk03.
  DATA: it7trk03 LIKE t7trk03 OCCURS 10 WITH HEADER LINE.

*Temel Ödemelerini bulur, bunlar net ise brut karşılıklarını rt den alır
  SORT p0008 BY begda ASCENDING.
  LOOP AT rgdir WHERE srtza EQ 'A' AND fpper LE iper-fired+0(6).
*  LOOP AT rgdir WHERE srtza EQ 'A' AND fpper LE kidendda9907+0(6)."Add by VS on 08.01.2014
  ENDLOOP.
  IF sy-subrc EQ 0.
    IF r_rt NE space. "Add by VS on 09.01.2014
      PERFORM gesamt_p0008 USING kidbetrg pernr-pernr
                                 rgdir-fpbeg rgdir-fpend.
      PERFORM compare_betrg_rt USING iper-betrg pernr-pernr rgdir-fpbeg.
    ELSE. "Add by VS on 09.01.2014
      PERFORM gesamt_p0008 USING kidbetrg pernr-pernr
                                 iper-fired iper-fired.
*                                 kidendda9907 kidendda9907. "Add by VS on 08.01.2014
      iper-betrg = kidbetrg.
    ENDIF. "Add by VS on 09.01.2014
  ELSE.
    hatatext+0(2) = iper-fired+4(2).
    hatatext+2(1) = '.'.
    hatatext+3(4) = iper-fired+0(4).
    PERFORM hatatablosu USING TEXT-ers 'N' hatatext.
    CHECK fatalerr EQ space.           "Check Point
  ENDIF.
*  saat ücretli hesaplanmasının yeri değişti
*  LOOP AT rt WHERE lgart EQ '9PAY'.    "Emre Baran

  IF r_rt NE space. "Add by VS on 09.01.2014

    LOOP AT py_result-inter-rt INTO rt
            WHERE lgart EQ '9PAY'
            OR    lgart EQ '/PAY'.    "Emre Baran
      iper-betrg = ( rt-betrg / rt-anzhl ) * 1000.  "Emre Baran
    ENDLOOP.
    IF sy-subrc NE 0.
      iper-betrg = iper-betrg * 1000.   "HC 09.05.2001
    ENDIF.                              "Emre Baran
*  "IS 1.3.2005
*  READ TABLE wpbp WITH KEY begda = rgdir-fpbeg.
    READ TABLE py_result-inter-wpbp INTO wpbp
               WITH KEY begda = rgdir-fpbeg.
    h_abart = wpbp-abart.

    IF h_abart EQ '1'.                   "HC 14.11.2000
      iper-betrg = ( iper-betrg * p0008-divgv ) / 1000.
    ELSEIF h_abart EQ '3'.                          "Emre Baran
      iper-betrg =  ( iper-betrg * 30 ) / 1000.      "Emre Baran
    ENDIF.

  ENDIF. "Add by VS on 09.01.2014

* Pot. Kıdem de T9YPK tablosuna göre olası maas artısı dikkate alınır
  IF potkidem NE space.
    REFRESH it7trk03. CLEAR it7trk03.
    SELECT * FROM t7trk03 INTO TABLE it7trk03
                       WHERE persg EQ p0001-persg
                         AND werks EQ iper-werks    "EMRE BARAN
                         AND btrtl EQ iper-btrtl    "EMRE BARAN
                         AND persk EQ p0001-persk
*                         AND datum GT rgdir-fpend
                         AND datum LT pottarih
    ORDER BY datum ASCENDING.          "EMRE BARAN
    LOOP AT it7trk03.
      IF NOT it7trk03-prznt IS INITIAL.  "Emre Baran
        iper-betrg = iper-betrg + ( iper-betrg * it7trk03-prznt / 100 ).
      ENDIF.
      IF NOT it7trk03-betrg IS INITIAL.
        iper-betrg = iper-betrg + it7trk03-betrg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF iper-betrg NE 0.
    PERFORM append_rtab USING space iper-betrg 'Esas Ücret - BT 0008'.
  ELSE.
    PERFORM hatatablosu USING TEXT-erm 'N' ppbwla-lgart.
  ENDIF.
ENDFORM.                               " COUNT_UCRET
*&---------------------------------------------------------------------*
*&      Form  COUNT_T9YKD_BETRG_0
*&      Form  COUNT_T7TRK02_BETRG_0
*&---------------------------------------------------------------------*
*FORM count_t9ykd_betrg_0.
FORM count_t7trk02_betrg_0.
*  DATA: BEGIN OF l_it9ykd OCCURS 10.
*          INCLUDE STRUCTURE t9ykd.
*  DATA:   cnt  TYPE i.
*  DATA: END OF l_it9ykd.

  DATA: BEGIN OF l_it7trk02 OCCURS 10.
          INCLUDE STRUCTURE t7trk02.
  DATA:   cnt TYPE i.
  DATA: END OF l_it7trk02.

  DATA: k_beg        LIKE rgdir-fpper, k_end LIKE rgdir-fpper,
        k_fpper      LIKE rgdir-fpper,
        k_cnt_dif(2) TYPE n,
        tar1         LIKE rgdir-fpper VALUE '000000'.
  DATA p_fark TYPE i.
  DATA: e_counter TYPE i.
  DATA: e_div    TYPE i,
        lv_sgkgn TYPE anzhl.

  p_fark = iper-fired - iper-hired + 1.
*  PERFORM re9y1p USING iper-werks iper-btrtl.
  PERFORM re7trg04 USING iper-werks iper-btrtl.
  h_topay = ( iper-ktime+0(4) * 12 ) + iper-ktime+4(2).
*  SELECT  * FROM t9yih WHERE ihbar  EQ t9y1p-ihbar "HC 27.04.01
*                         AND dinst1 LE h_topay  "p_fark
*                         AND dinst2 GE h_topay  "p_fark
*                         AND begda  LE iper-fired
*                         AND endda  GE iper-fired.
*  ENDSELECT.
*  iper-tavan = t9yih-kdtav.

  SELECT  * FROM t7trk01 WHERE ihbar  EQ t7trg04-ihbar "HC 27.04.01
                         AND ihbfr  LE h_topay  "p_fark
                         AND ihfto  GE h_topay  "p_fark
                         AND begda  LE iper-fired "kidendda9907 "Change "Add by VS on 08.01.2014
                         AND endda  GE iper-fired. "kidendda9907. "Change "Add by VS on 08.01.2014
  ENDSELECT.
  iper-tavan = t7trk01-kdtav.


*  REFRESH l_it9ykd. CLEAR l_it9ykd.
*  PERFORM re9y1e USING iper-persg iper-persk.
*  LOOP AT it9ykd WHERE kidem EQ t9y1e-kidem
*                 AND   btrtl EQ iper-btrtl  " Emre Baran
*                 AND   werks EQ iper-werks  " Emre Baran
*                 AND   betrg EQ 0.
*    CLEAR l_it9ykd.
*    MOVE-CORRESPONDING it9ykd TO l_it9ykd.
*    APPEND l_it9ykd.
*  ENDLOOP.

  REFRESH l_it7trk02. CLEAR l_it7trk02.
  PERFORM re7trg03 USING iper-persg iper-persk.

  LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                   AND   betrg EQ 0           "IS 19.04.2004
                   AND werks EQ iper-werks
                   AND btrtl EQ iper-btrtl.
    CLEAR l_it7trk02.
    MOVE-CORRESPONDING it7trk02 TO l_it7trk02.
    APPEND l_it7trk02.
  ENDLOOP.


* Ek ücretler
  LOOP AT l_it7trk02.
    IF l_it7trk02-rtkum GT 12.
      l_it7trk02-rtkum = 12.
    ENDIF.
    IF l_it7trk02-rtkum GT 0.
* Prim gibi ücretler (t7trk02-BETRG = 0, t7trk02-RTKUM > 0)
      IF zsonbrd EQ space.
        k_beg = k_end = iper-fired+0(6). "E.B.-REM
        k_fpper = iper-fired+0(6).
      ELSE.
        SORT rgdir BY fpper DESCENDING "E.B.-ADD
                      srtza ASCENDING. " K.A 21.12.00
        READ TABLE rgdir INDEX 1.
        IF iper-fired+0(6) LT rgdir-fpper.
          k_fpper = iper-fired+0(6).
        ELSE.
          k_fpper = rgdir-fpper.
        ENDIF.
        k_beg = k_end = rgdir-fpper.   "E.B.-ADD
      ENDIF.
      IF k_beg+4(2) GT l_it7trk02-rtkum.
        k_beg = k_beg - l_it7trk02-rtkum.
      ELSE.
        DATA ii TYPE i.
        ii = l_it7trk02-rtkum.
        k_beg+0(4) = k_beg+0(4) - '01'.
        k_beg+4(2) = k_beg+4(2) + 12.
        DO l_it7trk02-rtkum TIMES.
          k_beg = k_beg - 1.
        ENDDO.
      ENDIF.
*     sort rgdir by fpper descending.               "E.B.- REM
*     k_fpper = iper-fired+0(6). clear k_cnt_dif.   "E.B.- REM
      CLEAR k_cnt_dif.                 "E.B.- ADD
*     LOOP AT rgdir WHERE fpper EQ k_fpper. "     "E.B.- REM
      CLEAR e_counter .
      DO.
        LOOP AT rgdir WHERE fpper EQ k_fpper. "geriye sayim.
          CHECK : rgdir-srtza EQ stand OR stand EQ space.
*          rx-key-pernr = iper-pernr.
*          UNPACK rgdir-seqnr TO rx-key-seqno.
*          rp-imp-c2-rx.
*          CHECK rp-imp-rx-subrc EQ 0.
*---Add for Upgrade by Vural SÜER on 28.05.2007
          PERFORM read_payroll USING rgdir-fpper iper-pernr
                               CHANGING py_result . "
*   PCL2/TR Boş/Dolu kontrolü
          CHECK sy-subrc EQ 0.
*---SGK Günü
          CLEAR lv_sgkgn.
          LOOP AT py_result-inter-rt INTO rt
                  WHERE lgart EQ '/NDY'
                  OR    lgart EQ '5445'
                  OR    lgart EQ '5450'.
            lv_sgkgn = lv_sgkgn + rt-anzhl.
          ENDLOOP.

*          LOOP AT rt WHERE lgart EQ l_it7trk02-lgart.
          LOOP AT py_result-inter-rt INTO rt
                  WHERE lgart EQ l_it7trk02-lgart.
            l_it7trk02-cnt = l_it7trk02-cnt + 1.
* "IS  Taner YTL çevrimi için ekledi.
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
* "IS
            READ TABLE l_it7trk02 WITH KEY lgart = rt-lgart.
            l_it7trk02-betrg = l_it7trk02-betrg + rt-betrg.
            MODIFY l_it7trk02 .
*            index sy-tabix . "IS 25.02.2005
          ENDLOOP.
          e_counter = e_counter + 1.
        ENDLOOP.
        IF k_fpper+4(2) GT 1.
          k_fpper = k_fpper - 1.
        ELSE.
          k_fpper+0(4) = k_fpper+0(4) - 1.
          k_fpper+4(2) = 12.
        ENDIF.
        IF k_fpper LE k_beg.
          EXIT.
        ENDIF.
      ENDDO.
      IF iper-hired+0(6) GE k_beg.
        IF l_it7trk02-rtkum GT e_counter.
          e_div  = ( l_it7trk02-rtdiv * e_counter ) / l_it7trk02-rtkum.
          l_it7trk02-rtdiv = e_div.
        ENDIF.
      ENDIF.
      IF l_it7trk02-rtkum GT l_it7trk02-cnt.
*---t9ygr tablosu artık kullanılmayacak
*        SELECT * FROM t9ygr WHERE pernr EQ pernr-pernr
*                              AND lgart EQ l_it7trk02-lgart.
*          CHECK t9ygr-begda+0(6) GT k_beg.
*          CHECK t9ygr-endda+0(6) LE k_end.
*          l_it7trk02-cnt = l_it7trk02-cnt + 1.
*          l_it7trk02-betrg = l_it7trk02-betrg + t9ygr-betrg.
** "IS
**          perform convert_to_local_currency using
**    ppbwla-betrg ppbwla-endda ppbwla-waers calc_currency
**ppbwla-betrg.
**
*
*          MODIFY l_it7trk02 INDEX sy-tabix.
*        ENDSELECT.
*---t9ygr tablosu artık kullanılmayacak
      ENDIF.
      IF l_it7trk02-betrg GT 0.
*       if l_it7trk02-cnt le l_it7trk02-rtdiv.
        IF l_it7trk02-rtdiv GT 0.        "E.B.- ADD
*           l_it7trk02-betrg = l_it7trk02-betrg / l_it7trk02-cnt.
*         endif.                       "E.B.- ADD
*       else.
*         if l_it7trk02-rtdiv gt 0.      "E.B.- ADD
          l_it7trk02-betrg = l_it7trk02-betrg / l_it7trk02-rtdiv.
*         endif.                       "E.B.- ADD




        ENDIF.
* "IS
        PERFORM re512t USING calcmolga l_it7trk02-lgart.

        PERFORM convert_to_local_currency USING
                  l_it7trk02-betrg ppbwla-endda ppbwla-waers
                  calc_currency  l_it7trk02-betrg .

        PERFORM append_rtab USING
           l_it7trk02-lgart l_it7trk02-betrg t512t-lgtxt.
      ENDIF.
    ELSE.
* Ikramiye ( t7trk02-BETRG = 0 & t7trk02-RTKUM = 0 olmali. )
      PERFORM re512t USING calcmolga l_it7trk02-lgart.
      IF l_it7trk02-rtdiv GT 0.
        l_it7trk02-betrg = iper-betrg / l_it7trk02-rtdiv.
      ELSE.
        l_it7trk02-betrg = iper-betrg.
      ENDIF.
      PERFORM append_rtab USING
             l_it7trk02-lgart l_it7trk02-betrg t512t-lgtxt.
    ENDIF.
  ENDLOOP.

* Sabit degerli (t7trk02-BETRG > 0) Ek gelirler.
  LOOP AT it7trk02 WHERE kidem EQ t7trg03-kidem
                 AND   btrtl EQ iper-btrtl   " Emre Baran
                 AND   werks EQ iper-werks   " Emre Baran
                 AND   betrg GT 0.

* "IS 25.02.2005 YTL Problemi
    IF NOT ppbwla-waers EQ calc_currency.
      PERFORM convert_to_local_currency USING
         ppbwla-betrg ppbwla-endda ppbwla-waers
         calc_currency ppbwla-betrg.
    ENDIF.

    PERFORM re512t USING calcmolga it7trk02-lgart.
    PERFORM append_rtab USING
           it7trk02-lgart it7trk02-betrg t512t-lgtxt.
  ENDLOOP.

* Ihbar hesaplaması.
  PERFORM count_iper USING iper-werks iper-btrtl.
*  if i9005-fagan ne 0.
  IF i0776-fagan NE 0.
    iper-ihgun = t7trk01-multi.
    PERFORM on_calc_ihbar_user_exit.
*--- 10.10.2003 mkoker
    iper-ihbar = iper-topla / 30 * iper-ihgun.
*--- 10.10.2003 mkoker
    IF i0776-fagan EQ 2.
      iper-ihbar = iper-ihbar * -1.
    ENDIF.
  ENDIF.


** Ek ücretler
*  LOOP AT l_it9ykd.
*    IF l_it9ykd-rtkum GT 12.
*      l_it9ykd-rtkum = 12.
*    ENDIF.
*    IF l_it9ykd-rtkum GT 0.
** Prim gibi ücretler (T9YKD-BETRG = 0, T9YKD-RTKUM > 0)
*      IF zsonbrd EQ space.
*        k_beg = k_end = iper-fired+0(6). "E.B.-REM
*        k_fpper = iper-fired+0(6).
*      ELSE.
*        SORT rgdir BY fpper DESCENDING "E.B.-ADD
*                      srtza ASCENDING. " K.A 21.12.00
*        READ TABLE rgdir INDEX 1.
*        IF iper-fired+0(6) LT rgdir-fpper.
*          k_fpper = iper-fired+0(6).
*        ELSE.
*          k_fpper = rgdir-fpper.
*        ENDIF.
*        k_beg = k_end = rgdir-fpper.   "E.B.-ADD
*      ENDIF.
*      IF k_beg+4(2) GT l_it9ykd-rtkum.
*        k_beg = k_beg - l_it9ykd-rtkum.
*      ELSE.
*        DATA ii TYPE i.
*        ii = l_it9ykd-rtkum.
*        k_beg+0(4) = k_beg+0(4) - '01'.
*        k_beg+4(2) = k_beg+4(2) + 12.
*        DO l_it9ykd-rtkum TIMES.
*          k_beg = k_beg - 1.
*        ENDDO.
*      ENDIF.
**     sort rgdir by fpper descending.               "E.B.- REM
**     k_fpper = iper-fired+0(6). clear k_cnt_dif.   "E.B.- REM
*      CLEAR k_cnt_dif.                 "E.B.- ADD
**     LOOP AT rgdir WHERE fpper EQ k_fpper. "     "E.B.- REM
*      CLEAR e_counter .
*      DO.
*        LOOP AT rgdir WHERE fpper EQ k_fpper. "geriye sayim.
*          CHECK : rgdir-srtza EQ stand OR stand EQ space.
*          rx-key-pernr = iper-pernr.
*          UNPACK rgdir-seqnr TO rx-key-seqno.
*          rp-imp-c2-rx.
*          CHECK rp-imp-rx-subrc EQ 0.
*          LOOP AT rt WHERE lgart EQ l_it9ykd-lgart.
*            l_it9ykd-cnt = l_it9ykd-cnt + 1.
** "IS  Taner YTL çevrimi için ekledi.
*            IF rgdir-fpper LE '200412' .
*              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
*                EXPORTING
*                  client           = sy-mandt
*                  date             = '20050101'
*                  foreign_amount   = rt-betrg
*                  foreign_currency = 'TRL'
*                  local_currency   = ypb
*                IMPORTING
*                  local_amount     = rt-betrg.
*
*            ENDIF.
** "IS
*            READ TABLE l_it9ykd WITH KEY lgart = rt-lgart.
*            l_it9ykd-betrg = l_it9ykd-betrg + rt-betrg.
*            MODIFY l_it9ykd .
**            index sy-tabix . "IS 25.02.2005
*          ENDLOOP.
*          e_counter = e_counter + 1.
*        ENDLOOP.
*        IF k_fpper+4(2) GT 1.
*          k_fpper = k_fpper - 1.
*        ELSE.
*          k_fpper+0(4) = k_fpper+0(4) - 1.
*          k_fpper+4(2) = 12.
*        ENDIF.
*        IF k_fpper LE k_beg.
*          EXIT.
*        ENDIF.
*      ENDDO.
*      IF iper-hired+0(6) GE k_beg.
*        IF l_it9ykd-rtkum GT e_counter.
*          e_div  = ( l_it9ykd-rtdiv * e_counter ) / l_it9ykd-rtkum.
*          l_it9ykd-rtdiv = e_div.
*        ENDIF.
*      ENDIF.
*      IF l_it9ykd-rtkum GT l_it9ykd-cnt.
*        SELECT * FROM t9ygr WHERE pernr EQ pernr-pernr
*                              AND lgart EQ l_it9ykd-lgart.
*          CHECK t9ygr-begda+0(6) GT k_beg.
*          CHECK t9ygr-endda+0(6) LE k_end.
*          l_it9ykd-cnt = l_it9ykd-cnt + 1.
*          l_it9ykd-betrg = l_it9ykd-betrg + t9ygr-betrg.
** "IS
**          perform convert_to_local_currency using
**    ppbwla-betrg ppbwla-endda ppbwla-waers calc_currency
**ppbwla-betrg.
**
*
*          MODIFY l_it9ykd INDEX sy-tabix.
*        ENDSELECT.
*      ENDIF.
*      IF l_it9ykd-betrg GT 0.
**       if l_it9ykd-cnt le l_it9ykd-rtdiv.
*        IF l_it9ykd-rtdiv GT 0.        "E.B.- ADD
**           l_it9ykd-betrg = l_it9ykd-betrg / l_it9ykd-cnt.
**         endif.                       "E.B.- ADD
**       else.
**         if l_it9ykd-rtdiv gt 0.      "E.B.- ADD
*          l_it9ykd-betrg = l_it9ykd-betrg / l_it9ykd-rtdiv.
**         endif.                       "E.B.- ADD
*
*
*
*
*        ENDIF.
** "IS
*        PERFORM re512t USING calcmolga l_it9ykd-lgart.
*
*        PERFORM convert_to_local_currency USING
*                  l_it9ykd-betrg ppbwla-endda ppbwla-waers
*                  calc_currency  l_it9ykd-betrg .
*
*        PERFORM append_rtab USING
*           l_it9ykd-lgart l_it9ykd-betrg t512t-lgtxt.
*      ENDIF.
*    ELSE.
** Ikramiye ( T9YKD-BETRG = 0 & T9YKD-RTKUM = 0 olmali. )
*      PERFORM re512t USING calcmolga l_it9ykd-lgart.
*      IF l_it9ykd-rtdiv GT 0.
*        l_it9ykd-betrg = iper-betrg / l_it9ykd-rtdiv.
*      ELSE.
*        l_it9ykd-betrg = iper-betrg.
*      ENDIF.
*      PERFORM append_rtab USING
*             l_it9ykd-lgart l_it9ykd-betrg t512t-lgtxt.
*    ENDIF.
*  ENDLOOP.
*
** Sabit degerli (T9YKD-BETRG > 0) Ek gelirler.
*  LOOP AT it9ykd WHERE kidem EQ t9y1e-kidem
*                 AND   btrtl EQ iper-btrtl   " Emre Baran
*                 AND   werks EQ iper-werks   " Emre Baran
*                 AND   betrg GT 0.
*
** "IS 25.02.2005 YTL Problemi
*    IF NOT ppbwla-waers EQ calc_currency.
*      PERFORM convert_to_local_currency USING
*         ppbwla-betrg ppbwla-endda ppbwla-waers
*         calc_currency ppbwla-betrg.
*    ENDIF.
*
*    PERFORM re512t USING calcmolga it9ykd-lgart.
*    PERFORM append_rtab USING
*           it9ykd-lgart it9ykd-betrg t512t-lgtxt.
*  ENDLOOP.
*
** Ihbar hesaplaması.
*  PERFORM count_iper USING iper-werks iper-btrtl.
**  if i9005-fagan ne 0.
*  IF i0776-fagan NE 0.
*    iper-ihgun = T7TRK01-multi.
*    PERFORM on_calc_ihbar_user_exit.
**--- 10.10.2003 mkoker
*    iper-ihbar = iper-topla / 30 * iper-ihgun.
**--- 10.10.2003 mkoker
*    IF i0776-fagan EQ 2.
*      iper-ihbar = iper-ihbar * -1.
*    ENDIF.
*  ENDIF.

ENDFORM.                               " COUNT_PRIMS
*&---------------------------------------------------------------------*
*&      Form  COUNT_COCUK
*&---------------------------------------------------------------------*
*FORM count_cocuk.
* Çocuk Yardımı
*  rp-read-infotype pernr-pernr 9004 p9004 iper-fired iper-fired.
*  PERFORM re9y1p USING p0001-werks p0001-btrtl.
*  SELECT * FROM t9ytx WHERE grtax EQ t9y1p-grtax AND
*                            sskgr EQ p9004-sskgr AND
*                            begda LE iper-fired AND
*                            endda GE iper-fired.
*  ENDSELECT.
*  IF p9004-child GT 2.
*    p9004-child = 2.
*  ENDIF.
*  kidbetrg = p9004-child * t9ytx-cocuk.
*  PERFORM append_rtab USING wty_9chd kidbetrg 'Çocuk Parası'.
*ENDFORM.                               " COUNT_COCUK
*&---------------------------------------------------------------------*
*&      Form  COUNT_SEHIR
*&---------------------------------------------------------------------*
FORM count_sehir.
* Personelin şehrini bulur
*  SELECT SINGLE * FROM t9y1p WHERE werks EQ it9yd1-werks
*                               AND btrtl EQ it9yd1-btrtl.
  SELECT SINGLE * FROM t7trg04 WHERE werks EQ it7trg01-werks
  AND   btrtl EQ it7trg01-btrtl.
  IF sy-subrc EQ 0.
*    iper-sehir = t9y1p-prcty.
    iper-sehir = t7trg04-prcty.
  ENDIF.

ENDFORM.                               " COUNT_SEHIR

*&---------------------------------------------------------------------*
*&      Form  APPEND_IPER
*&---------------------------------------------------------------------*
FORM append_iper.
  DATA: lv_ktime TYPE begda.

*---İhbar hesaplanmayacaksa clear et
  IF ihbarhesapla EQ space.
    CLEAR: iper-ihgun,
           iper-ihbar.
  ENDIF.

* Hata testi yapar; yoksa personeli iper e ekler.
  CLEAR hatatab.
  LOOP AT hatatab WHERE werks EQ pernr-werks
                    AND btrtl EQ pernr-btrtl
                    AND pernr EQ pernr-pernr
                    AND norml EQ 'N'.
  ENDLOOP.
  IF sy-subrc NE 0.
*    IF p9907[] IS INITIAL.  "Add by VS on 08.01.2014
    CLEAR iper-hired.
*    ENDIF. "Add by VS on 08.01.2014
    IF potkidem = 'X' AND hakeden = 'X'.
*      IF p9907[] IS INITIAL.  "Add by VS on 08.01.2014
      IF iper-ktime+0(4) GT 0.
        APPEND iper.
      ENDIF.
*      ELSE."Add by VS on 08.01.2014
*        lv_ktime = kidendda9907 - iper-firsthired. "Add by VS on 08.01.2014
*        IF lv_ktime+0(4) GT 0."Add by VS on 08.01.2014
*          APPEND iper."Add by VS on 08.01.2014
*        ENDIF."Add by VS on 08.01.2014
*      ENDIF."Add by VS on 08.01.2014
    ELSE.
      APPEND iper.
    ENDIF.
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
    ULINE AT /(80).
    WRITE: / sy-vline                       NO-GAP,
                              ' '           , "NO-GAP,
           'PeAl PeAA'(pbe)                 , "NO-GAP,
           'SSK Numarası            '         , "NO-GAP,
           'TTF No.     '                   , "NO-GAP,
           'İşyerinin Adı               '   NO-GAP,
             sy-vline.
    ULINE AT /(80).
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
  LOOP AT it7trg01.
    READ TABLE iper WITH KEY werks = it7trg01-werks
                             btrtl = it7trg01-btrtl.
    IF sy-subrc EQ 0.
      PERFORM write_t7trg01.
    ELSE.
      DELETE it7trg01.                   " INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.
*  LOOP AT iT7TRG01.
*    MOVE-CORRESPONDING iT7TRG01 TO itemp. APPEND itemp.
*  ENDLOOP.
  IF it7trg01[] IS INITIAL.
    PERFORM set_gui_02.
    PERFORM write_hatatablosu USING '' 'N'.
  ELSE.
    ULINE AT /1(80).
  ENDIF.

ENDFORM.                               " END_OF_SELECTION
*&---------------------------------------------------------------------*
*&      Form  TABLES_TO_ITABS
*&---------------------------------------------------------------------*
FORM tables_to_itabs.
  PERFORM get_currency USING calcmolga
                             calc_currency
                             save_calc_currency
                             kidbegda
                             c_fact.

*  SELECT * FROM t9ypf INTO TABLE it9ypf WHERE
*                            dtart EQ 'PF' OR dtart EQ 'FP'.

  SELECT * FROM t7trg01 INTO TABLE it7trg01 WHERE
                                  werks IN pnpwerks AND
                                  btrtl IN pnpbtrtl AND
                                  begda LE kidendda AND
                                  endda GE kidendda
  ORDER BY werks btrtl.

*  SELECT * FROM t9ykd INTO TABLE it9ykd
*                      WHERE begda LE kidendda AND endda GE kidendda.

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

  CASE sy-ucomm.
    WHEN 'RW'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'LEAV'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'CANC'.
      LEAVE SCREEN.
    WHEN 'MALL'.
      PERFORM check_uncheck_line USING 'X'.
    WHEN 'MDEL'.
      PERFORM check_uncheck_line USING space.
    WHEN 'ERRO'.
      PERFORM set_gui_02.
      PERFORM write_hatatablosu USING '' 'N'.
    WHEN 'HATA'.
      PERFORM set_gui_02.
      PERFORM write_hatatablosu USING '' 'W'.
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
    WHEN 'WTYP' OR 'BUKR' OR 'PERS' OR 'NORM'.
      CLEAR: kidemtop.
      DO.
        CLEAR: m1.
        READ LINE sy-index FIELD VALUE m1.
        IF sy-subrc NE 0.
          EXIT.
        ELSE.
          CHECK m1 = 'X'.
          m1 = space.
          CASE sy-ucomm.
            WHEN 'WTYP'.
              PERFORM set_gui_02.
              PERFORM write_potkidembtrtl
                      USING it7trg01-werks it7trg01-btrtl.
            WHEN 'BUKR'.
              PERFORM set_gui_02.
              SELECT SINGLE bukrs INTO lt_b-bukrs
              FROM t500p WHERE persa EQ it7trg01-werks.
              IF sy-subrc EQ 0.
                COLLECT lt_b.
              ENDIF.
            WHEN 'PERS'.
              PERFORM set_gui_02.
              PERFORM write_potkidempersk
                      USING it7trg01-werks it7trg01-btrtl.
            WHEN 'NORM'.
              PERFORM set_gui_01.
              PERFORM write_norkidem USING '' ''.
          ENDCASE.
        ENDIF.
      ENDDO.

      IF sy-ucomm EQ 'BUKR'.
        LOOP AT lt_b.
          PERFORM write_potkidembukrs
                          USING lt_b-bukrs.
        ENDLOOP.
      ENDIF.

      gv_current_screen = sy-ucomm.

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

    WHEN 'DETY'.
      DO.
        CLEAR: m1.
        READ LINE sy-index FIELD VALUE m1.
        IF sy-subrc NE 0.
          EXIT.
        ELSE.
          CHECK m1 = 'X'.
          CHECK iper-pernr NE space.
          PERFORM set_gui_01.
          lt_p-pernr = iper-pernr.
          COLLECT lt_p.
        ENDIF.
      ENDDO.
      LOOP AT lt_p.
        PERFORM write_norkidem USING lt_p-pernr
                                     ''.
      ENDLOOP.

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
    WHEN 'DOWN'.
*{   REPLACE        IS3K900017                                        1
*\      REFRESH TC.
*\      LOOP AT IPER.
*\        MOVE-CORRESPONDING IPER TO TC.
*\        APPEND TC.
*\      ENDLOOP.
*\      PERFORM WRITE_FNAMES.
*\      PERFORM TABLE_CONTROL TABLES TC FNAMES
*\                          USING 'HR Kıdem Raporu Sonuçları' SY-REPID.
*---t9y04 artık kullanılmayacak
*      PERFORM call_list_viewer.
*---t9y04 artık kullanılmayacak
*
*}   REPLACE
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
  APPEND 'BTC2' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'DETY' TO xfcode.
  SET PF-STATUS 'YPCKIDEM'  EXCLUDING xfcode.
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
  APPEND 'MALM' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'TRANSLIST' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  IF kidmtest NE space OR sy-ucomm EQ 'DETY'.
    APPEND 'BATC' TO xfcode.
    APPEND 'DOWN' TO xfcode.
  ENDIF.
  SET PF-STATUS 'YPCKIDEM' EXCLUDING xfcode.
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
  ELSE.
  ENDIF.
  APPEND 'TRAN' TO xfcode.
  APPEND 'BUKR' TO xfcode.
  APPEND 'NORM' TO xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'MALM' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  SET PF-STATUS 'YPCKIDEM' EXCLUDING xfcode.
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
  APPEND 'DOWN' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'MALM' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'TRAN' TO xfcode.
  APPEND 'BUKR' TO xfcode.
  SET PF-STATUS 'YPCKIDEM' EXCLUDING xfcode.
ENDFORM.                                                    "set_gui_03

*---------------------------------------------------------------------*
*       FORM set_gui_10                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM set_gui_10.
  REFRESH xfcode. CLEAR xfcode.
  APPEND 'BATC' TO xfcode.
  APPEND 'DOWN' TO xfcode.
  APPEND 'WTYP' TO xfcode.
  APPEND 'PERS' TO xfcode.
  APPEND 'MALM' TO xfcode.
  APPEND 'DETY' TO xfcode.
  APPEND 'BTC2' TO xfcode.
  APPEND 'TRAN' TO xfcode.
  APPEND 'BUKR' TO xfcode.
  SET PF-STATUS 'YPCKIDEM' EXCLUDING xfcode.
ENDFORM.                                                    "set_gui_10

*---------------------------------------------------------------------*
*       FORM call_list_viewer                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*FORM call_list_viewer.
*  REFRESH it9y04. CLEAR it9y04.
*  LOOP AT iper.
*    IF iper-kidem GT 0.
*      it9y04-pernr = iper-pernr.
*      it9y04-monat = iper-fired+4(2).
*      it9y04-gjahr = iper-fired+0(4).
*      it9y04-kennz = 'K'.
*      it9y04-betrg = iper-kidem + iper-kikek.
*      it9y04-waers = calc_currency.
*      APPEND it9y04.
*    ENDIF.
*    IF iper-ihbar NE 0.                                     "gt
*      it9y04-kennz = 'I'.
*      it9y04-betrg = iper-ihbar.
*      it9y04-waers = calc_currency.
*      APPEND it9y04.
*    ENDIF.
*  ENDLOOP.
** Call ABAP/4 List Viewer
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
*    EXPORTING
*      i_structure_name = 'T9Y04'
*    TABLES
*      t_outtab         = it9y04.
*ENDFORM.                    "call_list_viewer


*&---------------------------------------------------------------------*
*&      Form  WRITE_HATATABLOSU
*&---------------------------------------------------------------------*
FORM write_hatatablosu USING p_btrtl p_norml.
  DATA hatpernr LIKE hatatab-pernr.
  DATA hatatmp LIKE hatatab OCCURS 0 WITH HEADER LINE.
  LOOP AT hatatab WHERE norml EQ p_norml.
    IF p_btrtl NE space.
      CHECK hatatab-btrtl EQ p_btrtl.
    ENDIF.
    MOVE-CORRESPONDING hatatab TO hatatmp.
    APPEND hatatmp.
  ENDLOOP.
  SORT hatatmp BY werks btrtl pernr.
  LOOP AT hatatmp.
    READ TABLE it7trg01 WITH KEY werks = hatatmp-werks
                               btrtl = hatatmp-btrtl.
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
**&---------------------------------------------------------------------
**
**&      Form  RE9Y1E
**&---------------------------------------------------------------------
**
*FORM re9y1e USING $persg $persk.
*  CHECK t7trg03-persg NE $persg OR t7trg03-persk NE $persk.
*  SELECT SINGLE * FROM t9y1e WHERE persg EQ $persg
*                             AND   persk EQ $persk.
*  IF sy-subrc NE 0.
*    CLEAR t9y1e.
*  ENDIF.
*ENDFORM.                                                    " RE9Y1E
*&---------------------------------------------------------------------*
*&      Form  COUNT_IPER
*&---------------------------------------------------------------------*
FORM count_iper USING $werks $btrtl.
  DATA p_fark TYPE i.

  CLEAR iper-ekucr.
  LOOP AT rtab WHERE pernr EQ iper-pernr.
    IF rtab-lgart IS INITIAL.
      iper-betrg = rtab-betrg.
    ELSE.
      iper-ekucr = iper-ekucr + rtab-betrg.
    ENDIF.
  ENDLOOP.
  iper-topla = iper-betrg + iper-ekucr.
  IF iper-topla > iper-tavan.
    iper-k1yil = iper-tavan.
  ELSE.
    iper-k1yil = iper-topla.
  ENDIF.

*  read table i9005 with key pernr = iper-pernr.
  READ TABLE i0776 WITH KEY pernr = iper-pernr.
  IF sy-subrc NE 0 AND potkidem NE space.
    PERFORM on_potantial_wo9005_user_exit.
  ELSEIF  sy-subrc NE 0 AND norkidem NE space.
    PERFORM hatatablosu USING
'9005 de kayıt bulunamadığı için standart değerler ile işlem yapılacak'
  'W' space.
    PERFORM on_normal_wo9005_user_exit.
  ENDIF.
*  if i9005-knorm eq 1.
*    if i9005-fprtg eq 0 and i9005-kidtg gt 30.
*      iper-k1yil = iper-k1yil / 30 * i9005-kidtg.
*    elseif i9005-fprtg eq 1 and i9005-kidpr gt 100.
*      iper-k1yil = iper-k1yil / 100 * i9005-kidpr.
*    endif.
  IF i0776-knorm EQ 1.
    IF i0776-fprtg EQ 0 AND i0776-kidtg GT 30.
      iper-k1yil = iper-k1yil / 30 * i0776-kidtg.
    ELSEIF i0776-fprtg EQ 1 AND i0776-kidpr GT 100.
      iper-k1yil = iper-k1yil / 100 * i0776-kidpr.
    ENDIF.
    IF iper-k1yil > t7trk01-kdtav.
      iper-kikek = iper-k1yil - iper-tavan.
      iper-k1yil = iper-tavan.
    ENDIF.
  ENDIF.
  PERFORM on_compensation_user_exit.
*--- 10.10.2003  mkoker
  iper-kidem = iper-kidem + ( iper-ktime+0(4) *   iper-k1yil ).
  iper-kidem = iper-kidem + ( iper-ktime+4(2) * ( iper-k1yil / 12  ) ).
*  iper-kidem = iper-kidem + ( iper-ktime+6(2) * ( iper-k1yil / 360 ) ).
  iper-kidem = iper-kidem + ( iper-ktime+6(2) * ( iper-k1yil / 365 ) ).
*--- 10.10.2003  mkoker
ENDFORM.                               " COUNT_KIDEM
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMBTRTL
*&---------------------------------------------------------------------*
FORM write_potkidembtrtl USING $werks $btrtl.
*  LOOP AT itemp WHERE secil NE space.
  SORT iper BY werks btrtl pernr.
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
      FORMAT COLOR COL_NORMAL.
      IF potkidem = 'X' AND ozet NE 'X'.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
            AT c_i04 sy-vline.
        ULINE AT /1(c_i04).
      ELSE.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
             AT c_i01 sy-vline.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    PERFORM write_potline.
    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF btrtl.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT END OF werks.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT LAST.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_POTKIDEMBTRTL
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMBUKRS
*&---------------------------------------------------------------------*
FORM write_potkidembukrs USING $bukrs.
*  LOOP AT itemp WHERE secil NE space.
  SORT iper BY bukrs pernr.
  LOOP AT iper WHERE bukrs EQ $bukrs.
    AT NEW bukrs.
      SELECT * FROM t001
             WHERE bukrs = iper-bukrs.
      ENDSELECT.
      IF sy-subrc NE 0.
        t001-butxt = 'BULUNAMADI'.
      ENDIF.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL.
      IF potkidem = 'X' AND ozet NE 'X'.
        WRITE: / sy-vline, iper-bukrs COLOR COL_GROUP,
                           t001-butxt,
*                          iT7TRG01-name1,
            AT c_i04 sy-vline.
        ULINE AT /1(c_i04).
      ELSE.
        WRITE: / sy-vline, iper-bukrs COLOR COL_GROUP,
                           t001-butxt,
*                          iT7TRG01-name1,
             AT c_i01 sy-vline.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    PERFORM write_potline.
    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF bukrs.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'ŞİRKET TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'ŞİRKET TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT LAST.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_POTKIDEMBUKRS

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
            AT c_i04 sy-vline.
        ULINE AT /1(c_i04).
      ELSE.
        WRITE: / sy-vline, iper-werks COLOR COL_HEADING,
                           iper-btrtl COLOR COL_GROUP,
                           t001p-btext,
*                          iT7TRG01-name1,
             AT c_i01 sy-vline.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    PERFORM write_potline.
    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF btrtl.
      SUM.
      iper = ipersum.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'PERSONEL ALT ALANI TOPLAMI :' paa_kisi.
        CLEAR paa_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT END OF werks.
      SUM.
      iper = ipersum.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam
                USING 'PERSONEL ALANI TOPLAMI :' pa_kisi.
        CLEAR pa_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT LAST.
      SUM.
      iper = ipersum.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
        FORMAT COLOR COL_GROUP.
        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
        CLEAR top_kisi.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_TRANSFER_LIST

*&---------------------------------------------------------------------*
*&      Form  WRITE_POTLINE
*&---------------------------------------------------------------------*
FORM write_potline.
  DATA: lv_atext TYPE abktx.

  IF iper-gesch EQ 1.
    cins = 'E'.
  ELSEIF iper-gesch EQ 2.
    cins = 'K'.
  ELSE.
    cins = ' '.
  ENDIF.

  SELECT SINGLE atext INTO lv_atext
                FROM t549t
                     WHERE sprsl EQ sy-langu
  AND   abkrs EQ iper-abkrs.

  IF potkidem = 'X' AND ozet NE 'X'.
    WRITE: / sy-vline       , m1 AS CHECKBOX ,
             sy-vline NO-GAP, iper-pernr NO-GAP COLOR COL_KEY,
             sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
             sy-vline NO-GAP, iper-kostl NO-GAP,
             sy-vline NO-GAP, lv_atext NO-GAP,
             sy-vline NO-GAP, iper-gbdat NO-GAP,
             sy-vline NO-GAP, cins       NO-GAP,
             sy-vline NO-GAP, iper-firsthired NO-GAP,
             sy-vline NO-GAP, iper-hired NO-GAP,
             sy-vline NO-GAP, iper-gtime NO-GAP,
             sy-vline NO-GAP, iper-ktime NO-GAP,
             sy-vline NO-GAP,
        (16) iper-betrg CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-ekucr CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-topla CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-k1yil CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-kiton CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-kidem CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-ihbar CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline.
  ELSE.
    WRITE: / sy-vline       , m1 AS CHECKBOX ,
             sy-vline NO-GAP, iper-pernr NO-GAP COLOR COL_KEY,
             sy-vline NO-GAP, iper-ename(21) NO-GAP COLOR COL_KEY,
             sy-vline NO-GAP, iper-kostl NO-GAP,
             sy-vline NO-GAP, lv_atext NO-GAP,
             sy-vline NO-GAP, iper-gbdat NO-GAP,
             sy-vline NO-GAP, cins       NO-GAP,
             sy-vline NO-GAP, iper-firsthired NO-GAP,
             sy-vline NO-GAP, iper-hired NO-GAP,
             sy-vline NO-GAP, iper-gtime NO-GAP,
             sy-vline NO-GAP, iper-ktime NO-GAP,
             sy-vline NO-GAP,
        (16) iper-k1yil CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-kiton CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline NO-GAP,
        (16) iper-kidem CURRENCY calc_currency NO-ZERO NO-GAP,
             sy-vline.
  ENDIF.
  HIDE iper.
ENDFORM.                               " WRITE_POTLINE
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
FORM write_pottoplam USING  p_tptext p_kisi.
  IF potkidem = 'X' AND ozet NE 'X'.
    WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
          AT c_i03(34) iper-betrg CURRENCY calc_currency NO-GAP NO-ZERO,
                  (34) iper-topla CURRENCY calc_currency NO-GAP NO-ZERO,
                  (34) iper-kiton CURRENCY calc_currency NO-GAP NO-ZERO,
                  (34) iper-ihbar CURRENCY calc_currency NO-GAP NO-ZERO,
          AT c_i04 sy-vline.
    WRITE: / sy-vline,
          AT c_i02(34) iper-ekucr CURRENCY calc_currency NO-GAP NO-ZERO,
                  (34) iper-k1yil CURRENCY calc_currency NO-GAP NO-ZERO,
                  (34) iper-kidem CURRENCY calc_currency NO-GAP NO-ZERO,
          AT c_i04 sy-vline.
  ELSE.
    WRITE: / sy-vline, p_tptext, p_kisi, 'Kişi',
         AT c_i02(34) iper-kiton CURRENCY calc_currency NO-GAP NO-ZERO,
                 (17) iper-kidem CURRENCY calc_currency NO-GAP NO-ZERO,
         AT c_i01 sy-vline.
    WRITE: / sy-vline,
         AT c_i03(34) iper-k1yil CURRENCY calc_currency NO-GAP NO-ZERO,
         AT c_i01 sy-vline.
  ENDIF.
ENDFORM.                               " WRITE_POTTOPLAM
*&---------------------------------------------------------------------*
*&      Form  WRITE_NORKIDEM
*&---------------------------------------------------------------------*
FORM write_norkidem USING p_pernr p_hired.
  DATA ip_pernr LIKE pnppernr OCCURS 1 WITH HEADER LINE.
  RANGES ip_hired FOR pnpbegda.

  IF p_pernr NE space.
    ip_pernr-sign   = 'I'.
    ip_pernr-option = 'EQ'.
    ip_pernr-low    =  p_pernr.
    APPEND ip_pernr.
  ENDIF.
  IF p_hired NE space.
    ip_hired-sign   = 'I'.
    ip_hired-option = 'EQ'.
    ip_hired-low    =  p_hired.
    APPEND ip_hired.
  ENDIF.

  IF gv_current_screen EQ 'TRAN'.
    LOOP AT ipersum WHERE pernr IN ip_pernr
                    AND   hired IN ip_hired.

      iper = ipersum. "Add by VS on 08.01.2014

      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      READ TABLE it7trg01 WITH KEY werks = iper-werks
                                 btrtl = iper-btrtl.
      PERFORM write_blokkidem.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      PERFORM write_blokbetrg.
    ENDLOOP.
  ELSE.
    LOOP AT iper WHERE  pernr IN ip_pernr
                  AND   hired IN ip_hired.

      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      READ TABLE it7trg01 WITH KEY werks = iper-werks
                                 btrtl = iper-btrtl.
      PERFORM write_blokkidem.
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      PERFORM write_blokbetrg.
    ENDLOOP.
  ENDIF.
ENDFORM.                               " WRITE_NORKIDEM

*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMPERSK
*&---------------------------------------------------------------------*
FORM write_potkidempersk USING $werks $btrtl.
  DATA p_persg LIKE iper-persg.
  SORT iper BY persg persk pernr.
*  LOOP AT itemp WHERE secil EQ 'X'.
  LOOP AT iper WHERE werks EQ $werks
                 AND btrtl EQ $btrtl.
    p_persg = iper-persg.
    AT NEW persk.
      NEW-PAGE.
      FORMAT COLOR COL_NORMAL.
      SELECT SINGLE * FROM t503t WHERE sprsl EQ sy-langu
      AND persk EQ iper-persk.
      IF sy-subrc NE 0.
        CLEAR t503t.
      ENDIF.
      IF potkidem = 'X' AND ozet NE 'X'.
        WRITE: / sy-vline,
                 p_persg COLOR COL_HEADING,
                 iper-persk COLOR COL_GROUP,
                 t503t-ptext,
            AT c_i04 sy-vline.
        ULINE AT /1(c_i04).
      ELSE.
        WRITE: / sy-vline,
                 p_persg COLOR COL_HEADING,
                 iper-persk COLOR COL_GROUP,
                 t503t-ptext,
           AT c_i01 sy-vline.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    PERFORM write_potline.
    paa_kisi = paa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF persk.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
      ENDIF.
      FORMAT COLOR COL_TOTAL.
      PERFORM write_pottoplam
              USING 'ÇALIŞAN ALT GRUBU TOPLAMI :' paa_kisi.
      CLEAR paa_kisi.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
    AT LAST.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
      ENDIF.
      FORMAT COLOR COL_GROUP.
      PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi.
      CLEAR top_kisi.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_i04).
      ELSE.
        ULINE AT /1(c_i01).
      ENDIF.
    ENDAT.
  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_POTKIDEMPERSK
*&---------------------------------------------------------------------*
*&      Form  WRITE_KIDEMBLOK
*&---------------------------------------------------------------------*
FORM write_blokkidem.
  NEW-PAGE.
  WRITE: / sy-vline, 'Personel Sicil No :', iper-pernr  ,
        69 sy-vline.
  WRITE: / sy-vline, 'Adı ve Soyadı     :', iper-ename  ,
        69 sy-vline.
  WRITE: / sy-vline, 'İşyeri            :', it7trg01-name1,
        69 sy-vline.
  WRITE: / sy-vline, 'İşyeri Ünvanı     :', it7trg01-name2,
        69 sy-vline.
  WRITE: / sy-vline, 'İşyeri Adresi     :', it7trg01-stras,
        69 sy-vline.
  WRITE: / sy-vline,                        it7trg01-stret
                                      UNDER it7trg01-name1,
        69 sy-vline.

*  SELECT SINGLE * FROM t9y01 WHERE city EQ iT7TRG01-city.

*---Data Definitions
  DATA: gv_val LIKE dd07v-domvalue_l,
        gv_txt LIKE dd07v-ddtext.

  MOVE it7trg01-city TO gv_val.
  CALL FUNCTION 'QC04_DOMAIN_TEXT_GET'
    EXPORTING
      i_domain_name = 'PTR_CITY'
      i_language    = sy-langu
      i_domvalue_l  = gv_val
    IMPORTING
      e_ddtext      = gv_txt
    EXCEPTIONS
      no_data_found = 1
      OTHERS        = 2.

  WRITE: / sy-vline,                        it7trg01-pfach
                                      UNDER it7trg01-name1,
                                            it7trg01-sdist,
                                            gv_txt(15) ,
*                                            t9y01-ctext ,
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
                          rtab-betrg  CURRENCY calc_currency,
             sy-vline.
  ENDLOOP.
  ULINE AT /(69).
  WRITE: / sy-vline, 'Toplam miktar', iper-topla UNDER rtab-betrg
                                      CURRENCY calc_currency,
           sy-vline.
  WRITE: / sy-vline, 'Kıdem tavanı ', iper-tavan UNDER rtab-betrg
                                      CURRENCY calc_currency,
           sy-vline.
  WRITE: / sy-vline, 'Kidem hesaplamasına esas miktar',
                                      iper-k1yil UNDER rtab-betrg
                                      CURRENCY calc_currency,
           sy-vline.
  ULINE AT /(69).

  DATA: lv_hired TYPE datum.
  IF iper-hired IS INITIAL.
    lv_hired = iper-firsthired.
  ELSE.
    lv_hired = iper-hired.
  ENDIF.

  WRITE: / sy-vline, 'Çalıştıgı zaman dilimi:',
                                   44 lv_hired,  "iper-hired,
                                   '-' , iper-fired,
*                                   44 iper-firsthired, '-' , iper-fired,
        69 sy-vline.
  WRITE: / sy-vline, 'Part-Time süresi   :'  ,
                                   42 iper-ptime+0(4) NO-ZERO, 'Yıl',
                                      iper-ptime+4(2) NO-ZERO, 'Ay ',
                                      iper-ptime+6(2) NO-ZERO, 'Gün',
        69 sy-vline.
  WRITE: / sy-vline, 'Full-Time süresi   :'  ,
                                   42 iper-ftime+0(4) NO-ZERO, 'Yıl',
                                      iper-ftime+4(2) NO-ZERO, 'Ay ',
                                      iper-ftime+6(2) NO-ZERO, 'Gün',
        69 sy-vline.
  WRITE: / sy-vline,  'Esas alınmayan süre:'  ,
                                   42 iper-gtime+0(4) NO-ZERO, 'Yıl' ,
                                      iper-gtime+4(2) NO-ZERO, 'Ay ' ,
                                      iper-gtime+6(2) NO-ZERO, 'Gün' ,
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
  gunlktop = iper-ktime+6(2) * ( iper-k1yil / 365 ).
  ayliktop = iper-ktime+4(2) * ( iper-k1yil / 12  ).
  yillktop = iper-ktime+0(4) *   iper-k1yil .
  aylik    = ( iper-k1yil / 12 ).
  gunlk    = ( iper-k1yil / 365 ).

*---< Begin of add by vsuer on 14.02.2011
  IF bykkid IS INITIAL.
*---> End of add by vsuer on 14.02.2011

    WRITE: / sy-vline, '    Yıl:', iper-ktime+0(4), 19 '*',
                                   iper-k1yil
                                            CURRENCY calc_currency, '=',
                         47 yillktop        CURRENCY calc_currency,
          69 sy-vline.

    WRITE: / sy-vline, '     Ay:', iper-ktime+4(2), 19 '*',
                            aylik           CURRENCY calc_currency, '=',
                         47 ayliktop        CURRENCY calc_currency,
          69 sy-vline.

    WRITE: / sy-vline, '    Gün:', iper-ktime+6(2), 19 '*',
                            gunlk           CURRENCY calc_currency, '=',
                         47 gunlktop        CURRENCY calc_currency,
          69 sy-vline.
    ULINE AT /(69).
  ENDIF.

  IF iper-ktime GE '00010000' .
    FORMAT COLOR COL_TOTAL.
    PERFORM write_footer1 USING gunlktop.
  ELSE.
    FORMAT COLOR COL_NEGATIVE.
    PERFORM write_footer1 USING gunlktop.
  ENDIF.
  ULINE AT /(69).

  IF iper-ihgun GT 0 AND iper-ihbar NE 0.                   "gt

    WRITE: / sy-vline, 'İhbar hesaplamasına esas miktar',
                     47 iper-topla            CURRENCY calc_currency,
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
FORM loop_for_batch.
  LOOP AT iper.
*    read table i9005 with key pernr = iper-pernr.
    READ TABLE i0776 WITH KEY pernr = iper-pernr.
    IF sy-subrc EQ 0.
      IF iper-kidem GT 0.
*---t9y04 artık kullanılmıyor
*        SELECT * FROM t9y04 WHERE pernr EQ iper-pernr
*                              AND kennz EQ 'K'
*                              AND monat EQ iper-fired+4(2)
*                              AND gjahr EQ iper-fired+0(4).
*          CHECK recalckd EQ 'X'.
*          DELETE t9y04.
*          PERFORM hatatablosu USING
*         'KIDEM: T9Y04 Tablosu: Kayıt Silindi:' 'B' iper-fired+0(6).
*        ENDSELECT.
*        IF recalckd EQ 'X' OR sy-subrc NE 0.
*          PERFORM count_t9y04.
*          INSERT t9y04.
*          PERFORM hatatablosu USING
*         'KIDEM: T9Y04 Tablosu: Kayıt Oluşturuldu' 'B' iper-fired+0(6).
*        ENDIF.
*---t9y04 artık kullanılmıyor
**        perform batch_input using i9005-lgkid iper-kidem iper-pernr
        PERFORM batch_input USING i0776-lgkid iper-kidem iper-pernr
                                  iper-hired iper-fired iper-fired
                                  calc_currency.
        PERFORM hatatablosu USING
        'KIDEM: Kıdem Ücreti Eklendi:' 'B' iper-kidem.
        IF iper-kikek GT 0.
*          perform batch_input using i9005-lgkek iper-kikek iper-pernr
          PERFORM batch_input USING i0776-lgkek iper-kikek iper-pernr
                                    iper-hired iper-fired iper-fired
                                    calc_currency.
          PERFORM hatatablosu USING
          'KIDEM: Ek Ücretler Eklendi:' 'B' iper-kikek.
        ENDIF.
        PERFORM hatatablosu USING
       'KIDEM: Toplu Girdi Oluşuruldu:' 'B' iper-fired+0(6).
      ELSE.
        PERFORM hatatablosu USING
        'KIDEM: Hata Oluştu: Kıdem Tutarı Sıfır.'
        'B' iper-fired+0(6).
      ENDIF.

      IF iper-ihbar NE 0.                                   "gt
*---t9y04 artık kullanılmıyor
*        SELECT * FROM t9y04 WHERE pernr EQ iper-pernr
*                              AND kennz EQ 'I'
*                              AND monat EQ iper-fired+4(2)
*                              AND gjahr EQ iper-fired+0(4).
*          CHECK recalckd EQ 'X'.
*          DELETE t9y04.
*          PERFORM hatatablosu USING
*          'IHBAR: T9Y04 Tablosu: Kayıt Silindi' 'B' iper-fired+0(6).
*        ENDSELECT.
*        PERFORM count_t9y04.
*        t9y04-kennz = 'I'.
*        t9y04-betrg = iper-ihbar.
*        INSERT t9y04.
*        PERFORM hatatablosu USING
*        'IHBAR: T9Y04 Tablosu: Kayıt Oluşturuldu' 'B' iper-fired+0(6).
*---t9y04 artık kullanılmıyor
*        if i9005-fagan eq 1.
*          ihblgart = i9005-lgihb.
*        elseif i9005-fagan eq 2.
*          ihblgart = i9005-lgih1.
*        endif.
        IF i0776-fagan EQ 1.
          ihblgart = i0776-lgihb.
        ELSEIF i0776-fagan EQ 2.
          ihblgart = i0776-lgih1.
        ENDIF.
        IF ihblgart NE space.
          REFRESH bdcdata.
          PERFORM batch_input USING ihblgart iper-ihbar iper-pernr
                                    iper-hired iper-fired iper-fired
                                    calc_currency.
          PERFORM hatatablosu USING
          'IHBAR: İhbar Turarı Eklendi:' 'B' iper-ihbar.
          PERFORM hatatablosu USING
          'IHBAR: Toplu Girdi Oluşturuldu:' 'B' ihblgart.
        ELSE.
          PERFORM hatatablosu USING
          'IHBAR: Hata Oluştu: Ücret Tipi Girilmemiş (BT 9005).'
          'B' iper-fired+0(6).
        ENDIF.
      ELSE.
        PERFORM hatatablosu USING
        'IHBAR: Hata Oluştu: İhbar Tutarı Sıfır.'
        'B' iper-fired+0(6).
      ENDIF.
    ELSE.
      PERFORM hatatablosu USING
      'KIDEM: Hata Oluştu: 9005 Bilgi Tipi Kaydı Bulunamadı.'
      'B' iper-fired+0(6).
      PERFORM hatatablosu USING
      'IHBAR: Hata Oluştu: 9005 Bilgi Tipi Kaydı Bulunamadı.'
      'B' iper-fired+0(6).
    ENDIF.
  ENDLOOP.
ENDFORM.                               " LOOP_FOR_BATCH

*&---------------------------------------------------------------------*
*&      Form  COUNT_T9Y04
*&---------------------------------------------------------------------*
*FORM count_t9y04.
*  t9y04-pernr = iper-pernr.
*  t9y04-monat = iper-fired+4(2).
*  t9y04-gjahr = iper-fired+0(4).
*  t9y04-kennz = 'K'.
*  t9y04-betrg = iper-kidem + iper-kikek.
*  t9y04-waers = calc_currency.
*ENDFORM.                               " COUNT_T9Y04
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
          textline1     = 'Seçilen Pesoneller İçin Bilgi Tipi 0015 de'
          textline2     = 'Kayıt Yaratmak İstediğinize Emin misiniz?'
        IMPORTING
          answer        = p_confrm.

      IF p_confrm EQ 'J' OR p_confrm EQ 'Y'.
        PERFORM batch_open USING 'HR KIDEM'.
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
*&      Form  WRITE_FNAMES
*&---------------------------------------------------------------------*
*FORM WRITE_FNAMES.
*  CLEAR FNAMES. REFRESH FNAMES.
*  FNAMES-TEXT = 'Sicilno'.        APPEND FNAMES.
*  FNAMES-TEXT = 'Adı ve Soyadı'.  APPEND FNAMES.
*  FNAMES-TEXT = 'Hire_date'.      APPEND FNAMES.
*  FNAMES-TEXT = 'fire_Date'.      APPEND FNAMES.
*  FNAMES-TEXT = 'Aylık Ücret'.    APPEND FNAMES.
*  FNAMES-TEXT = 'Aylık Ek gelir'.    APPEND FNAMES.
*  FNAMES-TEXT = 'Aylık Toplam'.      APPEND FNAMES.
*  FNAMES-TEXT = '1 yıl için Kıdem'.  APPEND FNAMES.
*  FNAMES-TEXT = 'Toplam Kidem'.      APPEND FNAMES.
*  FNAMES-TEXT = 'Ek-kıdem miktarı'.  APPEND FNAMES.
*  FNAMES-TEXT = 'Ihbar'.             APPEND FNAMES.
*ENDFORM.                               " WRITE_FNAMES
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
    CALL FUNCTION 'CONVERSION_EXIT_PERI_INPUT'
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
FORM write_footer1 USING gunlktop.
*---< Begin of add by vsuer on 06.11.2007
  DATA: lv_stamp LIKE iper-kidem,
        lv_net   LIKE iper-kidem.

  SELECT SINGLE * FROM t7trg04 WHERE werks EQ iper-werks
  AND   btrtl EQ iper-btrtl.
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM t7trp02 WHERE stgrp EQ t7trg04-grstx AND
                              begda LE pottarih AND
    endda GE pottarih.
  ENDIF.
  CLEAR: lv_net, lv_stamp.
  lv_stamp = iper-kidem * t7trp02-stamp.
  lv_net = iper-kidem - lv_stamp.
*---> End of add by vsuer on 06.11.2007
*---< Begin of add by vsuer on 14.02.2011
  CHECK bykkid IS INITIAL.
*---> End of add by vsuer on 14.02.2011


  WRITE: / sy-vline, 'KIDEM BRÜT : ' INTENSIFIED ON ,
        47 iper-kidem                   CURRENCY calc_currency,
        69 sy-vline,
*---< Begin of add by vsuer on 06.11.2007
         / sy-vline, 'Damga Ver  : ' ,
                      lv_stamp
                                             UNDER iper-topla,
       69 sy-vline,
         / sy-vline, 'Kidem Net  : ' ,
                      lv_net                 CURRENCY calc_currency
                                             UNDER iper-topla,
       69 sy-vline.
*---> End of add by vsuer on 06.11.2007

  IF iper-kikek GT 0.
    WRITE: / sy-vline,    'Ek Ücret: '  ,
                        21 gunlktop     ,
                        47 iper-kikek   CURRENCY calc_currency,
          69 sy-vline.
  ENDIF.
ENDFORM.                               " WRITE_FOOTER1

*&---------------------------------------------------------------------*
*&      Form  WRITE_FOOTER2
*&---------------------------------------------------------------------*
FORM write_footer2.
*data: lv_stamp  like iper-ihbar,
*      lv_net  like iper-ihbar.
*
*  select single * from t7trg04 where werks eq iper-werks
*                               and   btrtl eq iper-btrtl.
*  if sy-subrc eq 0.
*    select single * from t7trp02 where stgrp eq t7trg04-grstx and
*                              begda le pottarih and
*                              endda ge pottarih.
*  endif.
*  clear: lv_net, lv_stamp.
*  lv_stamp = iper-ihbar * t7trp02-stamp.
*  lv_net = iper-ihbar - lv_stamp.

  WRITE: / sy-vline,
       69 sy-vline,
         / sy-vline, 'İHBAR BRÜT : ' INTENSIFIED ON,
                      iper-ihbar             CURRENCY calc_currency
                                             UNDER iper-topla,
       69 sy-vline,
         / sy-vline,
       69 sy-vline.
*         / sy-vline, 'Damga Ver  : ' ,
*                      lv_stamp
*                                             UNDER iper-topla,
*       69 sy-vline,
*         / sy-vline, 'İhbar Net  : ' ,
*                      lv_net                 CURRENCY calc_currency
*                                             UNDER iper-topla,
*       69 sy-vline.
  ULINE AT /(69).
ENDFORM.                               " WRITE_FOOTER2
*&---------------------------------------------------------------------*
*&      Form  GET_LGART_VALUES
*&---------------------------------------------------------------------*
FORM get_lgart_values USING dynp_element.
  DATA: lgart LIKE t512w-lgart.
  DATA: BEGIN OF ihelp_fields OCCURS 20.
          INCLUDE STRUCTURE help_value.
  DATA: END OF ihelp_fields.
  DATA: BEGIN OF helptab OCCURS 100,
          feld(30),
        END OF helptab.

  CLEAR lgart.
  REFRESH ihelp_fields. CLEAR ihelp_fields.
  REFRESH helptab. CLEAR helptab.

  ihelp_fields-tabname    = 'T512W'.
  ihelp_fields-fieldname  = 'LGART'.
  ihelp_fields-selectflag = 'X'.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T512T'.
  ihelp_fields-fieldname  = 'LGTXT'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T512W'.
  ihelp_fields-fieldname  = 'BEGDA'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T512W'.
  ihelp_fields-fieldname  = 'ENDDA'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.

  SELECT * FROM t512w WHERE molga EQ '47'.
    helptab-feld = t512w-lgart.
    APPEND helptab.
    SELECT SINGLE * FROM t512t WHERE molga EQ '47'
                               AND   lgart EQ t512w-lgart
    AND   sprsl EQ sy-langu.
    IF sy-subrc NE 0.
      CLEAR helptab-feld.
    ELSE.
      helptab-feld = t512t-lgtxt.
    ENDIF.
    APPEND helptab.
    WRITE t512w-begda TO helptab-feld  DD/MM/YYYY.
    APPEND helptab.
    WRITE t512w-endda TO helptab-feld  DD/MM/YYYY.
    APPEND helptab.
  ENDSELECT.
  DESCRIBE TABLE helptab LINES sy-tfill.
  CHECK sy-tfill GT 0.
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      fieldname    = 'LGART'
      tabname      = 'T512W'
    IMPORTING
      select_value = lgart
    TABLES
      fields       = ihelp_fields
      valuetab     = helptab.

  CHECK sy-subrc EQ 0 AND lgart NE space.
  dynp_element = lgart.
ENDFORM.                               " GET_LGART_VALUE
*&---------------------------------------------------------------------*
*&      Form  CHECK_TARIH3
*&---------------------------------------------------------------------*
FORM check_tarih3.
  DATA: dat00 LIKE p0041-dat01,
        dar00 LIKE p0041-dar01.
*** 22.2.2001 KA
  CLEAR h_p0041.

*---Add for Upgrade by Vural SÜER on 28.05.2007
  CLEAR h_41dat.
*---Add for Upgrade by Vural SÜER on 28.05.2007

*  CHECK p9907[] IS INITIAL. "Add by VS on 08.01.2014

*** 21.11.2001  Abdullah
  LOOP AT  p0041 WHERE begda LE kidendda AND endda GE kidendda. ENDLOOP.
  CHECK sy-subrc EQ 0.
*** 22.2.2001 KA
  DO  VARYING dat00 FROM p0041-dat01 NEXT p0041-dat02
      VARYING dar00 FROM p0041-dar01 NEXT p0041-dar02.
    IF dar00 NE space.
      IF dar00 = '03'.
** 01.02.2001 H. Cingöz.
*---Giriş tarihi küçüktür kıdeme başlangıç tarihi kontrolü kaldırıldı
        h_41dat = dat00.
        IF dat00 LT hiredate .
          PERFORM tarihfarki USING dat00 hiredate h_p0041.
        ENDIF.
        iper-firsthired = dat00.
**
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

ENDFORM.                               " CHECK_TARIH3
*&---------------------------------------------------------------------*
*&      Form  GET_SUBTY_VALUES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WTY_9UBZ_HIGH  text                                        *
*----------------------------------------------------------------------*
FORM get_subty_values USING    dynp_element.
  DATA: subty LIKE t554s-subty.
  DATA: BEGIN OF ihelp_fields OCCURS 20.
          INCLUDE STRUCTURE help_value.
  DATA: END OF ihelp_fields.
  DATA: BEGIN OF helptab OCCURS 100,
          feld(30),
        END OF helptab.

  CLEAR subty.
  REFRESH ihelp_fields. CLEAR ihelp_fields.
  REFRESH helptab. CLEAR helptab.

  ihelp_fields-tabname    = 'T554S'.
  ihelp_fields-fieldname  = 'SUBTY'.
  ihelp_fields-selectflag = 'X'.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T554T'.
  ihelp_fields-fieldname  = 'ATEXT'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T554S'.
  ihelp_fields-fieldname  = 'BEGDA'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.
  ihelp_fields-tabname    = 'T554S'.
  ihelp_fields-fieldname  = 'ENDDA'.
  ihelp_fields-selectflag = ' '.
  APPEND ihelp_fields.

  SELECT * FROM t554s WHERE moabw EQ '47'.
    helptab-feld = t554s-subty.
    APPEND helptab.
    SELECT SINGLE * FROM t554t WHERE moabw EQ '47'
                               AND   awart EQ t554s-subty
    AND   sprsl EQ sy-langu.
    IF sy-subrc NE 0.
      CLEAR helptab-feld.
    ELSE.
      helptab-feld = t554t-atext.
    ENDIF.
    APPEND helptab.
    WRITE t554s-begda TO helptab-feld  DD/MM/YYYY.
    APPEND helptab.
    WRITE t554s-endda TO helptab-feld  DD/MM/YYYY.
    APPEND helptab.
  ENDSELECT.
  DESCRIBE TABLE helptab LINES sy-tfill.
  CHECK sy-tfill GT 0.
  CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
    EXPORTING
      fieldname    = 'SUBTY'
      tabname      = 'T554S'
    IMPORTING
      select_value = subty
    TABLES
      fields       = ihelp_fields
      valuetab     = helptab.

  CHECK sy-subrc EQ 0 AND subty NE space.
  dynp_element = subty.

ENDFORM.                               " GET_SUBTY_VALUES
*
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
            mmer-kidem CURRENCY calc_currency NO-ZERO NO-GAP, sy-vline.
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
          mmer-kidem CURRENCY calc_currency NO-ZERO UNDER mmer-kidem
                                       NO-GAP, sy-vline.
      ULINE AT /(c_i05).
    ENDAT.
  ENDLOOP.
ENDFORM.                               " MMER_YAZ
*&---------------------------------------------------------------------*
*&      Form  read_rgdir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_rgdir  USING p_pernr p_subrc.

  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      persnr          = p_pernr
    IMPORTING
      molga           = calcmolga
    TABLES
      in_rgdir        = rgdir
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  p_subrc = sy-subrc.
  IF sy-subrc = 1.
*    WRITE: / pernr-pernr,
*             ' nolu personele ilişkin bordro dizini bulunamamıştır.'.
  ENDIF.
ENDFORM.                    " read_rgdir
*&---------------------------------------------------------------------*
*&      Form  read_payroll
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PY_PERIO_FPPER  text
*      -->P_R_SRTZA  text
*      -->P_P_PERNR  text
*      <--P_PY_RESULT  text
*----------------------------------------------------------------------*
FORM read_payroll  USING    p_py_perio_fpper
                            p_p_pernr
                   CHANGING p_py_result TYPE paytr_result.


  DATA : seqnr LIKE pc261-seqnr.

*  LOOP AT rgdir WHERE fpper EQ P_PY_PERIO_FPPER
*                  AND srtza EQ 'A'.
  CLEAR py_result.

  seqnr = rgdir-seqnr.
  CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
    EXPORTING
      employeenumber               = pernr-pernr
      sequencenumber               = seqnr
      check_read_authority         = 'X'
    CHANGING
      payroll_result               = p_py_result
    EXCEPTIONS
      illegal_isocode_or_clusterid = 1
      error_generating_import      = 2
      import_mismatch_error        = 3
      subpool_dir_full             = 4
      no_read_authority            = 5
      no_record_found              = 6
      versions_do_not_match        = 7
      OTHERS                       = 8.

  IF sy-subrc NE 0.
*      WRITE: / pernr-pernr,
*             ' nolu personele ilişkin bordro kayıtları bulunamamıştır.'
    .
  ENDIF.
*  ENDLOOP.

ENDFORM.                    " read_payroll
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
                         AND werks EQ iper-werks    "EMRE BARAN
                         AND btrtl EQ iper-btrtl    "EMRE BARAN
                         AND persk EQ p0001-persk
*                         AND datum GT rgdir-fpend
                         AND datum LT pottarih
    ORDER BY datum ASCENDING.          "EMRE BARAN
    LOOP AT it7trk03.
      IF NOT it7trk03-prznt IS INITIAL.  "Emre Baran
        p_betrg = p_betrg + ( p_betrg * it7trk03-prznt / 100 ).
      ENDIF.
      IF NOT it7trk03-betrg IS INITIAL.
        p_betrg = p_betrg + it7trk03-betrg.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " ikramiye_zam
*&---------------------------------------------------------------------*
*&      Form  CALC_KIDEM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_KIDENDDA  text
*      -->P_KIDENDDA  text
*----------------------------------------------------------------------*
FORM calc_kidem.
  p0001temp[] = p0001[].
* Kullanılan değişkenleri sıfırlar.
  PERFORM clear_was.
* Pernr kaydını iper e kopyalar.
  MOVE-CORRESPONDING pernr TO iper.
  rp_provide_from_last p0002 space kidendda kidendda.
  MOVE p0002-gbdat TO iper-gbdat.      " DOG. TR
  MOVE p0002-gesch TO iper-gesch.      " CINSIYET
* 9005 kıdem bilgi tipi kontrolü
*  perform check_p9005.
* 0776 kıdem bilgi tipi kontrolü
  PERFORM check_p0776.
  CHECK fatalerr EQ space.             "Check Point
* Bordro sonuçları kotrolü
  PERFORM check_payroll.
  CHECK fatalerr EQ space.             "Check Point
* En son organizasyon kaydını kontrol eder.
  PERFORM check_p0001.
  CHECK fatalerr EQ space.             "Check Point
*  IF p9907-werks IS INITIAL.
  iper-werks = p0001-werks.
*  ELSE.
*    iper-werks = p9907-werks.
*  ENDIF.
*  IF p9907-btrtl IS INITIAL.
  iper-btrtl = p0001-btrtl.
*  ELSE.
*    iper-btrtl = p9907-btrtl.
*  ENDIF.
  iper-persk = p0001-persk.
  iper-persg = p0001-persg.
  iper-kostl = p0001-kostl.
*  IF p9907-bukrs IS INITIAL."Add by VS on 08.01.2014
  iper-bukrs = p0001-bukrs.
*  ELSE."Add by VS on 08.01.2014
*    iper-bukrs = p9907-bukrs."Add by VS on 08.01.2014
*  ENDIF."Add by VS on 08.01.2014

*  IF hiredate9907 IS INITIAL.  "Add by VS on 08.01.2014

* İşe başlangıç ve işten çıkış tarihlerini bulur.
  PERFORM hire_fire USING kidbegda kidendda hiredate firedate.
*    IF p9907[] IS INITIAL. "Add by VS on 08.01.2014
  CHECK hiredate LE kidendda."kidbegda.  "IS 10.02.2006 "Serenk 23072012
*    ENDIF. "Add by VS on 08.01.2014
  SORT phifi BY begda DESCENDING.
  LOOP AT phifi WHERE begda LE kidbegda
                  AND ( massn EQ '01' OR massn EQ '12' ) .
    hiredate = phifi-begda.            "HC 08.11.2000 işyeri değiş.
    EXIT.
  ENDLOOP.
  IF hiredate LE kidbegda. "Add by VS on 08.01.2014
    hiredatefirst = hiredate. "Add by VS on 08.01.2014
  ELSE. "Add by VS on 08.01.2014
    hiredate = hiredatefirst = kidbegda. "Add by VS on 08.01.2014
  ENDIF. "Add by VS on 08.01.2014
*    appendrtab = 'X'.
*  ELSE.  "Add by VS on 08.01.2014
*    hiredate = hiredate9907. "Add by VS on 08.01.2014
*    IF firedate LE kidbegda. "Add by VS on 08.01.2014
*      firedate = '99991231'. "Add by VS on 08.01.2014
*    ENDIF. "Add by VS on 08.01.2014
*    CLEAR appendrtab.
*  ENDIF. "Add by VS on 08.01.2014
  iper-firsthired = hiredatefirst.

* Tarih başlangıç değerlerinin kontrolü
  PERFORM check_tarih3.
  PERFORM check_tarih1.
  CHECK fatalerr EQ space.             "Check Point
* Başlangıç tarih değerlerinin iper e atanması
  PERFORM check_tarih2.
  CHECK fatalerr EQ space.             "Check Point
* İşe başlangıç ve içten çıkış tarihleri arasındaki farkı bulur.
*  PERFORM tarihfarki USING iper-hired iper-fired iper-ftime.
* Eski işyerindeki çalışma süresinin kontrolü
  PERFORM count_p0023.
* Grev günlerinin hesaba katılması
*  PERFORM count_t9ypf.  "?
* Çalışan Alt Grubu Part Time'a tabi ise part time sürelerini toplar
  PERFORM count_p0001.
* Grev günlerinin hesaplanıp kıdem süresinden çıkartılması
  PERFORM count_grevg.
  CHECK fatalerr EQ space.             "Check Point
** 01.02.2001 H. Cingöz  P0041 gün farkı h_p0041 ilave ediliyor.
  IF NOT h_p0041 IS INITIAL.
    PERFORM tarihtoplami USING iper-ftime h_p0041.
    PERFORM tarihtoplami USING iper-ktime h_p0041.
*    iper-hired = h_41dat.
    iper-firsthired = h_41dat.
  ENDIF.
**
* Ylıklı mı, saat ücretli mi.
  CLEAR h_abart.
  SELECT SINGLE abart FROM t503 INTO h_abart WHERE persg EQ p0001-persg
  AND persk EQ p0001-persk.

*  IF hiredate9907 IS INITIAL.  "Add by VS on 08.01.2014
*Temel Ödemelerini bulur, bunlar net ise brut karşılıklarını rt den alır
  PERFORM count_ucret.
  CHECK fatalerr EQ space.             "Check Point
* Ek ücretler ve primleri bulur
*  PERFORM count_prims.
*  PERFORM count_t9ykd_betrg_0.
  PERFORM count_t7trk02_betrg_0.
* Çocuk Yardımı
  PERFORM count_cocuk.
*  ENDIF.

  "<<--------BEGIN CODE------>>

* T7TRK02 tablosundaki ücretlerin tutarlarını değiştirebilir
* ve yeni ücret ekleyebilirsiniz.

*break taner.
  DATA: l_badi_06 TYPE REF TO if_ex_hrpaytr_kidem_06.

  DATA : exitlgart LIKE t512w-lgart.
  DATA: lt_rtab TYPE ptr09_tab.
  DATA: ls_rtab TYPE ptr09.
  DATA: exists TYPE sxrt_boolean.
  DATA:  ls_iper TYPE ptr07 .

  REFRESH lt_rtab.


  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    IMPORTING
      act_imp_existing       = exists
    CHANGING
      instance               = l_badi_06.

  IF exists NE space.
* sicile ait ücret tablosunu olustur
    LOOP AT rtab WHERE pernr EQ iper-pernr.
      APPEND rtab TO lt_rtab.
    ENDLOOP.
    MOVE-CORRESPONDING iper TO ls_iper .
    CALL METHOD l_badi_06->change_values
      CHANGING
        iper = ls_iper
        rtab = lt_rtab.
    iper-betrg = ls_iper-betrg.
    iper-ekucr = ls_iper-ekucr.
    iper-topla = ls_iper-topla.
    iper-k1yil = ls_iper-k1yil.
*
    LOOP AT lt_rtab INTO ls_rtab.
* mevcut ücretlerde değişiklik olduysa üzerine yaz
      READ TABLE rtab WITH KEY pernr = ls_rtab-pernr
                               lgart = ls_rtab-lgart.
      IF sy-subrc EQ 0.
        LOOP AT rtab WHERE pernr EQ ls_rtab-pernr
                       AND lgart EQ ls_rtab-lgart.
          rtab = ls_rtab.
          MODIFY rtab.
        ENDLOOP.
      ELSE.
* yeni bir ücret eklendiyse tabloya ekle.
        IF ls_rtab-pernr NE space.
          APPEND ls_rtab TO rtab.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.

  "<<--------END CODE------>>





* Personelin şehrini bulur
  PERFORM count_sehir.
* Hata testi yapar; yoksa personeli iper e ekler.
  PERFORM day_compute_usrexit.
*---Begin of Add by VS on 09.01.2014
  ADD kitonbetrg TO iper-kiton.
*---End of Add by VS on 09.01.2014
  PERFORM append_iper.
  ADD iper-kidem TO kitonbetrg.

*---Begin of Add by VS on 09.01.2014
  p0001[] = p0001temp[].
*---End of Add by VS on 09.01.2014
ENDFORM.                    " CALC_KIDEM
