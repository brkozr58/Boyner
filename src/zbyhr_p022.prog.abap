*&---------------------------------------------------------------------*
*& Report ZBYHR_P022
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p022
               LINE-SIZE 236 LINE-COUNT 63
               NO STANDARD PAGE HEADING MESSAGE-ID yy.
*----------------------------------------------------------------------*
*programmer    : Ayten AYGÜL  / Kadir ANLI                             *
*date          : 16/12/1999   / 27/06/2000                             *
*requested by  :                                                       *
*department    :                                                       *
*type          :
*                                                                      *
*----------------------------------------------------------------------*
*description   : Personel Giriş-Çıkış Tarihleri Listesi                *
*----------------------------------------------------------------------*
*  declaration of tables                                               *
*----------------------------------------------------------------------*
TABLES: hrp1000,
        pernr,  t500p, t001p,
        t001,  t527x,
        cskt,  " Masraf Yeri Metinleri
        tka02. " kontrol kodu
*----------------------------------------------------------------------*
*  declaration of info types                                           *
*----------------------------------------------------------------------*
INFOTYPES: 0000,
           0001,
           0002,
*           0009,
           0105,
*           9924,
           0769,
           0770,
           0771.
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
DATA : gw_itab         LIKE gt_itab,
*       gw_itab_by_date LIKE gt_itab_by_date,
       gv_objid_plans  TYPE hrobjid,
       gv_objid_orgeh  TYPE hrobjid,
       gv_objid_stell  TYPE hrobjid,
       gt_result1      LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gt_result2      LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gt_result_top   LIKE swhactor OCCURS 0 WITH HEADER LINE,
       gw_result       LIKE swhactor,
       gt_objec        LIKE objec OCCURS 0 WITH HEADER LINE,
       gt_struc        LIKE struc OCCURS 0 WITH HEADER LINE,
*       gt_1000         TYPE TABLE OF p1000,
*       gw_1000         TYPE p1000,
       gt_0000         TYPE TABLE OF p0000,
       gw_0000         TYPE p0000,
       gt_0001         TYPE TABLE OF p0001,
       gw_0001         TYPE p0001,
       gt_0002         TYPE TABLE OF p0002,
       gw_0002         TYPE p0002,
       gt_0008         TYPE TABLE OF p0008,
       gw_0008         TYPE p0008,
       gt_0105         TYPE TABLE OF p0105,
       gw_0105         TYPE p0105,
       gt_0769         TYPE TABLE OF p0769,
       gw_0769         TYPE p0769,
       gt_0770         TYPE TABLE OF p0770,
       gw_0770         TYPE p0770,
       gt_0771         TYPE TABLE OF p0771,
       gw_0771         TYPE p0771.
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
        gircik(1),
        pernr(8),
        ename          LIKE pernr-ename,
        vorna          LIKE p0002-vorna,
        nachn          LIKE p0002-nachn,
        bukrs          LIKE p0001-bukrs,
        butxt          LIKE t001-butxt,
        werks          LIKE p0001-werks,
        wtext          LIKE t500p-name1,
        btrtl          LIKE p0001-btrtl,
        btext          LIKE t001p-btext,
        orgeh          LIKE p0001-orgeh,
        birim          LIKE hrp1000-stext, "t527x-orgtx,
        unvan          LIKE t513s-stltx,
        pozisyon       LIKE hrp1000-stext, "t528t-plstx,
        kostl          LIKE p0001-kostl,
        ktext          LIKE cskt-ktext,
        ansvh          LIKE p0001-ansvh,
        atx            LIKE t542t-atx,
        persg          LIKE p0001-persg,
        cagrp          LIKE t501t-ptext,
        persk          LIKE p0001-persk,
        caagr          LIKE t503t-ptext,
        cttyp          LIKE p0771-cttyp,
        sozlesme_turu  LIKE t547s-cttxt,
        abkrs          LIKE p0001-abkrs,
        atext          LIKE t549t-atext,
        mstbr          LIKE p0001-mstbr,
        sgmnt          LIKE p0001-sgmnt,
        sgmntt         LIKE fagl_segmt-name,
*        zzpergrp LIKE p0001-zzpergrp,
*        zpergruptx LIKE zzpergr-zpergruptx,
*        zzkonfirm LIKE p0001-zzkonfirm,
*        zzfirmtxt LIKE zzkonfirm-zzfirmtxt,
*        zzkonfirmsgk LIKE zzkonfirmsgk-zzkonfirmsgk,
*        zzfirmtxtsgk LIKE zzkonfirmsgk-zzfirmtxt,
        zzindalis      LIKE hrp1000-short,
