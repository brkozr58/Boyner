class ZBYHR_HRPAYTR_ICM00 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_HRPAYTR_ICM00 .
protected section.
private section.
ENDCLASS.



CLASS ZBYHR_HRPAYTR_ICM00 IMPLEMENTATION.


  METHOD if_ex_hrpaytr_icm00~change_fieldcatalog.
    DATA: ls_fcat TYPE lvc_s_fcat.
    DATA: lv_i TYPE i .

    DEFINE add_fcat.
      DESCRIBE TABLE it_fcat LINES lv_i.
               ls_fcat-col_pos   = lv_i + 1 .
               ls_fcat-fieldname = &1.
               ls_fcat-outputlen = &2.
               ls_fcat-tabname   = '1'.
               ls_fcat-coltext   = &3.
               ls_fcat-datatype  = &4.
               APPEND ls_fcat TO it_fcat.
               CLEAR ls_fcat.
    END-OF-DEFINITION.

    add_fcat :
    'APZNR'       2  'İşyerine tayin'              'NUMC',
    'SGMNT'       10 'Segment Kodu'                'CHAR',
    'SGMNT_T'     50 'Segment Metni'               'CHAR',
    'MERNI'       50 'TC Kimlik No.'               'CHAR',
    'ANSVH'       2  'İstihdam Koşulu Kodu'        'CHAR',
    'ANSVH_T'     15 'İstihdam Koşulu Metni'       'CHAR',
    'GBDAT'       10 'Doğum tarihi'                'DATS',
    'IBAN'        15 'IBAN'                        'CHAR',
    'HIRED'       10 'İşe Giriş Tarihi'            'DATS',
    'FIRED'       10 'İşten Çıkış Tarihi'          'DATS',
    'MASSG_T'     30 'İşten Çıkış Nedeni'          'CHAR',
    'DISAB'       50 'Engellilik Derecesi'         'CHAR',
    'DISAB_T'     20 'Engellilik Derecesi Metni'   'CHAR',
    'GLRVE'       3  'Engellilik Oranı'            'CHAR',
    'KANUN'       5  'Kanun Numarası'              'CHAR',
    'SSGRP'       2  'Sosyal Güvenlik Grubu'       'CHAR',
    'SSGRP_T'     20 'Sosyal Güvenlik Grubu Metni' 'CHAR',

    'DAT02'       10 'Gruba İlk Giriş Tarihi'      'DATS',
    'DAT03'       10 'Kıdem Baz Tarihi'            'DATS',
    'DAT04'       10 'İzin Hakediş Tarihi'         'DATS',
    'DAT05'       10 'Ödüle Baz Tarihi'            'DATS',
    'DAT06'       10 'Emeklilik Tarihi'            'DATS',
    'DAT07'       10 'SGK ya ilk Giriş Tarihi'     'DATS',
    'ZAPZNR'       5 'Kişi Sayısı'                 'INT2'.

  ENDMETHOD.


  METHOD if_ex_hrpaytr_icm00~set_additional_fields.

    DATA : l_wpbp(30)  TYPE c VALUE '((ZHTRICM00)IS_RESULT-INTER-WPBP',
           l_begda(30) TYPE c VALUE '(ZHTRICM00)B_BEGDA',
           l_endda(30) TYPE c VALUE '(ZHTRICM00)B_ENDDA'.

    DATA : lt_t7trs01 TYPE TABLE OF t7trs01.
    DATA : lt_t7trt03 TYPE TABLE OF t7trt03.

    DATA : lt_fagl_segmt  TYPE TABLE OF fagl_segmt .
    FIELD-SYMBOLS <fs> TYPE any.
    FIELD-SYMBOLS <ft_wpbp> TYPE hrpay99_wpbp.
    FIELD-SYMBOLS <ft_data> TYPE table .

    DATA : is_ok            TYPE  boole_d.
    DATA : lv_apznr            TYPE  numc2.
    STATICS: message_handler  TYPE REF TO cl_hrpl_masterdata_messages.

    ASSIGN lt_tab->* TO <ft_data>.
    IF message_handler IS INITIAL.
      CREATE OBJECT message_handler.
    ENDIF..

    DEFINE get_0041_date .
      ASSIGN COMPONENT &4 OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        CALL FUNCTION 'HR_ECM_GET_DATETYP_FROM_IT0041'
          EXPORTING
            pernr           = &1
            keydt           = &2
            datar           = &3
            message_handler = message_handler
          IMPORTING
            date            = <fs>
            is_ok           = is_ok.
      ENDIF.
      UNASSIGN <fs>.
    END-OF-DEFINITION.


    ASSIGN (l_wpbp) TO <ft_wpbp> .
    ASSIGN (l_begda) TO FIELD-SYMBOL(<begda>) .
    ASSIGN (l_endda) TO FIELD-SYMBOL(<endda>) .
    IF <begda> IS NOT ASSIGNED AND <endda> IS NOT ASSIGNED  .
      l_wpbp = '(HTRICM00)IS_RESULT-INTER-WPBP'.
      l_begda = '(HTRICM00)S_BEGDA'.
      l_endda = '(HTRICM00)S_ENDDA'.
      l_endda = '(HTRICM00)S_ENDDA'.
      ASSIGN (l_begda) TO <begda> .
      ASSIGN (l_endda) TO <endda> .
      ASSIGN (l_wpbp) TO <ft_wpbp> .
    ENDIF.

    ASSIGN l_data TO FIELD-SYMBOL(<l_data>).
    ASSIGN COMPONENT 'PERNR' OF STRUCTURE <l_data> TO FIELD-SYMBOL(<pernr>).

    DESCRIBE TABLE <ft_data> LINES lv_apznr.

    LOOP AT <ft_wpbp> INTO DATA(ls_wpbp) WHERE aktivjn EQ 'X'.
