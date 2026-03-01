
CLASS ltd_person_provider DEFINITION FOR TESTING ##CLASS_FINAL.
  PUBLIC SECTION.
    INTERFACES if_hrsfec_ce_person_provider PARTIALLY IMPLEMENTED.
ENDCLASS.

CLASS ltd_person_provider IMPLEMENTATION.
  METHOD if_hrsfec_ce_person_provider~get.
    CLEAR er_person.
    RETURN.
  ENDMETHOD.

  METHOD if_hrsfec_ce_person_provider~get_person_ixml_document.
    RETURN.
  ENDMETHOD.

  METHOD if_hrsfec_ce_person_provider~get_employment_ixml_node.
    RETURN.
  ENDMETHOD.

  METHOD if_hrsfec_ce_person_provider~get_purge_details.
    RETURN.
  ENDMETHOD.

  METHOD if_hrsfec_ce_person_provider~get_employment_id_by_pernr.
    RETURN.
  ENDMETHOD.
ENDCLASS.

CLASS ltd_simple_hrpa_masterdata_bl DEFINITION FOR TESTING ##CLASS_FINAL.
  PUBLIC SECTION.

    INTERFACES if_hrpa_masterdata_bl.
    INTERFACES if_hrpa_masterdata_buffer.


ENDCLASS.

