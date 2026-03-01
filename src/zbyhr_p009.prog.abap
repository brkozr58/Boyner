*&---------------------------------------------------------------------*
*& Report ZBYHR_P009
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p009.

*---tables
TABLES: pernr,pcl1, pcl2,t001,s001,pa0014.

INFOTYPES: 0000,
           0001,
           0002,
           0027,
           0769,
           0771,
           2010.

*---TYPE-POOLS
TYPE-POOLS: slis, icon , kkblo .

*
*---Çıktı Tablosu
DATA: BEGIN OF gt_itab OCCURS 50,
        mark ,
        pernr     LIKE pernr-pernr,
        ename     LIKE p0001-ename,
        msgty     LIKE bapireturn1-type,
        durm      LIKE pa0105-usrid_long,
        ndy       LIKE pc207-betrg,
        hire      LIKE p0001-begda,
        fire      LIKE p0001-begda,
        gesch     LIKE p0002-gesch,
        gesch_txt LIKE  dd07v-ddtext,
        plans     LIKE p0001-plans,
        planst    LIKE hrp1000-stext,
        orgeh     LIKE p0001-orgeh,
        orgeht    LIKE hrp1000-stext,
        unvan     LIKE t513s-stltx,
        cagrp     LIKE t501t-ptext,
        caagr     LIKE t503t-ptext,
        abkrs     LIKE t549t-atext,
        mstbr     LIKE p0001-mstbr,
        kostl     LIKE p0001-kostl,
        ktext     LIKE cskt-ktext,
        ansvh     LIKE p0001-ansvh,
        atx       LIKE t542t-atx,
        massn     LIKE p0000-massn,
        mntxt     LIKE t529t-mntxt,
        massg     LIKE p0000-massg,
        mgtxt     LIKE t530t-mgtxt,
        bukrs     LIKE p0001-bukrs,
        butxt     LIKE t001-butxt,
        werks     LIKE p0001-werks,
        wtext     LIKE t500p-name1,
        btrtl     LIKE p0001-btrtl,
        btext     LIKE t001p-btext,
        kanun     LIKE p0769-kanun,
        borgo0    LIKE p0771-borgo0,
        borde0    LIKE p0771-borde0,
        say       LIKE bseg-peinh,
        color(4).
DATA  END OF gt_itab.

