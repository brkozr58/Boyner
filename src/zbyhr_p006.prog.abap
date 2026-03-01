*&---------------------------------------------------------------------*
*& Report ZBYHR_P006
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p006.

TABLES: pernr,
        zbyhr_v003,
        " View on Fields, Data Elements, and Domains of a Table
        t512w,                         " Wage Type Valuation
        t512z,  " Bilgi tipi başına ücret türlerinin kabul edilebilirliğ
        t512t,                         " Ücret ve maaş türleri metni
        sscrfields,                    " Fields on selection screens
        v_t512z,                       " Kabul edilebilir ücret türleri
        "zthr_psbr,  " Personel sicil bilgileri raporu (Search help)
        t503,                          " Çalışan grubu/çalışan alt grubu
        t510,                          " Ücret skalası grupları
        t001,                          " Şirket Adı
        t500p,                         " Personel Alanı Adı
        t001p,                         " Personel Alt Alanı Adı
        t527x,                         " Organizasyon Birimleri
        cskt,                          " Masraf Yeri Metinleri
        tka02.

TYPE-POOLS: truxs, slis,kkblo.
*----------------------------------------------------------------------*
*  declaration of info types                                           *
*----------------------------------------------------------------------*
INFOTYPES: 0000, 0001, 0002, 0008, 0014, 0015, 2001, 2010. "9917.
*----------------------------------------------------------------------*
*  declaration of data                                                 *
*----------------------------------------------------------------------*
CONSTANTS:  felder TYPE i VALUE 20.

DATA: myreport        LIKE sy-repid,
      headline2(132),
      footnote2(132),
      datum(10),
      w_date(13),
      col,
      no_of_person    TYPE i,
      num_of_personel TYPE i,
      wbetrg          LIKE p0014-betrg,
      dorgtx          LIKE t527x-orgtx.

*--Puantaj listesi ana verileri
DATA: BEGIN OF puantajlistesi OCCURS 100,
        bukrs       LIKE p0001-bukrs,        " Şirket
        butxt       LIKE t001-butxt,
        grup        LIKE p0001-kostl,
        "(10),
        gruptx      LIKE hrp1000-stext,
*       werks like p0001-werks,        " Pers. Alanı
*       btrtl like p0001-btrtl,        " Pers. Alt Alanı
*       orgeh like p0001-orgeh,        " Org. Birimi
*       mstbr like p0001-mstbr,        " Şef Alanı
        pernr       LIKE p0001-pernr,
        name        LIKE p0001-ename,
        hiredate    LIKE p0000-begda,   "(12)          ,
        firedate    LIKE p0000-begda,   "(12)          ,
        total00(10) TYPE p DECIMALS 2,
        total01(10) TYPE p DECIMALS 2,
        total02(10) TYPE p DECIMALS 2,
        total03(10) TYPE p DECIMALS 2,
        total04(10) TYPE p DECIMALS 2,
        total05(10) TYPE p DECIMALS 2,
        total06(10) TYPE p DECIMALS 2,
        total07(10) TYPE p DECIMALS 2,
        total08(10) TYPE p DECIMALS 2,
        total09(10) TYPE p DECIMALS 2,
        total10(10) TYPE p DECIMALS 2,
        total11(10) TYPE p DECIMALS 2,
        total12(10) TYPE p DECIMALS 2,
        total13(10) TYPE p DECIMALS 2,
        total14(10) TYPE p DECIMALS 2,
        total15(10) TYPE p DECIMALS 2,
        total16(10) TYPE p DECIMALS 2,
        total17(10) TYPE p DECIMALS 2,
        total18(10) TYPE p DECIMALS 2,
        total19(10) TYPE p DECIMALS 2,
        say         LIKE bseg-peinh,
        color(4),
        mark,
      END OF puantajlistesi.
*-- Filed defination
DATA: BEGIN OF fieldnames OCCURS 5,
        text(25),
        tabname   LIKE rsnewleng-tabname,
        fieldname LIKE rsnewleng-fieldname,
        typ,
      END OF fieldnames.

DATA: save_subrc  LIKE sy-subrc, return_code LIKE sy-subrc.

DATA: BEGIN OF display_err OCCURS 0.
        INCLUDE STRUCTURE hrerror.
DATA: END OF display_err.

DATA: begda LIKE prel-begda,
      endda LIKE prel-endda.

DATA: hiredate LIKE rptxxxxx-datum1,
      firedate LIKE rptxxxxx-datum1,
      w_endda  LIKE hiredate.

DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.
*--Personele ait ödemeler
DATA: BEGIN OF wtype  OCCURS 5,
        pernr     LIKE pernr-pernr,
        bukrs     LIKE p0001-bukrs, "Split için, SerenK 10052012
        grup(10),"Split için, SerenK 10052012
        lgart     LIKE p0014-lgart,
        total(16) TYPE p DECIMALS 2,
      END OF wtype.
*-- Ödeme tipileri
TYPES: BEGIN OF heading,
         lgart      LIKE p0014-lgart,
         infotyp(4) TYPE c,
         rowid(2)   TYPE i,
       END OF heading.

DATA: wheading_tab TYPE HASHED TABLE OF heading
                        WITH UNIQUE KEY lgart infotyp.
DATA: wheading TYPE heading.

DATA: h_kdbeg LIKE sy-datum,
      h_kdend LIKE sy-datum.

* Global structure of list
DATA: gv_subrc            LIKE sy-subrc,
      gv_endda            TYPE datum,
      gt_events           TYPE slis_t_event,
      gv_repid            LIKE sy-repid,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      gs_layout           TYPE slis_layout_alv,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      h_repid             LIKE sy-repid,
      gs_top,
      gs_variant          LIKE disvariant,
      gt_list_top_of_page TYPE slis_t_listheader.

DATA  : gt_fieldcat TYPE slis_t_fieldcat_alv  .

* Events used by ALV Function
CONSTANTS: gc_top_of_page   TYPE slis_formname VALUE 'TOP_OF_PAGE_ALV',
           gc_user_command  TYPE slis_formname VALUE 'USER_COMMAND_ALV',
           gc_pf_status_set TYPE slis_formname VALUE 'STATUS_SET_ALV'.



rp-lowdate-highdate.

