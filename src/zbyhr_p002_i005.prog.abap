*&---------------------------------------------------------------------*
*& Include          ZBYHR_P002_I005
*&---------------------------------------------------------------------*

FORM fill_personel_data .

  CHECK p0027-kst01 IN s_kst01 .
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

*    CALL FUNCTION 'HR_CHECK_AUTHORITY_PERNR'
*      EXPORTING
*        pernr                      = pernr-pernr
*        begda                      = period-begda
*        endda                      = period-endda
*        uname                      = sy-uname
*      EXCEPTIONS
*        no_authorization_for_pernr = 1
*        OTHERS                     = 2.
*    CHECK sy-subrc = 0.


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
      IF p_srtza EQ 'A' .
*        PERFORM fill_wages_to_p USING 'A'  1.
        PERFORM fill_wages_to_p2 USING 'A'  1.
      ENDIF.
      IF p_srtza EQ 'P' .
*        PERFORM fill_wages_to_p USING 'P'  1.
        PERFORM fill_wages_to_p2 USING 'P'  1.
      ENDIF.
      IF p_srtza EQ 'F' .
        CLEAR check_p.
*        PERFORM fill_wages_to_p USING 'P' -1.
        PERFORM fill_wages_to_p2 USING 'P' -1.
        CHECK check_p EQ 'X'.
*        PERFORM fill_wages_to_p USING 'A'  1.
        PERFORM fill_wages_to_p2 USING 'A'  1.
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
                  <m>     TYPE any.
  DATA : lv_check TYPE c .
  DATA : w_rt LIKE rt.
  DATA : lv_fname(20).
  DATA : lr_apznr TYPE RANGE OF apznr .
  DATA : ls_apznr LIKE LINE OF lr_apznr.

  DATA : lv_count TYPE n.
  CLEAR: lv_count.
  DATA : lv_ddntk TYPE c.

  DATA : lv01 LIKE gt_kostl-val01.
  DATA : lv02 LIKE gt_kostl-val01.


  DEFINE move_filter.