DATA: BEGIN OF gt_itab2 OCCURS 50,
        mark ,
        pernr    LIKE pernr-pernr,
        ename    LIKE p0001-ename,
        hire     LIKE p0001-begda,
        fire     LIKE p0001-begda,
        bukrs    LIKE p0001-bukrs,
        butxt    LIKE t001-butxt,
        kostl    LIKE p0001-kostl,
        ktext    LIKE cskt-ktext,
        plans    LIKE p0001-plans,
        planst   LIKE hrp1000-stext,
        orgeh    LIKE p0001-orgeh,
        orgeht   LIKE hrp1000-stext,
        ansvh    LIKE p0001-ansvh,
        atx      LIKE t542t-atx,
        begda    LIKE p2010-begda,
        ndy      LIKE p2010-anzhl,
        ndyor    LIKE p2010-anzhl,
        anzhl    LIKE p2010-anzhl,
        zeinh    LIKE p2010-zeinh,
        etext    LIKE t538t-etext,
        beg27    LIKE p0027-begda,
        end27    LIKE p0027-endda,
        pkprz    LIKE p0027-kpr01,
        kbu01    LIKE p0027-kbu01,
        kst01    LIKE p0027-kst01,
        ktt01    LIKE cskt-ltext,
        psp01    LIKE p0027-psp01,
        pst01    LIKE prps-postu,
        kpr01    LIKE p0027-kpr01,
        kbu02    LIKE p0027-kbu02,
        kst02    LIKE p0027-kst02,
        ktt02    LIKE cskt-ltext,
        psp02    LIKE p0027-psp02,
        pst02    LIKE prps-postu,
        kpr02    LIKE p0027-kpr02,
        kbu03    LIKE p0027-kbu03,
        kst03    LIKE p0027-kst03,
        ktt03    LIKE cskt-ltext,
        psp03    LIKE p0027-psp03,
        pst03    LIKE prps-postu,
        kpr03    LIKE p0027-kpr03,
        kbu04    LIKE p0027-kbu04,
        kst04    LIKE p0027-kst04,
        ktt04    LIKE cskt-ltext,
        psp04    LIKE p0027-psp04,
        pst04    LIKE prps-postu,
        kpr04    LIKE p0027-kpr04,
        kbu05    LIKE p0027-kbu05,
        kst05    LIKE p0027-kst05,
        ktt05    LIKE cskt-ltext,
        psp05    LIKE p0027-psp05,
        pst05    LIKE prps-postu,
        kpr05    LIKE p0027-kpr05,
        kbu06    LIKE p0027-kbu06,
        kst06    LIKE p0027-kst06,
        ktt06    LIKE cskt-ltext,
        psp06    LIKE p0027-psp06,
        pst06    LIKE prps-postu,
        kpr06    LIKE p0027-kpr06,
        kbu07    LIKE p0027-kbu07,
        kst07    LIKE p0027-kst07,
        ktt07    LIKE cskt-ltext,
        psp07    LIKE p0027-psp07,
        pst07    LIKE prps-postu,
        kpr07    LIKE p0027-kpr07,
        kbu08    LIKE p0027-kbu08,
        kst08    LIKE p0027-kst08,
        ktt08    LIKE cskt-ltext,
        psp08    LIKE p0027-psp08,
        pst08    LIKE prps-postu,
        kpr08    LIKE p0027-kpr08,
        kbu09    LIKE p0027-kbu09,
        kst09    LIKE p0027-kst09,
        ktt09    LIKE cskt-ltext,
        psp09    LIKE p0027-psp09,
        pst09    LIKE prps-postu,
        kpr09    LIKE p0027-kpr09,
        kbu10    LIKE p0027-kbu10,
        kst10    LIKE p0027-kst10,
        ktt10    LIKE cskt-ltext,
        psp10    LIKE p0027-psp10,
        pst10    LIKE prps-postu,
        kpr10    LIKE p0027-kpr10,
        kbu11    LIKE p0027-kbu11,
        kst11    LIKE p0027-kst11,
        ktt11    LIKE cskt-ltext,
        psp11    LIKE p0027-psp11,
        pst11    LIKE prps-postu,
        kpr11    LIKE p0027-kpr11,
        kbu12    LIKE p0027-kbu12,
        kst12    LIKE p0027-kst12,
        ktt12    LIKE cskt-ltext,
        psp12    LIKE p0027-psp12,
        pst12    LIKE prps-postu,
        kpr12    LIKE p0027-kpr12,
        kbu13    LIKE p0027-kbu13,
        kst13    LIKE p0027-kst13,
        ktt13    LIKE cskt-ltext,
        psp13    LIKE p0027-psp13,
        pst13    LIKE prps-postu,
        kpr13    LIKE p0027-kpr13,
        kbu14    LIKE p0027-kbu14,
        kst14    LIKE p0027-kst14,
        ktt14    LIKE cskt-ltext,
        psp14    LIKE p0027-psp14,
        pst14    LIKE prps-postu,
        kpr14    LIKE p0027-kpr14,
        kbu15    LIKE p0027-kbu15,
        kst15    LIKE p0027-kst15,
        ktt15    LIKE cskt-ltext,
        psp15    LIKE p0027-psp15,
        pst15    LIKE prps-postu,
        kpr15    LIKE p0027-kpr15,
        kbu16    LIKE p0027-kbu16,
        kst16    LIKE p0027-kst16,
        ktt16    LIKE cskt-ltext,
        psp16    LIKE p0027-psp16,
        pst16    LIKE prps-postu,
        kpr16    LIKE p0027-kpr16,
        kbu17    LIKE p0027-kbu17,
        kst17    LIKE p0027-kst17,
        ktt17    LIKE cskt-ltext,
        psp17    LIKE p0027-psp17,
        pst17    LIKE prps-postu,
        kpr17    LIKE p0027-kpr17,
        kbu18    LIKE p0027-kbu18,
        kst18    LIKE p0027-kst18,
        ktt18    LIKE cskt-ltext,
        psp18    LIKE p0027-psp18,
        pst18    LIKE prps-postu,
        kpr18    LIKE p0027-kpr18,
        kbu19    LIKE p0027-kbu19,
        kst19    LIKE p0027-kst19,
        ktt19    LIKE cskt-ltext,
        psp19    LIKE p0027-psp19,
        pst19    LIKE prps-postu,
        kpr19    LIKE p0027-kpr19,
        kbu20    LIKE p0027-kbu20,
        kst20    LIKE p0027-kst20,
        ktt20    LIKE cskt-ltext,
        psp20    LIKE p0027-psp20,
        pst20    LIKE prps-postu,
        kpr20    LIKE p0027-kpr20,
        kbu21    LIKE p0027-kbu21,
        kst21    LIKE p0027-kst21,
        ktt21    LIKE cskt-ltext,
        psp21    LIKE p0027-psp21,
        pst21    LIKE prps-postu,
        kpr21    LIKE p0027-kpr21,
        kbu22    LIKE p0027-kbu22,
        kst22    LIKE p0027-kst22,
        ktt22    LIKE cskt-ltext,
        psp22    LIKE p0027-psp22,
        pst22    LIKE prps-postu,
        kpr22    LIKE p0027-kpr22,
        kbu23    LIKE p0027-kbu23,
        kst23    LIKE p0027-kst23,
        ktt23    LIKE cskt-ltext,
        psp23    LIKE p0027-psp23,
        pst23    LIKE prps-postu,
        kpr23    LIKE p0027-kpr23,
        kbu24    LIKE p0027-kbu24,
        kst24    LIKE p0027-kst24,
        ktt24    LIKE cskt-ltext,
        psp24    LIKE p0027-psp24,
        pst24    LIKE prps-postu,
        kpr24    LIKE p0027-kpr24,
        kbu25    LIKE p0027-kbu25,
        kst25    LIKE p0027-kst25,
        ktt25    LIKE cskt-ltext,
        psp25    LIKE p0027-psp25,
        pst25    LIKE prps-postu,
        kpr25    LIKE p0027-kpr25,
        kanun    LIKE p0769-kanun,
        borgo0   LIKE p0771-borgo0,
        borde0   LIKE p0771-borde0,
        msgty    LIKE bapireturn1-type,
        durm     LIKE pa0105-usrid_long,
        say      LIKE bseg-peinh,
        color(4).
