class ZCL_HRSFEC_CE_DECIDE_HIRE_REHI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_HRSFEC_CE_DECIDE_HIRE_REHIR .
protected section.
private section.

  methods MOLGA_FROM_BUKRS
    importing
      !IV_BUKRS type BUKRS
    returning
      value(RV_MOLGA) type MOLGA .
ENDCLASS.



CLASS ZCL_HRSFEC_CE_DECIDE_HIRE_REHI IMPLEMENTATION.


  METHOD if_hrsfec_ce_decide_hire_rehir~decide_hire_rehire.
* Example implementation for BAdI HRSFEC_B_CE_DECIDE_HIRE_REHIRE

* The standard coding will create a separate PERNR for an employee whenever a new company code is assigned.
* This BAdI gives the customer controll on when a new pernr is to be created
* Parameter cv_new_hire:  Set to 'X' if a new pernr is supposed to be created
* Parameter cv_pernr:  Return the existing pernr which should be reused for this record

* BEWARE:
* =======
*  1) It is not advised to create new pernrs on a finer granularity (bukrs) than the standard SAP coding
*  2) Even if the BAdI implementation returns cv_new_hire = ' ' and in cv_pernr a pernr to be re-used,
*     it might not be possible to actually use this pernr for storing the emplyoee data.  The changes in
*     infotpye 0001 might be such that normal ERP logic requires a new pernr (e.g. on change of molga).
*     This will result in a failed replication with corresponding error messages in the log.
*  3) Do not try to combine data for distinct emplyoment records into one pernr. This will result in chaos
*     because Employee Central keeps separate sets of data for JobInformaiton, CompensationInformation,
*     etc. per employment.
*  4) Do not use io_ee_key_mapping to write key mapping entries, use it for reading only.
*     The standard coding processed after this will create necessary entries.

    DATA: lt_eekeymap    TYPE hrsfec_t_eekeymp,
          lv_bukrs_new   TYPE bukrs,
          lv_molga_new   TYPE molga,
          lv_employee_id TYPE pad_sfec_employment_id_v2,
          lv_company_id  TYPE hrsfec_company_id.
    DATA lv_uuid                    TYPE sysuuid_c32.

    FIELD-SYMBOLS:
                   <ls_eekeymap>      TYPE hrsfec_d_eekeymp.

    IF cv_new_hire IS NOT INITIAL. "do not override SAP's decision to keep pernr

      CALL METHOD cl_hrsfec_api_ce_type_conv=>convert_string_c
        EXPORTING
          iv_source_value      = is_person-person_id
          iv_source_fieldname  = if_hrsfec_api_ce_data=>gc_fld_person-person_id
          iv_source_objectname = if_hrsfec_api_ce_data=>gc_segment-person
          io_message_handler   = io_messsage_handler
        CHANGING
          cv_target_value      = lv_employee_id.

      CALL METHOD cl_hrsfec_api_ce_type_conv=>convert_string_c
        EXPORTING
          iv_source_value      = is_job_information-company
          iv_source_fieldname  = if_hrsfec_api_ce_data=>gc_fld_job_information-company
          iv_source_objectname = if_hrsfec_api_ce_data=>gc_segment-job_information
          io_message_handler   = io_messsage_handler
        CHANGING
          cv_target_value      = lv_company_id.

* get the uuid
      CALL METHOD cl_hrsfec_api_ce_type_conv=>convert_string_c
        EXPORTING
          iv_source_value      = is_person-per_person_uuid
          iv_source_fieldname  = if_hrsfec_api_ce_data=>gc_fld_person-per_person_uuid
          iv_source_objectname = if_hrsfec_api_ce_data=>gc_segment-person
          io_message_handler   = io_messsage_handler
        CHANGING
          cv_target_value      = lv_uuid.


*    read existing employee key mapping entries for this employment
      io_ee_key_mapping->read(
        EXPORTING iv_employee_id   = lv_employee_id
                  iv_person_uuid = lv_uuid
                  iv_employment_id = iv_employment_id
        IMPORTING et_hrsfec_eekeymap = lt_eekeymap ).
*    no need to catch exception; will be passed to caller

      IF lines( lt_eekeymap ) > 0. "no need to continue if employment was not replicated yet.

*       read bukrs for current record
        cl_hrsfec_key_map_comp_code=>read_bukrs_by_company_id(
          EXPORTING iv_company_id = lv_company_id
          IMPORTING ev_bukrs      = lv_bukrs_new ).

*       determine molga for current record
        lv_molga_new = molga_from_bukrs( lv_bukrs_new ).

        LOOP AT lt_eekeymap ASSIGNING <ls_eekeymap>.
          IF molga_from_bukrs( <ls_eekeymap>-bukrs ) = lv_molga_new.
*           found pernr for existing employment and bukrs
            CLEAR cv_new_hire.
            cv_pernr = <ls_eekeymap>-pernr.
            EXIT. "#EC CI_NOORDER
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD MOLGA_FROM_BUKRS.
    SELECT SINGLE molga FROM t500p INTO rv_molga WHERE bukrs = iv_bukrs. "#EC CI_NOORDER "#EC *  all entires for iv_bukrs must share same molga
    IF sy-subrc <> 0.
      CLEAR rv_molga.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
