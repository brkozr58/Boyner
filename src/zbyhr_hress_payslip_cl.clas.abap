class ZBYHR_HRESS_PAYSLIP_CL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_HRESS_PAYSLIP_BADI .

  data MV_GROUPING type PCCE_GPVAL .

  methods CONSTRUCTOR .
protected section.

  types:
*"* protected components of class CL_HRESS_PAYSLIP_BADI_STANDARD
*"* do not include other source files here!!!
    begin of ts_overview,
      seqnr    type pc261-seqnr, "internal
      ipend    type pc261-ipend, "In-Period end date
      inperiod TYPE char08, "In-Period '01/2009'
      paydt    type pc261-paydt, "Payment date
      bondt    type pc261-bondt, "Bonus date
      run_type TYPE xss_ser_string, "paytype
      betrg_1  type xss_ser_string, "gross amount
      betrg_2  TYPE xss_ser_string, "payment amount
      prt_status TYPE xss_ser_string,
      paydt_ui5(30) TYPE c,"Date for UI5 in format 01.JAN.2012
      payslip_title_ui5 TYPE xss_ser_string," Titile for Single Payslip in UI5
      deductions TYPE xss_ser_string, " Deductions betrg_1 - betrg_2
      is_deduction_visible TYPE boole_d,
      btn_dwnld_pdf(30) type c,
    end of ts_overview .
  types:
    tt_overview type standard table of ts_overview .

  data MO_PAY_ACCESS type ref to CL_HR_PAY_ACCESS .
  data MV_PRINT_BUTTON_ENABLED type ABAP_BOOL value ABAP_TRUE ##NO_TEXT.

  methods MAP_SY_TO_BAPIRET
    returning
      value(RS_MESSAGE) type BAPIRET2 .
  methods IS_OFFCYCLE
    importing
      !IV_MOLGA type MOLGA
    returning
      value(RT_OFFCYCLE) type BOOLE_D .
private section.
ENDCLASS.



CLASS ZBYHR_HRESS_PAYSLIP_CL IMPLEMENTATION.


method CONSTRUCTOR.

  create OBJECT mo_pay_access.

endmethod.


method if_hress_payslip_badi~adjust_field_catalog.

  data ls_field_usage type fpmgb_s_fieldusage.
  data lt_field_names type standard table of fpmgb_s_fieldusage-name.

* decision based on off-cycle
  if me->is_offcycle( iv_molga ) eq abap_true. "off-cycle country
*   display PayDate
*   disable InPeriod string
    append 'INPERIOD' to lt_field_names.
*   disable InPeriod End Date
    append 'IPEND'    to lt_field_names.
  else. "only standard periods
*    if payroll is monthly then
*      display InPeriod string
*   disable InPeriod End Date
    append 'IPEND'    to lt_field_names.
*    else.
**     display InPeriod End Date
**     disable InPeriod string
*      APPEND 'INPERIOD' TO lt_field_names.
*    endif.
*   disable Payment Date
    append 'PAYDT' to lt_field_names.
*   disable Payroll Run Type
    append 'RUN_TYPE' to lt_field_names.
*   disable Bonus Date
    append 'BONDT' to lt_field_names.
  endif.
* in case button 'Print_Request' is disabled no status field needed!
  if mv_print_button_enabled eq abap_false.
    append 'PRT_STATUS' to lt_field_names.
  endif.

  loop at lt_field_names into ls_field_usage-name.
    ls_field_usage-enabled = abap_false.
    ls_field_usage-visibility = cl_wd_uielement=>e_visible-none.
    modify ct_field_usage from ls_field_usage transporting enabled visibility
      where name eq ls_field_usage-name.
  endloop.

endmethod.


method IF_HRESS_PAYSLIP_BADI~ADJUST_PRINTBUTTON_STATUS.

* see method 'ADJUST_FIELD_CATALOG'
  mv_print_button_enabled = abap_true.
* precondition:
* button must be visible via configuration
* and action_id 'HRGRT_REQUEST_PTRINT' must be used for
* if precondition above is not valid this method has no functionality
* and setting will be ignored.
  ev_enabled = mv_print_button_enabled.

endmethod.


method IF_HRESS_PAYSLIP_BADI~PROVIDE_FIELD_CATALOG.

  data:
    lo_structdescr           type ref to    cl_abap_structdescr,
    lt_overview              type           tt_overview.
  field-symbols:
    <ls_component>           type           abap_compdescr,
    <ls_field_descr>         type line of   fpmgb_t_listfield_descr.


  eo_field_catalog ?= cl_abap_tabledescr=>describe_by_data( p_data = lt_overview ).
  lo_structdescr   ?= eo_field_catalog->get_table_line_type( ).
  clear et_field_description.

  loop at lo_structdescr->components assigning <ls_component>.
    append initial line to et_field_description assigning <ls_field_descr>.
    move-corresponding <ls_component> to <ls_field_descr>.
    <ls_field_descr>-visibility           = cl_wd_uielement=>e_visible-visible.
    <ls_field_descr>-read_only            = abap_true.
    <ls_field_descr>-header_text_wrapping = abap_true.
    <ls_field_descr>-allow_sort           = abap_false. "should not be changed!
    <ls_field_descr>-allow_filter         = abap_false. "should not be changed!
    case <ls_field_descr>-name.
      when 'BETRG_1'.
        <ls_field_descr>-header_label    = 'Gross Amount'(D01).
        <ls_field_descr>-text            = 'Gross Amount'(D01).
      when 'BETRG_2'.
        <ls_field_descr>-header_label    = 'Payment Amount'(D02).
        <ls_field_descr>-text            = 'Payment Amount'(D02).
      when 'PRT_STATUS'.
        <ls_field_descr>-header_label    = 'Print Status'(D03).
        <ls_field_descr>-text            = 'Print Status'(D03).
      when 'INPERIOD'.
        <ls_field_descr>-header_label    = 'In-Period'(D04).
        <ls_field_descr>-text            = 'In-Period'(D04).
      when 'RUN_TYPE'.
        <ls_field_descr>-header_label    = 'Payroll run type'(D05).
        <ls_field_descr>-text            = 'Payroll run type'(D05).
      when 'BTN_DWNLD_PDF'.
