*&---------------------------------------------------------------------*
*& Include          ZBYHR_HTRCALC0
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  init_objects_natio
*&---------------------------------------------------------------------*
FORM init_objects_natio.
  IF pnpstat2[] IS INITIAL .
    pnpstat2 = 'IEQ3'. COLLECT pnpstat2.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  fuzbyhr
*&---------------------------------------------------------------------*
FORM fuzbyhr .

  CASE as-parm1.
    WHEN '01'. PERFORM split_payroll .
    WHEN '02'. "PYP bazlı teşvik dağılımı
      PERFORM pyp_tesvik.
    WHEN '03'. PERFORM zgrtz. "Görev Tazminatı

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  split_payroll
*&---------------------------------------------------------------------*
FORM split_payroll.

  "ay ortasında işyeri değişikliği veya ssk grubu değişmişse
*  LOOP AT wpbp WHERE massn = '02' AND ( massg = '01' or massg = '05' ).
  DATA : lv_btrtl TYPE btrtl,
         lv_kostl TYPE kostl,
         lv_betrg TYPE betrg.

  LOOP AT wpbp INTO DATA(ls_wpbp).
    IF ls_wpbp-btrtl NE lv_btrtl
      AND lv_btrtl IS NOT INITIAL.
      DATA(lv_flag) = 'X'.
    ENDIF.

    IF ls_wpbp-aktivjn EQ 'X'.

      IF ( ls_wpbp-kostl NE lv_kostl
       AND lv_kostl IS NOT INITIAL ) .
        DATA(lv_flag2) = 'X'.
      ENDIF.

      SELECT SINGLE bet01 FROM pa0008  INTO @DATA(lv_bet01)
                                       WHERE pernr EQ @pernr-pernr
                                         AND begda LE @ls_wpbp-endda
                                         AND endda GE @ls_wpbp-begda.
      IF lv_betrg NE lv_bet01
        AND lv_betrg IS NOT INITIAL.
        lv_flag2 = 'X'.
      ENDIF.

      lv_betrg = lv_bet01.
      lv_kostl = ls_wpbp-kostl.
    ENDIF.
    lv_btrtl = ls_wpbp-btrtl.
  ENDLOOP.

  IF lv_flag EQ 'X'.
    var-lgart = 'ZSPL'.
    var-anzhl = 1.
    APPEND var.  CLEAR var .

    var-lgart = 'ZSP2'.
    var-anzhl = 1.
    APPEND var.  CLEAR var .
  ENDIF.


  IF lv_flag2 EQ 'X'.
    var-lgart = 'ZSP2'.
    var-anzhl = 1.
    APPEND var.  CLEAR var .
  ENDIF.



  LOOP AT var WHERE lgart = 'ZSPL'
                AND anzhl NE 0.
  ENDLOOP.
  CHECK sy-subrc NE 0.
  LOOP AT p0769 WHERE pernr = pernr-pernr
                  AND begda <= aper-endda
                  AND endda >= aper-begda
                  AND bkodu = '02'.
  ENDLOOP.
  IF sy-subrc EQ 0.
    DATA(lv_lines) = lines( p0769[] ).
    IF lv_lines GT 1.
      LOOP AT p0769 INTO DATA(ls_p0769) FROM 1 TO lv_lines - 1.
        IF ls_p0769-bkodu NE p0769-bkodu.
          var-lgart = 'ZSPL'.
          var-anzhl = 1.
          APPEND var.  CLEAR var .

          var-lgart = 'ZSP2'.
          var-anzhl = 1.
          APPEND var.  CLEAR var .
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form pyp_tesvik
*&---------------------------------------------------------------------*
FORM pyp_tesvik .

  DATA: lv_n032 TYPE betrg.
  DATA: lv_n03 TYPE betrg.
  DATA: lv_s032 TYPE betrg.
  DATA: lv_s03 TYPE betrg.
  DATA: lv_n102 TYPE betrg.
  DATA: lv_n10 TYPE betrg.
  DATA: lv_s052 TYPE betrg.
  DATA: lv_s05 TYPE betrg.
  DATA: lv_total TYPE anzhl.
  DATA: lv_seqnr(4) TYPE n VALUE 1.
  DATA : gt_0769 LIKE pa0769 OCCURS 0 WITH HEADER LINE .
  DATA : ls_0771     LIKE pa0771,
         lv_n032_sum TYPE betrg,
         lv_s032_sum TYPE betrg,
         lv_n102_sum TYPE betrg,
         lv_s052_sum TYPE betrg.

  DATA: lv_stext LIKE  t7tri04-stext.

  FREE : gt_0769.



  SELECT SINGLE * INTO ls_0771 FROM pa0771
                                     WHERE pernr = pernr-pernr
                                     AND   begda LE pn-endda
                                     AND   endda GE pn-begda.

  SELECT * FROM pa0769 INTO TABLE gt_0769 WHERE pernr = pernr-pernr
                                            AND   begda LE pn-endda
                                            AND   endda GE pn-begda.

  LOOP AT gt_0769.

