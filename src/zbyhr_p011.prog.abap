*&---------------------------------------------------------------------*
*& Report ZBYHR_P011
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p011.


INFOTYPES: 0027.

TABLES: p0001, p0769, ZBYHR_T011.

TYPE-POOLS: truxs, slis,kkblo.

TYPES: t_datatab TYPE ZBYHR_S002.
TYPES: t_datatab_head TYPE ZBYHR_S003.
DATA: it_datatab TYPE STANDARD TABLE OF t_datatab WITH HEADER LINE.
DATA: it_datatab_head TYPE STANDARD TABLE OF
      t_datatab_head WITH HEADER LINE.
DATA: gt_0769 TYPE STANDARD TABLE OF t_datatab WITH HEADER LINE.
DATA: it_raw TYPE truxs_t_text_data.


DATA: BEGIN OF gt_p OCCURS 10,
        pernr    LIKE p0769-pernr,
        ename    LIKE p0001-ename,
        kanun    LIKE p0769-kanun,
        borgo0   LIKE p0771-borgo0,
        borde0   LIKE p0771-borde0,
        hire     LIKE p0000-begda,
        fire     LIKE p0000-endda,
        begda    LIKE p0001-begda,
        endda    LIKE p0001-endda,
        msgty    LIKE bapireturn1-type,
        durm     LIKE pa0105-usrid_long,
        bukrs    LIKE p0027-kbu01,
        kostl    LIKE p0027-kst01,
*         kbu01 LIKE p0027-kbu01,
*         kst01 LIKE p0027-kst01,
*         ktt01 LIKE cskt-ltext,
*         psp01 LIKE p0027-psp01,
*         pst01 LIKE prps-postu,
        kpr01    LIKE p0027-kpr01,
*         kbu02 LIKE p0027-kbu02,
*         kst02 LIKE p0027-kst02,
*         ktt02 LIKE cskt-ltext,
*         psp02 LIKE p0027-psp02,
*         pst02 LIKE prps-postu,
        kpr02    LIKE p0027-kpr02,
*         kbu03 LIKE p0027-kbu03,
*         kst03 LIKE p0027-kst03,
*         ktt03 LIKE cskt-ltext,
*         psp03 LIKE p0027-psp03,
*         pst03 LIKE prps-postu,
        kpr03    LIKE p0027-kpr03,
*         kbu04 LIKE p0027-kbu04,
*         kst04 LIKE p0027-kst04,
*         ktt04 LIKE cskt-ltext,
*         psp04 LIKE p0027-psp04,
*         pst04 LIKE prps-postu,
        kpr04    LIKE p0027-kpr04,
*         kbu05 LIKE p0027-kbu05,
*         kst05 LIKE p0027-kst05,
*         ktt05 LIKE cskt-ltext,
*         psp05 LIKE p0027-psp05,
*         pst05 LIKE prps-postu,
        kpr05    LIKE p0027-kpr05,
*         kbu06 LIKE p0027-kbu06,
*         kst06 LIKE p0027-kst06,
*         ktt06 LIKE cskt-ltext,
*         psp06 LIKE p0027-psp06,
*         pst06 LIKE prps-postu,
        kpr06    LIKE p0027-kpr06,
*         kbu07 LIKE p0027-kbu07,
*         kst07 LIKE p0027-kst07,
*         ktt07 LIKE cskt-ltext,
*         psp07 LIKE p0027-psp07,
*         pst07 LIKE prps-postu,
        kpr07    LIKE p0027-kpr07,
*         kbu08 LIKE p0027-kbu08,
*         kst08 LIKE p0027-kst08,
*         ktt08 LIKE cskt-ltext,
*         psp08 LIKE p0027-psp08,
*         pst08 LIKE prps-postu,
        kpr08    LIKE p0027-kpr08,
*         kbu09 LIKE p0027-kbu09,
*         kst09 LIKE p0027-kst09,
*         ktt09 LIKE cskt-ltext,
*         psp09 LIKE p0027-psp09,
*         pst09 LIKE prps-postu,
        kpr09    LIKE p0027-kpr09,
*         kbu10 LIKE p0027-kbu10,
*         kst10 LIKE p0027-kst10,
*         ktt10 LIKE cskt-ltext,
*         psp10 LIKE p0027-psp10,
*         pst10 LIKE prps-postu,
        kpr10    LIKE p0027-kpr10,
*         kbu11 LIKE p0027-kbu11,
*         kst11 LIKE p0027-kst11,
*         ktt11 LIKE cskt-ltext,
*         psp11 LIKE p0027-psp11,
*         pst11 LIKE prps-postu,
        kpr11    LIKE p0027-kpr11,
