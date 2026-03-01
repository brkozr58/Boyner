*&---------------------------------------------------------------------*
*& Report ZBYHR_P008
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p008.

*--Tables and infotypes that will be filled
TYPE-POOLS : slis , icon , kkblo .

TABLES: pernr, pcl1, pcl2,
        s001.

INFOTYPES: 0000,0001,0002,0006,0009,0014,0021,0022,0105,0769,0770.

DATA: grid2             TYPE REF TO cl_gui_alv_grid,
      custom_container2 TYPE REF TO cl_gui_custom_container.
*--Data definitions
DATA : gt_t001    LIKE t001  OCCURS 0 WITH HEADER LINE, " Şirket
       gt_t500p   LIKE t500p OCCURS 0 WITH HEADER LINE, " Personel Alanı
       gt_t001p   LIKE t001p OCCURS 0 WITH HEADER LINE,
       " Personel Alt Aln
       gt_t501t   LIKE t501t OCCURS 0 WITH HEADER LINE, " Çalışan grubu
       gt_t503t   LIKE t503t OCCURS 0 WITH HEADER LINE,
       " Çalışan alt grb
       gt_t512t   LIKE t512t OCCURS 0 WITH HEADER LINE,
       gt_t542t   LIKE t542t OCCURS 0 WITH HEADER LINE,
       gt_t7trg01 LIKE t7trg01 OCCURS 0 WITH HEADER LINE.

*---Ana Liste
DATA: BEGIN OF gt_out OCCURS 50,
        mark ,
        bukrs     LIKE p0001-bukrs,
        kostl     LIKE p0001-kostl,
        ktext     LIKE cskt-ktext,
        ansvh     LIKE p0001-ansvh,
        atx       LIKE t542t-atx,
        massn     LIKE p0000-massn,
        mntxt     LIKE t529t-mntxt,
        massg     LIKE p0000-massg,
        mgtxt     LIKE t530t-mgtxt,
        btrtl     LIKE p0001-btrtl,
        btext     LIKE t001p-btext,
        unvan     LIKE t513s-stltx,
        birim     LIKE t527x-orgtx,
        werks     LIKE p0001-werks,
        wtext     LIKE t500p-name1,
        cagrp     LIKE t501t-ptext,
        caagr     LIKE t503t-ptext,
        abkrs     LIKE t549t-atext,
        mstbr     LIKE p0001-mstbr,
*---Esas Alanlar
        tsino     LIKE t7trg01-tsino, "İşyeri Tic.Sicil No
        taxno     LIKE t7trg01-taxno, "Vergi Numarası
        taxne     LIKE t7trg01-taxne, "Vergi Dairesi
        sskno	    LIKE hrp1000-stext, "İşyeri SGK no
        sskno1    LIKE hrp1000-stext, "İşyeri SGK no
        merni     LIKE pa0770-merni,  "TC Kimlik no
        iban      LIKE pa0009-iban,   "Banka Hesap IBAN
        vorna     LIKE pa0002-vorna,  "Adı
        nachn     LIKE pa0002-nachn,  "Soyadı
        ename     LIKE p0001-ename,   "Adı Soyadı
        kptut     LIKE pc207-betrg,   "Katkı Payı Tutar
        sskma     LIKE pc207-betrg,   "SSK matrahı
        kptutc    LIKE hrp1000-short, "
        kporn     LIKE pc207-anzhl,   "Katkı Payı Oran
        hire      LIKE p0000-begda,
        fire      LIKE p0000-endda,
        hirec     LIKE p0001-kostl,
        firec     LIKE p0001-kostl,
        cadur     LIKE hrp1000-short, "Çalışma Durumu
        cadurtx   LIKE hrp1000-stext, "Çalışma Durumu
        odetp     LIKE hrp1000-short, "Ödeme Tipi 01:Katkı Payı
        ay        LIKE bseg-stekz,  " Dönem Ay
        yil       LIKE bseg-gjahr,  " Dönem Yıl
        fpper     LIKE s001-spmon,
        fpperc    LIKE hrp1000-short, "Dönem Ay/Yıl
        cfpper    LIKE hrp1000-short, "Dönem Yıl/Ay
        fpperd    LIKE hrp1000-short, "Dönem Gün/Ay/Yıl
        odetr     LIKE pa0000-begda, "Ücret Ödeme Tarihi
        odetrc    LIKE hrp1000-short, "Ücret Ödeme Tarihi
        tahtr     LIKE pa0000-begda, "Tahsilat Tarihi
        tahtrc    LIKE hrp1000-short, "Tahsilat Tarihi
        pernr     LIKE p0001-pernr,
        persskno  LIKE pa0769-sskno,
        kimliktip LIKE pa0002-vorna, "Kimlik Tipi
        idcno     LIKE pa0770-idcno, "Nufus Cüzdanı Seri No
        gbdat     LIKE pa0002-gbdat, "Doğum Tarihi
        gbdatc    LIKE hrp1000-short, "Doğum Tarihi / lı
        fater     LIKE pa0770-fater, "Baba Adı
*        city  LIKE pa0006-ort01,                            "Adres 1
        citytx    LIKE pa0006-ort01,                          "Adres 1
        "zzpergrp LIKE p0001-zzpergrp,
        "zpergruptx LIKE zzpergr-zpergruptx,
        meslek    LIKE hrp1000-stext,
        ssksb     LIKE t7trg01-ssksb, "SGK Müdürlüğü
        sstxt     LIKE t7trs01-sstxt, "Statü:Normal,SGDP,Engelli
        bos1      LIKE hrp1000-stext,
        bos2      LIKE hrp1000-stext,
        bos3      LIKE hrp1000-stext,
        bos4      LIKE hrp1000-stext,
        butxt     LIKE t001-butxt,
        pozisyon  LIKE t528t-plstx,
        say       LIKE bseg-peinh,
        color(4),
      END OF gt_out.



