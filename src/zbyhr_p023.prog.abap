*&---------------------------------------------------------------------*
*& Report ZBYHR_P023
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p023
               LINE-SIZE 255 LINE-COUNT 63
               NO STANDARD PAGE HEADING MESSAGE-ID yy.
*----------------------------------------------------------------------*
TABLES: hrp1000,
        pernr,  t500p, t001p,
        t001,  t527x,
        cskt ,
        t7tri04,
        t7trg01.                   " Masraf Yeri Metinleri
*----------------------------------------------------------------------*
*  declaration of info types                                           *
*----------------------------------------------------------------------*
INFOTYPES: 0000, 0001, 0002, 0008, 0009, 0022, 0105, 0041,
           0769, 0770, 0771. "9913.
*----------------------------------------------------------------------*
*  declaration of data                                                 *
*----------------------------------------------------------------------*

INCLUDE z_alv_data.

DATA: calcmolga     LIKE t500l-molga VALUE '47',
      calc_currency LIKE t001-waers VALUE 'TRY'.
DATA: save_calc_currency LIKE t001-waers.

DATA: BEGIN OF gt_itab OCCURS 0,
        userid           TYPE p_pernr,
        firstname        TYPE vorna,
        lastname         TYPE nachn,
        employementstart TYPE begda,
        employementend   TYPE endda,
        department       TYPE orgeh,
        departmentname   TYPE stext,
        profession       TYPE stell,
        professionname   TYPE stext,
        position         TYPE plans,
        positionname     TYPE stext,
        manageruserid    TYPE p_pernr, "t527x-orgtx,
        email            TYPE ad_smtpadr,
        company          TYPE bukrs, "t528t-plstx,
        companyname      TYPE butxt,
        empendreason     TYPE massg,
        empendreasontext TYPE mgtxt,
        birthdate        TYPE gbdat,
        sex              TYPE gesch,
        sexname          TYPE stext,
      END OF gt_itab.
DATA : gw_itab        LIKE gt_itab,
*       gw_itab_by_date LIKE gt_itab_by_date,
       gv_objid_plans TYPE hrobjid,
       gv_objid_orgeh TYPE hrobjid,
       gv_objid_stell TYPE hrobjid,
       gt_result1     LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gt_result2     LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gt_result_top  LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gw_result      LIKE swhactor,
       gt_objec       LIKE objec OCCURS 0 WITH HEADER LINE,
       gt_struc       LIKE struc OCCURS 0 WITH HEADER LINE,
*       gt_1000         TYPE TABLE OF p1000,
*       gw_1000         TYPE p1000,
       gt_0000        TYPE TABLE OF p0000,
       gw_0000        TYPE p0000,
       gt_0001        TYPE TABLE OF p0001,
       gw_0001        TYPE p0001,
       gt_0002        TYPE TABLE OF p0002,
       gw_0002        TYPE p0002,
       gt_0008        TYPE TABLE OF p0008,
       gw_0008        TYPE p0008,
       gt_0105        TYPE TABLE OF p0105,
       gw_0105        TYPE p0105,
       gt_0769        TYPE TABLE OF p0769,
       gw_0769        TYPE p0769,
       gt_0770        TYPE TABLE OF p0770,
       gw_0770        TYPE p0770,
       gt_0771        TYPE TABLE OF p0771,
       gw_0771        TYPE p0771.
*DATA : gw_itab         LIKE gt_itab,
*      gv_objid_plans TYPE hrobjid,
*       gw_itab_by_date LIKE gt_itab_by_date.
DATA : BEGIN OF gt_manager OCCURS 0,
         department   TYPE orgeh,
         manager_dept TYPE orgeh,
         dept_name    TYPE otext,
         manager_pos  TYPE plans,
         manager_id   TYPE p_pernr,
       END OF gt_manager.
DATA : gw_manager LIKE gt_manager.

DATA: BEGIN OF int_tab OCCURS 0,
        index          TYPE i,
        bukrs          LIKE p0001-bukrs,
        butxt          LIKE t001-butxt,
        grup(10),
        gircik(1),
        pernr(8),
        ename          LIKE pernr-ename,
        vorna          LIKE p0002-vorna,
        nachn          LIKE p0002-nachn,
        werks          LIKE p0001-werks,
        name1          LIKE t500p-name1,
        btrtl          LIKE p0001-btrtl,
        btext          LIKE t001p-btext,
        persg          LIKE p0001-persg,
        cagrp          LIKE t501t-ptext,
        persk          LIKE p0001-persk,
        caagr          LIKE t503t-ptext,
        abkrs          LIKE p0001-abkrs,
        atext          LIKE t549t-atext,
        kostl          LIKE p0001-kostl,
        ktext	         LIKE cskt-ktext,
        orgeh          LIKE p0001-orgeh,
        otext          LIKE hrp1000-stext,
        pozition       LIKE hrp1000-stext,
        stell          LIKE p0001-stell,
        stext          LIKE hrp1000-stext,
        ansvh          LIKE p0001-ansvh,
        atx            LIKE t542t-atx,
        mstbr          LIKE p0001-mstbr,
        sgmnt          LIKE p0001-sgmnt,
        sgmntt         LIKE fagl_segmt-name,
*        zzpergrp LIKE p0001-zzpergrp,
*        zpergruptx LIKE zzpergr-zpergruptx,
*        zzkonfirm LIKE p0001-zzkonfirm,
*        zzfirmtxt LIKE zzkonfirm-zzfirmtxt,
*        zzkonfirmsgk LIKE p0001-zzkonfirmsgk,
*        zzfirmtxtsgk LIKE zzkonfirmsgk-zzfirmtxt,
*        zzdepartman LIKE p0001-zzdepartman,
*        zzdeptxt LIKE zzdepartman-zzdeptxt,
        zzindalis      LIKE hrp1000-short,
        trfgr          LIKE p0008-trfgr,
        trfst          LIKE p0008-trfst,
        sskno          LIKE p0769-sskno,
        kanun          LIKE p0769-kanun,
*        zzailebireyengel LIKE p0769-zzailebireyengel,
*        zzengellidetayi LIKE p0769-zzengellidetayi,
        merni          LIKE p0770-merni,
        kidembaztarih  LIKE p2001-begda, "Kıdeme Baz Tarih
        yilkizintarih  LIKE p2001-begda, "İzne Baz Tarih
        grupgirtarih   LIKE p2001-begda, "Gruba Giriş Tarih
        giristarih(12),
        cikistarih(12),
        bukrshire      LIKE p0000-begda,
        bukrsfire      LIKE p0000-endda,
        cikisneden     LIKE t530t-mgtxt,
        ucrettutar(15),
        ucret          LIKE t512t-lgtxt,
        ssktur         LIKE t7trs01-sstxt,
        sakatlikderece LIKE t7trt03-dtext,
        bankl          LIKE p0009-bankl,
        bankn          LIKE p0009-bankn,
        iban           LIKE p0009-iban,
        city           LIKE t7trg01-city,
        city_txt       LIKE  dd07v-ddtext,
        gesch          LIKE p0002-gesch,
        gesch_txt      LIKE  dd07v-ddtext,
        gbdat          LIKE  p0002-gbdat,
        manager_id     LIKE pernr-pernr,
        manager_ename  LIKE p0001-ename,
        mudur_id       LIKE pernr-pernr,
        mudur_ename    LIKE p0001-ename,
        direktor_id    LIKE pernr-pernr,
        direktor_ename LIKE p0001-ename,
        gmy_id         LIKE pernr-pernr,
        gmy_ename      LIKE p0001-ename,
        ceptel         LIKE p0105-usrid,
        email          LIKE p0105-usrid_long,
        cttyp          LIKE p0771-cttyp,
        mslks          LIKE p0771-mslks,
*        mermag LIKE p9913-mermag,
*        yonetici LIKE p9913-yonetici,
*        satis LIKE p9913-satis,
*        esnekodeme LIKE p9913-esnekodeme,
*        big LIKE p9913-big,
*        backoffice LIKE p9913-backoffice,
*        frontoffice LIKE p9913-frontoffice,
        9913           LIKE p0001-bukrs,
        foto           LIKE p0001-bukrs,
*        cmkod LIKE zhr_cm_kod-cmkod,
        begdaegt       LIKE p0022-begda,
        enddaegt       LIKE p0022-endda,
        stext1         LIKE t517t-stext,   "Okul türü
        insti1         LIKE p0022-insti,   "Okul adı
        ftext1         LIKE t517x-ftext,   "Bölümü
*        bolgekodu LIKE zhr_magazabolgeb-bolgekodu,
*        bolgeadi  LIKE zhr_magazabolgek-bolgeadi,
*        sbolgeid LIKE zhr_satisbolgeb-sbolgeid,
*        sbolgekodu LIKE zhr_satisbolgek-sbolgekodu,
*        sbolgeadi  LIKE zhr_satisbolgek-sbolgeadi,
        durum          LIKE t519t-stext,
        horizondestek  LIKE t7tri04-stext,
        zzdprt         LIKE p0001-zzdprt,
*        stext2 LIKE t517t-stext,   "Okul türü
*        insti2 LIKE p0022-insti,   "Okul adı
*        ftext2 LIKE t517x-ftext,   "Bölümü
        mark(1),
      END OF int_tab.

DATA : BEGIN OF gt_1000 OCCURS 0,
         otype TYPE otype,
         objid TYPE hrobjid,
         stext TYPE stext,
       END OF gt_1000.

