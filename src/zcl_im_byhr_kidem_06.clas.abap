class ZCL_IM_BYHR_KIDEM_06 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_HRPAYTR_KIDEM_06 .
PROTECTED SECTION.

  TYPES ts_ptr09 TYPE ptr09 .
  TYPES tt_ptr09 TYPE TABLE OF ts_ptr09.
private section.

  methods APPEND_RTAB
    importing
      !P_PERNR type PERSNO
      !P_LGART type LGART
      !P_BETRG type PTR_BETRG_1
      !P_WTEXT type LGTXT
    exporting
      !ET_RTAB type TT_PTR09 .
ENDCLASS.



CLASS ZCL_IM_BYHR_KIDEM_06 IMPLEMENTATION.


  METHOD append_rtab.

    DATA : ls_rtab TYPE ptr09.
    DATA : ls_0008 TYPE p0008.


    ASSIGN ('(HTRKID00)KIDENDDA') TO FIELD-SYMBOL(<fs_kid>).
    ASSIGN ('(HTRKID00)SAAT365') TO FIELD-SYMBOL(<fs_365>).
    ASSIGN ('(HTRKID00)H_ABART') TO FIELD-SYMBOL(<fs_abart>).
    IF <fs_365> IS NOT ASSIGNED   AND
       <fs_abart> IS NOT ASSIGNED AND
       <fs_kid> IS NOT ASSIGNED   .
      ASSIGN ('(ZBYHR_P016)KIDENDDA') TO <fs_kid>.
      ASSIGN ('(ZBYHR_P016)SAAT365') TO <fs_365>.
      ASSIGN ('(ZBYHR_P016)H_ABART') TO <fs_abart>.
    ENDIF.

    CHECK <fs_365> IS ASSIGNED .
    CHECK <fs_abart> IS ASSIGNED .
    CHECK <fs_kid> IS ASSIGNED .


    SELECT SINGLE *  FROM pa0008 INTO CORRESPONDING FIELDS OF ls_0008
        WHERE pernr EQ p_pernr
          AND endda GE <fs_kid>.


    CLEAR: ls_rtab.
    ls_rtab-lgtxt = p_wtext.
    ls_rtab-pernr = p_pernr.
    ls_rtab-betrg = p_betrg.

    IF <fs_abart> EQ '1' AND p_lgart EQ space.
      IF <fs_365> EQ 'X'.
        ls_rtab-betrg = ( ls_rtab-betrg * ( ls_0008-divgv / 30 )  *  365 ) / 12 .
      ELSE.
        ls_rtab-betrg = ls_rtab-betrg * ls_0008-divgv.
      ENDIF.
    ENDIF.
    ls_rtab-lgart = p_lgart.
    CHECK ls_rtab-betrg > 0.
    MODIFY et_rtab FROM ls_rtab TRANSPORTING betrg
        WHERE lgart EQ ls_rtab-lgart.
    IF sy-subrc NE 0 .
      APPEND ls_rtab TO et_rtab.
    ENDIF.
  ENDMETHOD.


  METHOD if_ex_hrpaytr_kidem_06~change_values.
    TYPES : ts_p0776 TYPE p0776,
            tt_p0776 TYPE TABLE OF ts_p0776,
            tr_lgart TYPE RANGE OF lgart.

    FIELD-SYMBOLS <ft_0776> TYPE tt_p0776.
    FIELD-SYMBOLS <ft_w_kistel> TYPE tr_lgart.


    DATA: BEGIN OF ls_it7trk02 .
            INCLUDE TYPE t7trk02.
    DATA:   cnt TYPE i.
    DATA: END OF ls_it7trk02.


    DATA : lt_t558a     TYPE TABLE OF t558a,
           lt_0000      TYPE TABLE OF p0000,
           lt_t021      TYPE TABLE OF zbyhr_t021,
           lt_it7trk02  LIKE TABLE OF ls_it7trk02,
           it_t7trk02   TYPE TABLE OF t7trk02,
           ls_g03       TYPE t7trg03,
           ls_rtab      TYPE ptr09,
           result       TYPE pay99_result,
           wa_rt        TYPE pc207,
           calcmolga    TYPE t500l-molga VALUE '47',
           in_rgdir     TYPE TABLE OF  pc261,
           gs_rgdir     TYPE pc261,
           k_beg        TYPE pc261-fpper,
           k_end        TYPE pc261-fpper,
           k_fpper      TYPE pc261-fpper,
           lv_sgkgn     TYPE anzhl,
           k_cnt_dif(2) TYPE n,
           lv_field(80).