*---Begin of 1855302 - User Exit for TRTAX (PCTAXTR0)
    CLEAR : lv_stext .
    SELECT SINGLE stext INTO lv_stext FROM t7tri04
                          WHERE borgo = ls_0771-borgo0
                          AND   borde = ls_0771-borde0.
    IF sy-subrc EQ 0.
      gt_0769-kanun = lv_stext+0(5).
    ENDIF.
*---End of 1855302 - User Exit for TRTAX (PCTAXTR0)


    IF gt_0769-kanun EQ '05746' OR gt_0769-kanun EQ '85746' OR gt_0769-kanun EQ '95746'
      OR ( gt_0769-kanun EQ space
         AND ls_0771-borgo0 EQ '01'
         AND ls_0771-borde0 BETWEEN '01' AND '03' ).

      LOOP AT rt WHERE lgart EQ '9N03' OR lgart EQ '9S03' OR lgart EQ '9N10' OR lgart EQ '9S05'.
        IF rt-lgart EQ '9N03'.
          lv_n032 = lv_n03 = rt-betrg.
        ELSEIF rt-lgart EQ '9S03'.
          lv_s032 = lv_s03 = rt-betrg.
        ENDIF.
        IF rt-lgart EQ '9N10'.
          lv_n102 = lv_n10 = rt-betrg.
        ELSEIF rt-lgart EQ '9S05'.
          lv_s052 = lv_s05 = rt-betrg.
        ENDIF.
      ENDLOOP.

      LOOP AT c0.
        lv_total = lv_total + c0-kprnn.
      ENDLOOP.

      SORT c1 DESCENDING BY c1znr.
      LOOP AT c1.
        EXIT.
      ENDLOOP.
      IF sy-subrc EQ 0.
        lv_seqnr = c1-c1znr + 1.
      ENDIF.
      CLEAR c1.
      LOOP AT c0.
        lv_n03 = lv_n032 * c0-kprnn / lv_total.
        ADD lv_n03 TO lv_n032_sum.
        AT LAST.
          IF lv_n032_sum NE lv_n032.
            lv_n03 = lv_n03 + lv_n032 - lv_n032_sum.
          ENDIF.
        ENDAT.
        rt-lgart = '/N03'.
        rt-betrg = lv_n03.
        rt-c1znr = lv_seqnr.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        c1-c1znr = lv_seqnr.
        c1-bukrs = c0-kbunn.
        c1-kostl = c0-kstnn.
        IF wpbp-bukrs EQ '1000'.
          c1-kokrs = '1000'.
        ENDIF.
        IF wpbp-bukrs EQ '1210'.
          c1-kokrs = '1210'.
        ENDIF.
        IF wpbp-bukrs EQ '1800'.
          c1-kokrs = '1800'.
        ENDIF.
        IF wpbp-bukrs EQ '1910'.
          c1-kokrs = '1910'.
        ENDIF.
        IF wpbp-bukrs EQ '1950'.
          c1-kokrs = '1950'.
        ENDIF.
        IF wpbp-bukrs EQ '2310'.
          c1-kokrs = '2310'.
        ENDIF.
        IF wpbp-bukrs EQ '5000'.
          c1-kokrs = '5000'.
        ENDIF.
        IF wpbp-bukrs EQ '6000'.
          c1-kokrs = '6000'.
        ENDIF.
        IF wpbp-bukrs EQ '8800'.
          c1-kokrs = '8800'.
        ENDIF.
        c1-posnr = c0-pspnn.
        APPEND c1.CLEAR c1.

        lv_seqnr = lv_seqnr + 1.
        lv_s03 = lv_s032 * c0-kprnn / lv_total.
        ADD lv_s03 TO lv_s032_sum.
        AT LAST.
          IF lv_s032_sum NE lv_s032.
            lv_s03 = lv_s03 + lv_s032 - lv_s032_sum.
          ENDIF.
        ENDAT.
        rt-lgart = '/S03'.
        rt-betrg = lv_s03.
        rt-c1znr = lv_seqnr.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        c1-c1znr = lv_seqnr.
        c1-bukrs = c0-kbunn.
        c1-kostl = c0-kstnn.
        IF wpbp-bukrs EQ '1000'.
          c1-kokrs = '1000'.
        ENDIF.
        IF wpbp-bukrs EQ '1210'.
          c1-kokrs = '1210'.
        ENDIF.
        IF wpbp-bukrs EQ '1800'.
          c1-kokrs = '1800'.
        ENDIF.
        IF wpbp-bukrs EQ '1910'.
          c1-kokrs = '1910'.
        ENDIF.
        IF wpbp-bukrs EQ '1950'.
          c1-kokrs = '1950'.
        ENDIF.
        IF wpbp-bukrs EQ '2310'.
          c1-kokrs = '2310'.
        ENDIF.
        IF wpbp-bukrs EQ '5000'.
          c1-kokrs = '5000'.
        ENDIF.
        IF wpbp-bukrs EQ '6000'.
          c1-kokrs = '6000'.
        ENDIF.
        IF wpbp-bukrs EQ '8800'.
          c1-kokrs = '8800'.
        ENDIF.
        c1-posnr = c0-pspnn.
        APPEND c1.CLEAR c1.

        lv_seqnr = lv_seqnr + 1.
        lv_n10 = lv_n102 * c0-kprnn / lv_total.
        ADD lv_n10 TO lv_n102_sum.
        AT LAST.
          IF lv_n102_sum NE lv_n102.
            lv_n10 = lv_n10 + lv_n102 - lv_n102_sum.
          ENDIF.
        ENDAT.
        rt-lgart = '/N10'.
        rt-betrg = lv_n10.
        rt-c1znr = lv_seqnr.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        c1-c1znr = lv_seqnr.
        c1-bukrs = c0-kbunn.
        c1-kostl = c0-kstnn.
        IF wpbp-bukrs EQ '1000'.
          c1-kokrs = '1000'.
        ENDIF.
        IF wpbp-bukrs EQ '1210'.
          c1-kokrs = '1210'.
        ENDIF.
        IF wpbp-bukrs EQ '1800'.
          c1-kokrs = '1800'.
        ENDIF.
        IF wpbp-bukrs EQ '1910'.
          c1-kokrs = '1910'.
        ENDIF.
        IF wpbp-bukrs EQ '1950'.
          c1-kokrs = '1950'.
        ENDIF.
        IF wpbp-bukrs EQ '2310'.
          c1-kokrs = '2310'.
        ENDIF.
        IF wpbp-bukrs EQ '5000'.
          c1-kokrs = '5000'.
        ENDIF.
        IF wpbp-bukrs EQ '6000'.
          c1-kokrs = '6000'.
        ENDIF.
        IF wpbp-bukrs EQ '8800'.
          c1-kokrs = '8800'.
        ENDIF.
        c1-posnr = c0-pspnn.
        APPEND c1.CLEAR c1.

        lv_seqnr = lv_seqnr + 1.
        lv_s05 = lv_s052 * c0-kprnn / lv_total.
        ADD lv_s05 TO lv_s052_sum.
        AT LAST.
          IF lv_s052_sum NE lv_s052.
            lv_s05 = lv_s05 + lv_s052 - lv_s052_sum.
          ENDIF.
        ENDAT.
        rt-lgart = '/S05'.
        rt-betrg = lv_s05.
        rt-c1znr = lv_seqnr.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        c1-c1znr = lv_seqnr.
        c1-bukrs = c0-kbunn.
        c1-kostl = c0-kstnn.
        IF wpbp-bukrs EQ '1000'.
          c1-kokrs = '1000'.
        ENDIF.
        IF wpbp-bukrs EQ '1210'.
          c1-kokrs = '1210'.
        ENDIF.
        IF wpbp-bukrs EQ '1800'.
          c1-kokrs = '1800'.
        ENDIF.
        IF wpbp-bukrs EQ '1910'.
          c1-kokrs = '1910'.
        ENDIF.
        IF wpbp-bukrs EQ '1950'.
          c1-kokrs = '1950'.
        ENDIF.
        IF wpbp-bukrs EQ '2310'.
          c1-kokrs = '2310'.
        ENDIF.
        IF wpbp-bukrs EQ '5000'.
          c1-kokrs = '5000'.
        ENDIF.
        IF wpbp-bukrs EQ '6000'.
          c1-kokrs = '6000'.
        ENDIF.
        IF wpbp-bukrs EQ '8800'.
          c1-kokrs = '8800'.
        ENDIF.
        c1-posnr = c0-pspnn.
        APPEND c1.CLEAR c1.

        lv_seqnr = lv_seqnr + 1.
      ENDLOOP.

      IF sy-subrc NE 0.

        rt-lgart = '/N03'.
        rt-betrg = lv_n03.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        rt-lgart = '/S03'.
        rt-betrg = lv_s03.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        rt-lgart = '/N10'.
        rt-betrg = lv_n10.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

        rt-lgart = '/S05'.
        rt-betrg = lv_s05.
        rt-abart = '*'.
        IF rt-betrg NE 0.
          APPEND rt. CLEAR rt.
        ENDIF.

      ENDIF.


      SORT c1 ASCENDING BY c1znr.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ZGRTZ - Görev Tazminatı
