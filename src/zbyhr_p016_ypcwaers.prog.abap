*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_YPCWAERS                                                   *
*----------------------------------------------------------------------*
*
FORM get_currency USING molga
                        currency
                        save_currency
                        begda
                        factor.

  CALL FUNCTION 'RP_GET_CURRENCY'
    EXPORTING
      molga = molga
      begda = begda
    IMPORTING
      waers = currency
              EXCEPTIONS
              OTHERS.
  IF sy-subrc NE 0.
    calc_currency = save_currency.
  ENDIF.


  CALL FUNCTION 'CURRENCY_CONVERTING_FACTOR'
    EXPORTING
      currency = currency
    IMPORTING
      factor   = factor.

ENDFORM.
*