*----------------------------------------------------------------------*
*  DECLARATION OF PARAMETERS                                           *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK select_options
  WITH FRAME TITLE frametxt.
  SELECTION-SCREEN BEGIN OF BLOCK secim WITH FRAME TITLE frmtxt2.
    SELECTION-SCREEN BEGIN OF LINE.
      PARAMETERS: s_orgbrm RADIOBUTTON GROUP gr2.
      SELECTION-SCREEN COMMENT 3(11) TEXT-s02.
      PARAMETERS: s_sicno RADIOBUTTON GROUP gr2.
      SELECTION-SCREEN COMMENT 17(08) TEXT-s03.
      PARAMETERS: s_paltal RADIOBUTTON GROUP gr2.
      SELECTION-SCREEN COMMENT 28(15) TEXT-s04.
      PARAMETERS: s_sefaln RADIOBUTTON GROUP gr2.
      SELECTION-SCREEN COMMENT 46(09) TEXT-s05.
      PARAMETERS: s_masyer RADIOBUTTON GROUP gr2.
      SELECTION-SCREEN COMMENT 58(08) TEXT-s06.
    SELECTION-SCREEN END OF LINE.
    PARAMETERS yenisayf AS CHECKBOX DEFAULT 'X'.
  SELECTION-SCREEN END OF BLOCK secim.
  SELECTION-SCREEN BEGIN OF BLOCK sirala WITH FRAME TITLE frmtxt3.
    SELECTION-SCREEN BEGIN OF LINE.
      PARAMETERS: ss_sicil RADIOBUTTON GROUP gr3.
      SELECTION-SCREEN COMMENT 3(10) TEXT-ss0.
      PARAMETERS: ss_isim RADIOBUTTON GROUP gr3.
      SELECTION-SCREEN COMMENT 16(10) TEXT-ss1.
    SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK sirala.
SELECTION-SCREEN END OF BLOCK select_options.

SELECTION-SCREEN BEGIN OF BLOCK wages WITH FRAME TITLE TEXT-kid.
  SELECT-OPTIONS i0014_lg FOR t512w-lgart.
  SELECT-OPTIONS i0015_lg FOR t512w-lgart.
  SELECT-OPTIONS i2010_lg FOR t512w-lgart.

  "SELECT-OPTIONS i0014_lg FOR zthr_psbr-p0014.
  "SELECT-OPTIONS i0015_lg FOR zthr_psbr-p0015.
  "SELECT-OPTIONS i2010_lg FOR zthr_psbr-p2010.

  SELECTION-SCREEN BEGIN OF BLOCK akt WITH FRAME TITLE TEXT-akt.
    SELECT-OPTIONS i2001_lg FOR p2001-awart.
    SELECTION-SCREEN BEGIN OF LINE.
      PARAMETERS r_abrtg RADIOBUTTON GROUP gr01.
      SELECTION-SCREEN COMMENT 3(20) TEXT-c06.
      PARAMETERS r_kaltg RADIOBUTTON GROUP gr01.
      SELECTION-SCREEN COMMENT 26(30) TEXT-c07.
    SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN END OF BLOCK akt.
SELECTION-SCREEN END OF BLOCK wages.

SELECTION-SCREEN BEGIN OF BLOCK wkrday WITH FRAME TITLE TEXT-wrk.
  PARAMETERS wrkday(2).
  PARAMETERS holiday(2).
  PARAMETERS holiday2(2).
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS bcheck AS CHECKBOX.
    SELECTION-SCREEN COMMENT 3(20) TEXT-c04.
    PARAMETERS atla AS CHECKBOX DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 26(30) TEXT-c05.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK wkrday.

*----------------
INITIALIZATION.
  myreport = sy-repid.
  frametxt = 'Kırılım ve Sıralama Seçimi'.
  frmtxt2  = 'Kırılım'.
  frmtxt3  = 'Sıralama'.

* HC 03.11.2000 Yetki sorunu  - KA
  pnp_sw_skip_pernr = 'N'.



AT SELECTION-SCREEN ON VALUE-REQUEST FOR i0014_lg-low.
  PERFORM f4_lgart USING '0014' 'I0014_LG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR i0015_lg-low.
  PERFORM f4_lgart USING '0015' 'I0015_LG-LOW'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR i2010_lg-low.
  PERFORM f4_lgart USING '2010' 'I2010_LG-LOW'.

*----------------------------------------------------------------------*
*  f4_lgart                                                 *
*----------------------------------------------------------------------*
FORM f4_lgart USING pv_infty pv_field.

  DATA : BEGIN OF lt_lgart OCCURS 0 ,
           lgart LIKE t512t-lgart,
           lgtxt LIKE t512t-lgtxt,
         END OF lt_lgart .


  SELECT t1~lgart t2~lgtxt
             FROM t512z AS t1
       INNER JOIN t512t AS t2
           ON    t2~lgart EQ t1~lgart
             AND t2~molga EQ t1~molga
    INTO TABLE lt_lgart
       WHERE t1~infty EQ pv_infty
         AND t1~molga EQ '47'
         AND t2~sprsl EQ sy-langu .
*  DATA: lt_lgart TYPE TABLE OF t512w.
*
*  SELECT * FROM t512w INTO TABLE lt_lgart
*                           WHERE lgart = pv_lgart.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = 'LGART'
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = pv_field
      value_org   = 'S'
    TABLES
      value_tab   = lt_lgart.
ENDFORM.

*----------------------------------------------------------------------*
*  START OF SELECTION                                                  *
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM add_fields TABLES fieldnames "PerNo
                     USING 'P0001' 'PERNR' 'F' 4.
  PERFORM add_fields TABLES fieldnames "Adı
                     USING 'P0001' 'ENAME' 'F' 1.
  PERFORM add_fields TABLES fieldnames "Giriş tarihi
                     USING 'PRELQ' 'FIREDATE' 'X' 3.

  rp-set-data-interval p0001 pn-begda pn-endda.   "Authorization VS