DATA  END OF gt_itab2.

*--Data definitions
DATA : gt_t001    LIKE t001  OCCURS 0 WITH HEADER LINE,
       gt_t500p   LIKE t500p OCCURS 0 WITH HEADER LINE,
       gt_t001p   LIKE t001p OCCURS 0 WITH HEADER LINE,
       gt_t501t   LIKE t501t OCCURS 0 WITH HEADER LINE,
       gt_t503t   LIKE t503t OCCURS 0 WITH HEADER LINE,
       gt_t512t   LIKE t512t OCCURS 0 WITH HEADER LINE,
       gt_t542t   LIKE t542t OCCURS 0 WITH HEADER LINE,
       gt_t7trg01 LIKE t7trg01 OCCURS 0 WITH HEADER LINE.
DATA : BEGIN OF gt_1000 OCCURS 0,
         otype  TYPE otype,
         objid TYPE hrobjid,
         stext TYPE stext,
       END OF gt_1000.

DATA: gs_top,
      gv_n TYPE i.

*---ALV
DATA: h_repid   LIKE sy-repid,
      h_variant LIKE disvariant,
      lt_header TYPE slis_t_listheader WITH HEADER LINE.

*---Data Definitions
DATA: gv_val LIKE dd07v-domvalue_l,
      gv_txt LIKE dd07v-ddtext.

DATA: h_hire              LIKE p0001-begda,
      h_fire              LIKE h_hire,
      h_hire_first        LIKE p0001-begda,
      gv_mobeg            LIKE p0001-begda,
      gv_repid            LIKE sy-repid,
      gv_first,
      gt_events           TYPE slis_t_event,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      gs_layout           TYPE slis_layout_alv,
      gt_sort            TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      gs_variant          LIKE disvariant,
      gt_list_top_of_page TYPE slis_t_listheader.
DATA: BEGIN OF phifi OCCURS 5.
        INCLUDE STRUCTURE phifi.
DATA: END OF phifi.
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_t_fieldcat_alv.
*** Single Domain Text ****
DATA: l_value LIKE  dd07v-domvalue_l,
      l_text  LIKE  dd07v-ddtext.
DATA: lv_i       TYPE i,
      lv_lgart   TYPE lgart,
      lv_f1(30),
      lv_f2(30),
      lv_f3(30),
      lv_f4(30),
      lv_f5(30),
      lv_f6(30),
      lv_f7(30),
      lv_f8(30),
      lv_f9(30),
      lv_f10(30),
      lv_f11(30),
      lv_f12(30),
      lv_n(2)    TYPE n,
      lv_n1(2)   TYPE n.
*

FIELD-SYMBOLS: <f1>  TYPE any,
               <f2>  TYPE any,
               <f3>  TYPE any,
               <f4>  TYPE any,
               <f5>  TYPE any,
               <f6>  TYPE any,
               <f7>  TYPE any,
*               <f8> TYPE ANY,
               <f9>  TYPE any,
*               <f10> TYPE ANY,
               <f11> TYPE any,
               <f12> TYPE any.

*---Constants for ALV
* Events used by ALV Function
CONSTANTS:gc_top_of_page  TYPE slis_formname VALUE 'TOP_OF_PAGE_ALV',
          gc_user_command TYPE slis_formname VALUE 'USER_COMMAND_ALV',
          gc_pf_status_set TYPE slis_formname VALUE 'STATUS_SET_ALV'.


*---Dinamik tablo ve çalışma alanı
FIELD-SYMBOLS: <dyn_table> TYPE STANDARD TABLE,
               <dyn_wa>,
               <tmp_table> TYPE STANDARD TABLE,
               <tmp_wa>,
               <mer_table> TYPE STANDARD TABLE,
               <mer_wa>,
               <mag_table> TYPE STANDARD TABLE,
               <mag_wa>.

*-----------------------------  INCLUDES ------------------------------*
INCLUDE rpc2cd09.
INCLUDE rpc2rx19.           " PCL2-Data Cluster RG general
INCLUDE pc2rxtr0.           " PCL2-Data Cluster RG Turkey
INCLUDE rpc2rx02.           " PCL2-Data Cluster RG common with Cl. B2
INCLUDE rpppxd00.           "Data definition buffer *PCL1/PCL2
INCLUDE rpppxd10.           "Common part buffer PCL1/PCL2
INCLUDE rpppxm00.           "Buffer handling routine


SELECT-OPTIONS psp01 FOR p0027-psp01 MATCHCODE OBJECT prpm.

PARAMETERS: p_fpper LIKE s001-spmon OBLIGATORY .
*---select-options
*---Eksik Veri Girişi

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: r_1 RADIOBUTTON GROUP gr1,
              r_2 RADIOBUTTON GROUP gr1.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-t02.
  PARAMETERS: p_vari LIKE disvariant-variant,
              p_grid AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK block2.



*---INITIALIZATION.
INITIALIZATION.
  PERFORM initialization.
  h_repid = sy-repid.
  PERFORM list_initialization(zby_gen_alv_list) USING h_repid.

