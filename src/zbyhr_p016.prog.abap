*&---------------------------------------------------------------------*
*& Report  ZBYHR_P016                              Datum: 05.10.1997   *
*& Hire/Fire function is added.                                        *
*&---------------------------------------------------------------------*
* ==================================================================== *
REPORT zbyhr_p016  LINE-SIZE  350 NO STANDARD PAGE HEADING
                           MESSAGE-ID hrpaytr01.


TABLES: pc260, "Cluster Directory for Payroll Results
        t001,
        pcl1 ,                         "HR Cluster 1
        pcl2 ,                         "HR Cluster 2
        pernr, "HR ana verileri raporlaması için standart verile
        t001p,                         "Personel alanları/alt alanları
        t500p,                         "Personel alanları
        t501t,                         "Çalışan grubu tanımları
        t503 ,                         "Çalışan grubu/çalışan alt grubu
        t503t,                         "Çalışan alt grubu tanımları
        t503z,                         "Çalışan grubu tanımları
        t512t,                         "Ücret ve maaş türleri metni
        t512w,                         "Wage Type Valuation
        t500w,                        " YTL Çevrimi için
        t554s, t554t.                  "DEVAMS#ZL#K TÜRLERI
TABLES : zbyhr_t027 .
TABLES : zbyhr_t028 .
DATA  as-funco.
DATA: gt_t588a TYPE TABLE OF t558a.
*        temptarh TYPE endda.
*___Lokalizasyon tabloları/Localisation tables
INCLUDE pcftbtr0.

TABLES : cskt.
INFOTYPES:  0000, 0001, 0002, 0007, 0041,
            0008, 0014, 0015, 0023, 0750,
            2001, 0769, 0770, 0776, 0771.


* Hire/fire includes
* Type-pool of ALV
TYPE-POOLS: slis.

* Selection screen
INCLUDE zbyhr_p016_pak01trs.

* Includes

INCLUDE rpc2cd09.

* INCLUDE rpc2cd00.
INCLUDE rpc2rx19.         " PCL2-Data Cluster RG general
INCLUDE pc2rxtr0.         " PCL2-Data Cl

INCLUDE rpc2rx02.           " PCL2-Data Cluster RG common with Cl. B2
INCLUDE rpppxd00.           "Data definition buffer *PCL1/PCL2
INCLUDE rpppxd10.           "Common part buffer PCL1/PCL2
INCLUDE rpppxm00.           "Buffer handling routine

INCLUDE pafhetry.
INCLUDE pafhetrz.

* Includes (Data Definitions)
INCLUDE pagentrc.         " General data definitions

* Includes (Modules)
* Payroll
INCLUDE zbyhr_pagentrp.         " Payroll includes

* Data element
INCLUDE zbyhr_p016_pak01trd.

* Performs
INCLUDE pak01trp.

DATA : c_i01 TYPE i VALUE 176. "155
DATA : c_i04 TYPE i VALUE 244. "223
DATA : c_i05 TYPE i VALUE 103.
DATA : c_259 TYPE i VALUE 329. "full list
DATA : c_208 TYPE i VALUE 248. "özet list
DATA : c_121 TYPE i VALUE 129. "oldlist
DATA : c_143 TYPE i VALUE 145. "oldlist
DATA : c_140 TYPE i VALUE 140. "toplam başlangıcı


INCLUDE zbyhr_p016_pak02trp.

DATA : exitlgart LIKE t512w-lgart.
DATA: lt_rtab TYPE ptr09_tab.
DATA: ls_rtab TYPE ptr09.
DATA: exists TYPE sxrt_boolean.



AT SELECTION-SCREEN ON pottarih.
  IF potkidem NE space.
    IF pottarih IS INITIAL.
      MESSAGE e040 WITH pottarih.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON norkitar.
  IF norkidem NE space.
    IF norkitar IS INITIAL.
      MESSAGE e040 WITH norkitar.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR norkitar.
  PERFORM f4_popup_for_period.


AT SELECTION-SCREEN ON wty_ubz.
  IF wty_ubz-low EQ space AND wty_ubz-high EQ space.
    MESSAGE i000 WITH 'Devamsızlık türü girmeyi unutmayın ' .
  ENDIF.

*___Initialization________________________________________*