CLASS ltd_simple_hrpa_masterdata_bl IMPLEMENTATION.

  METHOD if_hrpa_buffer_control~start_trial.
    CLEAR: magic_cookie.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_buffer_control~discard_trial.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_buffer_control~approve_trial.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_buffer_control~initialize.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_buffer_control~flush.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_masterdata_bl~insert.
    CLEAR: is_ok.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_masterdata_bl~modify.
    CLEAR: is_ok.
    cl_abap_unit_assert=>fail( msg =  text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_masterdata_bl~delete.
    CLEAR: is_ok.
    cl_abap_unit_assert=>fail( msg =  text-001 ).
  ENDMETHOD.
  METHOD if_hrpa_masterdata_bl~regroup.
    CLEAR: is_ok.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_additional_buffer~additional_update.
    cl_abap_unit_assert=>fail( msg =  text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_buffer~insert.
    cl_abap_unit_assert=>fail( msg =  text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_buffer~update.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_buffer~delete.
    cl_abap_unit_assert=>fail( msg =  text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_bl~get_infty_container.
    CLEAR: container, is_ok.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_bl~action.
    CLEAR: is_ok, aux_output.
    CLEAR container.
    CLEAR is_ok.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_bl~read.
    CLEAR container_tab.
    CLEAR is_ok.
    cl_abap_unit_assert=>fail( msg = text-001 ).
  ENDMETHOD.

  METHOD if_hrpa_masterdata_buffer~read.
    CLEAR container_tab.
    cl_abap_unit_assert=>fail( msg = text-001 ).

  ENDMETHOD.
ENDCLASS.




CLASS lcl_ce_change_it0001 DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
##CLASS_FINAL.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>lcl_Ce_Change_It0001
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>CL_HRSFEC_CE_CHANGE_IT0001
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_cut TYPE REF TO zhrsfec_b_ce_change_it0001.  "class under test
    DATA mo_mock_hrpa_masterdata_bl TYPE REF TO ltd_simple_hrpa_masterdata_bl.
    DATA mo_if TYPE REF TO ltd_simple_hrpa_masterdata_bl.
    DATA mo_pers_prov TYPE REF TO ltd_person_provider.
    DATA mo_pers_prov_if TYPE REF TO if_hrsfec_ce_person_provider.
    METHODS: setup.
    METHODS: change_info_type_data FOR TESTING.
    METHODS: change_info_type_data_hire FOR TESTING.
    METHODS: define_fields_to_be_changed FOR TESTING.
ENDCLASS.       "lcl_Ce_Change_It0001


CLASS lcl_ce_change_it0001 IMPLEMENTATION.

  METHOD setup.
    CREATE OBJECT mo_mock_hrpa_masterdata_bl.
    mo_if = mo_mock_hrpa_masterdata_bl.
    CREATE OBJECT mo_pers_prov.
    mo_pers_prov_if ?= mo_pers_prov .
    CREATE OBJECT f_cut.

  ENDMETHOD.

  METHOD change_info_type_data.
    CONSTANTS:
      lc_custom_field_name     TYPE string VALUE 'custom_string4'.

    DATA lt_job_information TYPE pad_sfec_ce_job_info_tab.
    DATA lo_message_handler       TYPE REF TO if_hrsfec_b2b_msg_handler.
    DATA lt_compensation_information  TYPE pad_sfec_ce_compensation_tab.
    DATA lt_map_messages  TYPE if_hrsfec_mapping_message=>gty_t_mapping_message.
    DATA ls_infty_0001  TYPE p0001.
    DATA lt_infty_0001  TYPE p0001_tab.
    DATA lt_infty_0001_exp  TYPE p0001_tab.
    DATA ls_job_information TYPE pad_sfec_ce_job_info.
    DATA ls_value TYPE pad_sfec_ce_field_value.

    ls_value-element_name = lc_custom_field_name.
    ls_value-element_value = 'UNION'.
    APPEND ls_value TO ls_job_information-_value_list.
    ls_job_information-location = 'US010002'.
    ls_job_information-company = 'US01'.
    ls_job_information-start_date = '20180101'.
    ls_job_information-end_date = '20180101'.
    APPEND ls_job_information TO lt_job_information.

    ls_value-element_name = lc_custom_field_name.
    ls_value-element_value = 'UNION'.
    APPEND ls_value TO ls_job_information-_value_list.
    ls_job_information-location = 'US010001'.
    ls_job_information-company = 'US01'.
    ls_job_information-start_date = '20180102'.
    ls_job_information-end_date = '20180104'.
    APPEND ls_job_information TO lt_job_information.

    CLEAR ls_infty_0001.
    ls_infty_0001-begda =  '20180101'.
    ls_infty_0001-endda =  '20180101'.
    APPEND ls_infty_0001 TO lt_infty_0001.
    CLEAR ls_infty_0001.
    ls_infty_0001-begda =  '20180102'.
    ls_infty_0001-endda =  '20180104'.
    APPEND ls_infty_0001 TO lt_infty_0001.

    CLEAR ls_infty_0001.
    ls_infty_0001-begda =  '20180101'.
    ls_infty_0001-endda =  '20180101'.
    ls_infty_0001-werks = 'US02'.
    ls_infty_0001-btrtl = 'UNIO'.

    APPEND ls_infty_0001 TO lt_infty_0001_exp.

    CLEAR ls_infty_0001.
    ls_infty_0001-begda =  '20180102'.
    ls_infty_0001-endda =  '20180104'.
    ls_infty_0001-werks = 'US01'.
    ls_infty_0001-btrtl = 'UNIO'.

    APPEND ls_infty_0001 TO lt_infty_0001_exp.

    DATA lt_cost_assignment TYPE pad_sfec_ce_empcostassgmt_tab.

    CREATE OBJECT lo_message_handler TYPE cl_hrsfec_b2b_message_list.
    TRY.
        DATA lo_hrsfec_ce_purge_details TYPE REF TO if_hrsfec_ce_purge_details.
        lo_hrsfec_ce_purge_details  = mo_pers_prov_if->get_purge_details( ).
        f_cut->if_hrsfec_ce_change_it0001~change_info_type_data(
          EXPORTING
            iv_country_grouping            = '01'
            iv_personnel_number            = '4711'
            it_job_information             =  lt_job_information
            it_compensation_information    =  lt_compensation_information
            it_cost_assignment             = lt_cost_assignment
            io_msg_handler                 =  lo_message_handler
            io_hrpa_masterdata_bl          =  mo_if
            io_ce_person_data_provider     =  mo_pers_prov_if
            iv_full_transmission_start_dat = '20100101'
            it_map_messages                =  lt_map_messages
            io_hrsfec_ce_purge_details     = lo_hrsfec_ce_purge_details
          CHANGING
            ct_infty_0001                  =  lt_infty_0001
        ).
      CATCH cx_hrsfec_root.    "
        cl_abap_unit_assert=>fail(
          EXPORTING
            msg    =  'unexpected exception'
        ).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act   = lt_infty_0001
      exp   = lt_infty_0001_exp
    ).
  ENDMETHOD.


  METHOD change_info_type_data_hire.
    CONSTANTS:
      lc_custom_field_name     TYPE string VALUE 'custom_string4'.

    DATA ls_job_information TYPE pad_sfec_ce_job_info.
    DATA lo_message_handler       TYPE REF TO if_hrsfec_b2b_msg_handler.
    DATA lt_map_messages  TYPE if_hrsfec_mapping_message=>gty_t_mapping_message.
    DATA ls_infty_0001  TYPE p0001.
    DATA ls_infty_0001_exp  TYPE p0001.
    CREATE OBJECT lo_message_handler TYPE cl_hrsfec_b2b_message_list.

    DATA ls_value TYPE pad_sfec_ce_field_value.

    ls_value-element_name = lc_custom_field_name.
    ls_value-element_value = 'UNION'.
    APPEND ls_value TO ls_job_information-_value_list.
    ls_job_information-location = 'US010002'.
    ls_job_information-company = 'US01'.
    ls_job_information-start_date = '20180101'.
    ls_job_information-end_date = '20180101'.

    CLEAR ls_infty_0001.
    ls_infty_0001-begda =  '20180101'.
    ls_infty_0001-endda =  '20180101'.

    CLEAR ls_infty_0001_exp.
    ls_infty_0001_exp-begda =  '20180101'.
    ls_infty_0001_exp-endda =  '20180101'.
    ls_infty_0001_exp-werks = 'US02'.
    ls_infty_0001_exp-btrtl = 'UNIO'.
    ls_infty_0001_exp-sbmod = ls_infty_0001_exp-werks.
    ls_infty_0001_exp-sachp = '001'.
    DATA ls_cost_assignment TYPE pad_sfec_ce_empcostassgmt.
    TRY.
        DATA lo_hrsfec_ce_purge_details TYPE REF TO if_hrsfec_ce_purge_details.
        lo_hrsfec_ce_purge_details  = mo_pers_prov_if->get_purge_details( ).
        f_cut->if_hrsfec_ce_change_it0001~change_info_type_data_hire(
          EXPORTING
            iv_country_grouping            =  '01'
            iv_personnel_number            =  '4711'
            is_job_information             =  ls_job_information
            iv_pay_group                   =  '02'
            is_cost_assignment             =  ls_cost_assignment
            io_msg_handler                 =  lo_message_handler
            io_hrpa_masterdata_bl          =  mo_if
            io_ce_person_data_provider     =  mo_pers_prov_if
            iv_full_transmission_start_dat = '20100101'
            it_map_messages                =  lt_map_messages
            io_hrsfec_ce_purge_details     = lo_hrsfec_ce_purge_details
          CHANGING
            cs_infty_0001                  =  ls_infty_0001
        ).

      CATCH cx_hrsfec_root.
        cl_abap_unit_assert=>fail(
  EXPORTING
    msg    =  'unexpected exception'
).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act   = ls_infty_0001
      exp   = ls_infty_0001_exp
    ).
  ENDMETHOD.


  METHOD define_fields_to_be_changed.
    DATA lt_changed_fields TYPE cl_hrsfec_map_extensibility=>gty_ts_mapped_field.
    DATA lt_changed_fields_exp TYPE cl_hrsfec_map_extensibility=>gty_ts_mapped_field.
    DATA ls_mapped_field TYPE cl_hrsfec_map_extensibility=>gty_s_mapped_field.
    ls_mapped_field-fieldname = 'BTRTL'.
    COLLECT ls_mapped_field INTO lt_changed_fields_exp .
    ls_mapped_field-fieldname = 'SACHP'.
    COLLECT ls_mapped_field INTO lt_changed_fields_exp .
    ls_mapped_field-fieldname = 'SBMOD'.
    COLLECT ls_mapped_field INTO lt_changed_fields_exp .
    ls_mapped_field-fieldname = 'WERKS'.
    COLLECT ls_mapped_field INTO lt_changed_fields_exp .
    TRY.
        f_cut->if_hrsfec_ce_change_it0001~define_fields_to_be_changed(
          EXPORTING
            iv_country_grouping =   '01'
          CHANGING
            ct_changed_fields   =   lt_changed_fields
        ).
      CATCH cx_hrsfec_root.    "
        cl_abap_unit_assert=>fail(
  EXPORTING
    msg    =  'unexpected exception'
).
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      act   = lt_changed_fields
      exp   = lt_changed_fields_exp
    ).
  ENDMETHOD.




ENDCLASS.