*        <ls_field_descr>-name            = 'DOWNLOAD_PDF'.
        <ls_field_descr>-header_label    = 'Download'(D06).
        <ls_field_descr>-text            = 'Download'(D06).
      when others.
        "use header from ddic
    endcase.
  endloop.

* disable technical field from viewing
  read table et_field_description assigning <ls_field_descr> with key name = 'SEQNR'.
  if sy-subrc eq 0.
    <ls_field_descr>-visibility = cl_wd_uielement=>e_visible-none.
    <ls_field_descr>-technical_field = abap_true.
  endif.

endmethod.


  METHOD if_hress_payslip_badi~provide_filtered_rgdir.
    DATA gt_table TYPE TABLE OF ZBYHR_T009.
    DATA gs_table TYPE          ZBYHR_T009.
    DATA gs_rgdir LIKE LINE OF ct_filtered_rgdir.

    SELECT * FROM ZBYHR_T009 INTO TABLE gt_table.

    LOOP AT ct_filtered_rgdir INTO gs_rgdir.
      READ TABLE gt_table INTO gs_table
            WITH KEY abkrs = gs_rgdir-abkrs
                     donem = gs_rgdir-fpper .
      IF sy-subrc EQ 0 .
        IF gs_table-tarih > sy-datum.
          DELETE TABLE ct_filtered_rgdir FROM gs_rgdir.
        ENDIF.
      ELSE.
        DELETE TABLE ct_filtered_rgdir FROM gs_rgdir.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


method if_hress_payslip_badi~provide_filter_list.

  data ls_value_set_ext type hrxss_rem_value_set_ext.
  data lv_date type datum.
  data lv_start_date type datum.
  data ls_rgdir type pc261.
  data lv_index type sytabix.
  DATA lv_ui5_active TYPE abap_bool.

  IF cl_hress_ui5_switch_check_01=>hress_sfws_ui5_ui_01( ) eq abap_true.
    lv_ui5_active = abap_true.
  ENDIF.
* table IT_FILTERED_RGDIR is sorted by PAYDT/IPEND SEQNR (descending)
* see method Provide_Filtered_RGDIR

* content of VSKEY could be any kind of value (must be unique)
* content of VSVALUE contains description (displayed on front-end)
* content of SEQNR defines last entry from table IT_FILTERED_RGDIR shwon in overview
* display order is defined by order of APPENDs (Top->Down)

* relative start_date
*  read table it_filtered_rgdir into ls_rgdir index 1.
*  if me->is_offcycle( iv_molga = iv_molga ) eq abap_true.
*    lv_start_date = ls_rgdir-paydt.
*  else.
*    lv_start_date = ls_rgdir-ipend.
*  endif.
* or absolute start_date
  lv_start_date = sy-datum.
  IF lv_ui5_active eq abap_false.
* get lowest SEQNR (= complete table IT_FILTERED_RGDIR)
  ls_value_set_ext-vskey = 'ALL'.
  ls_value_set_ext-vsvalue = 'All Available'(f01).
  read table it_filtered_rgdir into ls_rgdir index lines( it_filtered_rgdir ).
  ls_value_set_ext-seqnr = ls_rgdir-seqnr. "set last entry
  append ls_value_set_ext to et_value_set_ext.
  ENDIF.
* "last 3 months" - get lowest SEQNR for this period
  clear ls_value_set_ext.
  call function 'RP_CALC_DATE_IN_INTERVAL'
    exporting
      date      = lv_start_date
      days      = 0
      months    = 3
      signum    = '-'
      years     = 0
    importing
      calc_date = lv_date.
  ls_value_set_ext-vskey = '3M'.
  ls_value_set_ext-vsvalue = 'Last 3 months'(f02).
  clear ls_value_set_ext-seqnr.
  if me->is_offcycle( iv_molga = iv_molga ) eq abap_true.
*   check against PAYDT (PayDate) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      where paydt ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  else.
*   check againt IPEND (InPeriod end date) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      where ipend ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  endif.
  if ls_value_set_ext-seqnr is initial.
    IF lv_ui5_active eq abap_true.
      ls_value_set_ext-vskey = 'ALL'.
      ls_value_set_ext-vsvalue = 'All Available'(f01).
      read table it_filtered_rgdir into ls_rgdir index lines( it_filtered_rgdir ).
      ls_value_set_ext-seqnr = ls_rgdir-seqnr. "set last entry
      append ls_value_set_ext to et_value_set_ext.
    ENDIF.
    return.
  else.
    append ls_value_set_ext to et_value_set_ext.
  endif.