*        sskno LIKE p0769-sskno,
*        kanun LIKE p0769-kanun,
        merni          LIKE p0770-merni,
        giristarih(12),
        cikistarih(12),
        massg          LIKE p0000-massg,
        cikisneden     LIKE t530t-mgtxt,
*        ssktur LIKE t7trs01-sstxt,
        sakatlikderece LIKE t7trt03-dtext,
*        bankl LIKE p0009-bankl,
*        bankn LIKE p0009-bankn,
        city           LIKE t7trg01-city,
        city_txt       LIKE  dd07v-ddtext,
        gesch          LIKE p0002-gesch,
        gesch_txt      LIKE  dd07v-ddtext,
*        zzdepartman LIKE p0001-zzdepartman,
*        zzdeptxt LIKE zzdepartman-zzdeptxt,
        gbdat          LIKE p0002-gbdat,
*        cmkod LIKE zhr_cm_kod-cmkod,
        ceptel         LIKE p0105-usrid,
        email          LIKE p0105-usrid_long,
        email10        LIKE p0105-usrid_long,
        email30        LIKE p0105-usrid_long,
        manager_id     LIKE pernr-pernr,
        manager_ename  LIKE p0001-ename,
        manager_email  LIKE p0105-usrid_long,
*        twiserid     LIKE p9924-twiserid,
        mark(1),
      END OF int_tab.

DATA : BEGIN OF gt_1000 OCCURS 0,
         otype TYPE otype,
         objid TYPE hrobjid,
         stext TYPE stext,
       END OF gt_1000.

*--Data definitions
DATA : gt_t001  LIKE t001  OCCURS 0 WITH HEADER LINE, " Şirket
       gt_t500p LIKE t500p OCCURS 0 WITH HEADER LINE, " Personel Alanı
       gt_t001p LIKE t001p OCCURS 0 WITH HEADER LINE, " Personel Alt Aln
       gt_t501t LIKE t501t OCCURS 0 WITH HEADER LINE, " Çalışan grubu
       gt_t503t LIKE t503t OCCURS 0 WITH HEADER LINE, " Çalışan alt grb
       gt_t512t LIKE t512t OCCURS 0 WITH HEADER LINE,
       gt_t542t LIKE t542t OCCURS 0 WITH HEADER LINE.

*DATA: BEGIN OF wtype,
*        lgann LIKE p0008-lga01,
*        betnn LIKE p0008-bet01,
*      END OF wtype.

DATA : manager_pos     TYPE plans,
       gv_datum        TYPE datum,
       pozisyon(40),
       ucret_tur(25),
*       ucret_tutar LIKE p0008-bet01,
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

DATA: hiredate LIKE rptxxxxx-datum1,
      firedate LIKE rptxxxxx-datum1,
      massg    LIKE p0000-massg,
      massn    LIKE p0000-massn.

DATA: h_hire  LIKE p0001-begda,
      h_fire  LIKE h_hire,
      w_endda LIKE h_hire.

DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.

DATA: i_variant LIKE disvariant,
      e_variant LIKE disvariant.

DATA : h_variant LIKE disvariant,
       a_save    TYPE c VALUE 'A',
       variant   LIKE disvariant,
       c_variant LIKE disvariant.

*** Single Domain Text ****
DATA: l_value LIKE  dd07v-domvalue_l,
      l_text  LIKE  dd07v-ddtext.

CONSTANTS: c_stat_etkin TYPE stat2 VALUE '3'.


SELECTION-SCREEN COMMENT /1(83) comm1 MODIF ID mg1.

SELECTION-SCREEN SKIP 1.

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

SELECTION-SCREEN : BEGIN OF BLOCK varyant WITH FRAME.
  PARAMETERS       : p_var LIKE disvariant-variant.
SELECTION-SCREEN : END OF BLOCK varyant .


AT SELECTION-SCREEN OUTPUT.
  CONCATENATE
     'DİKKAT !!! Çıkış Tarihi sistem tarihinden'
     'büyük eşitse raporda boş gelir!'
      INTO comm1 SEPARATED BY space.

  LOOP AT SCREEN.
    IF screen-group1 = 'MG1'.
      screen-intensified = '1'.
      screen-color = '6' .
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
* rp-lowdate-highdate.

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