INITIALIZATION.
  IF wty_ubz-low EQ space AND wty_ubz-high EQ space.
    MESSAGE e000 WITH 'Lütfen devamsizlik türü girin !'.
  ENDIF.
  g_repid = sy-repid.
  PERFORM fieldcat_init USING gt_kidem[].


  wty_ubz-sign   = 'I'.
  wty_ubz-option = 'EQ'.
  wty_ubz-low    = '0120'.
  APPEND wty_ubz.
  wty_ubz-low    = '0130'.
  APPEND wty_ubz.
  wty_ubz-low    = '0200'.
  APPEND wty_ubz.
  wty_ubz-low    = '0180'.
  APPEND wty_ubz.

  REFRESH w_kistel.
  w_kistel-sign   = 'I'.
  w_kistel-option = 'EQ'.
  w_kistel-low    = '2000'.
  APPEND w_kistel.

  w_kistel-sign   = 'I'.
  w_kistel-option = 'EQ'.
  w_kistel-low    = '2006'.
  APPEND w_kistel.



*___START-OF-SELECTION______________________________________*
START-OF-SELECTION.

  SELECT * FROM t558a INTO TABLE @gt_t588a WHERE pernr IN @pnppernr.
  exitlgart = '/104'.

  PERFORM set_defaults.

  PERFORM set_first_conditions.

  IF NOT p_sir IS INITIAL.
    selectiontype = 1.
  ENDIF.
  IF potkidem = 'X'.
    kidendda = pottarih.
    PERFORM kidemtarihleri USING kidendda kidbegda.
    kidendda = pottarih.

* "IS - 22.11.2002 - Potansiyel Kıdem Tarihi tikli olunca ve
*  Normal Kıdem Tarihi farklı bir ay olunca, fhdates den dogru tarihi
*  alamıyordu.
    h_begda = kidbegda.
  ELSE.
    kidendda+0(6) = norkitar.
    kidendda+6(2) = '01'.
    PERFORM kidemtarihleri USING kidendda kidbegda.
  ENDIF.

  SELECT waers  INTO ypb FROM t500w
               WHERE land1 = 'TR'
            AND  begda = '20050101' .
  ENDSELECT.

  CALL FUNCTION 'RP_GET_CURRENCY'
    EXPORTING
      molga = '47'
      begda = h_begda
    IMPORTING
      waers = h_curr.

  CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
    EXPORTING
      currency = h_curr
    IMPORTING
      factor   = h_fact.

*  PERFORM kidtar_userexit.

*_User-Exit__________________________________________*
* Personelin şehrini bulur / Find the person's city
  DATA: l_badi_07 TYPE REF TO if_ex_hrpaytr_kidem_07.

  CALL METHOD cl_exithandler=>get_instance
    EXPORTING
      exit_name              = ''             " beklan checkman
      null_instance_accepted = '' " beklan checkman
    CHANGING
      instance               = l_badi_07.

  CALL METHOD l_badi_07->change_values
    IMPORTING
      pottarih = pottarih
    CHANGING
      kidbegda = kidbegda
      kidendda = kidendda.
*_User-Exit__________________________________________*

  PERFORM tables_to_itabs.

*___GET PERNR__________________________________________________*

GET pernr.

  PERFORM calc_kidem .

  IF iper[] IS NOT INITIAL.
    APPEND iper TO ipersum.
  ENDIF.

  CLEAR : iper, ipersum.
*___END-OF-SELECTION_________________________________________________*

END-OF-SELECTION.

  SORT iper ASCENDING BY werks btrtl  .
  SORT rtab BY pernr.
  PERFORM end_of_selection.

TOP-OF-PAGE.
  PERFORM top_of_page.

TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM top_of_page_line.

AT USER-COMMAND.
  PERFORM at_user_command.






  INCLUDE zbyhr_p016_htrbatch.
  INCLUDE zbyhr_p016_alv_chek. " daha geliştirilmedi










*&---------------------------------------------------------------------*
*& Form calc_kidem
*&---------------------------------------------------------------------*
FORM calc_kidem .


* Kullanılan değişkenleri sıfırlar / Initilialise parameters
  PERFORM clear_was.
* Pernr kaydını iper e kopyalar /Copy PERNR to IPER
  MOVE-CORRESPONDING pernr TO iper.

* 0776 kıdem bilgi tipi kontrolü / Control 0776 IT
  PERFORM check_p0776.
  CHECK fatalerr EQ space.             "Check Point

* En son organizasyon kaydın kontrol eder/
* Control last organisation record
  PERFORM check_p0001.
  CHECK fatalerr EQ space.             "Check Point

* Kimlik bilgilerinin okunması
  PERFORM read_p0770.