* "last 6 months" - get lowest SEQNR for this period
  clear ls_value_set_ext.
  call function 'RP_CALC_DATE_IN_INTERVAL'
    exporting
      date      = lv_start_date
      days      = 0
      months    = 6
      signum    = '-'
      years     = 0
    importing
      calc_date = lv_date.
  ls_value_set_ext-vskey = '6M'.
  ls_value_set_ext-vsvalue = 'Last 6 months'(f03).
  clear ls_value_set_ext-seqnr.
  if me->is_offcycle( iv_molga = iv_molga ) eq abap_true.
*   check against PAYDT (PayDate) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      from lv_index
      where paydt ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  else.
*   check againt IPEND (InPeriod end date) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      from lv_index
      where ipend ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  endif.
  if ls_value_set_ext-seqnr is initial.
    IF lv_ui5_active eq abap_true.
      ls_value_set_ext-vskey = 'ALL'.
      ls_value_set_ext-vsvalue = 'All Available'(f01).
      read table it_filtered_rgdir into ls_rgdir index lines( it_filtered_rgdir ).
      ls_value_set_ext-seqnr = ls_rgdir-seqnr. "set last entry
      append ls_value_set_ext to et_value_set_ext.
    ENDIF.
    return.
  else.
    append ls_value_set_ext to et_value_set_ext.
  endif.

* "last 12 months" - get lowest SEQNR for this period
  clear ls_value_set_ext.
  call function 'RP_CALC_DATE_IN_INTERVAL'
    exporting
      date      = lv_start_date
      days      = 0
      months    = 12
      signum    = '-'
      years     = 0
    importing
      calc_date = lv_date.
  ls_value_set_ext-vskey = '12M'.
  ls_value_set_ext-vsvalue = 'Last 12 months'(f04).
  clear ls_value_set_ext-seqnr.
  if me->is_offcycle( iv_molga = iv_molga ) eq abap_true.
*   check against PAYDT (PayDate) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      from lv_index
      where paydt ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  else.
*   check againt IPEND (InPeriod end date) - find lowest value
    loop at it_filtered_rgdir into ls_rgdir
      from lv_index
      where ipend ge lv_date.
      ls_value_set_ext-seqnr = ls_rgdir-seqnr.
      lv_index = sy-tabix.
    endloop.
  endif.
  if ls_value_set_ext-seqnr is initial.
    IF lv_ui5_active eq abap_true.
      ls_value_set_ext-vskey = 'ALL'.
      ls_value_set_ext-vsvalue = 'All Available'(f01).
      read table it_filtered_rgdir into ls_rgdir index lines( it_filtered_rgdir ).
      ls_value_set_ext-seqnr = ls_rgdir-seqnr. "set last entry
      append ls_value_set_ext to et_value_set_ext.
    ENDIF.
    return.
  else.
    append ls_value_set_ext to et_value_set_ext.
  endif.
  IF lv_ui5_active eq abap_true.
    ls_value_set_ext-vskey = 'ALL'.
    ls_value_set_ext-vsvalue = 'All Available'(f01).
    read table it_filtered_rgdir into ls_rgdir index lines( it_filtered_rgdir ).
    ls_value_set_ext-seqnr = ls_rgdir-seqnr. "set last entry
    append ls_value_set_ext to et_value_set_ext.
  ENDIF.

* not yet supported
* first entry in et_value_set_ext acts as default entry for
* drop-down as long as default_entry couldn't be set (FPM issue)
*  ev_default_entry = 'Z'.

endmethod.


method if_hress_payslip_badi~provide_overviewtab_line.

  data ls_overview type ts_overview.
  data lv_dummy_date(10) type c.
  data lt_t52ocg type table of t52ocg.
  data ls_t52ocg like line of lt_t52ocg.
*  data pay_result type pay99_result.
  data ls_rt type line of pay99_result-inter-rt.
  data ls_rt_person type pc2rt_person.
  data lv_betrg type pc207-betrg.
  data lv_betrg_c40 type char21.
  data lv_gross TYPE pc207-betrg.
  data lv_net TYPE pc207-betrg.
  data lv_deduction TYPE pc207-betrg.