*  frametxt = 'Kırılım ve Sıralama Seçimi'.
*  frmtxt2 = 'Kırılım'.
*  frmtxt3 = 'Sıralama'.
* HC 03.11.2000 Yetki sorunu  - KA
  pnp_sw_skip_pernr = 'N'.

*----------------------------------------------------------------------
*  start of selection
*----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM fill_text.

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
  int_tab-gbdat = p0002-gbdat.
  int_tab-vorna = p0002-vorna.
  int_tab-nachn = p0002-nachn.
*  rp_provide_from_last p0009 space pn-begda pn-endda.

  CLEAR p0105.
  rp_provide_from_last p0105 '0004' pn-begda pn-endda.
  IF sy-subrc EQ 0.
    int_tab-ceptel = p0105-usrid.
  ENDIF.

  CLEAR p0105.
  rp_provide_from_last p0105 '0010' pn-begda pn-endda.
  IF p0105-usrid_long IS INITIAL.
    rp_provide_from_last p0105 '0030' pn-begda pn-endda.
    IF p0105-usrid_long IS NOT INITIAL.
      int_tab-email = p0105-usrid_long.
      int_tab-email30 = p0105-usrid_long.
    ENDIF.
  ELSE.
    int_tab-email = p0105-usrid_long.
    int_tab-email10 = p0105-usrid_long.
  ENDIF.

*  CLEAR p9924.
*  rp_provide_from_last p9924 space pn-begda pn-endda.
*  IF sy-subrc EQ 0.
*    int_tab-twiserid = p9924-twiserid.
*  ENDIF.

  rp_provide_from_last p0769 space pn-begda pn-endda.
  rp_provide_from_last p0770 space pn-begda pn-endda.
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

*      int_tab-zzdepartman = p0001-zzdepartman.
*      int_tab-zzpergrp = p0001-zzpergrp .
*      int_tab-zzkonfirm = p0001-zzkonfirm.
*      int_tab-zzkonfirmsgk = p0001-zzkonfirmsgk.
      int_tab-orgeh = p0001-orgeh.

*      CLEAR int_tab-zpergruptx.
*      SELECT SINGLE zpergruptx FROM zzpergr INTO int_tab-zpergruptx
*                               WHERE bukrs = p0001-bukrs
*                               AND   zpergrup = p0001-zzpergrp .
*      CLEAR int_tab-zzfirmtxt.
*      SELECT SINGLE zzfirmtxt INTO int_tab-zzfirmtxt FROM zzkonfirm
*                                     WHERE bukrs = p0001-bukrs
*                                     AND  zzkonfirm = p0001-zzkonfirm.

*      CLEAR int_tab-zzfirmtxtsgk.
*      SELECT SINGLE zzfirmtxt INTO int_tab-zzfirmtxtsgk
*                    FROM zzkonfirmsgk
*                         WHERE bukrs        = p0001-bukrs
*                         AND   zzkonfirmsgk = p0001-zzkonfirmsgk.
*
*      CLEAR int_tab-zzdeptxt.
*      SELECT SINGLE zzdeptxt INTO int_tab-zzdeptxt
*                             FROM zzdepartman
*                             WHERE bukrs = p0001-bukrs
*                             AND  zzdepartman = p0001-zzdepartman.

*      CLEAR : l_value , l_text .

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

      PERFORM sigorta_tur_bul.
      PERFORM sakatlik_bul.

      ADD 1 TO totalper.
      endda = pn-endda.

*      ucret_tutar = 0.
**      do 20 times
**         varying wtype
**         from p0008-lga01
**         next p0008-lga02.
**        if wtype is initial.
**          exit.
**        endif.
**        add wtype-betnn to ucret_tutar .
**        clear wtype.
**      enddo.

      int_tab-pernr          = pernr-pernr.
      int_tab-ename          = pernr-ename.
      MOVE-CORRESPONDING p0001 TO int_tab.
      int_tab-mstbr          = p0001-mstbr. "Şef alanı
      int_tab-sgmnt = p0001-sgmnt.
