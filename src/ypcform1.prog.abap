*----------------------------------------------------------------------*
*   INCLUDE YPCFORM1                                            *
*----------------------------------------------------------------------*
TABLES: t549a, t549r, t549w, t549u, t549z, t54c2, t500l, t549q.
*
* ========== Form Gesamt_P0008 =======================================
*    Gesamtbetrag der Basisbezüge ermitteln.
* ====================================================================
FORM gesamt_p0008 USING totalbetrag value(persnr)
                          value(startdat) value(enddat).

  rp-read-infotype persnr 0008 p0008 startdat enddat.
  IF sy-subrc <> 0.
    CLEAR totalbetrag.
    EXIT.
  ENDIF.
  rp-read-infotype persnr 0001 p0001 startdat enddat.


  DATA: gesamtbetrag LIKE pbwla-betrg.

  CLEAR gesamtbetrag.

*    do 20 times
*      varying work_pay from p0008-lga01 next p0008-lga02
*      varying char     from p0008-ind01 next p0008-ind02.
*      if work_pay-lgart cn ' 0'.
*         clear pay_tab.
*         move-corresponding work_pay to pay_tab.
*         move char to pay_tab-indbw.
*         if char eq  'I'.
*            move true to indbw_flag.
*         endif.
*         append pay_tab.
*      else.
*        exit.
*      endif.
*    enddo.
*
  CALL FUNCTION 'RP_FILL_WAGE_TYPE_TABLE'
       EXPORTING
            appli                        = 'E'
            begda                        = startdat
            endda                        = enddat
            infty                        = p0008-infty
            objps                        = p0008-objps
            pernr                        = persnr
            subty                        = p0008-subty
       TABLES
            pp0001                       = p0001
            pp0008                       = p0008  "input
            ppbwla                       = ppbwla  "output
       EXCEPTIONS
            error_at_indirect_evaluation = 1.

  IF sy-subrc <>  0.
    EXIT.
  ELSE.
    LOOP AT ppbwla.
*           case p0008-infty.
*            when '0011'.
*              ppbwla-waers = p0011-waers.               "HC 01.10.1998
*              modify ppbwla.
*            when '0014'.
*              ppbwla-waers = p0014-waers.               "HC 01.10.1998
*              modify ppbwla.
*            when '0015'.
*              ppbwla-waers = p0015-waers.               "HC 01.10.1998
*              modify ppbwla.
*            when '0057'.
*              ppbwla-waers = p0057-waers.               "HC 01.10.1998
*              modify ppbwla.
*           endcase.
      IF ppbwla-waers NE calc_currency.           "HC - 02.11.1998
        PERFORM convert_to_local_currency USING
                                ppbwla-betrg enddat ppbwla-waers
                                calc_currency ppbwla-betrg.
      ENDIF.
      IF ppbwla-opken <> 'A'.
        ADD ppbwla-betrg TO gesamtbetrag.
        MODIFY ppbwla.
      ELSE.
        SUBTRACT ppbwla-betrg FROM gesamtbetrag.
        ppbwla-betrg = ppbwla-betrg * ( -1 ).
        MODIFY ppbwla.
      ENDIF.
    ENDLOOP.
  ENDIF.

  MOVE gesamtbetrag TO totalbetrag.
ENDFORM.
* ====================================================================

* lesen wiederkehrende be/abzuege.
FORM gesamt_p0014 USING value(persnr) permo
                        value(startdat) value(enddat).
  DATA: h_paper(6) TYPE n.
  DATA: returncode LIKE sy-subrc.
  DATA: message_text(80) TYPE c.

  DATA: BEGIN OF idates OCCURS 1,
          begda TYPE d,
          endda TYPE d,
          date  TYPE d,
        END OF idates.

  h_paper = startdat(6).
* PROVIDE * FROM P0014 BETWEEN PN/BEGDA AND PN/ENDDA.
  LOOP AT p0014 WHERE endda GE startdat  "pn/begda
                AND   begda LE enddat.   "pn/endda.
    CHECK NOT h_paper IS INITIAL
          OR ( p0014-model IS INITIAL AND  " => no modell
               p0014-zdate IS INITIAL AND
               p0014-zanzl IS INITIAL AND
               p0014-zeinz IS INITIAL AND
               p0014-zfper IS INITIAL ).

    CALL FUNCTION 'RP_CHECK_PAY_PERIOD'
      EXPORTING
        abkrs = pernr-abkrs
        abrpr = h_paper
        zanzl = p0014-zanzl
        zdate = p0014-zdate
        zeitx = p0014-zeinz
        zfper = p0014-zfper
        model = p0014-model
      IMPORTING
        rcode = returncode
      TABLES
        tabelle = idates
      EXCEPTIONS