GET pernr.

  DESCRIBE TABLE p0001 LINES sy-tfill. "Authorization  solution
  CHECK sy-tfill GT 0.                 "Authorization VS

  PERFORM hire_fire.
  w_endda = hiredate.
  IF hiredate LE pn-endda AND firedate GE pn-begda.
    rp_provide_from_last p0000 space pn-begda pn-endda.
    IF w_endda < pn-endda AND w_endda GE pn-begda.
      rp-provide-from-last p0001 space pn-begda w_endda.
    ELSE.
      rp-provide-from-last p0001 space pn-begda pn-endda.
    ENDIF.
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

      rp_provide_from_last p0008 space pn-begda pn-endda.
      rp_provide_from_last p0014 space pn-begda pn-endda.
      rp_provide_from_last p0015 space pn-begda pn-endda.
*   rp_provide_from_last p2001 space pn-begda pn-endda.
*   rp_provide_from_last p2010 space pn-begda pn-endda.

      puantajlistesi-bukrs = p0001-bukrs.
      IF s_orgbrm = 'X'.
        puantajlistesi-grup = p0001-orgeh.
      ELSEIF s_paltal = 'X'.
        puantajlistesi-grup+0(4) = p0001-werks.
        puantajlistesi-grup+4(4) = p0001-btrtl.
      ELSEIF s_sefaln = 'X'.
        puantajlistesi-grup = p0001-mstbr.
      ELSEIF s_masyer = 'X'.
        puantajlistesi-grup = p0001-kostl.
      ELSE.
        CLEAR puantajlistesi-grup.
      ENDIF.
      puantajlistesi-pernr = pernr-pernr.
      puantajlistesi-name  = p0001-ename.
      IF firedate LE pn-endda .
        MOVE firedate TO puantajlistesi-firedate.
      ELSE.
        CLEAR puantajlistesi-firedate.
      ENDIF.
      IF hiredate GE pn-begda .
        MOVE hiredate TO puantajlistesi-hiredate.
      ELSE.
        CLEAR puantajlistesi-hiredate.
      ENDIF.
*---Şirket Kodu
      CLEAR puantajlistesi-butxt.
      SELECT SINGLE butxt INTO puantajlistesi-butxt
             FROM t001 WHERE bukrs EQ puantajlistesi-bukrs.
      PERFORM read_group.
      puantajlistesi-say = 1.

      IF bcheck NE 'X'.
        PERFORM generate.
      ELSE.
        PERFORM generate_empty.
      ENDIF.
    ENDIF.
  ENDIF.

END-OF-SELECTION.
  IF bcheck NE 'X'.
    PERFORM make_crostab.
    IF atla EQ 'X'.
      PERFORM cikart.
    ENDIF.
  ENDIF.
  PERFORM def_headline2.
  PERFORM def_column.
  IF ss_sicil = 'X'.
    SORT puantajlistesi BY bukrs grup pernr ASCENDING.
  ELSE.
    SORT puantajlistesi BY bukrs grup name AS TEXT ASCENDING.
  ENDIF.
*  PERFORM show_report.
  PERFORM list_display USING 'PUANTAJLISTESI' .


*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
FORM list_display USING ip_table .
* Move current program name to variable
  gv_repid = sy-repid    .
* Define events
  PERFORM define_events          .
* Prepare field catalog
  PERFORM prepare_field_catalog USING ip_table .
* Display it
  PERFORM display_alv_list USING ip_table .
ENDFORM.                    " LIST_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  DEFINE_EVENTS
*&---------------------------------------------------------------------*
FORM define_events.
* Define events of ALV that will be used
  DATA: ls_event TYPE slis_alv_event.
  DATA: lv_index  LIKE sy-index        .
* Get events supported by ALV
  CHECK gt_events[] IS INITIAL .
  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.

* TOP_OF_PAGE
  READ TABLE gt_events WITH KEY name =  slis_ev_top_of_page
                           INTO ls_event.
  lv_index = sy-tabix.
  IF sy-subrc = 0.
    DELETE gt_events INDEX lv_index .
    MOVE gc_top_of_page TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.

* USER COMMAND
  READ TABLE gt_events WITH KEY name =  slis_ev_user_command
                            INTO ls_event.
  lv_index = sy-tabix.
  IF sy-subrc = 0.
    DELETE gt_events INDEX lv_index .
    MOVE gc_user_command TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.

** PF-STATUS
*  READ TABLE gt_events WITH KEY name =  slis_ev_pf_status_set
*                           INTO ls_event.
*  lv_index = sy-tabix.
*  IF sy-subrc = 0.
*    DELETE gt_events INDEX lv_index .
*    MOVE gc_pf_status_set TO ls_event-form.
*    APPEND ls_event TO gt_events.
*  ENDIF.

ENDFORM.                    " DEFINE_EVENTS

*&--------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_CATALOG
*&--------------------------------------------------------------------*
FORM prepare_field_catalog USING ip_table .

  DATA : ls_fieldcat   TYPE slis_fieldcat_alv,
         lv_save_tabix LIKE sy-tabix,
         lt_fieldcat   TYPE slis_t_fieldcat_alv,
         lv_str(20) .

* Get field names of structure
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = gv_repid
      i_internal_tabname     = ip_table
      i_inclname             = gv_repid
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  gt_fieldcat[] = lt_fieldcat[] .

  PERFORM change_display TABLES gt_fieldcat
                          USING ip_table.

ENDFORM .                    "PREPARE_FIELD_CATALOG
*&---------------------------------------------------------------------*
*&      Form  change_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM change_display  TABLES pt_fieldcat TYPE slis_t_fieldcat_alv
                      USING p_tabname  TYPE slis_tabname.
  DATA: lv_text(30), lv_hide.
  DATA: num_of_col TYPE i,
        lv_nc(2)   TYPE n.

*  IF r_paa NE space.
*    lv_text = 'KOSTL/KTEXT'.
*  ELSEIF r_k NE space.
*    lv_text = 'WERKS/WTEXT/BTRTL/BTEXT'.
*  ENDIF.

  lv_nc = '00'.
  num_of_col = 4.
  DO 20 TIMES.
    CONCATENATE 'TOTAL' lv_nc INTO lv_text.
    READ TABLE fieldnames INDEX num_of_col.
    IF sy-subrc EQ 0.
      PERFORM list_set_attribute(zby_gen_alv_list)
                    TABLES pt_fieldcat
                    USING  p_tabname:

                           lv_text
                           'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                           fieldnames-text.
      num_of_col = num_of_col + 1.
    ELSE.
      PERFORM list_set_attribute(zby_gen_alv_list)
                    TABLES pt_fieldcat
                    USING  p_tabname:

                           lv_text
                           'NO_OUT'
                           'X'.

    ENDIF.
    lv_nc = lv_nc + 1.
  ENDDO.


  PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:


                       'POZISYON'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Pozisyon',

                       'KOSTL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'ENAME/NAME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ad Soyad',

                       'SAY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kişi Sayısı',