*      int_tab-trfgr          = p0008-trfgr. " Ücret skala grubu
*      WRITE: p0769-sskno TO int_tab-sskno RIGHT-JUSTIFIED.
*      WRITE: P9004-TTSNO TO INT_TAB-TTSNO RIGHT-JUSTIFIED.
      WRITE: p0770-merni TO int_tab-merni RIGHT-JUSTIFIED.
      int_tab-giristarih     = hiredate. "Giris tarihi
      int_tab-cikistarih     = firedate. "Cikis tarihi

      CLEAR: int_tab-sgmntt.
      SELECT SINGLE name INTO int_tab-sgmntt FROM fagl_segmt
        WHERE langu EQ sy-langu
        AND   segment = int_tab-sgmnt.

      PERFORM set_itab_text.
      PERFORM fill_pernr_details.

*----------- çıkış nedenini bul ------------------*
      CLEAR: int_tab-cikisneden.
      SELECT SINGLE mgtxt FROM t530t INTO int_tab-cikisneden
          WHERE massn = massn
            AND massg = massg
            AND sprsl = sy-langu.
      int_tab-massg = massg.
*-------------------------------------------------*


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
      IF firedate IS INITIAL OR firedate GE sy-datum OR
         firedate EQ space OR firedate EQ '        '.
        gv_datum = sy-datum.
      ELSE.
        gv_datum = firedate.
      ENDIF.

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
        CLEAR int_tab-manager_email.
        SELECT SINGLE usrid_long INTO int_tab-manager_email
               FROM pa0105 WHERE pernr EQ int_tab-manager_id
                           AND   subty EQ '0010'
                           AND   endda GE pn-begda
                           AND   begda LE pn-endda.
        IF int_tab-manager_email IS INITIAL.
          SELECT SINGLE usrid_long INTO int_tab-manager_email
               FROM pa0105 WHERE pernr EQ int_tab-manager_id
                           AND   subty EQ '0030'
                           AND   endda GE pn-begda
                           AND   begda LE pn-endda.
        ENDIF.
      ENDIF.

      rp_provide_from_last p0771 space pn-begda pn-endda.
      int_tab-cttyp = p0771-cttyp.
      CLEAR int_tab-sozlesme_turu.
      SELECT SINGLE cttxt INTO int_tab-sozlesme_turu FROM t547s
                        WHERE sprsl EQ sy-langu
                        AND   cttyp EQ int_tab-cttyp.

*      CLEAR int_tab-cmkod.
*      SELECT SINGLE cmkod INTO int_tab-cmkod FROM zhr_cm_kod
*                        WHERE werks EQ int_tab-werks
*                        AND   btrtl EQ int_tab-btrtl.

*      int_tab-ucret          = ucret_tur  .     "Ucret türü
*      int_tab-ssktur         = sigorta_tur.     "Ssk türü
      int_tab-sakatlikderece = p0769-disab. "Sakatlık derecesi
*      int_tab-kanun          = p0769-kanun.
*      int_tab-bankl          = p0009-bankl.
*      int_tab-bankn          = p0009-bankn.
      int_tab-index          = 1.

      WRITE hiredate TO int_tab-giristarih MM/DD/YYYY.
      IF firedate NE ''.
        WRITE firedate TO int_tab-cikistarih MM/DD/YYYY.
      ENDIF.

      IF firedate GE sy-datum.
        CLEAR: int_tab-cikistarih,
               int_tab-cikisneden,
               int_tab-massg.
      ENDIF.

*      write ucret_tutar to int_tab-ucrettutar currency p0008-waers.
      APPEND int_tab.

    ENDIF.
  ENDIF.

END-OF-SELECTION.

*  IF ss_sicil = 'X'.
  SORT int_tab BY bukrs gircik pernr ASCENDING.
*  ELSE.
*    SORT int_tab BY bukrs gircik ename AS TEXT ASCENDING.
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
      massg = dmassg .
      massn = isdt.
    ENDIF.
  ENDSELECT.
ENDFORM.                    "girenler_tarih_bul
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
    IF dbegda >= pn-begda AND dbegda <= pn-endda .
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

  IF firedate GE sy-datum.
    CLEAR: firedate.
  ENDIF.

ENDFORM.                    "cikanlar_tarih_bul
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
    IF dbegda GE hiredate AND dbegda LE pn-endda.
      IF dbegda LE pn-endda.
        firedate = dbegda.
        massg = dmassg.
        massn = isdt.
      ENDIF.
    ENDIF.
  ENDSELECT.
ENDFORM.                    "calisan_tarih_bul
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

*  IF firedate GE sy-datum.
*    CLEAR: firedate.
*  ENDIF.