* Global structure of list
DATA: gv_subrc            LIKE sy-subrc,
      gv_fgbdt            TYPE datum,
      gv_endda            TYPE datum,
      gt_events           TYPE slis_t_event,
      gs_top,
      gv_repid            LIKE sy-repid,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      gs_layout           TYPE slis_layout_alv,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      h_repid             LIKE sy-repid,
      gs_variant          LIKE disvariant,
      gt_list_top_of_page TYPE slis_t_listheader,
      gs_pa0000           TYPE pa0000,
      gs_pa0001           TYPE pa0001.

DATA: h_hire LIKE p0001-begda,
      h_fire LIKE h_hire.
DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.

DATA  : gt_fieldcat TYPE slis_t_fieldcat_alv  .
*---Data Definitions
DATA: gv_val LIKE dd07v-domvalue_l,
      gv_txt LIKE dd07v-ddtext.


* Events used by ALV Function
CONSTANTS: gc_top_of_page   TYPE slis_formname VALUE 'TOP_OF_PAGE_ALV',
           gc_user_command  TYPE slis_formname VALUE 'USER_COMMAND_ALV',
           gc_pf_status_set TYPE slis_formname VALUE 'STATUS_SET_ALV'.

*-----------------------------  INCLUDES ------------------------------*
INCLUDE rpc2cd09.
INCLUDE rpc2rx19.           " PCL2-Data Cluster RG general
INCLUDE pc2rxtr0.           " PCL2-Data Cluster RG Turkey
INCLUDE rpc2rx02.           " PCL2-Data Cluster RG common with Cl. B2
INCLUDE rpppxd00.           "Data definition buffer *PCL1/PCL2
INCLUDE rpppxd10.           "Common part buffer PCL1/PCL2
INCLUDE rpppxm00.           "Buffer handling routine


*-------------------------- Selection Screen --------------------------*

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: odetp   TYPE zbyhr_de007 DEFAULT '01',
              odetr   LIKE pa0000-begda DEFAULT sy-datum,
              tahtr   LIKE pa0000-begda DEFAULT sy-datum,
              dogum   LIKE pa0000-begda DEFAULT '19720101',
              cadur   TYPE zbyhr_de008 DEFAULT '01',
              c_dtda  AS CHECKBOX, "Doğum Tarihini Dikkate Alma
              bescont AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK block3.
*---select-options
SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-t03.
  PARAMETERS: p_fpper LIKE s001-spmon OBLIGATORY.
  PARAMETERS: orgtay AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: r_tum    RADIOBUTTON GROUP gr1,
              r_gircik RADIOBUTTON GROUP gr1,
              r_giris  RADIOBUTTON GROUP gr1,
              r_cikis  RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: tutdec AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK block4.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001     .

  PARAMETERS: p_varnt LIKE disvariant-variant.

SELECTION-SCREEN END OF BLOCK block1.
*---
INITIALIZATION.

  PERFORM initialization.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varnt.
  PERFORM variant_f4 USING p_varnt.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpper.
  PERFORM f4_popup_for_period.

AT SELECTION-SCREEN OUTPUT.
*  IF gv_first EQ 'X'.
*    pnptimr1 = 'X'.
*    pnptimr6 = space.
*    CLEAR gv_first.
*  ENDIF.


START-OF-SELECTION.
  PERFORM initial_condition.
  PERFORM fill_text.
  pnp_sw_skip_pernr = 'N'.
*  gv_endda = pnpendda + 1.
  rp-set-data-interval p0001 pnpbegda pnpendda.


GET pernr.
  CLEAR: h_hire, h_fire.
  PERFORM hire_fire USING pn-begda pn-endda
                          h_hire h_fire.
  PERFORM get_personal_info.


END-OF-SELECTION.
  LOOP AT gt_out.
    gt_out-say = 1.

    MODIFY gt_out.
  ENDLOOP.

  SORT gt_out BY pernr sskno.

  gs_top = '1'.

  PERFORM list_display USING 'GT_OUT' .


*&---------------------------------------------------------------------*
*&      Form  initial_condition
*&---------------------------------------------------------------------*
FORM initial_condition.
  CONCATENATE p_fpper '01' INTO pnpbegda.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = pnpbegda
    IMPORTING
      last_day_of_month = pnpendda.
  pn-begps = pnpbegps = pn-begda = pnpbegda .
  pn-endps = pnpendps = pn-endda = pnpendda .

* Set Only Active Personel
  MOVE : 'I'   TO  pnpstat2-sign   ,
         'NE'  TO  pnpstat2-option ,
         '0'   TO  pnpstat2-low    .
  APPEND pnpstat2.
*-
*  rp-set-data-interval 'P0000' pn-begda pn-endda.
*  rp-set-data-interval 'P0001' pn-begda pn-endda.

  gv_fgbdt = sy-datum - 6575.


  gs_variant-report	= sy-cprog.
  gs_variant-variant = p_varnt.
  gs_variant-dependvars	=	'S'.
ENDFORM.                    "initial_condition

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

* PF-STATUS
  READ TABLE gt_events WITH KEY name =  slis_ev_pf_status_set
                           INTO ls_event.
  lv_index = sy-tabix.
  IF sy-subrc = 0.
    DELETE gt_events INDEX lv_index .
    MOVE gc_pf_status_set TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.

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
  DATA: lv_text(30), lv_no_out, lv_no_outc.

  IF tutdec NE space.
    lv_no_out = 'X'.
    CLEAR lv_no_outc.
  ELSE.
    lv_no_outc = 'X'.
    CLEAR lv_no_out.
  ENDIF.

  PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:


                       'POZISYON'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Pozisyon',

                       'KOSTL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'ENAME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ad Soyad',

                       'SAY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kişi Sayısı',