DATA: gt_517t LIKE t517t OCCURS 0 WITH HEADER LINE,
      gt_517x LIKE t517x OCCURS 0 WITH HEADER LINE,
      gt_519t LIKE t519t OCCURS 0 WITH HEADER LINE,
      gt_518b LIKE t518b OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF wtype,
        lgann LIKE p0008-lga01,
        betnn LIKE p0008-bet01,
      END OF wtype.


DATA : manager_pos     TYPE plans,
       manager_id      TYPE persno,
       manager_ename   TYPE emnam,
       gv_datum        TYPE datum,
       pozisyon(40),
       ps_connect_info TYPE toav0,
       ucret_tur(25),
       ucret_tutar     LIKE p0008-bet01,
       sigorta_tur(20),
*       SAKATLIK_DERECE(20),
       hata            TYPE i VALUE 0,
       dbegda          LIKE sy-datum,
       dendda          LIKE sy-datum,
       dmassg          LIKE p0000-massg,
       isdt            LIKE p0000-massn,
       sayfa           TYPE i.

DATA: totalper(5) ,
      w_kisi(5) ,
      grup_kisi(5) .
DATA: endda LIKE prel-endda.

DATA: hiredate      LIKE rptxxxxx-datum1,
      firedate      LIKE rptxxxxx-datum1,
      bukrshiredate LIKE rptxxxxx-datum1,
      bukrsfiredate LIKE rptxxxxx-datum1,
      massg         LIKE p0000-massg,
      massn         LIKE p0000-massn.

DATA: h_hire  LIKE p0001-begda,
      h_fire  LIKE h_hire,
      w_endda LIKE h_hire.

DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.

*** Single Domain Text ****
DATA: l_value  LIKE  dd07v-domvalue_l,
      l_text   LIKE  dd07v-ddtext,
      gv_pernr TYPE persno,
      gv_orgeh TYPE orgeh,
      gv_stell TYPE stell.


DATA: i_variant LIKE disvariant,
      e_variant LIKE disvariant.

DATA : h_variant LIKE disvariant,
       a_save    TYPE c VALUE 'A',
       variant   LIKE disvariant,
       c_variant LIKE disvariant.

CONSTANTS: c_stat_etkin TYPE stat2 VALUE '3'.

SELECTION-SCREEN BEGIN OF BLOCK secim WITH FRAME TITLE TEXT-t03.
  SELECTION-SCREEN BEGIN OF LINE.
    SELECTION-SCREEN POSITION 01.
    PARAMETERS: s_giren RADIOBUTTON GROUP gr2.
    SELECTION-SCREEN COMMENT  3(08) TEXT-s01.
    SELECTION-SCREEN POSITION 12.
    PARAMETERS: s_cikan RADIOBUTTON GROUP gr2.
    SELECTION-SCREEN COMMENT 14(08) TEXT-s02.
    SELECTION-SCREEN POSITION 23.
    PARAMETERS: s_hepsi RADIOBUTTON GROUP gr2.
    SELECTION-SCREEN COMMENT 25(21) TEXT-s03.
    SELECTION-SCREEN POSITION 47.
    PARAMETERS: s_calis RADIOBUTTON GROUP gr2.
    SELECTION-SCREEN COMMENT 49(10) TEXT-s04.
    SELECTION-SCREEN POSITION 60.
    PARAMETERS: s_gircik RADIOBUTTON GROUP gr2.
    SELECTION-SCREEN COMMENT 62(17) TEXT-s05.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK secim.

PARAMETERS c_yb AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN : BEGIN OF BLOCK varyant WITH FRAME.
  PARAMETERS       : p_var LIKE disvariant-variant.
SELECTION-SCREEN : END OF BLOCK varyant .

*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* PROGRAM EVENTS
*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
*---------------------------------------------------------------------*
*        AT SELECTION SCREEN ON VALUE-REQUEST                         *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.
  PERFORM f4_for_variant.

*---------------------------------------------------------------------*
*        AT SELECTION SCREEN                                          *
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM check_variant_existence.

INITIALIZATION.

* HC 03.11.2000 Yetki sorunu  - KA
  pnp_sw_skip_pernr = 'N'.

*----------------------------------------------------------------------
*  start of selection
*----------------------------------------------------------------------
START-OF-SELECTION.
  INCLUDE zhrpainc_secimler.
  PERFORM get_currency USING calcmolga
                        calc_currency
                        save_calc_currency.
  SELECT otype objid stext INTO TABLE gt_1000
                  FROM hrp1000
                 WHERE ( otype EQ 'O'
                     OR  otype EQ 'S'
                     OR  otype EQ 'C' )
                   AND langu EQ sy-langu
                   AND begda LE pn-endda
                   AND endda GE pn-begda.
  SORT gt_1000 BY otype objid.

  SELECT * FROM t517t INTO TABLE gt_517t WHERE sprsl = sy-langu.
  SELECT * FROM t517x INTO TABLE gt_517x WHERE langu = sy-langu.
  SELECT * FROM t519t INTO TABLE gt_519t WHERE sprsl = sy-langu.
  SELECT * FROM t518b INTO TABLE gt_518b WHERE langu = sy-langu.

  rp-set-data-interval p0001 pn-begda pn-endda.   "Authorization VS

GET pernr.

  LOOP AT p0001.
    AUTHORITY-CHECK OBJECT 'P_ORGIN'
*    ID 'ACTVT' FIELD 'R'
    ID 'INFTY' FIELD '0001'
    ID 'PERSA' FIELD p0001-werks.
    IF sy-subrc NE 0.
      DELETE p0001.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE p0001 LINES sy-tfill. "Authorization  solution
  CHECK sy-tfill GT 0.                 "Authorization VS

  CLEAR: h_hire, h_fire,int_tab.
  PERFORM hire_fire USING pn-begda pn-endda
                          h_hire h_fire.
  w_endda = h_fire.
  IF h_hire > pn-endda.
    REJECT.
  ELSEIF h_fire < pn-begda.
    REJECT.
  ENDIF.
*  rp_provide_from_last p0000 space pn-begda pn-endda.
  IF w_endda < pn-endda AND w_endda GE pn-begda.
    rp-provide-from-last p0001 space pn-begda w_endda.
  ELSE.
    rp-provide-from-last p0001 space pn-begda pn-endda.
  ENDIF.

  CHECK p0001 IS NOT INITIAL.
  rp_provide_from_last p0000 space p0001-begda p0001-endda.
  CHECK p0000-stat2 EQ c_stat_etkin.

  rp_provide_from_last p0002 space pn-begda pn-endda.
  rp_provide_from_last p0008 space pn-begda pn-endda.
  rp_provide_from_last p0009 space pn-begda pn-endda.

  CLEAR p0105.
  rp_provide_from_last p0105 '0004' pn-begda pn-endda.
  IF sy-subrc EQ 0.
    LOOP AT p0105 WHERE subty EQ 'CELL'.
      int_tab-ceptel = p0105-usrid.
    ENDLOOP.
  ENDIF.

  CLEAR p0105.
  rp_provide_from_last p0105 '0010' pn-begda pn-endda.
  IF p0105-usrid_long IS INITIAL.
    rp_provide_from_last p0105 '0030' pn-begda pn-endda.
    IF p0105-usrid_long IS NOT INITIAL.
      int_tab-email = p0105-usrid_long.
    ENDIF.
  ELSE.
    int_tab-email = p0105-usrid_long.
  ENDIF.
*  CLEAR p9913.
*  rp_provide_from_last p9913 space pn-begda pn-endda.
  rp_provide_from_last p0769 space pn-begda pn-endda.
  rp_provide_from_last p0770 space pn-begda pn-endda.
  rp_provide_from_last p0771 space pn-begda pn-endda.
  IF ( p0000-massn IN pnpmassn ) AND ( p0000-massg IN pnpmassg ) AND
     ( p0000-stat2 IN pnpstat2 ) AND ( p0001-bukrs IN pnpbukrs ) AND
     ( p0001-werks IN pnpwerks ) AND ( p0001-btrtl IN pnpbtrtl ) AND
     ( p0001-persg IN pnppersg ) AND ( p0001-persk IN pnppersk ) AND
     ( p0001-vdsk1 IN pnpvdsk1 ) AND ( p0001-abkrs IN pnpabkrs ) AND
     ( p0001-ansvh IN pnpansvh ) AND ( p0001-kostl IN pnpkostl ) AND
     ( p0001-orgeh IN pnporgeh ) AND ( p0001-plans IN pnpplans ) AND
     ( p0001-stell IN pnpstell ) AND ( p0001-mstbr IN pnpmstbr ) AND
     ( p0001-otype IN pnpotype ) AND ( p0001-ename IN pnpename ) AND
     ( p0001-sname IN pnpsname ).

    hiredate = ''. firedate = ''.
    CLEAR: bukrshiredate, bukrsfiredate.
    CLEAR: massg, massn.
    int_tab-gircik = 0.

    IF s_giren = 'X'.
      PERFORM girenler_tarih_bul.
      IF hiredate >= pn-begda AND hiredate <= pn-endda .
        hata = 0.
      ELSE.
        hata = 1.
      ENDIF.
    ELSEIF s_cikan = 'X'.
      PERFORM cikanlar_tarih_bul.
      IF firedate >= pn-begda AND firedate <= pn-endda .
        hata = 0.
      ELSE.
        hata = 1.
      ENDIF.
    ELSEIF s_hepsi = 'X'.
      PERFORM hepsi_tarih_bul.
      IF ( firedate = '' OR
         ( firedate GE pn-begda ) ).
        hata = 0.
      ELSE.
        hata = 1.
      ENDIF.
    ELSEIF s_calis = 'X'.
      PERFORM calisan_tarih_bul.
      IF  firedate = '' .
        hata = 0.
      ELSE.
        hata = 1.
      ENDIF.
    ELSEIF s_gircik = 'X'.
      PERFORM giris_cikis_bul.
      IF hiredate >= pn-begda AND hiredate <= pn-endda.
        int_tab-gircik = 1.
        hata = 0.
      ELSEIF firedate >= pn-begda AND firedate <= pn-endda.
        int_tab-gircik = 2.
        hata = 0.
      ELSE.
        hata = 1.
      ENDIF.
    ENDIF.

    IF hata = 0.

      int_tab-bukrs = p0001-bukrs.
      int_tab-orgeh = p0001-orgeh.