ENDFORM.                    "hepsi_tarih_bul
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
          firedate = ''.
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


  IF firedate GE sy-datum.
    CLEAR: firedate.
  ENDIF.


ENDFORM.                    "giris_cikis_bul
*----------------------------------------------------------------------*
* Ekrana Görüntüleniyor...
*----------------------------------------------------------------------*
FORM display.
*---
  w_kisi = 0. grup_kisi = 0.
*---

  PERFORM alv_initial USING '' 'INT_TAB'.
  PERFORM modify_fieldcat.


*  LOOP AT int_tab.
*    PERFORM sirket.
*    AT NEW bukrs.
*      sayfa = 0. NEW-PAGE.
*    ENDAT.
*    AT NEW grup. PERFORM write_top_of_group. ENDAT.
*    WRITE : /(08) int_tab-pernr NO-ZERO,
*             (30) int_tab-ename.
*    SET LEFT SCROLL-BOUNDARY .
*    WRITE: (15) int_tab-btrtl,
*           (08) int_tab-mstbr,
*           (34) int_tab-pozition,
*      (15) int_tab-stell,
*      (18) int_tab-sskno,
*      (12) int_tab-merni,
*      (10) int_tab-giristarih,
*      (10) int_tab-cikistarih,
*      (32) int_tab-cikisneden,
**      (17) int_tab-ucrettutar no-zero right-justified,
**      (8) int_tab-ucret,
*      (7) int_tab-ssktur,
*      (3) int_tab-sakatlikderece,
*      (9) int_tab-bankl LEFT-JUSTIFIED,
*      (10) int_tab-bankn.
*
*    w_kisi = w_kisi + 1.
*    IF int_tab-gircik EQ 2.
*      grup_kisi = grup_kisi - 1.
*    ELSE.
*      grup_kisi = grup_kisi + 1.
*    ENDIF.
*    IF s_gircik = 'X'.
*      AT END OF gircik.
*        ULINE.
*        WRITE : / w_kisi , 'KİŞİ'.
*        w_kisi = 0.
*        ULINE.
*      ENDAT.
*    ENDIF.
*    AT END OF grup.
*      ULINE.
*      WRITE : / grup_kisi , 'KİŞİ'.
*      grup_kisi = 0.
*      ULINE.
*    ENDAT.
*    IF s_gircik NE 'X'.
*      AT LAST.
*        ULINE.
*        WRITE : / totalper , 'KİŞİ'.
*        ULINE.
*      ENDAT.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    "display

*----------------------------------------------------------------------*
* Sigorta Türü Bulunuyor
*----------------------------------------------------------------------*
FORM sigorta_tur_bul.
  sigorta_tur = ''.
  SELECT sstxt
   FROM   t7trs01
   INTO   sigorta_tur
   WHERE   ssgrp = p0769-ssgrp.
  ENDSELECT.

ENDFORM.                    "sigorta_tur_bul

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
ENDFORM.                    "sakatlik_bul
*----------------------------------------------------------------------*
*      TOP OF PAGE                                                     *
*----------------------------------------------------------------------*
TOP-OF-PAGE.
  IF sayfa = 0.
    ULINE (82).
    WRITE: 5 'Parametre seçimleri'.
    WRITE: / sy-vline NO-GAP, sirket LEFT-JUSTIFIED NO-GAP,
             donem LEFT-JUSTIFIED NO-GAP, sy-vline.
    WRITE: / sy-vline NO-GAP, personel LEFT-JUSTIFIED NO-GAP,
             persalani LEFT-JUSTIFIED NO-GAP, sy-vline.
    WRITE: / sy-vline NO-GAP, calgrubu LEFT-JUSTIFIED NO-GAP,
             paltalani LEFT-JUSTIFIED NO-GAP, sy-vline.
    WRITE: / sy-vline NO-GAP, calaltgrb LEFT-JUSTIFIED NO-GAP,
             bdraltbirimi LEFT-JUSTIFIED NO-GAP, sy-vline.
    WRITE: / sy-vline NO-GAP, organizasyon LEFT-JUSTIFIED NO-GAP,
             ustalan LEFT-JUSTIFIED NO-GAP, sy-vline.
    WRITE:/ sy-vline NO-GAP, (80) sy-uline NO-GAP, sy-vline NO-GAP.
    WRITE:/.
  ENDIF.
  WRITE: 20 t001-butxt.
  WRITE: 50 'PERSONEL GİRİŞ ÇIKIŞ LİSTESİ'(top)
                                   COLOR COL_HEADING INVERSE.
  sayfa = sayfa + 1.
  DATA: lv_page(12),
        lv_txt(4).
  lv_txt = sayfa.
  CONCATENATE 'Sayfa : ' lv_txt INTO lv_page.
  WRITE:  205 lv_page RIGHT-JUSTIFIED.
  WRITE : /20 'Raporlama Dönemi :', pn-begda , '-' , pn-endda .
  IF s_giren = 'X'.
    WRITE: ' -İşe Girişler-'.
  ELSEIF s_cikan = 'X'.
    WRITE: ' -İşten Çıkanlar-'.
  ELSEIF s_hepsi = 'X'.
    WRITE: ' -Çalışanlar ve Ayrılanlar-'.
  ELSEIF s_calis = 'X'.
    WRITE: ' -Çalışanlar-'.
  ELSEIF s_gircik = 'X'.
    WRITE: ' -Giren ve Çıkanlar-'.
  ENDIF.

  ULINE.
  WRITE: /(08) 'Sicil No'     CENTERED,
          (30) 'Adı Soyadı'   LEFT-JUSTIFIED,
          (15) 'Pers.Alt Alanı'     LEFT-JUSTIFIED,
          (08) 'Şef Alan'     LEFT-JUSTIFIED,