**********************************************************************
    READ TABLE ssort INDEX 1 .
    IF sy-subrc EQ 0 .
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
        IF NOT p0001-kostl IS INITIAL .
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ELSE .
          CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
        ENDIF.
      ELSE .
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF .
      ASSIGN (lv_fname) TO <m> .
      gt_kostl-val01 = w-val01 = <m> .
      PERFORM set_text USING ssort-fnam+2(6) <m> w-txt01 .
      gt_kostl-txt01 = w-txt01 .
    ENDIF .
    READ TABLE ssort INDEX 2 .
    IF sy-subrc EQ 0 .
      CLEAR lv_fname .
      IF lv_count LE 1.
        IF ssort-fnam+2(6) EQ 'KOSTL' .
          IF NOT p0001-kostl IS INITIAL .
            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
          ELSE .
            CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
          ENDIF.
        ELSE .
          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
        ENDIF .
      ELSE.
        CLEAR s_wpbp.
        READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
                                             apznr   = s_rt-apznr.
        CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF.

      ASSIGN (lv_fname) TO <m> .
      gt_kostl-val02 = w-val02 = <m> .
      PERFORM set_text USING ssort-fnam+2(6) <m> w-txt02 .
      gt_kostl-txt02 = w-txt02 .
    ENDIF .

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


  ls_apznr-sign = 'I'.
  ls_apznr-option = 'EQ'.
  LOOP AT wpbp INTO s_wpbp WHERE btrtl IN pnpbtrtl.
    ls_apznr-low = s_wpbp-apznr .
    APPEND ls_apznr TO lr_apznr.
  ENDLOOP.

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
        CLEAR gt005.
        READ TABLE gt005 WITH KEY seqno = gt006-seqno
                                  anagr = gt006-anagr
                                  altgr = gt006-altgr
                                  slga  = gt006-slga
                                  ddntk = lv_ddntk.
        CHECK sy-subrc EQ 0.
        IF gt006-ssgrp EQ p0769-ssgrp. w-ssgrp = gt006-ssgrp.ENDIF." SSK Group
        IF gt006-pdate  EQ 'X'. w-num   = s_rt-anzhl.ENDIF." Gun
        IF gt006-phour  EQ 'X'. w-saat  = s_rt-anzhl.ENDIF." Saat
        IF gt006-person EQ 'X'. "w-count = 1.endif.
          READ TABLE personel WITH KEY pernr = pernr-pernr
                                       lgart = s_rt-lgart
                                       ddntk = lv_ddntk.
          IF sy-subrc NE 0.
            w-count = 1.
            personel-pernr = pernr-pernr. personel-lgart = s_rt-lgart.
            personel-ddntk = lv_ddntk.
            COLLECT personel.
          ELSE.
            w-count = 0.
          ENDIF.

        ENDIF." Personel Sayisi

        w-seqno = gt005-siran." Sıra Numarası
        w-anagr = gt005-anagr." Ana Grup
        w-altgr = gt005-altgr." Alt Grup
        w-slga  = gt005-slga ." Ucret Turu
        w-amt   = s_rt-betrg     ." Ucret

        w-lgtxt = gt005-lgtxt .
        w-seqno = gt005-siran." Sıra Numarası

        TRANSLATE w-lgtxt TO UPPER CASE.

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

    CLEAR gt005.
    READ TABLE gt005 WITH KEY slga = s_rt-lgart ddntk =
     lv_ddntk BINARY SEARCH.
    IF sy-subrc EQ 0.
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

      CLEAR gt006 .
      READ TABLE gt006 WITH KEY seqno  = gt005-seqno
                                anagr  = gt005-anagr
                                altgr  = gt005-altgr
                                slga   =  gt005-slga .
      IF gt006-lgart IS NOT INITIAL .

      ELSE .
        w-amt   = s_rt-betrg     . " Ucret
      ENDIF .

      IF s_rt-lgart EQ '/104' AND gt005-pdate EQ 'X'.
        w-amt = s_rt-anzhl .
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
          w-mat = w_rt-betrg.
        ELSE.
          CLEAR w-mat.
        ENDIF.
      ENDIF.

      IF gt005-pdate  EQ 'X'. w-num   = s_rt-anzhl.ENDIF." Gun
      IF gt005-phour  EQ 'X'. w-saat  = s_rt-anzhl.ENDIF." Saat
      IF gt005-person EQ 'X'. "w-count = 1.endif.
        READ TABLE personel WITH KEY pernr = pernr-pernr
                                    lgart    = s_rt-lgart
                                    ddntk  = lv_ddntk.
        IF sy-subrc NE 0.
          w-count = 1.
          personel-pernr = pernr-pernr. personel-lgart = s_rt-lgart.
          personel-ddntk = lv_ddntk .
          COLLECT personel.
        ELSE.
          w-count = 0.
        ENDIF.
      ENDIF." Personel Sayisi

      READ TABLE gt005 WITH KEY
      slga = w-slga ddntk = lv_ddntk BINARY SEARCH.
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


      "Description
      IF s_rt-lgart EQ '/104' .
        CLEAR w-lgtxt .
        w-lgtxt = TEXT-t01. "'SGK GÜNÜ'
      ENDIF .

      TRANSLATE w-lgtxt TO UPPER CASE.

      IF gt005-sumwt EQ 'X'.
        MOVE-CORRESPONDING w TO total.
        COLLECT total .
      ENDIF.

      COLLECT : w.
      IF NOT gt_kostl IS INITIAL .
        COLLECT gt_kostl .
      ENDIF .
      CLEAR: w, total,gt_kostl.

    ENDIF.



**********************************************************************
      move_filter lv01 lv02.
**********************************************************************

****************** toplam net *****************
    READ TABLE gt_kostl WITH KEY val01 = lv01
                                 val02 = lv02 .

    hd06-val01 = gt_kostl-val01 .
    hd06-val02 = gt_kostl-val02 .
    LOOP AT gt003 WHERE anagr = '98'.
      LOOP AT gt004 WHERE anagr = gt003-anagr
                      AND altgr = '98'.
        LOOP AT gt005 WHERE anagr = gt004-anagr
                        AND altgr = gt004-altgr
                        AND slga = s_rt-lgart
                        AND sumwt = 'X'
                        AND ddntk = lv_ddntk.

          ADD s_rt-betrg TO hd06-toplam_net.
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

          ADD s_rt-betrg TO hd06-tahsil_edl .
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
        col-betrg = s_rt-betrg * p_mul.
        COLLECT : col. CLEAR : col.
    ENDCASE.
*---Cihat Fark Bordrosu Kırılım 23.12.2014

  ENDLOOP.
*----