*         kbu12 LIKE p0027-kbu12,
*         kst12 LIKE p0027-kst12,
*         ktt12 LIKE cskt-ltext,
*         psp12 LIKE p0027-psp12,
*         pst12 LIKE prps-postu,
        kpr12    LIKE p0027-kpr12,
*         kbu13 LIKE p0027-kbu13,
*         kst13 LIKE p0027-kst13,
*         ktt13 LIKE cskt-ltext,
*         psp13 LIKE p0027-psp13,
*         pst13 LIKE prps-postu,
        kpr13    LIKE p0027-kpr13,
*         kbu14 LIKE p0027-kbu14,
*         kst14 LIKE p0027-kst14,
*         ktt14 LIKE cskt-ltext,
*         psp14 LIKE p0027-psp14,
*         pst14 LIKE prps-postu,
        kpr14    LIKE p0027-kpr14,
*         kbu15 LIKE p0027-kbu15,
*         kst15 LIKE p0027-kst15,
*         ktt15 LIKE cskt-ltext,
*         psp15 LIKE p0027-psp15,
*         pst15 LIKE prps-postu,
        kpr15    LIKE p0027-kpr15,
*         kbu16 LIKE p0027-kbu16,
*         kst16 LIKE p0027-kst16,
*         ktt16 LIKE cskt-ltext,
*         psp16 LIKE p0027-psp16,
*         pst16 LIKE prps-postu,
        kpr16    LIKE p0027-kpr16,
*         kbu17 LIKE p0027-kbu17,
*         kst17 LIKE p0027-kst17,
*         ktt17 LIKE cskt-ltext,
*         psp17 LIKE p0027-psp17,
*         pst17 LIKE prps-postu,
        kpr17    LIKE p0027-kpr17,
*         kbu18 LIKE p0027-kbu18,
*         kst18 LIKE p0027-kst18,
*         ktt18 LIKE cskt-ltext,
*         psp18 LIKE p0027-psp18,
*         pst18 LIKE prps-postu,
        kpr18    LIKE p0027-kpr18,
*         kbu19 LIKE p0027-kbu19,
*         kst19 LIKE p0027-kst19,
*         ktt19 LIKE cskt-ltext,
*         psp19 LIKE p0027-psp19,
*         pst19 LIKE prps-postu,
        kpr19    LIKE p0027-kpr19,
*         kbu20 LIKE p0027-kbu20,
*         kst20 LIKE p0027-kst20,
*         ktt20 LIKE cskt-ltext,
*         psp20 LIKE p0027-psp20,
*         pst20 LIKE prps-postu,
        kpr20    LIKE p0027-kpr20,
*         kbu21 LIKE p0027-kbu21,
*         kst21 LIKE p0027-kst21,
*         ktt21 LIKE cskt-ltext,
*         psp21 LIKE p0027-psp21,
*         pst21 LIKE prps-postu,
        kpr21    LIKE p0027-kpr21,
*         kbu22 LIKE p0027-kbu22,
*         kst22 LIKE p0027-kst22,
*         ktt22 LIKE cskt-ltext,
*         psp22 LIKE p0027-psp22,
*         pst22 LIKE prps-postu,
        kpr22    LIKE p0027-kpr22,
*         kbu23 LIKE p0027-kbu23,
*         kst23 LIKE p0027-kst23,
*         ktt23 LIKE cskt-ltext,
*         psp23 LIKE p0027-psp23,
*         pst23 LIKE prps-postu,
        kpr23    LIKE p0027-kpr23,
*         kbu24 LIKE p0027-kbu24,
*         kst24 LIKE p0027-kst24,
*         ktt24 LIKE cskt-ltext,
*         psp24 LIKE p0027-psp24,
*         pst24 LIKE prps-postu,
        kpr24    LIKE p0027-kpr24,
*         kbu25 LIKE p0027-kbu25,
*         kst25 LIKE p0027-kst25,
*         ktt25 LIKE cskt-ltext,
*         psp25 LIKE p0027-psp25,
*         pst25 LIKE prps-postu,
        kpr25    LIKE p0027-kpr25,
        kprtp    LIKE p0027-kpr25,
        say      LIKE bseg-peinh,
        color(4),
        mark,
      END OF gt_p.
DATA: gt_p_kal LIKE gt_p OCCURS 10 WITH HEADER LINE.

DATA : BEGIN OF gt_h OCCURS 0,
         pernr TYPE persno,
         begda TYPE begda,
       END OF gt_h.