*---AT SELECTION-SCREEN
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM list_f4_for_variant(zby_gen_alv_list) USING p_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpper.
  PERFORM f4_popup_for_period.


*---AT SELECTION-SCREEN OUTPUT.
AT SELECTION-SCREEN OUTPUT.
  IF gv_first EQ 'X'.
    pnptimr1 = space.
    pnptimr6 = 'X'.
    CLEAR gv_first.
  ENDIF.


*---START-OF-SELECTION.
START-OF-SELECTION.
  PERFORM initial_condition.
  PERFORM fill_text.

GET pernr.
  CLEAR: h_hire, h_fire.
  PERFORM hire_fire USING pn-begda pn-endda
                          h_hire h_fire.
  PERFORM get_personal_info.


*---END-OF-SELECTION.
END-OF-SELECTION.
  DATA: gv_fark LIKE gt_itab2-ndyor.
  IF r_1 NE space.
    SORT gt_itab BY pernr.
    PERFORM list_display USING 'GT_ITAB' .
  ELSEIF r_2 NE space.
    SORT gt_itab2 BY pernr.
    LOOP AT gt_itab2.
      IF gt_itab2-ndy NE 0.
        gt_itab2-ndyor = gt_itab2-anzhl / gt_itab2-ndy * 100.
      ENDIF.
      IF psp01[] IS INITIAL.
        gv_fark = abs( ( gt_itab2-ndyor - gt_itab2-pkprz ) * 100 ).
        IF gv_fark EQ 0.
          CLEAR gt_itab2-color.
        ELSEIF gv_fark EQ 1.
          gt_itab2-color = 'C710'.
          gt_itab2-msgty = 'E'.
          gt_itab2-durm = gv_fark.
          CONCATENATE gt_itab2-durm
                      'PYP Yüzde toplamı %100 den farklı!'
                      INTO gt_itab2-durm.
        ELSE.
          gt_itab2-color = 'C610'.
          gt_itab2-msgty = 'E'.
          gt_itab2-durm = gv_fark.
          CONCATENATE gt_itab2-durm
                      'PYP Yüzde toplamı %100 den farklı!'
                      INTO gt_itab2-durm.
        ENDIF.
      ENDIF.
      MODIFY gt_itab2.
    ENDLOOP.
    PERFORM list_display USING 'GT_ITAB2' .
  ENDIF.




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

  pn-begps = pnpbegps = pn-begda = pnpbegda.
  pn-endps = pnpendps = pn-endda = pnpendda.

* Set Only Active Personel
  MOVE : 'I'   TO  pnpstat2-sign   ,
         'NE'  TO  pnpstat2-option ,
         '0'   TO  pnpstat2-low    .
  APPEND pnpstat2.
*-
*  rp-set-data-interval 'P0000' pn-begda pn-endda.
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
  DATA: lv_text1 TYPE stext,
        lv_text2 TYPE stext,
        lv_text3 TYPE stext,
        lv_text4 TYPE stext,
        lv_text5 TYPE stext,
        lv_text6 TYPE stext.

  IF r_1 NE space.
    CLEAR lv_n.
    DO 25 TIMES.
      ADD 1 TO lv_n.
      CONCATENATE 'KBU' lv_n INTO lv_f1.
      CONCATENATE 'KST' lv_n INTO lv_f2.
      CONCATENATE 'KTT' lv_n INTO lv_f3.
      CONCATENATE 'PSP' lv_n INTO lv_f4.
      CONCATENATE 'PST' lv_n INTO lv_f5.
      CONCATENATE 'KPR' lv_n INTO lv_f6.
      PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:

                       lv_f1
                       'NO_OUT'
                       'X',

                       lv_f2
                       'NO_OUT'
                       'X',

                       lv_f3
                       'NO_OUT'
                       'X',

                       lv_f4
                       'NO_OUT'
                       'X',

                       lv_f5
                       'NO_OUT'
                       'X',

                       lv_f6
                       'NO_OUT'
                       'X'.
    ENDDO.


    PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:

                       'BEGUZ/ENDUZ/VTKEN/STDAZ/LGART/ANZHL/ZEINH'
                       'NO_OUT'
                       'X',

                       'BWGRL/AUFKZ/BETRG/ENDOF'
                       'NO_OUT'
                       'X',

                       ''
                       'NO_OUT'
                       'X'.
  ELSEIF r_2 NE space.
    CLEAR lv_n.
    DO 25 TIMES.
      ADD 1 TO lv_n.
      CONCATENATE 'KBU' lv_n INTO lv_f1.
      CONCATENATE 'KST' lv_n INTO lv_f2.
      CONCATENATE 'KTT' lv_n INTO lv_f3.
      CONCATENATE 'PSP' lv_n INTO lv_f4.
      CONCATENATE 'PST' lv_n INTO lv_f5.
      CONCATENATE 'KPR' lv_n INTO lv_f6.
      CONCATENATE lv_n '.Şirket kodu' INTO lv_text1.
      CONCATENATE lv_n '.Masraf yeri' INTO lv_text2.
      CONCATENATE lv_n '.Masraf yeri' INTO lv_text3.
      CONCATENATE lv_n '.PYP öğesi' INTO lv_text4.
      CONCATENATE lv_n '.PYP öğesi' INTO lv_text5.
      CONCATENATE lv_n '.M.Yüzde' INTO lv_text6.
      PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:

                       lv_f1
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text1,

                       lv_f2
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text2,

                       lv_f3
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text3,

                       lv_f4
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text4,

                       lv_f5
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text5,

                       lv_f6
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       lv_text6.
    ENDDO.
    PERFORM list_set_attribute(zby_gen_alv_list)
                TABLES pt_fieldcat
                USING  p_tabname:

                       'MSGTY/DURM'
                       'NO_OUT'
                       'X',

                       'PKPRZ'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Toplam Yüzde',

                       'BEGDA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '2010 Başlangıç Tarihi',

                       'BEG27'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '27 Başlangıç Tarihi',

                       'END27'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '27 Bitiş Tarihi'.
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

                       'SAY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kişi Sayısı',

                       'IZIN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İzin',

                       'ZZFIRMTXTSGK'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK Konsinye Firma ',

                       'ZZFIRMTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Konsinye Firma ',

                       'POZISYON'
                       'NO_OUT'
                       'X',

                       'MSTBR/ZEINH'
                       'NO_OUT'
                       'X',

