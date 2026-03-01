*&---------------------------------------------------------------------*
*& Report ZBYHR_P005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT  zbyhr_p005 NO STANDARD PAGE HEADING   LINE-SIZE  1000.
*----include
INCLUDE ZBYHR_P005_in.
*---selection-screen
SELECT-OPTIONS : fpper  FOR  s001-spmon  OBLIGATORY .
*-----Parameters
PARAMETERS: tcurr LIKE  tcurr-tcurr,
            srtza LIKE  rgdir-srtza DEFAULT 'A'.
PARAMETERS: p_waers    LIKE  versc-waers DEFAULT 'TRY'.
PARAMETERS: setname  LIKE setheader-setname,
            subclass LIKE setheader-subclass NO-DISPLAY.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN SKIP 1.
  SELECT-OPTIONS : lgart FOR  rt-lgart, " NO-DISPLAY,
                   lgadd FOR  rt-lgart  NO-DISPLAY,
                   lgsub FOR  rt-lgart  NO-DISPLAY.
  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN:  PUSHBUTTON /1(15)  TEXT-100 USER-COMMAND lgart,
  PUSHBUTTON  18(15) TEXT-101 USER-COMMAND lgadd,
  PUSHBUTTON  35(15) TEXT-102 USER-COMMAND lgsub.
*                  pushbutton /10(18) text-102 user-command ZBYHR_T003.
SELECTION-SCREEN END OF BLOCK bl1.
*-----İnitialization.
INITIALIZATION.
  PERFORM initialization.
*-----At selection-screen.
AT SELECTION-SCREEN.
  PERFORM at_selection_screen.
*--At selection-screen on p_waers .
AT SELECTION-SCREEN ON p_waers .
  PERFORM control_currency .

*-----
AT SELECTION-SCREEN ON VALUE-REQUEST FOR setname.
  PERFORM get_setname_value.
*-----Start-of-selection.
START-OF-SELECTION.
  CLEAR: gv_val, gv_text.
  LOOP AT lgart.
    READ TABLE wt WITH KEY lgart = lgart-low.
    IF sy-subrc NE 0.
      CONCATENATE gv_text lgart-low INTO gv_text SEPARATED BY space.
      gv_val = 1.
      DELETE lgart.
      CLEAR lgart.
*      exit.
    ENDIF.
  ENDLOOP.
  IF gv_val = 1.
    MESSAGE ID 'RP' TYPE 'I' NUMBER '016'
       WITH gv_text+0(50) gv_text+51(50)
            'Ücret Tipi Listesinde Yer Almadığından'
            'SİLİNECEKTİR'.

    EXIT.
  ENDIF.

  PERFORM initial_condition.
  pnp_sw_skip_pernr = 'N'.
  rp-set-data-interval p0001 pnpbegda pnpendda.

GET pernr.
  PERFORM fill_personel_table_p.
*-----End-of-selection.
END-OF-SELECTION.
  PERFORM fill_variable_table_v.
  PERFORM calc_vom_vos_vsum.
  PERFORM calc_variable_output_values.
  PERFORM calc_variable_percentages.
  PERFORM write_vom_vos_vsum_to_screen.
*-----At user-command.
AT USER-COMMAND.
  PERFORM at_user_command.
*-----At line-selection.
AT LINE-SELECTION.
  PERFORM at_line_selection.
*---Top-of-page.
TOP-OF-PAGE.
  PERFORM top_page.
*---Top-of-page during line-selection.
TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM top_page.
*&---------------------------------------------------------------------*
*&      Form  INITIALIZATION
*&---------------------------------------------------------------------*
FORM initialization.
*-----
  MOVE : 'I'          TO fpper-sign   ,
         'EQ'         TO fpper-option ,
         sy-datum+(6) TO fpper-low    .
  APPEND fpper.
*-----Fill Aoutorization table
  MOVE : 'I'     TO   a_bukrs-sign,
         'EQ'    TO   a_bukrs-option.
  APPEND a_bukrs.
  SELECT bukrs FROM zbyhr_t008 INTO a_bukrs-low  WHERE uname EQ sy-uname
  .
    COLLECT a_bukrs.
  ENDSELECT.
  IF sy-subrc NE 0. MESSAGE e000(wt) WITH TEXT-010. ENDIF.
*-----
  SELECT lgtxt t_lgart FROM zbyhr_t003 INTO TABLE wt
                    WHERE sprsl     EQ   sy-langu   AND
                          progname  EQ   'BS'       AND
                          bukrs     IN   a_bukrs.
  LOOP AT wt.
    MOVE : '-'         TO   wt-lgtxt+20(1),
           wt-lgart    TO   wt-lgtxt+21(4).
    MODIFY wt.
  ENDLOOP.
  SORT wt BY lgart ASCENDING.
*-----
ENDFORM.                               " INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM at_selection_screen.
  CASE sscrfields-ucomm.
    WHEN 'LGART'. PERFORM fill_lgart.
    WHEN 'LGADD'. PERFORM fill_lgadd.
    WHEN 'LGSUB'. PERFORM fill_lgsub.
  "  WHEN 'ZBYHR_T003'. CALL TRANSACTION 'ZBYHR_T003'.
  ENDCASE.
ENDFORM.                               " AT_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*&      Form  INITIAL_CONDITION
*&---------------------------------------------------------------------*
FORM initial_condition.

*-----Fill Tables
  SELECT * FROM zbyhr_t005   INTO TABLE zbyhr_t005.
  SELECT ftxt_t fnam ftxt_n flen_n  flen_t FROM zbyhr_t006 INTO TABLE vp
  .
  SELECT * FROM zbyhr_t007 INTO TABLE zbyhr_t007.
*-----
  PERFORM calculate_periods_values.
  PERFORM set_wage_type_proporties.
  PERFORM set_initial_mods.
  PERFORM set_pf_status.
  PERFORM check_kostl_hiyerarsi.
*---Only Active personnel
  MOVE : 'I'   TO  pnpstat2-sign   ,
         'NE'  TO  pnpstat2-option ,
         '0'   TO  pnpstat2-low    .
  APPEND pnpstat2.
*---

  SELECT * FROM t7trg01 INTO TABLE gt_t7trg01 WHERE begda LE pnpendda
                                              AND   endda GE pnpendda.

ENDFORM.                               " INITIAL_CONDITION
*&---------------------------------------------------------------------*
*&      Form  FILL_PERSONEL_TABLE_P
*&---------------------------------------------------------------------*
FORM fill_personel_table_p.
*---İs there Any Payroll Result
  cd-key-pernr = pernr-pernr.
  rp-imp-c2-cd.
*----For performance
  CLEAR : p0000,p0001,first,p.
*------Period values
  LOOP AT f.
*-----Check p0000
    IF p0000-begda LE f-endda AND p0000-endda GE f-begda AND
                                  p0000-stat2 NE '0'.
    ELSE.
      LOOP AT p0000 WHERE stat2 NE '0'     AND
                          begda LE f-endda AND
                          endda GE f-begda.
      ENDLOOP.
      CHECK sy-subrc EQ 0.
    ENDIF.
*---Check p0001
    MOVE f-fpper TO p-fpper.
    IF NOT ( p0001-begda LE f-endda AND p0001-endda GE f-begda ) .
      LOOP AT p0001 WHERE begda LE f-endda AND endda GE f-begda.ENDLOOP.
      LOOP AT p0008 WHERE begda LE f-endda AND endda GE f-begda.
      ENDLOOP.
      LOOP AT p0002 WHERE begda LE f-endda AND endda GE f-begda.
      ENDLOOP.
      LOOP AT p0769 WHERE begda LE f-endda AND endda GE f-begda.ENDLOOP.
      PERFORM fill_personel_variables_to_p.
    ENDIF.

*-> SerenK 07122012, Split durumunda personelin kontrolü
    LOOP AT p0001 WHERE begda LE f-endda   AND endda GE f-begda   AND
                        bukrs IN pnpbukrs  AND sname IN pnpsname  AND
                        werks IN pnpwerks  AND btrtl IN pnpbtrtl  AND
                        persg IN pnppersg  AND persk IN pnppersk  AND
                        vdsk1 IN pnpvdsk1  AND abkrs IN pnpabkrs  AND
                        ansvh IN pnpansvh  AND kostl IN pnpkostl  AND
                        orgeh IN pnporgeh  AND plans IN pnpplans  AND
                        stell IN pnpstell  AND mstbr IN pnpmstbr  AND
                        otype IN pnpotype  AND ename IN pnpename  AND
                        bukrs IN a_bukrs .
      EXIT.
    ENDLOOP .
    CHECK sy-subrc = 0 .
    LOOP AT p0001 WHERE begda LE f-endda AND endda GE f-begda.ENDLOOP.
*-< SerenK 07122012, Split durumunda personelin kontrolü

*    CHECK :  p0001-bukrs   IN   pnpbukrs ,
*             p0001-bukrs   IN   a_bukrs  ,
*             p0001-kostl   IN   pnpkostl ,
*             p0001-werks   IN   pnpwerks ,
*             p0001-btrtl   IN   pnpbtrtl ,
*             p0001-orgeh   IN   pnporgeh ,
*             p0001-stell   IN   pnpstell ,
*             p0001-persg   IN   pnppersg ,
*             p0001-persk   IN   pnppersk ,
*             p0001-ansvh   IN   pnpansvh ,
*             p0001-abkrs   IN   pnpabkrs .
*-------

    IF  rp-imp-cd-subrc EQ 0.
      CLEAR : p-w[],w[].
      IF srtza EQ 'A' . PERFORM fill_wages_to_p USING 'A'  1. ENDIF.
      IF srtza EQ 'P' . PERFORM fill_wages_to_p USING 'P'  1. ENDIF.
      IF srtza EQ 'F' .
        PERFORM fill_wages_to_p USING 'A'  1.
        PERFORM fill_wages_to_p USING 'P' -1.
      ENDIF.
*-> Split için commentlendi, SerenK 14052012
*      PERFORM  calc_right_summury_in_p-w.
*      MOVE w[] TO p-w[].
*      APPEND p.
*-< Split için commentlendi, SerenK 14052012
    ELSE.
      APPEND p.
    ENDIF .

*----Memory
    MOVE : p-pernr TO pex-pernr, p-fpper TO pex-fpper. APPEND pex.
*IF NOT p-w[] IS INITIAL. first = 'X'. ENDIF. "Comment by VS on
*14.07.2014
  ENDLOOP.
*---
  IF first EQ 'X'.
    p-femod = 'X'.
    MODIFY p TRANSPORTING femod WHERE pernr = pernr-pernr.
  ENDIF.
*---Fill Table V
  MOVE : 'P-PERNR'    TO v-fnam,
          pernr-pernr TO v-fval,
          pernr-ename TO v-ftxt.
  APPEND v.
ENDFORM.                               " FILL_PERSONEL_TABLE_P
*&---------------------------------------------------------------------*
*&      Form  FILL_VARIABLE_TABLE_V
*&---------------------------------------------------------------------*
FORM fill_variable_table_v.
*---Begin of Add by VS on 03.02.2011 Upgrade
  DATA: lv_lsind(30),
        lv_ssk_no TYPE text40.
  lv_lsind = newmod-lsind.
*----Export Memory
  EXPORT pex TO MEMORY ID lv_lsind. REFRESH pex.
*  EXPORT pex TO MEMORY ID newmod-lsind. REFRESH pex.
*---Begin of Add by VS on 03.02.2011 Upgrade
*----
  DEFINE c_v.
    MOVE : &1 TO v-fnam, &2 TO v-fval. v-fadd =  p-bukrs. COLLECT v.
  END-OF-DEFINITION.
