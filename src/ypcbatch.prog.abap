*----------------------------------------------------------------------*
*   INCLUDE ZPCBATCH                                              *
*----------------------------------------------------------------------*
*
* =================================================================== *
* Erstellung der Batch-Input Mappe für die Abfindung
* =================================================================== *
*---------------------------------------------------------------------*
*  form batch_open.
*---------------------------------------------------------------------*
FORM BATCH_OPEN USING $BNAME.
  CALL FUNCTION 'BDC_OPEN_GROUP'
       EXPORTING
            CLIENT = SY-MANDT
            GROUP  = $BNAME
            USER   = SY-UNAME.
ENDFORM.

*---------------------------------------------------------------------*
*  form batch_input.
*---------------------------------------------------------------------*
FORM BATCH_INPUT USING $LGART $BETRG $PERNR
                       $HIRE  $FIRE  $DATE $WAERS.
*  perform batch_open.
  PERFORM D1000 USING $LGART $PERNR $HIRE $FIRE.
  PERFORM BI_INSERT USING $LGART $BETRG $WAERS $DATE.
  CALL FUNCTION 'BDC_INSERT'
       EXPORTING
            TCODE     = 'PA30'
       TABLES
            DYNPROTAB = BDCDATA.
*  call function 'BDC_CLOSE_GROUP'.
ENDFORM.

*---------------------------------------------------------------------*
*  form batch_input.
*---------------------------------------------------------------------*
FORM BATCH_INPUT_0014 USING $LGART $BETRG $PERNR
                            $HIRE  $FIRE  $DATE $WAERS.
*  perform batch_open.
  PERFORM D1000_0014 USING $LGART $PERNR $HIRE $FIRE.
  PERFORM BI_INSERT_0014 USING $LGART $BETRG $WAERS $DATE.
  CALL FUNCTION 'BDC_INSERT'
       EXPORTING
            TCODE     = 'PA30'
       TABLES
            DYNPROTAB = BDCDATA.
*  call function 'BDC_CLOSE_GROUP'.
ENDFORM.


*---------------------------------------------------------------------*
*       Einstiegsbild PA30                                            *
*---------------------------------------------------------------------*
*  form d1000.
*---------------------------------------------------------------------*
FORM D1000 USING $LGART $PERNR $HIRE $FIRE.
  REFRESH BDCDATA.

  PERFORM BDC_DYNPRO USING 'SAPMP50A' '1000'.
  PERFORM BDC_FIELD USING 'RP50G-PERNR' $PERNR.
  PERFORM BDC_FIELD USING 'RP50G-CHOIC' '0015'.
*  perform bdc_field using 'RP50G-SUBTY' $lgart.
  WRITE $HIRE TO H_DATE.
  PERFORM BDC_FIELD USING 'RP50G-BEGDA' H_DATE.
*  write $fire to h_date.
*  perform bdc_field using 'RP50G-ENDDA' h_date.
  PERFORM BDC_FIELD USING 'BDC_OKCODE' '=INS'.
ENDFORM.

*---------------------------------------------------------------------*
*       Einstiegsbild PA30                                            *
*---------------------------------------------------------------------*
*  form d1000.
*---------------------------------------------------------------------*
FORM D1000_0014 USING $LGART $PERNR $HIRE $FIRE.
  REFRESH BDCDATA.

  PERFORM BDC_DYNPRO USING 'SAPMP50A' '1100'.
  PERFORM BDC_FIELD USING 'RP50G-PERNR' $PERNR.
  PERFORM BDC_FIELD USING 'RP50G-CHOIC' '0014'.
  PERFORM BDC_FIELD USING 'RP50G-SUBTY' $LGART.
*  write $hire to h_date.
*  perform bdc_field using 'RP50G-BEGDA' h_date.
*  write $fire to h_date.
*  perform bdc_field using 'RP50G-ENDDA' h_date.
  PERFORM BDC_FIELD USING 'BDC_OKCODE' '=INS'.
ENDFORM.

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM BI_INSERT USING $LGART $BETRG $WAERS $DATE.
  DATA: WS_CHAR(13).
  PERFORM BDC_DYNPRO USING 'MP001500' '2000'.
  PERFORM BDC_FIELD USING 'P0015-LGART' $LGART.
  WRITE $BETRG CURRENCY CALC_CURRENCY TO WS_CHAR.
  PERFORM BDC_FIELD USING 'Q0015-BETRG' WS_CHAR.
  PERFORM BDC_FIELD USING 'P0015-WAERS' $WAERS.
  WRITE $DATE TO H_DATE.
  PERFORM BDC_FIELD USING 'P0015-BEGDA' H_DATE.
  PERFORM BDC_FIELD USING 'BDC_OKCODE' '=UPD'.
ENDFORM.

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM BI_INSERT_0014 USING $LGART $BETRG $WAERS $DATE.
  DATA: WS_CHAR(13).
  PERFORM BDC_DYNPRO USING 'MP001400' '2000'.
  PERFORM BDC_FIELD USING 'P0014-LGART' $LGART.
  WRITE $BETRG CURRENCY CALC_CURRENCY TO WS_CHAR.
  PERFORM BDC_FIELD USING 'Q0014-BETRG' WS_CHAR.
  PERFORM BDC_FIELD USING 'P0014-WAERS' $WAERS.
  WRITE $DATE TO H_DATE.
  PERFORM BDC_FIELD USING 'P0014-BEGDA' H_DATE.
  PERFORM BDC_FIELD USING 'BDC_OKCODE' '=UPD'.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM BDC_DYNPRO                                               *
*---------------------------------------------------------------------*
FORM BDC_DYNPRO USING PROGRAM DYNPRO.
  CLEAR BDCDATA.
  BDCDATA-PROGRAM = PROGRAM.
  BDCDATA-DYNPRO = DYNPRO.
  BDCDATA-DYNBEGIN = 'X'.
  APPEND BDCDATA.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM BDC-FIELD                                                *
*---------------------------------------------------------------------*
FORM BDC_FIELD USING FNAM FVAL.
  CLEAR BDCDATA.
  BDCDATA-FNAM = FNAM.
  BDCDATA-FVAL = FVAL.
  APPEND BDCDATA.
ENDFORM.

*
