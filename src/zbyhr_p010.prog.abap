*&---------------------------------------------------------------------*
*& Report ZBYHR_P010
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p010.


*--Tables and infotypes that will be filled
TYPE-POOLS : slis , icon , kkblo .
TABLES:pernr .
INFOTYPES:0000,0001,2010.

DATA: grid2             TYPE REF TO cl_gui_alv_grid,
      custom_container2 TYPE REF TO cl_gui_custom_container.
*--Data definitions
DATA : gt_t001  LIKE t001  OCCURS 0 WITH HEADER LINE,
       gt_t500p LIKE t500p OCCURS 0 WITH HEADER LINE,
       gt_t001p LIKE t001p OCCURS 0 WITH HEADER LINE,
       gt_t501t LIKE t501t OCCURS 0 WITH HEADER LINE,
       gt_t503t LIKE t503t OCCURS 0 WITH HEADER LINE,
       gt_t512t LIKE t512t OCCURS 0 WITH HEADER LINE,
       gt_t542t LIKE t542t OCCURS 0 WITH HEADER LINE.


DATA: BEGIN OF gt_itab OCCURS 1,
        mark ,
        pernr    LIKE p0000-pernr,
        ename    LIKE p0001-ename,
        bukrs    LIKE p0001-bukrs,
        butxt    LIKE t001-butxt,
        kostl    LIKE p0001-kostl,
        ktext    LIKE cskt-ktext,
        ansvh    LIKE p0001-ansvh,
        atx      LIKE t542t-atx,
        oansvh   LIKE p0001-ansvh,
        oatx     LIKE t542t-atx,
        mesaj    LIKE hrp1000-stext,
        hire     LIKE p0001-begda,
        fire     LIKE p0001-endda,
        massn    LIKE p0000-massn,
        mntxt    LIKE t529t-mntxt,
        massg    LIKE p0000-massg,
        mgtxt    LIKE t530t-mgtxt,
        btrtl    LIKE p0001-btrtl,
        btext    LIKE t001p-btext,
        pozisyon LIKE t528t-plstx,
        unvan    LIKE t513s-stltx,
        birim    LIKE t527x-orgtx,
        werks    LIKE t500p-name1,
        werksn   LIKE p0001-werks,
        cagrp    LIKE t501t-ptext,
        caagr    LIKE t503t-ptext,
        abkrs    LIKE t549t-atext,
        mstbr    LIKE p0001-mstbr,
        say      LIKE bseg-peinh,
        color(4),
      END OF gt_itab.

* Global structure of list
DATA: gv_subrc            LIKE sy-subrc,
      gt_events           TYPE slis_t_event,
      gv_repid            LIKE sy-repid,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      gs_layout           TYPE slis_layout_alv,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gs_variant          LIKE disvariant,
      gt_list_top_of_page TYPE slis_t_listheader.

DATA: h_hire LIKE p0001-begda,
      h_fire LIKE h_hire.
DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.

DATA  : gt_fieldcat TYPE slis_t_fieldcat_alv  .

* Events used by ALV Function
CONSTANTS:gc_top_of_page   TYPE slis_formname VALUE 'TOP_OF_PAGE_ALV',
         gc_user_command  TYPE slis_formname VALUE 'USER_COMMAND_ALV',
         gc_pf_status_set TYPE slis_formname VALUE 'STATUS_SET_ALV'.


*-------------------------- Selection Screen --------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001     .

  PARAMETERS: p_varnt LIKE disvariant-variant.

SELECTION-SCREEN END OF BLOCK block1                                 .
*---
INITIALIZATION.
  PERFORM initialization.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_varnt.
  PERFORM variant_f4 USING p_varnt.

START-OF-SELECTION.
  PERFORM initial_condition.
  PERFORM fill_text.


GET pernr.
  CLEAR: h_hire, h_fire.
  PERFORM hire_fire USING pn-begda pn-endda
                          h_hire h_fire.
  PERFORM get_personal_info.