*---
  CLEAR : v-ftxt.
  LOOP AT p.
    ON CHANGE OF p-bukrs.
      MOVE :  p-bukrs TO vsm-fval_m. COLLECT vsm.
      c_v  'P-BUKRS' p-bukrs.
    ENDON.
    ON CHANGE OF p-werks.  c_v  'P-WERKS' p-werks.  ENDON.
    ON CHANGE OF p-btrtl.  c_v  'P-BTRTL' p-btrtl.  ENDON.
    ON CHANGE OF p-kanun.  c_v  'P-KANUN' p-kanun.  ENDON.
    ON CHANGE OF p-sskno.  c_v  'P-SSKNO' p-sskno.  ENDON.
    ON CHANGE OF p-kostl.  c_v  'P-KOSTL' p-kostl.  ENDON.
    ON CHANGE OF p-abkrs.  c_v  'P-ABKRS' p-abkrs.  ENDON.
    ON CHANGE OF p-orgeh.  c_v  'P-ORGEH' p-orgeh.  ENDON.
    ON CHANGE OF p-stell.  c_v  'P-STELL' p-stell.  ENDON.
    ON CHANGE OF p-persg.  c_v  'P-PERSG' p-persg.  ENDON.
    ON CHANGE OF p-persk.  c_v  'P-PERSK' p-persk.  ENDON.
    ON CHANGE OF p-pergr.  c_v  'P-PERGR' p-pergr.  ENDON.
    ON CHANGE OF p-ansvh.  c_v  'P-ANSVH' p-ansvh.  ENDON.
    ON CHANGE OF p-mstbr.  c_v  'P-MSTBR' p-mstbr.  ENDON.
    ON CHANGE OF p-sgmnt.  c_v  'P-SGMNT' p-sgmnt.  ENDON.
    ON CHANGE OF p-trfgr.  c_v  'P-TRFGR' p-trfgr.  ENDON.
    ON CHANGE OF p-trfst.  c_v  'P-TRFST' p-trfst.  ENDON.
    ON CHANGE OF p-gesch.  c_v  'P-GESCH' p-gesch.  ENDON.
    ON CHANGE OF p-setna.  c_v  'P-SETNA' p-setna.  ENDON.
"ON CHANGE OF p-sinif.  c_v  'P-SINIF' p-sinif.  ENDON. "Add by VS
"31.10.2016
"ON CHANGE OF p-depar.  c_v  'P-DEPAR' p-depar.  ENDON. "Add by VS
"31.10.2017
  ENDLOOP.
*---T001
  SORT v BY fnam fval.
  LOOP AT v WHERE fnam NE 'P-PERNR'.
    CLEAR v-ftxt.
    CASE v-fnam.
      WHEN 'P-BUKRS'.
        SELECT SINGLE butxt FROM t001 INTO v-ftxt WHERE bukrs EQ v-fval.
      WHEN 'P-KOSTL'.
        SELECT SINGLE * FROM tka02 WHERE bukrs = v-fadd ."Serenk11022013
        SELECT SINGLE ktext FROM cskt INTO v-ftxt WHERE kokrs EQ
        tka02-kokrs "v-fadd ""Serenk11022013
                                                   AND  kostl EQ v-fval.
      WHEN 'P-WERKS'.
        SELECT SINGLE name1 FROM t500p INTO v-ftxt WHERE persa EQ v-fval
        .
      WHEN 'P-BTRTL'.
        SELECT SINGLE btext FROM t001p INTO v-ftxt
        WHERE werks EQ v-fval+5(4) AND btrtl EQ v-fval+0(4).
      WHEN 'P-KANUN'.
*****Kanun bilgisi****************************
        CLEAR : gv_val , gv_txt .

        gv_val = v-fval.
        CALL FUNCTION 'GET_DOMAENENTEXT'
          EXPORTING
            dname           = 'PTR_SSKKN'
            dvalue          = gv_val
          IMPORTING
            dtext           = gv_txt
          EXCEPTIONS
            no_domain_found = 1
            OTHERS          = 2.
        v-ftxt = gv_txt.
      WHEN 'P-SSKNO'.
        READ TABLE gt_t7trg01 WITH KEY werks = v-fval+5(4)
                                       btrtl = v-fval+0(4).
        IF sy-subrc EQ 0.
          CALL FUNCTION 'ZHR_ISYERI_SSKNO_URET'
            EXPORTING
              sskno  = gt_t7trg01-sskno
              akodu  = gt_t7trg01-akodu
            IMPORTING
              ssk_no = lv_ssk_no.

          v-ftxt = lv_ssk_no.
        ENDIF.
      WHEN 'P-ABKRS'.
        SELECT SINGLE atext FROM t549t INTO v-ftxt
        WHERE sprsl EQ 'TR' AND abkrs EQ v-fval.
      WHEN 'P-ORGEH'. PERFORM get_txt_from_hrp1000 USING  'O ' v-fval.
      WHEN 'P-STELL'. PERFORM get_txt_from_hrp1000 USING  'C ' v-fval.
      WHEN 'P-SGMNT'.
        SELECT SINGLE name INTO v-ftxt FROM fagl_segmt
          WHERE langu EQ sy-langu
          AND   segment = v-fval.
      WHEN 'P-PERSG'.
        SELECT SINGLE ptext FROM t501t INTO v-ftxt
               WHERE sprsl = 'TR' AND   persg = v-fval.
      WHEN 'P-PERSK'.
        SELECT SINGLE ptext FROM t503t INTO v-ftxt
               WHERE sprsl = 'TR' AND   persk = v-fval.
      WHEN 'P-ANSVH'.
        SELECT SINGLE atx   FROM t542t INTO v-ftxt
               WHERE spras = 'TR' AND   ansvh = v-fval.
      WHEN 'P-SETNA'.
        SELECT SINGLE descript FROM setheadert INTO v-ftxt
               WHERE   langu    EQ sy-langu  AND
                       setclass EQ '0101'    AND
                       subclass EQ subclass  AND
                       setname  EQ v-fval.
*      WHEN 'P-SINIF'.
*        SELECT SINGLE zpergruptx FROM zzpergr INTO v-ftxt
*                                 WHERE bukrs = v-fadd
*                                 AND   zpergrup = v-fval .
*      WHEN 'P-ZZDEPARTMAN'.
*        SELECT SINGLE zzdeptxt FROM zzdepartman INTO v-ftxt
*                                 WHERE bukrs = v-fadd
*                                 AND   zzdepartman = v-fval .
      WHEN 'P-GESCH'.
*****cinsiyet bilgisi****************************
        CLEAR : gv_val , gv_txt .

        gv_val = v-fval.
        CALL FUNCTION 'GET_DOMAENENTEXT'
          EXPORTING
            dname           = 'GESCH'
            dvalue          = gv_val
          IMPORTING
            dtext           = gv_txt
          EXCEPTIONS
            no_domain_found = 1
            OTHERS          = 2.
        v-ftxt = gv_txt.

      WHEN OTHERS.
        SELECT SINGLE ftxt FROM zbyhr_t007 INTO v-ftxt
               WHERE   fnam EQ v-fnam AND fval EQ v-fval.
    ENDCASE.
    MODIFY v TRANSPORTING ftxt.
  ENDLOOP.
  SORT vsm BY fval_m fval_s.
*-----
ENDFORM.                               " FILL_VARIABLE_TABLE_V
*&---------------------------------------------------------------------*
*&      Form  CALC_VOM_VOS_VSUM
*&---------------------------------------------------------------------*
FORM calc_vom_vos_vsum.
*---Begin of Add by VS on 03.02.2011 Upgrade
  DATA: lv_lsind(30).
  lv_lsind = oldmod-lsind.
*--------İmport
*  IMPORT pex TO pim FROM MEMORY ID oldmod-lsind. CLEAR pex[]. SORT pim.
  IMPORT pex TO pim FROM MEMORY ID lv_lsind. CLEAR pex[]. SORT pim.
*---End of Add by VS on 03.02.2011 Upgrade
*---------Assign
  ASSIGN : (oldmod-fnam_m) TO <o_fnam_m>,
           (newmod-fnam_m) TO <n_fnam_m>.
  IF oldmod-fnam_s NE space.ASSIGN (oldmod-fnam_s) TO <o_fnam_s>.ENDIF.
  IF newmod-fnam_s NE space.ASSIGN (newmod-fnam_s) TO <n_fnam_s>.ENDIF.
*--------Sort
  MOVE newmod-fnam_m+2(5) TO fnam_m.
  IF newmod-fnam_s EQ space.
    SORT p BY (fnam_m) pernr fpper.
  ELSE.
    MOVE newmod-fnam_s+2(5) TO fnam_s.
    SORT p BY (fnam_m) (fnam_s) pernr fpper.
  ENDIF.
*--------
  MOVE 'X' TO first.
  FREE  : vom,vos,vsum.
  CLEAR : vom,vos,vsum,vsm.
*-----
  LOOP AT p .
    READ TABLE pim WITH KEY pernr = p-pernr fpper = p-fpper
                            BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK sy-subrc EQ 0.
*---Check Variables from selected previous list
    IF oldmod-fnam_s EQ space.
      IF  vsm-fval_m NE <o_fnam_m> OR <o_fnam_m> EQ space.
        READ TABLE vsm WITH KEY fval_m = <o_fnam_m> BINARY SEARCH.
        CHECK sy-subrc EQ 0.
      ENDIF.
    ELSE.
      IF  vsm-fval_m NE <o_fnam_m> OR vsm-fval_s NE <o_fnam_s>
                                   OR <o_fnam_m> EQ space.
        READ TABLE vsm WITH KEY fval_m = <o_fnam_m>
                                fval_s = <o_fnam_s>  BINARY SEARCH.
        CHECK sy-subrc EQ 0.
      ENDIF.
    ENDIF.
*---Export Memory
    MOVE : p-pernr TO pex-pernr,p-fpper TO pex-fpper.APPEND pex.
*----Check Full Empty All
    CHECK p-femod IN femod.
*---Fill Table Vom if not Slave
    IF newmod-fnam_s EQ space. PERFORM calc_vom_table_in_p.ENDIF.
    IF newmod-fnam_s NE space. PERFORM calc_vos_table_in_p.ENDIF.
  ENDLOOP.
*----AT LAST
  IF newmod-fnam_s EQ space.
    IF NOT vom-pcf[] IS INITIAL.
      SORT: vom-pcf,vom-w BY fpper lgart .
      APPEND vom. CLEAR : vom,vom-w[],vom-pcf[].
    ENDIF.
  ELSEIF NOT vos-pcf[] IS INITIAL.
    SORT: vos-pcf,vos-w BY fpper lgart .
    APPEND vos. CLEAR : vos,vos-w[],vos-pcf[].
  ENDIF.
*---------
  IF newmod-fnam_s NE space. PERFORM calc_vom_table_from_vos. ENDIF.
*---Variable Master Output Table
  LOOP AT vom.
*---Calculate VOM General summury
    LOOP AT vom-w INTO w WHERE fpper NE '999912'.
      COLLECT w INTO vsum-w.
      MOVE  '999912' TO w-fpper.
      COLLECT w INTO vom-w.
    ENDLOOP.
*---
    LOOP AT vom-pcf INTO pcf.
      COLLECT pcf-pernr INTO vom-pc .
      APPEND pcf TO vsum-pcf.
    ENDLOOP.
    SORT  vom-w BY fpper lgart.
    MODIFY vom TRANSPORTING w pc.
  ENDLOOP.
*----Variable Summury
  SORT : vsum-w BY fpper lgart, vsum-pcf BY pernr.
  LOOP AT vsum-w INTO w WHERE fpper NE '999912'.
    MOVE  '999912' TO w-fpper.
    COLLECT w INTO vsum-w.
  ENDLOOP.
  CLEAR pcf.
  LOOP AT vsum-pcf INTO pcf.
    COLLECT pcf-pernr INTO vsum-pc .
  ENDLOOP.
  SORT  vsum-w BY lgart.