*&---------------------------------------------------------------------*
FORM zgrtz.
  DATA : lv_vars TYPE anzhl.
  DATA : lv_begda TYPE endda .
  DATA : lv_endda TYPE endda .



  LOOP AT it INTO DATA(ls_ndy) WHERE lgart EQ '/NDY'.
    LOOP AT ait INTO DATA(ls_zucr) WHERE apznr EQ ls_ndy-apznr
                                     AND lgart EQ 'ZUCR'.
    ENDLOOP.
    LOOP AT ait INTO DATA(ls_zucs) WHERE apznr EQ ls_ndy-apznr
                                     AND lgart EQ 'ZUCS'.
    ENDLOOP.

    lv_begda = aper-begda.
    lv_endda = aper-endda.
    LOOP AT wpbp WHERE apznr EQ ls_ndy-apznr.ENDLOOP.
    IF wpbp-endda LT aper-endda.
      lv_endda = wpbp-endda.
    ENDIF.
    IF wpbp-begda GT aper-begda.
      lv_begda = wpbp-begda.
    ENDIF.
    CLEAR p0771.
    LOOP AT p0771 WHERE begda LE lv_endda AND endda GE lv_begda.ENDLOOP.

    CHECK p0771-borde3 IS NOT INITIAL .
    SELECT SINGLE * INTO @DATA(ls_t019) FROM zbyhr_t019
              WHERE btrtl EQ @wpbp-btrtl
                AND borde EQ @p0771-borde3
                AND begda LE @lv_endda
                AND endda GE @lv_begda.
    CHECK sy-subrc EQ 0 .


    " abart ve apznr için
    LOOP AT it INTO DATA(ls_7016) WHERE lgart EQ '7016 '.ENDLOOP.

    it-abart = ls_ndy-abart.
    it-apznr = ls_ndy-apznr.
    it-lgart = '3487'.

    CASE ls_ndy-anzhl.
      WHEN 30.
        IF ls_zucr-anzhl EQ 0 .
          lv_vars = 30.
        ELSEIF ls_zucr-anzhl GT 0.
          lv_vars = ( ( lv_endda - lv_begda ) + 1 ) - ls_zucr-anzhl.
        ENDIF.
      WHEN OTHERS.
        lv_vars = ( ( lv_endda - lv_begda ) + 1 ) - ls_zucr-anzhl - ls_zucs-anzhl - ls_7016-anzhl.

    ENDCASE.

    it-betrg = ( ls_t019-tutar / 30 ) * ( lv_vars ).
    it-anzhl =  lv_vars .

    APPEND it.  CLEAR it.
  ENDLOOP.

ENDFORM.