*          (08) 'Skala'     left-justified,
          (34) 'Pozisyon'     LEFT-JUSTIFIED,
          (15) 'İş      '     LEFT-JUSTIFIED,
          (18) 'SSK Sicil No' RIGHT-JUSTIFIED,
          (12) 'TC.Kimlik No'       RIGHT-JUSTIFIED,
          (10) 'Gir.Tar.'     CENTERED,
          (10) 'Çık.Tar.'     CENTERED,
          (32) 'Çık.Ned.'   ,
*          (17) 'Ücret  '      right-justified,
*          (8) 'Ücr. Tip'    left-justified,
          (7) 'SSK Tür'      LEFT-JUSTIFIED,
          (3) 'Skt'     LEFT-JUSTIFIED,
          (9) 'Bnk. Şube' LEFT-JUSTIFIED,
          (10) 'Hesap No' LEFT-JUSTIFIED.

  ULINE.

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
*&      Form  FIND_BTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM find_btext .
  SELECT SINGLE btext INTO int_tab-btrtl FROM t001p
                                         WHERE werks EQ p0001-werks
                                         AND   btrtl EQ p0001-btrtl.
ENDFORM.                    " FIND_BTEXT
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
    'butxt'         'Şirket Adı'            'Şirket Adı',
    'werks'         'Personel Alanı ID'     'Personel Alanı ID',
    'name1'         'Personel Alanı'        'Personel Alanı',
    'btrtl'         'Personel Alt Alanı ID' 'Personel Alt Alanı ID',
    'btext'         'Personel Alt Alanı'    'Personel Alt Alanı',
    'kostl'         'Masraf Yeri ID'        'Masraf Yeri',
    'ktext'         'Masraf Yeri'           'Masraf Yeri',
    'mstbr'         'Şef Alan'              'Şef Alan',
    'sgmnt'         'Segment'               'Segment',
    'sgmntt'        'Segment Adı'           'Segment Adı',
    'zzpergrp'      'Personel Sınıfı ID'    'Personel Sınıfı ID',
    'zpergruptx'    'Personel Sınıfı'       'Personel Sınıfı',
    'ZZINDALIS'     'İlet-Sakla İzni'        'İletişim-Saklama İzni',
    'trfgr'         'Skala'                 'Skala',
    'orgeh'         'Organizasyon ID'       'Organizasyon',
    'otext'         'Organizasyon'          'Organizasyon',
    'birim'         'Organizasyon'          'Organizasyon',
    'pozition'      'Pozisyon'              'Pozisyon',
    'Pozisyon'      'Pozisyon'              'Pozisyon',
    'stell'         'İş'                    'İş',
    'sskno'         'SSK Sicil No'          'SSK Sicil No',
    'merni'         'TC.Kimlik No'          'TC.Kimlik No',
    'giristarih'    'Gir.Tar.'              'Gir.Tar.',
    'cikistarih'    'Çık.Tar.'              'Çık.Tar.',
    'cikisneden'    'Çık.Ned.'              'Çık.Ned.',
    'ucrettutar'    'Ücret  '               'Ücret  ',
    'ucret'         'Ücr. Tip'              'Ücr. Tip',
    'ssktur'        'SSK Tür'               'SSK Tür',
    'sakatlikderece' 'Skt'                  'Skt',
    'bankl'          'Bnk. Şube'            'Bnk. Şube',
    'bankn'          'Hesap No'             'Hesap No',
    'twiserid'       'TWISER ID'            'TWISER ID',
    'email'          'E-Mail'               'E-Mail',
    'email10'        'E-Mail'               'Şirket E-Mail',
    'email30'        'E-Mail'               'Özel E-Mail',
    'ceptel'         'Cep Telefonu'         'Cep Telefonu',
    'city_txt'       'İl'                   'İl',
    'MANAGER_ID'     'Yönetici Sicil'       'Yönetici Sicil',
    'MANAGER_ENAME'  'Yönetici Adı'         'Yönetici Adı',
    'ZZFIRMTXTSGK'   'Konsinye Firma SGK'   'Konsinye Firma SGK',
    'MASSG'          'Çıkış Nedeni Kodu'    'Çıkış Nedeni Kodu',
    'manager_email'  'Yönetici E-Mail'      'Yönetici E-Mail',
    'gesch_txt'      'Cinsiyet'             'Cinsiyet'.

  PERFORM modify_fieldcatalog USING :
   'bukrs'    'NO_OUT' 'X',
   'wtext'    'NO_OUT' 'X',
