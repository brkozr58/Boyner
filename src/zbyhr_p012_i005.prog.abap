*&---------------------------------------------------------------------*
*& Include          ZBYHR_P002_I005
*&---------------------------------------------------------------------*

FORM fill_personel_data .

*  CHECK p0027-kst01 IN s_kst01 .
*---Is there Any Payroll Result
  cd-key-pernr = pernr-pernr.
  rp-imp-c2-cd.

  LOOP AT period.
*---Check p0001
    LOOP AT p0001 WHERE begda LE period-endda
                  AND   endda GE period-begda.
    ENDLOOP.
    IF sy-subrc NE 0.
      LOOP AT p0001.ENDLOOP.
    ENDIF.

    "<---sezgin - 05.12.2012
    LOOP AT p0027 WHERE begda LE period-endda
                  AND   endda GE period-begda.
    ENDLOOP.
    "--->sezgin - 05.12.2012


    AUTHORITY-CHECK OBJECT 'P_ORGIN' FOR USER sy-uname
        ID 'AUTHC' FIELD '*'
        ID 'PERSA' FIELD p0001-werks
        ID 'PERSG' FIELD p0001-persg
        ID 'PERSK' FIELD p0001-persk.
    CHECK sy-subrc EQ 0.


    IF  rp-imp-cd-subrc EQ 0.
* Basliktaki Toplam Bilgilerinin Hesaplanmasi
      READ TABLE rgdir WITH KEY fpper = period-fpper srtza = p_srtza.
      IF sy-subrc EQ 0.
        READ TABLE gt_count INTO gs_count
        WITH KEY pernr = pernr-pernr.
        IF sy-subrc <> 0.
          PERFORM calculate_people_number .
          gs_count-pernr = pernr-pernr.
          COLLECT gs_count INTO gt_count.
        ENDIF.
      ENDIF .

      DATA : lt_w     LIKE TABLE OF  w,
             lt_total LIKE TABLE OF  total,
             lt_kostl LIKE TABLE OF  gt_kostl.

      IF p_srtza EQ 'A' .
*        PERFORM fill_wages_to_son USING 'A'  1.
        PERFORM fill_wages_to_son2 TABLES lt_w
                                          lt_total
                                          lt_kostl
                                    USING 'A'
                                          1      .
      ENDIF.
      IF p_srtza EQ 'P' .
*        PERFORM fill_wages_to_son USING 'P'  1.
        PERFORM fill_wages_to_son2 TABLES lt_w
                                          lt_total
                                          lt_kostl
                                    USING 'P'
                                          1      .
      ENDIF.
      IF p_srtza EQ 'F' .
        CLEAR check_p.
*        PERFORM fill_wages_to_son USING 'P' -1.
        PERFORM fill_wages_to_son2 TABLES lt_w
                                          lt_total
                                          lt_kostl
                                    USING 'P'
                                          -1      .
        CHECK check_p EQ 'X'.
*        PERFORM fill_wages_to_son USING 'A'  1.
        PERFORM fill_wages_to_son2 TABLES lt_w
                                          lt_total
                                          lt_kostl
                                    USING 'A'
                                          -1      .
      ENDIF.

*      IF p_ort EQ 'X'.
*        PERFORM add_ort_uct.
*      ENDIF.
      SORT w .
    ENDIF.

  ENDLOOP.
ENDFORM.                    " fill_personel_data
*&---------------------------------------------------------------------*
*&      Form  fill_wages_to_p2 önceki ve aktif ücret hesaplama
*&---------------------------------------------------------------------*
FORM fill_wages_to_p2 USING p_srtza TYPE c p_mul TYPE i.

  FIELD-SYMBOLS : <val01> TYPE any,
                  <val02> TYPE any,
                  <m>     TYPE any,
                  <kpr>   TYPE any.
  DATA : lv_check TYPE c .
  DATA : w_rt LIKE rt.
  DATA : lv_fname(20).
  DATA : lv_fname2(20).
  DATA : lr_apznr TYPE RANGE OF apznr .
  DATA : ls_apznr LIKE LINE OF lr_apznr.

  DATA : lv_count TYPE n.
  CLEAR: lv_count.
  DATA : lv_kn(2) TYPE n.
  DATA : lv_ddntk TYPE c.

  DATA : lv01 LIKE gt_kostl-val01.
  DATA : lv02 LIKE gt_kostl-val01.

  DATA : lv_kpr LIKE p0027-kpr01 VALUE 100 .
  DATA : lv_27.

  DATA : lv_tabix TYPE sy-tabix.

  DEFINE move_filter.
    CLEAR lv_tabix.
    LOOP AT ssort.
      lv_tabix = sy-tabix.
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
        IF p0027 IS NOT INITIAL AND lv_27 NE 'X'.
          CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
        ELSE.
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ENDIF.
      ELSE .
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF .

      ASSIGN (lv_fname) TO <m> .

      CASE lv_tabix .
        WHEN 1.
          gt_kostl-val01 = w-val01 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> w-txt01 .
          gt_kostl-txt01 = w-txt01 .
        WHEN 2.
          ASSIGN (lv_fname) TO <m> .
          gt_kostl-val02 = w-val02 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> w-txt02 .
          gt_kostl-txt02 = w-txt02.
      ENDCASE.
    ENDLOOP.
    &1 = gt_kostl-val01.
    &2 = gt_kostl-val02.
**********************************************************************
  END-OF-DEFINITION.

*-----
  READ TABLE rgdir WITH KEY fpper = period-fpper srtza = p_srtza.
  CHECK sy-subrc EQ 0.
  check_p = 'X'.
  rx-key-pernr = pernr-pernr.
  UNPACK rgdir-seqnr TO rx-key-seqno.

* Control Data Cluster
  CASE t500l-relid.
    WHEN 'TR'.  rp-imp-c2-tr.
    WHEN 'RX'.  rp-imp-c2-rx.
  ENDCASE.

  DATA : lv_rt LIKE rt OCCURS 0 WITH HEADER LINE.
  MOVE rt[] TO lv_rt[].
*----

  LOOP AT wpbp INTO DATA(s_wpbp) WHERE aktivjn EQ 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.

  REFRESH lr_apznr.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  LOOP AT wpbp INTO s_wpbp WHERE btrtl IN pnpbtrtl.
    ls_apznr-low = s_wpbp-apznr .
    APPEND ls_apznr TO lr_apznr.
  ENDLOOP.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  ls_apznr-low = '00' .
  APPEND ls_apznr TO lr_apznr.

  CLEAR gt_rt[].
  LOOP AT rt .
    gt_rt = CORRESPONDING #( rt ) .
    gt_rt-table = 'RT'.
    APPEND gt_rt.
  ENDLOOP.
  LOOP AT ddntk .
    gt_rt = CORRESPONDING #( ddntk ) .
    gt_rt-table = 'DDNTK'.
    gt_rt-apznr = s_wpbp-apznr.
    APPEND gt_rt.
  ENDLOOP.


  CLEAR lv_kn.
  DO 20 TIMES.
    ADD 1 TO lv_kn.


    CHECK lv_kpr IS NOT INITIAL .
    " 27 de %100 masraf yeri dağıtımı yoksa kalanı 1bt deki masrafyerine ata
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc EQ 0 .
      IF p0027 IS NOT INITIAL .
        CONCATENATE 'P0027-' 'KPR' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <kpr> .
        IF <kpr> IS INITIAL .
          lv_fname = 'LV_KPR'.
          ASSIGN (lv_fname) TO <kpr> .
          lv_27 = 'X'.
        ENDIF.
      ELSE.
        lv_fname = 'LV_KPR'.
        ASSIGN (lv_fname) TO <kpr> .
        lv_27 = 'X'.
      ENDIF.
    ELSE.
      lv_fname = 'LV_KPR'.lv_27 = 'X'.
      ASSIGN (lv_fname) TO <kpr> .
    ENDIF.



    LOOP AT gt_rt INTO DATA(s_rt) WHERE apznr IN lr_apznr .
      IF s_rt-table EQ 'DDNTK'.
        lv_ddntk = 'X'.
      ELSE.
        CLEAR lv_ddntk.
      ENDIF.

      s_rt-betrg = abs( s_rt-betrg ) * p_mul.
      s_rt-anzhl = abs( s_rt-anzhl ) * p_mul.


      CLEAR lv_check .
      CASE s_rt-lgart.
        WHEN '/NDY' OR '/104'.
          CASE p0769-sskod.
            WHEN '2'. lv_check = 'X' .
          ENDCASE.
          CASE p0769-ssgrp.
            WHEN '1'OR '2'.
          ENDCASE.
        WHEN '/561'.
          s_rt-betrg =  s_rt-betrg * -1.
      ENDCASE.

      READ TABLE gt006 WITH KEY lgart = s_rt-lgart
       BINARY SEARCH TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        READ TABLE gt_t008 WITH KEY persg = p0001-persg .
        IF sy-subrc EQ 0 .
          READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
                                      lgart = s_rt-lgart .
          CHECK sy-subrc NE 0 .
        ENDIF .