DATA : BEGIN OF gt_f OCCURS 0,
         pernr TYPE persno,
         begda TYPE begda,
         massn TYPE massn,
         massg TYPE massg,
       END OF gt_f.

DATA: wa_tab  LIKE gt_p,
      it_data LIKE gt_p OCCURS 10.

DATA: g_exit_caused_by_caller,
      gs_exit_caused_by_user TYPE slis_exit_by_user.
DATA: g_save.

* Global structure of list
DATA: gv_subrc            LIKE sy-subrc,
      gv_begda            TYPE datum,
      gv_endda            TYPE datum,
      gv_begdarec         TYPE datum,
      gt_events           TYPE slis_t_event,
      gv_repid            LIKE sy-repid,
      gs_keyinfo          TYPE slis_keyinfo_alv,
      gs_layout           TYPE slis_layout_alv,
      gt_sort             TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      h_repid             LIKE sy-repid,
      gs_top,
      gs_variant          LIKE disvariant,
      gt_list_top_of_page TYPE slis_t_listheader.

DATA: gt_fieldcat     TYPE slis_t_fieldcat_alv,
      gv_kanun(5)     TYPE n,
      gv_kostl_nc(10) TYPE n,
      lv_postu        LIKE prps-postu.
DATA: lv_i      TYPE i,
      gv_i      TYPE i, lv_ok,
      lv_f1(30),
      lv_f2(30),
      lv_f3(30),
      lv_f4(30),
      lv_f5(30),
      lv_f6(30),
      lv_f7(30),
      lv_n(2)   TYPE n,
      lv_n1(2)  TYPE n.
*

FIELD-SYMBOLS: <f1> TYPE any,
               <f2> TYPE any,
               <f3> TYPE any,
               <f4> TYPE any,
               <f5> TYPE any,
               <f6> TYPE any,
               <f7> TYPE any.

RANGES: gr_pernr FOR p0001-pernr.

CONSTANTS: c_stat_etkin TYPE stat2 VALUE '3'.

* Events used by ALV Function
CONSTANTS: gc_top_of_page   TYPE slis_formname VALUE 'TOP_OF_PAGE_ALV',
           gc_user_command  TYPE slis_formname VALUE 'USER_COMMAND_ALV',
           gc_pf_status_set TYPE slis_formname VALUE 'STATUS_SET_ALV'.


SELECT-OPTIONS : kanun FOR p0769-kanun NO INTERVALS .

*PARAMETERS p_bukrs like pa0001-bukrs.
SELECTION-SCREEN BEGIN OF BLOCK b002 WITH FRAME TITLE TEXT-t03.
  PARAMETERS: p_fpper LIKE s001-spmon OBLIGATORY,
              p_bukrs LIKE pa0001-bukrs OBLIGATORY,
              p_excel TYPE  rlgrap-filename.
SELECTION-SCREEN END OF BLOCK b002.


SELECTION-SCREEN BEGIN OF BLOCK b003 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN COMMENT /1(50) comm8.
  SELECTION-SCREEN COMMENT /1(50) comm9.
  SELECTION-SCREEN COMMENT /1(50) comm1.
  SELECTION-SCREEN COMMENT /1(50) comm2.
  SELECTION-SCREEN COMMENT /1(50) comm3.
  SELECTION-SCREEN COMMENT /1(50) comm4.
  SELECTION-SCREEN COMMENT /1(50) comm5.
  SELECTION-SCREEN COMMENT /1(50) comm6.
  SELECTION-SCREEN COMMENT /1(50) comm7.
SELECTION-SCREEN END OF BLOCK b003.


INITIALIZATION.
  REFRESH kanun.
  kanun = 'IEQ'.
  kanun-low = '85746'.
  APPEND kanun.
  kanun-low = '05746'.
  APPEND kanun.
  kanun-low = '95746'.
  APPEND kanun.


AT SELECTION-SCREEN OUTPUT.
  comm8 = 'PYP Kodlarını Başlık Satırından Almaktadır'.
  comm1 = 'Sicil'.
  comm2 = 'Şirket'.
  comm3 = 'Masraf Yeri'.
  comm4 = 'PYP Öğesi 1 Yüzde'.
  comm5 = 'PYP Öğesi 2 Yüzde'.
  comm6 = '........'.
  comm7 = 'PYP Öğesi 25 Yüzde'.


*---AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_excel.
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_excel.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_EXCEL'
    IMPORTING
      file_name  = p_excel.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fpper.
  PERFORM f4_popup_for_period.