*                       'SAY/SSKSB/SSTXT/SIUNV/NAKIL/POZISYON'
                       'SSKSB/SSTXT/SIUNV/NAKIL/POZISYON'
                       'NO_OUT'
                       'X',

                       lv_text
                       'NO_OUT'
                       'X',

                       'KPTUT'
                       'NO_OUT'
                       lv_no_out,

                       'KPTUTC'
                       'NO_OUT'
                       lv_no_outc,

*                       'POZISYON'
*                       'NO_OUT'
*                       'X',

                       'MSTBR/BOS1/BOS2/BOS3/BOS4'
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

                       'UNVAN'
                       'NO_OUT'
                       'X',

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

*                       'ENAME'
*                       'NO_OUT'
*                       lv_no_out,
*
                       'BUKRS/WERKS/BTRTL/MASSN/MASSG/KOSTL'
                       'NO_OUT'
                       'X',

                       'KTEXT/MNTXT/MGTXT/BTEXT'
                       'NO_OUT'
                       'X',

                       'SAYI/SIUNV/CITY'
                       'NO_OUT'
                       'X',

                       'ANRED/BIRIM/CAGRP/CAAGR/ABKRS/MSTBR'
                       'NO_OUT'
                       'X',

                       'ANSVH/ATX/WTEXT/BUTXT/ZPERGRUPTX/GBDATC'
                       'NO_OUT'
                       'X',

                       'PERNR/PERSSKNO/KIMLIKTIP/IDCNO/GBDAT/FATER/CITY'
                       'NO_OUT'
                       'X',

                       'CITYTX/ZZPERGRP/ZZPERGRPTX/MESLEK/SSKSB/SSTXT'
                       'NO_OUT'
                       'X',

                       'POZISYON/BUTXT'
                       'NO_OUT'
                       'X',

                       'BOS1'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Boş1',

                       'BOS2'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Boş2',

                       'BOS3'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Boş3',

                       'BOS4'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Boş4',

                       'COCUK'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'ÇocukSayısı',

                       'COCUK18'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '18BüyükÇocukSayısı',

                       'TOPLAM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Toplam',

                       'CINS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Cinsiyet',

                       'BET01'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Saat Ücreti',

                       'SSKSB'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK Müdürlüğü',

                       'SIUNV'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Şirket Ünvanı',

                       'SSKNO/SSKNO1'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşyeri Sicil No',

                       'DBTSS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Dönemde Bildirilecek Toplam Sigortalı Sayısı',

                       'PERNR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SAP NO',

                       'MERNİ'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'TC Kimlik no',

                       'SSTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Statü',

                       'NAKIL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Nakil Olup Olmadığı',

                       'HIREC'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'GirişTrCHAR',

                       'KTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'KTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'HIRE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Giriş Tarihi',

                       'HIRE'
                       'SELTEXT_S'
                       'GirişTarih',

                       'FIREC'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'ÇıkışTrCHAR',

                       'FIRE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'ÇıkışTarihi',

                       'FIRE'
                       'SELTEXT_S'
                       'ÇıkışTarih',

                       'BUTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Şirket Ünvanı',

                       'FIRE'
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

                       'ODEMEGUN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'M.Ödeme Günü',

                       'CITY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adrİl',

                       'CITYTX'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adres İl',

                       'DISTRICT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adres İlçe',

                       'ADRESS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adres',

                       'PHONEGSM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Cep Telefonu',

                       'EMAIL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'E-mail',

                       'IBAN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'IBAN',

                       'ISFAIZSIZ'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'FonFaizsiz',

                       'MESLEK'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Meslek',

                       'OGRENIMDURUM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öğrenim Durumu',

                       'ANAKIZLIKSOYAD'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Anne Kızlık Soyadı',

                       'DIGERULKEKODU'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Diğer Ülke kodu',

                       'DAMGA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Damga',


                       'UYRUK'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Uyruk',

                       'PERSSKNO'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK no',

                       'ADRESSULKE '
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adres Ülke',

                       'VERGIULKE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Vergi Ülke',

                       'KIMLIKTIP'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kimlik Tipi',

                       'KPTUT/KPTUTC'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Katkı Payı Tutar',

                       'KPORN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Katkı Payı Oran',

                       'CADUR/CADURTX'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Çalışma Durumu',

                       'ODETP'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ödeme Tipi',

                       'AY '
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ay',

                       'YIL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Yıl',

                       'FPPER'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Dönem',

                       'FPPER/FPPERC/CFPPER/FPPERD'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Dönem/',

                       'ODETR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ödeme Tarihi',

                       'TAHTR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Tahsilat Tarihi',

                       'ODETRC'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ödeme Tarihi/',

                       'TAHTRC'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Tahsilat Tarihi/',

                       'SSKMA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SSK Matrahı',

                       ''
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '',

                       'ENDDA'
                       'EDIT'
                       '',

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
        lv_datum1(10)                ,
        lv_num(5)     TYPE n.

  IF sy-ucomm EQ '&F03'.
    gs_top = gs_top - 1.
  ENDIF.

  CLEAR: gt_list_top_of_page[], gt_list_top_of_page, ls_line.
  ls_line-typ  = 'H'.

  ls_line-info = 'BES Tahsilat Listesi'.
  APPEND ls_line TO gt_list_top_of_page.
  DESCRIBE TABLE gt_out LINES lv_num.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  WRITE : pn-begda TO lv_datum DD/MM/YYYY.
  WRITE : pn-endda TO lv_datum1 DD/MM/YYYY.
  CONCATENATE 'Dönem:' lv_datum '-' lv_datum1
                INTO ls_line-info SEPARATED BY space .
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

  DATA : lt_seltab       LIKE rsparams OCCURS 1 WITH HEADER LINE,
         lv_upd,
         lv_popuptxt(50).

  CASE ip_ucomm.