* include H99_BATCH_PRCTY.
  data lv_batch_prcty_form  type t52occ-payty value 'F'.
  data lv_gross_amount_wt   like ls_rt-lgart value '/101'.
  data lv_net_amount_wt     like ls_rt-lgart value '/559'.
  data lo_pay_result        type ref to cl_hr_pay_result.
  data lo_pay_result_person type ref to cl_hr_pay_result_person.
  data lv_dummy type c.                               "#EC NEEDED
  "KVHN1921168 - From Here
  DATA : l_cl_pay_access type ref to CL_HR_PAY_ACCESS,
           l_o_pay_result  type ref to CL_HR_PAY_RESULT_PERSON,
           wa_rt_person    type PC2RT_PERSON,
           ls_person       TYPE pcce_pnp_person,
           ls_pernr        LIKE LINE OF ls_person-all_pernrs,
           lv_pernr_tab    TYPE PCCET_PERNR_UNSORTED,
           lv_pernr_pay_result TYPE REF TO CL_HR_PAY_RESULT,
           wa_pernr_tab    LIKE LINE OF lv_pernr_tab,
           wa_rt_pernr     LIKE LINE OF lv_pernr_pay_result->inter-rt,
           lr_cegrp        TYPE REF TO cl_hrcce_grouping_reader_pay,
           lt_gpval        TYPE pccet_period_gpval,
           ls_period       TYPE hrperiods,
           lt_pernr_period TYPE pccet_pernr_period_u,
           lt_pernr_tab_temp TYPE PCCET_PERNR_UNSORTED,
           lt_pernr_tab    LIKE ls_person-all_pernrs,
           ls_pernr_period LIKE LINE OF lt_pernr_period,
           lt_pernr_gpval  TYPE PCCET_PERNR_PERIOD_GPVAL,
           lv_currency     TYPE waers.
  FIELD-SYMBOLS :
            <ls_gpval>     LIKE LINE OF lt_gpval,
            <ls_pernr_period>   LIKE LINE OF lt_pernr_period,
            <ls_pernr_gpval> LIKE LINE OF lt_pernr_gpval.
  "KVHN1921168 - Till Here
  DATA:    lv_retro_gross      TYPE pc207-betrg,             "KVHN2263898
           lv_retro_gross_prev TYPE pc207-betrg,             "KVHN2263898
           lt_rgdir            TYPE HRPY_TT_RGDIR,           "KVHN2263898
           ls_rgdir      LIKE LINE OF lt_rgdir,              "KVHN2263898
           ls_rgdir_prev LIKE LINE OF lt_rgdir,              "KVHN2263898
           lo_pay_result_evp type ref to cl_hr_pay_result,        "KVHN2263898
           lo_pay_result_evp_prev type ref to cl_hr_pay_result.   "KVHN2263898
  "Splits are not handled while calculating Gross   "KVHN2604058
  data: BEGIN OF ls_seqnr_processed,                "KVHN2604058
           seqnr TYPE pc261-seqnr,
           processed TYPE boolean,
        END   OF ls_seqnr_processed,
        lt_seqnr_processed like table of ls_seqnr_processed,
        lt_rgdir_prev like table of ls_rgdir_prev,
        lv_tabix type sy-tabix.

  clear es_message.
  "KVHN1921168 - From Here
  IF  cl_hrce_masterswitches=>payroll_active( molga = iv_molga ) <> 'X'. " For Non-CE cases
    mo_pay_access->read_pa_result(
      exporting
        pernr          = iv_pernr
        molga          = iv_molga
        period         = is_rgdir
      importing
        payroll_result = lo_pay_result ).

    if sy-subrc ne 0.
      message a002(xss_rem) with 'READ_PA_RESULT' iv_pernr is_rgdir-seqnr space into lv_dummy.
      es_message = me->map_sy_to_bapiret( ).
      return.
    endif.
    lv_currency = lo_pay_result->inter-versc-waers.
    CALL METHOD MO_PAY_ACCESS->READ_CLUSTER_DIR_EVP    "KVHN2263898
      EXPORTING
        BONUS_DATE       = is_rgdir-bondt
        INPER_MODIF      = is_rgdir-iperm
        INPER            = is_rgdir-inper
        PAY_TYPE         = is_rgdir-payty
        PAY_IDENT        = is_rgdir-payid
        PERNR            = iv_pernr
        ACCESS_CLUSTER   = 'X'
      IMPORTING
        CLUSTER_DIR      = lt_rgdir
      EXCEPTIONS
        NO_ENTRIES_FOUND = 1
        others           = 2.
  ELSE.   "CE Cases
      CREATE OBJECT l_cl_pay_access.
*   Read the Person Results
      CALL METHOD L_CL_PAY_ACCESS->READ_PE_RESULT
        EXPORTING
          PERNR                         = iv_pernr
          PERIOD                        = is_rgdir
        IMPORTING
          PAYROLL_RESULT                = l_o_pay_result.

      IF SY-SUBRC <> 0.
        message a002(xss_rem) with 'READ_PE_RESULT' iv_pernr is_rgdir-seqnr space into lv_dummy.
        es_message = me->map_sy_to_bapiret( ).
        return.
      ENDIF.
      lv_currency = l_o_pay_result->versc-waers.
   ENDIF.
  "KVHN1921168 - Till Here
* first column (invisible): Sequential number of result
  ls_overview-seqnr = is_rgdir-seqnr.

* date/period
*  if me->is_offcycle( iv_molga ) eq abap_true. "off-cycle country
*   paydate
  ls_overview-paydt = is_rgdir-paydt.
*  else. "only standard periods
*   payroll period
  ls_overview-inperiod = is_rgdir-inper+4(2) && '/' && is_rgdir-inper(4).
*  endif.
  ls_overview-ipend = is_rgdir-ipend.

* set payroll run type
  case iv_molga.
*    when '22'. "Japan
    when others.
      case is_rgdir-payty.
        when ' '. "regular payroll run
          ls_overview-run_type = 'Regular payroll run'(t80).
        when 'A'. "Bonus run
          ls_overview-run_type = 'Bonus payment'(t81).
        when 'B'. "Correction run
          ls_overview-run_type = 'Correction accounting'(t82).
        when 'C'. "Manual check
          ls_overview-run_type = 'Manual check'(T83).
        when others.
      endcase.
  endcase.