*                       'SAY'
*                       'NO_OUT'
*                       'X',

                       lv_text
                       'NO_OUT'
                       'X',

                       'MASSN/MNTXT/MASSG/MGTXT'
                       'NO_OUT'
                       'X',

                       'POZISYON'
                       'NO_OUT'
                       'X',

                       'MSTBR'
                       'NO_OUT'
                       'X',

                       'CAGRP'
                       'NO_OUT'
                       'X',

                       'CAAGR'
                       'NO_OUT'
                       'X',

                       'ABKRS'
                       'NO_OUT'
                       'X',

*                       'UNVAN'
*                       'NO_OUT'
*                       'X',

                       'BIRIM'
                       'NO_OUT'
                       'X',

                       'ANZKL'
                       'NO_OUT'
                       'X',

                       'NEDENKOD'
                       'NO_OUT'
                       'X',

                       'ALTNEDENKOD'
                       'NO_OUT'
                       'X',

                       'GRUP/BUKRS'
                       'NO_OUT'
                       'X',

*                       'BUTXT'
*                       'NO_OUT'
*                       'X',

                       'SAYI'
                       'NO_OUT'
                       'X',

                       'ANRED/BIRIM/CAGRP/CAAGR/ABKRS/MSTBR'
                       'NO_OUT'
                       'X',

                       'ANSVH/ATX/'
                       'NO_OUT'
                       'X',

                       'TOPLAM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Toplam',

                       'NORM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Norm',

                       'FULLTIME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Fiili FT',

                       'PARTTIME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Fiili PT',

                       'BELIRLISURELI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Fiili BS',

                       'TOPLAMFIILI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Toplam Fiili',

                       'KAFASAYISI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kafa Sayısı',

                       'KAFASAYISI'
                       'NO_OUT'
                       'X',

                       'FARK'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Fark',

                       'FARK'
                       'OUTPUTLEN'
                       '4',

                       'NETDEGISIM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Net değişim',

                       'NETDEGISIM'
                       'OUTPUTLEN'
                       '11',

                       'SPMON'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Dönem',

                       'GRUP/GRUPTX'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Grup',

                       ''
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '',

                       'BEGDA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İzBaşla',

                       'ENDDA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İzBitiş',

                       ''
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '',

                       'KATEGORI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kategori',

                       'HIREDATE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşe Giriş Tarihi',

                       'KTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'HIREDATE'
                       'SELTEXT_S'
                       'GirişTarih',

                       'FIREDATE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşten Çıkış Tarihi',

                       'FIREDATE'
                       'SELTEXT_S'
                       'ÇıkışTarih',

                       'FIREDATE'
                       'OUTPUTLEN'
                       '20',

                       'CIKND'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşten Çıkış Nedeni',

                       'CIKND'
                       'SELTEXT_S'
                       'ÇıkışNeden',

                       'CIKND'
                       'OUTPUTLEN'
                       '20',

                       'MERNI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'TC Kimlik No',

                       'PERNR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Sicil',

                       'DURM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Durum',

                       'BUKRS/BUTXT/GRUP/GRUPTX/PERNR'
                       'FIX_COLUMN'
                       'X',

                       'ODEMEYAPILDI'
                       'CHECKBOX'
                       'X',

                       'YENGI'
                       'EMPHASIZE'
                       'C411',

                       'HIZMET_KODU'
                       'EDIT'
                       ''.





ENDFORM.                    " change_display

*---------------------------------------------------------------------*
*       FORM DISPLAY_ALV_LIST                                         *
*---------------------------------------------------------------------*
FORM display_alv_list USING ip_table .
* Display ALV on screen
  DATA : lv_str(20) .
  FIELD-SYMBOLS <lf_table>      TYPE STANDARD TABLE.
  FIELD-SYMBOLS <lf_fcat_table>      TYPE STANDARD TABLE.

  CONCATENATE ip_table '[]' INTO lv_str .
  ASSIGN (lv_str) TO <lf_table> .

  gs_layout-zebra = 'X'  .
  gs_layout-box_fieldname = 'MARK'.
  gs_layout-colwidth_optimize = 'X'  .
  gs_layout-info_fieldname = 'COLOR'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = gv_repid
      is_layout          = gs_layout
      it_fieldcat        = gt_fieldcat
      it_sort            = gt_sort[]
      is_variant         = gs_variant
      it_events          = gt_events
    TABLES
      t_outtab           = <lf_table>
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_LIST

*---------------------------------------------------------------------*
*       FORM STATUS_SET_ALV                                           *
*---------------------------------------------------------------------*
FORM status_set_alv USING is_extab TYPE kkblo_t_extab.      "#EC CALLED

  SET PF-STATUS 'ZHR_PFSTAT' .

ENDFORM.                    "STATUS_SET_ALV
*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE_ALV                                          *
*---------------------------------------------------------------------*
FORM top_of_page_alv .
                                                            "#EC CALLED
*          Top-Of-Page
  PERFORM fill_header  .

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE_ALV
*&---------------------------------------------------------------------*
*&      Form  fill_header
*&---------------------------------------------------------------------*
FORM fill_header.
  DATA: ls_line       TYPE slis_listheader,
        lv_count      TYPE i,
        lv_str(150)                  ,
        lv_datum(10)                 ,
        lv_datum1(10)                 ,
        lv_num(5)     TYPE n.

  IF sy-ucomm EQ '&F03'.
    gs_top = gs_top - 1.
  ENDIF.

  CLEAR: gt_list_top_of_page[], gt_list_top_of_page, ls_line.
  ls_line-typ  = 'H'.


  ls_line-info = 'PUANTAJ LİSTESİ'.
  APPEND ls_line TO gt_list_top_of_page.
  DESCRIBE TABLE puantajlistesi LINES lv_num.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  ls_line-info = headline2.
  APPEND ls_line TO gt_list_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  WRITE : sy-datum TO lv_datum DD/MM/YYYY.
  CONCATENATE sy-uzeit+0(2) ':' sy-uzeit+2(2) ':'
              sy-uzeit+4(2) INTO lv_str.
  CONCATENATE sy-uname '/' lv_datum '/' lv_str
                INTO ls_line-info SEPARATED BY space .
  APPEND ls_line TO gt_list_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'A'.
  CONCATENATE 'Satır sayısı:' lv_num INTO ls_line-info.
  APPEND ls_line TO gt_list_top_of_page.