* Pick
    WHEN '&IC1'  .
      IF gs_top = '1'.
        PERFORM pick_selection USING ip_selfield .
      ENDIF.

    WHEN 'DETAY' .

    WHEN OTHERS .
      .
  ENDCASE.
  ip_selfield-refresh    = 'X'.
  ip_selfield-col_stable = 'X'.
  ip_selfield-row_stable = 'X'.
ENDFORM.                    "USER_COMMAND_ALV

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

  SELECT * FROM t7trg01 INTO TABLE gt_t7trg01 WHERE begda LE pn-endda
                                              AND   endda GE pn-begda.
  SORT gt_t7trg01 BY werks btrtl.

ENDFORM.                    " fill_TEXT
*&---------------------------------------------------------------------*
*&      Form  GET_PERSONAL_INFO
*&---------------------------------------------------------------------*
FORM get_personal_info .
  DATA: BEGIN OF lt_wb OCCURS 2,
          werks  LIKE t7trg01-werks,
          btrtl  LIKE t7trg01-btrtl,
          sskno	 LIKE hrp1000-stext, "t7trg01-sskno,
          begda  TYPE p0001-begda,
          endda  TYPE p0001-endda,
          begda1 TYPE p0001-begda,
          endda1 TYPE p0001-endda,
          city   LIKE t7trg01-city, "Şehir
          ssksb  LIKE t7trg01-ssksb, "SGK Müdürlüğü
          siunv  TYPE t7trg01-banka,
          taxno  TYPE t7trg01-taxno,   "İşyeri Vergi Numarası
          taxne  TYPE t7trg01-taxne,   "İşyeri Vergi Dairesi Adı
          tsino  LIKE t7trg01-tsino, "İşyeri Tic.Sicil No
        END OF lt_wb,
        ls_wb   LIKE lt_wb,
        lv_fire TYPE datum.

  rp_provide_from_last p0014 '2500' pn-begda pn-endda.
  IF bescont NE space.
    IF p0014-lgart EQ '2500'.
      EXIT.
    ENDIF.
  ELSE.
    CHECK p0014-lgart IS NOT INITIAL.
  ENDIF.

*--Fetch data
  rp_provide_from_last p0000 space pn-begda pn-endda.

  gt_out-hire = h_hire.
  LOOP AT p0000 WHERE ( massn EQ '01'
*                OR (  massn EQ '02'
*                AND   massg EQ '14' )
                OR    massn EQ '12'
                OR    massn EQ '19' )
                AND   begda LE pn-endda.
  ENDLOOP.
  IF sy-subrc EQ 0.
    IF p0000-begda GT h_hire.
      gt_out-hire = p0000-begda.
    ENDIF.
  ENDIF.
*  ENDIF.
  IF h_fire BETWEEN pn-begda AND pn-endda.
    gt_out-fire = h_fire.
    rp-provide-from-last p0000 space gt_out-fire pn-endda.
  ENDIF.
  IF h_fire EQ '00000000'.
    h_fire = '99991231'.
  ENDIF.

*---Dönem içi hiç çalışmadıysa tespit et
  CHECK: gt_out-hire LE pn-endda,
         h_fire GE pn-begda.

  MOVE pernr-pernr TO cd-key-pernr.
  rp-imp-c2-cd.
  CHECK: rp-imp-cd-subrc EQ 0.

  CLEAR: lt_wb[], lt_wb, ls_wb.


  LOOP AT p0001 WHERE begda LE pn-endda
                AND   endda GE pn-begda
                AND   endda LE h_fire
                AND   bukrs IN pnpbukrs
                AND   persg IN pnppersg
                AND   persk IN pnppersk
                AND   kostl IN pnpkostl
                AND   abkrs IN pnpabkrs
                AND   werks IN pnpwerks
                AND   btrtl IN pnpbtrtl.
*                AND   plans NE '99999999'.
    READ TABLE gt_t7trg01 WITH KEY werks = p0001-werks
                                   btrtl = p0001-btrtl
                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE: gt_t7trg01-city TO lt_wb-city,
            gt_t7trg01-ssksb TO lt_wb-ssksb,
            gt_t7trg01-taxno TO lt_wb-taxno,
            gt_t7trg01-taxne TO lt_wb-taxne,
*            gt_t7trg01-sskno TO lt_wb-sskno,
            gt_t7trg01-tsino TO lt_wb-tsino.

      CALL FUNCTION 'ZHR_ISYERI_SSKNO_URET'
        EXPORTING
          sskno  = gt_t7trg01-sskno
          akodu  = gt_t7trg01-akodu
        IMPORTING
          ssk_no = lt_wb-sskno.

      CONCATENATE gt_t7trg01-name1 gt_t7trg01-name2 INTO lt_wb-siunv.
      IF ls_wb-sskno = lt_wb-sskno AND
         lt_wb[] IS NOT INITIAL.
        LOOP AT lt_wb WHERE sskno = lt_wb-sskno
                      AND   begda = ls_wb-begda.
          lt_wb-endda = lt_wb-endda1 = p0001-endda.
          PERFORM set_begda_endda USING lt_wb-begda lt_wb-endda.
          MODIFY lt_wb.
        ENDLOOP.
      ELSE.
        PERFORM set_begda_endda USING lt_wb-begda lt_wb-endda.
        lt_wb-begda1 = p0001-begda.
        lt_wb-endda1 = p0001-endda.
        COLLECT lt_wb.
      ENDIF.
    ENDIF.
    ls_wb = lt_wb.
  ENDLOOP.

  IF orgtay EQ space.
    SORT lt_wb BY begda DESCENDING.
    LOOP AT lt_wb.
      IF sy-tabix NE 1.
        DELETE lt_wb.
      ENDIF.
    ENDLOOP.
  ENDIF.