* Seçim kriterlerinde bukrs alanı seçimi için.


  iper-werks = p0001-werks.
  iper-btrtl = p0001-btrtl.
  iper-bukrs = p0001-bukrs.

  iper-plans = p0001-plans.
  iper-kostl = p0001-kostl.
  iper-abkrs = p0001-abkrs.
  rp_provide_from_last p0002 space kidendda kidendda.
  iper-gbdat = p0002-gbdat.

  IF iper-plans EQ '99999999'.
    DATA: gecici LIKE p0001-begda.
    gecici = p0001-begda - 1.

    PROVIDE * FROM p0001 BETWEEN kidbegda AND gecici
                          WHERE p0001-endda EQ gecici.
    ENDPROVIDE.

    iper-plans = p0001-plans.

  ENDIF.

  SELECT SINGLE * FROM t528t
   WHERE sprsl EQ 'T' AND
         plans EQ iper-plans AND
         endda EQ '99991231'.
  IF sy-subrc EQ 0.
    MOVE t528t-plstx TO iper-plstx.
  ENDIF.

  iper-massg = p0000-massg.
  iper-massn = p0000-massn.

  SELECT SINGLE * FROM t530t
  WHERE sprsl EQ 'T' AND
         massn EQ iper-massn AND
         massg EQ iper-massg.
  IF sy-subrc EQ 0.
    MOVE t530t-mgtxt TO iper-mgtxt.
  ENDIF.


* İşe başlangıç ve içten çıkış tarihlerini bulur.
* Toplu çalıştırmada işten çıkan kişilere de kıdem hesabı

*___Raporun esas çalışması gereken başlangıç ve bitiş tarihleri
*___Find BEGDA and ENDDA for the report
  r_begda = kidbegda.      " Rap. Çalış. Başlangıç Günü
  r_endda = kidendda.      " Rap. Çalış. Bitiş Günü
  r_srtza = 'A'.           " Güncel Ay

*___Bordro verilerinin bulunması/Find payroll data

  PERFORM read_payroll_results.

*___Tarih başlangıç değerlerinin kontrolü / Control BEGDA data
*___0041'den tarihleri kontrol et / Control dates from 0041
  PERFORM check_tarih3.
  CHECK fatalerr EQ space.             "Check Point

*___Çıkış tarihi kontrolü / Control fire date
  PERFORM check_tarih1.
  CHECK fatalerr EQ space.             "Check Point
* Başlangıç tarih değerlerinin iper'e atanması / Transfer BEGDA to IPER
  PERFORM check_tarih2.
  CHECK fatalerr EQ space.             "Check Point

*__İşe başlangıç ve içten çıkış tarihleri arasındaki farkı bulur.
*__Find the date difference between Hire- Fire dates
  PERFORM tarihfarki USING iper-hire iper-fire iper-ftime.


*___Eski işyerindeki çalışma süresinin kontrolü
*___Control of previous working place
  PERFORM count_p0023.

* Grev günlerinin hesaba katılması
* "IS 05.04.2004 grev!!
*  PERFORM count_t9ypf.

*___Çalışan Alt Grubu Part Time'a tabi ise part time sürelerini toplar
*___Calculates part-time days if it is a PART-TIME Employee Subgroup
  PERFORM count_p0001.

*___Grev günlerinin hesaplanıp kıdem süresinden çıkartılması
*___Calculate strike days and subtrack from Senioriyt days
  PERFORM count_grevg.
  CHECK fatalerr EQ space.             "Check Point

*___Personelin aylıklı ya da saat ücretli olduğunun kontrolü /
*___Control of hourly/monthly waged
  CLEAR h_abart.
  SELECT SINGLE abart FROM t503 INTO h_abart WHERE persg EQ p0001-persg
                                  AND persk EQ p0001-persk.

*___Temel Ödemelerini bulur, bunlar net ise brut karşılık. RT'den alır
*___Finds basic salary (if they are netto finds brutto accrual) Gets
*___from RT
  PERFORM count_ucret.
  CHECK fatalerr EQ space.             "Check Point

* Ek ücretler ve primleri bulur / Additional payments and premiums
  PERFORM count_t7trk02_betrg_0.


* Çocuk Yardımı  / Child payment
  PERFORM count_cocuk.

* T7TRK02 tablosundaki ücretlerin tutarlarını değiştirebilir
* ve yeni ücret ekleyebilirsiniz.