END-OF-SELECTION.
  PERFORM list_display USING 'GT_ITAB' .


*&---------------------------------------------------------------------*
*&      Form  initial_condition
*&---------------------------------------------------------------------*
FORM initial_condition.
  pn-begps = pnpbegps = pnpbegda = pn-begda.
  pn-endps = pnpendps = pnpendda = pn-endda.

* Set Only Active Personel
  MOVE : 'I'   TO  pnpstat2-sign   ,
         'NE'  TO  pnpstat2-option ,
         '0'   TO  pnpstat2-low    .
  APPEND pnpstat2.
*-
  rp-set-data-interval 'P0000' pn-begda pn-endda.
  rp-set-data-interval 'P0001' pn-begda pn-endda.
*-
ENDFORM.                    "initial_condition

*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
FORM list_display  USING ip_table .
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

  LOOP AT lt_fieldcat INTO ls_fieldcat .
    CLEAR ls_fieldcat-key.
    lv_save_tabix = sy-tabix .
    CASE ls_fieldcat-fieldname .
      WHEN 'MARK' .
        ls_fieldcat-no_out = 'X' .
      WHEN 'PERNR' .
        ls_fieldcat-key = 'X' .
        ls_fieldcat-hotspot = 'X' .
      WHEN 'MESAJ' .
        ls_fieldcat-seltext_s    =
        ls_fieldcat-seltext_m    =
        ls_fieldcat-reptext_ddic =
        ls_fieldcat-seltext_l    = 'Mesaj'.
*        ls_fieldcat-emphasize    = 'C710'.
      WHEN 'OANSVH' .
        ls_fieldcat-seltext_s    =
        ls_fieldcat-seltext_m    =
        ls_fieldcat-reptext_ddic =
        ls_fieldcat-seltext_l    = 'Doğru İstihdam Koşulu'.
        ls_fieldcat-emphasize    = 'C510'.
      WHEN 'OATX' .
        ls_fieldcat-seltext_s    =
        ls_fieldcat-seltext_m    =
        ls_fieldcat-reptext_ddic =
        ls_fieldcat-seltext_l    = 'Doğru İstihdam Koşulu'.
        ls_fieldcat-emphasize    = 'C510'.
      WHEN 'ENAME'.
      WHEN OTHERS.
*        ls_fieldcat-no_out       = 'X'.

    ENDCASE .

    MODIFY lt_fieldcat FROM ls_fieldcat .
  ENDLOOP.

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

                       'POZISYON'
                       'NO_OUT'
                       'X',

                       'MSTBR'
                       'NO_OUT'
                       'X',

                       'HIRE'
                       'NO_OUT'
                       'X',

                       'FIRE'
                       'NO_OUT'
                       'X',

                       'WERKS'
                       'NO_OUT'
                       'X',

*                       'KOSTL'
*                       'NO_OUT'
*                       'X',
*
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

                       'BTRTL'
                       'NO_OUT'
                       'X',

                       'BTEXT'
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

                       'MNTXT'
                       'NO_OUT'
                       'X',

                       'WERKSN'
                       'NO_OUT'
                       'X',

                       'MGTXT'
                       'NO_OUT'
                       'X',

                       'MASSG'
                       'NO_OUT'
                       'X',

                       'BUKRS'
                       'NO_OUT'
                       'X',

                       'BUTXT'
                       'NO_OUT'
                       'X',

                       'MASSN'
                       'NO_OUT'
                       'X',

                       'ANRED'
                       'NO_OUT'
                       'X',