*-----
ENDFORM.                               " CALC_VOM_VOS_VSUM
*&---------------------------------------------------------------------*
*&      Form  CALC_VARIABLE_OUTPUT_VALUES
*&---------------------------------------------------------------------*
FORM calc_variable_output_values.
*------SUMMURY
  PERFORM calc_wo TABLES  vsum-w vsum-wo vsum-pcf vsum-ppcf.
  DESCRIBE TABLE vsum-pc LINES vsum-count.
*------MASTER
  LOOP AT vom.
    CLEAR v.
    READ TABLE v WITH KEY fnam = newmod-fnam_m
                          fval = vom-fval_m BINARY SEARCH.
    MOVE v-ftxt TO vom-ftxt_m.
    PERFORM calc_wo TABLES  vom-w vom-wo vom-pcf vom-ppcf.
    DESCRIBE TABLE vom-pc LINES vom-count.
    MODIFY vom TRANSPORTING ftxt_m count wo ppcf .
  ENDLOOP.
*-----SLAVE
  LOOP AT vos.
    CLEAR v.
    READ TABLE v WITH KEY fnam = newmod-fnam_s
                          fval = vos-fval_s BINARY SEARCH.
    MOVE v-ftxt TO vos-ftxt_s.
    PERFORM calc_wo TABLES  vos-w vos-wo vos-pcf vos-ppcf.
    DESCRIBE TABLE vos-pc LINES vos-count.
    MODIFY vos TRANSPORTING ftxt_s count wo ppcf.
  ENDLOOP.
*-----
ENDFORM.                               " CALC_VARIABLE_OUTPUT_VALUES

*&---------------------------------------------------------------------*
*&      Form  CALC_VARIABLE_PERCENTAGES
*&---------------------------------------------------------------------*
FORM calc_variable_percentages.
  CHECK newmod-nrpmd NE 'SPACE'.
*---EVIRM = WAGES
  CONCATENATE 'W-'  newmod-nrmod INTO fnam_m.
  ASSIGN (fnam_m) TO <w_mul>.
  CONCATENATE 'WX-' newmod-nrmod INTO fnam_m.
  ASSIGN (fnam_m) TO <w_div>.
*-----
  LOOP AT vom.
    PERFORM calc_percentage TABLES vom-wo.
    MODIFY vom TRANSPORTING wo.
  ENDLOOP.
  LOOP AT vos.
    PERFORM calc_percentage TABLES vos-wo.
    MODIFY vos TRANSPORTING wo.
  ENDLOOP.
  PERFORM calc_percentage TABLES vsum-wo.
*-----
ENDFORM.                               " CALC_VARIABLE_PERCENTAGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_VOM_VOS_VSUM_TO_SCREEN
*&---------------------------------------------------------------------*
FORM write_vom_vos_vsum_to_screen.
*-----
  CHECK NOT  vom[] IS INITIAL.
*---Set variable field length
  READ TABLE vp WITH KEY fnam = newmod-fnam_m.
  lmn = vp-flen_n. lmt = vp-flen_t.
  IF newmod-fnam_s NE space.
    READ TABLE vp WITH KEY fnam = newmod-fnam_s.
    lsn = vp-flen_n. lst = vp-flen_t.
  ENDIF.
*--------
  MOVE 'X' TO box.
*--------
  IF newmod-evirm EQ 'WAGES'.
    PERFORM write_vom_vos_vsum_wages.
  ELSE.
    PERFORM write_vom_vos_vsum_prmod.
  ENDIF.
*-----Export Memory
  MOVE sy-lsind TO newmod-lsind. MOVE newmod TO oldmod . HIDE oldmod.
  SORT pex BY pernr fpper.

*---Begin of Add by VS on 03.02.2011 Upgrade
  DATA: lv_lsind(30).
  lv_lsind = newmod-lsind.
  EXPORT pex TO MEMORY ID lv_lsind.
*  EXPORT pex TO MEMORY ID newmod-lsind.
*---End of Add by VS on 03.02.2011 Upgrade
*-----
ENDFORM.                               " WRITE_VOM_VOS_VSUM_TO_SCREEN
*&---------------------------------------------------------------------*
*&      Form  AT_USER_COMMAND
*&---------------------------------------------------------------------*
FORM at_user_command.
*-----
  PERFORM set_newmod_and_oldmod.
  PERFORM set_pf_status.
*-----
  CASE newmod-ucomm.
    WHEN 'GRAPY'  OR 'GRAPX'.      PERFORM draw_graph_to_screen.
    WHEN 'LIST'.                   PERFORM call_basic_list.
    WHEN 'XMARK'.                  PERFORM mark_lines USING 'X'.
    WHEN 'BMARK'.                  PERFORM mark_lines USING ' '.
    WHEN OTHERS.
      PERFORM process_vakey.
      CHECK newmod-fnam_m NE space.
      PERFORM fill_table_vsm_for_select.
      PERFORM calc_vom_vos_vsum.
      PERFORM calc_variable_output_values.
      PERFORM calc_variable_percentages.
      PERFORM sort_variables.
      PERFORM write_vom_vos_vsum_to_screen.
  ENDCASE.
*-----
ENDFORM.                               " AT_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  AT_LINE_SELECTION
*&---------------------------------------------------------------------*
FORM at_line_selection.
*----
  MOVE sy-lilli TO index.
  PERFORM set_newmod_and_oldmod.
  PERFORM set_pf_status.
  MOVE 'VAKEY'   TO newmod-ucomm     .
  MOVE : 'P-PERNR' TO newmod-fnam_m,
         space     TO newmod-fnam_s.
  CLEAR : vsm,vsm[],vom,vos.
  READ LINE index.
  IF oldmod-fnam_s EQ space.
    MOVE : vom-fval_m    TO vsm-fval_m.
  ELSE.
    MOVE : vos-fval_m    TO vsm-fval_m,
           vos-fval_s    TO vsm-fval_s.
  ENDIF.
  COLLECT vsm.
*------
  PERFORM calc_vom_vos_vsum.
  PERFORM calc_variable_output_values.
  PERFORM calc_variable_percentages.
  PERFORM sort_variables.
  PERFORM write_vom_vos_vsum_to_screen.
ENDFORM.                               " AT_LINE_SELECTION
*&---------------------------------------------------------------------*
*&      Form  TOP_PAGE
*&---------------------------------------------------------------------*
FORM top_page.
*-----
  WRITE :  /, /2 'Kullanıcı:'                        COLOR 1 ,
             sy-uname                                COLOR 2 ,
             40 ' Tarih :'                           COLOR 1 ,
             sy-datum  NO-GAP                        COLOR 2 ,
              ' / ' NO-GAP COLOR 2 ,sy-uzeit         COLOR 2 ,
             75 'Sayfa no   :'                       COLOR 1 ,
                sy-pagno                             COLOR 2 ,
              /2 'Dönem    :'                        COLOR 1 .
*-----
  WRITE : fpper-low  NO-GAP COLOR 2.
  IF fpper-high NE space.
    WRITE :  '-' NO-GAP,  fpper-high COLOR 2.
  ENDIF.
  SKIP.
*-----
  FORMAT HOTSPOT ON.
  IF newmod-evirm EQ 'WAGES'. PERFORM top_of_page_wages. ENDIF.
  IF newmod-evirm EQ 'PRMOD'. PERFORM top_of_page_prmod. ENDIF.
  FORMAT HOTSPOT OFF.
*-----
ENDFORM.                               " TOP_PAGE
*&---------------------------------------------------------------------*
*&      Form  FILL_LGART
*&---------------------------------------------------------------------*
FORM fill_lgart.

  CLEAR: gv_val, gv_text.
  LOOP AT lgart.
    READ TABLE wt WITH KEY lgart = lgart-low.
    IF sy-subrc NE 0.
      CONCATENATE gv_text lgart-low INTO gv_text SEPARATED BY space.
      gv_val = 1.
      DELETE lgart.
*      exit.
    ENDIF.
  ENDLOOP.
  IF gv_val = 1.
    MESSAGE ID 'RP' TYPE 'I' NUMBER '016'
       WITH gv_text+0(50) gv_text+51(50)
            'Ücret Tipi Listesinde Yer Almadığından'
            'SİLİNECEKTİR'.
    EXIT.
  ENDIF.

*-----
  REFRESH wts.
  LOOP AT lgart.
    READ TABLE wt WITH KEY lgart = lgart-low.
    CHECK sy-subrc EQ 0.  APPEND wt TO wts.
  ENDLOOP.
*---
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields  = 50
      titel1     = TEXT-001
    TABLES
      fieldtabin = wt
      selfields  = wts.
*-----Fill Lgart
  REFRESH lgart.
  LOOP AT wts.
    MOVE : 'I'         TO   lgart-sign,
           'EQ'        TO   lgart-option,
           wts-lgart   TO   lgart-low.
    APPEND lgart.
  ENDLOOP.
*-----Refresh right summury
  REFRESH wts.
  DELETE lgadd WHERE NOT low IN lgart.
  DELETE lgsub WHERE NOT low IN lgart.
*-----
ENDFORM.                               " FILL_LGART
*&---------------------------------------------------------------------*
*&      Form  FILL_LGADD
*&---------------------------------------------------------------------*
FORM fill_lgadd.
*---
  CHECK NOT lgart[] IS INITIAL.
*---
  REFRESH: wts,wts_t.
  LOOP AT lgart.
    READ TABLE wt    WITH KEY lgart = lgart-low.
    READ TABLE lgsub WITH KEY low   = lgart-low.
    CHECK sy-subrc NE 0.
    APPEND wt TO wts.
  ENDLOOP.
  CHECK NOT wts[] IS INITIAL.
*---
  LOOP AT lgadd.
    READ TABLE wts WITH KEY lgart = lgadd-low.
    APPEND wts TO wts_t.
  ENDLOOP.
*-----
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields  = 50
      titel1     = TEXT-002
    TABLES
      fieldtabin = wts
      selfields  = wts_t.
*-----
  REFRESH lgadd.
  LOOP AT wts_t.
    MOVE : 'I'           TO   lgadd-sign,
           'EQ'          TO   lgadd-option,
           wts_t-lgart   TO   lgadd-low.
    APPEND lgadd.
  ENDLOOP.
*-----
ENDFORM.                               " FILL_LGADD
*&---------------------------------------------------------------------*
*&      Form  FILL_LGSUB
*&---------------------------------------------------------------------*
FORM fill_lgsub.
  CHECK NOT lgart[] IS INITIAL.
*---
  REFRESH: wts,wts_t.
  LOOP AT lgart.
    READ TABLE wt    WITH KEY lgart = lgart-low.
    READ TABLE lgadd WITH KEY low   = lgart-low.
    CHECK sy-subrc NE 0.
    APPEND wt TO wts.
  ENDLOOP.
  CHECK NOT wts[] IS INITIAL.
*---
  LOOP AT lgsub.
    READ TABLE wts WITH KEY lgart = lgsub-low.
    APPEND wts TO wts_t.
  ENDLOOP.
*---
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields  = 50
      titel1     = TEXT-003
    TABLES
      fieldtabin = wts
      selfields  = wts_t.
*---
  REFRESH lgsub.
  LOOP AT wts_t.
    MOVE : 'I'           TO   lgsub-sign,
           'EQ'          TO   lgsub-option,
           wts_t-lgart   TO   lgsub-low.
    APPEND lgsub.
  ENDLOOP.
*-----
ENDFORM.                               " FILL_LGSUB
*&---------------------------------------------------------------------*
*&      Form  CALCULATE_PERIODS_VALUES
*&---------------------------------------------------------------------*
FORM calculate_periods_values.
*---
  MOVE  fpper-low TO  f-fpper.
  CONCATENATE f-fpper '01' INTO f-begda.
  PERFORM find_begda_endda USING f-begda  f-endda.
  APPEND f.