*break taner.
  DATA: l_badi_06 TYPE REF TO if_ex_hrpaytr_kidem_06.

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

    DATA : ls_iper TYPE ptr07 .
    MOVE-CORRESPONDING iper TO ls_iper .
    CALL METHOD l_badi_06->change_values
      CHANGING
        iper = ls_iper
        rtab = lt_rtab.

    MOVE-CORRESPONDING ls_iper TO iper .
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

  SELECT SINGLE * FROM t7trg04 WHERE werks EQ it7trg01-werks
  AND   btrtl EQ it7trg01-btrtl.
  IF sy-subrc EQ 0.
    iper-sehir = t7trg04-prcty.
  ENDIF.


*
  ADD kitonbetrg TO iper-kiton.

*     PERFORM day_compute_usrexit.
  PERFORM append_iper.

  ADD iper-kidem TO kitonbetrg.


ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WRITE_POTKIDEMBUKRS
*&---------------------------------------------------------------------*
FORM write_potkidembukrs USING $bukrs
* CHANGING topbetrg  topekucr  toptopla topk1yil topkidem topkiton topihbar
   .

  DATA: btrbetrg LIKE iper-betrg,
        btrekucr LIKE iper-ekucr,
        btrtopla LIKE iper-topla,
        btrk1yil LIKE iper-k1yil,
        btrkidem LIKE iper-kidem,
        btrkiton LIKE iper-kiton,
        btrihbar LIKE iper-ihbar.
*  LOOP AT itemp WHERE secil NE space.
  SORT iper BY bukrs pernr.
  LOOP AT iper WHERE bukrs EQ $bukrs.
    AT NEW bukrs.
      SELECT * FROM t001 INTO t001
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
            AT c_259 sy-vline.
        ULINE AT /1(c_259).
      ELSE.
        WRITE: / sy-vline, iper-bukrs COLOR COL_GROUP,
                           t001-butxt,
*                          iT7TRG01-name1,
             AT c_208 sy-vline.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.
    PERFORM write_potline.
    paa_kisi = paa_kisi + 1.
    pa_kisi = pa_kisi + 1.
    top_kisi = top_kisi + 1.
    AT END OF bukrs.
      SUM.
      IF potkidem = 'X' AND ozet NE 'X'.
        ULINE AT /1(c_259).
        FORMAT COLOR COL_TOTAL.

        PERFORM write_pottoplam USING 'ŞİRKET TOPLAMI :' paa_kisi
          CHANGING
            btrbetrg
            btrekucr
            btrtopla
            btrk1yil
            btrkidem
            btrkiton
            btrihbar.

        CLEAR paa_kisi.
        ULINE AT /1(c_259).
      ELSE.
        ULINE AT /1(c_208).
        FORMAT COLOR COL_TOTAL.
        PERFORM write_pottoplam
                USING 'ŞİRKET TOPLAMI :' paa_kisi
            CHANGING
              btrbetrg
              btrekucr
              btrtopla
              btrk1yil
              btrkidem
              btrkiton
              btrihbar.

        CLEAR paa_kisi.
        ULINE AT /1(c_208).
      ENDIF.
    ENDAT.
*    AT LAST.
*      SUM.
*      IF potkidem = 'X' AND ozet NE 'X'.
*        ULINE AT /1(c_259).
*        FORMAT COLOR COL_GROUP.
*        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi
*            CHANGING
*              btrbetrg
*              btrekucr
*              btrtopla
*              btrk1yil
*              btrkidem
*              btrkiton
*              btrihbar.
*
*        CLEAR top_kisi.
*        ULINE AT /1(c_259).
*      ELSE.
*        ULINE AT /1(c_208).
*        FORMAT COLOR COL_GROUP.
*        PERFORM write_pottoplam USING 'GENEL TOPLAM :' top_kisi
*            CHANGING
*              btrbetrg
*              btrekucr
*              btrtopla
*              btrk1yil
*              btrkidem
*              btrkiton
*              btrihbar.
*
*        CLEAR top_kisi.
*        ULINE AT /1(c_208).
*      ENDIF.
*    ENDAT.


    IF iper-topdahil EQ 1.
      ADD:   iper-betrg TO btrbetrg ,
             iper-ekucr TO btrekucr ,
             iper-topla TO btrtopla ,
             iper-k1yil TO btrk1yil ,
             iper-kidem TO btrkidem ,
             iper-kiton TO btrkiton ,
             iper-ihbar TO btrihbar .
*
*      ADD:   btrbetrg TO topbetrg , btrekucr TO topekucr ,
*             btrtopla TO toptopla , btrk1yil TO topk1yil ,
*             btrkidem TO topkidem , btrihbar TO topihbar,
*             btrkiton TO topkiton.
    ENDIF.
  ENDLOOP.
*  ENDLOOP.
ENDFORM.                               " WRITE_POTKIDEMBUKRS