*                       'NEDENLTEXT'
*                       'OUTPUTLEN'
*                       '1024',
*
                       'CINS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Cinsiyet',

                       'BET01'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Saat Ücreti',

                       'BETAI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M'
                       'Aidat Tutarı',

                       'BETAI'
                       'SELTEXT_S'
                       'AidatTutar',

                       'BETAI'
                       'OUTPUTLEN'
                       '13',

                       'AIDTR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Aidat Türü',

                       'HIRE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşe Giriş Tarihi',

                       'KTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Masraf Yeri',

                       'HIRE'
                       'SELTEXT_S'
                       'GirişTarih',

                       'FIRE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşten Çıkış Tarihi',

                       'FIRE'
                       'SELTEXT_S'
                       'ÇıkışTarih',

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
FORM status_set_alv USING is_extab TYPE kkblo_t_extab.     "#EC CALLED

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
  DATA: ls_line      TYPE slis_listheader,
        lv_count     TYPE i,
        lv_str(150)                  ,
        lv_datum(10)                 ,
        lv_num(5)    TYPE n.

  DESCRIBE TABLE gt_list_top_of_page LINES lv_count .
  CHECK lv_count EQ  0 .
  CLEAR ls_line.
  ls_line-typ  = 'H'.

*  CONCATENATE  pn-begda+6(2) '.' pn-begda+4(2) '.' pn-begda+0(4) '-'
*               pn-endda+6(2) '.' pn-endda+4(2) '.' pn-endda+0(4)
*              INTO ls_line-info.
*  CONCATENATE ls_line-info 'Dönemi OFF Gün Raporu'
*    INTO ls_line-info SEPARATED BY space.

  ls_line-info = 'Şirket, Masraf Yerine göre İstihdam koşulları'.
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
  DESCRIBE TABLE gt_itab LINES lv_num.
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
      PERFORM pick_selection USING ip_selfield .
    WHEN 'DETAY' .
      CALL SCREEN 101 STARTING AT 10 5.
    WHEN OTHERS .
      .
  ENDCASE.
  ip_selfield-refresh    = 'X'.
  ip_selfield-col_stable = 'X'.
  ip_selfield-row_stable = 'X'.
ENDFORM.                    "USER_COMMAND_ALV

*&---------------------------------------------------------------------*
*&      Form  PICK_SELECTION
*&---------------------------------------------------------------------*
FORM pick_selection USING ip_selfield TYPE kkblo_selfield.
  DATA : lv_pernr LIKE pa0001-pernr .

  READ TABLE gt_itab INDEX ip_selfield-tabindex .
  lv_pernr = gt_itab-pernr .

  CHECK lv_pernr NE space .
  CASE ip_selfield-fieldname .
    WHEN 'PERNR'.
      SET PARAMETER ID 'PER' FIELD lv_pernr .
      CALL TRANSACTION 'PA30' .
  ENDCASE .

ENDFORM.                    " PICK_SELECTION


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

  SELECT * FROM t542t INTO TABLE gt_t542t WHERE molga EQ '47'
                                            AND spras EQ sy-langu.

ENDFORM.                    " fill_TEXT
*&---------------------------------------
*&---------------------------------------------------------------------*
*&      Form  GET_PERSONAL_INFO
*&---------------------------------------------------------------------*
FORM get_personal_info .

  CLEAR gt_itab.
  gt_itab-pernr = pernr-pernr.
*--Fetch data
  rp_provide_from_last p0000 space pn-begda pn-endda.
  rp_provide_from_last p0001 space pn-begda pn-endda.

  IF h_hire BETWEEN pn-begda AND pn-endda.
    gt_itab-hire = h_hire.
  ENDIF.
  IF h_fire BETWEEN pn-begda AND pn-endda.
    gt_itab-fire = h_fire.
    rp-provide-from-last p0000 space gt_itab-fire pn-endda.
  ENDIF.

  MOVE-CORRESPONDING p0001 TO gt_itab.

  SELECT SINGLE ansvh INTO gt_itab-oansvh
                      FROM zbyhr_t010
                      WHERE bukrs EQ gt_itab-bukrs
                      AND   kostl EQ gt_itab-kostl.

*--Itabın içindeki metinleri oku
  PERFORM set_itab_text.

  PERFORM fill_pernr_details .

  gt_itab-say = 1.
  APPEND gt_itab.

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
  READ TABLE gt_t001 WITH KEY bukrs = gt_itab-bukrs.
  gt_itab-butxt = gt_t001-butxt.