* gross amount
  clear lv_betrg.
  case iv_molga.
    when '22'. "Japan
      if is_rgdir-payty <> ' ' and is_rgdir-payid = 'S'.
        lv_gross_amount_wt = '/121'.
      elseif is_rgdir-payty <> ' ' and is_rgdir-payid = 'N'.
        lv_gross_amount_wt = '/141'.
      endif.
    when '01'.
        lv_gross_amount_wt = '/10E'.  "KVHN1933140
    when others.
  endcase.
  "KVHN1921168 - From Here
  IF  cl_hrce_masterswitches=>payroll_active( molga = iv_molga ) <> 'X'.
    CASE iv_molga.
        WHEN '05'.                                                 " Netherland  Note3019843
          LOOP AT lo_pay_result->inter-rt INTO ls_rt
           WHERE lgart EQ '/101' OR lgart EQ '/102'.
            lv_betrg = lv_betrg + ls_rt-betrg.
          ENDLOOP.
        WHEN OTHERS.
          loop at lo_pay_result->inter-rt into ls_rt
           where lgart = lv_gross_amount_wt.
            lv_betrg = lv_betrg + ls_rt-betrg.
          endloop.
     ENDCASE.
    "KVHN2263898 - Starts
    loop at lt_rgdir into ls_rgdir.
      move-corresponding ls_rgdir to ls_seqnr_processed.
      append ls_seqnr_processed to lt_seqnr_processed.
    endloop.
    if is_rgdir-payty <> 'B'.
      loop at lt_rgdir into ls_rgdir where inper = is_rgdir-inper
                                   and   fpper <> is_rgdir-inper
                                   and   bondt = is_rgdir-bondt
                                   and   payid = is_rgdir-payid
                                   and   payty = is_rgdir-payty
                                   "and   permo = is_rgdir-permo   "MP3313817
                                   and   srtza = 'A'.
      mo_pay_access->read_pa_result(
        exporting
          pernr          = iv_pernr
          molga          = iv_molga
          period         = ls_rgdir
        importing
          payroll_result = lo_pay_result_evp ).
      clear lv_retro_gross.
      clear lv_retro_gross_prev.
      if lo_pay_result_evp is not initial.
          if ( iv_molga = '01' and lo_pay_result_evp->inter-versc-fpend <= '20091231' ).
            lv_gross_amount_wt = '/101'.
          endif.
          CASE iv_molga.
              WHEN '05'.                                                     " Netherland
                LOOP AT lo_pay_result_evp->inter-rt INTO ls_rt
                 WHERE lgart EQ '/101' OR lgart EQ '/102'.
                  lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                ENDLOOP.
              WHEN OTHERS.
                loop at lo_pay_result_evp->inter-rt into ls_rt
                 where lgart = lv_gross_amount_wt.
                  lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                endloop.
           ENDCASE.
          " Copy all the previous period data to handle splits
          clear lt_rgdir_prev. refresh lt_rgdir_prev.
          loop at lt_rgdir into ls_rgdir_prev where       fpper = ls_rgdir-fpper and
                                                          bondt = ls_rgdir-bondt and
                                                          payid = ls_rgdir-payid and
                                                          payty = ls_rgdir-payty and
                                                        "  permo = ls_rgdir-permo and
                                                          srtza = 'P'.
            append ls_rgdir_prev to lt_rgdir_prev.
          endloop.
          loop at lt_rgdir_prev into ls_rgdir_prev.
            read table lt_seqnr_processed into ls_seqnr_processed with key seqnr = ls_rgdir_prev-seqnr.
            if sy-subrc = 0.
              lv_tabix = sy-tabix.
              if ls_seqnr_processed-processed = 'X'.
              else.
            mo_pay_access->read_pa_result(
              exporting
                pernr          = iv_pernr
                molga          = iv_molga
                period         = ls_rgdir_prev
              importing
                payroll_result = lo_pay_result_evp_prev ).
            loop at lo_pay_result_evp_prev->inter-rt into ls_rt
                             where lgart = lv_gross_amount_wt.
              lv_retro_gross_prev = lv_retro_gross_prev + ls_rt-betrg.
            endloop.
                ls_seqnr_processed-processed = 'X'.
                modify lt_seqnr_processed from ls_seqnr_processed index lv_tabix.
              endif.
            endif.
          endloop.
      endif.
      lv_betrg = lv_betrg + lv_retro_gross - lv_retro_gross_prev.
    endloop.
    else.
      loop at lt_rgdir into ls_rgdir where inper = is_rgdir-inper
                                     and   fpper <> is_rgdir-inper
                                     "and   permo = is_rgdir-permo    "MP3594785
                                     and   srtza = 'A'.
        mo_pay_access->read_pa_result(
          exporting
            pernr          = iv_pernr
            molga          = iv_molga
            period         = ls_rgdir
          importing
            payroll_result = lo_pay_result_evp ).
        clear lv_retro_gross.
        clear lv_retro_gross_prev.
        if lo_pay_result_evp is not initial.
            if ( iv_molga = '01' and lo_pay_result_evp->inter-versc-fpend <= '20091231' ).
              lv_gross_amount_wt = '/101'.
            endif.

            CASE iv_molga.
              WHEN '05'.                                                    " Netherland
                LOOP AT lo_pay_result_evp->inter-rt INTO ls_rt
                 WHERE lgart EQ '/101' OR lgart EQ '/102'.
                  lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                ENDLOOP.
              WHEN OTHERS.
                loop at lo_pay_result_evp->inter-rt into ls_rt
                 where lgart = lv_gross_amount_wt.
                  lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                endloop.
             ENDCASE.
            " Copy all the previous period data to handle splits
            clear lt_rgdir_prev. refresh lt_rgdir_prev.
            loop at lt_rgdir into ls_rgdir_prev where       fpper = ls_rgdir-fpper and
                                                            "permo = ls_rgdir-permo and   "MP3594785
                                                            srtza = 'P'.
              append ls_rgdir_prev to lt_rgdir_prev.
            endloop.
            loop at lt_rgdir_prev into ls_rgdir_prev.
              read table lt_seqnr_processed into ls_seqnr_processed with key seqnr = ls_rgdir_prev-seqnr.
              if sy-subrc = 0.
                lv_tabix = sy-tabix.
                if ls_seqnr_processed-processed = 'X'.
                else.
                  mo_pay_access->read_pa_result(
                    exporting
                      pernr          = iv_pernr
                      molga          = iv_molga
                      period         = ls_rgdir_prev
                    importing
                      payroll_result = lo_pay_result_evp_prev ).

                   CASE iv_molga.
                    WHEN '05'.                                                           " Netherland
                      LOOP AT lo_pay_result_evp_prev->inter-rt INTO ls_rt
                       WHERE lgart EQ '/101' OR lgart EQ '/102'.
                        lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                      ENDLOOP.
                     WHEN OTHERS.
                      loop at lo_pay_result_evp_prev->inter-rt into ls_rt
                       where lgart = lv_gross_amount_wt.
                        lv_retro_gross_prev = lv_retro_gross_prev + ls_rt-betrg.
                      endloop.
                    ENDCASE.
                  ls_seqnr_processed-processed = 'X'.
                  modify lt_seqnr_processed from ls_seqnr_processed index lv_tabix.
                endif.
              endif.
            endloop.
        endif.
        lv_betrg = lv_betrg + lv_retro_gross - lv_retro_gross_prev.
      endloop.
    endif.
    "KVHN2263898 - Ends
  ELSE.
    clear lv_betrg.
    CALL FUNCTION 'HRF_GET_PERSON_FROM_PERNR'
               EXPORTING
                   iv_pernr      = iv_pernr
                   ix_all_pernrs = 'X'
               IMPORTING
                   es_person     = ls_person.
    CALL METHOD cl_hrcce_grouping_reader_pay=>get_instance
             EXPORTING
               p_endda_source_change = is_rgdir-fpend
             RECEIVING
               p_grouping_reader     = lr_cegrp.

    ls_period-begda = is_rgdir-fpbeg.
    ls_period-endda = is_rgdir-fpend.
    CALL METHOD LR_CEGRP->GET_VALUES_BY_PERSONID
      EXPORTING
        P_PERSONID  = ls_person-objid
        P_GPRSN     = 'XXNT'
        P_PERIOD    = ls_period
      IMPORTING
        P_GPVAL     = lt_pernr_gpval.

    LOOP AT lt_pernr_gpval ASSIGNING <ls_pernr_gpval>
                               where pernr = iv_pernr.
      IF <ls_pernr_gpval>-gpval IS NOT INITIAL.
        READ TABLE <ls_pernr_gpval>-gpval ASSIGNING <ls_gpval> INDEX 1.
        mv_grouping = <ls_gpval>-gpval.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
            CALL METHOD lr_cegrp->get_pernr_by_value
                EXPORTING
                  p_pernr     = iv_pernr
                  p_gprsn     = 'XXNT'
                  p_gpval     = mv_grouping
                  p_period    = ls_period
                IMPORTING
                  p_rpernr    = lt_pernr_period.

            CALL METHOD L_CL_PAY_ACCESS->GET_PARTICIPATING_PERNRS
              EXPORTING