*--START-OF-SELECTION.
START-OF-SELECTION.

  CONCATENATE p_fpper '01' INTO gv_begda.
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gv_begda
    IMPORTING
      last_day_of_month = gv_endda.



  IF p_excel IS NOT INITIAL.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = ';'
        i_line_header        = ' '
        i_tab_raw_data       = it_raw       " WORK TABLE
        i_filename           = p_excel
      TABLES
        i_tab_converted_data = it_datatab_head[]    "ACTUAL DATA
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
        i_field_seperator    = ';'
        i_line_header        = 'X'
        i_tab_raw_data       = it_raw       " WORK TABLE
        i_filename           = p_excel
      TABLES
        i_tab_converted_data = it_datatab[]    "ACTUAL DATA
      EXCEPTIONS
        conversion_failed    = 1
        OTHERS               = 2.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  READ TABLE it_datatab_head INDEX 1.
  REFRESH it_datatab_head.

*---Gelen PYP öğeleri sistemde mevcutmu
  CLEAR: lv_n.
  DO 25 TIMES.

    ADD 1 TO lv_n.

    CONCATENATE 'IT_DATATAB_HEAD' '-KPR' lv_n INTO lv_f6.
    ASSIGN: (lv_f6) TO <f6>.
    CHECK sy-subrc EQ 0 AND <f6> IS NOT INITIAL.

    SELECT SINGLE postu INTO lv_postu FROM prps
                              WHERE posid EQ <f6>.
    IF sy-subrc NE 0 .
      MESSAGE ID 'RP' TYPE 'E' NUMBER '016'
              WITH <f6> 'PYP Öğesi sistemde mevcut değil.'
                   'SAP da tanımlayıp tekrar yükleyiniz!'.
    ENDIF.
  ENDDO.

  SORT it_datatab BY pernr.

  REFRESH gr_pernr.
  LOOP AT it_datatab.
    gr_pernr = 'IEQ'.
    gr_pernr-low = it_datatab-pernr.
    APPEND gr_pernr.
  ENDLOOP.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE gt_p
     FROM pa0001 JOIN pa0000
       ON pa0000~pernr EQ pa0001~pernr
        AND pa0000~begda LE pa0001~endda
        AND pa0000~endda GE pa0001~begda
    WHERE pa0000~stat2 EQ c_stat_etkin
      AND pa0000~pernr IN gr_pernr
      AND pa0001~endda GE gv_begda
      AND pa0001~begda LE gv_endda
      AND pa0000~endda GE gv_begda
      AND pa0000~begda LE gv_endda
      AND pa0001~bukrs EQ p_bukrs.
*      AND pa0001~werks IN werks
*      AND pa0001~btrtl IN btrtl
*      AND pa0001~persg IN persg
*      AND pa0001~persk IN persk
*      AND pa0001~abkrs IN abkrs
*      AND pa0001~plans IN plans
*      AND pa0001~stell IN stell
*      AND pa0001~kostl IN kostl
*      AND pa0001~orgeh IN orgeh
*      AND pa0001~ansvh IN ansvh.
*      AND pa0001~plans NE '99999999'.

  SORT gt_p BY pernr begda.
  LOOP AT gt_p.
    gt_p_kal = gt_p.
    AT END OF pernr.
*---Her Sicilin Son Kaydı kalsın
      APPEND gt_p_kal.
    ENDAT.
  ENDLOOP.
  gt_p[] = gt_p_kal[].
  REFRESH gt_p_kal.
  SORT gt_p BY pernr.




*---END-OF-SELECTION
END-OF-SELECTION.

  LOOP AT gt_p.

    gt_p-begda = gv_begda.
    gt_p-endda = gv_endda.

    CLEAR gt_p-hire.
    SELECT SINGLE begda INTO gt_p-hire FROM pa0000
                               WHERE ( massn EQ '01'
                               OR    massn EQ '12' )
                               AND   pernr EQ gt_p-pernr
                               AND   begda GE gv_begda
                               AND   begda LE gv_endda.
    IF sy-subrc EQ 0.
      gt_p-begda = gt_p-hire.
    ELSE.
      gt_p-begda = gv_begda.
    ENDIF.

    CLEAR gt_p-fire.
    SELECT SINGLE begda INTO gt_p-fire FROM pa0000
                               WHERE   massn EQ '10'
                               AND     pernr EQ gt_p-pernr
                               AND     begda GE gv_begda
                               AND     begda LE gv_endda.
    IF sy-subrc EQ 0.
      gt_p-endda = gt_p-fire.
    ELSE.
      gt_p-endda = gv_endda.
    ENDIF.

    CLEAR gt_p-kanun.
    SELECT SINGLE kanun INTO gt_p-kanun
         FROM pa0769 WHERE pernr EQ gt_p-pernr
                     AND   begda LE gv_endda
                     AND   endda GE gv_endda
                     AND   kanun IN kanun
                     AND   kanun IS NOT NULL
                     AND   kanun NE space
                     AND   kanun NE '     '.

    IF gt_p-kanun IS INITIAL.
      SELECT SINGLE borgo0 borde0
           INTO (gt_p-borgo0, gt_p-borde0)
           FROM pa0771 WHERE pernr EQ gt_p-pernr
                       AND   begda LE gv_endda
                       AND   endda GE gv_endda
                       AND   borgo0 EQ '01'
                       AND   borde0 NE space.
      IF sy-subrc EQ 0.