**********************************************************************
        move_filter lv01 lv02.
**********************************************************************

        LOOP AT gt006 WHERE lgart EQ s_rt-lgart .
          "ASGARI ÜCRETLI VEYA DIĞER ÜCRETLI ÇALıŞAN BILGILERI

          IF    gt006-anagr EQ '05'  . "ASGARI/DIĞER ÜCRETLILER
            CASE gt006-altgr.
              WHEN 'AU'  ."ASGARI ÜCRETLILER .
                CHECK p0769-asucc EQ 'X'.
              WHEN 'DU'  ."DIĞER ÜCRETLILER.
                CHECK p0769-asucc NE 'X'.
            ENDCASE.
          ENDIF.

          CLEAR gt005.
          READ TABLE gt005 WITH KEY seqno = gt006-seqno
                                    anagr = gt006-anagr
                                    altgr = gt006-altgr
                                    slga  = gt006-slga
                                    ddntk = lv_ddntk.
          CHECK sy-subrc EQ 0 .



          IF gt006-ssgrp EQ p0769-ssgrp. w-ssgrp = gt006-ssgrp.ENDIF." SSK Group
          IF gt006-pdate  EQ 'X'. w-num   = s_rt-anzhl * <kpr> / 100 .ENDIF." Gun
          IF gt006-phour  EQ 'X'. w-saat  = s_rt-betpe * <kpr> / 100 .ENDIF." Saat

          DATA : lv_kostl TYPE kostl.
          CLEAR : lv_kostl.
          READ TABLE ssort INTO DATA(ls_1) INDEX 1 .
          IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
            lv_kostl = gt_kostl-val01.
          ENDIF.
          READ TABLE ssort INTO ls_1 INDEX 2 .
          IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
            lv_kostl = gt_kostl-val02.
          ENDIF.

          IF gt006-person EQ 'X' . "w-count = 1.endif.
            IF NOT ( gt006-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
                AND ( p0001-persg = '5' OR p0001-persg = '6' )  ).
              READ TABLE personel WITH KEY pernr = pernr-pernr
                             kostl = lv_kostl
                            anagr = gt005-anagr
                            altgr = gt005-altgr
                             lgart = s_rt-lgart
                             ddntk = lv_ddntk.
              IF sy-subrc NE 0.
                w-count = 1.
                personel-anagr = gt005-anagr.
                personel-altgr = gt005-altgr.
                personel-kostl = lv_kostl.
                personel-pernr = pernr-pernr.
                personel-lgart = s_rt-lgart.
                personel-ddntk = lv_ddntk.
                COLLECT personel.
              ELSE.
                w-count = 0.
              ENDIF.
            ELSE.
              w-count = 0.
            ENDIF.
          ENDIF." Personel Sayisi

          w-seqno = gt005-siran." Sıra Numarası
          w-anagr = gt005-anagr." Ana Grup
          w-altgr = gt005-altgr." Alt Grup
          w-slga  = gt005-slga ." Ucret Turu
          w-amt = s_rt-betrg * <kpr> / 100.  " Ucret

          w-lgtxt = gt005-lgtxt .
          w-seqno = gt005-siran." Sıra Numarası

*          TRANSLATE w-lgtxt TO UPPER CASE.

          IF gt006-sumwt NE 'X' .
            w-amt = w-amt * -1 .
          ENDIF.

          IF gt005-sumwt EQ 'X'.
            MOVE-CORRESPONDING w TO total.
            COLLECT total .
          ENDIF.

          COLLECT : w.

          IF NOT gt_kostl IS INITIAL .
            COLLECT gt_kostl .
          ENDIF .
          CLEAR: w, total, gt_kostl.

        ENDLOOP .
      ENDIF .
*      ENDLOOP.

      CLEAR gt005.
      LOOP AT gt005 WHERE slga = s_rt-lgart AND ddntk = lv_ddntk.

*      READ TABLE gt005 WITH KEY slga = s_rt-lgart ddntk =
*       lv_ddntk BINARY SEARCH.
*      IF sy-subrc EQ 0.


        "ASGARI ÜCRETLI VEYA DIĞER ÜCRETLI ÇALıŞAN BILGILERI
        IF    gt005-anagr EQ '05'  . "ASGARI/DIĞER ÜCRETLILER
          CASE gt005-altgr.
            WHEN 'AU'  ."ASGARI ÜCRETLILER .
              CHECK p0769-asucc EQ 'X'.
            WHEN 'DU'  ."DIĞER ÜCRETLILER.
              CHECK p0769-asucc NE 'X'.
          ENDCASE.
        ENDIF.
*<---
        READ TABLE gt_t008 WITH KEY persg = p0001-persg .
        IF sy-subrc EQ 0 .
          READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
                                      lgart = s_rt-lgart .
          CHECK sy-subrc NE 0 .
        ENDIF .

        w-anagr =  gt005-anagr. " Ana Grup
        w-altgr =  gt005-altgr. " Alt Grup
        w-seqno =  gt005-siran. " Sıra Numarası
        w-slga  =  gt005-slga . " Ucret Turu
        w-lgtxt = gt005-lgtxt.

        CLEAR gt006 .
        READ TABLE gt006 WITH KEY seqno  = gt005-seqno
                                  anagr  = gt005-anagr
                                  altgr  = gt005-altgr
                                  slga   =  gt005-slga .
        IF gt006-lgart IS NOT INITIAL .

        ELSE .
          w-amt = s_rt-betrg * <kpr> / 100.  " Ucret
        ENDIF .

        IF s_rt-lgart EQ '/104' AND gt005-pdate EQ 'X'.
          w-amt = s_rt-anzhl * <kpr> / 100.  " Ucret
        ENDIF .

**********************************************************************
        move_filter lv01 lv02.