*                MOLGA            =
                PERNR            = iv_pernr
                PERIOD           = is_rgdir
              IMPORTING
                PERNR_TAB        = lt_pernr_tab_temp.
            lt_pernr_tab[] = lt_pernr_tab_temp[].
            LOOP AT lt_pernr_period INTO ls_pernr_period.
              READ TABLE lt_pernr_tab TRANSPORTING NO FIELDS
                         WITH KEY pernr = ls_pernr_period-pernr.
              IF SY-SUBRC <> 0.
                DELETE lt_pernr_period.
              ENDIF.
            ENDLOOP.
    ENDIF.

* Read the individual results of the assignments to get the Gross
     LOOP AT ls_person-all_pernrs INTO ls_pernr.
       CALL METHOD MO_PAY_ACCESS->READ_CLUSTER_DIR_EVP    "KVHN2263898
        EXPORTING
          BONUS_DATE       = is_rgdir-bondt
          INPER_MODIF      = is_rgdir-iperm
          INPER            = is_rgdir-inper
          PAY_TYPE         = is_rgdir-payty
          PAY_IDENT        = is_rgdir-payid
          PERNR            = ls_pernr-pernr
          ACCESS_CLUSTER   = 'X'
        IMPORTING
          CLUSTER_DIR      = lt_rgdir
        EXCEPTIONS
          NO_ENTRIES_FOUND = 1
          others           = 2.

       READ TABLE lt_pernr_period
         WITH KEY pernr = ls_pernr-pernr TRANSPORTING NO FIELDS.
       IF sy-subrc = 0.
         CALL METHOD L_CL_PAY_ACCESS->READ_PA_RESULT
          EXPORTING
            PERNR                         = ls_pernr-pernr
            MOLGA                         = iv_molga
            PERIOD                        = is_rgdir
          IMPORTING
            PAYROLL_RESULT                = lv_pernr_pay_result
          EXCEPTIONS
            NO_AUTHORIZATION              = 1
            READ_ERROR                    = 2
            COUNTRY_VERSION_NOT_AVAILABLE = 3
            others                        = 4
                .
        IF SY-SUBRC = 0.
          LOOP AT lv_pernr_pay_result->inter-rt INTO wa_rt_pernr
            WHERE lgart = lv_gross_amount_wt.
            lv_betrg = lv_betrg + wa_rt_pernr-betrg.
          ENDLOOP.
 "KVHN2263898 - Starts
          if is_rgdir-payty <> 'B'.
            loop at lt_rgdir into ls_rgdir where inper = is_rgdir-inper
                                         and   fpper <> is_rgdir-inper
                                         and   bondt = is_rgdir-bondt
                                         and   payid = is_rgdir-payid
                                         and   payty = is_rgdir-payty
                                         and   permo = is_rgdir-permo
                                         and   srtza = 'A'.
            mo_pay_access->read_pa_result(
              exporting
                pernr          = ls_pernr-pernr
                molga          = iv_molga
                period         = ls_rgdir
              importing
                payroll_result = lo_pay_result_evp ).
            clear lv_retro_gross.
            clear lv_retro_gross_prev.
            if lo_pay_result_evp is not initial.
               loop at lo_pay_result_evp->inter-rt into ls_rt
                             where lgart = lv_gross_amount_wt.
                  lv_retro_gross = lv_retro_gross + ls_rt-betrg.
              endloop.
                read table lt_rgdir into ls_rgdir_prev with key fpper = ls_rgdir-fpper
                                                                bondt = ls_rgdir-bondt
                                                                payid = ls_rgdir-payid
                                                                payty = ls_rgdir-payty
                                                                  permo = ls_rgdir-permo
                                                                  srtza = 'P'.
                  if sy-subrc = 0.
                    mo_pay_access->read_pa_result(
                      exporting
                        pernr          = ls_pernr-pernr
                        molga          = iv_molga
                        period         = ls_rgdir_prev
                      importing
                        payroll_result = lo_pay_result_evp_prev ).