*      int_tab-stell = p0001-stell.
      int_tab-stell = p0001-zzlvlk.
      int_tab-werks = p0001-werks.
      int_tab-btrtl = p0001-btrtl.
      int_tab-abkrs = p0001-abkrs.
      int_tab-persg = p0001-persg.
      int_tab-persk = p0001-persk.
      int_tab-mstbr = p0001-mstbr.
      int_tab-ansvh = p0001-ansvh.
      int_tab-sgmnt = p0001-sgmnt.
      int_tab-zzdprt = p0001-zzdprt.
      int_tab-gbdat = p0002-gbdat.
      int_tab-vorna = p0002-vorna.
      int_tab-nachn = p0002-nachn.
*      int_tab-zzdepartman = p0001-zzdepartman.
*      int_tab-zzpergrp = p0001-zzpergrp .
      int_tab-kostl = p0001-kostl.
*      int_tab-zzkonfirm = p0001-zzkonfirm.
*      int_tab-zzkonfirmsgk = p0001-zzkonfirmsgk.

      DELETE p0022 WHERE slabs NE '01'.

      SORT p0022 BY begda DESCENDING.

      READ TABLE p0022 INDEX 1.
      IF sy-subrc EQ 0.
        int_tab-begdaegt = p0022-begda.
        int_tab-enddaegt = p0022-endda.
        READ TABLE gt_517t WITH KEY slart = p0022-slart.
        IF sy-subrc EQ 0.
          int_tab-stext1 = gt_517t-stext.
        ENDIF.
        IF p0022-sltp1 GT 0.
          READ TABLE gt_517x WITH KEY faart = p0022-sltp1.
          IF sy-subrc EQ 0.
            int_tab-ftext1 = gt_517x-ftext.
          ENDIF.
        ENDIF.

        IF p0022-slabs GT 0.
          READ TABLE gt_519t WITH KEY slabs = p0022-slabs.
          IF sy-subrc EQ 0.
            int_tab-durum = gt_519t-stext.
          ENDIF.
        ENDIF.

        IF p0022-ausbi IS NOT INITIAL.
          READ TABLE gt_518b WITH KEY ausbi = p0022-ausbi.
          IF sy-subrc EQ 0.
            int_tab-insti1 = gt_518b-atext.
          ENDIF.

        ELSE.
          int_tab-insti1 = p0022-insti.
        ENDIF.
      ENDIF.

*      CLEAR: int_tab-cmkod.
*      SELECT SINGLE cmkod INTO int_tab-cmkod FROM zhr_cm_kod
*        WHERE werks = int_tab-werks
*        AND   btrtl = int_tab-btrtl.

      CLEAR: int_tab-sgmntt.
      SELECT SINGLE name INTO int_tab-sgmntt FROM fagl_segmt
        WHERE langu EQ sy-langu
        AND   segment = int_tab-sgmnt.

      CLEAR: int_tab-butxt.
      SELECT SINGLE butxt INTO int_tab-butxt FROM t001
        WHERE bukrs = int_tab-bukrs.

      CLEAR: int_tab-cagrp.
      SELECT SINGLE ptext INTO int_tab-cagrp FROM t501t
        WHERE persg = p0001-persg.

      CLEAR: int_tab-caagr.
      SELECT SINGLE ptext INTO int_tab-caagr FROM t503t
        WHERE persk = p0001-persk.

      CLEAR: int_tab-atext.
      SELECT SINGLE atext INTO int_tab-atext FROM t549t
        WHERE abkrs = p0001-abkrs
        AND   sprsl = sy-langu.

*      CLEAR int_tab-zzfirmtxt.
*      SELECT SINGLE zzfirmtxt INTO int_tab-zzfirmtxt FROM zzkonfirm
*                                     WHERE bukrs = p0001-bukrs
*                                     AND  zzkonfirm = p0001-zzkonfirm.

*      CLEAR int_tab-zzfirmtxtsgk.
*      SELECT SINGLE zzfirmtxt INTO int_tab-zzfirmtxtsgk
*                    FROM zzkonfirmsgk
*                         WHERE bukrs        = p0001-bukrs
*                         AND   zzkonfirmsgk = p0001-zzkonfirmsgk.

      CLEAR int_tab-btext.
      SELECT SINGLE btext INTO int_tab-btext FROM t001p
                                     WHERE werks EQ p0001-werks
                                     AND   btrtl EQ p0001-btrtl.
      CLEAR int_tab-name1.
      SELECT SINGLE name1 FROM t500p INTO int_tab-name1
      WHERE persa = p0001-werks
      AND   molga = '47'.

*      SELECT SINGLE zpergruptx FROM zzpergr INTO int_tab-zpergruptx
*                               WHERE bukrs = p0001-bukrs
*                               AND   zpergrup = p0001-zzpergrp .

*      CLEAR int_tab-zzdeptxt.
*      SELECT SINGLE zzdeptxt INTO int_tab-zzdeptxt
*                             FROM zzdepartman
*                             WHERE bukrs = p0001-bukrs
*                             AND  zzdepartman = p0001-zzdepartman.
* İstihdam Koşulu
      CLEAR int_tab-atx.
      SELECT SINGLE atx INTO int_tab-atx
        FROM t542t WHERE ansvh = int_tab-ansvh
                   AND   spras EQ sy-langu
                   AND   molga EQ '47'.


      CLEAR : l_value , l_text .

*      l_value = p0001-zzindalis.
*      CALL FUNCTION 'GET_DOMAENENTEXT'
*        EXPORTING
*          dname           = 'ZZ_INDALIS'
*          dvalue          = l_value
*        IMPORTING
*          dtext           = l_text
*        EXCEPTIONS
*          no_domain_found = 1
*          OTHERS          = 2.
*      int_tab-zzindalis = l_text.

*      CLEAR int_tab-bolgekodu.
*      SELECT SINGLE bolgekodu INTO int_tab-bolgekodu
*                              FROM zhr_magazabolgeb
*                              WHERE werks = p0001-werks
*                              AND   btrtl = p0001-btrtl
*                              AND   begda LE pn-endda
*                              AND   endda GE pn-endda.
*      IF sy-subrc EQ 0.
*        CLEAR int_tab-bolgeadi.
*        SELECT SINGLE bolgeadi INTO int_tab-bolgeadi
*                               FROM zhr_magazabolgek
*                               WHERE bolgekodu = int_tab-bolgekodu.
*      ENDIF.

*---Satış Bölgesi
*      CLEAR int_tab-sbolgeid.
*      SELECT SINGLE sbolgeid INTO int_tab-sbolgeid
*                              FROM zhr_satisbolgeb
*                              WHERE werks = p0001-werks
*                              AND   btrtl = p0001-btrtl.
*                              AND   begda LE pn-endda
*                              AND   endda GE pn-endda.
*      IF sy-subrc EQ 0.
*        CLEAR int_tab-sbolgekodu.
*        CLEAR int_tab-sbolgeadi.
*        SELECT SINGLE "sbolgekodu
*                      sbolgeadi
*          INTO int_tab-sbolgeadi
**          INTO (int_tab-sbolgekodu, int_tab-sbolgeadi)
*                               FROM zhr_satisbolgek
*                               WHERE sbolgeid = int_tab-sbolgeid.
*      ENDIF.

      PERFORM pozisyon_bul.
      PERFORM find_stell_text.
      PERFORM ucret_tur_bul.
      PERFORM sigorta_tur_bul.
      PERFORM sakatlik_bul.

      ADD 1 TO totalper.
      endda = pn-endda.

      ucret_tutar = 0.
      DO 20 TIMES
*---Begin of Add by VS on 02.02.2011
*       VARYING wtype
       VARYING wtype-lgann FROM p0008-lga01 NEXT p0008-lga02
       VARYING wtype-betnn FROM p0008-bet01 NEXT p0008-bet02.
*---End of Add by VS on 02.02.2011
        IF wtype IS INITIAL.
          EXIT.
        ENDIF.
        ADD wtype-betnn TO ucret_tutar .
        CLEAR wtype.
      ENDDO.

      CLEAR int_tab-ktext.
      SELECT SINGLE ktext FROM cskt INTO int_tab-ktext
        WHERE kokrs EQ p0001-kokrs
          AND kostl EQ p0001-kostl
          AND datbi GE endda.

      CLEAR int_tab-otext.
*      SELECT SINGLE stext FROM hrp1000 INTO int_tab-otext
*        WHERE plvar = '01'
*              AND otype = 'O'
*              AND objid = p0001-orgeh
*              AND istat = '1'
*              AND endda GE endda.
      READ TABLE gt_1000 WITH KEY otype = 'O'
                                objid = p0001-orgeh
                             BINARY SEARCH.
      IF sy-subrc EQ 0.
        int_tab-otext = gt_1000-stext.
      ENDIF.

