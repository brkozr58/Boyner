*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_YPKIDTOP                                                   *
*----------------------------------------------------------------------*
* Variables
DATA: m1,
      m2,
      cins(1),
      satirtip,
      stoploop,
      normlerr,
      fatalerr,
      p_confrm,
      hataturu,
      batchcnt,
      hatatext(50),
      paa_kisi(5),
      pa_kisi(5),
      top_kisi(5).

DATA: kidemtop TYPE i,
      kidcount TYPE i.
DATA  grevtarh(5) TYPE n.
DATA  ret_code LIKE sy-subrc.

DATA: kidbetrg LIKE rt-betrg,
      ihblgart LIKE rt-lgart,
      kidtavan LIKE rt-betrg,
      kidprimt LIKE rt-betrg,
      kidlgart LIKE rt-lgart.

DATA: kidpernr LIKE pernr-pernr.

DATA: kidbegda LIKE p0001-begda,
      kidendda LIKE p0001-endda,
      kidanfda LIKE p0001-begda,
      kidfpper LIKE p0001-endda,
      farktarh LIKE p0001-endda,
      temptarh LIKE p0001-endda.

*---Begin of Add by VS on 20.01.2014
DATA: appendrtab,
      ihbarhesapla,
      kitonbetrg    LIKE rt-betrg,
      kidemduzelt   LIKE rt-betrg,
      hiredatefirst LIKE p0001-begda.
*---End of Add by VS on 20.01.2014

DATA: hiredate LIKE p0001-begda,
      firedate LIKE p0001-endda,
      h_date   LIKE p0001-endda,
      h_anfda  LIKE p0001-endda.

DATA  phifi    LIKE phifi OCCURS
             5 WITH HEADER LINE.

DATA: calcmolga          LIKE t500l-molga VALUE '47',
      calc_currency      LIKE t001-waers  VALUE 'YTL',
      save_calc_currency LIKE t001-waers,
      c_fact             TYPE p DECIMALS 3.



DATA: BEGIN OF bdcdata OCCURS 1.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdcdata.
DATA BEGIN OF messtab OCCURS 10.
INCLUDE STRUCTURE bdcmsgcoll.
DATA END OF messtab.


DATA: BEGIN OF it7trg01 OCCURS 200.
        INCLUDE STRUCTURE t7trg01.
DATA:   cflag(1) TYPE c.
DATA: END OF it7trg01.

DATA: BEGIN OF itemp OCCURS 5,
        werks LIKE it7trg01-werks,
        btrtl LIKE it7trg01-btrtl,
        hesap,
        secil,
      END OF itemp.
DATA: BEGIN OF hatatab OCCURS 100,
        werks     LIKE pernr-werks,
        btrtl     LIKE pernr-btrtl,
        pernr     LIKE pernr-pernr,
        ename     LIKE pernr-ename,
        norml ,
        fatal ,
        htext(85),
      END OF hatatab.

*data: begin of it9ykd occurs 200.
*        include structure t9ykd.
*data: end of it9ykd.
DATA: BEGIN OF it7trk02 OCCURS 200.
        INCLUDE STRUCTURE t7trk02.
DATA: END OF it7trk02.

DATA: BEGIN OF it529a OCCURS 0.
        INCLUDE STRUCTURE t529a.
DATA: END OF it529a.

DATA: i0776 LIKE p0776 OCCURS 0 WITH HEADER LINE.

*DATA: BEGIN OF i0776 OCCURS 0.
*DATA: pernr LIKE p0776-pernr.
*      INCLUDE STRUCTURE ps0776.
*DATA: END OF i0776.

DATA: BEGIN OF p0000top OCCURS 5,
        begda LIKE p0000-begda,
        endda LIKE p0000-endda,
        farkt LIKE sy-datum,
      END OF p0000top.

DATA: BEGIN OF rtab OCCURS 0,
        pernr LIKE pernr-pernr,
        lgart LIKE t512w-lgart,
        lgtxt LIKE t512t-lgtxt,
        betrg LIKE rt-betrg,
      END OF rtab.

DATA: BEGIN OF mmer OCCURS 1000,
        bukrs LIKE pernr-bukrs,
        kostl LIKE pernr-kostl,
        kisi  TYPE i,
        kyil  TYPE i,
        kay   TYPE i,
        kgun  TYPE i,
        kidem LIKE rt-betrg,
        kiton LIKE rt-betrg,
      END OF mmer.