ENDFORM .                    "FILL_HEADER
*---------------------------------------------------------------------*
*       FORM USER_COMMAND_ALV                                         *
*---------------------------------------------------------------------*
FORM user_command_alv USING ip_ucomm LIKE sy-ucomm
                        ip_selfield TYPE kkblo_selfield.
                                                            "#EC CALLED

  DATA: wa_field LIKE puantajlistesi. "TYPE x_data.
* Check function code
  CASE ip_ucomm.
    WHEN 'AKTAR'.
*      CLEAR : it_data[] , wa_tab.
*      LOOP AT puantajlistesi INTO wa_field.
*        IF wa_field-mark ='X'.
*          MOVE-CORRESPONDING wa_field TO wa_tab.
*          APPEND wa_tab TO it_data.
*        ENDIF.
*      ENDLOOP.
*      IF sy-subrc = 0.
*        PERFORM operation .
*      ENDIF.
  ENDCASE.

  ip_selfield-refresh    = 'X'.
  ip_selfield-col_stable = 'X'.
  ip_selfield-row_stable = 'X'.
ENDFORM.                    "USER_COMMAND_ALV

*&---------------------------------------------------------------------*
*&      Form  f4_for_period
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
ENDFORM.                               " F4_FOR_PERIOD
*&---------------------------------------------------------------------*
*&      Form  set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZHR_PFSTAT'. " EXCLUDING rt_extab.
ENDFORM.                    "set_pf_status
*---------------------------------------------------------------------*
*       FORM READ_GROUP                                               *
*---------------------------------------------------------------------*
FORM read_group.
  IF s_orgbrm = 'X'.
    SELECT SINGLE orgtx INTO dorgtx FROM t527x
      WHERE orgeh = puantajlistesi-grup
        AND sprsl = 'T'.
    IF sy-subrc NE 0.
      dorgtx = 'Bulunamadı'.
    ENDIF.
    puantajlistesi-gruptx = dorgtx.
  ELSEIF s_paltal = 'X'.
    SELECT SINGLE * FROM t500p
      WHERE persa = puantajlistesi-grup+0(4)
      AND   molga = '47'.
    IF sy-subrc NE 0.
      dorgtx = 'Bulunamadı'.
    ENDIF.
    SELECT SINGLE * FROM t001p
      WHERE werks = puantajlistesi-grup+0(4)
      AND   btrtl = puantajlistesi-grup+4(4)
      AND   molga = '47'.
    IF sy-subrc NE 0.
      dorgtx = 'Bulunamadı'.
    ENDIF.
    CONCATENATE t500p-name1 t001p-btext
               INTO puantajlistesi-gruptx.
  ELSEIF s_sefaln = 'X'.
    puantajlistesi-gruptx = puantajlistesi-grup.
  ELSEIF s_masyer = 'X'.
    SELECT SINGLE * FROM tka02 WHERE bukrs = puantajlistesi-bukrs .
    SELECT SINGLE * FROM cskt WHERE kokrs EQ tka02-kokrs "
                              AND   kostl EQ puantajlistesi-grup
                              AND   datbi GE endda.
    IF sy-subrc NE 0.
      cskt-ktext = 'Bulunamadı'.
    ENDIF.
    puantajlistesi-gruptx = cskt-ktext.
  ENDIF.
ENDFORM.                    "READ_GROUP



*---------------------------------------------------------------------*
*       FORM GENERATE                                                 *
*---------------------------------------------------------------------*
FORM generate.
  PERFORM collect_wage_type.
  APPEND puantajlistesi.
ENDFORM.                    "GENERATE
*---------------------------------------------------------------------*
*       FORM GENERATE_EMPTY                                           *
*---------------------------------------------------------------------*
FORM generate_empty.
  PERFORM collect_empty_wage_type.
  puantajlistesi-total00 = wrkday.
  puantajlistesi-total01 = holiday.
  puantajlistesi-total02 = holiday2.
  APPEND puantajlistesi.
ENDFORM.                    "GENERATE_EMPTY
*---------------------------------------------------------------------*
*       FORM add_fields
*---------------------------------------------------------------------*
* ->  $table       Tabel Name
* ->  $name        Feld name
* ->  $typ         type
* <-  $fields
*---------------------------------------------------------------------*
FORM add_fields TABLES $fields LIKE fieldnames[]
                USING  $table $name $typ $num.
  CLEAR $fields.
  SELECT SINGLE * FROM zbyhr_v003 WHERE tabname    = $table
                                    AND   fieldname  = $name
                                    AND   ddlanguage = sy-langu.
  IF sy-subrc EQ 0.
    CASE $num.
      WHEN 1.
        $fields-text = zbyhr_v003-scrtext_s.
      WHEN 2.
        $fields-text = zbyhr_v003-scrtext_m.
      WHEN 3.
        $fields-text = zbyhr_v003-scrtext_l.
      WHEN 4.
        $fields-text = zbyhr_v003-reptext.
      WHEN 5.
        $fields-text = zbyhr_v003-ddtext.
      WHEN OTHERS.
        CLEAR $fields-text.
    ENDCASE.
  ENDIF.
  $fields-tabname = $table.
  $fields-fieldname = $name.
  $fields-typ = $typ.
  APPEND $fields.
ENDFORM.                    "ADD_FIELDS
*----------------------------------------------------------------------*
*       FORM init_fields
*----------------------------------------------------------------------*
* ->  $table       Tabel Name
* ->  $name        Feld name
* ->  $typ         type
* <-  $fields
*----------------------------------------------------------------------*
FORM init_fields TABLES $fields LIKE fieldnames[]
                USING  $table $name $text $typ.
  CLEAR $fields.
  $fields-tabname = $table.
  $fields-fieldname = $name.
  $fields-text = $text.
  $fields-typ = $typ.
  APPEND $fields.