*                       'HIRE'
*                       'NO_OUT'
*                       'X',
*
*                       'FIRE'
*                       'NO_OUT'
*                       'X',

                       'ZZPERGRUPTX/ZZFIRMTXT/ZZFIRMTXTSGK/ZZDEPTXT'
                       'NO_OUT'
                       'X',

                       'ZZPERGRUP/ZZKONFIRM/ZZINDALIS/ZZPERGRP'
                       'NO_OUT'
                       'X',

                       'WERKS/ZZDEPARTMAN/OBJPS/SPRPS/SEQNR/SUBTY'
                       'NO_OUT'
                       'X',

                       'CAGRP/ZPERGRUPTX/ZZKONFIRMSGK'
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

*                       'BTRTL/BTEXT'
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

            'BUKRS/ORGEH/PLANS/BTRTL/REFORGEH/REFPLANS/REFBTRTL'
                       'NO_OUT'
                       'X',

                       'GESCH/GESCH_TXT/INDEX/WTEXT'
                       'NO_OUT'
                       'X',

*                       'BUTXT/SAY'
                       'BUTXT'
                       'NO_OUT'
                       'X',

                       'MASSN/MNTXT/MASSG/MGTXT/SAYI'
                       'NO_OUT'
                       'X',

                       'ANRED/BIRIM/CAGRP/CAAGR/ABKRS/MSTBR'
                       'NO_OUT'
                       'X',

                       'KOSTL/ANSVH/ATX/WERKS/WERKSN'
                       'NO_OUT'
                       'X',

                       'BORGO0'
*                       'BORDE0'
                       'NO_OUT'
                       'X',

                       'GESCH/GESCH_TXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Cinsiyet',

                       'ANZHL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '2010 Gün',

                       'NDY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK Gün',

                       'NDYOR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '2010/SGK',

                       'CINS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Cinsiyet',

                       'BORGO0'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       '771 Tür',

                       '771 Kanun Kod'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK Gr',

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

                       'REFFIRE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren ÇıkışTarih',

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

                       'REFPERNR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Sicil',

                       'REFENAME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Adı',

                       'REFPLANS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Pozisyon',

                       'REFPLANST'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Pozisyon',

                       'REFORGEH'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Departman',

                       'REFORGEHT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren Departman',

                       'REFBTRTL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren AltAlan',

                       'REFBTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Öneren AltAlan',

                       'PERNR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Sicil',

                       'ENAME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Adı ve Soyadı',

                       'PLANS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Pozisyon',

                       'PLANST'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Pozisyon',

                       'ORGEH'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Organizasyon Birimi',

                       'ORGEHT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Organizasyon Birimi',

                       'BTRTL'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'AltAlan',

                       'BTEXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'AltAlan',

                       'DENEMESURESI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Deneme Süresi',

                       'ODEMEYAPILDI'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ödeme Yapıldı',

                       'BUKRS/BUTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Şirket',

                       'ANSVH/ATX'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İstihdam Koşulu',

                       'MASSN/MNTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşlemler dizisi türü',

                       'MASSG/MGTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İşlemler dizisi nedeni',

                       'UNVAN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'İş',

                       'WERKS/WERKSN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Personel Alanı',

                       'CAGRP'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Çalışan Grup',

                       'CAAGR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Çalışan Alt Grup',

                       'ABKRS'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Bordro Altbirimi',

                       'MSBTR'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Şef alanı',

                       'SSTXT'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SGK Grubu',

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
FORM status_set_alv USING is_extab TYPE kkblo_t_extab.    "#EC CALLED

  SET PF-STATUS 'STANDARD_FULLSCR_CNT' .

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

