*----------------------------------------------------------------------*
*   INCLUDE HTRBATCH                                              *
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
ENDFORM.                    "BATCH_OPEN

*---------------------------------------------------------------------*
*  form batch_input.
*---------------------------------------------------------------------*
FORM batch_input USING $lgart $betrg $pernr
                       $hire  $fire  $date $waers.
  PERFORM d1000 USING $lgart $pernr $hire $fire.
  PERFORM bi_insert USING $lgart $betrg $waers $date.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
ENDFORM.                    "BATCH_INPUT

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
ENDFORM.                    "BATCH_INPUT_0014


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
  PERFORM bdc_field USING 'RP50G-SUBTY' $lgart.
  WRITE $hire TO h_date.
  PERFORM bdc_field USING 'RP50G-BEGDA' h_date.
  WRITE $fire TO h_date.
  PERFORM bdc_field USING 'RP50G-ENDDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=INS'.
ENDFORM.                                                    "D1000

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
ENDFORM.                                                    "D1000_0014

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM bi_insert USING $lgart $betrg $waers $date.
  DATA: ws_char(13).
  PERFORM bdc_dynpro USING 'MP001500' '2000'.
  PERFORM bdc_field USING 'P0015-LGART' $lgart.
  WRITE $betrg CURRENCY h_curr TO ws_char.
  PERFORM bdc_field USING 'Q0015-BETRG' ws_char.
  PERFORM bdc_field USING 'P0015-WAERS' $waers.
  WRITE $date TO h_date.
  PERFORM bdc_field USING 'P0015-BEGDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=UPD'.
ENDFORM.                    "BI_INSERT

*---------------------------------------------------------------------*
*  form bi_insert.
*---------------------------------------------------------------------*
FORM bi_insert_0014 USING $lgart $betrg $waers $date.
  DATA: ws_char(13).
  PERFORM bdc_dynpro USING 'MP001400' '2000'.
  PERFORM bdc_field USING 'P0014-LGART' $lgart.
  WRITE $betrg CURRENCY h_curr TO ws_char.
  PERFORM bdc_field USING 'Q0014-BETRG' ws_char.
  PERFORM bdc_field USING 'P0014-WAERS' $waers.
  WRITE $date TO h_date.
  PERFORM bdc_field USING 'P0014-BEGDA' h_date.
  PERFORM bdc_field USING 'BDC_OKCODE' '=UPD'.
ENDFORM.                    "BI_INSERT_0014


*---------------------------------------------------------------------*
*       FORM BDC_DYNPRO                                               *
*---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program = program.
  bdcdata-dynpro = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO


*---------------------------------------------------------------------*
*       FORM BDC-FIELD                                                *
*---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.                    "BDC_FIELD

*
*&---------------------------------------------------------------------*
*&      Form  D1000_0776
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_$LGART  text
*      -->P_$PERNR  text
*      -->P_$HIRE  text
*      -->P_$FIRE  text
*----------------------------------------------------------------------*

FORM batch_input_0776 USING $kennz $betrg $pernr
                       $hire  $fire   $waers.
*  perform batch_open.
  PERFORM d1000_0776 USING  $pernr .
  PERFORM bi_insert_0776 USING $kennz $betrg $waers $hire $fire .
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
*  call function 'BDC_CLOSE_GROUP'.
ENDFORM.                    "BATCH_INPUT_0776

*___FORM D1000_0776 ____________________________*
FORM d1000_0776 USING  $pernr.
  REFRESH bdcdata.

  PERFORM bdc_dynpro USING 'SAPMP50A' '1000'.
  PERFORM bdc_field USING 'RP50G-PERNR' $pernr.
  PERFORM bdc_field USING 'RP50G-CHOIC' '0776'.
  PERFORM bdc_field USING 'RP50G-SUBTY' '02'.
  PERFORM bdc_field USING 'BDC_OKCODE' '=INS'.
ENDFORM.                                                    "D1000_0776

*___FORM BI_INSERT_0776 ____________________________*

FORM bi_insert_0776 USING $kennz $betrg $waers $hire $fire.

  DATA: ws_char(21).

  PERFORM bdc_dynpro USING 'MP077600' '2001'.
  PERFORM bdc_field USING 'P0776-KENNZ' $kennz.
  WRITE $hire TO h_date.
  PERFORM bdc_field USING 'P0776-BEGDA' h_date.
  WRITE $hire TO h_edate.
  PERFORM bdc_field USING 'P0776-ENDDA' h_edate.

  WRITE $betrg CURRENCY h_curr TO ws_char.

  PERFORM bdc_field USING 'P0776-BETRG' ws_char.
  PERFORM bdc_field USING 'P0776-WAERS' $waers.

  PERFORM bdc_field USING 'BDC_OKCODE' '=UPD'.

ENDFORM.                    "BI_INSERT_0776
*&---------------------------------------------------------------------*
*&      Form  write_batchinput_776
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_batchinput_776.

  IF potkidem IS INITIAL.
    IF kidmtest IS INITIAL.
      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
        EXPORTING
          defaultoption = 'Y'
          titel         = '(0776) Kayıt Yaratılsın mı?'
          textline1     = 'Seçilen Pesoneller için Bilgi Tipi 0776 da'
          textline2     = 'Kayıt yaratmak istediğinize Emin misiniz?'
        IMPORTING
          answer        = p_confrm.

      IF p_confrm EQ 'J' OR p_confrm EQ 'Y'.
        PERFORM batch_open USING 'HR KIDEM_776'.
        LOOP AT iper.
          IF iper-ihbar LT 0.
            iper-ihbar = iper-ihbar * -1.
            MODIFY iper.
          ENDIF.
        ENDLOOP.
* BADI
        DATA: l_badi_01 TYPE REF TO if_ex_hrpaytr_kidem_01.

        CALL METHOD cl_exithandler=>get_instance
          EXPORTING
            exit_name              = ''             " beklan
            null_instance_accepted = '' " beklan
          CHANGING
            instance               = l_badi_01.

        DATA : ls_iper TYPE ptr07 .
        MOVE-CORRESPONDING iper TO ls_iper .
        CALL METHOD l_badi_01->change_values
          CHANGING
            iper = ls_iper.
*
        MOVE-CORRESPONDING ls_iper TO iper .
*        PERFORM ue_vor_batch_mappe.
        PERFORM loop_for_batch_0776.
        CALL FUNCTION 'BDC_CLOSE_GROUP'.
        MESSAGE i030 WITH 'HR KIDEM_0776'.
      ENDIF.
    ELSE.
      MESSAGE w031.
    ENDIF.
  ELSE.
    MESSAGE w037.
  ENDIF.


ENDFORM.                    " write_batchinput_776