*SY-CPROG
    CASE sy-cprog.
      WHEN 'ZBYHR_P016_OLD'.
        ASSIGN ('(ZBYHR_P016_OLD)ZSONBRD') TO FIELD-SYMBOL(<fs_zsonbrd>).
        ASSIGN ('(ZBYHR_P016_OLD)BYKKID') TO FIELD-SYMBOL(<fs_biryil>).
        ASSIGN ('(ZBYHR_P016_OLD)I0776[]') TO <ft_0776>.
        ASSIGN ('(ZBYHR_P016_OLD)KIDENDDA') TO FIELD-SYMBOL(<fs_kid>).
        ASSIGN ('(ZBYHR_P016_OLD)C_FACT') TO FIELD-SYMBOL(<fs_h_fact>).
        ASSIGN ('(ZBYHR_P016_OLD)STAND') TO FIELD-SYMBOL(<fs_stand>).
        ASSIGN ('(ZBYHR_P016_OLD)YPB') TO FIELD-SYMBOL(<fs_ypb>).
        ASSIGN ('(ZBYHR_P016_OLD)W_KISTEL[]') TO <ft_w_kistel>.
        ASSIGN ('(ZBYHR_P016_OLD)IPER-HIRE') TO FIELD-SYMBOL(<fs_hire>).
        CHECK <fs_kid>    IS ASSIGNED AND
              <fs_stand>  IS ASSIGNED AND
              <fs_h_fact> IS ASSIGNED AND
              <fs_biryil> IS ASSIGNED AND
              <ft_0776>   IS ASSIGNED AND
              <fs_hire>   IS ASSIGNED AND
              <fs_ypb>    IS ASSIGNED .
      WHEN 'ZBYHR_P016'.
        ASSIGN ('(ZBYHR_P016)ZSONBRD') TO <fs_zsonbrd>.
        ASSIGN ('(ZBYHR_P016)BIRYIL') TO <fs_biryil>.
        ASSIGN ('(ZBYHR_P016)I0776[]') TO <ft_0776>.
        ASSIGN ('(ZBYHR_P016)KIDENDDA') TO <fs_kid>.
        ASSIGN ('(ZBYHR_P016)H_FACT') TO <fs_h_fact>.
        ASSIGN ('(ZBYHR_P016)STAND') TO <fs_stand>.
        ASSIGN ('(ZBYHR_P016)YPB') TO <fs_ypb>.
        ASSIGN ('(ZBYHR_P016)HESAP') TO FIELD-SYMBOL(<fs_hesap>).
        ASSIGN ('(ZBYHR_P016)W_KISTEL[]') TO <ft_w_kistel>.
        ASSIGN ('(ZBYHR_P016)IPER-FCHIRE') TO <fs_hire>. " işe girişi 41 de farklı ise
        CHECK <fs_kid>    IS ASSIGNED AND
              <fs_stand>  IS ASSIGNED AND
              <fs_h_fact> IS ASSIGNED AND
              <fs_biryil> IS ASSIGNED AND
              <ft_0776>   IS ASSIGNED AND
              <fs_hesap>   IS ASSIGNED AND
              <fs_hire>   IS ASSIGNED AND
              <fs_ypb>    IS ASSIGNED .
        IF <fs_hire> IS INITIAL .
          ASSIGN ('(ZBYHR_P016)IPER-HIRE') TO <fs_hire>.  " FCHIRE boşsa iper-hire alınsın
        ENDIF.

      WHEN OTHERS.
        ASSIGN ('(HTRKID00)BIRYIL') TO <fs_biryil>.
        ASSIGN ('(HTRKID00)I0776[]') TO <ft_0776>.
        ASSIGN ('(HTRKID00)KIDENDDA') TO <fs_kid>.
        ASSIGN ('(HTRKID00)H_FACT') TO <fs_h_fact>.
        ASSIGN ('(HTRKID00)STAND') TO <fs_stand>.
        ASSIGN ('(HTRKID00)YPB') TO <fs_ypb>.
        ASSIGN ('(HTRKID00)HESAP') TO <fs_hesap>.
        ASSIGN ('(HTRKID00)WTY_UBZ[]') TO <ft_w_kistel>.
        ASSIGN ('(ZBYHR_P016_OLD)IPER-HIRE') TO <fs_hire>.
        CHECK <fs_kid>    IS ASSIGNED AND
              <fs_stand>  IS ASSIGNED AND
              <fs_h_fact> IS ASSIGNED AND
              <fs_biryil> IS ASSIGNED AND
              <ft_0776>   IS ASSIGNED AND
              <fs_hesap>   IS ASSIGNED AND
              <fs_hire>   IS ASSIGNED AND
              <fs_ypb>    IS ASSIGNED .
    ENDCASE.

    " Bordroda olmayan ek ücretler
    SELECT * FROM t558a INTO TABLE lt_t558a
        WHERE pernr EQ iper-pernr
          AND begda LE iper-fire
          AND endda GE <fs_hire>.


    SELECT * FROM zbyhr_t021 INTO TABLE lt_t021.

    SELECT * FROM t7trk02 INTO TABLE it_t7trk02
              WHERE begda LE <fs_kid> AND endda GE <fs_kid>.

    SELECT SINGLE * FROM t7trg04 INTO @DATA(ls_t7trg04)
                          WHERE werks EQ @iper-werks
                            AND btrtl EQ @iper-btrtl.


    SELECT * FROM pa0000 INTO CORRESPONDING FIELDS OF TABLE lt_0000
        WHERE pernr EQ iper-pernr.


    SELECT SINGLE * FROM t7trg03 INTO ls_g03
                WHERE persg EQ iper-persg
                 AND persk EQ iper-persk.

    LOOP AT it_t7trk02 INTO DATA(ls_k02)
                   WHERE kidem EQ ls_g03-kidem
                     AND betrg EQ 0
                     AND werks EQ iper-werks
                     AND btrtl EQ iper-btrtl.
      CLEAR ls_it7trk02.
      MOVE-CORRESPONDING ls_k02 TO ls_it7trk02.
      APPEND ls_it7trk02 TO lt_it7trk02.
    ENDLOOP.
    SORT lt_it7trk02 BY rtdiv.
    LOOP AT it_t7trk02 INTO ls_k02
              WHERE kidem EQ ls_g03-kidem
                    AND   betrg EQ 0
                    AND werks IS INITIAL
                    AND btrtl IS INITIAL.
      CLEAR ls_it7trk02.
      MOVE-CORRESPONDING ls_k02 TO ls_it7trk02.
      APPEND ls_it7trk02 TO lt_it7trk02.
    ENDLOOP.

    CALL FUNCTION 'CU_READ_RGDIR'
      EXPORTING
        persnr          = iper-pernr
      TABLES
        in_rgdir        = in_rgdir
      EXCEPTIONS
        no_record_found = 1
        OTHERS          = 2.

    CLEAR ls_it7trk02.
    LOOP AT lt_it7trk02 INTO ls_it7trk02.
      IF ls_it7trk02-rtkum GT 12.
        ls_it7trk02-rtkum = 12.
      ENDIF.
      IF ls_it7trk02-rtkum GT 0.