*  CONCATENATE pn-begda+6(2) '.' pn-begda+4(2) '.' pn-begda+0(4) '-'
*              pn-endda+6(2) '.' pn-endda+4(2) '.' pn-endda+0(4)
*              INTO ls_line-info.
*  CONCATENATE ls_line-info 'Dönemi OFF Gün Raporu'
*    INTO ls_line-info SEPARATED BY space.

  ls_line-info = 'ARGE Kontrol Listesi (85746 05746 95746)'.
  APPEND ls_line TO gt_list_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'S'.
  CONCATENATE   p_fpper+4(2) '.' p_fpper+0(4)
              INTO ls_line-info.
  CONCATENATE 'Dönem:    ' ls_line-info
    INTO ls_line-info SEPARATED BY space.
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
  IF r_1 NE space.
    DESCRIBE TABLE gt_itab LINES lv_num.
  ELSEIF r_2 NE space.
    DESCRIBE TABLE gt_itab2 LINES lv_num.
  ENDIF.
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
*
  SELECT * FROM t542t INTO TABLE gt_t542t WHERE spras EQ sy-langu.
*
  SELECT otype objid stext INTO TABLE gt_1000
                  FROM hrp1000
                 WHERE ( otype EQ 'O'
                     OR  otype EQ 'S'
                     OR  otype EQ 'C' )
                   AND langu EQ sy-langu
*                   AND endda GE pn-begda
                   AND begda LE pn-endda.
  SORT gt_1000 BY otype objid.

ENDFORM.                    " fill_TEXT
*&---------------------------------------
*&---------------------------------------------------------------------*
*&      Form  GET_PERSONAL_INFO
*&---------------------------------------------------------------------*
FORM get_personal_info .

  CLEAR: gt_itab, gt_itab2.
  gt_itab-pernr = pernr-pernr.
*--Fetch data
  rp_provide_from_last p0000 space pn-begda pn-endda.
  rp_provide_from_last p0001 space pn-begda pn-endda.
  rp_provide_from_last p0769 space pn-begda pn-endda.
  rp_provide_from_last p0771 space pn-begda pn-endda.
  CHECK ( p0769-kanun EQ '85746' OR
          p0769-kanun EQ '05746' OR
          p0769-kanun EQ '95746' ) OR
          p0771-borgo0 EQ '01' AND
          p0771-borde0 NE space.

  CLEAR h_fire.
  IF p0000-massn EQ '10'.
    h_fire = p0000-begda - 1.
  ENDIF.

*  IF h_hire BETWEEN pn-begda AND pn-endda.
  gt_itab-hire = h_hire.
*  ENDIF.
  IF h_fire BETWEEN pn-begda AND pn-endda.
    gt_itab-fire = h_fire.
    rp-provide-from-last p0001 space pn-begda gt_itab-fire.
  ENDIF.
  IF h_fire EQ '00000000'.
    h_fire = '99991231'.
  ENDIF.

  CHECK: gt_itab-hire LE pn-endda,
         h_fire GE pn-begda.

  rp_provide_from_last p0002 space pn-begda pn-endda.

  MOVE-CORRESPONDING: p0769 TO gt_itab,
                      p0771 TO gt_itab,
                      p0002 TO gt_itab,
                      p0001 TO gt_itab.
  gt_itab-pernr = pernr-pernr.

*--Itabın içindeki metinleri oku
  PERFORM set_itab_text.

  PERFORM fill_pernr_details .


  gt_itab-say = 1.

  CLEAR: p0027, p2010.
  rp_provide_from_last p0027 '01  ' pn-begda pn-endda.
  rp_provide_from_last p2010 '5ARG' pn-begda pn-endda.

  IF r_1 NE space.
    PERFORM control_eksik_veri_girisi.
  ELSEIF r_2 NE space.
    PERFORM read_2010_0027.
  ENDIF.

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
  DATA: ls_ref  TYPE pa0001,
        lv_date TYPE datum.


* Şirket TX
  CLEAR gt_t001.
  READ TABLE gt_t001 WITH KEY bukrs = gt_itab-bukrs.
  gt_itab-butxt = gt_t001-butxt.

  CLEAR gt_t500p.
  READ TABLE gt_t500p WITH KEY persa = gt_itab-werks.
  gt_itab-wtext = gt_t500p-name1.

  CLEAR gt_t001p.
  READ TABLE gt_t001p WITH KEY werks = gt_itab-werks
                               btrtl = gt_itab-btrtl.
  gt_itab-btext = gt_t001p-btext.


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



*-pozisyon metni
  READ TABLE gt_1000 WITH KEY otype = 'S'
                              objid = gt_itab-plans
                           BINARY SEARCH.
  IF sy-subrc EQ 0.
    gt_itab-planst = gt_1000-stext.
  ENDIF.

*-org. birimi metni
  READ TABLE gt_1000 WITH KEY otype = 'O'
                              objid = gt_itab-orgeh
                           BINARY SEARCH.
  IF sy-subrc EQ 0.
    gt_itab-orgeht = gt_1000-stext.
  ENDIF.

*-alt alan
  CLEAR: gt_itab-btext.
  SELECT SINGLE btext INTO gt_itab-btext FROM t001p
    WHERE werks = gt_itab-werks
    AND   btrtl = gt_itab-btrtl.

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
FORM initialization.

  p_fpper = sy-datum+0(6).

  pnptimr1 = space.
  pnptimr6 = 'X'.