*---
  WHILE fpper-high GT f-fpper.
    IF  f-fpper+4(2) EQ '12'.
      f-fpper+4(2) = '01' . ADD 1 TO f-fpper(4) .
    ELSE.
      ADD 1 TO f-fpper+4(2) .
    ENDIF.
    CONCATENATE f-fpper '01' INTO f-begda.
    PERFORM find_begda_endda USING f-begda   f-endda.
    APPEND f.
  ENDWHILE.
*---Dönem Hesabı
  CONCATENATE fpper-low '01' INTO pnpbegda.
  CONCATENATE f-fpper   '01' INTO pnpendda.
  PERFORM find_begda_endda USING pnpendda pnpendda.
*---
  MOVE : pnpbegda TO pn-begps,
         pnpendda TO pn-endps.
*---Calculate Exchange Rates
  IF tcurr NE space.
    LOOP AT f.
      MOVE : 1000000000 TO f-divid.
      CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
        EXPORTING
          date             = f-endda
          foreign_currency = tcurr
          local_amount     = f-divid
          local_currency   = scurr
        IMPORTING
          foreign_amount   = f-multi.
      MODIFY f.
    ENDLOOP.
  ENDIF.
*------
  DEFINE addfp.
    CLEAR fp.
    MOVE &3 TO fp-prmod.
    IF f-fpper+4(2) BETWEEN &1 AND &2.
      CONCATENATE  f-fpper+0(4) &1 INTO fp-low.
      CONCATENATE  f-fpper+0(4) &2 INTO fp-high.
      IF fp-prmod EQ 'PR012'.
        MOVE f-fpper+0(4) TO fp-txt.
      ELSE.
        CONCATENATE fp-low+4(2)  '.'  fp-low(4)    '-'
                    fp-high+4(2) '.'  fp-high(4)  INTO fp-txt.
      ENDIF.
      COLLECT fp.
    ENDIF.
  END-OF-DEFINITION.
*---FILL TABLE FPP
  LOOP AT f.
*---Monthly
    MOVE : 'PR001'   TO fp-prmod,
           f-fpper   TO fp-low  ,
           f-fpper   TO fp-high .
    CONCATENATE f-fpper+4(2)  '.'  f-fpper(4) INTO fp-txt.
    COLLECT fp.
*---Three Montly
    addfp :  '01' '03' 'PR003',
             '04' '06' 'PR003',
             '07' '09' 'PR003',
             '10' '12' 'PR003'.
*-----Six Montly
    addfp : '01' '06' 'PR006',
            '07' '12' 'PR006'.
*-----Yearly
    addfp : '01' '12' 'PR012'.
  ENDLOOP.
  SORT fp.
*------
ENDFORM.                               " CALCULATE_PERIODS_VALUES
*&---------------------------------------------------------------------*
*&      Form  FIND_BEGDA_ENDDA
*&---------------------------------------------------------------------*
FORM find_begda_endda USING    p_begda p_endda.
*-----
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_begda
    IMPORTING
      last_day_of_month = p_endda.
*-----
ENDFORM.                               " FIND_BEGDA_ENDDA
*&---------------------------------------------------------------------*
*&      Form  SET_WAGE_TYPE_PROPORTIES
*&---------------------------------------------------------------------*
FORM set_wage_type_proporties.
*-----
  IF lgart[] IS INITIAL.MESSAGE i208(00) WITH TEXT-110. STOP. ENDIF.
  REFRESH wts.
  LOOP AT lgart .
    READ TABLE wt WITH KEY lgart = lgart-low. APPEND wt TO wts.
  ENDLOOP.
*-----Get Group Source Wage types
  SELECT * FROM zbyhr_t004  INTO TABLE  zbyhr_t004 FOR ALL ENTRIES IN
  wts
            WHERE progname EQ 'BS'  AND t_lgart  EQ wts-lgart AND
                  bukrs    IN a_bukrs.
*-----Set LGART Ranges
  REFRESH lgart.
  MOVE : 'I'     TO   lgart-sign,
         'EQ'    TO   lgart-option.
  LOOP AT zbyhr_t004.
    MOVE :  zbyhr_t004-s_lgart  TO  lgart-low. APPEND lgart.
  ENDLOOP.
*-----CHECK ZBYHR_T004
  LOOP AT zbyhr_t004.
    IF zbyhr_t004-amt_mul = 0. zbyhr_t004-amt_mul = 1. ENDIF.
    IF zbyhr_t004-amt_div = 0. zbyhr_t004-amt_div = 1. ENDIF.
    IF zbyhr_t004-num_mul = 0. zbyhr_t004-num_mul = 1. ENDIF.
    IF zbyhr_t004-num_div = 0. zbyhr_t004-num_div = 1. ENDIF.
    MODIFY zbyhr_t004.
  ENDLOOP.
*-----Add to Right Summury
  CHECK NOT lgadd[] IS INITIAL.
  MOVE '+' TO wts-sumsign.
  MODIFY wts TRANSPORTING sumsign WHERE lgart IN lgadd.
*-----Substract From Right Summury
  IF NOT lgsub[] IS INITIAL.
    MOVE '-' TO wts-sumsign.
    MODIFY wts TRANSPORTING sumsign WHERE lgart IN lgsub.
  ENDIF.
  MOVE : 'Toplam '     TO wts-lgtxt  ,
         '&&&&'        TO wts-lgart  ,
         space         TO wts-sumsign.
  APPEND wts.
*-----
ENDFORM.                               " SET_WAGE_TYPE_PROPORTIES
*&---------------------------------------------------------------------*
*&      Form  SET_INITIAL_MODS
*&---------------------------------------------------------------------*
FORM set_initial_mods.
*-----
  MOVE : 'PRSUM'   TO newmod-prmod,
         'AMT  '   TO newmod-nrmod,
         'SPACE'   TO newmod-nrpmd,
         'ALL  '   TO newmod-femod,
         'WAGES'   TO newmod-evirm,
         'VAKEY'   TO newmod-ucomm,
         'P-BUKRS' TO newmod-fnam_m,
          1        TO newmod-lsind,
          newmod   TO oldmod      ,
          TEXT-104 TO evirm       .
ENDFORM.                               " SET_INITIAL_MODS
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
FORM set_pf_status.
*---SET FULL EMPTY ALL
  FREE: fcode,femod.
  MOVE : 'I'   TO femod-sign  , 'EQ'  TO femod-option.
  IF newmod-femod EQ 'FULL'.  femod-low = 'X'. APPEND femod. ENDIF.
  IF newmod-femod EQ 'EMPTY'. femod-low = ' '. APPEND femod. ENDIF.
*-----Fill Fcode
  APPEND :   newmod-nrmod TO fcode,
             newmod-nrpmd TO fcode,
             newmod-prmod TO fcode,
             newmod-femod TO fcode.
  IF tcurr EQ space.    APPEND 'C_AMT' TO fcode. ENDIF.
  IF lgadd[] IS INITIAL.
    APPEND: 'NRROW' TO fcode,'TOTAL' TO fcode.
  ENDIF.
*------
  SET PF-STATUS 'PAYROLL' EXCLUDING fcode.
  IF sy-lsind EQ 16. sy-lsind = 1. ENDIF.
*-----
ENDFORM.                               " SET_PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  FILL_PERSONEL_VARIABLES_TO_P
*&---------------------------------------------------------------------*
FORM fill_personel_variables_to_p.
*----
  IF setna-kostl NE p0001-kostl AND setname NE space.
    READ TABLE setna WITH KEY kostl = p0001-kostl.
  ENDIF.
*------
  IF p-persg NE zbyhr_t005-persg OR p-persk NE zbyhr_t005-persk.
    CLEAR zbyhr_t005.
    READ TABLE zbyhr_t005 WITH KEY persg = p-persg persk = p-persk.
  ENDIF.
*-----
  MOVE : p0001-pernr   TO    p-pernr ,
         p0001-bukrs   TO    p-bukrs ,
         p0001-kostl   TO    p-kostl ,
         p0001-werks   TO    p-werks ,
         p0001-orgeh   TO    p-orgeh ,
         p0001-stell   TO    p-stell ,
         p0001-persg   TO    p-persg ,
         p0001-persk   TO    p-persk ,
         p0001-ansvh   TO    p-ansvh ,
         p0001-abkrs   TO    p-abkrs ,
         p0001-mstbr   TO    p-mstbr ,
         p0001-sgmnt   TO    p-sgmnt ,
         p0001-zzpersnf TO   p-sinif ,
*         p0001-zzdepartman TO p-depar ,
         p0008-trfgr   TO    p-trfgr ,
         p0008-trfst   TO    p-trfst ,
         p0002-gesch   TO    p-gesch ,
         p0769-kanun   TO    p-kanun ,
         setna-setname TO    p-setna ,
         zbyhr_t005-pergr   TO    p-pergr .
  CONCATENATE  p0001-btrtl '-' p0001-werks INTO  p-btrtl .
  CONCATENATE  p0001-btrtl '-' p0001-werks INTO  p-sskno .
*  READ TABLE gt_t7trg01 WITH KEY werks = p0001-werks
*                                 btrtl = p0001-btrtl.
*  IF sy-subrc EQ 0.
*    p-sskno = gt_t7trg01-sskno.
*  ENDIF.
*----
ENDFORM.                               " FILL_PERSONEL_VARIABLES_TO_P
*&---------------------------------------------------------------------*
*&      Form  FILL_WAGES_TO_P
*&---------------------------------------------------------------------*
FORM fill_wages_to_p USING p_srtza TYPE c p_mul TYPE i.
*-----
  READ TABLE rgdir WITH KEY fpper = f-fpper srtza = p_srtza.
  CHECK sy-subrc EQ 0.
  rx-key-pernr = pernr-pernr.
  UNPACK rgdir-seqnr TO rx-key-seqno.
  rp-imp-c2-tr.
*-----Conversion
  PERFORM convert_currency_payroll USING versc-waers  p_waers.
*-----
  MOVE f-fpper TO w-fpper.


*-> "Split için, SerenK 10052012
  READ TABLE rt WITH KEY lgart = '/SPL' .
  IF sy-subrc = 0 .
    LOOP AT wpbp WHERE aktivjn = 'X'.

      CHECK ( wpbp-massn IN pnpmassn ) AND ( wpbp-massg IN pnpmassg )
      AND
            ( wpbp-stat2 IN pnpstat2 ) AND ( wpbp-bukrs IN pnpbukrs )
            AND
            ( wpbp-werks IN pnpwerks ) AND ( wpbp-btrtl IN pnpbtrtl )
            AND
            ( wpbp-persg IN pnppersg ) AND ( wpbp-persk IN pnppersk )
            AND
            ( wpbp-vdsk1 IN pnpvdsk1 ) AND
            ( wpbp-ansvh IN pnpansvh ) AND ( wpbp-kostl IN pnpkostl )
            AND
            ( wpbp-orgeh IN pnporgeh ) AND ( wpbp-plans IN pnpplans )
            AND
            ( wpbp-stell IN pnpstell ) .

      REFRESH gr_apznr .CLEAR gr_apznr.
      gr_apznr-sign = 'I' .gr_apznr-option = 'EQ' .gr_apznr-low =
      wpbp-apznr .APPEND gr_apznr .
      IF wpbp-apznr = '01' .gr_apznr-low = '00' .APPEND gr_apznr .ENDIF
      .

      MOVE : wpbp-bukrs   TO    p-bukrs ,
             wpbp-kostl   TO    p-kostl ,
             wpbp-werks   TO    p-werks ,
             wpbp-orgeh   TO    p-orgeh ,
             wpbp-stell   TO    p-stell ,
             wpbp-sgmnt   TO    p-sgmnt ,
             wpbp-persg   TO    p-persg ,
             wpbp-persk   TO    p-persk ,
             wpbp-ansvh   TO    p-ansvh ,
             wpbp-trfgr   TO    p-trfgr ,
             wpbp-trfst   TO    p-trfst .

      MOVE : p0001-zzpersnf TO  p-sinif . "Add by VS 31.12.2016
      MOVE : p0002-gesch  TO    p-gesch . "Add by VS 18.05.2017
      MOVE : p0769-kanun  TO    p-kanun . "Add by VS 22.11.2017

      CONCATENATE  wpbp-btrtl '-' wpbp-werks INTO  p-sskno .

      CONCATENATE  wpbp-btrtl '-' wpbp-werks INTO  p-btrtl .
      CLEAR : p-w[],
              w[].

