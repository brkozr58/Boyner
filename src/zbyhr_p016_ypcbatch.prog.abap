*----------------------------------------------------------------------*
*   INCLUDE ZBYHR_P016_YPCBATCH                                              *
*----------------------------------------------------------------------*
*
* =================================================================== *
* Erstellung der Batch-Input Mappe für die Abfindung
* =================================================================== *
*---------------------------------------------------------------------*
*  form batch_open.
*---------------------------------------------------------------------*
FORM batch_open USING $bname.
  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client = sy-mandt
      group  = $bname
      user   = sy-uname.
ENDFORM.

*---------------------------------------------------------------------*
*  form batch_input.
*---------------------------------------------------------------------*
FORM batch_input USING $lgart $betrg $pernr
                       $hire  $fire  $date $waers.
*  perform batch_open.
  PERFORM d1000 USING $lgart $pernr $hire $fire.
  PERFORM bi_insert USING $lgart $betrg $waers $date.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
*  call function 'BDC_CLOSE_GROUP'.
ENDFORM.

*---------------------------------------------------------------------*
*  form batch_input.
*---------------------------------------------------------------------*
FORM batch_input_0014 USING $lgart $betrg $pernr
                            $hire  $fire  $date $waers.
*  perform batch_open.
  PERFORM d1000_0014 USING $lgart $pernr $hire $fire.
  PERFORM bi_insert_0014 USING $lgart $betrg $waers $date.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
*  call function 'BDC_CLOSE_GROUP'.
ENDFORM.


*---------------------------------------------------------------------*
*       Einstiegsbild PA30                                            *
*---------------------------------------------------------------------*
*  form d1000.
*---------------------------------------------------------------------*
FORM d1000 USING $lgart $pernr $hire $fire.
  REFRESH bdcdata.

  PERFORM bdc_dynpro USING 'SAPMP50A' '1000'.
  PERFORM bdc_field USING 'RP50G-PERNR' $pernr.
  PERFORM bdc_field USING 'RP50G-CHOIC' '0015'.
*  perform bdc_field using 'RP50G-SUBTY' $lgart.
  WRITE $hire TO h_date.
  PERFORM bdc_field USING 'RP50G-BEGDA' h_date.
*  write $fire to h_date.
*  perform bdc_field using 'RP50G-ENDDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=INS'.
ENDFORM.

*---------------------------------------------------------------------*
*       Einstiegsbild PA30                                            *
*---------------------------------------------------------------------*
*  form d1000.
*---------------------------------------------------------------------*
FORM d1000_0014 USING $lgart $pernr $hire $fire.
  REFRESH bdcdata.

  PERFORM bdc_dynpro USING 'SAPMP50A' '1100'.
  PERFORM bdc_field USING 'RP50G-PERNR' $pernr.
  PERFORM bdc_field USING 'RP50G-CHOIC' '0014'.
  PERFORM bdc_field USING 'RP50G-SUBTY' $lgart.
*  write $hire to h_date.
*  perform bdc_field using 'RP50G-BEGDA' h_date.
*  write $fire to h_date.
*  perform bdc_field using 'RP50G-ENDDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=INS'.
ENDFORM.

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM bi_insert USING $lgart $betrg $waers $date.
  DATA: ws_char(13).
  PERFORM bdc_dynpro USING 'MP001500' '2000'.
  PERFORM bdc_field USING 'P0015-LGART' $lgart.
  WRITE $betrg CURRENCY calc_currency TO ws_char.
  PERFORM bdc_field USING 'Q0015-BETRG' ws_char.
  PERFORM bdc_field USING 'P0015-WAERS' $waers.
  WRITE $date TO h_date.
  PERFORM bdc_field USING 'P0015-BEGDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=UPD'.
ENDFORM.

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM bi_insert_0014 USING $lgart $betrg $waers $date.
  DATA: ws_char(13).
  PERFORM bdc_dynpro USING 'MP001400' '2000'.
  PERFORM bdc_field USING 'P0014-LGART' $lgart.
  WRITE $betrg CURRENCY calc_currency TO ws_char.
  PERFORM bdc_field USING 'Q0014-BETRG' ws_char.
  PERFORM bdc_field USING 'P0014-WAERS' $waers.
  WRITE $date TO h_date.
  PERFORM bdc_field USING 'P0014-BEGDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=UPD'.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM BDC_DYNPRO                                               *
*---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program = program.
  bdcdata-dynpro = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.


*---------------------------------------------------------------------*
*       FORM BDC-FIELD                                                *
*---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.

*