ENDFORM.                    " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  fill_pernr_details
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_pernr_details .

  CLEAR: gt_itab-unvan.
  SELECT stltx INTO gt_itab-unvan FROM t513s
    WHERE stell = p0001-stell.
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

  CLEAR: gt_itab-mntxt.
  SELECT  mntxt INTO gt_itab-mntxt FROM t529t
    WHERE massn = gt_itab-massn.
  ENDSELECT.

  CLEAR: gt_itab-mgtxt.
  SELECT  mgtxt INTO gt_itab-mgtxt FROM t530t
    WHERE  massn = gt_itab-massn
    AND   massg = gt_itab-massg.
  ENDSELECT.

*****cinsiyet bilgisi****************************
  CLEAR : l_value , l_text .

  l_value = gt_itab-gesch.
  CALL FUNCTION 'GET_DOMAENENTEXT'
    EXPORTING
      dname           = 'GESCH'
      dvalue          = l_value
    IMPORTING
      dtext           = l_text
    EXCEPTIONS
      no_domain_found = 1
      OTHERS          = 2.
  gt_itab-gesch_txt = l_text.


*---Emekli Kanun
  CLEAR : l_value , l_text .
  SELECT SINGLE stext INTO l_text FROM t7tri04
                        WHERE borgo = gt_itab-borgo0
                        AND   borde = gt_itab-borde0.
  IF sy-subrc EQ 0.
    gt_itab-kanun = l_text+0(5).
  ENDIF.

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

  SORT p0000 BY begda DESCENDING.

  LOOP AT p0000 WHERE massn = '01' OR massn = '12'.
    h_date = p0000-begda.
    EXIT.
  ENDLOOP.

ENDFORM.                               " HIRE_FIRE
*&---------------------------------------------------------------------*
*&      Form  CONTROL_EKSIK_VERI_GIRISI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM control_eksik_veri_girisi .
*---Bordro Oku
  MOVE pernr-pernr TO cd-key-pernr.
  rp-imp-c2-cd.
  CHECK: rp-imp-cd-subrc EQ 0.

  LOOP AT rgdir WHERE fpper EQ p_fpper
                AND   srtza = 'A'.
    rx-key-pernr = pernr-pernr.
    UNPACK rgdir-seqnr TO rx-key-seqno.
    rp-imp-c2-tr.
    CHECK:  rp-imp-tr-subrc EQ  0 .

*---
    LOOP AT wpbp.
      IF wpbp-apznr EQ '00'.
        wpbp-apznr = '01'.
      ENDIF.
      LOOP AT rt WHERE lgart EQ '/NDY'
                 AND   apznr EQ wpbp-apznr.
        gt_itab-ndy = gt_itab-ndy + rt-anzhl.
      ENDLOOP.

    ENDLOOP.
  ENDLOOP.


  IF p0027 IS NOT INITIAL AND p2010 IS INITIAL.
    gt_itab-msgty = 'E'.
    gt_itab-durm =
    '27 PYP öğesi dağılımı Girilmiş 2010 Ödeme Belgesi Girilmemiş!'.
    APPEND gt_itab.
  ELSEIF p0027 IS INITIAL AND p2010 IS NOT INITIAL.
    gt_itab-msgty = 'E'.
    gt_itab-durm =
    '27 PYP öğesi dağılımı Girilmemiş 2010 Ödeme Belgesi Girilmiş!'.
    APPEND gt_itab.
  ELSEIF p0027 IS INITIAL AND p2010 IS INITIAL.
    gt_itab-msgty = 'E'.
    gt_itab-durm =
   '27 PYP öğesi dağılımı Girilmemiş 2010 Ödeme Belgesi Girilmemiş!'.
    APPEND gt_itab.
  ENDIF.
ENDFORM.                    " CONTROL_EKSIK_VERI_GIRISI
*&---------------------------------------------------------------------*
*&      Form  READ_2010_0027
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM read_2010_0027.
  DATA: lv_ok.

  CLEAR lv_ok.
  MOVE-CORRESPONDING: gt_itab TO gt_itab2.
  IF p0027 IS NOT INITIAL.
*    MOVE-CORRESPONDING: p0027 TO gt_itab2.
    gt_itab2-beg27 = p0027-begda.
    gt_itab2-end27 = p0027-endda.
    CLEAR: lv_n, lv_n1.
    DO 25 TIMES.
      ADD 1 TO lv_n1.
      CONCATENATE 'P0027' '-KST' lv_n1 INTO lv_f7.
      ASSIGN: (lv_f7) TO <f7>.
      CHECK sy-subrc EQ 0.
      CHECK <f7> IS NOT INITIAL.

*      CONCATENATE 'P0027' '-KTT' lv_n1 INTO lv_f8.
*      ASSIGN: (lv_f8) TO <f8>.
*      check sy-subrc eq 0.
      CONCATENATE 'P0027' '-PSP' lv_n1 INTO lv_f9.
      ASSIGN: (lv_f9) TO <f9>.
      CHECK sy-subrc EQ 0.