*   'btext'    'NO_OUT' 'X',
   'butxt'    'NO_OUT' 'X',
   'kostl'    'NO_OUT' 'X',
   'ansvh'    'NO_OUT' 'X',
   'atx'      'NO_OUT' 'X',
*   'cagrp'    'NO_OUT' 'X',
*   'caagr'    'NO_OUT' 'X',
   'abkrs'    'NO_OUT' 'X',
   'werks'    'NO_OUT' 'X',
   'name1'    'NO_OUT' 'X',
   'btrtl'    'NO_OUT' 'X',
   'city'     'NO_OUT' 'X',
   'orgeh'    'NO_OUT' 'X',
   'gesch'    'NO_OUT' 'X',
   'grup'     'NO_OUT' 'X',
   'gircik'   'NO_OUT' 'X',
   'bukrs'    'NO_OUT' 'X',
   'persg'    'NO_OUT' 'X',
   'persk'    'NO_OUT' 'X',
   'atext'    'NO_OUT' 'X',
   'mark'     'NO_OUT' 'X',
   'kanun'    'NO_OUT' 'X',
   'email10'  'NO_OUT' 'X',
   'email30'  'NO_OUT' 'X',
   'twiserid' 'NO_OUT' 'X',
   'sgmnt'    'NO_OUT' 'X',
   'sgmntt'   'NO_OUT' 'X',
   'ZZINDALIS' 'NO_OUT' 'X',
   'zzpergrp' 'NO_OUT' 'X',
   'ZZKONFIRM' 'NO_OUT' 'X',
   'zzfirmtxt' 'NO_OUT' 'X',
   'ZZDEPARTMAN' 'NO_OUT' 'X',
   'ZZDEPTXT' 'NO_OUT' 'X',
   'ZZKONFIRMSGK' 'NO_OUT' 'X',
   'zzfirmtxtSGK' 'NO_OUT' 'X',
*   'MANAGER_ID' 'NO_OUT' 'X',
*   'MANAGER_ENAME' 'NO_OUT' 'X',
   'CTTYP' 'NO_OUT' 'X',
   'KTEXT' 'NO_OUT' 'X',
   'MSTBR' 'NO_OUT' 'X',
   'GBDAT' 'NO_OUT' 'X',
   'VORNA' 'NO_OUT' 'X',
   'NACHN' 'NO_OUT' 'X',
   'zpergruptx' 'NO_OUT' 'X'.


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
*&      Form  SET_ITAB_TEXT
*&---------------------------------------------------------------------*
FORM set_itab_text .
* Şirket TX
  CLEAR gt_t001.
  READ TABLE gt_t001 WITH KEY bukrs = int_tab-bukrs.
  int_tab-butxt = gt_t001-butxt.

  SELECT SINGLE * FROM tka02
                  WHERE bukrs EQ p0001-bukrs.