*-< "Split için, SerenK 10052012
      LOOP AT rt WHERE lgart IN lgart AND apznr IN gr_apznr .
      "Split için apznr kontrolü eklendi, SerenK 10052012

*---All Wages positive
        rt-betrg = abs( rt-betrg ) * p_mul.
        rt-anzhl = abs( rt-anzhl ) * p_mul.
*---Wage Transmition
        LOOP AT zbyhr_t004 WHERE s_lgart EQ rt-lgart.
          w-lgart =  zbyhr_t004-t_lgart.
          w-amt   = ( rt-betrg * zbyhr_t004-amt_mul ) /
          zbyhr_t004-amt_div.
          w-num   = ( rt-anzhl * zbyhr_t004-num_mul ) /
          zbyhr_t004-num_div.
          COLLECT w.
        ENDLOOP.
      ENDLOOP.

*----
*-> "Split için, SerenK 10052012
      PERFORM  calc_right_summury_in_p-w.
      MOVE w[] TO p-w[].
      APPEND p.
      IF NOT p-w[] IS INITIAL. first = 'X'. ENDIF.
      "Add by VS on 14.07.2014
*-< "Split için, SerenK 10052012
    ENDLOOP .

  ELSE .

    LOOP AT rt WHERE lgart IN lgart.
*---All Wages positive
      rt-betrg = abs( rt-betrg ) * p_mul.
      rt-anzhl = abs( rt-anzhl ) * p_mul.
*---Wage Transmition
      LOOP AT zbyhr_t004 WHERE s_lgart EQ rt-lgart.
        w-lgart =  zbyhr_t004-t_lgart.
        w-amt   = ( rt-betrg * zbyhr_t004-amt_mul ) / zbyhr_t004-amt_div
        .
        w-num   = ( rt-anzhl * zbyhr_t004-num_mul ) / zbyhr_t004-num_div
        .
        COLLECT w.
      ENDLOOP.
    ENDLOOP.

*-> "Split için, SerenK 10052012
    PERFORM  calc_right_summury_in_p-w.
    MOVE w[] TO p-w[].
    APPEND p.
    IF NOT p-w[] IS INITIAL. first = 'X'. ENDIF.
    "Add by VS on 14.07.2014
*-< "Split için, SerenK 10052012

  ENDIF .

ENDFORM.                               " FILL_WAGES_TO_P
*&---------------------------------------------------------------------*
*&      Form  CALC_RIGHT_SUMMURY_IN_P-W
*&---------------------------------------------------------------------*
FORM calc_right_summury_in_p-w.
*-----Calculate Currency
  IF tcurr NE space.
    LOOP AT w.
      w-c_amt = ( w-amt * f-multi ) / f-divid. MODIFY w.
    ENDLOOP.
  ENDIF.
*-----Calculte Right Summury
  IF NOT lgadd[] IS INITIAL.
    LOOP AT w WHERE lgart NE '&&&&' .
      READ TABLE wts WITH KEY lgart = w-lgart.
      CHECK wts-sumsign NE space.
      IF wts-sumsign EQ '-'.
        MULTIPLY: w-amt BY -1, w-num BY -1, w-c_amt BY -1.
      ENDIF.
      MOVE '&&&&' TO w-lgart. COLLECT w.
    ENDLOOP.
  ENDIF.
  SORT w BY lgart.
*-----
ENDFORM.                               " CALC_RIGHT_SUMMURY_IN_P-W
*&---------------------------------------------------------------------*
*&      Form  GET_TXT_FROM_HRP1000
*&---------------------------------------------------------------------*
FORM get_txt_from_hrp1000  USING  otype objid.
*-----
  SELECT SINGLE stext FROM hrp1000 INTO v-ftxt
                        WHERE plvar  EQ '01'      AND
                              otype  EQ otype     AND
                              objid  EQ objid     AND
                              begda  LE sy-datum  AND
                              endda  GE sy-datum  AND
                              langu  EQ sy-langu.
ENDFORM.                               " GET_TXT_FROM_HRP1000
*&---------------------------------------------------------------------*
*&      Form  CALC_VOM_TABLE_IN_P
*&---------------------------------------------------------------------*
FORM calc_vom_table_in_p.
*------
  IF first EQ 'X'.
    MOVE space TO first.
  ELSEIF vom-fval_m NE <n_fnam_m>.
    SORT: vom-pcf,vom-w BY fpper lgart .
    APPEND vom. CLEAR : vom,vom-w[],vom-pcf[].
  ENDIF.
  vom-fval_m = <n_fnam_m>.
  LOOP AT p-w INTO w. COLLECT  w  INTO vom-w .ENDLOOP.
  IF newmod-fnam_m NE 'PERNR'. APPEND pex TO vom-pcf. ENDIF.
*------
ENDFORM.                               " CALC_VOM_TABLE_IN_P
*&---------------------------------------------------------------------*
*&      Form  CALC_VOS_TABLE_IN_P
*&---------------------------------------------------------------------*
FORM calc_vos_table_in_p.
*-----
  IF first EQ 'X'.
    MOVE space TO first.
  ELSEIF vos-fval_s NE <n_fnam_s> OR vos-fval_m NE <n_fnam_m>.
    SORT: vos-pcf,vos-w BY fpper lgart .
    APPEND vos. CLEAR : vos,vos-w[],vos-pcf[].
  ENDIF.
  vos-fval_m = <n_fnam_m>. vos-fval_s = <n_fnam_s>.
  LOOP AT p-w INTO w. COLLECT  w  INTO vos-w .ENDLOOP.
  APPEND pex TO vos-pcf.
*-----
ENDFORM.                               " CALC_VOS_TABLE_IN_P
*&---------------------------------------------------------------------*
*&      Form  CALC_VOM_TABLE_FROM_VOS
*&---------------------------------------------------------------------*
FORM calc_vom_table_from_vos.
*---
  MOVE 'X' TO first.
  LOOP AT vos.
*---Calculte VOM table
    IF first EQ 'X'.
      MOVE space TO first.
      vom-fval_m = vos-fval_m.
    ELSEIF vom-fval_m NE vos-fval_m.
      SORT: vom-pcf,vom-w BY  fpper lgart.
      APPEND vom. CLEAR : vom,vom-w[],vom-pcf[].
      vom-fval_m = vos-fval_m.
    ENDIF.
*---Calculate VOS general summury
    LOOP AT vos-w INTO w WHERE fpper NE '999912'.
      COLLECT w INTO vom-w.
      MOVE  '999912' TO w-fpper.
      COLLECT w INTO vos-w.
    ENDLOOP.

    LOOP AT vos-pcf INTO pcf.
      COLLECT : pcf-pernr  INTO vos-pc,
                pcf        INTO vom-pcf.
    ENDLOOP.
    MODIFY vos TRANSPORTING w pc.
*----
    AT LAST.
      SORT: vom-pcf,vom-w BY  fpper lgart.
      APPEND vom. CLEAR : vom,vom-w[],vom-pcf[].
    ENDAT.
  ENDLOOP.
*----
ENDFORM.                               " CALC_VOM_TABLE_FROM_VOS
*&---------------------------------------------------------------------*
*&      Form  CALC_WO
*&---------------------------------------------------------------------*
FORM calc_wo TABLES  p_w  STRUCTURE w p_wo p_pcf p_ppcf.
  CLEAR p_wo[].
*--------Calculate WO
  LOOP AT p_w INTO w WHERE fpper EQ '999912'.
    APPEND w TO p_wo.
  ENDLOOP.
  IF newmod-prmod NE 'PRSUM'.
    LOOP AT p_w INTO w WHERE fpper NE '999912'.
      CASE newmod-prmod.
        WHEN 'PR001'.
        WHEN 'PR003'. w-fpper+4(2) = ( w-fpper+4(2) + 2 ) DIV 3 * 3.
        WHEN 'PR006'. w-fpper+4(2) = ( w-fpper+4(2) + 5 ) DIV 6 * 6.
        WHEN 'PR012'. w-fpper+4(2) = '12'.
      ENDCASE.
      COLLECT w INTO p_wo.
    ENDLOOP.
  ENDIF.
  SORT p_wo .
*---------Personel Counts
  DATA opcf LIKE pcf.
  CLEAR p_ppcf[]. SORT p_pcf.
  LOOP AT p_pcf INTO pcf.
    CASE newmod-prmod.
      WHEN 'PR001'.
      WHEN 'PR003'. pcf-fpper+4(2) = ( pcf-fpper+4(2) + 2 ) DIV 3 * 3.
      WHEN 'PR006'. pcf-fpper+4(2) = ( pcf-fpper+4(2) + 5 ) DIV 6 * 6.
      WHEN 'PR012'. pcf-fpper+4(2) = '12'.
    ENDCASE.
*----
    IF pcf NE opcf.
      MOVE : pcf-fpper TO ppcf-fpper , 1   TO ppcf-count .
      COLLECT ppcf INTO p_ppcf.
    ENDIF.
    MOVE pcf TO opcf.
  ENDLOOP.
*---
ENDFORM.                               " CALC_WO
*&---------------------------------------------------------------------*
*&      Form  CALC_PERCENTAGE
*&---------------------------------------------------------------------*
FORM calc_percentage TABLES p_wo STRUCTURE w.
*---define read_wx.
  DEFINE read_wx.
    IF wx-fpper NE &1 OR wx-lgart NE &2 .
      READ TABLE wx WITH KEY fpper = &1 lgart = &2.
    ENDIF.
    CHECK:  sy-subrc EQ 0, <w_div>  GT 0.
    w-per = ( <w_mul> * 100 ) / <w_div>.
  END-OF-DEFINITION.
*----
  CLEAR wx.
  IF   newmod-nrpmd EQ 'NRROW'.
    MOVE p_wo[]    TO wx[].
  ELSE.
    MOVE vsum-wo[] TO wx[].
  ENDIF.
*-----
  IF newmod-nrpmd EQ 'NRROW'.
    LOOP AT p_wo INTO w.
      IF newmod-evirm = 'WAGES'.
        read_wx w-fpper  '&&&&'.
      ELSE.
        read_wx '999912'  w-lgart.
      ENDIF.
      MODIFY p_wo FROM w.
    ENDLOOP.
  ENDIF.
*-----
  IF newmod-nrpmd EQ 'NRCOL'.
    LOOP AT p_wo INTO w.
      IF newmod-evirm = 'WAGES'.
        read_wx '999912'  w-lgart.
      ELSE.
        read_wx w-fpper  '&&&&'.
      ENDIF.
      MODIFY p_wo FROM w.
    ENDLOOP.
  ENDIF.
*-----
  IF newmod-nrpmd EQ 'TOTAL'.
    LOOP AT p_wo INTO w.
      read_wx '999912'  '&&&&'.
      MODIFY p_wo FROM w.
    ENDLOOP.
  ENDIF.
*-----
ENDFORM.                               " CALC_PERCENTAGE
*&---------------------------------------------------------------------*
*&      Form  WRITE_VOM_VOS_VSUM_WAGES
*&---------------------------------------------------------------------*
FORM write_vom_vos_vsum_wages.
*-----
  LOOP AT vom.
    LOOP AT vos WHERE fval_m EQ vom-fval_m.
      PERFORM set_format_color_intensified.
      PERFORM header_wages USING 'VOS_H'.
      PERFORM write_w_wages TABLES vos-wo USING '999912' .
      IF newmod-prmod NE 'PRSUM'.
        LOOP AT fp WHERE prmod EQ  newmod-prmod.
          PERFORM header_wages  USING 'VOS_P'.
          PERFORM write_w_wages  TABLES vos-wo USING fp-high .
        ENDLOOP.
      ENDIF.
    ENDLOOP.