*                    read table lo_pay_result_evp_prev->inter-rt into ls_rt
*                                     with key lgart = lv_gross_amount_wt.
*                    if sy-subrc = 0.
*                      lv_retro_gross_prev = ls_rt-betrg.
*                    endif.
              if lo_pay_result_evp_prev is not initial.
               loop at lo_pay_result_evp_prev->inter-rt into ls_rt
                             where lgart = lv_gross_amount_wt.
                  lv_retro_gross_prev = lv_retro_gross_prev + ls_rt-betrg.
              endloop.
                endif.
               endif.
              endif.
              lv_betrg = lv_betrg + lv_retro_gross - lv_retro_gross_prev.
            endloop.
          else.
            loop at lt_rgdir into ls_rgdir where inper = is_rgdir-inper
                                           and   fpper <> is_rgdir-inper
                                           and   permo = is_rgdir-permo
                                           and   srtza = 'A'.
              mo_pay_access->read_pa_result(
                exporting
                  pernr          = ls_pernr-pernr
                  molga          = iv_molga
                  period         = ls_rgdir
                importing
                  payroll_result = lo_pay_result_evp ).
              clear lv_retro_gross.
              clear lv_retro_gross_prev.
              if lo_pay_result_evp is not initial.
                 loop at lo_pay_result_evp->inter-rt into ls_rt
                               where lgart = lv_gross_amount_wt.
                    lv_retro_gross = lv_retro_gross + ls_rt-betrg.
                endloop.
                  read table lt_rgdir into ls_rgdir_prev with key fpper = ls_rgdir-fpper
                                                                  permo = ls_rgdir-permo
                                                                  srtza = 'P'.
                  if sy-subrc = 0.
                    mo_pay_access->read_pa_result(
                      exporting
                        pernr          = ls_pernr-pernr
                        molga          = iv_molga
                        period         = ls_rgdir_prev
                      importing
                        payroll_result = lo_pay_result_evp_prev ).
*                    read table lo_pay_result_evp_prev->inter-rt into ls_rt
*                                     with key lgart = lv_gross_amount_wt.
*                    if sy-subrc = 0.
*                      lv_retro_gross_prev = ls_rt-betrg.
                     if lo_pay_result_evp_prev is not initial.
               loop at lo_pay_result_evp_prev->inter-rt into ls_rt
                             where lgart = lv_gross_amount_wt.
                  lv_retro_gross_prev = lv_retro_gross_prev + ls_rt-betrg.
              endloop.
                    endif.
                  endif.
              endif.
              lv_betrg = lv_betrg + lv_retro_gross - lv_retro_gross_prev.
            endloop.
          endif.
    "KVHN2263898 - Ends
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
  "KVHN1921168 - Till Here
  write lv_betrg to lv_betrg_c40 right-justified
  currency lv_currency.
  concatenate lv_betrg_c40 lv_currency
  into ls_overview-betrg_1 separated by space.
  lv_gross = lv_betrg.