ENDFORM.                    "INIT_FIELDS
*----------------------------------------------------------------------*
*      Form  def_header2
*----------------------------------------------------------------------*
FORM def_headline2.
  IF pn-begda EQ pn-endda.
    headline2 = 'Anahtar tarih :'.
    WRITE pn-begda TO datum DD/MM/YYYY.
    CONCATENATE headline2 datum INTO headline2
                                    SEPARATED BY space.
  ELSE.
    headline2 = TEXT-key.
    WRITE pn-begda TO datum DD/MM/YYYY.
    REPLACE '$1' WITH datum INTO headline2.
    WRITE pn-endda TO datum DD/MM/YYYY.
    REPLACE '$2' WITH datum INTO headline2.
  ENDIF.
ENDFORM.                    "DEF_HEADLINE2
*----------------------------------------------------------------------*
*      Form  hire_fire
*----------------------------------------------------------------------*
FORM hire_fire.
  begda = pn-begda.
  endda = pn-endda.
  CALL FUNCTION 'RP_HIRE_FIRE'
    EXPORTING
      beg       = begda
      end       = endda
    IMPORTING
      hire_date = hiredate
      fire_date = firedate
    TABLES
      pp0000    = p0000          "input
      pp0001    = p0001          "input
      pphifi    = phifi.         "output
ENDFORM.                    "HIRE_FIRE
*----------------------------------------------------------------------*
*      Form  collect_wage_type
*----------------------------------------------------------------------*
FORM collect_wage_type.
  DATA: lv_begda TYPE begda,
        lv_endda TYPE endda,
        lv_abrtg TYPE p2001-abrtg,
        ls_p2001 TYPE p2001.

  IF i0014_lg <> ''.
    PROVIDE * FROM p0014
              BETWEEN pn-begda AND pn-endda
              WHERE p0014-pernr = p0001-pernr
                AND p0014-lgart IN i0014_lg.
      wheading-lgart = p0014-lgart.
      wheading-infotyp = '0014'.
      COLLECT wheading INTO wheading_tab.
      wtype-pernr = p0014-pernr.
      wtype-lgart = p0014-lgart.
      IF p0014-lgart = 2025.
        wtype-total = p0014-anzhl.
      ELSE.
****   BEGIN OF YTL   AE   *****
*       WTYPE-TOTAL = P0014-BETRG * 100.
        wtype-total = p0014-betrg .
****   END OF YTL   AE *****
      ENDIF.
      IF p0014-indbw = 'I'.
        PERFORM find_wage USING p0014-lgart.
        wtype-total = wbetrg * 100.
        IF p0014-anzhl > 0.
          wtype-total = wtype-total * p0014-anzhl.
        ENDIF.
      ENDIF.

      APPEND wtype.
      CLEAR wtype.
    ENDPROVIDE.
  ENDIF.

  IF i2001_lg <> ''.
    PROVIDE * FROM p2001
              BETWEEN pn-begda AND pn-endda
              WHERE p2001-pernr = p0001-pernr
                AND p2001-awart IN i2001_lg.


      wheading-lgart = p2001-awart.
      wheading-infotyp = '2001'.
      COLLECT wheading INTO wheading_tab.
      wtype-pernr = p2001-pernr.
      wtype-lgart = p2001-awart.
*      WTYPE-TOTAL = WTYPE-TOTAL + P2001-ABWTG.
*      IF NOT ( p2001-begda BETWEEN pn-begda AND pn-endda )
*         OR not ( p2001-endda BETWEEN pn-begda AND pn-endda ) .
      READ TABLE p2001 INTO ls_p2001 WITH KEY begda = p2001-begda
                                              endda = p2001-endda.
      IF sy-subrc EQ 0.
        IF r_abrtg NE space.
          wtype-total = wtype-total + p2001-abrtg.
        ELSEIF r_kaltg NE space.
          wtype-total = wtype-total + p2001-kaltg.
        ENDIF.
      ELSE.
        PERFORM calc_abrtg USING p0001-pernr
                                 p2001-begda
                                 p2001-endda
                                 p2001-awart
                           CHANGING lv_abrtg.
        wtype-total = wtype-total + lv_abrtg.
      ENDIF.

      APPEND wtype.
      CLEAR wtype.
    ENDPROVIDE.
  ENDIF.
  IF i2010_lg <> ''.
    PROVIDE * FROM p2010
              BETWEEN pn-begda AND pn-endda
              WHERE p2010-pernr = p0001-pernr
                AND p2010-lgart IN i2010_lg.

      wheading-lgart = p2010-lgart.
      wheading-infotyp = '2010'.
      COLLECT wheading INTO wheading_tab.
      wtype-pernr = p2010-pernr.
      wtype-lgart = p2010-lgart.
      wtype-total = wtype-total + p2010-anzhl.

      APPEND wtype.
      CLEAR wtype.
    ENDPROVIDE.
  ENDIF.
  IF i0015_lg <> ''.
    PROVIDE * FROM p0015
              BETWEEN pn-begda AND pn-endda
              WHERE p0015-pernr = p0001-pernr
                AND p0015-lgart IN i0015_lg.
      wheading-lgart = p0015-lgart.
      wheading-infotyp = '0015'.
      COLLECT wheading INTO wheading_tab.
      wtype-pernr = p0015-pernr.
      wtype-lgart = p0015-lgart.
****   BEGIN OF YTL   AE   *****
*      WTYPE-TOTAL = P0015-BETRG * 100.
      wtype-total = p0015-betrg .
****   END OF YTL   AE *****

      IF p0015-indbw = 'I'.
        PERFORM find_wage USING p0015-lgart.
****   AE 191009  tahsil yardimi gibi sabit ucretlerde sorun vardi ****
*        WTYPE-TOTAL = WBETRG * 100.
        wtype-total = wbetrg.
****   AE 191009  son  ****
        IF p0015-anzhl > 0.
          wtype-total = wtype-total * p0015-anzhl.
        ENDIF.
      ENDIF.

      APPEND wtype.
      CLEAR wtype.
    ENDPROVIDE.
  ENDIF.