*      IF p9913 IS INITIAL.
*        int_tab-9913 = 'Yok'.
*      ELSE.
*        int_tab-9913 = 'Var'.
*        int_tab-mermag = p9913-mermag.
*        int_tab-yonetici = p9913-yonetici.
*        int_tab-satis = p9913-satis.
*        int_tab-esnekodeme = p9913-esnekodeme.
*        int_tab-big = p9913-big.
*        int_tab-backoffice = p9913-backoffice.
*        int_tab-frontoffice = p9913-frontoffice.
*      ENDIF.

      int_tab-pernr          = pernr-pernr.
      int_tab-ename          = pernr-ename.
      int_tab-mstbr          = p0001-mstbr. "Şef alanı
      int_tab-ansvh          = p0001-ansvh. "Şef alanı
      int_tab-sgmnt          = p0001-sgmnt. "Segment
      int_tab-trfgr          = p0008-trfgr. " Ücret skala grubu
      int_tab-trfst          = p0008-trfst. " Ücret skala düzeyi

      WRITE: p0769-sskno TO int_tab-sskno RIGHT-JUSTIFIED.
*      WRITE: P9004-TTSNO TO INT_TAB-TTSNO RIGHT-JUSTIFIED.
      WRITE: p0770-merni TO int_tab-merni RIGHT-JUSTIFIED.
      int_tab-cttyp     = p0771-cttyp . "
      int_tab-mslks     = p0771-mslks . "
      IF p0771-borgo1 EQ '02' AND
         p0771-borde1 NE space.
        CLEAR t7tri04.
        SELECT SINGLE  * FROM t7tri04 WHERE borgo = p0771-borgo1
                                      AND   borde = p0771-borde1.
        int_tab-horizondestek = t7tri04-stext.
      ELSE.
        CLEAR int_tab-horizondestek.
      ENDIF.

      int_tab-giristarih     = hiredate. "Giris tarihi
      int_tab-cikistarih     = firedate. "Cikis tarihi
      int_tab-bukrshire      = bukrshiredate. "Giris tarihi
      int_tab-bukrsfire      = bukrsfiredate. "Cikis tarihi
*----------- çıkış nedenini bul ------------------*
      CLEAR: int_tab-cikisneden.
      SELECT SINGLE mgtxt FROM t530t INTO int_tab-cikisneden
          WHERE massn = massn
            AND massg = massg
            AND sprsl = sy-langu.
*-------------------------------------------------*
      CLEAR: int_tab-sgmntt.
      SELECT SINGLE name INTO int_tab-sgmntt FROM fagl_segmt
        WHERE langu EQ sy-langu
        AND   segment = int_tab-sgmnt.

*****cinsiyet bilgisi****************************
      int_tab-gesch = p0002-gesch.
      CLEAR : l_value , l_text .

      l_value = int_tab-gesch.
      CALL FUNCTION 'GET_DOMAENENTEXT'
        EXPORTING
          dname           = 'GESCH'
          dvalue          = l_value
        IMPORTING
          dtext           = l_text
        EXCEPTIONS
          no_domain_found = 1
          OTHERS          = 2.
      int_tab-gesch_txt = l_text.
************************************************
      SELECT SINGLE city FROM t7trg01 INTO int_tab-city
                   WHERE werks = p0001-werks
                     AND btrtl =  p0001-btrtl
                     AND endda = '99991231'.
      CLEAR : l_value , l_text .
      l_value = int_tab-city.
      CALL FUNCTION 'GET_DOMAENENTEXT'
        EXPORTING
          dname           = 'PTR_CITY'
          dvalue          = l_value
        IMPORTING
          dtext           = l_text
        EXCEPTIONS
          no_domain_found = 1
          OTHERS          = 2.
      int_tab-city_txt = l_text.

*---------------------------------------------------*
      int_tab-ucret          = ucret_tur.   "Ucret türü
      int_tab-ssktur         = sigorta_tur. "Ssk türü
      int_tab-sakatlikderece = p0769-disab. "Sakatlık derecesi
      int_tab-kanun          = p0769-kanun.
*      int_tab-zzailebireyengel = p0769-zzailebireyengel.
*      int_tab-zzengellidetayi = p0769-zzengellidetayi.
      int_tab-bankl          = p0009-bankl.
      int_tab-bankn          = p0009-bankn.
      int_tab-iban           = p0009-iban.
      int_tab-index          = 1.

      rp_provide_from_last p0041 space pn-begda pn-endda.
      IF p0041 IS NOT INITIAL.
        PERFORM read_tarih_p0041 USING p0041
                                       '03'
                              CHANGING int_tab-kıdembaztarih.
        rp_provide_from_last p0041 space pn-begda pn-endda.
        PERFORM read_tarih_p0041 USING p0041
                                       '01'
                              CHANGING int_tab-yilkizintarih.
        rp_provide_from_last p0041 space pn-begda pn-endda.
        PERFORM read_tarih_p0041 USING p0041
                                       '02'
                              CHANGING int_tab-grupgirtarih.
      ENDIF.

      WRITE hiredate TO int_tab-giristarih MM/DD/YYYY.
      IF firedate NE ''.
        WRITE firedate TO int_tab-cikistarih MM/DD/YYYY.
      ENDIF.
      WRITE ucret_tutar TO int_tab-ucrettutar CURRENCY p0008-waers.

      IF firedate IS INITIAL OR firedate GE sy-datum OR
         firedate EQ space OR firedate EQ '        '.
        gv_datum = sy-datum.
      ELSE.
        gv_datum = firedate.
      ENDIF.

      IF c_yb IS NOT INITIAL.
        PERFORM find_manager USING int_tab-orgeh
                                   int_tab-pernr
                                   gv_datum
                          CHANGING int_tab-manager_id
                                   manager_pos.
        IF int_tab-manager_id IS NOT INITIAL.
          SELECT SINGLE ename INTO int_tab-manager_ename
                 FROM pa0001 WHERE pernr EQ int_tab-manager_id
                             AND   begda LE pn-endda
                             AND   endda GE pn-begda.
        ENDIF.

        gv_pernr = int_tab-pernr.
        gv_orgeh = int_tab-orgeh.
*        CLEAR lv_n.
        CLEAR: int_tab-mudur_id,
               int_tab-mudur_ename,
               int_tab-direktor_id,
               int_tab-direktor_ename,
               int_tab-gmy_id,
               int_tab-gmy_ename.

        DO 5 TIMES.
          CLEAR: manager_id, manager_pos, manager_ename.
          PERFORM find_manager USING gv_orgeh "int_tab-orgeh
                                     gv_pernr
                                     pn-endda
*                                     pn-endda
                            CHANGING manager_id
                                     manager_pos.
          IF manager_id IS NOT INITIAL AND manager_id NE gv_pernr.
            SELECT SINGLE ename orgeh stell
                    INTO (manager_ename, gv_orgeh, gv_stell)
                   FROM pa0001 WHERE pernr EQ manager_id
                               AND   begda LE pn-endda
                               AND   endda GE pn-begda.
            IF gv_stell EQ '50000096'. "Müdür
              int_tab-mudur_id = manager_id.
              int_tab-mudur_ename = manager_ename.
            ELSEIF gv_stell EQ '50000089'. "Mağaza Müdürü
              int_tab-mudur_id = manager_id.
              int_tab-mudur_ename = manager_ename.
              EXIT.
            ELSEIF gv_stell EQ '50000064'.
              int_tab-direktor_id = manager_id.
              int_tab-direktor_ename = manager_ename.
            ELSEIF gv_stell EQ '50000071'.
              int_tab-gmy_id = manager_id.
              int_tab-gmy_ename = manager_ename.
              EXIT.
            ENDIF.
            gv_pernr = manager_id.
          ELSE.
            CLEAR manager_id.
            EXIT.
          ENDIF.
        ENDDO.

      ENDIF.
*---
      CALL FUNCTION 'ZBYHR_FG002_004'
        EXPORTING
          p_pernr        = pernr-pernr
        IMPORTING
          p_connect_info = ps_connect_info.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.

      int_tab-foto = 'YOK'.
      IF ps_connect_info IS NOT INITIAL.
        int_tab-foto = 'VAR'.
      ENDIF.

      APPEND int_tab.
      CLEAR int_tab.
    ENDIF.
  ENDIF.

END-OF-SELECTION.

*  IF ss_sicil = 'X'.
  SORT int_tab BY bukrs grup gircik pernr ASCENDING.
*  ELSE.
*    SORT int_tab BY bukrs grup gircik ename AS TEXT ASCENDING.
*  ENDIF.

  PERFORM display.

*----------------------------------------------------------------------
* İşe Girenler İçin Giriş-Çıkış Tarihleri bulunuyor...
*----------------------------------------------------------------------
FORM girenler_tarih_bul.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr = p0000-pernr
        AND ( massn = '01' OR massn = '12' )
        AND begda GE pn-begda
      ORDER BY begda ASCENDING.
    IF dbegda >= pn-begda AND dbegda <= pn-endda.
      hiredate = dbegda.
    ENDIF.
  ENDSELECT.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr  =  p0000-pernr
        AND massn  =  '10' AND
        begda >=  hiredate
      ORDER BY begda ASCENDING.
    dbegda = dbegda - 1 .
    IF dbegda >= pn-begda AND dbegda <= pn-endda.
      firedate = dbegda.
      massg = dmassg.
      massn = isdt.
    ENDIF.
  ENDSELECT.

*---Begin of Grup İçi Transfer
  PERFORM grup_ici_transfer.

