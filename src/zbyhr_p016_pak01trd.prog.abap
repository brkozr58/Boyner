*----------------------------------------------------------------------*
*   INCLUDE PA01KTRD                                               *
*----------------------------------------------------------------------*


DATA:   gt_kidem TYPE slis_t_fieldcat_alv.
DATA:   g_repid LIKE sy-repid.

* GUI
DATA: BEGIN OF xfcode OCCURS 10,
        fcode(4),
      END OF xfcode.

DATA: h_pernr    LIKE pernr-pernr,
      c_of(1)    TYPE c VALUE '0',
      m(1), h_yesno(1), h_zeile.       "Flags

DATA: h_abart         LIKE rt-abart,
      h_ue_artis_flag.

DATA : ypb LIKE t005-waers.               "YTL Dönüşümü için.


DATA: BEGIN OF hifint OCCURS 0,
        werks  LIKE py_wpbp-werks,
        btrtl  LIKE py_wpbp-btrtl,
        sskno  LIKE t7trg01-sskno,
        h_hire LIKE h_hire,
        h_fire LIKE h_fire,
        durum .
DATA:   END OF hifint.
* Variables
DATA:
  m1,
  m2,
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


DATA: hiredate LIKE p0001-begda,
      firedate LIKE p0001-endda,
      h_date   LIKE p0001-endda,
      h_edate  LIKE p0001-endda,
      h_anfda  LIKE p0001-endda.

DATA  phifi    LIKE phifi OCCURS 5 WITH HEADER LINE.

DATA: gv_current_screen(4).
DATA: calcmolga          LIKE t500l-molga VALUE '47'.

* Internal Tables
* "IS 05.04.2004 yapılmadı grev
*DATA:  BEGIN OF IT9YPF OCCURS 1.
*        INCLUDE STRUCTURE T9YPF.
*DATA:  END   OF IT9YPF.

DATA: BEGIN OF bdcdata OCCURS 1.
        INCLUDE STRUCTURE bdcdata.
DATA: END OF bdcdata.
DATA BEGIN OF messtab OCCURS 10.
INCLUDE STRUCTURE bdcmsgcoll.
DATA END OF messtab.
* "IS 8.4.2004
*DATA: BEGIN OF It7trg01 OCCURS 200.
*        INCLUDE STRUCTURE t7trg01.
*DATA: CFLAG(1) TYPE C.
*DATA: END OF It7trg01.
*
DATA: BEGIN OF hatatab OCCURS 100,
        werks     LIKE pernr-werks,
        btrtl     LIKE pernr-btrtl,
        pernr     LIKE pernr-pernr,
        ename     LIKE pernr-ename,
        norml ,
        fatal ,
        htext(85),
      END OF hatatab.

DATA: BEGIN OF it7trk02 OCCURS 200.
        INCLUDE STRUCTURE t7trk02.
DATA: END OF it7trk02.

DATA: BEGIN OF it529a OCCURS 0.
        INCLUDE STRUCTURE t529a.
DATA: END OF it529a.

DATA: i0776 LIKE p0776 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF p0000top OCCURS 5,
        begda LIKE p0000-begda,
        endda LIKE p0000-endda,
        farkt LIKE sy-datum,
      END OF p0000top.

*DATA: BEGIN OF rtab OCCURS 0,
*        pernr LIKE pernr-pernr,
*        lgart LIKE t512w-lgart,
*        lgtxt LIKE t512t-lgtxt,
*        betrg LIKE rt-betrg,
*END OF rtab.

DATA: rtab LIKE ptr09 OCCURS 0 WITH HEADER LINE.

DATA :
  kitonbetrg LIKE rt-betrg,
  ikid       LIKE ptr07 OCCURS 0 WITH HEADER LINE.


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
*DATA:  iper TYPE ptr07 OCCURS 10 WITH HEADER LINE.
DATA:   BEGIN OF iper OCCURS 10 .
DATA : bukrs  LIKE pernr-bukrs.
       INCLUDE    TYPE ptr07 .
       INCLUDE    TYPE zbyhr_skid00 .
DATA : fchire TYPE datum.
DATA : END OF iper.

DATA: ipersum LIKE iper OCCURS 1000 WITH HEADER LINE.


DATA:  eiper TYPE ptr07 OCCURS 10 WITH HEADER LINE.  " excel çıktısı .
*DATA:  iperc TYPE ptr07 OCCURS 10 WITH HEADER LINE. "Çalışan Alt Grubu
DATA:  iperc LIKE iper OCCURS 10 WITH HEADER LINE. "Çalışan Alt Grubu

DATA: BEGIN OF iperw OCCURS 20.        "Werks/Btrtl IS
DATA: werks LIKE pernr-werks,
      btrtl LIKE pernr-btrtl.
DATA: END OF iperw.
DATA: BEGIN OF ipery OCCURS 20.
DATA: persg LIKE pernr-persg,
      persk LIKE pernr-persk.
DATA: END OF ipery.
*___Masraf yerine gore kırılması için / Cost center sorting
DATA: BEGIN OF iperk OCCURS 20.
DATA:   kostl LIKE pernr-kostl.
DATA: END OF iperk.


DATA: BEGIN OF la OCCURS 20.
DATA:   pernr LIKE pernr-pernr.
        INCLUDE STRUCTURE pbwla.
DATA: END OF la.
DATA: BEGIN OF ppbwla OCCURS 20.
        INCLUDE STRUCTURE pbwla.
DATA: END OF ppbwla.
DATA: h_flg, c_on VALUE '1', c_off VALUE '0'.
DATA: h_pers ."SerenK 22012009
* "IS 17.09.2002

DATA: h_fper0 LIKE pc260-fpper,
      h_fper1 LIKE pc260-fpper,
*      H_HIRE     LIKE P0001-BEGDA, "IS 8.4.2004
*      H_FIRE     LIKE H_HIRE,      "IS 8.4.2004
      h_begda LIKE sy-datum,
      h_endda LIKE sy-datum.

* "IS 9.04.2004
*DATA: BEGIN OF FHDATES OCCURS 0,
*      H_HIRE LIKE P0001-BEGDA,
*      H_FIRE LIKE P0001-BEGDA,
*      END OF FHDATES.
* "IS 9.04.2004


* "IS 17.09.2002

TABLES : t528t, t530t.