* Prim gibi ücretler (T9YKD-BETRG = 0, T9YKD-RTKUM > 0)
        IF <fs_zsonbrd> IS ASSIGNED .
          IF <fs_zsonbrd> EQ space.
            k_beg = k_end = iper-fire+0(6). "E.B.-REM
            k_fpper = iper-fire+0(6).
          ELSE.
            SORT in_rgdir BY fpper DESCENDING.
            READ TABLE in_rgdir  INTO DATA(rgdir) INDEX 1.
            k_fpper = rgdir-fpper.
            k_beg = k_end = k_fpper.
          ENDIF.
        ELSE.
          SORT in_rgdir BY fpper DESCENDING.
          READ TABLE in_rgdir INTO rgdir INDEX 1.
          k_fpper = rgdir-fpper.
          k_beg = k_end = k_fpper.

        ENDIF.
*        SORT in_rgdir BY fpper DESCENDING.
*        READ TABLE in_rgdir INTO DATA(rgdir) INDEX 1.
*        k_fpper = rgdir-fpper.
*        k_beg = k_end = k_fpper.


        IF k_beg+4(2) LE ls_it7trk02-rtkum.
* Bordro sonucunun bir ay öncesi kullanılır.
          k_beg+0(4) = k_beg+0(4) - 1.
          k_beg+4(2) = k_beg+4(2) + 12.
        ENDIF.
        k_beg = k_beg - ls_it7trk02-rtkum + 1.
        IF k_beg+5(1) EQ space.          "not relevant
          k_beg+5(1) = k_beg+4(1).
          k_beg+4(1) = '0'.
        ENDIF.
        CLEAR k_cnt_dif.
        LOOP AT in_rgdir INTO rgdir.