* payment (net amount)
* If CE is active /559 should be fetched from PERSON results
  clear lv_betrg.
    CASE iv_molga.
      WHEN '05'.                            " Netherland
      lv_net_amount_wt = '/560'.
      WHEN OTHERS.
    ENDCASE.
  if cl_hrce_masterswitches=>payroll_active( molga = iv_molga ) <> 'X'
    or is_rgdir-persdata is initial.
    loop at lo_pay_result->inter-rt into ls_rt
      where lgart = lv_net_amount_wt.
      lv_betrg = lv_betrg + ls_rt-betrg.
    endloop.
  else.
    call method mo_pay_access->read_pe_result
      exporting
        pernr          = iv_pernr
        molga          = iv_molga
        period         = is_rgdir
      importing
        payroll_result = lo_pay_result_person.

    if sy-subrc <> 0.
      message a002(xss_rem) with 'READ_PE_RESULT' iv_pernr is_rgdir-seqnr space into lv_dummy.
      es_message = me->map_sy_to_bapiret( ).
      return.
    endif.
    loop at lo_pay_result_person->inter-rt_person into ls_rt_person
      where lgart = lv_net_amount_wt.
      lv_betrg = lv_betrg + ls_rt_person-betrg.
    endloop.
  endif.

  write lv_betrg to lv_betrg_c40 right-justified
  currency lv_currency.
  concatenate lv_betrg_c40 lv_currency
  into ls_overview-betrg_2 separated by space.

  lv_net = lv_betrg.
*  Add Deduction - UI5
  lv_deduction = lv_gross - lv_net.
  write lv_deduction to lv_betrg_c40 right-justified currency lv_currency.

  IF lv_deduction < 0.
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        value         = lv_betrg_c40.
  ENDIF.
  concatenate lv_betrg_c40 lv_currency into ls_overview-deductions separated by space.
  ls_overview-is_deduction_visible = abap_true.
* last column
* print indicator
  call function 'HR_OC_READ_BATCH'
    exporting
      p_pernr   = iv_pernr
      p_rgdir   = is_rgdir
      p_prcty   = lv_batch_prcty_form
    tables
      pt_t52ocg = lt_t52ocg
    exceptions
      others    = 1.
  if sy-subrc <> 0.
    message a002(xss_rem) with 'HR_OC_READ_BATCH' iv_pernr is_rgdir-seqnr space into lv_dummy.
    es_message = me->map_sy_to_bapiret( ).
    return.
  else.
    sort lt_t52ocg by lfdnr descending.
    loop at lt_t52ocg into ls_t52ocg.
    endloop.
    if sy-subrc ne 0.
*     no entry found - not printed yet
      clear ls_overview-prt_status.
    else.
      if ls_t52ocg-prusr eq space.
        write ls_t52ocg-indat to lv_dummy_date.
        ls_overview-prt_status = 'Flagged for Printing on &1'(t90).
      else.
        write ls_t52ocg-prdat to lv_dummy_date.
        ls_overview-prt_status = 'Printed on &1'(t91).
      endif.
      replace first occurrence of '&1' in ls_overview-prt_status with lv_dummy_date.
    endif. "sy-subrc
  endif.
  IF ls_overview IS NOT INITIAL.
*    CALL FUNCTION 'CONVERSION_EXIT_SDATE_OUTPUT'
*      EXPORTING
*        input         = ls_overview-paydt
*     IMPORTING
*       OUTPUT        = ls_overview-paydt_ui5.
    WRITE ls_overview-paydt to ls_overview-paydt_ui5.
    CONCATENATE ls_overview-paydt_ui5 ':' ls_overview-run_type INTO ls_overview-payslip_title_ui5 SEPARATED BY SPACE.
  ENDIF.

  es_overview = ls_overview.
endmethod.


METHOD if_hress_payslip_badi~provide_titles.

  DATA lv_title_part   TYPE char40.
  DATA lv_ui5_active TYPE abap_bool.
  DATA lo_otr TYPE REF TO cl_sotr.
  IF cl_hress_ui5_switch_check_01=>hress_sfws_ui5_ui_01( ) EQ abap_true AND is_rgdir IS INITIAL.
    CREATE OBJECT lo_otr
      EXPORTING
        i_langu = sy-langu.
    lo_otr->get_text_by_alias(
      EXPORTING
        i_alias = 'PAOC_ESS_UI5/SALARY_STATEMENT'     " Unique Alias Name for OTR Concept
      IMPORTING
        e_text  = ev_appl_title    " Text Table in the OTR
    ).
  ELSE.
    IF me->is_offcycle( iv_molga ) EQ abap_true.
      WRITE is_rgdir-paydt TO lv_title_part LEFT-JUSTIFIED.
    ELSE.
      lv_title_part = is_rgdir-inper+4(2) && '/' && is_rgdir-inper(4).
    ENDIF.
    ev_appl_title = iv_default_title && `: ` && lv_title_part .
    ev_popup_title = ev_appl_title.
  ENDIF.
ENDMETHOD.


  method IS_OFFCYCLE.
  endmethod.


  method MAP_SY_TO_BAPIRET.
  endmethod.
ENDCLASS.
