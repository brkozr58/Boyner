*----------------------------------------------------------------------*
*   INCLUDE YPRHIRE                                                    *
*----------------------------------------------------------------------*
*

*---------------------------------------------------------------------*
* form hire_fire.
*---------------------------------------------------------------------*
FORM HIRE_FIRE USING BEGDA ENDDA
                     H_DATE F_DATE.
 CALL FUNCTION 'RP_HIRE_FIRE'
      EXPORTING
           BEG       = BEGDA
           END       = ENDDA
      IMPORTING
           HIRE_DATE = H_DATE
           FIRE_DATE = F_DATE
      TABLES
           PP0000    = P0000                               "in
           PP0001    = P0001                               "in
           PPHIFI    = PHIFI.                              "out
ENDFORM.
