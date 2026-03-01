*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_YPCHIRE0                                                    *
*----------------------------------------------------------------------*
*

*---------------------------------------------------------------------*
* form hire_fire.
*---------------------------------------------------------------------*
FORM hire_fire USING begda endda
                     h_date f_date.
  CALL FUNCTION 'RP_HIRE_FIRE'
    EXPORTING
      beg       = begda
      end       = endda
    IMPORTING
      hire_date = h_date
      fire_date = f_date
    TABLES
      pp0000    = p0000                               "in
      pp0001    = p0001                               "in
      pphifi    = phifi.                              "out
ENDFORM.