*---Emekli Kanun
        CLEAR : lv_f1 .
        SELECT SINGLE stext INTO lv_f1 FROM t7tri04
                            WHERE borgo = gt_p-borgo0
                            AND   borde = gt_p-borde0.
        IF sy-subrc EQ 0.
          gt_p-kanun = lv_f1+0(5).
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY gt_p.

  ENDLOOP.


  SORT gt_p BY pernr.

  LOOP AT it_datatab.
*    READ TABLE gt_p WITH KEY pernr = it_datatab-pernr
*                       BINARY SEARCH.
*    IF sy-subrc EQ 0.
    LOOP AT gt_p WHERE pernr = it_datatab-pernr.
      CLEAR gt_p-durm.
      MOVE-CORRESPONDING it_datatab TO gt_p.

      CLEAR: lv_n, lv_n1.
      DO 25 TIMES.

        ADD 1 TO lv_n.

        CONCATENATE 'GT_P' '-KPR' lv_n INTO lv_f6.
        ASSIGN: (lv_f6) TO <f6>.
        CHECK sy-subrc EQ 0 AND <f6> NE 0.
        ADD <f6> TO gt_p-kprtp.

        CONCATENATE 'GT_P' '-KBU' lv_n INTO lv_f5.
        ASSIGN: (lv_f5) TO <f5>.
        CHECK sy-subrc EQ 0.
        IF it_datatab-bukrs = p_bukrs.
          <f5> = it_datatab-bukrs.
        ELSE.
          gt_p-msgty = 'E'.
          gt_p-color = 'C600'.
          gt_p-durm =
          'EXCEL den gelen Şirket Kodu Seçim Kriterlerine Uygun Değil!'.
        ENDIF.

        CONCATENATE 'GT_P' '-KST' lv_n INTO lv_f1.
        CONCATENATE 'GT_P' '-KTT' lv_n INTO lv_f2.
        CONCATENATE 'GT_P' '-PSP' lv_n INTO lv_f3.
        CONCATENATE 'GT_P' '-PST' lv_n INTO lv_f4.

        ASSIGN: (lv_f1) TO <f1>.
        IF sy-subrc EQ 0.
          <f1> = it_datatab-kostl.
          ASSIGN: (lv_f2) TO <f2>.
          IF sy-subrc EQ 0.
            SELECT SINGLE ltext INTO <f2> FROM cskt
                                  WHERE spras EQ sy-langu
                                  AND   kostl EQ <f1>
                                  AND   datbi GE gv_begda.
          ENDIF.
        ENDIF.

        ASSIGN: (lv_f3) TO <f3>.
        IF sy-subrc EQ 0.
          ASSIGN: (lv_f4) TO <f4>.
          IF sy-subrc EQ 0.
            SELECT SINGLE postu INTO <f4> FROM prps
                                  WHERE posid EQ <f3>.
          ENDIF.
        ENDIF.

      ENDDO.

      gt_p-msgty = 'I'.

      IF gt_p-kprtp GT 100.
        gt_p-msgty = 'E'.
        gt_p-color = 'C600'.
        gt_p-durm =
        'EXCEL den gelen Yüzde toplamı 100 ü aşamaz!'.
      ENDIF.

      IF gt_p-kprtp EQ 0.
        gt_p-msgty = 'E'.
        gt_p-color = 'C600'.
        gt_p-durm =
        'EXCEL den gelen Yüzde toplamı SIFIR 0 dan farklı olmalı!'.
      ENDIF.

      IF gt_p-kostl IS INITIAL.
        gt_p-msgty = 'E'.
        gt_p-color = 'C600'.
        gt_p-durm =
        'EXCEL den gelen Masraf Yeri BOŞ!'.
      ELSE.
        gv_kostl_nc = gt_p-kostl.
        CLEAR: gv_i, lv_ok.
        DO 10 TIMES.
          IF gt_p-kostl+gv_i(1) BETWEEN '0' AND '9' OR
             gt_p-kostl+gv_i(1) EQ space.
          ELSE.
            lv_ok = 'X'.
            EXIT.
          ENDIF.
          ADD 1 TO gv_i.
        ENDDO.
        IF lv_ok = space.
          gt_p-kostl = gv_kostl_nc.
        ENDIF.
        SELECT SINGLE * FROM ZBYHR_T011 WHERE bukrs EQ gt_p-bukrs
                                          AND ( kostl EQ gt_p-kostl
                                           OR   kostl EQ gv_kostl_nc ).
        IF sy-subrc NE 0.
          gt_p-msgty = 'E'.
          gt_p-color = 'C600'.
          gt_p-durm =