ENDFORM.                    " fill_wages_to_p2
*&---------------------------------------------------------------------*
*&      Form  fill_wages_to_p_w önceki ve aktif ücret hesaplama
*&---------------------------------------------------------------------*
*FORM fill_wages_to_p USING p_srtza TYPE c p_mul TYPE i.
*
*  FIELD-SYMBOLS : <val01> TYPE any,
*                  <val02> TYPE any,
*                  <m>     TYPE any.
*  DATA : lv_check TYPE c .
*  DATA : w_rt LIKE rt.
*  DATA : lv_fname(20).
*  DATA : lr_apznr TYPE RANGE OF apznr .
*  DATA : ls_apznr LIKE LINE OF lr_apznr.
*
*  DATA : lv_count TYPE n.
*  CLEAR: lv_count.
*  DATA : lv_ddntk TYPE c.
*
*  DATA : lv01 LIKE gt_kostl-val01.
*  DATA : lv02 LIKE gt_kostl-val01.
*
*
**-----
*  READ TABLE rgdir WITH KEY fpper = period-fpper srtza = p_srtza.
*  CHECK sy-subrc EQ 0.
*  check_p = 'X'.
*  rx-key-pernr = pernr-pernr.
*  UNPACK rgdir-seqnr TO rx-key-seqno.
*
** Control Data Cluster
*  CASE t500l-relid.
*    WHEN 'TR'.  rp-imp-c2-tr.
*    WHEN 'RX'.  rp-imp-c2-rx.
*  ENDCASE.
*
*  DATA : lv_rt LIKE rt OCCURS 0 WITH HEADER LINE.
*  MOVE rt[] TO lv_rt[].
**----
*
*  LOOP AT wpbp INTO DATA(s_wpbp) WHERE aktivjn EQ 'X'.
*    lv_count = lv_count + 1.
*  ENDLOOP.
*
*
*  ls_apznr-sign = 'I'.
*  ls_apznr-option = 'EQ'.
*  LOOP AT wpbp INTO s_wpbp WHERE btrtl IN pnpbtrtl.
*    ls_apznr-low = s_wpbp-apznr .
*    APPEND ls_apznr TO lr_apznr.
*  ENDLOOP.
*
*  CLEAR gt_rt[].
*  LOOP AT rt .
*    gt_rt = CORRESPONDING #( rt ) .
*    gt_rt-table = 'RT'.
*    APPEND gt_rt.
*  ENDLOOP.
*  LOOP AT ddntk .
*    gt_rt = CORRESPONDING #( ddntk ) .
*    gt_rt-table = 'DDNTK'.
*    gt_rt-apznr = s_wpbp-apznr.
*    APPEND gt_rt.
*  ENDLOOP.
**  LOOP AT rt WHERE apznr IN lr_apznr .
*  LOOP AT gt_rt INTO DATA(s_rt) WHERE apznr IN lr_apznr .
*    IF s_rt-table EQ 'DDNTK'.
*      lv_ddntk = 'X'.
*    ELSE.
*      CLEAR lv_ddntk.
*    ENDIF.
*    s_rt-betrg = abs( s_rt-betrg ) * p_mul.
*    s_rt-anzhl = abs( s_rt-anzhl ) * p_mul.
*    CLEAR lv_check .
*    CASE s_rt-lgart.
*      WHEN '/NDY' OR '/104'.
*        CASE p0769-sskod.
*          WHEN '2'. lv_check = 'X' .
*        ENDCASE.
*        CASE p0769-ssgrp.
*          WHEN '1'OR '2'.
*        ENDCASE.
*      WHEN '/561'.
*        s_rt-betrg =  s_rt-betrg * -1.
*    ENDCASE.
*
*
*    READ TABLE gt006 WITH KEY lgart = s_rt-lgart
*     BINARY SEARCH TRANSPORTING NO FIELDS.
*    IF sy-subrc EQ 0.
*      READ TABLE gt_t008 WITH KEY persg = p0001-persg .
*      IF sy-subrc EQ 0 .
*        READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
*                                    lgart = s_rt-lgart .
*        CHECK sy-subrc NE 0 .
*      ENDIF .
*
***********************************************************************
*      READ TABLE ssort INDEX 1 .
*      IF sy-subrc EQ 0 .
*        CLEAR lv_fname .
*        IF ssort-fnam+2(6) EQ 'KOSTL' .
*          IF NOT p0001-kostl IS INITIAL .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ELSE .
*            CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*          ENDIF.
*        ELSE .
*          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*        ENDIF .
*        ASSIGN (lv_fname) TO <m> .
*        gt_kostl-val01 = w-val01 = <m> .
*        PERFORM set_text USING ssort-fnam+2(6) <m> w-txt01 .
*        gt_kostl-txt01 = w-txt01 .
*      ENDIF .
*      READ TABLE ssort INDEX 2 .
*      IF sy-subrc EQ 0 .
*        CLEAR lv_fname .
*        IF lv_count LE 1.
*          IF ssort-fnam+2(6) EQ 'KOSTL' .
*            IF NOT p0001-kostl IS INITIAL .
*              CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*            ELSE .
*              CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*            ENDIF.
*          ELSE .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ENDIF .
*        ELSE.
*          CLEAR s_wpbp.
*          READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
*                                               apznr   = s_rt-apznr.
*          CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
*        ENDIF.
*
*        ASSIGN (lv_fname) TO <m> .
*        gt_kostl-val02 = w-val02 = <m> .
*        PERFORM set_text USING ssort-fnam+2(6) <m> w-txt02 .
*        gt_kostl-txt02 = w-txt02 .
*      ENDIF .
***********************************************************************
*
*      LOOP AT gt006 WHERE lgart EQ s_rt-lgart .
*        CLEAR gt005.
*        READ TABLE gt005 WITH KEY seqno = gt006-seqno
*                                  anagr = gt006-anagr
*                                  altgr = gt006-altgr
*                                  slga  = gt006-slga
*                                  ddntk = lv_ddntk.
*        CHECK sy-subrc EQ 0.
*        IF gt006-ssgrp EQ p0769-ssgrp. w-ssgrp = gt006-ssgrp.ENDIF." SSK Group
*        IF gt006-pdate  EQ 'X'. w-num   = s_rt-anzhl.ENDIF." Gun
*        IF gt006-phour  EQ 'X'. w-saat  = s_rt-anzhl.ENDIF." Saat
*        IF gt006-person EQ 'X'. "w-count = 1.endif.
*          READ TABLE personel WITH KEY pernr = pernr-pernr
*                                       lgart = s_rt-lgart
*                                       ddntk = lv_ddntk.
*          IF sy-subrc NE 0.
*            w-count = 1.
*            personel-pernr = pernr-pernr. personel-lgart = s_rt-lgart.
*            personel-ddntk = lv_ddntk.
*            COLLECT personel.
*          ELSE.
*            w-count = 0.
*          ENDIF.
*
*        ENDIF." Personel Sayisi
*
*        w-seqno = gt005-siran." Sıra Numarası
*        w-anagr = gt005-anagr." Ana Grup
*        w-altgr = gt005-altgr." Alt Grup
*        w-slga  = gt005-slga ." Ucret Turu
*        w-amt   = s_rt-betrg     ." Ucret
*
*        w-lgtxt = gt005-lgtxt .
*        w-seqno = gt005-siran." Sıra Numarası
*
*        TRANSLATE w-lgtxt TO UPPER CASE.
*
*        IF gt006-sumwt NE 'X' .
*          w-amt = w-amt * -1 .
*        ENDIF.
*
*        IF gt005-sumwt EQ 'X'.
*          MOVE-CORRESPONDING w TO total.
*          COLLECT total .
*        ENDIF.
*
*        COLLECT : w.
*
*        IF NOT gt_kostl IS INITIAL .
*          COLLECT gt_kostl .
*        ENDIF .
*        CLEAR: w, total, gt_kostl.
*
*      ENDLOOP .
*    ENDIF .
*
*    CLEAR gt005.
*    READ TABLE gt005 WITH KEY slga = s_rt-lgart ddntk =
*     lv_ddntk BINARY SEARCH.
*    IF sy-subrc EQ 0.
**<---
*      READ TABLE gt_t008 WITH KEY persg = p0001-persg .
*      IF sy-subrc EQ 0 .
*        READ TABLE gt_t007 WITH KEY perid = gt_t008-perid
*                                    lgart = s_rt-lgart .
*        CHECK sy-subrc NE 0 .
*      ENDIF .
*
*      w-anagr =  gt005-anagr. " Ana Grup
*      w-altgr =  gt005-altgr. " Alt Grup
*      w-seqno =  gt005-siran. " Sıra Numarası
*      w-slga  =  gt005-slga . " Ucret Turu
*
*      CLEAR gt006 .
*      READ TABLE gt006 WITH KEY seqno  = gt005-seqno
*                                anagr  = gt005-anagr
*                                altgr  = gt005-altgr
*                                slga   =  gt005-slga .
*      IF gt006-lgart IS NOT INITIAL .
*
*      ELSE .
*        w-amt   = s_rt-betrg     . " Ucret
*      ENDIF .
*
*      IF s_rt-lgart EQ '/104' AND gt005-pdate EQ 'X'.
*        w-amt = s_rt-anzhl .
*      ENDIF .
**            W-KOSTL = PERNR-KOSTL  . " Masraf Yeri
*
***********************************************************************
*      READ TABLE ssort INDEX 1 .
*      IF sy-subrc EQ 0 .
*        IF lv_count LE 1.
*          CLEAR lv_fname .
*          IF ssort-fnam+2(6) EQ 'KOSTL' .
*            IF NOT p0001-kostl IS INITIAL .
*              CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*            ELSE .
*              CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*            ENDIF.
*          ELSE .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ENDIF .
*        ELSE.
*          CLEAR s_wpbp.
*          READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
*                                               apznr   = s_rt-apznr.
*          CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
*
*        ENDIF.
*        ASSIGN (lv_fname) TO <m> .
*        gt_kostl-val01 = w-val01 = <m> .
*        PERFORM set_text USING ssort-fnam+2(6) <m> w-txt01 .
*        gt_kostl-txt01 = w-txt01 .
*      ENDIF .
*      READ TABLE ssort INDEX 2 .
*      IF sy-subrc EQ 0 .
*        IF lv_count LE 1.
*          CLEAR lv_fname .
*          IF ssort-fnam+2(6) EQ 'KOSTL' .
*            IF NOT p0001-kostl IS INITIAL .
*              CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*            ELSE .
*              CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*            ENDIF.
*          ELSE .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ENDIF .
*        ELSE.
*          CLEAR s_wpbp.
*          READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
*                                               apznr   = s_rt-apznr.
*          CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
*
*        ENDIF.
*        ASSIGN (lv_fname) TO <m> .
*        gt_kostl-val02 = w-val02 = <m> .
*        PERFORM set_text USING ssort-fnam+2(6) <m> w-txt02 .
*        gt_kostl-txt02 = w-txt02 .
*      ENDIF .
***********************************************************************
*
*
*      IF NOT gt005-milgrt IS INITIAL.
*        READ TABLE rt INTO w_rt WITH KEY
*         lgart = gt005-milgrt apznr = s_rt-apznr.
*        IF sy-subrc EQ 0.
*          "fark icmalinde matrah ücreti negatif gelmiyordu. 160712
*          w_rt-betrg = abs( w_rt-betrg ) * p_mul.
*          w-mat = w_rt-betrg.
*        ELSE.
*          CLEAR w-mat.
*        ENDIF.
*      ENDIF.
*
*      IF gt005-pdate  EQ 'X'. w-num   = s_rt-anzhl.ENDIF." Gun
*      IF gt005-phour  EQ 'X'. w-saat  = s_rt-anzhl.ENDIF." Saat
*      IF gt005-person EQ 'X'. "w-count = 1.endif.
*        READ TABLE personel WITH KEY pernr = pernr-pernr
*                                    lgart    = s_rt-lgart
*                                    ddntk  = lv_ddntk.
*        IF sy-subrc NE 0.
*          w-count = 1.
*          personel-pernr = pernr-pernr. personel-lgart = s_rt-lgart.
*          personel-ddntk = lv_ddntk .
*          COLLECT personel.
*        ELSE.
*          w-count = 0.
*        ENDIF.
*      ENDIF." Personel Sayisi
*
*      READ TABLE gt005 WITH KEY
*      slga = w-slga ddntk = lv_ddntk BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        w-lgtxt = gt005-lgtxt.
*      ENDIF.
*
*      IF w-lgtxt IS INITIAL.
*        CLEAR gt_t512t .
*        READ TABLE gt_t512t WITH KEY sprsl = gv_spras
*                                     molga = gv_molga
*                                     lgart = w-slga BINARY SEARCH.
*
*        IF sy-subrc EQ 0. w-lgtxt = gt_t512t-lgtxt. ENDIF.
*      ENDIF.
*
*
*      "Description
*      IF s_rt-lgart EQ '/104' .
*        CLEAR w-lgtxt .
*        w-lgtxt = TEXT-t01. "'SGK GÜNÜ'
*      ENDIF .
*
*      TRANSLATE w-lgtxt TO UPPER CASE.
*
*      IF gt005-sumwt EQ 'X'.
*        MOVE-CORRESPONDING w TO total.
*        COLLECT total .
*      ENDIF.
*
*      COLLECT : w.
*      IF NOT gt_kostl IS INITIAL .
*        COLLECT gt_kostl .
*      ENDIF .
*      CLEAR: w, total,gt_kostl.
*
*    ENDIF.
*
*
*
***********************************************************************
**** index 1
*    CLEAR : ssort , lv_fname.
*    READ TABLE ssort INDEX 1 .
*    IF sy-subrc EQ 0 .
*      IF lv_count LE 1.
*        IF ssort-fnam+2(6) EQ 'KOSTL' .
*          IF NOT p0001-kostl IS INITIAL .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ELSE .
*            CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*          ENDIF.
*        ELSE .
*          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*        ENDIF .
*      ELSE.
*        CLEAR s_wpbp.
*        READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
*                                             apznr   = s_rt-apznr.
*        CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
*
*      ENDIF.
*      ASSIGN (lv_fname) TO <val01> .
*      lv01 = <val01> .
*    ENDIF .
*
**** index 2
*    CLEAR : ssort , lv_fname.
*    READ TABLE ssort INDEX 2 .
*    IF sy-subrc EQ 0 .
*      IF lv_count LE 1 .
*        IF ssort-fnam+2(6) EQ 'KOSTL' .
*          IF NOT p0001-kostl IS INITIAL .
*            CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*          ELSE .
*            CONCATENATE 'P0027-' 'KST01' INTO lv_fname .
*          ENDIF.
*        ELSE .
*          CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*        ENDIF .
*      ELSE.
*        CLEAR s_wpbp.
*        READ TABLE wpbp INTO s_wpbp WITH KEY aktivjn = 'X'
*                                             apznr   = s_rt-apznr.
*        CONCATENATE 'S_WPBP-' ssort-fnam+2(6) INTO lv_fname.
*
*      ENDIF.
*      ASSIGN (lv_fname) TO <val02> .
*      lv02 = <val02> .
*    ENDIF .
***********************************************************************
*
******************* toplam net *****************
*    READ TABLE gt_kostl WITH KEY val01 = lv01
*                                 val02 = lv02 .
*
*    hd06-val01 = gt_kostl-val01 .
*    hd06-val02 = gt_kostl-val02 .
*    LOOP AT gt003 WHERE anagr = '98'.
*      LOOP AT gt004 WHERE anagr = gt003-anagr
*                      AND altgr = '98'.
*        LOOP AT gt005 WHERE anagr = gt004-anagr
*                        AND altgr = gt004-altgr
*                        AND slga = s_rt-lgart
*                        AND sumwt = 'X'
*                        AND ddntk = lv_ddntk.
*
*          ADD s_rt-betrg TO hd06-toplam_net.
*        ENDLOOP.
*      ENDLOOP.
*    ENDLOOP.
*
**<---- tahsil edilecek tutar ..
*    LOOP AT gt003 WHERE anagr = '99' .
*      LOOP AT gt004 WHERE anagr = gt003-anagr
*                       AND altgr = '99' .
*        LOOP AT gt005 WHERE anagr = gt004-anagr
*                        AND altgr = gt004-altgr
*                        AND slga = s_rt-lgart
*                        AND sumwt = 'X'
*                        AND ddntk = lv_ddntk.
*
*          ADD s_rt-betrg TO hd06-tahsil_edl .
*        ENDLOOP .
*      ENDLOOP .
*    ENDLOOP .
*    COLLECT hd06 . CLEAR hd06 .
**---->
**---Cihat Fark Bordrosu Kırılım 23.12.2014
*    CASE s_rt-lgart.
*      WHEN '/551' OR '/552'.
*        col-fld01 = lv01.
*        col-fld02 = lv02.
*        col-lgart = s_rt-lgart.
*        col-betrg = s_rt-betrg * p_mul.
*        COLLECT : col. CLEAR : col.
*    ENDCASE.
**---Cihat Fark Bordrosu Kırılım 23.12.2014
*
*  ENDLOOP.
**----
*
*
*
*ENDFORM.                    " fill_wages_to_p_w
*&---------------------------------------------------------------------*
*&   masraf yeri düzenlenmesi
*&---------------------------------------------------------------------*
FORM calculate_people_number .

  DATA : lv_datum2 TYPE datum .
  DATA lv_fname(30) .
  DATA : lv_kn(2) TYPE n.
  FIELD-SYMBOLS <m> TYPE any .

  CLEAR lv_kn.
  DO 20 TIMES.
    ADD 1 TO lv_kn.