ENDFORM.                    "GIRENLER_TARIH_BUL
*----------------------------------------------------------------------
* İşten Çıkanlar İçin Giriş-Çıkış Tarihleri bulunuyor...
*----------------------------------------------------------------------
FORM cikanlar_tarih_bul.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr = p0000-pernr
        AND massn = '10'
        AND begda GE pn-begda
      ORDER BY begda ASCENDING.
    dbegda = dbegda - 1 .
    IF dbegda >= pn-begda AND dbegda <= pn-endda AND dbegda <= w_endda.
      firedate = dbegda .
      massg = dmassg.
      massn = isdt.
    ENDIF.
  ENDSELECT.
  IF firedate <> ''.
    SELECT  begda endda massn FROM  pa0000
            INTO  (dbegda, dendda, isdt)
        WHERE pernr  =  p0000-pernr
          AND ( massn = '01' OR massn = '12' )
          AND begda <=  firedate
        ORDER BY begda ASCENDING.
      hiredate = dbegda .
    ENDSELECT.
  ENDIF.

*---Begin of Grup İçi Transfer
  PERFORM grup_ici_transfer.

ENDFORM.                    "CIKANLAR_TARIH_BUL
*----------------------------------------------------------------------
* Çalışanlar İçin Giriş-Çıkış Tarihleri bulunuyor...
*----------------------------------------------------------------------
FORM calisan_tarih_bul.
  SELECT  begda endda massn FROM  pa0000
          INTO  (dbegda, dendda, isdt)
      WHERE pernr = p0000-pernr
        AND ( massn = '01' OR massn = '12' )
        AND begda LE pn-endda
      ORDER BY begda ASCENDING.
    hiredate = dbegda.
  ENDSELECT.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr  =  p0000-pernr
        AND massn  =  '10'
*       and ( begda ge hiredate and begda le pn-endda )
      ORDER BY begda ASCENDING.
    dbegda = dbegda - 1 .
*    IF dbegda GE hiredate AND dbegda LE pn-endda. "VS 23.02.2017
    IF dbegda GE hiredate AND dbegda LT pn-endda. "VS 23.02.2017
      IF dbegda LE pn-endda.
        firedate = dbegda.
        massg = dmassg.
        massn = isdt.
      ENDIF.
    ENDIF.
  ENDSELECT.

*---Begin of Grup İçi Transfer
  PERFORM grup_ici_transfer.

*---Begin of Performans İçin Commentlendi
*  SORT p0000 BY pernr begda.
*  LOOP AT p0000
*      WHERE pernr = p0000-pernr
*        AND ( massn = '01' OR massn = '12' )
*        AND begda LE pn-endda.
*    dbegda = p0000-begda.
*    dendda = p0000-endda.
*    isdt = p0000-massn.
*    hiredate = dbegda.
*  ENDLOOP.
*
*  LOOP AT p0000
*      WHERE pernr  =  p0000-pernr
*        AND massn  =  '10'.
*    dbegda = p0000-begda.
*    dendda = p0000-endda.
*    isdt = p0000-massn.
*    dmassg = p0000-massg.
*    hiredate = dbegda.
*
*    dbegda = dbegda - 1 .
*    IF dbegda GE hiredate AND dbegda LT pn-endda. "VS 23.02.2017
*      IF dbegda LE pn-endda.
*        firedate = dbegda.
*        massg = dmassg.
*        massn = isdt.
*      ENDIF.
*    ENDIF.
*
*  ENDLOOP.
*---End of Performans İçin Commentlendi
ENDFORM.                    "CALISAN_TARIH_BUL
*----------------------------------------------------------------------*
* Hepsi İçin Giriş - Çıkış Tarihleri bulunuyor...
*----------------------------------------------------------------------*
FORM hepsi_tarih_bul.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr = p0000-pernr
        AND ( massn = '10' OR massn = '01' OR massn = '12' )
      ORDER BY begda ASCENDING.
    IF isdt = '10'.
      dbegda = dbegda - 1 .
    ENDIF.
    IF dbegda LE pn-endda.
      IF isdt = '10'.
        firedate = dbegda .
        massg = dmassg.
        massn = isdt.
      ELSE.
        firedate = ''.
        CLEAR massg.
      ENDIF.
    ENDIF.
  ENDSELECT.
  IF firedate <> ''.
    SELECT  begda endda massn FROM  pa0000
            INTO  (dbegda, dendda, isdt)
        WHERE pernr  =  p0000-pernr
          AND ( massn = '01' OR massn = '12' )
          AND begda LE firedate
        ORDER BY begda ASCENDING.
      hiredate = dbegda .
    ENDSELECT.
  ELSE.
    SELECT  begda endda massn FROM  pa0000
            INTO  (dbegda, dendda, isdt)
        WHERE pernr  =  p0000-pernr
          AND ( massn = '01' OR massn = '12' )
          AND begda LE pn-endda
        ORDER BY begda ASCENDING.
      hiredate = dbegda .
    ENDSELECT.
  ENDIF.

*---Begin of Grup İçi Transfer
  PERFORM grup_ici_transfer.

ENDFORM.                    "HEPSI_TARIH_BUL
*----------------------------------------------------------------------*
* Giriş - Çıkış Tarihleri bulunuyor...
*----------------------------------------------------------------------*
FORM giris_cikis_bul.
  SELECT  begda endda massn massg FROM  pa0000
          INTO  (dbegda, dendda, isdt, dmassg)
      WHERE pernr = p0000-pernr
      ORDER BY begda ASCENDING.
    IF isdt = '10'.
      dbegda = dbegda - 1 .
    ENDIF.
    IF dbegda LE pn-endda.
      IF isdt = '01' OR isdt = '12'.
        IF dbegda >= pn-begda AND dbegda <= pn-endda.
          hiredate = dbegda.
*---Begin of Add by VS on 14.02.2011 Upgarde
*          firedate = ''.
          IF NOT ( firedate >= pn-begda AND firedate <= pn-endda ).
            firedate = ''. CLEAR: massg, massn.
          ENDIF.
*---End of Add by VS on 14.02.2011 Upgarde
        ENDIF.
      ELSEIF isdt = '10'.
        IF dbegda >= pn-begda AND dbegda <= pn-endda .
          firedate = dbegda.
          massg = dmassg.
          massn = isdt.
          SELECT  begda endda massn FROM  pa0000
                  INTO  (dbegda, dendda, isdt)
              WHERE pernr  =  p0000-pernr
                AND ( massn  =  '01' OR massn  =  '12' )
                AND begda <=  firedate
              ORDER BY begda ASCENDING.
            hiredate = dbegda .
          ENDSELECT.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDSELECT.

*---Begin of Grup İçi Transfer
  PERFORM grup_ici_transfer.

ENDFORM.                    "GIRIS_CIKIS_BUL
*----------------------------------------------------------------------*
* Ekrana Görüntüleniyor...
*----------------------------------------------------------------------*
FORM display.
*---
  w_kisi = 0. grup_kisi = 0.
*---
  PERFORM alv_initial USING '' 'INT_TAB'.
  PERFORM modify_fieldcat.
*  perform display_alv using 'X'.

ENDFORM.                    "DISPLAY
*----------------------------------------------------------------------*
* Pozisyon Bulunuyor
*----------------------------------------------------------------------*
FORM pozisyon_bul.
  CHECK p0001-plans NE '99999999'.
  MOVE p0001-plans TO int_tab-pozition .
  READ TABLE gt_1000 WITH KEY otype = 'S'
                            objid = int_tab-pozition
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
    int_tab-pozition = gt_1000-stext.
  ENDIF.

*  SELECT SINGLE stext INTO int_tab-pozition
*         FROM hrp1000 WHERE plvar = '01'
*                      AND   otype = 'S'
*                      AND   objid = p0001-plans
*                      AND   begda LE pn-endda
*                      AND   endda GE pn-begda.
ENDFORM.                    "POZISYON_BUL
*----------------------------------------------------------------------*
* Ücret Türü Bulunuyor
*----------------------------------------------------------------------*
FORM ucret_tur_bul.
  ucret_tur = ''.
  ucret_tur = p0008-waers.
  IF p0008-lga01+1(1) = '3'.
    CONCATENATE ucret_tur '-' 'NET' INTO ucret_tur.
  ELSEIF p0008-waers = ''.
    ucret_tur = ''.
  ELSE.
    CONCATENATE ucret_tur '-' 'BRÜT' INTO ucret_tur.
  ENDIF.

ENDFORM.                    "UCRET_TUR_BUL

*----------------------------------------------------------------------*
* Sigorta Türü Bulunuyor
*----------------------------------------------------------------------*
FORM sigorta_tur_bul.
  sigorta_tur = ''.
  SELECT SINGLE sstxt INTO sigorta_tur
   FROM   t7trs01
   WHERE   ssgrp = p0769-ssgrp.
*  ENDSELECT.

ENDFORM.                    "SIGORTA_TUR_BUL