*---VOM
    PERFORM set_format_color_intensified.
    PERFORM header_wages  USING 'VOM_H'.
    PERFORM write_w_wages TABLES vom-wo USING '999912' .
    IF newmod-prmod NE 'PRSUM'.
      LOOP AT fp WHERE prmod EQ  newmod-prmod.
        PERFORM header_wages  USING 'VOM_P'.
        PERFORM write_w_wages TABLES vom-wo USING fp-high .
      ENDLOOP.
    ENDIF.
    IF newmod-fnam_s NE space.
      NEW-LINE . ULINE AT (row_len). NEW-LINE.
    ENDIF.
  ENDLOOP.
*---VSUM
  PERFORM set_format_color_intensified.
  PERFORM header_wages  USING 'VSUM_H'.
  PERFORM write_w_wages TABLES vsum-wo USING '999912' .
  IF newmod-prmod NE 'PRSUM'.
    LOOP AT fp WHERE prmod EQ  newmod-prmod.
      PERFORM header_wages  USING 'VSUM_P'.
      PERFORM write_w_wages TABLES vsum-wo USING fp-high .
    ENDLOOP.
  ENDIF.
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
*-----
ENDFORM.                               " WRITE_VOM_VOS_VSUM_WAGES
*&---------------------------------------------------------------------*
*&      Form  SET_FORMAT_COLOR_INTENSIFIED
*&---------------------------------------------------------------------*
FORM set_format_color_intensified.
  STATICS: int.
  IF int = space.
    FORMAT INTENSIFIED ON.  int = 'X'.
  ELSE.
    FORMAT INTENSIFIED OFF. int = space.
  ENDIF.
ENDFORM.                               " SET_FORMAT_COLOR_INTENSIFIED
*&---------------------------------------------------------------------*
*&      Form  HEADER_WAGES
*&---------------------------------------------------------------------*
FORM header_wages  USING  vomod.
  FORMAT COLOR COL_KEY.
*----
  IF newmod-fnam_s EQ space.
    CASE vomod.
*-----
      WHEN 'VOM_H'.
        WRITE : / '|', box AS CHECKBOX                ,
                AT (lmn) vom-fval_m NO-GAP ,'|' NO-GAP,
                AT (lmt) vom-ftxt_m NO-GAP ,'|' NO-GAP.
        IF newmod-fnam_m NE 'P-PERNR' .
          WRITE : (5) vom-count NO-GAP , '|' NO-GAP .
        ENDIF.
        HIDE vom-fval_m.
*-----
      WHEN 'VOM_P'.
        WRITE : / '|  ',  AT (lmn) space  NO-GAP ,'|' NO-GAP ,
                AT (lmt) fp-txt CENTERED  NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR'.
          READ TABLE vom-ppcf INTO ppcf WITH KEY fpper = fp-high.
          WRITE : (5) ppcf-count NO-GAP , '|' NO-GAP .
        ENDIF.
*-----
      WHEN 'VSUM_H'.
        NEW-LINE . ULINE AT (row_len). NEW-LINE.
        WRITE : / '|  ', AT (lmn) space  NO-GAP , '|' NO-GAP ,
                         AT (lmt) space  NO-GAP , '|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR'.
          WRITE : (5) vsum-count NO-GAP, '|' NO-GAP.
        ENDIF.
*-----
      WHEN 'VSUM_P'.
        WRITE : / '|  ', AT (lmn) space   NO-GAP , '|' NO-GAP ,
                 AT (lmt) fp-txt CENTERED  NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR'.
          READ TABLE vsum-ppcf INTO ppcf WITH KEY fpper = fp-high.
          WRITE : (5) ppcf-count NO-GAP , '|' NO-GAP .
        ENDIF.
    ENDCASE.
  ELSE.
*-----
    CASE vomod.
      WHEN 'VOM_H'.
        WRITE : / '|  ',AT (lmt) space      NO-GAP ,'|' NO-GAP,
                        AT (lsn) space      NO-GAP ,'|' NO-GAP ,
                        AT (lst) 'TOPLAM'   NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR' AND  newmod-fnam_s NE 'P-PERNR'.
          WRITE : (5) vom-count NO-GAP , '|' NO-GAP .
        ENDIF.
*-----
      WHEN 'VOM_P'.
        WRITE : / '|  ',  AT (lmt) space  NO-GAP ,'|' NO-GAP ,
                          AT (lsn) space  NO-GAP ,'|' NO-GAP ,
                          AT (lst) fp-txt  CENTERED NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR' AND  newmod-fnam_s NE 'P-PERNR'.
          READ TABLE vom-ppcf INTO ppcf WITH KEY fpper = fp-high.
          WRITE : (5) ppcf-count NO-GAP , '|' NO-GAP .
        ENDIF.
*-----
      WHEN 'VOS_H'.
        WRITE : / '|', box AS CHECKBOX                           ,
                       AT (lmt) vom-ftxt_m  NO-GAP   ,'|' NO-GAP ,
                       AT (lsn) vos-fval_s  NO-GAP   ,'|' NO-GAP ,
                       AT (lst) vos-ftxt_s  NO-GAP   ,'|' NO-GAP .
        IF newmod-fnam_m NE 'P-PERNR' AND newmod-fnam_s NE 'P-PERNR'.
          WRITE : (5) vos-count  NO-GAP , '|'  NO-GAP .
        ENDIF.
        IF newmod-prmod EQ 'PRSUM'. CLEAR vom-ftxt_m. ENDIF.
        HIDE: vos-fval_m,vos-fval_s.
*-----
      WHEN 'VOS_P'.
        WRITE : / '|  ', AT (lmt) space   NO-GAP ,'|' NO-GAP ,
                         AT (lsn) space   NO-GAP ,'|' NO-GAP ,
                         AT (lst) fp-txt  CENTERED NO-GAP,'|' NO-GAP.
        IF newmod-fnam_m NE 'P-PERNR' AND newmod-fnam_s NE 'P-PERNR'.
          READ TABLE vos-ppcf INTO ppcf WITH KEY fpper = fp-high.
          WRITE : (5) ppcf-count NO-GAP , '|' NO-GAP .
        ENDIF.
*------
      WHEN 'VSUM_H'.
        NEW-LINE . ULINE AT (row_len). NEW-LINE.
        WRITE : / '|  ', AT (lmt) space  NO-GAP , '|' NO-GAP ,
                         AT (lsn) space   NO-GAP , '|' NO-GAP ,
                         AT (lst) 'GENEL TOPLAM' NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_s NE 'P-PERNR'.
          WRITE : (5) vsum-count NO-GAP, '|' NO-GAP.
        ENDIF.
*-----
      WHEN 'VSUM_P'.
        WRITE : / '|  ', AT (lmt) space  NO-GAP  , '|' NO-GAP ,
                         AT (lsn) space   NO-GAP , '|' NO-GAP ,
                         AT (lst) fp-txt  CENTERED NO-GAP ,'|' NO-GAP .
        IF newmod-fnam_s NE 'P-PERNR'.
          READ TABLE vsum-ppcf INTO ppcf WITH KEY fpper = fp-high.
          WRITE : (5) ppcf-count NO-GAP , '|' NO-GAP .
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                               " HEADER_WAGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_W_WAGES
*&---------------------------------------------------------------------*
FORM write_w_wages TABLES p_w STRUCTURE w USING p_fpper .
  LOOP AT wts.
    CLEAR w.
    READ TABLE  p_w INTO w WITH KEY fpper = p_fpper lgart = wts-lgart.
    PERFORM write_w_to_screen.
  ENDLOOP.
ENDFORM.                               " WRITE_W_WAGES
*&---------------------------------------------------------------------*
*&      Form  WRITE_W_TO_SCREEN
*&---------------------------------------------------------------------*
FORM write_w_to_screen.
*-----
  IF newmod-nrpmd EQ 'SPACE'.
    IF newmod-nrmod EQ 'AMT'.
*     WRITE: (18)W-AMT CURRENCY 'TRL' NO-ZERO COLOR 2 NO-GAP,'|' NO-GAP.
      WRITE: (18)w-amt CURRENCY p_waers NO-ZERO COLOR 2 NO-GAP,'|'
      NO-GAP.
    ELSEIF newmod-nrmod EQ 'C_AMT'.
      WRITE: (18)w-c_amt CURRENCY tcurr NO-ZERO COLOR 2 NO-GAP,
                                                             '|' NO-GAP.
    ELSEIF newmod-nrmod EQ 'NUM'.
      WRITE: (18)w-num DECIMALS 1    NO-ZERO COLOR 2 NO-GAP, '|' NO-GAP.
    ENDIF.
  ELSE.
    WRITE: (18)w-per DECIMALS 4    NO-ZERO COLOR 2 NO-GAP, '|' NO-GAP.
  ENDIF.
ENDFORM.                               " WRITE_W_TO_SCREEN
*&---------------------------------------------------------------------*
*&      Form  WRITE_VOM_VOS_VSUM_PRMOD
*&---------------------------------------------------------------------*
FORM write_vom_vos_vsum_prmod.
*----
  LOOP AT vom.
    LOOP AT vos WHERE fval_m EQ vom-fval_m.
      PERFORM set_format_color_intensified.
      PERFORM header_prmod  USING 'VOS_H'.
      PERFORM write_personel_counts TABLES vos-ppcf USING vos-count.
      LOOP AT wts.
        PERFORM header_prmod  USING 'VOS_P'.
        PERFORM write_w_prmod TABLES vos-wo.
      ENDLOOP.
    ENDLOOP.
*-----VOM
    PERFORM set_format_color_intensified.
    PERFORM header_prmod  USING 'VOM_H'.
    PERFORM write_personel_counts TABLES vom-ppcf USING vom-count.
    LOOP AT wts.
      PERFORM header_prmod  USING 'VOM_P'.
      PERFORM write_w_prmod TABLES vom-wo.
    ENDLOOP.
  ENDLOOP.
*-----VSUM
  PERFORM set_format_color_intensified.
  PERFORM header_prmod  USING 'VSUM_H'.
  PERFORM write_personel_counts TABLES vsum-ppcf USING vsum-count.
  LOOP AT wts.
    PERFORM header_prmod  USING 'VSUM_P'.
    PERFORM write_w_prmod TABLES vsum-wo.
  ENDLOOP.
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
*-----
ENDFORM.                               " WRITE_VOM_VOS_VSUM_PRMOD
*&---------------------------------------------------------------------*
*&      Form  HEADER_PRMOD
*&---------------------------------------------------------------------*
FORM header_prmod USING  vomod.
  FORMAT COLOR COL_KEY.
  IF newmod-fnam_s EQ space.
    CASE vomod.
*-----
      WHEN 'VOM_H'.
        WRITE : / '|', box AS CHECKBOX                ,
                AT (lmn) vom-fval_m  NO-GAP ,'|' NO-GAP,
                AT (lmt)  vom-ftxt_m NO-GAP ,'|' NO-GAP.
        HIDE vom-fval_m.
*-----
      WHEN 'VOM_P'.
        WRITE : / '|  ',
                AT (lmn) space NO-GAP ,'|' NO-GAP,
                AT (lmt) wts-lgtxt NO-GAP ,'|' NO-GAP.
*-----
      WHEN 'VSUM_H'.
        NEW-LINE . ULINE AT (row_len). NEW-LINE.
        WRITE : / '|  ', AT (lmn) space  NO-GAP , '|' NO-GAP ,
                         AT (lmt) space  NO-GAP , '|' NO-GAP .