*** index 1
    READ TABLE ssort INDEX 1 .
    CLEAR lv_fname .
    IF ssort-fnam+2(6) EQ 'KOSTL' .
      IF p0027 IS NOT INITIAL .
        CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
        ASSIGN (lv_fname) TO <m> .
        CHECK <m> IS NOT INITIAL .
      ELSE.
        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
      ENDIF.
    ELSE .
      CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
    ENDIF.

    ASSIGN (lv_fname) TO <m> .
    hd01-val02 = hd02-val02 = hd03-val02 =
    hd04-val02 = hd05-val02 = <m> .

*** index 2
    READ TABLE ssort INDEX 2 .
    IF sy-subrc EQ 0 .
      CLEAR lv_fname .
      IF ssort-fnam+2(6) EQ 'KOSTL' .
        IF p0027 IS NOT INITIAL .
          CONCATENATE 'P0027-' 'KST' lv_kn INTO lv_fname.
          ASSIGN (lv_fname) TO <m> .
          CHECK <m> IS NOT INITIAL .
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
    IF sy-subrc NE 0 .
      EXIT.
    ENDIF.
  ENDDO.
*
**** index 1
*  READ TABLE ssort INDEX 1 .
*  CLEAR lv_fname .
*  IF ssort-fnam+2(6) EQ 'KOSTL' .
*    IF NOT p0001-kostl IS INITIAL .
*      CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*    ELSE .
*      CONCATENATE 'P0027-' 'KST01' INTO lv_fname.
*    ENDIF .
*  ELSE .
*    CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*  ENDIF .
*  ASSIGN (lv_fname) TO <m> .
*  hd01-val01 = hd02-val01 = hd03-val01 =
*  hd04-val01 = hd05-val01 = <m> .
*
**** index 2
*  READ TABLE ssort INDEX 2 .
*  IF sy-subrc EQ 0 .
*    CLEAR lv_fname .
*    IF ssort-fnam+2(6) EQ 'KOSTL' .
*      IF NOT p0001-kostl IS INITIAL .
*        CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*      ELSE .
*        CONCATENATE 'P0027-' 'KST01' INTO lv_fname.
*      ENDIF .
*    ELSE .
*      CONCATENATE 'P0001-' ssort-fnam+2(6) INTO lv_fname.
*    ENDIF .
*    ASSIGN (lv_fname) TO <m> .
*    hd01-val02 = hd02-val02 = hd03-val02 =
*    hd04-val02 = hd05-val02 = <m> .
*
*  ENDIF .