*        check l_it9ykd-rtkum ge sy-tabix.
          CHECK rgdir-fpper GE k_beg.
          CHECK rgdir-fpper LE k_fpper.
          CHECK: rgdir-srtza EQ <fs_stand> OR <fs_stand> EQ space.
          CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
            EXPORTING
              clusterid                    = 'TR'
              employeenumber               = iper-pernr
              sequencenumber               = rgdir-seqnr
              read_only_international      = 'X'
            CHANGING
              payroll_result               = result
            EXCEPTIONS
              illegal_isocode_or_clusterid = 1
              error_generating_import      = 2
              import_mismatch_error        = 3
              subpool_dir_full             = 4
              no_read_authority            = 5
              no_record_found              = 6
              versions_do_not_match        = 7
              OTHERS                       = 8.

*---SGK Günü
          CLEAR lv_sgkgn.
          LOOP AT result-inter-rt INTO wa_rt
                  WHERE lgart EQ '/NDY'
                  OR    lgart EQ '5445'
                  OR    lgart EQ '5450'.
            lv_sgkgn = lv_sgkgn + wa_rt-anzhl.
          ENDLOOP.



          LOOP AT result-inter-rt INTO wa_rt
                WHERE lgart EQ ls_it7trk02-lgart.

            DELETE lt_t558a WHERE lgart EQ ls_it7trk02-lgart
                              AND pernr EQ iper-pernr
                              AND begda LE rgdir-fpend
                              AND endda GE rgdir-fpbeg.

            ls_it7trk02-cnt = ls_it7trk02-cnt + 1.
* YTL Çevrimi için
            IF rgdir-fpper LE '200412' .
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  client           = sy-mandt
                  date             = '20050101'
                  foreign_amount   = wa_rt-betrg
                  foreign_currency = 'TRL'
                  local_currency   = <fs_ypb>
                IMPORTING
                  local_amount     = wa_rt-betrg.

            ENDIF.
*---Kıstelli Ücret ise 30 güne tamamla.
            IF wa_rt-lgart IN <ft_w_kistel> AND lv_sgkgn NE 0.
              wa_rt-betrg = wa_rt-betrg / lv_sgkgn * 30.
            ENDIF.

            ls_it7trk02-betrg = ls_it7trk02-betrg + wa_rt-betrg.