'EXCEL den gelen Masraf Yeri teşviklilerden olmalı!'.
        ENDIF.
      ENDIF.
      IF gt_p-kanun IS INITIAL.
        gt_p-msgty = 'E'.
        gt_p-color = 'C600'.
        gt_p-durm =
        'KANUN Boş!'.
      ENDIF.

      gt_p-say = 1.
      MODIFY gt_p.
    ENDLOOP. "LOOP AT gt_p
    IF sy-subrc NE 0.
      CLEAR gt_p.
      gt_p-pernr = it_datatab-pernr.
      gt_p-msgty = 'E'.
      gt_p-color = 'C600'.
      gt_p-durm =
      'EXCEL den gelen Sicil Seçim Kriterlerine Uygun Değil!'.

      APPEND gt_p.
      SORT gt_p BY pernr.
    ENDIF.
  ENDLOOP.

  SORT gt_p BY msgty durm pernr.


  PERFORM list_display USING 'GT_P' .


*&---------------------------------------------------------------------*
*&      Form  LIST_DISPLAY
*&---------------------------------------------------------------------*
FORM list_display USING ip_table .
* Move current program name to variable
  gv_repid = sy-repid.
* Define events
  PERFORM define_events.
* Prepare field catalog
  PERFORM prepare_field_catalog USING ip_table .
* Display it
  PERFORM display_alv_list USING ip_table.
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
  DATA: lv_text(30),
        lv_hide.
  DATA: lv_text1 TYPE stext,
        lv_text2 TYPE stext,
        lv_text3 TYPE stext,
        lv_text4 TYPE stext,
        lv_text5 TYPE stext,
        lv_text6 TYPE stext.

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

*  IF r_paa NE space.
*    lv_text = 'KOSTL/KTEXT'.
*  ELSEIF r_k NE space.
*    lv_text = 'WERKS/WTEXT/BTRTL/BTEXT'.
*  ENDIF.

  lv_n = 0.
  DO 25 TIMES.
    ADD 1 TO lv_n.
    CONCATENATE 'IT_DATATAB_HEAD-KPR' lv_n INTO lv_f1.
    ASSIGN (lv_f1) TO <f1>.
    IF sy-subrc EQ 0.
      lv_text = <f1>.
      CONCATENATE 'KPR' lv_n INTO lv_f2.
    ENDIF.
    CLEAR lv_hide.
    IF lv_text EQ space.
      lv_hide = 'X'.
    ENDIF.
    PERFORM list_set_attribute(zby_gen_alv_list)
                  TABLES pt_fieldcat
                  USING  p_tabname:

                         lv_f2
                         'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                         lv_text,

                         lv_f2
                         'NO_OUT'
                         lv_hide.

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

                       'ENAME'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Ad Soyad',

                       'SAY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Sayı',

                       'SAY'
                       'NO_OUT'
                       'X',

                       lv_text
                       'NO_OUT'
                       'X',

                       'MASSN/MNTXT/MASSG/MGTXT'
                       'NO_OUT'
                       'X',

                       'POZISYON/BORGO0/BORDE0'
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