*----------------------------------------------------------------------*
* Sakatlık derecesi bulunuyor.
*----------------------------------------------------------------------*
FORM sakatlik_bul.
*  SAKATLIK_DERECE = ''.
*  SELECT DTEXT
*  FROM   T7TRT03
*  INTO   SAKATLIK_DERECE
*  WHERE   DISAB = P0769-DISAB.
*  ENDSELECT.
ENDFORM.                    "SAKATLIK_BUL
*----------------------------------------------------------------------*
*      TOP OF PAGE                                                     *
*----------------------------------------------------------------------*
TOP-OF-PAGE.
*  IF sayfa = 0.
*    ULINE (82).
*    WRITE: 5 'Parametre seçimleri'.
*    WRITE: / sy-vline NO-GAP, sirket LEFT-JUSTIFIED NO-GAP,
*             donem LEFT-JUSTIFIED NO-GAP, sy-vline.
*    WRITE: / sy-vline NO-GAP, personel LEFT-JUSTIFIED NO-GAP,
*             persalani LEFT-JUSTIFIED NO-GAP, sy-vline.
*    WRITE: / sy-vline NO-GAP, calgrubu LEFT-JUSTIFIED NO-GAP,
*             paltalani LEFT-JUSTIFIED NO-GAP, sy-vline.
*    WRITE: / sy-vline NO-GAP, calaltgrb LEFT-JUSTIFIED NO-GAP,
*             bdraltbirimi LEFT-JUSTIFIED NO-GAP, sy-vline.
*    WRITE: / sy-vline NO-GAP, organizasyon LEFT-JUSTIFIED NO-GAP,
*             ustalan LEFT-JUSTIFIED NO-GAP, sy-vline.
*    WRITE:/ sy-vline NO-GAP, (80) sy-uline NO-GAP, sy-vline NO-GAP.
*    WRITE:/.
*  ENDIF.
*  WRITE: 20 t001-butxt.
*  WRITE: 50 'PERSONEL GİRİŞ ÇIKIŞ LİSTESİ'(top)
*                                   COLOR COL_HEADING INVERSE.
*  sayfa = sayfa + 1.
*  DATA: lv_page(12),
*        lv_txt(4).
*  lv_txt = sayfa.
*  CONCATENATE 'Sayfa : ' lv_txt INTO lv_page.
*  WRITE:  243 lv_page RIGHT-JUSTIFIED.
*  WRITE : /20 'Raporlama Dönemi :', pn-begda , '-' , pn-endda .
*  IF s_giren = 'X'.
*    WRITE: ' -İşe Girişler-'.
*  ELSEIF s_cikan = 'X'.
*    WRITE: ' -İşten Çıkanlar-'.
*  ELSEIF s_hepsi = 'X'.
*    WRITE: ' -Çalışanlar ve Ayrılanlar-'.
*  ELSEIF s_calis = 'X'.
*    WRITE: ' -Çalışanlar-'.
*  ELSEIF s_gircik = 'X'.
*    WRITE: ' -Giren ve Çıkanlar-'.
*  ENDIF.
*
*  ULINE.
*  WRITE: /(08) 'Sicil No'     CENTERED,
*          (30) 'Adı Soyadı'   LEFT-JUSTIFIED,
*          (18) 'Personel Alt Alanı'       LEFT-JUSTIFIED,
*          (08) 'Şef Alan'     LEFT-JUSTIFIED,
*          (08) 'Skala'        LEFT-JUSTIFIED,
*          (34) 'Pozisyon'     LEFT-JUSTIFIED,
*          (15) 'İş      '     LEFT-JUSTIFIED,
**          (18) 'SSK Sicil No' RIGHT-JUSTIFIED,
*          (12) 'TC.Kimlik No' RIGHT-JUSTIFIED,
*          (10) 'Gir.Tar.'     CENTERED,
*          (10) 'Çık.Tar.'     CENTERED,
*          (32) 'Çık.Ned.'   ,
*          (17) 'Ücret  '      RIGHT-JUSTIFIED,
*          (8) 'Ücr. Tip'      LEFT-JUSTIFIED,
*          (7) 'SSK Tür'       LEFT-JUSTIFIED,
*          (3) 'Skt'           LEFT-JUSTIFIED,
*          (9) 'Bnk. Şube'     LEFT-JUSTIFIED,
*          (10) 'Hesap No'     LEFT-JUSTIFIED.
*
*  ULINE.
*&---------------------------------------------------------------------*
*&      Form  SIRKET
*&---------------------------------------------------------------------*
FORM sirket.
  SELECT * FROM t001
      WHERE bukrs = int_tab-bukrs.
  ENDSELECT.
ENDFORM.                               " SIRKET

*INCLUDE YPCWAERS.   "AE  PARAMAETRE SAYISI DEGISTIGINDEN CALISMIYORDU
INCLUDE zpcwaers.
*&---------------------------------------------------------------------*
*&      Form  HIRE_FIRE
*&---------------------------------------------------------------------*
FORM hire_fire USING begda endda
                     h_date f_date.
  CALL FUNCTION 'RP_HIRE_FIRE'
    EXPORTING
      beg       = begda
      end       = endda
    IMPORTING
      hire_date = h_date
      fire_date = f_date
    TABLES
      pp0000    = p0000                               "in
      pp0001    = p0001                               "in
      pphifi    = phifi.                              "out
ENDFORM.                               " HIRE_FIRE
*&---------------------------------------------------------------------*
*&      Form  WRITE_TOP_OF_GROUP
*&---------------------------------------------------------------------*
FORM write_top_of_group.
*  FORMAT RESET.
*  WRITE :/.
*  IF s_orgbrm = 'X'.
*    SELECT SINGLE * FROM t527x
*      WHERE orgeh = int_tab-grup
*        AND sprsl = 'T'.
*    IF sy-subrc NE 0.
*      t527x-orgtx = 'Bulunamadı'.
*    ENDIF.
*    WRITE : 11 int_tab-grup COLOR COL_TOTAL,
*               t527x-orgtx COLOR COL_TOTAL.
*  ELSEIF s_paltal = 'X'.
*    SELECT SINGLE * FROM t500p
*      WHERE persa = int_tab-grup+0(4)
*      AND   molga = '47'.
*    IF sy-subrc NE 0.
*      t500p-name1 = 'Bulunamadı'.
*    ENDIF.
*    SELECT SINGLE * FROM t001p
*      WHERE werks = int_tab-grup+0(4)
*      AND   btrtl = int_tab-grup+4(4)
*      AND   molga = '47'.
*    IF sy-subrc NE 0.
*      t001p-btext = 'Bulunamadı'.
*    ENDIF.
*    WRITE : 11 int_tab-grup COLOR COL_TOTAL,
*               t500p-name1 COLOR COL_TOTAL,
*               t001p-btext COLOR COL_TOTAL.
*  ELSEIF s_sefaln = 'X'.
*    WRITE AT 11 int_tab-grup COLOR COL_TOTAL.
*  ELSEIF s_masyer = 'X'.
*    SELECT SINGLE * FROM cskt WHERE kokrs EQ int_tab-bukrs
*                              AND   kostl EQ int_tab-grup
*                              AND   datbi GE endda.
*    IF sy-subrc NE 0.
*      cskt-ktext = 'Bulunamadı'.
*    ENDIF.
*    WRITE : 11 int_tab-grup COLOR COL_TOTAL,
*               cskt-ktext COLOR COL_TOTAL.
*  ENDIF.
*  ULINE.

ENDFORM.                               " WRITE_TOP_OF_GROUP
*&---------------------------------------------------------------------*
*&      Form  FIND_STELL_TEXT
*&---------------------------------------------------------------------*
FORM find_stell_text.
  CHECK p0001-stell NE '00000000'.
  int_tab-stell = p0001-zzlvlk.
  int_tab-stext = p0001-zzlvl.

*  READ TABLE gt_1000 WITH KEY otype = 'C'
*                            objid = int_tab-stell
*                         BINARY SEARCH.
*  IF sy-subrc EQ 0.
*    int_tab-stext = gt_1000-stext.
*  ENDIF.

ENDFORM.                    " FIND_STELL_TEXT
*&---------------------------------------------------------------------*
*&      Form  ALV_INITIAL
*&---------------------------------------------------------------------*
FORM alv_initial USING header tablename.
  DATA: lv_text(20).

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-box_fieldname = 'MARK'.

* create_fieldcatalog
  CLEAR gt_fieldcat[].
  ASSIGN gt_fieldcat[] TO <fcat>.
  PERFORM create_fieldcatalog USING   tablename.
  CLEAR lv_text.
  CONCATENATE tablename '[]' INTO lv_text.

  ASSIGN (lv_text) TO <fout>.