* Taner 14.02.2007
* bordrodan gelen değerin değiştirilmesi için badi

            DATA: l_badi_12 TYPE REF TO if_ex_hrpaytr_kidem_12.

            CALL METHOD cl_exithandler=>get_instance
              EXPORTING
                exit_name              = ''
                null_instance_accepted = ''
              CHANGING
                instance               = l_badi_12.

            CALL METHOD l_badi_12->change_values
              EXPORTING
                rt    = result-inter-rt[]
                lgart = ls_it7trk02-lgart
              CHANGING
                betrg = ls_it7trk02-betrg.

            MODIFY lt_it7trk02 FROM ls_it7trk02 .
          ENDLOOP.
          IF k_fpper+4(2) GT 1.
            k_fpper = k_fpper - 1.
          ELSE.
            k_fpper+0(4) = k_fpper+0(4) - 1.
            k_fpper+4(2) = 12.
          ENDIF.
          IF k_fpper LT k_beg.
            EXIT.
          ENDIF.
        ENDLOOP.

        "<<--------Bordroda olmayan ek ücretler------>>
        IF ( ls_it7trk02-rtkum EQ '01' AND ls_it7trk02-rtdiv EQ '01' AND ls_it7trk02-betrg EQ 0 ) OR
           ( NOT ( ls_it7trk02-rtkum EQ '01' AND ls_it7trk02-rtdiv EQ '01'  ) AND ls_it7trk02-betrg GE 0 ) OR ls_it7trk02-betrg EQ 0 .
          CLEAR : k_beg, k_fpper.
          SORT lt_t558a BY endda DESCENDING.
          k_beg = k_end = iper-fire+0(6).
          k_fpper = iper-fire+0(6).

          IF  k_beg IS NOT INITIAL .
            IF k_beg+4(2) LE ls_it7trk02-rtkum.
* Bordro sonucunun bir ay öncesi kullanılır.
              k_beg+0(4) = k_beg+0(4) - 1.
              k_beg+4(2) = k_beg+4(2) + 12.
            ENDIF.
            k_beg = k_beg - ls_it7trk02-rtkum + 1.
            IF k_beg+5(1) EQ space.          "not relevant
              k_beg+5(1) = k_beg+4(1).
              k_beg+4(1) = '0'.
            ENDIF.
          ENDIF.


          LOOP AT lt_t558a INTO DATA(ls_t558a)
                WHERE lgart EQ ls_it7trk02-lgart .
            CHECK ls_t558a-endda(6) GE k_beg.
            CHECK ls_t558a-endda(6) LE k_fpper.
            CLEAR lv_sgkgn.
            LOOP AT lt_t558a INTO DATA(l_sgkg)
                    WHERE begda LE ls_t558a-endda
                      AND endda GE ls_t558a-begda
                      AND ( lgart EQ '/NDY'
                         OR lgart EQ '5445'
                         OR lgart EQ '5450' ) .
              lv_sgkgn = lv_sgkgn + l_sgkg-anzhl.
            ENDLOOP.

            ls_it7trk02-cnt = ls_it7trk02-cnt + 1.

* YTL Çevrimi için
            IF ls_t558a-begda(6) LE '200412' .
              CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
                EXPORTING
                  client           = sy-mandt
                  date             = '20050101'
                  foreign_amount   = ls_t558a-betrg
                  foreign_currency = 'TRL'
                  local_currency   = <fs_ypb>
                IMPORTING
                  local_amount     = ls_t558a-betrg.
            ENDIF.
*---Kıstelli Ücret ise 30 güne tamamla.
            IF ls_t558a-lgart IN <ft_w_kistel> AND lv_sgkgn NE 0.
              ls_t558a-betrg = ls_t558a-betrg / lv_sgkgn * 30.
            ENDIF.
            ls_it7trk02-betrg = ls_it7trk02-betrg + ls_t558a-betrg.
            MODIFY lt_it7trk02 FROM ls_it7trk02 .
            IF k_fpper+4(2) GT 1.
              k_fpper = k_fpper - 1.
            ELSE.
              k_fpper+0(4) = k_fpper+0(4) - 1.
              k_fpper+4(2) = 12.
            ENDIF.
            IF k_fpper LT k_beg.
              EXIT.
            ENDIF.
          ENDLOOP.

        ENDIF.
        "<<--------END CODE------>>