*                       'BUKRS'
*                       'NO_OUT'
*                       'X',

                       'BUTXT'
                       'NO_OUT'
                       'X',

                       'SAYI'
                       'NO_OUT'
                       'X',

                       'ANRED/BIRIM/CAGRP/CAAGR/ABKRS/MSTBR'
                       'NO_OUT'
                       'X',

                       'ANSVH/ATX/'
                       'NO_OUT'
                       'X',

                       'KPRTP'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Toplam %',

                       'BEGDA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SAP Başlangıç',

                       'ENDDA'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SAP Son',

                       'KDHL1'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kontenjan Dahili',

                       'KDHL2'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Kontenjan Fazlaı',

                       'KANUN'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'SAP Kanun no',

                       'KANUNE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'EXCEL Kanun no',

                       'BEGDAE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'YENİ Başlangıç',

                       'ENDDAE'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'YENİ Son',

                       'KAFASAYISI'
                       'NO_OUT'
                       'X',

                       'SPMON'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Dönem',

                       'MSGTY'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Tip',

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

                       'DURM'
                       'REPTEXT_DDIC/SELTEXT_L/SELTEXT_M/SELTEXT_S'
                       'Durum',

                       'ENDDA'
                       'EDIT'
                       '',

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


  ls_line-info = 'PYP Öğelerinin Yüklenmesi'.
  APPEND ls_line TO gt_list_top_of_page.
  DESCRIBE TABLE gt_p LINES lv_num.

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

  DATA: wa_field LIKE gt_p. "TYPE x_data.
* Check function code
  CASE ip_ucomm.
    WHEN 'AKTAR'.
      CLEAR : it_data[] , wa_tab.
      LOOP AT gt_p INTO wa_field.
        IF wa_field-mark = 'X' AND
         ( wa_field-msgty EQ 'I' ).
          MOVE-CORRESPONDING wa_field TO wa_tab.
          APPEND wa_tab TO it_data.
        ENDIF.
      ENDLOOP.
      IF sy-subrc = 0.
        PERFORM insert_data_to_0027 .
      ENDIF.
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
*&---------------------------------------------------------------------*
*&      Form  INSERT_DATA_TO_0769
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM insert_data_to_0027 .
  DATA: ls_return    LIKE bapireturn1,
        gv_aufnr(12) TYPE n,
        lv_mod       TYPE actio, " zemail
        iv_dialog_mode TYPE c VALUE '0'.

  READ TABLE it_datatab_head INDEX 1.

  lv_mod = 'INS'.

  LOOP AT it_data INTO gt_p.

    CLEAR p0027.
*    MOVE-CORRESPONDING gt_p TO p0027.
    p0027-pernr = gt_p-pernr.
    p0027-begda = gt_p-begda.
    p0027-endda = gt_p-endda.
    p0027-infty = '0027'.
    p0027-kstar = '01  '.  "Ücret Maaş
    p0027-subty = '01  '.

    CLEAR: lv_n, lv_n1.
    DO 25 TIMES.

      ADD 1 TO lv_n.

      CONCATENATE 'GT_P' '-KPR' lv_n INTO lv_f6.
      ASSIGN: (lv_f6) TO <f6>.
      CHECK sy-subrc EQ 0 AND <f6> NE 0.

      ADD 1 TO lv_n1.
      CONCATENATE 'P0027' '-KBU' lv_n1 INTO lv_f5.
      ASSIGN: (lv_f5) TO <f5>.
      IF sy-subrc EQ 0.
        <f5> = gt_p-bukrs.
      ENDIF.

      CONCATENATE 'P0027' '-KST' lv_n1 INTO lv_f1.
      ASSIGN: (lv_f1) TO <f1>.
      IF sy-subrc EQ 0.
        <f1> = gt_p-kostl.
*        gv_kostl_nc = gt_p-kostl.
*        <f1> = gv_kostl_nc.
      ENDIF.

      CONCATENATE 'P0027' '-PSP' lv_n1 INTO lv_f3.
      ASSIGN: (lv_f3) TO <f3>.
      IF sy-subrc EQ 0.
        CONCATENATE 'IT_DATATAB_HEAD' '-KPR' lv_n INTO lv_f2.
        ASSIGN: (lv_f2) TO <f2>.
        IF sy-subrc EQ 0.
          CONDENSE <f2> NO-GAPS.  "Add by VS 11.07.2019
          SELECT SINGLE pspnr INTO <f3> FROM prps
                              WHERE posid EQ <f2>.
        ENDIF.
      ENDIF.

      CONCATENATE 'P0027-KPR' lv_n1 INTO lv_f4.
      ASSIGN (lv_f4) TO <f4>.
      IF sy-subrc EQ 0.
        <f4> = <f6>.
      ENDIF.

    ENDDO.


    PERFORM operation_pa_infty
                          USING p0027
                                ls_return
                                lv_mod
                                space
                                iv_dialog_mode.
    IF ls_return-type IS INITIAL.