*-----
      WHEN 'VSUM_P'.
        WRITE : / '|  ', AT (lmn) space   NO-GAP , '|' NO-GAP ,
                         AT (lmt) wts-lgtxt NO-GAP ,'|' NO-GAP.
    ENDCASE.
  ELSE.
    CASE vomod.
*-----
      WHEN 'VOM_H'.
        WRITE : / '|  ',AT (lmt) space      NO-GAP ,'|' NO-GAP,
                        AT (lsn) space      NO-GAP ,'|' NO-GAP ,
                        AT (lst) 'TOPLAM'   NO-GAP ,'|' NO-GAP .
*-----
      WHEN 'VOM_P'.
        WRITE : / '|  ',  AT (lmt) space  NO-GAP ,'|' NO-GAP ,
                          AT (lsn) space  NO-GAP ,'|' NO-GAP ,
                     AT (lst) wts-lgtxt  CENTERED NO-GAP ,'|' NO-GAP.
*-----
      WHEN 'VOS_H'.
        WRITE : / '|', box AS CHECKBOX                           ,
                       AT (lmt) vom-ftxt_m  NO-GAP   ,'|' NO-GAP ,
                       AT (lsn) vos-fval_s  NO-GAP   ,'|' NO-GAP ,
                       AT (lst) vos-ftxt_s  NO-GAP   ,'|' NO-GAP .
        HIDE: vos-fval_m,vos-fval_s.
*-----
      WHEN 'VOS_P'.
        WRITE : / '|  ', AT (lmt) space   NO-GAP ,'|' NO-GAP ,
                         AT (lsn) space   NO-GAP ,'|' NO-GAP ,
                        AT (lst) wts-lgtxt  CENTERED NO-GAP ,'|' NO-GAP.
*-------
      WHEN 'VSUM_H'.
        NEW-LINE . ULINE AT (row_len). NEW-LINE.
        WRITE : / '|  ', AT (lmt) space  NO-GAP , '|' NO-GAP ,
                         AT (lsn) space   NO-GAP , '|' NO-GAP ,
                         AT (lst) 'GENEL TOPLAM' NO-GAP ,'|' NO-GAP .
*------
      WHEN 'VSUM_P'.
        WRITE : / '|  ', AT (lmt) space  NO-GAP  , '|' NO-GAP ,
                         AT (lsn) space   NO-GAP , '|' NO-GAP ,
                        AT (lst) wts-lgtxt  CENTERED NO-GAP ,'|' NO-GAP.
    ENDCASE.
  ENDIF.
ENDFORM.                               " HEADER_PRMOD
*&---------------------------------------------------------------------*
*&      Form  WRITE_PERSONEL_COUNTS
*&---------------------------------------------------------------------*
FORM write_personel_counts TABLES   p_ppcf STRUCTURE ppcf
                           USING    p_count LIKE vom-count.
  CLEAR ppcf.
*----
  IF newmod-prmod NE 'PRSUM'.
    LOOP AT fp WHERE prmod EQ newmod-prmod.
      IF newmod-fnam_s NE 'P-PERNR'  AND newmod-fnam_m NE 'P-PERNR'.
        CLEAR ppcf.
        READ TABLE p_ppcf INTO ppcf WITH KEY fpper = fp-high.
      ENDIF.
      WRITE : (18) ppcf-count NO-GAP NO-ZERO COLOR 2, '|' NO-GAP .
    ENDLOOP.
  ENDIF.
  IF newmod-fnam_s EQ 'P-PERNR'  OR newmod-fnam_m EQ 'P-PERNR'.
    CLEAR p_count.
  ENDIF.
  WRITE : (18) p_count NO-GAP NO-ZERO COLOR 2, '|' NO-GAP .
*---
ENDFORM.                               " WRITE_PERSONEL_COUNTS
*&---------------------------------------------------------------------*
*&      Form  WRITE_W_PRMOD
*&---------------------------------------------------------------------*
FORM write_w_prmod   TABLES p_w STRUCTURE w .
  IF newmod-prmod NE 'PRSUM'.
    LOOP AT fp WHERE prmod EQ newmod-prmod.
      CLEAR w.
      READ TABLE p_w  INTO w WITH KEY lgart = wts-lgart fpper = fp-high.
      PERFORM write_w_to_screen.
    ENDLOOP.
  ENDIF.
*-----
  CLEAR w.
  READ TABLE p_w     INTO w WITH KEY lgart = wts-lgart fpper = '999912'.
  PERFORM write_w_to_screen.
*-----
ENDFORM.                               " WRITE_W_PRMOD
*&---------------------------------------------------------------------*
*&      Form  DRAW_GRAPH_TO_SCREEN
*&---------------------------------------------------------------------*
FORM draw_graph_to_screen.
*-----
  PERFORM fill_table_vsm_for_select.
  PERFORM calc_vom_vos_vsum.
  PERFORM calc_variable_output_values.
  PERFORM calc_variable_percentages.
  PERFORM sort_variables.
*-----
  IF newmod-ucomm EQ 'GRAPX'.
    LOOP AT vom.
      CLEAR : w.
      READ TABLE vom-w INTO w WITH KEY fpper = '999912'
                                       lgart = '&&&&'.
      grp-ftxt = vom-ftxt_m+0(16).
      grp-amt  =  w-amt / 10 .
      APPEND grp.
    ENDLOOP.
  ELSE.
    LOOP AT wts.
      CLEAR w.
      READ TABLE vsum-w INTO w WITH KEY  fpper = '999912'
                                         lgart = wts-lgart.
      grp-ftxt = wts-lgtxt+0(16).
      grp-amt  =  w-amt / 10 .
      APPEND grp.
    ENDLOOP.
  ENDIF.
*---
  CALL FUNCTION 'GRAPH_3D'
    EXPORTING
*     titl       = text_1
      dim1       = 'KODU'
*     dim2       = text_2
      mail_allow = 'X'
    TABLES
      data       = grp.
  CLEAR grp[].
ENDFORM.                               " DRAW_GRAPH_TO_SCREEN
*&---------------------------------------------------------------------*
*&      Form  SET_NEWMOD_AND_OLDMOD
*&---------------------------------------------------------------------*
FORM set_newmod_and_oldmod.
*-----Read oldmod and create newmod
  DESCRIBE LIST NUMBER OF LINES lines.
  READ LINE lines.
  MOVE : oldmod TO newmod .  MOVE sy-ucomm  TO newmod-ucomm.
*-----
  CASE sy-ucomm.
    WHEN 'VAKEY'. MOVE sy-ucomm  TO newmod-ucomm.
    WHEN 'AMT' OR 'NUM' OR 'C_AMT' .
      MOVE : 'NRMOD'   TO newmod-ucomm,
             sy-ucomm TO newmod-nrmod.
    WHEN 'FULL' OR 'ALL' OR 'EMPTY'.
      MOVE : 'FEMOD'   TO newmod-ucomm,
              sy-ucomm TO newmod-femod.
    WHEN 'PRSUM' OR 'PR001' OR 'PR003' OR 'PR006' OR 'PR012' .
      MOVE : 'PRMOD'   TO newmod-ucomm,
              sy-ucomm TO newmod-prmod.
    WHEN 'EVIRM'.
      MOVE  sy-ucomm   TO newmod-ucomm.
      IF newmod-evirm EQ 'WAGES'.
        MOVE : 'PRMOD'  TO newmod-evirm,
                TEXT-103 TO evirm       .
      ELSE.
        MOVE : 'WAGES'  TO newmod-evirm,
               TEXT-104 TO evirm       .
      ENDIF.
    WHEN 'NRROW' OR 'NRCOL'OR 'TOTAL'OR 'SPACE'.
      MOVE : 'NRPMD'   TO newmod-ucomm,
              sy-ucomm TO newmod-nrpmd.
    WHEN 'SORTUP' OR 'SORTDOWN'.
      CLEAR: sortfnam,sortfval,head.
      GET CURSOR LINE lines .
      READ LINE lines.
      IF head EQ 'X'.
        GET CURSOR FIELD  sortfnam VALUE sortfval .
        MOVE sy-ucomm  TO newmod-ucomm.
      ENDIF.
    WHEN OTHERS. MOVE sy-ucomm  TO newmod-ucomm.
  ENDCASE.
*-----
ENDFORM.                               " SET_NEWMOD_AND_OLDMOD
*&---------------------------------------------------------------------*
*&      Form  CALL_BASIC_LIST
*&---------------------------------------------------------------------*
FORM call_basic_list.
  CLEAR: datatab[], header[],head.
  DATA line_value(1000) TYPE c.
  DO.
    READ LINE sy-index LINE VALUE INTO line_value.
    IF sy-subrc NE 0. EXIT. ENDIF.
    CHECK line_value+0(1) EQ '|' .
    IF head EQ 'X'.
      SPLIT line_value AT '|' INTO TABLE header. CLEAR head.
    ELSE.
      SPLIT line_value AT '|' INTO datatab-langtext1
                                   datatab-langtext1
                                   datatab-langtext2
                                   datatab-langtext3
                                   datatab-langtext4
                                   datatab-langtext5
                                   datatab-langtext6
                                   datatab-langtext7
                                   datatab-langtext8
                                   datatab-langtext9
                                   datatab-langtext10
                                   datatab-langtext11
                                   datatab-langtext12
                                   datatab-langtext13
                                   datatab-langtext14
                                   datatab-langtext15
                                   datatab-langtext16
                                   datatab-langtext17
                                   datatab-langtext18
                                   datatab-langtext19
                                   datatab-langtext20.
      SHIFT:  datatab-langtext1 LEFT,
              datatab-langtext1 LEFT.
      APPEND datatab.
    ENDIF.
  ENDDO.
  DELETE header INDEX 1.
*-----
  CALL FUNCTION 'DISPLAY_BASIC_LIST'
    EXPORTING
      basic_list_title    = sy-title
      file_name           = 'HRDATA'
      head_line1          = sy-title
      application         = 'HR'
    TABLES
      data_tab            = datatab
      fieldname_tab       = header
    EXCEPTIONS
      no_data_tab_entries = 1
      OTHERS              = 2.
  CLEAR : datatab, datatab[], header[].
ENDFORM.                               " CALL_BASIC_LIST
*&---------------------------------------------------------------------*
*&      Form  MARK_LINES
*&---------------------------------------------------------------------*
FORM mark_lines USING   mark.
  DO.
    READ LINE sy-index .
    IF sy-subrc NE 0.  EXIT.  ENDIF.
    MODIFY LINE sy-index FIELD VALUE box FROM mark.
  ENDDO.
ENDFORM.                               " MARK_LINES
*&---------------------------------------------------------------------*
*&      Form  PROCESS_VAKEY
*&---------------------------------------------------------------------*
FORM process_vakey.
  CHECK newmod-ucomm EQ 'VAKEY'. REFRESH vps.
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields                 = 2
      titel1                    = TEXT-001
      titel2                    = TEXT-002
      popuptitel                = TEXT-003
    TABLES
      fieldtabin                = vp
      selfields                 = vps
    EXCEPTIONS
      no_tab_field_input        = 1
      to_many_selfields_entries = 2
      OTHERS                    = 3.
  CHECK sy-subrc EQ 0.
  CLEAR : newmod-fnam_m, newmod-fnam_s.
  READ TABLE vps INDEX 1. CHECK  sy-subrc EQ 0.
  MOVE vps-fnam TO newmod-fnam_m.
  READ TABLE vps INDEX 2.
  IF sy-subrc EQ 0. MOVE vps-fnam TO newmod-fnam_s. ENDIF.