ENDFORM.                    "COLLECT_WAGE_TYPE
*---------------------------------------------------------------------*
*       FORM FIND_WAGE                                                *
*---------------------------------------------------------------------*
FORM find_wage USING plgart.
  DATA: wtrfkz LIKE t510-trfkz.
  CLEAR: wtrfkz, wbetrg.
  SELECT SINGLE trfkz INTO wtrfkz FROM t503
   WHERE persg = p0001-persg
     AND persk = p0001-persk.
  SELECT SINGLE betrg INTO wbetrg FROM t510
   WHERE molga = '47'
     AND trfar = p0008-trfar
     AND trfgb = p0008-trfgb
     AND trfkz = wtrfkz
     AND lgart = plgart
     AND endda GE pn-endda
     AND begda LE pn-begda.
ENDFORM.                    "FIND_WAGE
*----------------------------------------------------------------------*
*      Form  collect_empty_wage_type
*----------------------------------------------------------------------*
FORM collect_empty_wage_type.
  DATA: wlgart LIKE t512t-lgart.
  IF i0014_lg <> ''.
    SELECT lgart INTO (wlgart) FROM t512t
       WHERE lgart IN i0014_lg
         AND sprsl = 'T'.
      wheading-infotyp = '0014'.
      wheading-lgart = wlgart.
      COLLECT wheading INTO wheading_tab.
    ENDSELECT.
  ENDIF.
  IF i0015_lg <> ''.
    SELECT lgart INTO (wlgart) FROM t512t
      WHERE lgart IN i0015_lg
        AND sprsl = 'T'.
      wheading-infotyp = '0015'.
      wheading-lgart = wlgart.
      COLLECT wheading INTO wheading_tab.
    ENDSELECT.
  ENDIF.
  IF i2001_lg <> ''.
    SELECT awart INTO (wlgart) FROM t554t
      WHERE awart IN i2001_lg
        AND sprsl = 'T'.
      wheading-infotyp = '2001'.
      wheading-lgart = wlgart.
      COLLECT wheading INTO wheading_tab.
    ENDSELECT.
  ENDIF.
  IF i2010_lg <> ''.
    SELECT lgart INTO (wlgart) FROM t512t
      WHERE lgart IN i2010_lg
        AND sprsl = 'T'.
      wheading-infotyp = '2010'.
      wheading-lgart = wlgart.
      COLLECT wheading INTO wheading_tab.
    ENDSELECT.
  ENDIF.

ENDFORM.                    "COLLECT_EMPTY_WAGE_TYPE
*----------------------------------------------------------------------*
*      Form  def_column
*----------------------------------------------------------------------*
FORM def_column.
  DATA: wlgtxt  LIKE t512t-lgtxt,
        counter TYPE i.
  counter = 0.
  IF bcheck EQ 'X'.
    PERFORM init_fields TABLES fieldnames
                        USING space 'PRIM' TEXT-tw1 space.
  ENDIF.
  IF bcheck EQ 'X'.
    PERFORM init_fields TABLES fieldnames
                        USING space 'PRIM' TEXT-tw2 space.
  ENDIF.
  IF bcheck EQ 'X'.
    PERFORM init_fields TABLES fieldnames
                        USING space 'PRIM' TEXT-tw3 space.
  ENDIF.
  LOOP AT wheading_tab INTO wheading.
    CASE wheading-infotyp.
      WHEN '0014' OR '0015' OR '2010'.
        SELECT SINGLE lgtxt INTO (wlgtxt) FROM t512t
         WHERE lgart = wheading-lgart
           AND sprsl = 'T'.
      WHEN '2001'.
        SELECT SINGLE atext INTO (wlgtxt) FROM t554t
         WHERE awart = wheading-lgart
          AND sprsl = 'T'.
      WHEN '9917'.
        SELECT SINGLE stext INTO (wlgtxt) FROM t591s
         WHERE infty EQ '9917'
          AND subty = wheading-lgart
          AND sprsl = 'T'.

    ENDCASE.
    IF counter < 10.
      PERFORM init_fields TABLES fieldnames
                          USING space 'PRIM' wlgtxt space.
    ENDIF.
    counter = counter + 1.
  ENDLOOP.
ENDFORM.                    "DEF_COLUMN
*----------------------------------------------------------------------*
*      Form  make_crostab
*----------------------------------------------------------------------*
FORM make_crostab.
  DATA: counter TYPE n.
  counter = 0.
  LOOP AT wheading_tab INTO wheading.
    wheading-rowid = counter.
    MODIFY TABLE wheading_tab FROM wheading TRANSPORTING rowid.
    counter = counter + 1.
  ENDLOOP.
  LOOP AT wtype INTO wtype.
    LOOP AT wheading_tab INTO wheading WHERE lgart = wtype-lgart .
      LOOP AT puantajlistesi WHERE pernr = wtype-pernr.
        CASE wheading-rowid.
          WHEN 0.
            puantajlistesi-total00 = puantajlistesi-total00
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total00
              WHERE pernr = wtype-pernr.
          WHEN 1.
            puantajlistesi-total01 = puantajlistesi-total01
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total01
              WHERE pernr = wtype-pernr.
          WHEN 2.
            puantajlistesi-total02 = puantajlistesi-total02
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total02
              WHERE pernr = wtype-pernr.
          WHEN 3.
            puantajlistesi-total03 = puantajlistesi-total03
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total03
              WHERE pernr = wtype-pernr.
          WHEN 4.
            puantajlistesi-total04 = puantajlistesi-total04
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total04
              WHERE pernr = wtype-pernr.
          WHEN 5.
            puantajlistesi-total05 = puantajlistesi-total05
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total05
              WHERE pernr = wtype-pernr.
          WHEN 6.
            puantajlistesi-total06 = puantajlistesi-total06
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total06
              WHERE pernr = wtype-pernr.
          WHEN 7.
            puantajlistesi-total07 = puantajlistesi-total07
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total07
              WHERE pernr = wtype-pernr.
          WHEN 8.
            puantajlistesi-total08 = puantajlistesi-total08
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total08
              WHERE pernr = wtype-pernr.
          WHEN 9.
            puantajlistesi-total09 = puantajlistesi-total09
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total09
              WHERE pernr = wtype-pernr.
          WHEN 10.
            puantajlistesi-total10 = puantajlistesi-total10
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total10
              WHERE pernr = wtype-pernr.
          WHEN 11.
            puantajlistesi-total11 = puantajlistesi-total11
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total11
              WHERE pernr = wtype-pernr.
          WHEN 12.
            puantajlistesi-total12 = puantajlistesi-total12
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total12
              WHERE pernr = wtype-pernr.
          WHEN 13.
            puantajlistesi-total13 = puantajlistesi-total13
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total13
              WHERE pernr = wtype-pernr.
          WHEN 14.
            puantajlistesi-total14 = puantajlistesi-total14
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total14
              WHERE pernr = wtype-pernr.
          WHEN 15.
            puantajlistesi-total15 = puantajlistesi-total15
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total15
              WHERE pernr = wtype-pernr.
          WHEN 16.
            puantajlistesi-total16 = puantajlistesi-total16
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total16
              WHERE pernr = wtype-pernr.
          WHEN 17.
            puantajlistesi-total17 = puantajlistesi-total17
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total17
              WHERE pernr = wtype-pernr.
          WHEN 18.
            puantajlistesi-total18 = puantajlistesi-total18
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total18
              WHERE pernr = wtype-pernr.
          WHEN 19.
            puantajlistesi-total19 = puantajlistesi-total19
                                   + wtype-total.
            MODIFY puantajlistesi TRANSPORTING total19
              WHERE pernr = wtype-pernr.
        ENDCASE.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    "MAKE_CROSTAB