*---OK
      LOOP AT gt_p WHERE pernr = gt_p-pernr
                   AND   begda = gt_p-begda
                   AND   endda = gt_p-endda.
        IF ( gt_p-mark = 'X' ).
          gt_p-msgty = 'S'.
          gt_p-color = '500'.
          gt_p-durm = 'PYP Öğeleri başarı ile atılmıştır!'.
        ENDIF.
        MODIFY gt_p.
      ENDLOOP.
    ELSE.
      LOOP AT gt_p WHERE pernr = gt_p-pernr
                   AND   begda = gt_p-begda
                   AND   endda = gt_p-endda.
        IF ( gt_p-mark = 'X' ).
          gt_p-msgty = 'E'.
          gt_p-color = '700'.
          CONCATENATE 'HATA:' ls_return-message INTO gt_p-durm.
        ENDIF.
        MODIFY gt_p.
      ENDLOOP.

    ENDIF.
    CLEAR ls_return.
  ENDLOOP.
ENDFORM.                    " INSERT_DATA_TO_0027
*---------------------------------------------------------------------*
*       FORM operation_pa_infty                                       *
*---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM operation_pa_infty USING is_nnnn
                              is_return    TYPE bapireturn1
                              iv_operation TYPE actio
                              iv_nocommit  LIKE bapi_stand-no_commit
                              iv_dialog_mode TYPE c.
  DATA : lt_key       LIKE bapipakey,
         lv_snnnn(10) VALUE 'IS_NNNN',
         ls_return    TYPE bapireturn1.

  FIELD-SYMBOLS: <lf_nnnn>  TYPE any,
                 <lf_infty> TYPE any,
                 <lf_pernr> TYPE any,
                 <lf_subty> TYPE any,
                 <lf_objps> TYPE any,
                 <lf_sprps> TYPE any,
                 <lf_endda> TYPE any,
                 <lf_begda> TYPE any,
                 <lf_seqnr> TYPE any.

  CLEAR is_return.
  ASSIGN (lv_snnnn) TO <lf_nnnn>.

  ASSIGN COMPONENT 'INFTY'  OF STRUCTURE <lf_nnnn> TO <lf_infty>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'PERNR'  OF STRUCTURE <lf_nnnn> TO <lf_pernr>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'SUBTY'  OF STRUCTURE <lf_nnnn> TO <lf_subty>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'OBJPS'  OF STRUCTURE <lf_nnnn> TO <lf_objps>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'SPRPS'  OF STRUCTURE <lf_nnnn> TO <lf_sprps>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'ENDDA'  OF STRUCTURE <lf_nnnn> TO <lf_endda>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'BEGDA'  OF STRUCTURE <lf_nnnn> TO <lf_begda>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.
  ASSIGN COMPONENT 'SEQNR'  OF STRUCTURE <lf_nnnn> TO <lf_seqnr>.
  IF sy-subrc <> 0.
    is_return-type = 'E'.
  ENDIF.

  CHECK is_return-type IS INITIAL.

  PERFORM lock_empoyee USING <lf_pernr>
                              is_return.
  CHECK is_return-type IS INITIAL.

  CALL FUNCTION 'HR_INFOTYPE_OPERATION'
    EXPORTING
      infty         = <lf_infty>
      number        = <lf_pernr>
      subtype       = <lf_subty>
      objectid      = <lf_objps>
      lockindicator = <lf_sprps>
      validityend   = <lf_endda>
      validitybegin = <lf_begda>
      recordnumber  = <lf_seqnr>
      record        = <lf_nnnn>
      operation     = iv_operation
      tclas         = 'A'
      dialog_mode   = iv_dialog_mode
      nocommit      = iv_nocommit
*     VIEW_IDENTIFIER        =
*     SECONDARY_RECORD       =
    IMPORTING
      return        = is_return
      key           = lt_key.

*  CHECK is_return-type IS INITIAL.

  PERFORM unlock_empoyee USING <lf_pernr>
                                ls_return.

ENDFORM.                    " operation_pa_infty
*&---------------------------------------------------------------------*
*&      Form  lock_empoyee
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lock_empoyee USING iv_pernr  LIKE prelp-pernr
                         is_return TYPE bapireturn1.
  CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
    EXPORTING
      number = iv_pernr
    IMPORTING
      return = is_return.
ENDFORM.                    "lock_empoyee

*&---------------------------------------------------------------------*
*&      Form  unlock_empoyee
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM unlock_empoyee USING iv_pernr  LIKE prelp-pernr
                           is_return TYPE bapireturn1.
  CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
    EXPORTING
      number = iv_pernr
    IMPORTING
      return = is_return.
ENDFORM.                    "unlock_empoyee
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