*    LOOP AT <ft_wpbp> INTO DATA(ls_wpbp) WHERE apznr GT lv_apznr
*                                           AND aktivjn EQ 'X'.

      SELECT * FROM t529t INTO TABLE @DATA(lt_massnt)
             WHERE sprsl EQ @sy-langu .

      SELECT * FROM t530t INTO TABLE @DATA(lt_massgt)
          FOR ALL ENTRIES IN @lt_massnt
             WHERE massn EQ @lt_massnt-massn
               AND sprsl EQ @sy-langu .

      SELECT * FROM t7trs01 INTO TABLE lt_t7trs01.
      SELECT * FROM t7trt03 INTO TABLE lt_t7trt03
           WHERE endda GE <begda>
             AND begda LE <endda>.
      SELECT * FROM fagl_segmt INTO TABLE lt_fagl_segmt.

      SELECT * FROM t542t INTO TABLE @DATA(lt_ansvh)
             WHERE spras EQ @sy-langu
               AND molga EQ '47'.

      SELECT * FROM pa0000 INTO @DATA(ls_hired)
             WHERE pernr EQ @<pernr>
               AND begda LE @ls_wpbp-begda  "<BEGDA>
               AND ( massn EQ '01' OR massn EQ '12' ) .
      ENDSELECT.

      SELECT * FROM pa0000 INTO @DATA(ls_fired)
             WHERE pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND massn EQ '10'  .
      ENDSELECT.

      SELECT SINGLE * FROM pa0001 INTO @DATA(ls_0001)
             WHERE pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND begda LE @ls_wpbp-endda ." <ENDDA>.

      SELECT SINGLE * FROM pa0002 INTO @DATA(ls_0002)
             WHERE pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND begda LE @ls_wpbp-endda ." <ENDDA>.

      SELECT SINGLE * FROM pa0009 INTO @DATA(ls_0009)
             WHERE pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND begda LE @ls_wpbp-endda ." <ENDDA>.

      SELECT SINGLE * FROM pa0769 INTO @DATA(ls_0769)
             WHERE pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND begda LE @ls_wpbp-endda ." <ENDDA>.

      SELECT SINGLE * FROM pa0770 INTO @DATA(ls_0770)
             WHERE subty EQ '01'
               AND pernr EQ @<pernr>
               AND endda GE @ls_wpbp-begda  "<BEGDA>
               AND begda LE @ls_wpbp-endda ." <ENDDA>.

      "
      ASSIGN COMPONENT 'APZNR' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_wpbp-apznr.
      ENDIF.
      UNASSIGN <fs>.

     " iş yerine tayin toplam alanı
      ASSIGN COMPONENT 'ZAPZNR' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_wpbp-apznr.
      ENDIF.
      UNASSIGN <fs>.

      " İŞE GIRIŞ TARIHI
      ASSIGN COMPONENT 'HIRED' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_hired-begda.
      ENDIF.
      UNASSIGN <fs>.

      " İŞTEN ÇıKıŞ TARIHI
      ASSIGN COMPONENT 'FIRED' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_fired-begda.
      ENDIF.
      UNASSIGN <fs>.

      " SEGMENT KODU
      ASSIGN COMPONENT 'SGMNT' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0001-sgmnt.
      ENDIF.
      UNASSIGN <fs>.


      " SEGMENT METNI
      IF ls_0001-sgmnt IS NOT INITIAL.
        READ TABLE lt_fagl_segmt INTO DATA(ls_fagl_segmt) WITH KEY segment = ls_0001-sgmnt.
        IF sy-subrc EQ 0 .
          ASSIGN COMPONENT 'SGMNT_T' OF STRUCTURE <l_data> TO <fs>.
          IF <fs> IS ASSIGNED.
            <fs> = ls_fagl_segmt-name.
          ENDIF.
          UNASSIGN <fs>.
        ENDIF.
      ENDIF.

      " İŞTEN ÇıKıŞ NEDENI
      IF ls_fired IS NOT INITIAL.
        READ TABLE lt_massgt INTO DATA(ls_massgt) WITH KEY massn = ls_fired-massn massg = ls_fired-massg.
        IF sy-subrc EQ 0 .
          ASSIGN COMPONENT 'MASSG_T' OF STRUCTURE <l_data> TO <fs>.
          IF <fs> IS ASSIGNED.
            <fs> = ls_massgt-mgtxt.
          ENDIF.
          UNASSIGN <fs>.
        ENDIF.
      ENDIF.

      " İSTIHDAM KOŞULU KODU
      ASSIGN COMPONENT 'ANSVH' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0001-ansvh.
      ENDIF.
      UNASSIGN <fs>.

      " İSTIHDAM KOŞULU METNI
      READ TABLE lt_ansvh INTO DATA(ls_ansvh) WITH KEY ansvh = ls_0001-ansvh.
      IF sy-subrc EQ 0 .
        ASSIGN COMPONENT 'ANSVH_T' OF STRUCTURE <l_data> TO <fs>.
        IF <fs> IS ASSIGNED.
          <fs> = ls_ansvh-atx.
        ENDIF.
        UNASSIGN <fs>.
      ENDIF.

      " DOĞUM TARIHI
      ASSIGN COMPONENT 'GBDAT' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0002-gbdat.
      ENDIF.
      UNASSIGN <fs>.

      " IBAN
      ASSIGN COMPONENT 'IBAN' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0009-iban.
      ENDIF.
      UNASSIGN <fs>.

      " ENGELLILIK DERECESI
      ASSIGN COMPONENT 'DISAB' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0769-disab.
      ENDIF.
      UNASSIGN <fs>.

      " ENGELLILIK DERECESI METNI
      READ TABLE lt_t7trt03 INTO DATA(ls_t7trt03) WITH KEY disab = ls_0769-disab.
      IF sy-subrc EQ 0 .
        ASSIGN COMPONENT 'DISAB_T' OF STRUCTURE <l_data> TO <fs>.
        IF <fs> IS ASSIGNED.
          <fs> = ls_t7trt03-dtext.
        ENDIF.
        UNASSIGN <fs>.
      ENDIF.

      " KANUN NUMARASı
      ASSIGN COMPONENT 'KANUN' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0769-kanun.
      ENDIF.
      UNASSIGN <fs>.

      " ENGELLILIK ORANı
      ASSIGN COMPONENT 'GLRVE' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0769-glrve.
      ENDIF.
      UNASSIGN <fs>.

      "SEGMENT KODU
      ASSIGN COMPONENT 'SSGRP' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0769-ssgrp .
      ENDIF.
      UNASSIGN <fs>.

      " SOSYAL GÜVENLIK GRUBU METNI
      READ TABLE lt_t7trs01 INTO DATA(ls_t7trs01) WITH KEY ssgrp = ls_0769-ssgrp.
      IF sy-subrc EQ 0 .
        ASSIGN COMPONENT 'SSGRP_T' OF STRUCTURE <l_data> TO <fs>.
        IF <fs> IS ASSIGNED.
          <fs> = ls_t7trs01-sstxt.
        ENDIF.
        UNASSIGN <fs>.
      ENDIF.

      "TC KIMLIK NO.
      ASSIGN COMPONENT 'MERNI' OF STRUCTURE <l_data> TO <fs>.
      IF <fs> IS ASSIGNED.
        <fs> = ls_0770-merni.
      ENDIF.
      UNASSIGN <fs>.

*<BEGDA>
      get_0041_date : <pernr> ls_wpbp-begda '02' 'DAT02', " GRUBA İLK GIRIŞ TARIHI
                      <pernr> ls_wpbp-begda '03' 'DAT03', " KıDEM BAZ TARIHI
                      <pernr> ls_wpbp-begda '04' 'DAT04', " İZIN HAKEDIŞ TARIHI
                      <pernr> ls_wpbp-begda '05' 'DAT05', " ÖDÜLE BAZ TARIHI
                      <pernr> ls_wpbp-begda '06' 'DAT06', " EMEKLILIK TARIHI
                      <pernr> ls_wpbp-begda '07' 'DAT07'. " SGK YA ILK GIRIŞ TARIHI

*
      DESCRIBE TABLE <ft_data> LINES lv_apznr.
      IF lv_apznr IS INITIAL .
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
