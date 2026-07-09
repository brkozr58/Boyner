class ZCL_HRPAYTR_PRH01_13 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_HRPAYTR_PRH01_13 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_HRPAYTR_PRH01_13 IMPLEMENTATION.


  METHOD if_ex_hrpaytr_prh01_13~change_values.
    CLEAR : split_cons .
    LOOP AT wpbp TRANSPORTING NO FIELDS WHERE aktivjn EQ 'X'.
      ADD 1 TO split_cons.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