*----
ENDFORM.                               " PROCESS_VAKEY
*&---------------------------------------------------------------------*
*&      Form  FILL_TABLE_VSM_FOR_SELECT
*&---------------------------------------------------------------------*
FORM fill_table_vsm_for_select.
*-----Fill selected variables
  REFRESH vsm. CLEAR  box.
  DO.
    READ LINE sy-index FIELD VALUE box .
    IF sy-subrc NE 0. EXIT. ENDIF.
    CHECK box EQ 'X'. CLEAR box.
    IF oldmod-fnam_s EQ space.
      MOVE : vom-fval_m    TO vsm-fval_m.
    ELSE.
      MOVE : vos-fval_m    TO vsm-fval_m,
             vos-fval_s    TO vsm-fval_s.
    ENDIF.
    COLLECT vsm.
  ENDDO.
  SORT vsm.
*-----
ENDFORM.                               " FILL_TABLE_VSM_FOR_SELECT
*&---------------------------------------------------------------------*
*&      Form  SORT_VARIABLES
*&---------------------------------------------------------------------*
FORM sort_variables.
  CHECK newmod-ucomm EQ 'SORTUP' OR newmod-ucomm EQ 'SORTDOWN'.
  CHECK sortfnam NE space.
  IF newmod-fnam_s EQ space.
    CASE sortfnam.
      WHEN 'VP-FTXT_N'. MOVE 'FVAL_M'  TO sortfnam.
      WHEN 'VP-FTXT_T'. MOVE 'FTXT_M'  TO sortfnam.
      WHEN 'WTS-LGTXT'.
        LOOP AT wts.
          CHECK  wts-lgtxt(18) EQ sortfval+(18). EXIT.
        ENDLOOP.
        LOOP AT vom.
          CLEAR w.
          READ TABLE vom-wo INTO w WITH KEY fpper = '999912'
                                             lgart = wts-lgart.
          MOVE w-amt TO vom-betsq.
          MODIFY vom TRANSPORTING betsq.
        ENDLOOP.
        MOVE 'BETSQ'  TO sortfnam.
      WHEN OTHERS. IF sortfval EQ 'Kişi'. MOVE 'COUNT' TO sortfnam.
      ENDIF.
    ENDCASE.

    IF newmod-ucomm EQ 'SORTUP'  .SORT vom BY (sortfnam) ASCENDING.
    ENDIF.
    IF newmod-ucomm EQ 'SORTDOWN'.
      SORT vom BY (sortfnam) DESCENDING.
    ENDIF.
  ELSE.
    CASE sortfnam.
      WHEN 'VP-FTXT_N'. MOVE 'FVAL_S'  TO sortfnam.
      WHEN 'VP-FTXT_T'. MOVE 'FTXT_S'  TO sortfnam.
      WHEN 'WTS-LGTXT'.
        LOOP AT wts. CHECK  wts-lgtxt(18) EQ sortfval+(18). EXIT.ENDLOOP
        .
        LOOP AT vos.
          CLEAR w.
          READ TABLE vos-wo INTO w WITH KEY fpper = '999912'
                                             lgart = wts-lgart.
          MOVE w-amt TO vos-betsq.
          MODIFY vos TRANSPORTING betsq.
        ENDLOOP.
      WHEN OTHERS. IF sortfval EQ 'Kişi'. MOVE 'COUNT' TO sortfnam.
      ENDIF.
    ENDCASE.
    MOVE 'BETSQ'  TO sortfnam.
    IF newmod-ucomm EQ 'SORTUP'   .SORT vos BY (sortfnam) ASCENDING.
    ENDIF.
    IF newmod-ucomm EQ 'SORTDOWN'.
      SORT vos BY (sortfnam) DESCENDING.
    ENDIF.
  ENDIF.
*----
ENDFORM.                               " SORT_VARIABLES
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_WAGES
*&---------------------------------------------------------------------*
FORM top_of_page_wages.
*--
  DESCRIBE TABLE wts LINES lines.
  IF newmod-fnam_s EQ space.
    row_len = 6 + lmn + lmt + lines * 19.
  ELSE.
    row_len = 7 + lmt +  lsn + lst + lines * 19.
  ENDIF.
  IF newmod-fnam_m NE 'P-PERNR'  AND  newmod-fnam_s NE 'P-PERNR'.
    ADD 6 TO row_len.
  ENDIF.
*------
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
  FORMAT COLOR COL_HEADING.
*-----
  READ TABLE vp WITH KEY fnam = newmod-fnam_m.
  IF newmod-fnam_s EQ space.
    WRITE : '|  ', AT (lmn) vp-ftxt_n  NO-GAP ,'|' NO-GAP ,
                   AT (lmt) vp-ftxt_t  NO-GAP ,'|' NO-GAP .
    IF newmod-fnam_m NE 'P-PERNR'  AND  newmod-fnam_s NE 'P-PERNR'.
      WRITE : (5) 'Kişi' NO-GAP , '|' NO-GAP .
    ENDIF.
  ELSE.
    WRITE : / '|  ',AT (lmt) vp-ftxt_t  NO-GAP ,'|' NO-GAP.
    READ TABLE vp WITH KEY fnam = newmod-fnam_s.
    WRITE :    AT (lsn) vp-ftxt_n  NO-GAP ,'|' NO-GAP ,
               AT (lst) vp-ftxt_t  NO-GAP ,'|' NO-GAP .
    IF newmod-fnam_m NE 'P-PERNR' AND  newmod-fnam_s NE 'P-PERNR'.
      WRITE : (5) 'Kişi' NO-GAP , '|' NO-GAP .
    ENDIF.
  ENDIF.
  MOVE 'X' TO head. HIDE head.
  SET LEFT SCROLL-BOUNDARY.
  LOOP AT wts. WRITE: (18) wts-lgtxt  NO-GAP,'|' NO-GAP.ENDLOOP.
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
*-----
ENDFORM.                               " TOP_OF_PAGE_WAGES
*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE_PRMOD
*&---------------------------------------------------------------------*
FORM top_of_page_prmod.
  lines = 1.
  LOOP AT fp WHERE prmod EQ newmod-prmod.
    ADD 1 TO lines.
  ENDLOOP.
  IF newmod-fnam_s EQ space.
    row_len = 6 + lmn + lmt + lines * 19.
  ELSE.
    row_len = 7 + lmt +  lsn + lst + lines * 19.
  ENDIF.
*------
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
  FORMAT COLOR COL_HEADING.
*-----
  READ TABLE vp WITH KEY fnam = newmod-fnam_m.
  IF newmod-fnam_s EQ space.
    WRITE : '|  ', AT (lmn) vp-ftxt_n  NO-GAP ,'|' NO-GAP ,
                   AT (lmt) vp-ftxt_t  NO-GAP ,'|' NO-GAP .
  ELSE.
    WRITE : / '|  ',AT (lmt) vp-ftxt_t  NO-GAP ,'|' NO-GAP.
    READ TABLE vp WITH KEY fnam = newmod-fnam_s.
    WRITE :    AT (lsn) vp-ftxt_n  NO-GAP ,'|' NO-GAP ,
               AT (lst) vp-ftxt_t  NO-GAP ,'|' NO-GAP .
  ENDIF.
  MOVE 'X' TO head. HIDE head.
  SET LEFT SCROLL-BOUNDARY.
  LOOP AT fp WHERE prmod EQ newmod-prmod.
    WRITE: (18) fp-txt  NO-GAP,'|' NO-GAP.
  ENDLOOP.
  WRITE: (18) 'TOPLAM'  NO-GAP,'|' NO-GAP.
  NEW-LINE . ULINE AT (row_len). NEW-LINE.
*------
ENDFORM.                               " TOP_OF_PAGE_PRMOD
*&---------------------------------------------------------------------*
*&      Form  CHECK_KOSTL_HIYERARSI
*&---------------------------------------------------------------------*
FORM check_kostl_hiyerarsi.
*----
  CHECK setname NE space.
  TABLES : setheader, setnode ,setleaf.
*----
  SELECT kokrs FROM tka02 INTO subclass WHERE bukrs IN a_bukrs.
    SELECT SINGLE subclass FROM setheader  INTO subclass
                                  WHERE  setname EQ setname  AND
                                         settype  EQ 'S'     AND
                                         setclass EQ '0101'  AND
                                         subclass EQ subclass.
    IF sy-subrc EQ 0. EXIT. ENDIF.
  ENDSELECT.
*----
  MOVE : 'I'     TO   pnpkostl-sign,
         'EQ'    TO   pnpkostl-option.
  SELECT SINGLE * FROM setheader WHERE settype  EQ 'S'     AND
                                       setclass EQ '0101'  AND
                                       setname  EQ setname AND
                                       subclass EQ subclass.
  CHECK sy-subrc EQ 0.
  SELECT * FROM setnode WHERE
                        setclass EQ setheader-setclass AND
                        subclass EQ setheader-subclass AND
                        setname  EQ setheader-setname.
    SELECT * FROM setleaf WHERE
                          setclass EQ setnode-setclass    AND
                          subclass EQ setnode-subclass    AND
                          setname  EQ setnode-subsetname.
      CLEAR setna.
      MOVE : setnode-subsetname TO setna-setname,
             setleaf-valfrom    TO setna-kostl     ,
             setleaf-valfrom    TO pnpkostl-low    .
      APPEND : setna,pnpkostl.
    ENDSELECT.
  ENDSELECT.
*----
ENDFORM.                    "CHECK_KOSTL_HIYERARSI
*&---------------------------------------------------------------------*
*&      Form  GET_SETNAME_VALUE
*&---------------------------------------------------------------------*
FORM get_setname_value.
*-----
  DATA setnas LIKE setna OCCURS 0 WITH HEADER LINE.

  SELECT kokrs FROM tka02 INTO subclass WHERE bukrs IN a_bukrs.
    SELECT setname FROM setheader APPENDING TABLE setna
                                  WHERE settype  EQ 'S'     AND
                                         setclass EQ '0101'  AND
                                         subclass EQ subclass.
  ENDSELECT.
  CHECK NOT setna[] IS INITIAL.
  CALL FUNCTION 'HR_FIELD_CHOICE'
    EXPORTING
      maxfields  = 1
      titel1     = 'Masraf Yeri Grubları'
    TABLES
      fieldtabin = setna
      selfields  = setnas.
*-----
  READ TABLE setnas INDEX 1. CHECK sy-subrc EQ 0.
  MOVE setnas-setname TO setname.
*  select kokrs from tka02 into subclass where bukrs in a_bukrs.
*    select single subclass from setheader  into subclass
*                                  where  setname eq setname  and
*                                         settype  eq 'S'     and
*                                         setclass eq '0101'  and
*                                         subclass eq subclass.
*    if sy-subrc eq 0. exit. endif.
*  endselect.
  REFRESH setna.
*----
ENDFORM.                               " GET_SETNAME_VALUE
*&---------------------------------------------------------------------*
*&      Form  set_default_cunrrency
*&---------------------------------------------------------------------*
FORM set_default_cunrrency.

  CALL FUNCTION 'RP_GET_CURRENCY'
    EXPORTING
      molga = '47'
      begda = sy-datum
      endda = sy-datum
    IMPORTING
      waers = p_waers.

ENDFORM.                    " set_default_cunrrency
*&---------------------------------------------------------------------*
*&      Form  convert_currency_payroll
*&---------------------------------------------------------------------*
FORM convert_currency_payroll  USING  p_frgn
                                      p_local .
  CHECK p_frgn NE p_local.
*-------------
  CALL FUNCTION 'HR_CONVERT_CURRENCY_RESULT'
    EXPORTING
      country_grouping       = '47'
      conversion_date        = sy-datum
      foreign_currency       = p_frgn
      local_currency         = p_local
    TABLES
      result_table           = rt
      cumulated_result_table = crt.
*-------------
ENDFORM.                    " convert_currency_payroll
*&---------------------------------------------------------------------*
*&      Form  control_currency
*&---------------------------------------------------------------------*
FORM control_currency.
  IF p_waers NE 'YTL' AND p_waers NE 'TRL'
AND p_waers NE 'TRY'.
    MESSAGE ID 'YDHR_PA' TYPE 'E' NUMBER '000'.
  ENDIF.
ENDFORM.                    " control_currency