*
*  ADD 1 TO hd01-say_01 . " Toplam Çalışan Sayisi
*  CASE p0002-gesch .
*    WHEN '1'. ADD 1 TO hd02-say_01 . " Erkek Sayisi
*    WHEN '2'. ADD 1 TO hd02-say_02 . " Kadin Sayisi
*  ENDCASE.
*  DATA : lv_datum TYPE datum.
*  DATA : lv_pernr TYPE persno.
*  lv_datum = pn-endda + 1.
*
*  SELECT SINGLE pernr FROM pa0000 INTO lv_pernr
*                                 WHERE pernr EQ pernr-pernr
*                                   AND stat2 NE '3'
*                                   AND begda LE lv_datum
*                                   AND begda GE pn-begda.
*  IF sy-subrc EQ 0.
*    ADD 1 TO hd03-say_04 .
*    CASE p0002-gesch .
*      WHEN '1'. ADD 1 TO hd03-say_05 . " Erkek Sayisi
*      WHEN '2'. ADD 1 TO hd03-say_06 . " Kadin Sayisi
*    ENDCASE.
*
*  ELSE .
*    CLEAR lv_datum2  .
*    lv_datum2 = p0000-endda + 1 .
*    " nakil
*    SELECT SINGLE pernr FROM pa0000 INTO lv_pernr
*                                WHERE pernr EQ pernr-pernr
*                                  AND massn EQ '02'
*                                  AND massg EQ '01'
*                                  AND begda LE lv_datum2
*                                  AND endda GE lv_datum2.
*
*    IF sy-subrc EQ 0.
*      ADD 1 TO hd03-say_04 .
*      CASE p0002-gesch .
*        WHEN '1'. ADD 1 TO hd03-say_05 . " Erkek Sayisi
*        WHEN '2'. ADD 1 TO hd03-say_06 . " Kadin Sayisi
*      ENDCASE.
*    ENDIF .
*
*  ENDIF.
*
*
*
*  LOOP AT p0000 WHERE ( massn EQ '01' OR massn EQ '12'
*                   OR   massn EQ '30' OR
*    ( massn EQ '02' AND massg EQ '01' ) ) " nakil
*                  AND pernr EQ pernr-pernr
*                  AND begda LE pn-endda
*                  AND begda GE pn-begda.
*  ENDLOOP.
*  IF sy-subrc EQ 0.
*    ADD 1 TO hd03-say_01 .
*    CASE p0002-gesch .
*      WHEN '1'. ADD 1 TO hd03-say_02 . " Erkek Sayisi
*      WHEN '2'. ADD 1 TO hd03-say_03 . " Kadin Sayisi
*    ENDCASE.
*  ENDIF.
*
*  LOOP AT p0001 WHERE begda LE pn-endda
*                  AND endda GE pn-begda.
*  ENDLOOP.
*  IF    p0001-persk EQ '10' OR p0001-persk EQ '20'
*     OR p0001-persk EQ '21' OR p0001-persk EQ '22 '
*     OR p0001-persk EQ '46'. "Beyaz Yaka Son hali 23.02.2023 tarihinde Emine Ekinci'den Gelen maile istinaden eklenmiştir.
*
*    ADD 1 TO hd04-say_01 .
*  ELSEIF p0001-persk EQ '30' OR p0001-persk EQ '31'
*        OR p0001-persk EQ '32' OR p0001-persk EQ '33'
*        OR p0001-persk EQ '45' OR p0001-persk EQ '50'  . "Mavi Yaka
*    ADD 1 TO hd04-say_02 .
*  ELSEIF p0001-persk EQ '40' OR p0001-persk EQ '41' " Stajyer
*      OR p0001-persk EQ '42'.
*    ADD 1 TO hd04-say_03 .
*  ENDIF.
*
*
*  LOOP AT p0769 WHERE begda LE pn-endda
*                  AND endda GE pn-begda.
*  ENDLOOP.
*  IF p0769-asucc EQ 'X'."Askari ücretli
*    CASE p0002-gesch .
*      WHEN '1'. ADD 1 TO hd05-say_01 . " Erkek Sayisi
*      WHEN '2'. ADD 1 TO hd05-say_02 . " Kadin Sayisi
*    ENDCASE.
*  ENDIF.
*  IF p0769-disab IS NOT INITIAL."Engelli
*    CASE p0002-gesch .
*      WHEN '1'. ADD 1 TO hd05-say_03 . " Erkek Sayisi
*      WHEN '2'. ADD 1 TO hd05-say_04 . " Kadin Sayisi
*    ENDCASE.
*  ENDIF.
*
*  COLLECT : hd01,hd02,hd03,hd04,hd05.
*
*  CLEAR : hd01,hd02,hd03,hd04,hd05.