*---Bordro Oku
  PERFORM read_payroll CHANGING sy-subrc.
  CHECK sy-subrc EQ 0.


  LOOP AT lt_wb.
    CLEAR gt_out.
    gt_out-pernr = pernr-pernr.
    gt_out-kimliktip = 'NÜFUS CÜZDANI'.
    gt_out-odetp = odetp.
    gt_out-ay = p_fpper+4(2).
    gt_out-yil = p_fpper+0(4).
    gt_out-fpper = p_fpper.
    CONCATENATE '01/' p_fpper+4(2) '/' p_fpper+0(4) INTO gt_out-fpperd.
    CONCATENATE p_fpper+4(2) '/' p_fpper+0(4) INTO gt_out-fpperc.
    CONCATENATE p_fpper+0(4) '/' p_fpper+4(2) INTO gt_out-cfpper.

    gt_out-odetr = odetr.
    gt_out-tahtr = tahtr.
    CONCATENATE gt_out-odetr+6(2) '/'
                gt_out-odetr+4(2) '/'
                gt_out-odetr+0(4)
                INTO gt_out-odetrc.
    CONCATENATE gt_out-tahtr+6(2) '/'
                gt_out-tahtr+4(2) '/'
                gt_out-tahtr+0(4)
                INTO gt_out-tahtrc.

    rp_provide_from_last p0000 space lt_wb-begda lt_wb-endda.
    CHECK p0000-stat2 IN pnpstat2.


    IF orgtay NE space.
*---İşe Giriş Tarihi
      IF lt_wb-begda1 BETWEEN lt_wb-begda AND lt_wb-endda.
        LOOP AT p0000 WHERE ( massn EQ '01'
                      OR    ( massn EQ '02'
                      AND     massg EQ '14' )
                      OR      massn EQ '12'
                      OR      massn EQ '19' )
                      AND     begda EQ lt_wb-begda1.
        ENDLOOP.
        IF sy-subrc EQ 0.
          gt_out-hire = lt_wb-begda1.
        ENDIF.
      ENDIF.
      LOOP AT p0000 WHERE ( massn EQ '01'
                    OR    ( massn EQ '02'
                    AND     massg EQ '14' )
                    OR      massn EQ '12'
                    OR      massn EQ '19' )
                    AND     begda LE lt_wb-endda.
      ENDLOOP.
      IF sy-subrc EQ 0.
        IF p0000-begda GT gt_out-hire.
          gt_out-hire = p0000-begda.
        ENDIF.
      ENDIF.
*---İşten Çıkış Tarihi
      IF lt_wb-endda1 BETWEEN lt_wb-begda AND lt_wb-endda.
        gt_out-fire = lt_wb-endda1.
      ENDIF.
      lv_fire = gt_out-fire + 1.
      LOOP AT p0000 WHERE ( massn EQ '10'
                  OR    ( massn EQ '02'
                  AND     massg EQ '14' )
                  OR      massn EQ '19' )
                  AND     begda EQ lv_fire.
      ENDLOOP.
      IF sy-subrc NE 0.
        CLEAR gt_out-fire.
      ENDIF.
    ELSE.
*---İşe Giriş Tarihi
      gt_out-hire = h_hire.
      LOOP AT p0000 WHERE ( massn EQ '01'
                    OR      massn EQ '12'
                    OR      massn EQ '19' )
                    AND     begda LE lt_wb-endda.
      ENDLOOP.
      IF sy-subrc EQ 0.
        IF p0000-begda GT gt_out-hire.
          gt_out-hire = p0000-begda.
        ENDIF.
      ENDIF.

*---İşten Çıkış Tarihi
      gt_out-fire = h_fire.
      lv_fire = lt_wb-endda + 1.
      LOOP AT p0000 WHERE ( massn EQ '10'
                    OR      massn EQ '19' )
                    AND     begda LE lv_fire.
      ENDLOOP.
      IF sy-subrc EQ 0.
        gt_out-fire = p0000-begda - 1.
      ENDIF.
    ENDIF.

    IF gt_out-fire BETWEEN pn-begda AND pn-endda.
    ELSE.
      CLEAR gt_out-fire.
    ENDIF.

    IF gt_out-hire NE '00000000'.
      CONCATENATE gt_out-hire+6(2) '/'
                  gt_out-hire+4(2) '/'
                  gt_out-hire+0(4)
                  INTO gt_out-hirec.
    ENDIF.
    IF gt_out-fire NE '00000000'.
      CONCATENATE gt_out-fire+6(2) '/'
                  gt_out-fire+4(2) '/'
                  gt_out-fire+0(4)
                  INTO gt_out-firec.
    ENDIF.

    rp_provide_from_last p0001 space lt_wb-begda lt_wb-endda.
    rp_provide_from_last p0002 space lt_wb-begda lt_wb-endda.
    rp_provide_from_last p0006 '1   ' lt_wb-begda lt_wb-endda.
    rp_provide_from_last p0009 space lt_wb-begda lt_wb-endda.

    rp_provide_from_last p0769 space pn-begda pn-endda.
    rp_provide_from_last p0770 '01  ' pn-begda pn-endda.
    MOVE-CORRESPONDING: lt_wb TO gt_out,
                        p0001 TO gt_out,
                        p0002 TO gt_out.