ENDFORM.                    "alv_initial
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCAT
*&---------------------------------------------------------------------*
FORM modify_fieldcat .

  PERFORM modify_fieldcatalog_text USING:
    'index'         'Sıra'                  'Sıra',
    'pernr'         'Sicil No'              'Sicil No',
    'ename'         'Adı Soyadı'            'Adı Soyadı',
    'bukrs'         'Şirket Kodu ID'        'Şirket Kodu ID',
    'butxt'         'Şirket'                'Şirket',
    'werks'         'Personel Alanı ID'     'Personel Alanı ID',
    'name1'         'Personel Alanı'        'Personel Alanı',
    'btrtl'         'Personel Alt Alanı ID' 'Personel Alt Alanı ID',
    'btext'         'Personel Alt Alanı'    'Personel Alt Alanı',
    'kostl'         'Masraf Yeri ID'        'Masraf Yeri',
    'ktext'         'Masraf Yeri'           'Masraf Yeri',
    'mstbr'         'Şef Alan'              'Şef Alan',
    'ansvh'         'İstihdam Koşulu'       'İstihdam Koşulu',
    'sgmnt'         'Segment'               'Segment',
    'sgmntt'        'Segment Adı'           'Segment Adı',
    'zzpergrp'      'Personel Sınıfı ID'    'Personel Sınıfı ID',
    'zpergruptx'    'Personel Sınıfı'       'Personel Sınıfı',
    'ZZINDALIS'     'İlet-Sakla İzni'        'İletişim-Saklama İzni',
    'trfgr'         'Skala'                 'Skala',
    'orgeh'         'Organizasyon ID'       'Organizasyon',
    'otext'         'Organizasyon'          'Organizasyon',
    'pozition'      'Pozisyon'              'Pozisyon',
    'stell'         'İş Kod'                'İş Kod',
    'stext'         'İş'                    'İş',
    'sskno'         'SSK Sicil No'          'SSK Sicil No',
    'merni'         'TC.Kimlik No'          'TC.Kimlik No',
    'giristarih'    'Gir.Tar.'              'Gir.Tar.',
    'cikistarih'    'Çık.Tar.'              'Çık.Tar.',
    'cikisneden'    'Çık.Ned.'              'Çık.Ned.',
    'bukrshire'     'Grp.Trn.Gir.Tar.'      'Şir.Trn.Gir.Tar.',
    'bukrsfire'     'Şir.Trn.Çık.Tar.'      'Şir.Trn.Çık.Tar.',
    'ucrettutar'    'Ücret  '               'Ücret  ',
    'ucret'         'Ücr. Tip'              'Ücr. Tip',
    'ssktur'        'SSK Tür'               'SSK Tür',
    'sakatlikderece' 'Skt'                  'Skt',
    'bankl'          'Bnk. Şube'            'Bnk. Şube',
    'bankn'          'Hesap No'             'Hesap No',
    'iban'           'IBAN'                 'IBAN',
    'email'          'E-Mail'               'E-Mail',
    'ceptel'         'Cep Telefonu'         'Cep Telefonu',
    'city_txt'       'İl'                   'İl',
    'MANAGER_ID'     'Yönetici Sicil'       'Yönetici Sicil',
    'MANAGER_ENAME'  'Yönetici Adı'         'Yönetici Adı',
    'mermag'         'Merkez/Mağaza'        'Merkez/Mağaza',
    'yonetici'       'Yönetici'             'Yönetici',
    'satis'          'Satış'                'Satış',
    'esnekodeme'     'Esnek Ödeme'          'Esnek Ödeme',
    'big'            'Big'                  'Big',
    'backoffice'     'BackOfis'             'BackOfis',
    'frontoffice'    'FrontOfis'            'FrontOfis',
    'kidembaztarih'  'KıdemeBazTarih'       'Kıdeme Baz Tarih',
    'yilkizintarih'  'İzneBazTarih'         'İzne Baz Tarih',
    'grupgirtarih'   'GrubaGirişTarih'      'Gruba Giriş Tarih',
    '9913'           '9913'                 '9913',
    'FOTO'           'Fotoğraf'             'Fotoğraf',
    'begdaegt'       'Egt.Başlama'          'Egt.Başlama',
    'enddaegt'       'Egt.Bitiş'            'Egt.Bitiş',
    'stext1'         'Okul türü'            'Okul türü',
    'insti1'         'Okul adı'             'Okul adı',
    'ftext1'         'Bölümü'               'Bölümü',
    'durum'          'Durum'                'Durum',
    'horizondestek'  'Horizon Destek'       'Horizon Destek',
    'mudur_id'       'YönMdSicil'           'YönMdSicil',
    'mudur_ename'    'YönMdİsim'            'YönMdİsim',
    'direktor_id'    'YönDirSicil'          'YönDirSicil',
    'direktor_ename' 'YönDirİsim'           'YönDirİsim',
    'gmy_id'         'YönGMYSicil'          'YönGMYSicil',
    'gmy_ename'      'YönGMYİsim'           'YönGMYİsim',
*    'stext2'         'Okul türü'            'Okul türü',
*    'insti2'         'Okul adı'             'Okul adı',
*    'ftext2'         'Bölümü'               'Bölümü',
    'BOLGEKODU'      'Bölge Kodu'           'Bölge Kodu',
    'SBOLGEID'       'Satış Bölge Kodu'     'Satış Bölge Kodu',
    'gesch_txt'      'Cinsiyet'             'Cinsiyet'.


  PERFORM modify_fieldcatalog USING :
   'bukrs'    'NO_OUT' 'X',
   'butxt'    'NO_OUT' 'X',
   'cagrp'    'NO_OUT' 'X',
   'caagr'    'NO_OUT' 'X',
   'abkrs'    'NO_OUT' 'X',
   'kostl'    'NO_OUT' 'X',
   'werks'    'NO_OUT' 'X',
   'name1'    'NO_OUT' 'X',
   'btrtl'    'NO_OUT' 'X',
   'city'     'NO_OUT' 'X',
   'orgeh'    'NO_OUT' 'X',
   'stell'    'NO_OUT' 'X',
   'gesch'    'NO_OUT' 'X',
   'grup'     'NO_OUT' 'X',
   'gircik'   'NO_OUT' 'X',
   'bukrs'    'NO_OUT' 'X',
   'bukrshire' 'NO_OUT' 'X',
   'bukrsfire' 'NO_OUT' 'X',
   'persg'    'NO_OUT' 'X',
   'persk'    'NO_OUT' 'X',
   'atext'    'NO_OUT' 'X',
   'mark'     'NO_OUT' 'X',
   'kanun'    'NO_OUT' 'X',
   'ZZAILEBIREYENGEL' 'NO_OUT' 'X',
   'ZZENGELLIDETAYI' 'NO_OUT' 'X',
   'ansvh'    'NO_OUT' 'X',
   'atx'      'NO_OUT' 'X',
   'zzpergrp' 'NO_OUT' 'X',
   'sgmnt'    'NO_OUT' 'X',
   'sgmntt'   'NO_OUT' 'X',
   'kidembaztarih'   'NO_OUT' 'X',
   'yilkizintarih'   'NO_OUT' 'X',
   'grupgirtarih'    'NO_OUT' 'X',
   'ZZKONFIRM' 'NO_OUT' 'X',
   'zzfirmtxt' 'NO_OUT' 'X',
   'ZZKONFIRMSGK' 'NO_OUT' 'X',
   'zzfirmtxtSGK' 'NO_OUT' 'X',
   'ZZDEPARTMAN' 'NO_OUT' 'X',
   'ZZDEPTXT'  'NO_OUT' 'X',
   'ZZINDALIS' 'NO_OUT' 'X',
   'MANAGER_ID' 'NO_OUT' 'X',
   'MANAGER_ENAME' 'NO_OUT' 'X',
   'CTTYP'       'NO_OUT' 'X',
   'MSLKS'       'NO_OUT' 'X',
   'VORNA'       'NO_OUT' 'X',
   'NACHN'       'NO_OUT' 'X',
   'mermag'      'NO_OUT' 'X',
   'yonetici'    'NO_OUT' 'X',
   'satis'       'NO_OUT' 'X',
   'esnekodeme'  'NO_OUT' 'X',
   'big'         'NO_OUT' 'X',
   'backoffice'  'NO_OUT' 'X',
   'frontoffice' 'NO_OUT' 'X',
   '9913'        'NO_OUT' 'X',
   'FOTO'        'NO_OUT' 'X',
   'bankl'       'NO_OUT' 'X',
   'bankn'       'NO_OUT' 'X',
   'cmkod'       'NO_OUT' 'X',
   'begdaegt'    'NO_OUT' 'X',
   'enddaegt'    'NO_OUT' 'X',
   'stext1'      'NO_OUT' 'X',
   'insti1'      'NO_OUT' 'X',
   'ftext1'      'NO_OUT' 'X',
   'durum'       'NO_OUT' 'X',
   'horizondestek'  'NO_OUT' 'X',
   'mudur_id'       'NO_OUT' 'X',
   'mudur_ename'    'NO_OUT' 'X',
   'direktor_id'    'NO_OUT' 'X',
   'direktor_ename' 'NO_OUT' 'X',
   'gmy_id'         'NO_OUT' 'X',
   'gmy_ename'      'NO_OUT' 'X',
*   'stext2'      'NO_OUT' 'X',
*   'insti2'      'NO_OUT' 'X',
*   'ftext2'      'NO_OUT' 'X',
   'BOLGEKODU'   'NO_OUT' 'X',
   'BOLGEADI'    'NO_OUT' 'X',
   'SBOLGEID'    'NO_OUT' 'X',
*   'SBOLGEKODU'   'NO_OUT' 'X',
   'SBOLGEADI'    'NO_OUT' 'X',
   'zpergruptx'  'NO_OUT' 'X'.

  DELETE gt_fieldcat WHERE fieldname = 'GRUP' .
  DELETE gt_fieldcat WHERE fieldname = 'GIRCIK' .
  DELETE gt_fieldcat WHERE fieldname = 'CITY' .
  DELETE gt_fieldcat WHERE fieldname = 'GESCH' .

  IF e_variant IS INITIAL AND c_variant IS NOT INITIAL.
    e_variant = c_variant.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
*     i_callback_top_of_page   = 'TOP_OF_PAGE'
      i_background_id          = 'ALV_BACKGROUND'
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = <fcat>
      it_sort                  = gt_sort
      is_variant               = e_variant
      it_events                = gt_events[]
      i_save                   = 'A'
    TABLES
      t_outtab                 = <fout>
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

ENDFORM.                    "modify_fieldcat
*User Command
FORM user_command  USING p_ucomm p_f TYPE slis_selfield.
  CASE p_ucomm.
    WHEN '&IC1'.
    WHEN 'BACK' OR '&EX'.
      LEAVE TO SCREEN 0.
  ENDCASE.
  p_f-refresh = 'X'.
ENDFORM.                    "user_command
*PF_STATUS
FORM pf_status_set USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'GUI'.
ENDFORM.                    "PF_STATUS_SET
*---------------------------------------------------------------------*
*      Form  F4_FOR_VARIANT                                           *
*---------------------------------------------------------------------*
FORM f4_for_variant.

  i_variant-report = sy-repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = i_variant
      i_save     = a_save