*      CONCATENATE 'P0027' '-PST' lv_n1 INTO lv_f10.
*      ASSIGN: (lv_f10) TO <f10>.
*      check sy-subrc eq 0.
      CONCATENATE 'P0027' '-KBU' lv_n1 INTO lv_f11.
      ASSIGN: (lv_f11) TO <f11>.
      CHECK sy-subrc EQ 0.
      CONCATENATE 'P0027' '-KPR' lv_n1 INTO lv_f12.
      ASSIGN: (lv_f12) TO <f12>.
      CHECK sy-subrc EQ 0.

      ADD 1 TO lv_n.
      CONCATENATE 'GT_ITAB2' '-KST' lv_n INTO lv_f1.
      CONCATENATE 'GT_ITAB2' '-KTT' lv_n INTO lv_f2.
      CONCATENATE 'GT_ITAB2' '-PSP' lv_n INTO lv_f3.
      CONCATENATE 'GT_ITAB2' '-PST' lv_n INTO lv_f4.

      ASSIGN: (lv_f1) TO <f1>.
      IF sy-subrc EQ 0.
        ASSIGN: (lv_f2) TO <f2>.
        IF sy-subrc EQ 0.
          <f1> = <f7>.
*          <f2> = <f8>.
          SELECT SINGLE ltext INTO <f2> FROM cskt
                                WHERE spras EQ sy-langu
                                AND   kostl EQ <f1>
                                AND   datbi GE pn-begda.
        ENDIF.
      ENDIF.
      CONCATENATE 'GT_ITAB2' '-KBU' lv_n INTO lv_f5.
      CONCATENATE 'GT_ITAB2' '-KPR' lv_n INTO lv_f6.
      ASSIGN: (lv_f5) TO <f5>.
      CHECK sy-subrc EQ 0.
      <f5> = <f11>.
      ASSIGN: (lv_f6) TO <f6>.
      CHECK sy-subrc EQ 0.
      <f6> = <f12>.

      ASSIGN: (lv_f3) TO <f3>.
      IF sy-subrc EQ 0.
        <f3> = <f9>.
        IF <f3> IN psp01.
          lv_ok = 'X'.
        ELSE.
          CLEAR: <f6>, <f5>, <f3>, <f2>, <f1>.
          SUBTRACT 1 FROM lv_n.
        ENDIF.
        IF sy-subrc EQ 0.
          ASSIGN: (lv_f4) TO <f4>.
          IF sy-subrc EQ 0.
*           <f4> = <f10>.
            SELECT SINGLE postu INTO <f4> FROM prps
                                  WHERE pspnr EQ <f3>.
            IF sy-subrc NE 0.
              gt_itab2-color = 'C710'.
              gt_itab2-msgty = 'E'.
              CONCATENATE <f3>
                          'PYP Öğesi SAP da mevcut değil!'
                          INTO gt_itab2-durm.
            ENDIF.
            IF <f3> IS INITIAL AND <f6> IS NOT INITIAL.
              gt_itab2-color = 'C710'.
              gt_itab2-msgty = 'E'.
              CONCATENATE 'PYP Öğesi boş olamsına rağmen'
                          <f3>
                          'Yüzde mevcut!'
                          INTO gt_itab2-durm.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.




    ENDDO.
  ENDIF.

  IF p2010 IS NOT INITIAL.
    MOVE-CORRESPONDING: p2010 TO gt_itab2.
    SELECT SINGLE etext INTO gt_itab2-etext FROM t538t
                        WHERE sprsl EQ sy-langu
                        AND   zeinh EQ gt_itab2-zeinh.
  ENDIF.

  gt_itab2-pkprz = gt_itab2-kpr01 +
                   gt_itab2-kpr02 +
                   gt_itab2-kpr03 +
                   gt_itab2-kpr04 +
                   gt_itab2-kpr05 +
                   gt_itab2-kpr06 +
                   gt_itab2-kpr07 +
                   gt_itab2-kpr08 +
                   gt_itab2-kpr09 +
                   gt_itab2-kpr10 +
                   gt_itab2-kpr11 +
                   gt_itab2-kpr12 +
                   gt_itab2-kpr13 +
                   gt_itab2-kpr14 +
                   gt_itab2-kpr15 +
                   gt_itab2-kpr16 +
                   gt_itab2-kpr17 +
                   gt_itab2-kpr18 +
                   gt_itab2-kpr19 +
                   gt_itab2-kpr20 +
                   gt_itab2-kpr21 +
                   gt_itab2-kpr22 +
                   gt_itab2-kpr23 +
                   gt_itab2-kpr24 +
                   gt_itab2-kpr25.

  CHECK lv_ok EQ 'X'.

  MOVE pernr-pernr TO cd-key-pernr.
  rp-imp-c2-cd.
  CHECK: rp-imp-cd-subrc EQ 0.

  LOOP AT rgdir WHERE fpper EQ p_fpper
                AND   srtza = 'A'.
    rx-key-pernr = pernr-pernr.
    UNPACK rgdir-seqnr TO rx-key-seqno.
    rp-imp-c2-tr.
    CHECK:  rp-imp-tr-subrc EQ  0 .

*---
    LOOP AT wpbp.
      IF wpbp-apznr EQ '00'.
        wpbp-apznr = '01'.
      ENDIF.
      LOOP AT rt WHERE lgart EQ '/NDY'
                 AND   apznr EQ wpbp-apznr.
        gt_itab2-ndy = gt_itab2-ndy + rt-anzhl.
      ENDLOOP.

    ENDLOOP.
  ENDLOOP.

  APPEND gt_itab2.

ENDFORM.                    " READ_2010_0027