*       no_model_found = 1.
        no_model_found = 1
        no_table_entry = 2.
    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
      WHEN 2.
    ENDCASE.
    CHECK returncode EQ 0.

    IF p0014-indbw EQ 'I'.
      PERFORM call_function_indev
                            USING p0014-infty p0014-subty p0014-objps
                            startdat startdat p0014-seqnr.

      MOVE-CORRESPONDING ppbwla TO la.
      la-pernr = pernr-pernr.
    ELSE.
      MOVE-CORRESPONDING p0014 TO la.
    ENDIF.
    IF NOT p0014-model IS INITIAL.
      PERFORM split_model_amount USING p0014-model
                                       pernr-abkrs permo
                                       p0014-betrg.
    ENDIF.
    APPEND la.
  ENDLOOP.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM GESAMT_P0015                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(PERSNR)                                                 *
*  -->  VALUE(STARTDAT)                                               *
*  -->  VALUE(ENDDAT)                                                 *
*---------------------------------------------------------------------*
FORM gesamt_p0015 USING value(persnr)
                        value(startdat) value(enddat).
* PROVIDE * FROM P0015 BETWEEN PN/BEGDA AND PN/ENDDA.
  LOOP AT p0015 WHERE endda GE startdat
                AND   begda LE enddat.
    IF p0015-indbw EQ 'I'.
      PERFORM call_function_indev
                            USING p0015-infty p0015-subty p0015-objps
                            startdat startdat p0015-seqnr.
      MOVE-CORRESPONDING ppbwla TO la.
      la-pernr = pernr-pernr.
    ELSE.
      MOVE-CORRESPONDING p0015 TO la.
    ENDIF.
    APPEND la.
  ENDLOOP.
ENDFORM. "END OF FUP0015.


*---------------------------------------------------------------------*
*       FORM CALL_FUNCTION_INDEV                                      *
*---------------------------------------------------------------------*
*       input:  PINFTY, PSUBTY, POBJPS identifies record to be        *
*               evaluated                                             *
*       output: PPBWLA table with all evaluated wage types of the     *
*               corresponding record, converted to CALC_WAERS, if nec.*
*---------------------------------------------------------------------*
*FORM CALL_FUNCTION_INDEV USING PINFTY PSUBTY POBJPS PBEGDA PENDDA. "XPS
FORM call_function_indev USING
                         pinfty psubty pobjps pbegda pendda seqnr.
  REFRESH ppbwla.
  CALL FUNCTION 'RP_FILL_WAGE_TYPE_TABLE_EXT'
       EXPORTING
            appli                        = 'P'
            pernr                        = pernr-pernr
            infty                        = pinfty
            subty                        = psubty
            objps                        = pobjps
*           WAERS                        = SY-WAERS
            begda                        = pbegda
            endda                        = pendda
            seqnr                        = seqnr
       TABLES
            pp0001                       = p0001    "input
            pp0007                       = p0007    "input
            pp0008                       = p0008    "input
            ppbwla                       = ppbwla   "output
**            pp0230                       = p0230    "input
       EXCEPTIONS
            error_at_indirect_evaluation = 1.
  CASE sy-subrc.
    WHEN 0.                          "all o.k.
    WHEN 1.
  ENDCASE.
  LOOP AT ppbwla.
    IF ppbwla-waers NE calc_currency.
      PERFORM convert_to_local_currency USING pbegda
              ppbwla-betrg ppbwla-waers calc_currency ppbwla-betrg.
**      if fc-sw_dec = 'X'. "hourly rate
**        if ppbwla-waers(3) ne calc_currency.
**          ppbwla-waers = calc_currency.
**          modify ppbwla.
**        endif.
**      else.
**          ppbwla-waers = calc_currency.
**          modify ppbwla.
**      endif.
      ppbwla-waers = calc_currency.
      MODIFY ppbwla.
    ENDIF.
  ENDLOOP.
ENDFORM.  "CALL_FUNCTION_INDEV



*---------------------------------------------------------------------*
*       FORM CONVERT_TO_LOCAL_CURRENCY                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  AMOUNT                                                        *
*  -->  DATE                                                          *
*  -->  FOREIGN_CURRENCY                                              *
*  -->  LOCAL_CURRENCY                                                *
*  -->  RESULT                                                        *
*---------------------------------------------------------------------*
FORM convert_to_local_currency USING amount date
                               foreign_currency local_currency result.
  DATA: foreign_currency1 LIKE tcurr-fcurr.
  DATA: local_currency1 LIKE tcurr-fcurr.

**if fc-sw_dec = 'X'.
**  local_currency1 = local_currency.
**  foreign_currency1 = foreign_currency .
**  if foreign_currency1(3) eq local_currency1(3).
**    foreign_currency = local_currency.
**  endif.
**endif.    "sw_dec

  CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
       EXPORTING
            date             = date
            foreign_amount   = amount
            foreign_currency = foreign_currency
            local_currency   = local_currency
       IMPORTING
            local_amount     = result
       EXCEPTIONS
            no_rate_found    = 01
            overflow         = 02.