ENDFORM.                    " CALCULATE_PEOPLE_NUMBER
*&---------------------------------------------------------------------*
*& Form ADD_ORT_UCT
*&---------------------------------------------------------------------*
FORM add_ort_uct .
  READ TABLE w INTO DATA(ok_w) INDEX 1.
  CLEAR w.
  IF p_ek1_t IS NOT INITIAL AND p_ek1_u IS NOT INITIAL.
    w-count = ok_w-count.
    w-txt01 = ok_w-txt01.
    w-txt02 = ok_w-txt02.
    w-val01 = ok_w-val01.
    w-val02 = ok_w-val02.
    w-slga  = ok_w-slga.
    w-anagr = '02'.
    w-altgr = '01'.
    w-amt   = p_ek1_u.
    w-lgtxt = p_ek1_t.
    APPEND w. CLEAR w.
  ENDIF.

  IF p_ek2_t IS NOT INITIAL AND p_ek2_u IS NOT INITIAL.
    w-count = ok_w-count.
    w-txt01 = ok_w-txt01.
    w-txt02 = ok_w-txt02.
    w-val01 = ok_w-val01.
    w-val02 = ok_w-val02.
    w-slga  = ok_w-slga.
    w-anagr = '02'.
    w-altgr = '01'.
    w-amt   = p_ek2_u.
    w-lgtxt = p_ek2_t.
    APPEND w. CLEAR w.
  ENDIF.

  IF p_ek3_t IS NOT INITIAL AND p_ek3_u IS NOT INITIAL.
    w-count = ok_w-count.
    w-txt01 = ok_w-txt01.
    w-txt02 = ok_w-txt02.
    w-val01 = ok_w-val01.
    w-val02 = ok_w-val02.
    w-slga  = ok_w-slga.
    w-anagr = '02'.
    w-altgr = '01'.
    w-amt   = p_ek3_u.
    w-lgtxt = p_ek3_t.
    APPEND w. CLEAR w.
  ENDIF.

  IF p_ek4_t IS NOT INITIAL AND p_ek4_u IS NOT INITIAL.
    w-count = ok_w-count.
    w-txt01 = ok_w-txt01.
    w-txt02 = ok_w-txt02.
    w-val01 = ok_w-val01.
    w-val02 = ok_w-val02.
    w-slga  = ok_w-slga.
    w-anagr = '02'.
    w-altgr = '01'.
    w-amt   = p_ek4_u.
    w-lgtxt = p_ek4_t.
    APPEND w. CLEAR w.
  ENDIF.

  IF p_ek5_t IS NOT INITIAL AND p_ek5_u IS NOT INITIAL.
    w-count = ok_w-count.
    w-txt01 = ok_w-txt01.
    w-txt02 = ok_w-txt02.
    w-val01 = ok_w-val01.
    w-val02 = ok_w-val02.
    w-slga  = ok_w-slga.
    w-anagr = '02'.
    w-altgr = '01'.
    w-amt   = p_ek5_u.
    w-lgtxt = p_ek5_t.
    APPEND w. CLEAR w.
  ENDIF.

ENDFORM.