*                  and   gsber eq p0001-gsber.

  SELECT SINGLE ktext INTO int_tab-ktext
                      FROM cskt
                           WHERE spras EQ sy-langu
                           AND   kokrs EQ tka02-kokrs
                           AND   kostl EQ int_tab-kostl
                           AND   datbi GE sy-datum.
* İstihdam Koşulu
  CLEAR gt_t542t.
  READ TABLE gt_t542t WITH KEY ansvh = int_tab-ansvh.
  int_tab-atx = gt_t542t-atx.


  CLEAR: int_tab-wtext.
  SELECT name1 INTO int_tab-wtext FROM t500p
    WHERE persa = int_tab-werks.
  ENDSELECT.

ENDFORM.                    " SET_ITAB_TEXT
*&---------------------------------------------------------------------*
*&      Form  fill_pernr_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_pernr_details .

  CLEAR: int_tab-pozisyon.
*  SELECT plstx INTO int_tab-pozisyon FROM t528t
*    WHERE plans = p0001-plans.
*  ENDSELECT.
*  SELECT SINGLE stext INTO int_tab-pozisyon
*         FROM hrp1000 WHERE plvar = '01'
*                      AND   otype = 'S'
*                      AND   objid = p0001-plans
*                      AND   begda LE pn-endda
*                      AND   endda GE pn-begda.
  READ TABLE gt_1000 WITH KEY otype = 'S'
                            objid = p0001-plans
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
    int_tab-pozisyon = gt_1000-stext.
  ENDIF.


*  CLEAR: int_tab-unvan.
*  SELECT stltx INTO int_tab-unvan FROM t513s
*    WHERE stell = p0001-stell.
*  ENDSELECT.
  READ TABLE gt_1000 WITH KEY otype = 'C'
                            objid = p0001-stell
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
    int_tab-unvan = gt_1000-stext.
  ENDIF.

*  CLEAR: int_tab-birim.
*  SELECT orgtx INTO int_tab-birim FROM t527x
*    WHERE orgeh = p0001-orgeh.
*  ENDSELECT.
  READ TABLE gt_1000 WITH KEY otype = 'O'
                            objid = p0001-orgeh
                         BINARY SEARCH.
  IF sy-subrc EQ 0.
    int_tab-birim = gt_1000-stext.
  ENDIF.

  CLEAR: int_tab-cagrp.
  SELECT ptext INTO int_tab-cagrp FROM t501t
    WHERE persg = p0001-persg.
  ENDSELECT.

  CLEAR: int_tab-caagr.
  SELECT ptext INTO int_tab-caagr FROM t503t
    WHERE persk = p0001-persk.
  ENDSELECT.

  CLEAR: int_tab-atext.
  SELECT atext INTO int_tab-atext FROM t549t
    WHERE abkrs = p0001-abkrs
    AND   sprsl = sy-langu.
  ENDSELECT.

  CLEAR: int_tab-wtext.
  SELECT name1 INTO int_tab-wtext FROM t500p
    WHERE persa = p0001-werks.
  ENDSELECT.

  CLEAR: int_tab-btext.
  SELECT btext INTO int_tab-btext FROM t001p
    WHERE werks = p0001-werks
    AND   btrtl = p0001-btrtl.
  ENDSELECT.

ENDFORM.                    " fill_pernr_details
*&---------------------------------------------------------------------*
*&      Form  fill_TEXT
*&---------------------------------------------------------------------*
FORM fill_text.
* Şirket Tanımları
  SELECT * FROM t001  INTO TABLE gt_t001 .
* Personel Alanı Metni
  SELECT * FROM t500p INTO TABLE gt_t500p.
* Personel Alt Alanı Metni
  SELECT * FROM t001p INTO TABLE gt_t001p.
* Çalışan Grubu Metni
  SELECT * FROM t501t INTO TABLE gt_t501t WHERE sprsl = sy-langu.
* Çalışan Alt Grubu Metni
  SELECT * FROM t503t INTO TABLE gt_t503t WHERE sprsl = sy-langu.
* Ücret Türü Metinleri
  SELECT * FROM t512t INTO TABLE gt_t512t
                      WHERE sprsl = sy-langu
                        AND molga = '47'.

  SELECT * FROM t542t INTO TABLE gt_t542t WHERE spras EQ sy-langu.

ENDFORM.                    " fill_TEXT
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

  DATA : ls_unit TYPE hrsobid,
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