*                        p0009 TO gt_out.
    IF gt_out-gbdat NE '00000000'.
      CONCATENATE gt_out-gbdat+6(2) '/'
                  gt_out-gbdat+4(2) '/'
                  gt_out-gbdat+0(4)
                  INTO gt_out-gbdatc.
    ENDIF.
    IF c_dtda EQ space.
      CHECK gt_out-gbdat GE dogum.
    ENDIF.


    gt_out-iban = p0009-iban.

    SELECT SINGLE stext INTO gt_out-meslek FROM hrp1000
                           WHERE plvar EQ '01'
                           AND   otype EQ 'C '
                           AND   objid EQ p0001-stell
                           AND   begda LE lt_wb-endda
                           AND   endda GE lt_wb-begda
                           AND   langu EQ sy-langu.

    gt_out-fater = p0770-fater.

    MOVE: p0006-ort01  TO gt_out-citytx.  " İl


    PERFORM fill_pernr_details .


    MOVE: "lt_wb-city  TO gt_out-city,
          lt_wb-ssksb TO gt_out-ssksb,
          lt_wb-taxno TO gt_out-taxno,
          lt_wb-taxne TO gt_out-taxne,
          lt_wb-tsino TO gt_out-tsino.
*          lt_wb-sskno TO gt_out-sskno.
*          lt_wb-siunv TO gt_out-siunv.
    gt_out-sskno+0(1) = ''''.
    gt_out-sskno+1 = lt_wb-sskno.
    gt_out-sskno1 = lt_wb-sskno.
    MOVE: p0770-merni TO gt_out-merni. "TC Kimlik no
    MOVE: p0770-idcno TO gt_out-idcno. "Nüfüs Cüzdanı Seri no


*---Statü:Normal,SGDP,Engelli
    IF p0769-disab IS INITIAL.
      SELECT SINGLE sstxt INTO gt_out-sstxt FROM t7trs01
                                  WHERE sskod EQ p0769-sskod
                                  AND   ssgrp EQ p0769-ssgrp.
    ELSE.
      gt_out-sstxt = 'Engelli'.
    ENDIF.
    gt_out-persskno = p0769-sskno.


*---Bordro
    IF orgtay EQ space.
      CLEAR gv_val.
      LOOP AT wpbp.
*---
        IF wpbp-apznr EQ '00'.
          wpbp-apznr = '01'.
        ENDIF.
        LOOP AT rt WHERE lgart EQ '2500'
                   AND   apznr EQ wpbp-apznr.
          gt_out-kptut = gt_out-kptut + abs( rt-betrg ) .
          gt_out-kporn = gt_out-kporn + rt-anzhl.
        ENDLOOP.

        LOOP AT rt WHERE lgart EQ '/104'
                   AND   apznr EQ wpbp-apznr.
          gt_out-sskma = rt-betrg.
        ENDLOOP.
        ADD 1 TO gv_val.
      ENDLOOP.
*      gt_out-kporn = gt_out-kporn / gv_val.
    ELSE.
      LOOP AT wpbp WHERE begda LE lt_wb-endda
                   AND   endda GE lt_wb-begda.
*---
        IF wpbp-apznr EQ '00'.
          wpbp-apznr = '01'.
        ENDIF.
        LOOP AT rt WHERE lgart EQ '2500'
                   AND   apznr EQ wpbp-apznr.
          gt_out-kptut = gt_out-kptut + abs( rt-betrg ) .
          gt_out-kporn = gt_out-kporn + rt-anzhl.
        ENDLOOP.

        LOOP AT rt WHERE lgart EQ '/104'
                   AND   apznr EQ wpbp-apznr.
          gt_out-sskma = rt-betrg.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    WRITE gt_out-kptut TO gt_out-kptutc DECIMALS 0.


*---Çalışma Durumu
    IF gt_out-fire BETWEEN pn-begda AND pn-endda.
      gt_out-cadur = '04'. "İşten Ayrılan.
      gt_out-cadurtx = 'İşten Ayrılan'.
    ELSEIF gt_out-hire BETWEEN pn-begda AND pn-endda AND cadur EQ '01'.
      gt_out-cadur = '02'. "İşe Giren.
      gt_out-cadurtx = 'Yeni Giren'.
    ELSEIF p0014-anzhl NE 0 AND
           gt_out-kptut EQ 0.
      gt_out-cadur = '03'. "Ücretsiz İzin
      gt_out-cadurtx = 'Ücretsiz İzin'.
    ELSE.
      gt_out-cadur = '01'. "Aktif
      IF cadur EQ '01'.
        gt_out-cadurtx = 'Devam Eden'.
      ELSEIF cadur EQ '02'.
        gt_out-cadurtx = 'Aktif'.
      ENDIF.
    ENDIF.


*---Dönemde Bildirilecek Toplam Sigortalı Sayısı
    gt_out-say = 1.

    IF r_giris NE space.
      IF gt_out-hire BETWEEN pn-begda AND pn-endda.
*--Itabın içindeki metinleri oku
        PERFORM set_itab_text.
        COLLECT gt_out.
      ENDIF.
    ELSEIF r_cikis NE space.
      IF gt_out-fire BETWEEN pn-begda AND pn-endda.
*--Itabın içindeki metinleri oku
        PERFORM set_itab_text.
        COLLECT gt_out.
      ENDIF.
    ELSEIF r_gircik NE space.
      IF gt_out-fire BETWEEN pn-begda AND pn-endda OR
         gt_out-hire BETWEEN pn-begda AND pn-endda.
*--Itabın içindeki metinleri oku
        PERFORM set_itab_text.
        COLLECT gt_out.
      ENDIF.
    ELSEIF r_tum NE space.
*--Itabın içindeki metinleri oku
      PERFORM set_itab_text.
      COLLECT gt_out.
    ENDIF.

  ENDLOOP.  "LOOP AT lt_wb.

ENDFORM.                    " GET_PERSONAL_INFO


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
*&      Form  SET_ITAB_TEXT
*&---------------------------------------------------------------------*
FORM set_itab_text .
* Şirket TX
  CLEAR gt_t001.
  READ TABLE gt_t001 WITH KEY bukrs = gt_out-bukrs.
  gt_out-butxt = gt_t001-butxt.
  SELECT SINGLE ktext INTO gt_out-ktext "gt_out-ktext
                      FROM cskt
                           WHERE spras EQ sy-langu
*                           KOKRS
                           AND   kostl EQ gt_out-kostl
                           AND   datbi GE sy-datum.
* İstihdam Koşulu
  CLEAR gt_t542t.
  READ TABLE gt_t542t WITH KEY ansvh = gt_out-ansvh.
  gt_out-atx = gt_t542t-atx.


  CLEAR: gt_out-wtext.
  SELECT name1 INTO gt_out-wtext FROM t500p
    WHERE persa = p0001-werks.
  ENDSELECT.


*  MOVE gt_out-city TO gv_val.
*  CALL FUNCTION 'QC04_DOMAIN_TEXT_GET'
*    EXPORTING
*      i_domain_name = 'PTR_CITY'
*      i_language    = sy-langu
*      i_domvalue_l  = gv_val
*    IMPORTING
*      e_ddtext      = gv_txt
*    EXCEPTIONS
*      no_data_found = 1
*      OTHERS        = 2.
*  IF sy-subrc EQ 0.
*    MOVE gv_txt TO gt_out-citytx.
*  ENDIF.

*  IF meslek NE space.
*    gt_out-meslek = 'Diğer'.
*  ENDIF.

ENDFORM.                    " SET_ITAB_TEXT

*&---------------------------------------------------------------------*
*&      Form  variant_f4
*&---------------------------------------------------------------------*
FORM variant_f4 USING p_varnt.

  DATA: ls_variant TYPE disvariant.
  DATA: lt_fcat TYPE lvc_t_fcat.
  DATA: ls_layout TYPE slis_layout_alv.

  DATA: l_exit.
  ls_variant-report = sy-cprog.

  CALL FUNCTION 'LVC_VARIANT_SELECT'
    EXPORTING
      i_dialog            = 'X'
      i_default           = ' '
      i_user_specific     = ' '
      it_default_fieldcat = lt_fcat[]
    IMPORTING
      e_exit              = l_exit
      et_fieldcat         = lt_fcat[]
    CHANGING
      cs_variant          = ls_variant
    EXCEPTIONS
      wrong_input         = 1
      fc_not_complete     = 2
      not_found           = 3
      program_error       = 4
      data_missing        = 5
      OTHERS              = 6.
  IF sy-subrc NE 0.
    CALL FUNCTION 'LVC_VARIANT_SELECT'
      EXPORTING
        i_dialog            = 'X'
        i_default           = ' '
        i_user_specific     = 'X'
        it_default_fieldcat = lt_fcat[]
      IMPORTING
        e_exit              = l_exit
        et_fieldcat         = lt_fcat[]
      CHANGING
        cs_variant          = ls_variant
      EXCEPTIONS
        wrong_input         = 1
        fc_not_complete     = 2
        not_found           = 3
        program_error       = 4
        data_missing        = 5
        OTHERS              = 6.

  ENDIF.

  IF l_exit EQ space AND sy-subrc EQ 0.
    gs_variant = ls_variant.
    p_varnt = gs_variant-variant.
  ENDIF.
ENDFORM.                    " variant_f4
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
FORM initialization .

*  pnppersg-sign = 'I'.
*  pnppersg-option = 'BT'.
*  pnppersg-low = '1'.
*  pnppersg-high = '2'.
*  APPEND pnppersg.

  pnpabkrs-sign = 'E'.
  pnpabkrs-option = 'EQ'.
  pnpabkrs-low = '97'.
  APPEND pnpabkrs.
  CLEAR pnpabkrs.

  pnpabkrs-sign = 'E'.
  pnpabkrs-option = 'EQ'.
  pnpabkrs-low = '98'.
  APPEND pnpabkrs.
  CLEAR pnpabkrs.

  pnpstat2-sign = 'I'.
  pnpstat2-option = 'EQ'.
  pnpstat2-low = '3'.
  APPEND pnpstat2.
  CLEAR pnpstat2.

  pnptimr1 = 'X'.
  pnptimr6 = space.
*  pn-begda = pn-endda = sy-datum.

  h_repid = sy-repid.
  PERFORM list_initialization(zby_gen_alv_list) USING h_repid.

  p_fpper = sy-datum+0(6).

ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  fill_pernr_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_pernr_details .

  CLEAR: gt_out-pozisyon.
  SELECT plstx INTO gt_out-pozisyon FROM t528t
    WHERE plans = p0001-plans.
  ENDSELECT.

  CLEAR: gt_out-unvan.
  SELECT stltx INTO gt_out-unvan FROM t513s
    WHERE stell = p0001-stell.
  ENDSELECT.

  CLEAR: gt_out-birim.
  SELECT orgtx INTO gt_out-birim FROM t527x
    WHERE orgeh = p0001-orgeh.
  ENDSELECT.

  CLEAR: gt_out-cagrp.
  SELECT ptext INTO gt_out-cagrp FROM t501t
    WHERE persg = p0001-persg.
  ENDSELECT.

  CLEAR: gt_out-caagr.
  SELECT ptext INTO gt_out-caagr FROM t503t
    WHERE persk = p0001-persk.
  ENDSELECT.

  CLEAR: gt_out-abkrs.
  SELECT atext INTO gt_out-abkrs FROM t549t
    WHERE abkrs = p0001-abkrs
    AND   sprsl = sy-langu.
  ENDSELECT.

  CLEAR: gt_out-wtext.
  SELECT name1 INTO gt_out-wtext FROM t500p
    WHERE persa = p0001-werks.
  ENDSELECT.
  gt_out-wtext = gt_out-wtext.

  CLEAR: gt_out-btext.
  SELECT btext INTO gt_out-btext FROM t001p
    WHERE werks = p0001-werks
    AND   btrtl = p0001-btrtl.
  ENDSELECT.
  gt_out-btext = gt_out-btext.

  CLEAR: gt_out-mntxt.
  SELECT  mntxt INTO gt_out-mntxt FROM t529t
    WHERE massn = gt_out-massn.
  ENDSELECT.

  CLEAR: gt_out-mgtxt.
  SELECT  mgtxt INTO gt_out-mgtxt FROM t530t
    WHERE  massn = gt_out-massn
    AND   massg = gt_out-massg.
  ENDSELECT.


ENDFORM.                    " fill_pernr_details
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
*&      Form  nakil_olup_olmadigi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM nakil_olup_olmadigi USING iv_begda iv_endda
                               iv_werks iv_btrtl.
*  DATA: lv_endda TYPE endda.
*
*
**---Nakil Olup Olmadığı
**---Giriş Transfer (intergroup)
*  LOOP AT p0000 WHERE begda LE iv_endda
*                AND   begda GE iv_begda
*                AND ( massn EQ '19'
*                OR    massn EQ '02'
*                AND   massg EQ '18' )
*                .
*    gt_out-hire = p0000-begda.
*    gt_out-nakil = 'NAKİL'.
*  ENDLOOP.
*
*
*  lv_endda = iv_endda + 1.
*
**---Çıkış Transfer (intergroup)
*  SELECT SINGLE * INTO gs_pa0000 FROM pa0000
*                       WHERE pernr EQ pernr-pernr
*                       AND   begda EQ lv_endda
*                       AND ( massn EQ '19'
*                       OR    massn EQ '02'
*                       AND   massg EQ '18' ).
*  IF sy-subrc EQ 0.
*    gt_out-fire = gs_pa0000-begda - 1 .
*    gt_out-nakil = 'NAKİL'.
*  ELSE.
*    LOOP AT p0000 WHERE begda LE lv_endda
*                 AND   endda GE iv_begda
*                       AND ( massn EQ '19'
*                       OR    massn EQ '02'
*                       AND   massg EQ '18' ).
**                 AND   massn NE '10'
**                 AND   massn NE '19'.
*      SELECT SINGLE * INTO gs_pa0001 FROM pa0001
*                              WHERE pernr = pernr-pernr
*                              AND   begda = lv_endda.
*      IF sy-subrc EQ 0.
*        IF gs_pa0001-werks EQ iv_werks AND
*           gs_pa0001-btrtl EQ iv_btrtl.
*        ELSE.
*          gt_out-fire = p0000-begda - 1 .
*          gt_out-nakil = 'NAKİL'.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDIF.
*
*  IF gt_out-fire LT pn-begda OR
*     gt_out-fire GT pn-endda.
*    CLEAR gt_out-fire.
*  ENDIF.

ENDFORM.                    " FILL_CALISAN_SAYI
*&---------------------------------------------------------------------*
*&      Form  SET_BEGDA_ENDDA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_begda_endda USING iv_begda iv_endda.
  IF p0001-begda LT pn-begda.
    iv_begda = pn-begda.
  ELSE.
    iv_begda = p0001-begda.
  ENDIF.

  IF p0001-endda GT pn-endda.
    iv_endda = pn-endda.
  ELSE.
    iv_endda = p0001-endda.
  ENDIF.
ENDFORM.                    " SET_BEGDA_ENDDA

*&---------------------------------------------------------------------*
*&      Form  PICK_SELECTION
*&---------------------------------------------------------------------*
FORM pick_selection USING ip_selfield TYPE kkblo_selfield.

*  DATA: lv_nc(2) TYPE n,
*        lv_fpper LIKE zhr_metrik_firda-fpper,
*        lv_txt(40).
*  FIELD-SYMBOLS <fout> TYPE ANY.
*  FIELD-SYMBOLS <fitab> TYPE ANY.
*
*  gs_top = '2'.
*
*  READ TABLE gt_out INDEX ip_selfield-tabindex.
*
*  CONCATENATE 'GT_OUT-'
*              ip_selfield-fieldname
*              INTO lv_txt.
*  ASSIGN (lv_txt) TO <fout>.
*  CHECK sy-subrc EQ 0.
*

*  CLEAR: gt_sumdl,
*         gt_sumdl[].
*  LOOP AT gt_sumd WHERE btext EQ gt_out-btext.
*
*    CONCATENATE 'GT_SUMD-'
*                ip_selfield-fieldname
*                INTO lv_txt.
*    ASSIGN (lv_txt) TO <fitab>.
*    CHECK sy-subrc EQ 0.
*    CHECK <fitab> EQ 1.
*
*    APPEND gt_sumd TO gt_sumdl.
*  ENDLOOP.

*  PERFORM list_display USING 'GT_SUMDL'.

ENDFORM.                    " PICK_SELECTION
*&---------------------------------------------------------------------*
*&      Form  READ_PAYROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM read_payroll  CHANGING p_sy_subrc.
  DATA: lv_fpper2 LIKE s001-spmon.

  LOOP AT rgdir WHERE fpper EQ p_fpper
                AND   srtza = 'A'.
    rx-key-pernr = pernr-pernr.
    UNPACK rgdir-seqnr TO rx-key-seqno.
    rp-imp-c2-tr.
    CHECK:  rp-imp-tr-subrc EQ  0 .

    p_sy_subrc = 0.

  ENDLOOP.



ENDFORM.                    " READ_PAYROLL
