class ZBYHR_CHANGE_0008_CL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_HRSFEC_CE_CHANGE_IT0008 .
protected section.
private section.
ENDCLASS.



CLASS ZBYHR_CHANGE_0008_CL IMPLEMENTATION.


  METHOD if_hrsfec_ce_change_it0008~change_info_type_data.

    CONSTANTS:
      lc_customf1 TYPE string VALUE 'custom_double2'.


    LOOP AT it_compensation_information ASSIGNING FIELD-SYMBOL(<ls_comp>).
      LOOP AT ct_infty_0008 ASSIGNING FIELD-SYMBOL(<ls_0008>)
          WHERE begda LE <ls_comp>-end_date
            AND endda GE <ls_comp>-start_date.
        LOOP AT <ls_comp>-paycompensation_recurring ASSIGNING FIELD-SYMBOL(<ls_payr>)
             WHERE start_date LE <ls_comp>-end_date
               AND end_date   GE <ls_comp>-start_date.
          LOOP AT <ls_payr>-_value_list ASSIGNING FIELD-SYMBOL(<ls_vlist>) WHERE element_name EQ lc_customf1.
            <ls_0008>-anz01 = <ls_vlist>-element_value.
          ENDLOOP.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
