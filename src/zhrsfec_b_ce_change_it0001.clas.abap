class ZHRSFEC_B_CE_CHANGE_IT0001 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_HRSFEC_CE_CHANGE_IT0001 .
protected section.
private section.
ENDCLASS.



CLASS ZHRSFEC_B_CE_CHANGE_IT0001 IMPLEMENTATION.


  METHOD if_hrsfec_ce_change_it0001~change_info_type_data.
* THIS IS AN EXAMPLE IMPLEMENTATION HOW FOR INFOTYPE 1 THE FIELD
* PERSONNEL AREA CAN BE DERIVED FROM THE EMPLOYEE CENTRAL FIELDS
* LOCATION AND LEGAL ENTITY AND HOW THE FIELD PERSONNEL SUB AREA CAN BE
* DERIVED FROM A CUSTOM FIELD IN EMPLOYEE CENTRAL.
*


    CONSTANTS:
      lc_custom_field_name TYPE string VALUE 'custom_string16',
      lc_custom_field_name1 TYPE string VALUE 'custom_string17',
      lc_custom_field_name2 TYPE string VALUE 'custom_string11'.
    DATA:
      ls_p0001      TYPE          p0001,
      ls_msg        TYPE          symsg,
      ls_value      TYPE          pad_sfec_ce_field_value,
      lv_isseviyesi TYPE          string,
      lv_dagitim    TYPE          string,
      lv_persinif   TYPE          string,
      lv_tabix      TYPE          sy-tabix,
      lv_dummy      TYPE          string.
    DATA : lt_zzlvl TYPE TABLE OF zbyhr_t020 .
    DATA : ls_zzlvl TYPE zbyhr_t020 .
    DATA : lt_persnf TYPE TABLE OF zbyhr_t022 .
    DATA : ls_persnf TYPE zbyhr_t022 .
    DATA : lt_zzdgtm TYPE TABLE OF zbyhr_t023 .
    DATA : ls_zzdgtm TYPE zbyhr_t023 .

    FIELD-SYMBOLS:
      <ls_job_information>   TYPE pad_sfec_ce_job_info.
*...

    DEFINE add_message .

      MESSAGE ID &3 TYPE &2 NUMBER 042  WITH &1
          INTO lv_dummy.
      MOVE-CORRESPONDING sy TO ls_msg.
      CALL METHOD io_msg_handler->add_message_with_reference
        EXPORTING
          is_message = ls_msg
          iv_pernr   = iv_personnel_number
          iv_infty   = cl_hrsfec_service_lib=>gc_infty_0001.
    END-OF-DEFINITION.


    SELECT * FROM zbyhr_t020 INTO TABLE lt_zzlvl .
    SELECT * FROM zbyhr_t022 INTO TABLE lt_persnf .
    SELECT * FROM zbyhr_t023 INTO TABLE lt_zzdgtm .


    LOOP AT it_job_information ASSIGNING <ls_job_information>.
      READ TABLE <ls_job_information>-_value_list INTO ls_value
            WITH KEY element_name = lc_custom_field_name.
      IF sy-subrc <> 0.
        CLEAR  lv_isseviyesi .
      ELSE.
        lv_isseviyesi = ls_value-element_value.
      ENDIF.

      READ TABLE <ls_job_information>-_value_list INTO ls_value
            WITH KEY element_name = lc_custom_field_name1.
      IF sy-subrc <> 0.
        CLEAR  lv_persinif .
      ELSE.
        lv_persinif = ls_value-element_value.
      ENDIF.

      READ TABLE <ls_job_information>-_value_list INTO ls_value
           WITH KEY element_name = lc_custom_field_name2.
      IF sy-subrc <> 0.
        CLEAR  lv_dagitim .
      ELSE.
        lv_dagitim = ls_value-element_value.
      ENDIF.

      CLEAR lv_tabix.
      LOOP AT ct_infty_0001 INTO ls_p0001 WHERE
              begda LE <ls_job_information>-end_date  AND
              endda GE <ls_job_information>-start_date.

        lv_tabix = sy-tabix.

*  UPDATE VDSK1

        READ TABLE lt_zzlvl INTO ls_zzlvl WITH KEY zzlvlk = lv_isseviyesi.
        ls_p0001-zzlvl = ls_zzlvl-zzlvl.
        READ TABLE lt_persnf INTO ls_persnf WITH KEY zzpesnfk = lv_persinif.
        ls_p0001-zzpersnf = ls_persnf-zzpersnf.
        READ TABLE lt_zzdgtm INTO ls_zzdgtm WITH KEY zzdgtmkd = lv_dagitim.
        ls_p0001-zzdgtm = ls_zzdgtm-zzdgtm.
*
*        READ TABLE LT_KOKRS INTO LS_KOKRS WITH KEY BUKRS = COMPANY.
*        IF SY-SUBRC EQ 0 .
*          CONCATENATE 'KONTROL KODU'
*                      LV_COSTC(4)
*                      '-> '
*                      LS_KOKRS-KOKRS
*                      'DÖNÜŞTÜRÜLMÜŞTÜR. BILGI TIPI 0001'
*          INTO DATA(LV_MSG) SEPARATED BY SPACE ..
*
*          ADD_MESSAGE : LV_MSG 'W' 'HRSFEC_SERVICES' .
*          LV_COSTC(4) = LS_KOKRS-KOKRS.
*        ENDIF.
*        LS_P0001-KOKRS = LV_COSTC(4).
*        LS_P0001-KOSTL = LV_COSTC+4(10).
*        LV_COSTC = LV_COSTC2.


        MODIFY ct_infty_0001 INDEX lv_tabix FROM ls_p0001 .
*          TRANSPORTING WERKS BTRTL.

      ENDLOOP.


      IF sy-subrc <> 0.
        add_message : 'MESSAGE SENT BY TESTBADI IT0001'
                      'W'
                      'HRSFEC_SERVICES'.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.


  METHOD if_hrsfec_ce_change_it0001~define_fields_to_be_changed.
* in the sample implementation method CHANGE_INFO_TYPE_DATA field BTRTL and WERKS of infotype 0001 is changed.
* so we need to register here the change of the field .

    DATA ls_mapped_field TYPE cl_hrsfec_map_extensibility=>gty_s_mapped_field.
*    ls_mapped_field-fieldname = 'BTRTL'.
*    COLLECT ls_mapped_field INTO ct_changed_fields.
*    ls_mapped_field-fieldname = 'SACHP'.
*    COLLECT ls_mapped_field INTO ct_changed_fields.
    ls_mapped_field-fieldname = 'VDSK1'.
    COLLECT ls_mapped_field INTO ct_changed_fields.
*    ls_mapped_field-fieldname = 'WERKS'.
*    COLLECT ls_mapped_field INTO ct_changed_fields.
     ls_mapped_field-fieldname = 'ZZLVL'.
     COLLECT ls_mapped_field INTO ct_changed_fields.

  ENDMETHOD.
ENDCLASS.