**if fc-sw_dec = 'X'.
**  foreign_currency = foreign_currency1 .
**endif.
ENDFORM.                               "CONVERT_TO_LOCAL_CURRENCY



*---------------------------------------------------------------------*
*       FORM CONVERT_TO_FOREIGN_CURRENCY                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  AMOUNT                                                        *
*  -->  DATE                                                          *
*  -->  LOCAL_CURRENCY                                                *
*  -->  FOREIGN_CURRENCY                                              *
*  -->  RESULT                                                        *
*---------------------------------------------------------------------*
FORM convert_to_foreign_currency USING amount date
                  local_currency foreign_currency result.
  CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
       EXPORTING
            date             = date
            foreign_currency = foreign_currency
            local_amount     = amount
            local_currency   = local_currency
       IMPORTING
            foreign_amount   = result
       EXCEPTIONS
            no_rate_found    = 01
            overflow         = 02.
ENDFORM.                               "CONVERT_TO_FOREIGN_CURRENCY


*---------------------------------------------------------------------*
*       FORM SPLIT_MODEL_AMOUNT                                       *
*---------------------------------------------------------------------*
* Divide amount according to payperiod frequencies.                   *
*---------------------------------------------------------------------*
*       $MODEL  -- Input-Parameter                                    *
*                  Payroll Frequency Model                            *
*       $ABKRS  -- Input-Parameter                                    *
*                  Payroll Subunit                                    *
*       $PERMO  -- Input-Parameter                                    *
*                  Period Modifier                                    *
*       $BETRG  -- Input-/Output-Parameter                            *
*                  Amount                                             *
*---------------------------------------------------------------------*
FORM split_model_amount USING $model $abkrs $permo $betrg.  "QXOK146729
  DATA: unit_pabrj      LIKE t549u-pabrj,   "year
        unit_pabrp      LIKE t549u-pabrp.   "key of unit

* get details on payroll subunit
  PERFORM re549a USING $abkrs.

* get details on payperiod frequency
  PERFORM re549w USING $model.

* compare period modifier of employee with the one the model has
* been established for - they have to match in order to avoid
* any trouble, that might occur
  IF t549w-datmo <> t549a-datmo OR     "incorrect date modifier?
     t549w-permo <> $permo.            "incorrect period modifier?
    WRITE: / text-f00, $model, t549a-datmo, t549w-datmo,
             $permo, t549w-permo.
    EXIT.                 "abort processing
  ENDIF.

* get details on internal modifiers
  PERFORM re549r USING $permo.

* get details on internal calendar modifier
  PERFORM re54c2 USING t549w-pperm.

* further processing has to be done only in case there is a
* difference in PERMO
  CHECK: t549r-zeinh <> t54c2-zeinh.   "difference found?

* dividing of amount has to be done - according to payperiods per
* unit (T549W-PPERM)
  PERFORM re549z USING t549w-datmo $permo h_anfda(4)
                       h_anfda+4(2) t549w-pperm.
* get number of pay-periods per unit
  PERFORM re549u USING $model t549z-dedyr t549z-dedno.

* divide amount according to number of payperiods available
  $betrg = $betrg / t549u-anzhl.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM RE500L                                                   *
*---------------------------------------------------------------------*
FORM re500l USING molga.                                 "VUUK11K139330
  CHECK t500l-molga NE molga.                                        "!
  SELECT SINGLE * FROM t500l WHERE molga EQ molga.                   "!
  CHECK sy-subrc NE 0.                                               "!
ENDFORM.                               "RE500L           "VUUK11K139330

*---------------------------------------------------------------------*
*       FORM RE549W                                                   *
*---------------------------------------------------------------------*
* Read Table 549W - Payroll Frequency Model.                          *
*---------------------------------------------------------------------*
*       $MODEL  -- Input-Parameter                                    *
*                  Payroll Frequency Model                            *
*---------------------------------------------------------------------*
FORM re549w USING $model.              "                      QXOK146729

* any changes since the last time accessing this table
  CHECK: t549w-model <> $model.

  SELECT SINGLE * FROM t549w
         WHERE model = $model.         "Model?

  CHECK: sy-subrc <> 0.                "no entry found?
ENDFORM.

*---------------------------------------------------------------------*
*       FORM RE549U                                                   *
*---------------------------------------------------------------------*
* Read Table 549U - Number of Payperiods per Unit.                    *
*---------------------------------------------------------------------*
*       $MODEL  -- Input-Parameter                                    *
*                  Payroll Frequency Model                            *
*       $PABRJ  -- Input-Parameter                                    *
*                  Year                                               *
*       $PABRP  -- Input-Parameter                                    *
*                  Unit (Month, Quarter, Semi-Anually, Anually)       *
*---------------------------------------------------------------------*
FORM re549u USING $model $pabrj $pabrp."                      QXOK146729