DATA: BEGIN OF iper OCCURS 1000,
        bukrs      LIKE pernr-bukrs,
        werks      LIKE pernr-werks,
        btrtl      LIKE pernr-btrtl,
        persk      LIKE pernr-persk,
        persg      LIKE pernr-persg,
        kostl      LIKE pernr-kostl,
        abkrs      LIKE pernr-abkrs,
        sehir      LIKE t7trg01-city,
        pernr      LIKE pernr-pernr,
        ename      LIKE pernr-ename,
        firsthired LIKE p0001-begda,
        hired      LIKE p0001-begda,
        fired      LIKE p0001-begda,
        gbdat      LIKE p0002-gbdat,
        gesch      LIKE p0002-gesch,
        ptime      LIKE p0001-begda,
        ftime      LIKE p0001-begda,
        ktime      LIKE p0001-begda,
        gtime      LIKE p0001-begda,
        eskit      LIKE p0001-begda,
        betrg      LIKE rt-betrg,
        ekucr      LIKE rt-betrg,
        topla      LIKE rt-betrg,
        kidem      LIKE rt-betrg,
        ihgun(3)   TYPE c,
        ihbar      LIKE rt-betrg,
        tavan      LIKE rt-betrg,
        k1yil      LIKE rt-betrg,
        kiton      LIKE rt-betrg,
        kikek      LIKE rt-betrg,
      END OF iper.
DATA: ipersum LIKE iper OCCURS 1000 WITH HEADER LINE.
DATA: BEGIN OF tc OCCURS 0,
        pernr     LIKE pernr-pernr,
        ename     LIKE iper-ename,
        hire      LIKE sy-datum,
        fire      LIKE sy-datum,
        betrg(20),
        ekucr(20),
        topla(20),
        k1yil(20),
        kidem(20),
        kikek(20),
        ihbar(20),
      END OF tc.
DATA: BEGIN OF fnames OCCURS 15,
        text(60),
        tabname(10),
        fname(10),
        typ,
      END OF fnames.
DATA: BEGIN OF la OCCURS 20.
DATA:   pernr LIKE pernr-pernr.
        INCLUDE STRUCTURE pbwla.
DATA: END OF la.
DATA: BEGIN OF ppbwla OCCURS 20.
        INCLUDE STRUCTURE pbwla.
DATA: END OF ppbwla.
DATA: h_flg, c_on VALUE '1', c_off VALUE '0'.

* selection screen
SELECTION-SCREEN BEGIN OF BLOCK kidem WITH FRAME TITLE TEXT-kid.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: potkidem RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN COMMENT 5(25) TEXT-sc1.
    PARAMETERS: pottarih LIKE sy-datum DEFAULT sy-datum.
    SELECTION-SCREEN POSITION 45.
    PARAMETERS: hakeden AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 47(20) TEXT-ka1.
    SELECTION-SCREEN POSITION 68.
    PARAMETERS: ozet AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 70(05) TEXT-ka2.
    SELECTION-SCREEN POSITION 76.
    PARAMETERS: bykkid AS CHECKBOX DEFAULT space.
    SELECTION-SCREEN COMMENT 78(38) TEXT-ka3.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: norkidem RADIOBUTTON GROUP gr1.
    SELECTION-SCREEN COMMENT 5(25) TEXT-sc2.
    PARAMETERS: norkitar LIKE mcbc-spmon DEFAULT sy-datum.

*PARAMETERS: norkiday(2) TYPE n, norkdyil(4) TYPE n.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: recalckd AS CHECKBOX.
    SELECTION-SCREEN COMMENT 5(40) TEXT-sc3.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS:  zsonbrd AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 5(60) TEXT-sc0.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: hatadety LIKE rpcxxxxx-kr_feld1 DEFAULT space.
    SELECTION-SCREEN COMMENT 5(60) TEXT-sc4.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: kidmtest LIKE rpcxxxxx-kr_feld1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 5(40) TEXT-sc5.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: artikyil LIKE rpcxxxxx-kr_feld1 DEFAULT space.
    SELECTION-SCREEN COMMENT 5(40) TEXT-sc6.
  SELECTION-SCREEN END OF LINE.

  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS: r_rt RADIOBUTTON GROUP gr5.
    SELECTION-SCREEN COMMENT 5(25) TEXT-uc1.
    PARAMETERS: r_8 RADIOBUTTON GROUP gr5.
    SELECTION-SCREEN COMMENT 40(25) TEXT-uc2.
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK kidem.

PARAMETERS: stand LIKE pc260-srtza DEFAULT 'A' NO-DISPLAY.
*
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK lgart WITH FRAME TITLE TEXT-lgt.

  SELECT-OPTIONS: wty_prim FOR t512w-lgart DEFAULT '3000' TO  '3001'
  NO-DISPLAY.
  SELECT-OPTIONS: wty_9chd FOR t512w-lgart."EFAULT '2005'.

  SELECT-OPTIONS: wty_9ubz FOR t554s-subty."EFAULT '0190'.

  SELECT-OPTIONS: wty_ikrm FOR t512w-lgart NO INTERVALS DEFAULT '/PAY'.

  SELECT-OPTIONS: w_ikrm14 FOR t512w-lgart NO INTERVALS DEFAULT '2050'.

  SELECT-OPTIONS: w_kistel FOR t512w-lgart NO INTERVALS DEFAULT '2050'.  "2100

SELECTION-SCREEN END OF BLOCK lgart.
