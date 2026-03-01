class ZCL_EX_HRPAYTR_TAX definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_HRPAYTR_TAX .
protected section.
private section.
ENDCLASS.



CLASS ZCL_EX_HRPAYTR_TAX IMPLEMENTATION.


  METHOD if_ex_hrpaytr_tax~change_cancel_rate.
    DATA lr_wpbp TYPE REF TO pc205.

    LOOP AT it_wpbp REFERENCE INTO lr_wpbp.
      IF lr_wpbp->werks = '2310' AND lr_wpbp->btrtl = '2311'.
        cv_terko = '100'.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