*     i_tabname_header    =
*     i_tabname_item      =
*     it_default_fieldcat =
    IMPORTING
*     e_exit     =
      es_variant = e_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 2.
    MESSAGE s205(0k).
  ELSE.
    p_var = e_variant-variant.
  ENDIF.
ENDFORM.                    "f4_for_variant
*---------------------------------------------------------------------*
*      Form  CHECK_VARIANT_EXISTENCE                                  *
*---------------------------------------------------------------------*
FORM check_variant_existence.

  IF NOT p_var IS INITIAL.
    MOVE: p_var  TO c_variant-variant,
          sy-repid TO c_variant-report.

    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = a_save
      CHANGING
        cs_variant = c_variant.
*        exceptions
*             wrong_input   = 1
*             not_found     = 2
*             program_error = 3
*             others        = 4.
  ENDIF.

ENDFORM.                    "check_variant_existence
*&---------------------------------------------------------------------*
*&      Form  GRUP_ICI_TRANSFER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM grup_ici_transfer .

  SELECT  begda endda FROM  pa0000
          INTO  (dbegda, dendda)
      WHERE pernr  =  p0000-pernr
        AND massn  =  '19'
        AND begda >=  hiredate
        AND begda LE pn-endda
    ORDER BY begda ASCENDING.
*    IF dbegda <= pn-endda.
*    ELSE.
*      EXIT.
*    ENDIF.
  ENDSELECT.
  IF sy-subrc EQ 0.
    SELECT SINGLE endda INTO dendda
                  FROM pa0001 WHERE pernr EQ p0000-pernr
                              AND   begda EQ dbegda
                              AND   bukrs EQ p0001-bukrs.
    IF sy-subrc EQ 0.
      bukrshiredate = dbegda.
    ELSE.
      bukrsfiredate = dbegda - 1.
    ENDIF.
  ENDIF.

ENDFORM.                    " GRUP_ICI_TRANSFER
*&---------------------------------------------------------------------*
*&      Form  READ_TARIH_P0041
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_tarih_p0041  USING    p0041 TYPE p0041
                                iv_datar TYPE datar
                       CHANGING ev_dardt TYPE dardt.
  FIELD-SYMBOLS: <f1> TYPE any.
  DATA: lv_f1(40), lv_nc(2) TYPE n.

  CLEAR lv_nc.
  DO 12 TIMES.
    ADD 1 TO lv_nc.
    CONCATENATE 'P0041-DAR' lv_nc INTO lv_f1.
    ASSIGN (lv_f1) TO <f1>.
    IF <f1> EQ iv_datar.
      FREE <f1>.
      CONCATENATE 'P0041-DAT' lv_nc INTO lv_f1.
      ASSIGN (lv_f1) TO <f1>.
      ev_dardt = <f1>.
    ENDIF.
    FREE <f1>.
  ENDDO.

ENDFORM.                    " READ_TARIH_P0041
FORM find_manager USING iv_orgeh
                        iv_pernr
                        iv_datum
                  CHANGING ev_manager_pernr
                           ev_manager_pos.
  DATA: lv_l TYPE i VALUE 2..

  CLEAR: ev_manager_pernr,
         gw_itab-manageruserid,
         gw_manager-manager_pos,
         gv_objid_plans.

  gv_objid_orgeh = iv_orgeh.

  lv_l = 3. "2.  "31.01.2023 VS
  DO 3 TIMES. "Add by VS

    CLEAR : gt_result1, gt_struc, gt_objec.
    PERFORM get_struc TABLES gt_objec gt_struc gt_result1
                       USING 'O'    gv_objid_orgeh
                             'B012' '01'
                             iv_datum iv_datum.


    READ TABLE gt_result1 INTO gw_result WITH KEY otype = 'S'.
    IF sy-subrc EQ 0.
      ev_manager_pos = gw_manager-manager_pos = gw_result-objid.

      gv_objid_plans = gw_result-objid.
      CLEAR : gt_result2, gt_struc, gt_objec.

      PERFORM get_struc TABLES gt_objec gt_struc gt_result2
                         USING 'S'    gv_objid_plans
                               'A008' '01'
                               iv_datum iv_datum.

      CLEAR gw_result.

      READ TABLE gt_result2 INTO gw_result WITH KEY otype = 'P'.
      IF sy-subrc EQ 0 AND gw_result-objid NE iv_pernr.
        gw_itab-manageruserid = gw_result-objid.
*        gw_manager-manager_id = gw_itab-manageruserid.
      ELSE.
        PERFORM get_higher_dept_man USING gv_objid_orgeh
                                 CHANGING gw_itab-manageruserid.
*        gw_manager-manager_id = gw_itab-manageruserid.
        IF sy-tabix EQ 1.
          lv_l = 3.
        ENDIF.
      ENDIF.

    ENDIF.

*---Begin off Add by VS
    IF gw_itab-manageruserid IS INITIAL OR
       gw_itab-manageruserid EQ iv_pernr.

      CLEAR : gt_result2, gt_struc, gt_objec.

      PERFORM get_struc TABLES gt_objec gt_struc gt_result2
                         USING 'O'    gv_objid_orgeh
                               'A002' '01'
                               iv_datum iv_datum.

      CLEAR gw_result.

      READ TABLE gt_result2 INTO gw_result WITH KEY otype = 'O'.
      IF sy-subrc EQ 0 AND gw_result-objid NE gv_objid_orgeh.
        gv_objid_orgeh = gw_result-objid.
      ENDIF.
    ELSE.
      EXIT.
    ENDIF.
    IF sy-index EQ lv_l.
      EXIT.
    ENDIF.

  ENDDO.

  ev_manager_pernr = gw_itab-manageruserid.
ENDFORM.                    " FIND_MANAGER
FORM get_struc TABLES pt_objec  STRUCTURE objec
                      pt_struc  STRUCTURE struc
                      pt_result STRUCTURE swhactor
               USING  pv_otype  LIKE objec-otype
                      pv_objid  LIKE gv_objid_orgeh
                      pv_wegid  LIKE gdstr-wegid
                      pv_plvar  LIKE objec-plvar
                      pv_begda  LIKE objec-begda
                      pv_endda  LIKE objec-endda.


  CLEAR : pt_objec, pt_struc, pt_result.
  REFRESH : pt_objec, pt_struc, pt_result.

  CALL FUNCTION 'RH_STRUC_GET'
    EXPORTING
      act_otype      = pv_otype
      act_objid      = pv_objid
      act_wegid      = pv_wegid
      act_plvar      = pv_plvar
      act_begda      = pv_begda
      act_endda      = pv_endda
    TABLES
      result_tab     = pt_result
      result_objec   = pt_objec
      result_struc   = pt_struc
    EXCEPTIONS
      no_plvar_found = 1
      no_entry_found = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " GET_STRUC
FORM get_higher_dept_man  USING    pv_department LIKE hrp1001-objid
                          CHANGING pv_userid     LIKE hrp1001-objid.

  DATA : lt_org_units TYPE hap_t_hrsobid,
         lv_from      TYPE hap_date_from,
         lv_to        TYPE hap_date_to,
         lt_types     TYPE hap_t_type.

  DATA : lt_high_units TYPE hap_t_hrsobid,
         lt_managers   TYPE hap_t_hrsobid,
         ls_return     TYPE bal_s_msg.

  DATA : ls_unit  TYPE hrsobid,
         ls_types TYPE hap_s_type.

  DATA : lw_1001 LIKE hrp1001.

  ls_unit-plvar = '01'.
  ls_unit-otype = 'O'.
  ls_unit-sobid = pv_department.
  APPEND ls_unit TO lt_org_units.

  lv_from = sy-datum.
  lv_to   = sy-datum.

  ls_types-type = 'O'.
  APPEND ls_types TO lt_types.

  CLEAR ls_types.
  ls_types-type = 'S'.
  APPEND ls_types TO lt_types.

  CLEAR ls_types.
  ls_types-type = 'P'.
  APPEND ls_types TO lt_types.


  CALL FUNCTION 'HRHAP_SEL_MANAGER_OF_HIGH_ORG'
    EXPORTING
      t_org_units        = lt_org_units
      from_date          = lv_from
      to_date            = lv_to
      t_target_types     = lt_types
    IMPORTING
      t_org_units_higher = lt_high_units
      t_managers         = lt_managers
      s_return           = ls_return
    EXCEPTIONS
      no_org_unit        = 1
      no_position        = 2
      OTHERS             = 3.
  IF sy-subrc EQ 0.
    CLEAR ls_unit.

    SORT lt_managers BY plvar otype.
    READ TABLE lt_managers INTO ls_unit WITH KEY plvar = '01'
                                                 otype = 'P'
                                                 BINARY SEARCH.
    IF sy-subrc EQ 0.
      pv_userid = ls_unit-sobid.
    ELSE.
      READ TABLE lt_managers INTO ls_unit WITH KEY plvar = '01'
                                                   otype = 'S'
                                                   BINARY SEARCH.
      IF sy-subrc EQ 0.
        CLEAR lw_1001.
        SELECT SINGLE * INTO lw_1001
                        FROM hrp1001
                       WHERE otype EQ ls_unit-otype
                         AND objid EQ ls_unit-sobid
                         AND plvar EQ '01'
                         AND rsign EQ 'A'
                         AND relat EQ '008'
                         AND begda LE sy-datum
                         AND endda GE sy-datum.
        IF sy-subrc EQ 0 AND lw_1001-sclas EQ 'P'.
          pv_userid = lw_1001-sobid.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDIF.
ENDFORM.                    " GET_HIGHER_DEPT_MAN