*&---------------------------------------------------------------------*
*&      Form  CIKART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cikart.
  LOOP AT puantajlistesi.
    IF puantajlistesi-total00 = 0 AND
       puantajlistesi-total01 = 0 AND
       puantajlistesi-total02 = 0 AND
       puantajlistesi-total03 = 0 AND
       puantajlistesi-total04 = 0 AND
       puantajlistesi-total05 = 0 AND
       puantajlistesi-total06 = 0 AND
       puantajlistesi-total07 = 0 AND
       puantajlistesi-total08 = 0 AND
       puantajlistesi-total09 = 0 AND
       puantajlistesi-total10 = 0 AND
       puantajlistesi-total11 = 0 AND
       puantajlistesi-total12 = 0 AND
       puantajlistesi-total13 = 0 AND
       puantajlistesi-total14 = 0 AND
       puantajlistesi-total15 = 0 AND
       puantajlistesi-total16 = 0 AND
       puantajlistesi-total17 = 0 AND
       puantajlistesi-total18 = 0 AND
       puantajlistesi-total19 = 0.
      DELETE puantajlistesi.
    ENDIF.
  ENDLOOP.
ENDFORM.                               " CIKART
*&---------------------------------------------------------------------*
*&      Form  CALC_ANZHL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM calc_abrtg USING iv_pernr iv_begda iv_endda iv_awart
                CHANGING ev_abrtg .

  DATA: p_m0000            TYPE TABLE OF p0000,
        p_m0001            TYPE TABLE OF p0001,
        p_m0002            TYPE TABLE OF p0002,
        p_m0007            TYPE TABLE OF p0007,
*        p_m9917 TYPE TABLE OF p9917,
        p_m2001            TYPE TABLE OF p2001,
        p_m2002            TYPE TABLE OF p2002,
        p_m2003            TYPE TABLE OF p2003,
        p_times_per_day    TYPE TABLE OF ptm_times_per_day,
        p_holiday          TYPE TABLE OF holiday,
        error_wo_exception TYPE c,
        p_beguz            TYPE p2001-beguz,
        p_enduz            TYPE p2001-enduz,
        p_kaltg            TYPE p2001-kaltg,
        p_stdaz            TYPE p2001-stdaz,
        p_abwtg            TYPE p2001-abwtg,
        p_abrtg            TYPE p2001-abrtg,
        p_abrst            TYPE p2001-abrst,
        p_hrsif            TYPE p2001-hrsif,
        p_alldf            TYPE p2001-hrsif,
        p_vtken            TYPE p2001-vtken,
        p_holiday_filled,
        p_breaks           TYPE hrtim_att_breaks, "YMMPH0K000026
        p_resubrc          TYPE sy-subrc.

  CHECK: iv_pernr IS NOT INITIAL,
         iv_begda IS NOT INITIAL,
         iv_endda IS NOT INITIAL.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m0000
                FROM pa0000 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m0001
                FROM pa0001 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m0002
                FROM pa0002 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m0007
                FROM pa0007 WHERE pernr EQ iv_pernr.
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m9917
*                FROM pa9917 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m2001
                FROM pa2001 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m2002
                FROM pa2002 WHERE pernr EQ iv_pernr.
  SELECT * INTO CORRESPONDING FIELDS OF TABLE p_m2003
                FROM pa2003 WHERE pernr EQ iv_pernr.

* Verarbeitung in FuBa rufen
  CALL FUNCTION 'HR_ABS_ATT_TIMES_AT_ENTRY'
    EXPORTING
      pernr              = iv_pernr
      awart              = iv_awart
      begda              = iv_begda
      endda              = iv_endda
    IMPORTING
      abwtg              = p_abwtg
      abrtg              = p_abrtg
      abrst              = p_abrst
      kaltg              = p_kaltg
      hrsif              = p_hrsif
      alldf              = p_alldf
      error_wo_exception = error_wo_exception
    TABLES
      m0000              = p_m0000
      m0001              = p_m0001
      m0002              = p_m0002
      m0007              = p_m0007
      m2001              = p_m2001
      m2002              = p_m2002
      m2003              = p_m2003
      times_per_day      = p_times_per_day
    CHANGING
      beguz              = p_beguz
      enduz              = p_enduz
      vtken              = p_vtken
      stdaz              = p_stdaz
      breaks             = p_breaks    "YMMPH0K000026
    EXCEPTIONS
      it0001_missing     = 1
      customizing_error  = 2
      error_occurred     = 3                        "YAYP40K054237
      end_before_begin   = 4.                       "YAYP40K054237
*           others            = 5.
* Nur gewisse Exceptions werden angenommen und führen zur Ausgabe
* einer Fehlermeldung. Der Rest führt zum Abbruch (->Systemfehler).

  IF r_abrtg NE space.
    ev_abrtg = p_abrtg.
  ELSEIF r_kaltg NE space.
    ev_abrtg = p_kaltg.
  ENDIF.

*  iv_izingunu = iv_endda - iv_begda.

ENDFORM.                    " CALC_ANZHL