**********************************************************************

        IF NOT gt005-milgrt IS INITIAL.
          READ TABLE rt INTO w_rt WITH KEY
           lgart = gt005-milgrt apznr = s_rt-apznr.
          IF sy-subrc EQ 0.
            "fark icmalinde matrah ücreti negatif gelmiyordu. 160712
            w_rt-betrg = abs( w_rt-betrg ) * p_mul.
            w-mat = w_rt-betrg * <kpr> / 100.  " Ucret
          ELSE.
            CLEAR w-mat.
          ENDIF.
        ENDIF.

        IF gt005-pdate  EQ 'X'. w-num   = s_rt-anzhl * <kpr> / 100.ENDIF." Gun
        IF gt005-phour  EQ 'X'. w-saat  = s_rt-betpe * <kpr> / 100.ENDIF." Saat

        READ TABLE ssort INTO ls_1 INDEX 1 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = gt_kostl-val01.
        ENDIF.
        READ TABLE ssort INTO ls_1 INDEX 2 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = gt_kostl-val02.
        ENDIF.

        IF gt005-person EQ 'X'. "w-count = 1.endif.
          IF NOT ( gt005-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
              AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
            READ TABLE personel WITH KEY pernr = pernr-pernr
                           kostl = lv_kostl
                          anagr = gt005-anagr
                          altgr = gt005-altgr
                           lgart = s_rt-lgart
                           ddntk = lv_ddntk.
            IF sy-subrc NE 0.
              w-count = 1.
              personel-anagr = gt005-anagr.
              personel-altgr = gt005-altgr.
              personel-kostl = lv_kostl.
              personel-pernr = pernr-pernr.
              personel-lgart = s_rt-lgart.
              personel-ddntk = lv_ddntk.
              COLLECT personel.
            ELSE.
              w-count = 0.
            ENDIF.
          ELSE.
            w-count = 0.
          ENDIF.
*          READ TABLE personel WITH KEY  kostl = lv_kostl
*                                        pernr = pernr-pernr
*                                        anagr = gt005-anagr
*                                        altgr = gt005-altgr
*                                        lgart = s_rt-lgart
*                                        ddntk = lv_ddntk.
*          IF sy-subrc NE 0.
*            w-count = 1.
*            personel-anagr = gt005-anagr.
*            personel-altgr = gt005-altgr.
*            personel-kostl = lv_kostl.
*            personel-pernr = pernr-pernr.
*            personel-lgart = s_rt-lgart.
*            personel-ddntk = lv_ddntk .
*            COLLECT personel.
*          ELSE.
*            w-count = 0.
*          ENDIF.
        ENDIF." Personel Sayisi

        READ TABLE gt005 WITH KEY
                                  seqno = w-seqno
                                  anagr = w-anagr
                                  altgr = w-altgr
                                  slga = w-slga
                                  ddntk = lv_ddntk
            BINARY SEARCH.
        IF sy-subrc EQ 0.
          w-lgtxt = gt005-lgtxt.
        ENDIF.

        IF w-lgtxt IS INITIAL.
          CLEAR gt_t512t .
          READ TABLE gt_t512t WITH KEY sprsl = gv_spras
                                       molga = gv_molga
                                       lgart = w-slga BINARY SEARCH.

          IF sy-subrc EQ 0. w-lgtxt = gt_t512t-lgtxt. ENDIF.
        ENDIF.

*        "Description
*        IF s_rt-lgart EQ '/104' .
*          CLEAR w-lgtxt .
*          w-lgtxt = TEXT-t01. "'SGK GÜNÜ'
*        ENDIF .

*        TRANSLATE w-lgtxt TO UPPER CASE.

        IF gt005-sumwt EQ 'X'.
          MOVE-CORRESPONDING w TO total.
          COLLECT total .
        ENDIF.

        COLLECT : w.
        IF NOT gt_kostl IS INITIAL .
          COLLECT gt_kostl .
        ENDIF .
        CLEAR: w, total,gt_kostl.

*      ENDIF.
      ENDLOOP.

**********************************************************************
      move_filter lv01 lv02.
**********************************************************************
      DATA : lv_tempmat LIKE s_rt-betrg.
****************** toplam net *****************
      READ TABLE gt_kostl WITH KEY val01 = lv01
                                   val02 = lv02 .

*      hd06-kostl = gt_kostl-kostl .
      hd06-val01 = gt_kostl-val01 .
      hd06-val02 = gt_kostl-val02 .
      LOOP AT gt003 WHERE anagr = '99'.
        LOOP AT gt004 WHERE anagr = gt003-anagr
                        AND altgr = '98'.
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-toplam_net.
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-toplam_net.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.

*<---- tahsil edilecek tutar ..
      LOOP AT gt003 WHERE anagr = '99' .
        LOOP AT gt004 WHERE anagr = gt003-anagr
                         AND altgr = '99' .
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-tahsil_edl .
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-tahsil_edl.
          ENDLOOP .
        ENDLOOP .
      ENDLOOP .
      COLLECT hd06 . CLEAR hd06 .
*---->
*---Cihat Fark Bordrosu Kırılım 23.12.2014
      CASE s_rt-lgart.
        WHEN '/551' OR '/552'.
          col-fld01 = lv01.
          col-fld02 = lv02.
          col-lgart = s_rt-lgart.
          lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
          col-betrg = lv_tempmat * p_mul.
          COLLECT : col. CLEAR : col.
      ENDCASE.
*---Cihat Fark Bordrosu Kırılım 23.12.2014

    ENDLOOP.
*----
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc NE 0  OR lv_27 = 'X' .
      EXIT.
    ELSE.
      IF <kpr> IS ASSIGNED .
        lv_kpr = lv_kpr - <kpr>.
        CHECK lv_kpr GT 0   .
      ENDIF.
    ENDIF.
  ENDDO.
ENDFORM.                    " fill_wages_to_p2
*&---------------------------------------------------------------------*
*&   masraf yeri düzenlenmesi
*&---------------------------------------------------------------------*
FORM calculate_people_number .

  DATA : lv_datum2 TYPE datum .
  DATA lv_fname(30) .
  DATA : lv_kn(2) TYPE n.
  FIELD-SYMBOLS <m> TYPE any .
  FIELD-SYMBOLS <kst> TYPE any .
  FIELD-SYMBOLS <kpr> TYPE any .
  DATA : lv_27 .
  DATA : lv_kpr LIKE p0027-kpr01 VALUE 100 .

  rx-key-pernr = pernr-pernr.
  UNPACK rgdir-seqnr TO rx-key-seqno.

* Control Data Cluster
  CASE t500l-relid.
    WHEN 'TR'.  rp-imp-c2-tr.
    WHEN 'RX'.  rp-imp-c2-rx.
  ENDCASE.



  CLEAR lv_kn.
  DO 20 TIMES.
    ADD 1 TO lv_kn.
    CHECK lv_kpr IS NOT INITIAL .
    " 27 de %100 masraf yeri dağıtımı yoksa kalanı 1bt deki masrafyerine ata
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc EQ 0 .
      IF p0027 IS NOT INITIAL AND pc_27 EQ 'X' .
        CONCATENATE 'P0027-' 'KPR' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <kpr> .
        IF <kpr> IS INITIAL .
          lv_fname = 'LV_KPR'.
          ASSIGN (lv_fname) TO <kpr> .
          lv_27 = 'X'.
        ENDIF.
      ELSE.
        lv_fname = 'LV_KPR'.
        ASSIGN (lv_fname) TO <kpr> .
        lv_27 = 'X'.
      ENDIF.
    ELSE.
      lv_fname = 'LV_KPR'.
      ASSIGN (lv_fname) TO <kpr> .
    ENDIF.


    IF lv_27 NE 'X'
*      AND  p0027 IS NOT INITIAL
      .
      CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
      ASSIGN (lv_fname) TO <m> .
      IF <m> IS INITIAL .
        CONCATENATE 'P0001-' 'KOSTL' INTO lv_fname.
        ASSIGN (lv_fname) TO <m> .
      ENDIF.
    ELSE.
      CONCATENATE 'P0001-' 'KOSTL' INTO lv_fname.
    ENDIF.
    ASSIGN (lv_fname) TO <m> .
    CHECK <m> IS NOT INITIAL .

*    hd01-kostl = hd02-kostl = hd03-kostl =
*    hd04-kostl = hd05-kostl = <m> .


*** index 1
    READ TABLE ssort INDEX 1 .
    CLEAR lv_fname .
    IF ssort-fnam+2(6) EQ 'KOSTL' .
      IF  lv_27 NE 'X'
*        AND p0027 IS NOT INITIAL
        .
        CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <m> .
        IF <m> IS INITIAL .
          CONCATENATE 'P0001-' 'KOSTL' INTO lv_fname.
          ASSIGN (lv_fname) TO <m> .
        ENDIF.
      ELSE.
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        lv_27 = 'X'.
      ENDIF.
    ELSE .
      CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
    ENDIF.

    ASSIGN (lv_fname) TO <m> .
    hd01-val01 = hd02-val01 = hd03-val01 =
    hd04-val01 = hd05-val01 = <m> .

*** index 2
    READ TABLE ssort INDEX 2 .
    IF sy-subrc EQ 0 .
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
        IF  lv_27 NE 'X'
*        AND p0027 IS NOT INITIAL
          .
          CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
          ASSIGN (lv_fname) TO <m> .
          IF <m> IS INITIAL .
            CONCATENATE 'P0001-' 'KOSTL' INTO lv_fname.
            ASSIGN (lv_fname) TO <m> .
          ENDIF.
        ELSE.
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ENDIF.
      ELSE .
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF.

      ASSIGN (lv_fname) TO <m> .
      hd01-val02 = hd02-val02 = hd03-val02 =
      hd04-val02 = hd05-val02 = <m> .

    ENDIF.

    READ TABLE rt WITH KEY lgart = '9SPL'.
    IF sy-subrc EQ 0 .
      ADD 1 TO hd04-say_04 . " Splitli Top.Çal.Say
    ENDIF.

    ADD 1 TO hd01-say_01 . " Toplam Çalışan Sayisi
    CASE p0002-gesch .
      WHEN '1'. ADD 1 TO hd02-say_01 . " Erkek Sayisi
      WHEN '2'. ADD 1 TO hd02-say_02 . " Kadin Sayisi
    ENDCASE.
    DATA : lv_datum TYPE datum.
    DATA : lv_pernr TYPE persno.
    lv_datum = pn-endda + 1.

    SELECT SINGLE pernr FROM pa0000 INTO lv_pernr
                                   WHERE pernr EQ pernr-pernr
                                     AND stat2 NE '3'
                                     AND begda LE lv_datum
                                     AND begda GE pn-begda.
    IF sy-subrc EQ 0.
      ADD 1 TO hd03-say_04 .
      CASE p0002-gesch .
        WHEN '1'. ADD 1 TO hd03-say_05 . " Erkek Sayisi
        WHEN '2'. ADD 1 TO hd03-say_06 . " Kadin Sayisi
      ENDCASE.

    ELSE .
      CLEAR lv_datum2  .
      lv_datum2 = p0000-endda + 1 .
      " nakil
      SELECT SINGLE pernr FROM pa0000 INTO lv_pernr
                                  WHERE pernr EQ pernr-pernr
                                    AND massn EQ '02'
                                    AND massg EQ '01'
                                    AND begda LE lv_datum2
                                    AND endda GE lv_datum2.

      IF sy-subrc EQ 0.
        ADD 1 TO hd03-say_04 .
        CASE p0002-gesch .
          WHEN '1'. ADD 1 TO hd03-say_05 . " Erkek Sayisi
          WHEN '2'. ADD 1 TO hd03-say_06 . " Kadin Sayisi
        ENDCASE.
      ENDIF .

    ENDIF.



    LOOP AT p0000 WHERE ( massn EQ '01' OR massn EQ '12'
                     OR   massn EQ '30' OR
      ( massn EQ '02' AND massg EQ '01' ) ) " nakil
                    AND pernr EQ pernr-pernr
                    AND begda LE pn-endda
                    AND begda GE pn-begda.
    ENDLOOP.
    IF sy-subrc EQ 0.
      ADD 1 TO hd03-say_01 .
      CASE p0002-gesch .
        WHEN '1'. ADD 1 TO hd03-say_02 . " Erkek Sayisi
        WHEN '2'. ADD 1 TO hd03-say_03 . " Kadin Sayisi
      ENDCASE.
    ENDIF.


    LOOP AT p0001 WHERE begda LE pn-endda AND endda GE pn-begda.ENDLOOP.
    IF    p0001-persk EQ '10' OR p0001-persk EQ '20'
       OR p0001-persk EQ '21' OR p0001-persk EQ '22 '
       OR p0001-persk EQ '46'. "Beyaz Yaka Son hali 23.02.2023 tarihinde Emine Ekinci'den Gelen maile istinaden eklenmiştir.

      ADD 1 TO hd04-say_01 .
    ELSEIF p0001-persk EQ '30' OR p0001-persk EQ '31'
          OR p0001-persk EQ '32' OR p0001-persk EQ '33'
          OR p0001-persk EQ '45' OR p0001-persk EQ '50'  . "Mavi Yaka
      ADD 1 TO hd04-say_02 .
    ELSEIF p0001-persk EQ '40' OR p0001-persk EQ '41' " Stajyer
        OR p0001-persk EQ '42'.
      ADD 1 TO hd04-say_03 .
    ENDIF.


    LOOP AT p0769 WHERE begda LE pn-endda AND endda GE pn-begda. ENDLOOP.
    IF p0769-asucc EQ 'X'."Askari ücretli
      CASE p0002-gesch .
        WHEN '1'. ADD 1 TO hd05-say_01 . " Erkek Sayisi
        WHEN '2'. ADD 1 TO hd05-say_02 . " Kadin Sayisi
      ENDCASE.
    ENDIF.
    IF p0769-disab IS NOT INITIAL."Engelli
      CASE p0002-gesch .
        WHEN '1'. ADD 1 TO hd05-say_03 . " Erkek Sayisi
        WHEN '2'. ADD 1 TO hd05-say_04 . " Kadin Sayisi
      ENDCASE.
    ENDIF.

    COLLECT : hd01,hd02,hd03,hd04,hd05.

    CLEAR : hd01,hd02,hd03,hd04,hd05.

    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc NE 0 OR lv_27 EQ 'X'.
      EXIT.
    ELSE.
      IF <kpr> IS ASSIGNED .
        lv_kpr = lv_kpr - <kpr>.
        CHECK lv_kpr GT 0   .
      ENDIF.
    ENDIF.
  ENDDO.
*
ENDFORM.                    " CALCULATE_PEOPLE_NUMBER
*&---------------------------------------------------------------------*
*&      Form  fill_wages_to_son önceki ve aktif ücret hesaplama
*&---------------------------------------------------------------------*
FORM fill_wages_to_son USING p_srtza TYPE c p_mul TYPE i.

  FIELD-SYMBOLS : <val01> TYPE any,
                  <val02> TYPE any,
                  <m>     TYPE any,
                  <kpr>   TYPE any.
  DATA : lv_check TYPE c .
  DATA : w_rt LIKE rt.
  DATA : lv_fname(20).
  DATA : lv_fname2(20).
  DATA : lr_apznr TYPE RANGE OF apznr .
  DATA : lr_lgart TYPE RANGE OF lgart .
  DATA : ls_apznr LIKE LINE OF lr_apznr.

  DATA : lv_count TYPE n.
  CLEAR: lv_count.
  DATA : lv_kn(2) TYPE n.
  DATA : lv_ddntk TYPE c.

  DATA : lv01 LIKE gt_kostl-val01.
  DATA : lv02 LIKE gt_kostl-val01.

  DATA : lv_kpr LIKE p0027-kpr01 VALUE 100 .
  DATA : lv_27.

  DATA : lv_tabix TYPE sy-tabix.

  DEFINE move_filter.
    CLEAR lv_tabix.
    LOOP AT ssort.
      lv_tabix = sy-tabix.
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
      IF  lv_27 NE 'X'
*        AND p0027 IS NOT INITIAL
        .
          CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
        ELSE.
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ENDIF.
      ELSE .
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF .

      ASSIGN (lv_fname) TO <m> .

      CASE lv_tabix .
        WHEN 1.
          gt_kostl-val01 = w-val01 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> w-txt01 .
          gt_kostl-txt01 = w-txt01 .
        WHEN 2.
          ASSIGN (lv_fname) TO <m> .
          gt_kostl-val02 = w-val02 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> w-txt02 .
          gt_kostl-txt02 = w-txt02.
      ENDCASE.
    ENDLOOP.
    &1 = gt_kostl-val01.
    &2 = gt_kostl-val02.
**********************************************************************
  END-OF-DEFINITION.

*-----
  READ TABLE rgdir WITH KEY fpper = period-fpper srtza = p_srtza.
  CHECK sy-subrc EQ 0.
  check_p = 'X'.
  rx-key-pernr = pernr-pernr.
  UNPACK rgdir-seqnr TO rx-key-seqno.

* Control Data Cluster
  CASE t500l-relid.
    WHEN 'TR'.  rp-imp-c2-tr.
    WHEN 'RX'.  rp-imp-c2-rx.
  ENDCASE.

  DATA : lv_rt LIKE rt OCCURS 0 WITH HEADER LINE.
  MOVE rt[] TO lv_rt[].
*----

  LOOP AT wpbp INTO DATA(s_wpbp) WHERE aktivjn EQ 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.

  REFRESH lr_apznr.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  LOOP AT wpbp INTO s_wpbp WHERE btrtl IN pnpbtrtl.
    ls_apznr-low = s_wpbp-apznr .
    APPEND ls_apznr TO lr_apznr.
  ENDLOOP.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  ls_apznr-low = '00' .
  APPEND ls_apznr TO lr_apznr.

  CLEAR gt_rt[].
  lr_lgart = VALUE #( FOR ls IN rt ( sign = 'I' option = 'EQ' low = ls-lgart )  ).
  LOOP AT rt .
    gt_rt = CORRESPONDING #( rt ) .
    gt_rt-table = 'RT'.
    APPEND gt_rt.
  ENDLOOP.
  LOOP AT ddntk .
    gt_rt = CORRESPONDING #( ddntk ) .
    gt_rt-table = 'DDNTK'.
    gt_rt-apznr = s_wpbp-apznr.
    APPEND gt_rt.
  ENDLOOP.


  CLEAR lv_kn.
  DO 20 TIMES.
    ADD 1 TO lv_kn.


    CHECK lv_kpr IS NOT INITIAL .
    " 27 de %100 masraf yeri dağıtımı yoksa kalanı 1bt deki masrafyerine ata
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc EQ 0 .
      IF p0027 IS NOT INITIAL AND pc_27 EQ 'X'.
        CONCATENATE 'P0027-' 'KPR' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <kpr> .
        IF <kpr> IS INITIAL .
          lv_fname = 'LV_KPR'.
          ASSIGN (lv_fname) TO <kpr> .
          lv_27 = 'X'.
        ENDIF.
      ELSE.
        lv_fname = 'LV_KPR'.
        ASSIGN (lv_fname) TO <kpr> .
        lv_27 = 'X'.
      ENDIF.
    ELSE.
      lv_fname = 'LV_KPR'.lv_27 = 'X'.
      ASSIGN (lv_fname) TO <kpr> .
    ENDIF.


    DATA : s_rt LIKE gt_rt.

    DATA : lv_kostl TYPE kostl.
    CLEAR : lv_kostl.
    READ TABLE ssort INTO DATA(ls_1) INDEX 1 .
    IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
      lv_kostl = gt_kostl-val01.
    ENDIF.
    READ TABLE ssort INTO ls_1 INDEX 2 .
    IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
      lv_kostl = gt_kostl-val02.
    ENDIF.

    LOOP AT gt005 WHERE slga IN lr_lgart[].

      "ASGARI ÜCRETLI VEYA DIĞER ÜCRETLI ÇALıŞAN BILGILERI
      IF    gt005-anagr EQ '05'  . "ASGARI/DIĞER ÜCRETLILER
        CASE gt005-altgr.
          WHEN 'AU'  ."ASGARI ÜCRETLILER .
            CHECK p0769-asucc EQ 'X'.
          WHEN 'DU'  ."DIĞER ÜCRETLILER.
            CHECK p0769-asucc NE 'X'.
        ENDCASE.
      ENDIF.

**********************************************************************
      move_filter lv01 lv02.
**********************************************************************

      IF NOT gt005-milgrt IS INITIAL.
        LOOP AT rt INTO w_rt WHERE lgart = gt005-milgrt  ..
          "fark icmalinde matrah ücreti negatif gelmiyordu. 160712
          w_rt-betrg = abs( w_rt-betrg ) * p_mul.
          w-mat = w_rt-betrg * <kpr> / 100.  " Ucret
        ENDLOOP.
        IF sy-subrc EQ 0.
        ELSE.
          CLEAR w-mat.
        ENDIF.
      ENDIF.


      CLEAR s_rt.
      CLEAR lv_ddntk.
      LOOP AT gt_rt INTO DATA(ls_temp) WHERE lgart EQ gt005-slga
                                         AND apznr IN lr_apznr.
        IF s_rt-table EQ 'DDNTK'.
          lv_ddntk = 'X'.
        ENDIF.
        MOVE : ls_temp-lgart TO s_rt-lgart .

        ls_temp-betrg = abs( ls_temp-betrg ) * p_mul.
        ls_temp-anzhl = abs( ls_temp-anzhl ) * p_mul.

        ADD : ls_temp-anzhl TO s_rt-anzhl,
              ls_temp-betrg TO s_rt-betrg ,
              ls_temp-betpe TO s_rt-betpe .
      ENDLOOP.

      IF gt005-pdate  EQ 'X'. w-num   = s_rt-anzhl * <kpr> / 100.ENDIF." Gun
      IF gt005-phour  EQ 'X'. w-saat  = s_rt-betpe * <kpr> / 100.ENDIF." Saat

      READ TABLE gt_t008 WITH KEY persg = p0001-persg .
      IF sy-subrc EQ 0 .
        READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
                                    lgart = s_rt-lgart .
        CHECK sy-subrc NE 0 .
      ENDIF .

      READ TABLE ssort INTO ls_1 INDEX 1 .
      IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
        lv_kostl = gt_kostl-val01.
      ENDIF.
      READ TABLE ssort INTO ls_1 INDEX 2 .
      IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
        lv_kostl = gt_kostl-val02.
      ENDIF.


      IF gt005-person EQ 'X'. "w-count = 1.endif.
        IF NOT ( gt005-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
            AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
          READ TABLE personel WITH KEY pernr = pernr-pernr
                                       kostl = lv_kostl
                                       anagr = gt005-anagr
                                       altgr = gt005-altgr
                                       lgart = gt005-slga
                                       ddntk = lv_ddntk.
          IF sy-subrc NE 0.
            w-count = 1.
            personel-anagr = gt005-anagr.
            personel-altgr = gt005-altgr.
            personel-kostl = lv_kostl.
            personel-pernr = pernr-pernr.
            personel-lgart = s_rt-lgart.
            personel-ddntk = lv_ddntk.
            COLLECT personel.
          ELSE.
            w-count = 0.
          ENDIF.
        ELSE.
          w-count = 0.
        ENDIF.
      ENDIF." Personel Sayisi

      w-seqno = gt005-siran." Sıra Numarası
      w-anagr = gt005-anagr." Ana Grup
      w-altgr = gt005-altgr." Alt Grup
      w-slga  = gt005-slga ." Ucret Turu
      w-amt = s_rt-betrg * <kpr> / 100.  " Ucret

      w-lgtxt = gt005-lgtxt .
      w-seqno = gt005-siran." Sıra Numarası

      IF gt005-sumwt EQ 'X'.
        MOVE-CORRESPONDING w TO total.
        COLLECT total .
      ENDIF.

      READ TABLE gt005 WITH KEY seqno = w-seqno
                                anagr = w-anagr
                                altgr = w-altgr
                                slga = w-slga
                                ddntk = lv_ddntk BINARY SEARCH.
      IF sy-subrc EQ 0.
        w-lgtxt = gt005-lgtxt.
      ENDIF.
      IF w-lgtxt IS INITIAL.
        CLEAR gt_t512t .
        READ TABLE gt_t512t WITH KEY sprsl = gv_spras
                                     molga = gv_molga
                                     lgart = w-slga BINARY SEARCH.

        IF sy-subrc EQ 0. w-lgtxt = gt_t512t-lgtxt. ENDIF.
      ENDIF.
      COLLECT : w.

      IF NOT gt_kostl IS INITIAL .
        COLLECT gt_kostl .
      ENDIF .

      CLEAR: w, total,gt_kostl.


      LOOP AT gt006 WHERE anagr EQ gt005-anagr
                      AND altgr EQ gt005-altgr
                      AND slga  EQ gt005-slga   .

**********************************************************************
        move_filter lv01 lv02.
**********************************************************************
        CLEAR s_rt.
        CLEAR lv_ddntk.
        LOOP AT gt_rt INTO ls_temp WHERE lgart EQ gt006-lgart
                                           AND apznr IN lr_apznr.
          IF s_rt-table EQ 'DDNTK'.
            lv_ddntk = 'X'.
          ENDIF.
          MOVE : ls_temp-lgart TO s_rt-lgart .

          ls_temp-betrg = abs( ls_temp-betrg ) * p_mul.
          ls_temp-anzhl = abs( ls_temp-anzhl ) * p_mul.

          ADD : ls_temp-anzhl TO s_rt-anzhl,
                ls_temp-betrg TO s_rt-betrg ,
                ls_temp-betpe TO s_rt-betpe .
        ENDLOOP.

        READ TABLE ssort INTO ls_1 INDEX 1 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = gt_kostl-val01.
        ENDIF.
        READ TABLE ssort INTO ls_1 INDEX 2 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = gt_kostl-val02.
        ENDIF.

        IF gt006-person EQ 'X' . "w-count = 1.endif.
          IF NOT ( gt006-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
              AND ( p0001-persg = '5' OR p0001-persg = '6' )  ).
            READ TABLE personel WITH KEY pernr = pernr-pernr
                           kostl = lv_kostl
                          anagr = gt005-anagr
                          altgr = gt005-altgr
                          lgart = gt005-slga
                          ddntk = lv_ddntk.
            IF sy-subrc NE 0.
              w-count = 1.
              personel-anagr = gt005-anagr.
              personel-altgr = gt005-altgr.
              personel-kostl = lv_kostl.
              personel-pernr = pernr-pernr.
              personel-lgart = s_rt-lgart.
              personel-ddntk = lv_ddntk.
              COLLECT personel.
            ELSE.
              w-count = 0.
            ENDIF.
          ELSE.
            w-count = 0.
          ENDIF.
        ENDIF." Personel Sayisi

        w-seqno = gt005-siran." Sıra Numarası
        w-anagr = gt005-anagr." Ana Grup
        w-altgr = gt005-altgr." Alt Grup
        w-slga  = gt005-slga ." Ucret Turu
        w-amt = s_rt-betrg * <kpr> / 100.  " Ucret

        w-lgtxt = gt005-lgtxt .
        w-seqno = gt005-siran." Sıra Numarası

        IF gt006-sumwt NE 'X' .
          w-amt = w-amt * -1 .
*          w-count = -1 .
        ENDIF.

        IF gt005-sumwt EQ 'X'.
          MOVE-CORRESPONDING w TO total.
          COLLECT total .
        ENDIF.


        READ TABLE gt005 WITH KEY seqno = w-seqno
                                  anagr = w-anagr
                                  altgr = w-altgr
                                  slga = w-slga
                                  ddntk = lv_ddntk BINARY SEARCH.
        IF sy-subrc EQ 0.
          w-lgtxt = gt005-lgtxt.
        ENDIF.
        IF w-lgtxt IS INITIAL.
          CLEAR gt_t512t .
          READ TABLE gt_t512t WITH KEY sprsl = gv_spras
                                       molga = gv_molga
                                       lgart = w-slga BINARY SEARCH.

          IF sy-subrc EQ 0. w-lgtxt = gt_t512t-lgtxt. ENDIF.
        ENDIF.
        COLLECT : w.
        SORT w ASCENDING BY anagr altgr seqno.
        IF NOT gt_kostl IS INITIAL .
          COLLECT gt_kostl .
        ENDIF .
        CLEAR: w, total, gt_kostl.

      ENDLOOP.


      DATA : lv_tempmat LIKE s_rt-betrg.

    ENDLOOP.

    LOOP AT gt_rt INTO s_rt   .
      s_rt-betrg = abs( s_rt-betrg ) * p_mul.
      s_rt-anzhl = abs( s_rt-anzhl ) * p_mul.
*---Cihat Fark Bordrosu Kırılım 23.12.2014
      CASE s_rt-lgart.
        WHEN '/551' OR '/552'.
          col-fld01 = lv01.
          col-fld02 = lv02.
          col-lgart = s_rt-lgart.
          lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
          col-betrg = lv_tempmat * p_mul.
          COLLECT : col. CLEAR : col.
      ENDCASE.

**********************************************************************
      move_filter lv01 lv02.
**********************************************************************
****************** toplam net *****************
      READ TABLE gt_kostl WITH KEY val01 = lv01
                                   val02 = lv02 .
      hd06-val01 = gt_kostl-val01 .
      hd06-val02 = gt_kostl-val02 .

      LOOP AT gt003 WHERE anagr = '99'.
        LOOP AT gt004 WHERE anagr = gt003-anagr
                        AND altgr = '98'.
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-toplam_net.
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-toplam_net.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.


*<---- tahsil edilecek tutar ..
      LOOP AT gt003 WHERE anagr = '99' .
        LOOP AT gt004 WHERE anagr = gt003-anagr
                         AND altgr = '99' .
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-tahsil_edl .
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-tahsil_edl.
          ENDLOOP .
        ENDLOOP .
      ENDLOOP .
      COLLECT hd06 . CLEAR hd06 .

    ENDLOOP.


*----
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc NE 0  OR lv_27 = 'X' .
      EXIT.
    ELSE.
      IF <kpr> IS ASSIGNED .
        lv_kpr = lv_kpr - <kpr>.
        CHECK lv_kpr GT 0   .
      ENDIF.
    ENDIF.
  ENDDO.


  DELETE w WHERE amt IS INITIAL AND
                 saat IS INITIAL AND
                 num IS INITIAL .


ENDFORM.                    " fill_wages_to_son

*&---------------------------------------------------------------------*
*&      Form  fill_wages_to_son2 önceki ve aktif ücret hesaplama
*&---------------------------------------------------------------------*
FORM fill_wages_to_son2 TABLES pt_w STRUCTURE w
                              pt_total STRUCTURE total
                              pt_kostl STRUCTURE gt_kostl
                        USING p_srtza TYPE c
                              p_mul   TYPE i.

  FIELD-SYMBOLS : <val01> TYPE any,
                  <val02> TYPE any,
                  <m>     TYPE any,
                  <kpr>   TYPE any.
  DATA : lv_check TYPE c .
  DATA : w_rt LIKE rt.
  DATA : lv_fname(20).
  DATA : lv_fname2(20).
  DATA : lr_apznr TYPE RANGE OF apznr .
  DATA : lr_lgart TYPE RANGE OF lgart .
  DATA : ls_apznr LIKE LINE OF lr_apznr.

  DATA : lv_count TYPE n.
  CLEAR: lv_count.
  DATA : lv_kn(2) TYPE n.
  DATA : lv_ddntk TYPE c.

  DATA : lv01 LIKE gt_kostl-val01.
  DATA : lv02 LIKE gt_kostl-val01.

  DATA : lv_kpr LIKE p0027-kpr01 VALUE 100 .
  DATA : lv_27.

  DATA : lv_tabix TYPE sy-tabix.

  DEFINE move_filter.
    CLEAR lv_tabix.
    LOOP AT ssort.
      lv_tabix = sy-tabix.
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
      IF  lv_27 NE 'X'
*        AND p0027 IS NOT INITIAL
        .
          CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
        ELSE.
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ENDIF.
      ELSE .
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF .

      ASSIGN (lv_fname) TO <m> .

      CASE lv_tabix .
        WHEN 1.
          pt_kostl-val01 = pt_w-val01 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> pt_w-txt01 .
          pt_kostl-txt01 = pt_w-txt01 .
        WHEN 2.
          ASSIGN (lv_fname) TO <m> .
          pt_kostl-val02 = pt_w-val02 = <m> .
          PERFORM set_text USING ssort-fnam+2(6) <m> pt_w-txt02 .
          pt_kostl-txt02 = pt_w-txt02.
      ENDCASE.
    ENDLOOP.
    &1 = pt_kostl-val01.
    &2 = pt_kostl-val02.
**********************************************************************
  END-OF-DEFINITION.

*-----
  READ TABLE rgdir WITH KEY fpper = period-fpper srtza = p_srtza.
  CHECK sy-subrc EQ 0.
  check_p = 'X'.
  rx-key-pernr = pernr-pernr.
  UNPACK rgdir-seqnr TO rx-key-seqno.

* Control Data Cluster
  CASE t500l-relid.
    WHEN 'TR'.
      rp-imp-c2-tr.
    WHEN 'RX'.
      rp-imp-c2-rx.
  ENDCASE.

  DATA : lv_rt LIKE rt OCCURS 0 WITH HEADER LINE.
  MOVE rt[] TO lv_rt[].
*----

  LOOP AT wpbp INTO DATA(s_wpbp) WHERE aktivjn EQ 'X'.
    lv_count = lv_count + 1.
  ENDLOOP.

  REFRESH lr_apznr.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  LOOP AT wpbp INTO s_wpbp WHERE btrtl IN pnpbtrtl.
    ls_apznr-low = s_wpbp-apznr .
    APPEND ls_apznr TO lr_apznr.
  ENDLOOP.
  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  ls_apznr-low = '00' .
  APPEND ls_apznr TO lr_apznr.

  CLEAR gt_rt[].
  lr_lgart = VALUE #( FOR ls IN rt ( sign = 'I' option = 'EQ' low = ls-lgart )  ).
  LOOP AT rt .
    gt_rt = CORRESPONDING #( rt ) .
    gt_rt-table = 'RT'.
    APPEND gt_rt.
  ENDLOOP.
  LOOP AT ddntk .
    gt_rt = CORRESPONDING #( ddntk ) .
    gt_rt-table = 'DDNTK'.
    gt_rt-apznr = s_wpbp-apznr.
    APPEND gt_rt.
  ENDLOOP.


  CLEAR lv_kn.
  DO 20 TIMES.
    ADD 1 TO lv_kn.


    CHECK lv_kpr IS NOT INITIAL .
    " 27 de %100 masraf yeri dağıtımı yoksa kalanı 1bt deki masrafyerine ata
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc EQ 0 .
      IF p0027 IS NOT INITIAL AND pc_27 EQ 'X'.
        CONCATENATE 'P0027-' 'KPR' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <kpr> .
        IF <kpr> IS INITIAL .
          lv_fname = 'LV_KPR'.
          ASSIGN (lv_fname) TO <kpr> .
          lv_27 = 'X'.
        ENDIF.
      ELSE.
        lv_fname = 'LV_KPR'.
        ASSIGN (lv_fname) TO <kpr> .
        lv_27 = 'X'.
      ENDIF.
    ELSE.
      lv_fname = 'LV_KPR'.lv_27 = 'X'.
      ASSIGN (lv_fname) TO <kpr> .
    ENDIF.


    DATA : s_rt LIKE gt_rt.

    DATA : lv_kostl TYPE kostl.
    CLEAR : lv_kostl.
    READ TABLE ssort INTO DATA(ls_1) INDEX 1 .
    IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
      lv_kostl = pt_kostl-val01.
    ENDIF.
    READ TABLE ssort INTO ls_1 INDEX 2 .
    IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
      lv_kostl = pt_kostl-val02.
    ENDIF.

    LOOP AT gt005 WHERE slga IN lr_lgart[].

      "ASGARI ÜCRETLI VEYA DIĞER ÜCRETLI ÇALıŞAN BILGILERI
      IF    gt005-anagr EQ '05'  . "ASGARI/DIĞER ÜCRETLILER
        CASE gt005-altgr.
          WHEN 'AU'  ."ASGARI ÜCRETLILER .
            CHECK p0769-asucc EQ 'X'.
          WHEN 'DU'  ."DIĞER ÜCRETLILER.
            CHECK p0769-asucc NE 'X'.
        ENDCASE.
      ENDIF.

**********************************************************************
      move_filter lv01 lv02.
**********************************************************************

      IF NOT gt005-milgrt IS INITIAL.
        LOOP AT rt INTO w_rt WHERE lgart = gt005-milgrt  ..
          "fark icmalinde matrah ücreti negatif gelmiyordu. 160712
          w_rt-betrg = abs( w_rt-betrg ) * p_mul.
          pt_w-mat = w_rt-betrg * <kpr> / 100.  " Ucret
        ENDLOOP.
        IF sy-subrc EQ 0.
        ELSE.
          CLEAR pt_w-mat.
        ENDIF.
      ENDIF.


      CLEAR s_rt.
      CLEAR lv_ddntk.
      LOOP AT gt_rt INTO DATA(ls_temp) WHERE lgart EQ gt005-slga
                                         AND apznr IN lr_apznr.
        IF s_rt-table EQ 'DDNTK'.
          lv_ddntk = 'X'.
        ENDIF.
        MOVE : ls_temp-lgart TO s_rt-lgart .

        ls_temp-betrg = abs( ls_temp-betrg ) * p_mul.
        ls_temp-anzhl = abs( ls_temp-anzhl ) * p_mul.

        ADD : ls_temp-anzhl TO s_rt-anzhl,
              ls_temp-betrg TO s_rt-betrg ,
              ls_temp-betpe TO s_rt-betpe .
      ENDLOOP.

      IF gt005-pdate  EQ 'X'. pt_w-num   = s_rt-anzhl * <kpr> / 100.ENDIF." Gun
      IF gt005-phour  EQ 'X'. pt_w-saat  = s_rt-betpe * <kpr> / 100.ENDIF." Saat

      READ TABLE gt_t008 WITH KEY persg = p0001-persg .
      IF sy-subrc EQ 0 .
        READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
                                    lgart = s_rt-lgart .
        CHECK sy-subrc NE 0 .
      ENDIF .

      READ TABLE ssort INTO ls_1 INDEX 1 .
      IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
        lv_kostl = pt_kostl-val01.
      ENDIF.
      READ TABLE ssort INTO ls_1 INDEX 2 .
      IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
        lv_kostl = pt_kostl-val02.
      ENDIF.


      IF gt005-person EQ 'X'. "w-count = 1.endif.
        IF NOT ( gt005-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
            AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
          READ TABLE personel WITH KEY pernr = pernr-pernr
                                       kostl = lv_kostl
                                       anagr = gt005-anagr
                                       altgr = gt005-altgr
                                       lgart = gt005-slga
                                       ddntk = lv_ddntk.
          IF sy-subrc NE 0.
            pt_w-count = 1.
            personel-anagr = gt005-anagr.
            personel-altgr = gt005-altgr.
            personel-kostl = lv_kostl.
            personel-pernr = pernr-pernr.
            personel-lgart = s_rt-lgart.
            personel-ddntk = lv_ddntk.
            COLLECT personel.
          ELSE.
            pt_w-count = 0.
          ENDIF.
        ELSE.
          pt_w-count = 0.
        ENDIF.
      ENDIF." Personel Sayisi

      pt_w-seqno = gt005-siran." Sıra Numarası
      pt_w-anagr = gt005-anagr." Ana Grup
      pt_w-altgr = gt005-altgr." Alt Grup
      pt_w-slga  = gt005-slga ." Ucret Turu

      IF NOT ( gt005-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
            AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
        pt_w-amt = s_rt-betrg * <kpr> / 100.  " Ucret
      ENDIF.

      pt_w-lgtxt = gt005-lgtxt .
      pt_w-seqno = gt005-siran." Sıra Numarası

      IF gt005-sumwt EQ 'X'.
        MOVE-CORRESPONDING pt_w TO pt_total.
        COLLECT pt_total .
      ENDIF.

      READ TABLE gt005 WITH KEY seqno = pt_w-seqno
                                anagr = pt_w-anagr
                                altgr = pt_w-altgr
                                slga = pt_w-slga
                                ddntk = lv_ddntk BINARY SEARCH.
      IF sy-subrc EQ 0.
        pt_w-lgtxt = gt005-lgtxt.
      ENDIF.
      IF pt_w-lgtxt IS INITIAL.
        CLEAR gt_t512t .
        READ TABLE gt_t512t WITH KEY sprsl = gv_spras
                                     molga = gv_molga
                                     lgart = pt_w-slga BINARY SEARCH.

        IF sy-subrc EQ 0. pt_w-lgtxt = gt_t512t-lgtxt. ENDIF.
      ENDIF.
      COLLECT : pt_w.

      IF NOT pt_kostl IS INITIAL .
        COLLECT pt_kostl .
      ENDIF .

      CLEAR: pt_w, pt_total,pt_kostl.


      LOOP AT gt006 WHERE anagr EQ gt005-anagr
                      AND altgr EQ gt005-altgr
                      AND slga  EQ gt005-slga   .

**********************************************************************
        move_filter lv01 lv02.
**********************************************************************
        CLEAR s_rt.
        CLEAR lv_ddntk.
        LOOP AT gt_rt INTO ls_temp WHERE lgart EQ gt006-lgart
                                           AND apznr IN lr_apznr.
          IF s_rt-table EQ 'DDNTK'.
            lv_ddntk = 'X'.
          ENDIF.
          MOVE : ls_temp-lgart TO s_rt-lgart .

          ls_temp-betrg = abs( ls_temp-betrg ) * p_mul.
          ls_temp-anzhl = abs( ls_temp-anzhl ) * p_mul.

          ADD : ls_temp-anzhl TO s_rt-anzhl,
                ls_temp-betrg TO s_rt-betrg ,
                ls_temp-betpe TO s_rt-betpe .
        ENDLOOP.


        IF gt005-pdate  EQ 'X'. s_rt-anzhl  = s_rt-anzhl * <kpr> / 100.ENDIF." Gun
        IF gt005-phour  EQ 'X'. s_rt-betpe  = s_rt-betpe * <kpr> / 100.ENDIF." Saat

        READ TABLE ssort INTO ls_1 INDEX 1 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = pt_kostl-val01.
        ENDIF.
        READ TABLE ssort INTO ls_1 INDEX 2 .
        IF sy-subrc EQ 0 AND  ls_1-fnam = 'P-KOSTL'..
          lv_kostl = pt_kostl-val02.
        ENDIF.

        IF gt006-person EQ 'X' . "w-count = 1.endif.
          IF NOT ( gt006-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
            AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
            READ TABLE personel WITH KEY pernr = pernr-pernr
                           kostl = lv_kostl
                          anagr = gt005-anagr
                          altgr = gt005-altgr
                          lgart = gt005-slga
                          ddntk = lv_ddntk.
            IF sy-subrc NE 0.
              pt_w-count = 1.
              personel-anagr = gt005-anagr.
              personel-altgr = gt005-altgr.
              personel-kostl = lv_kostl.
              personel-pernr = pernr-pernr.
              personel-lgart = s_rt-lgart.
              personel-ddntk = lv_ddntk.
              COLLECT personel.
            ELSE.
              pt_w-count = 0.
            ENDIF.
          ELSE.
            pt_w-count = 0.
          ENDIF.
        ENDIF." Personel Sayisi

        pt_w-seqno = gt005-siran." Sıra Numarası
        pt_w-anagr = gt005-anagr." Ana Grup
        pt_w-altgr = gt005-altgr." Alt Grup
        pt_w-slga  = gt005-slga ." Ucret Turu
        IF NOT ( gt005-altgr EQ 'DU' AND s_rt-lgart EQ '/101'
            AND ( p0001-persg = '5' OR p0001-persg = '6' ) ).
          pt_w-amt = s_rt-betrg * <kpr> / 100.  " Ucret

          pt_w-lgtxt = gt005-lgtxt .
          pt_w-seqno = gt005-siran." Sıra Numarası

          IF gt006-sumwt NE 'X' .
            pt_w-amt = pt_w-amt * -1 .
            pt_w-num   = s_rt-anzhl * -1 .
            pt_w-saat  = s_rt-betpe * -1 .

*          pt_w-count = -1 .
          ENDIF.

          IF gt005-sumwt EQ 'X'.
            MOVE-CORRESPONDING pt_w TO pt_total.
            COLLECT pt_total .
          ENDIF.
        ENDIF.


        READ TABLE gt005 WITH KEY seqno = pt_w-seqno
                                  anagr = pt_w-anagr
                                  altgr = pt_w-altgr
                                  slga = pt_w-slga
                                  ddntk = lv_ddntk BINARY SEARCH.
        IF sy-subrc EQ 0.
          pt_w-lgtxt = gt005-lgtxt.
        ENDIF.
        IF pt_w-lgtxt IS INITIAL.
          CLEAR gt_t512t .
          READ TABLE gt_t512t WITH KEY sprsl = gv_spras
                                       molga = gv_molga
                                       lgart = pt_w-slga BINARY SEARCH.

          IF sy-subrc EQ 0. pt_w-lgtxt = gt_t512t-lgtxt. ENDIF.
        ENDIF.
        COLLECT : pt_w.
        SORT pt_w ASCENDING BY anagr altgr seqno.
        IF NOT pt_kostl IS INITIAL .
          COLLECT pt_kostl .
        ENDIF .
        CLEAR: pt_w, pt_total, gt_kostl.

      ENDLOOP.


      DATA : lv_tempmat LIKE s_rt-betrg.

    ENDLOOP.

    LOOP AT gt_rt INTO s_rt   .
      s_rt-betrg = abs( s_rt-betrg ) * p_mul.
      s_rt-anzhl = abs( s_rt-anzhl ) * p_mul.
*---Cihat Fark Bordrosu Kırılım 23.12.2014
      CASE s_rt-lgart.
        WHEN '/551' OR '/552'.
          col-fld01 = lv01.
          col-fld02 = lv02.
          col-lgart = s_rt-lgart.
          lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
          col-betrg = lv_tempmat * p_mul.
          COLLECT : col. CLEAR : col.
      ENDCASE.

**********************************************************************
      move_filter lv01 lv02.
**********************************************************************
****************** toplam net *****************
      READ TABLE pt_kostl WITH KEY val01 = lv01
                                   val02 = lv02 .
      hd06-val01 = pt_kostl-val01 .
      hd06-val02 = pt_kostl-val02 .

      LOOP AT gt003 WHERE anagr = '99'.
        LOOP AT gt004 WHERE anagr = gt003-anagr
                        AND altgr = '98'.
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-toplam_net.
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-toplam_net.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.


*<---- tahsil edilecek tutar ..
      LOOP AT gt003 WHERE anagr = '99' .
        LOOP AT gt004 WHERE anagr = gt003-anagr
                         AND altgr = '99' .
          LOOP AT gt005 WHERE anagr = gt004-anagr
                          AND altgr = gt004-altgr
                          AND slga = s_rt-lgart
                          AND sumwt = 'X'
                          AND ddntk = lv_ddntk.

*            ADD s_rt-betrg TO hd06-tahsil_edl .
            lv_tempmat = s_rt-betrg * <kpr> / 100.  " Ucret
            ADD lv_tempmat TO hd06-tahsil_edl.
          ENDLOOP .
        ENDLOOP .
      ENDLOOP .
      COLLECT hd06 . CLEAR hd06 .

    ENDLOOP.


*----
    READ TABLE ssort TRANSPORTING NO FIELDS WITH KEY fnam = 'P-KOSTL'.
    IF sy-subrc NE 0  OR lv_27 = 'X' .
      EXIT.
    ELSE.
      IF <kpr> IS ASSIGNED .
        lv_kpr = lv_kpr - <kpr>.
        CHECK lv_kpr GT 0   .
      ENDIF.
    ENDIF.
  ENDDO.


  LOOP AT pt_w WHERE amt IS INITIAL AND
                 saat IS INITIAL AND
                 num IS INITIAL .
    READ TABLE pt_total ASSIGNING FIELD-SYMBOL(<fs_tot>)
        WITH KEY val01 = pt_w-val01
                 val02 = pt_w-val02
                 anagr = pt_w-anagr
                 altgr = pt_w-altgr.
    IF sy-subrc EQ 0 .
      <fs_tot>-count = <fs_tot>-count - pt_w-count .
    ENDIF.

*    pt_total
  ENDLOOP.


  DELETE pt_w WHERE amt IS INITIAL AND
                 saat IS INITIAL AND
                 num IS INITIAL .

  LOOP AT pt_w.
    COLLECT pt_w INTO w .
  ENDLOOP.
  LOOP AT pt_total.
    COLLECT pt_total INTO total .
  ENDLOOP.

  LOOP AT pt_kostl.
    COLLECT pt_kostl INTO gt_kostl .
  ENDLOOP.
  REFRESH : pt_w, pt_total, pt_kostl.
ENDFORM.                    " fill_wages_to_son2