* any changes since the last time accessing this table
  CHECK: t549u-model <> $model OR
         t549u-pabrj <> $pabrj OR
         t549u-pabrp <> $pabrp.

  SELECT SINGLE * FROM t549u
         WHERE model = $model          "Model?
         AND   pabrj = $pabrj          "Year?
         AND   pabrp = $pabrp.         "Unit?

  CHECK: sy-subrc <> 0.                "no entry found?
ENDFORM.

*---------------------------------------------------------------------*
*       FORM RE549Z                                                   *
*---------------------------------------------------------------------*
* Read Table 549Z - Calendar for Deductions/General Purpose.          *
*---------------------------------------------------------------------*
*       $DATMO  -- Input-Parameter                                    *
*                  Date modifier                                      *
*       $PERMO  -- Input-Parameter                                    *
*                  Period modifier                                    *
*       $PABRJ  -- Input-Parameter                                    *
*                  Year                                               *
*       $PABRP  -- Input-Parameter                                    *
*                  Period                                             *
*       $PPERM  -- Input-Parameter                                    *
*                  Calendar Type                                      *
*---------------------------------------------------------------------*
FORM re549z USING $datmo $permo $pabrj $pabrp $pperm.       "QXOK146729

* any changes since the last time accessing this table
  CHECK: t549z-datmo <> $datmo OR
         t549z-permo <> $permo OR
         t549z-pabrj <> $pabrj OR
         t549z-pabrp <> $pabrp OR
         t549z-pperm <> $pperm.

  SELECT SINGLE * FROM t549z
         WHERE datmo = $datmo          "date modifier?
         AND   permo = $permo          "period modifier?
         AND   pabrj = $pabrj          "year?
         AND   pabrp = $pabrp          "period?
         AND   pperm = $pperm.         "calendar modifier?

  CHECK: sy-subrc <> 0.                "no entry found?
ENDFORM.

*---------------------------------------------------------------------*
*       FORM RE549A                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  VALUE(RE549A-ABKRS)                                           *
*---------------------------------------------------------------------*
FORM re549a USING value(re549a-abkrs).                      "QNUK60880
  CHECK t549a-abkrs NE re549a-abkrs.
  SELECT SINGLE * FROM t549a WHERE abkrs EQ re549a-abkrs.
  IF sy-subrc NE 0.
  ENDIF.
ENDFORM.                                                    "RE549A

*ORM RE549Q USING VALUE(RE549Q-ABKRS) VALUE(RE549Q-PABRJ)    "QNUK60880
FORM re549q USING value(re549q-permo) value(re549q-pabrj)   "QNUK60880
                  value(re549q-pabrp).
* CHECK T549Q-ABKRS NE RE549Q-ABKRS OR                       "QNUK60880
  CHECK t549q-permo NE re549q-permo OR                      "QNUK60880
        t549q-pabrj NE re549q-pabrj OR
        t549q-pabrp NE re549q-pabrp.
                                                            "QNUK60880
* SELECT SINGLE * FROM T549Q WHERE ABKRS EQ RE549Q-ABKRS     "QNUK60880
  SELECT SINGLE * FROM t549q WHERE permo EQ re549q-permo    "QNUK60880
                             AND   pabrj EQ re549q-pabrj
                             AND   pabrp EQ re549q-pabrp.
  IF sy-subrc <> 0.                "no entry found?
  ENDIF.
ENDFORM.                                                    "RE549Q

*---------------------------------------------------------------------*
*       FORM RE549R                                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  RE549R-PERMO                                                  *
*---------------------------------------------------------------------*
FORM re549r USING re549r-permo.                             "YUIK73527
  CHECK t549r-permo NE re549r-permo.
  SELECT SINGLE * FROM t549r WHERE permo EQ re549r-permo.
  IF sy-subrc <> 0.                "no entry found?
  ENDIF.
ENDFORM.                                                    "RE549R

*---------------------------------------------------------------------*
*       FORM RE54C2                                                   *
*---------------------------------------------------------------------*
* Read Table 54C2 - Assignment to internal Calendar Types.            *
*---------------------------------------------------------------------*
*       $CUMTY  -- Input-Parameter                                    *
*                  Calendar Type                                      *
*---------------------------------------------------------------------*
FORM re54c2 USING $cumty.                                   "QXOK146729

* any changes since the last time accessing this table
  CHECK: t54c2-cumty <> $cumty.

  SELECT SINGLE * FROM t54c2
         WHERE cumty = $cumty.         "calendar modifier?

  CHECK: sy-subrc <> 0.                "no entry found?
ENDFORM.

*