** Personel alanı TX
*  CLEAR gt_t500p.
*  READ TABLE gt_t500p WITH KEY persa = gt_itab-werks.
*  gt_itab-name1 = gt_t500p-name1.
** Personel alt alanı TX
*  CLEAR gt_t001p.
*  READ TABLE gt_t001p WITH KEY werks = gt_itab-werks
*                               btrtl = gt_itab-btrtl.
*  gt_itab-btext = gt_t001p-btext.
** Çalışan grubu TX
*  CLEAR gt_t501t.
*  READ TABLE gt_t501t WITH KEY persg = gt_itab-persg.
*  gt_itab-ptext = gt_t501t-ptext.
** Çalışan alt grubu TX
*  CLEAR gt_t503t.
*  READ TABLE gt_t503t WITH KEY persk = gt_itab-persk.
*  gt_itab-pktxt = gt_t503t-ptext.
  SELECT SINGLE ktext INTO gt_itab-ktext
                      FROM cskt
                           WHERE spras EQ sy-langu
*                           KOKRS
                           AND   kostl EQ gt_itab-kostl
                           AND   datbi GE sy-datum.
* İstihdam Koşulu
  CLEAR gt_t542t.
  READ TABLE gt_t542t WITH KEY ansvh = gt_itab-ansvh.
  gt_itab-atx = gt_t542t-atx.
  CLEAR gt_t542t.
  READ TABLE gt_t542t WITH KEY ansvh = gt_itab-oansvh.
  gt_itab-oatx = gt_t542t-atx.

  IF gt_itab-oansvh NE gt_itab-ansvh.
    gt_itab-mesaj = 'HATA:Farklı istihdam Koşulu'.
  ENDIF.

  IF gt_itab-oansvh IS INITIAL.
    gt_itab-mesaj = 'HATA: Tabloda Tanımlanmamış'.
  ENDIF.

  IF gt_itab-ansvh IS INITIAL.
    gt_itab-mesaj = 'BOŞ:İstihdam Koşulu Girilmemiş'.
  ENDIF.

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



ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  fill_pernr_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_pernr_details .

  CLEAR: gt_itab-pozisyon.
  SELECT plstx INTO gt_itab-pozisyon FROM t528t
    WHERE plans = p0001-plans.
  ENDSELECT.

  CLEAR: gt_itab-unvan.
  SELECT stltx INTO gt_itab-unvan FROM t513s
    WHERE stell = p0001-stell.
  ENDSELECT.

  CLEAR: gt_itab-birim.
  SELECT orgtx INTO gt_itab-birim FROM t527x
    WHERE orgeh = p0001-orgeh.
  ENDSELECT.

  CLEAR: gt_itab-cagrp.
  SELECT ptext INTO gt_itab-cagrp FROM t501t
    WHERE persg = p0001-persg.
  ENDSELECT.

  CLEAR: gt_itab-caagr.
  SELECT ptext INTO gt_itab-caagr FROM t503t
    WHERE persk = p0001-persk.
  ENDSELECT.

  CLEAR: gt_itab-abkrs.
  SELECT atext INTO gt_itab-abkrs FROM t549t
    WHERE abkrs = p0001-abkrs
    AND   sprsl = sy-langu.
  ENDSELECT.

  CLEAR: gt_itab-werks.
  SELECT name1 INTO gt_itab-werks FROM t500p
    WHERE persa = p0001-werks.
  ENDSELECT.

  CLEAR: gt_itab-btext.
  SELECT btext INTO gt_itab-btext FROM t001p
    WHERE btrtl = p0001-btrtl.
  ENDSELECT.

  CLEAR: gt_itab-mntxt.
  SELECT  mntxt INTO gt_itab-mntxt FROM t529t
    WHERE massn = gt_itab-massn.
  ENDSELECT.

  CLEAR: gt_itab-mgtxt.
  SELECT  mgtxt INTO gt_itab-mgtxt FROM t530t
    WHERE  massn = gt_itab-massn
    AND   massg = gt_itab-massg.
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