* Bu k#sma dikkat.

        IF ls_it7trk02-rtkum GT ls_it7trk02-cnt.
        ENDIF.

        DESCRIBE TABLE in_rgdir LINES DATA(lv_pyc).

        IF ls_it7trk02-betrg GT 0.
          IF ls_it7trk02-cnt LE ls_it7trk02-rtdiv AND ls_it7trk02-cnt GT 0 .
            READ TABLE lt_t021 INTO DATA(ls_t021) WITH KEY lgart = ls_it7trk02-lgart.
            IF sy-subrc EQ 0 AND ls_t021-zcount EQ 'X'.
              ls_it7trk02-betrg = ls_it7trk02-betrg / ls_it7trk02-cnt.
            ELSE.
              IF lv_pyc LT ls_it7trk02-rtdiv.
                ls_it7trk02-betrg = ls_it7trk02-betrg / lv_pyc.
              ELSE.
                IF ls_it7trk02-rtdiv GT 0.
                  ls_it7trk02-betrg = ls_it7trk02-betrg / ls_it7trk02-rtdiv.
                ENDIF.
              ENDIF.

            ENDIF.
          ELSE.
            IF lv_pyc LT ls_it7trk02-rtdiv.
              ls_it7trk02-betrg = ls_it7trk02-betrg / lv_pyc.
            ELSE.
              IF ls_it7trk02-rtdiv GT 0.
                ls_it7trk02-betrg = ls_it7trk02-betrg / ls_it7trk02-rtdiv.
              ENDIF.
            ENDIF.
          ENDIF.

          SELECT SINGLE lgtxt FROM t512t INTO ls_rtab-lgtxt
            WHERE sprsl EQ sy-langu AND
                  molga EQ calcmolga AND
                  lgart EQ ls_it7trk02-lgart.
          append_rtab(
            EXPORTING
              p_pernr = iper-pernr
              p_lgart = ls_it7trk02-lgart
              p_betrg = ls_it7trk02-betrg
              p_wtext = ls_rtab-lgtxt
            IMPORTING
              et_rtab = rtab
          ).
        ENDIF.
      ELSE.
** Ikramiye ( T9YKD-BETRG = 0 & T9YKD-RTKUM = 0 olmali. )
        SELECT SINGLE lgtxt FROM t512t INTO ls_rtab-lgtxt
          WHERE sprsl EQ sy-langu AND
                molga EQ calcmolga AND
                lgart EQ ls_it7trk02-lgart.
        IF ls_it7trk02-rtdiv GT 0.
          ls_it7trk02-betrg = iper-betrg / ls_it7trk02-rtdiv.
        ELSE.
          ls_it7trk02-betrg = ls_rtab-betrg.   "Basic Pay
        ENDIF.

        append_rtab(
          EXPORTING
            p_pernr = iper-pernr
            p_lgart = ls_it7trk02-lgart
            p_betrg = ls_it7trk02-betrg
            p_wtext = ls_rtab-lgtxt
          IMPORTING
            et_rtab = rtab
        ).
      ENDIF.
    ENDLOOP.


    CLEAR iper-ekucr.
    LOOP AT rtab INTO ls_rtab WHERE pernr EQ iper-pernr.
*      IF ls_rtab-lgart IS INITIAL .
      IF ls_rtab-lgart IS INITIAL OR ls_rtab-lgart EQ '1100'.
        iper-betrg = ls_rtab-betrg * <fs_h_fact>.
      ELSE.
        iper-ekucr = iper-ekucr + ls_rtab-betrg * <fs_h_fact>.
      ENDIF.
    ENDLOOP.

    iper-topla = iper-betrg + iper-ekucr.
    IF iper-topla > iper-tavan.
      iper-k1yil = iper-tavan.
    ELSE.
      iper-k1yil = iper-topla.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
