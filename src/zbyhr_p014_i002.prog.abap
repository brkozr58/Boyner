*&---------------------------------------------------------------------*
*& Include          ZBYHR_P014_I002
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  CONCATENATE 'HR_' abkrs '_SNDK' INTO mapname.
  CALL FUNCTION 'UPLOAD'
    EXPORTING
      filename            = 'A:\SANDIK.TXT'
      filetype            = 'ASC'
    IMPORTING
      filesize            = fsize
      act_filename        = fname
      act_filetype        = ftype
    TABLES
      data_tab            = int_tab
    EXCEPTIONS
      conversion_error    = 1
      invalid_table_width = 2
      invalid_type        = 3.

  WRITE: / 'Yard.Sandığı bilgisi sisteme aktarıldı.'.
  WRITE: / 'Aktarımı tamamlamak için lütfen bu satıra çift tıklayın ve'.
  WRITE: / mapname, ' isimiyle oluşturulmuş oturumu çalıştırın.'.

  IF sy-subrc NE 0.  EXIT.  ENDIF.

  CALL FUNCTION 'BDC_OPEN_GROUP'
    EXPORTING
      client = sy-mandt
      group  = mapname
      user   = sy-uname.
  WRITE date DD/MM/YYYY TO tarih.
  LOOP AT int_tab.
* inserted by koksal.
    CLEAR :
        xkatki_payi,
        xborc_g_odeme,
        xder_yil_aidati,
        xder_gir_aidati,
        xsan_gir_aidati,
        xtopl_birikim,
        xnema_birikim,
        xson_alinan_borc,
        xkalan_borc.

    xkatki_payi = int_tab-katki_payi.
    xborc_g_odeme = int_tab-borc_g_odeme.
    xder_yil_aidati = int_tab-der_yil_aidati.
    xder_gir_aidati  = int_tab-der_gir_aidati.
    xsan_gir_aidati = int_tab-san_gir_aidati.
    xtopl_birikim = int_tab-topl_birikim.
    xnema_birikim = int_tab-nema_birikim.
    xson_alinan_borc  = int_tab-son_alinan_borc.
    xkalan_borc  = int_tab-kalan_borc.

    REPLACE ',' WITH '.' INTO xborc_g_odeme.
    REPLACE ',' WITH '.' INTO xder_yil_aidati.
    REPLACE ',' WITH '.' INTO xkatki_payi.
    REPLACE ',' WITH '.' INTO xder_gir_aidati.
    REPLACE ',' WITH '.' INTO xsan_gir_aidati.
    REPLACE ',' WITH '.' INTO xtopl_birikim.
    REPLACE ',' WITH '.' INTO xnema_birikim.
    REPLACE ',' WITH '.' INTO xson_alinan_borc.
    REPLACE ',' WITH '.' INTO xkalan_borc.

    IF xkatki_payi > 0 .
      PERFORM katki_payi.
    ENDIF.
    IF xborc_g_odeme > 0 .
      PERFORM borc_g_odeme.
    ENDIF.
    IF xder_yil_aidati > 0 .
      PERFORM der_yil_aidati.
    ENDIF.
    IF xder_gir_aidati > 0 .
      PERFORM der_gir_aidati.
    ENDIF.
    IF xsan_gir_aidati > 0 .
      PERFORM san_gir_aidati.
    ENDIF.
    IF xtopl_birikim > 0 OR
       xson_alinan_borc > 0 OR
       xkalan_borc > 0 OR
       xnema_birikim > 0.
      PERFORM topl_birikim.
    ENDIF.

  ENDLOOP.
  CALL FUNCTION 'BDC_CLOSE_GROUP'.
ENDFORM.
FORM katki_payi.
  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '0015'.
  PERFORM yaz USING 'RP50G-SUBTY' '3502'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP001500' '2000'.
  PERFORM yaz USING 'Q0015-BETRG' int_tab-katki_payi.
  PERFORM yaz USING 'P0015-LGART' '3502'.
  PERFORM yaz USING 'P0015-BEGDA' tarih.
  PERFORM yaz USING 'P0015-WAERS' 'TRY'.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
ENDFORM.
FORM borc_g_odeme.
  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '0015'.
  PERFORM yaz USING 'RP50G-SUBTY' '3501'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP001500' '2000'.
  PERFORM yaz USING 'Q0015-BETRG' int_tab-borc_g_odeme.
  PERFORM yaz USING 'P0015-LGART' '3501'.
  PERFORM yaz USING 'P0015-BEGDA' tarih.
  PERFORM yaz USING 'P0015-WAERS' 'TRY'.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
ENDFORM.
FORM der_yil_aidati.
  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '0015'.
  PERFORM yaz USING 'RP50G-SUBTY' '3504'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP001500' '2000'.
  PERFORM yaz USING 'Q0015-BETRG' int_tab-der_yil_aidati.
  PERFORM yaz USING 'P0015-LGART' '3504'.
  PERFORM yaz USING 'P0015-BEGDA' tarih.
  PERFORM yaz USING 'P0015-WAERS' 'TRY'.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
ENDFORM.
FORM der_gir_aidati.
  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '0015'.
  PERFORM yaz USING 'RP50G-SUBTY' '3505'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP001500' '2000'.
  PERFORM yaz USING 'Q0015-BETRG' int_tab-der_gir_aidati.
  PERFORM yaz USING 'P0015-LGART' '3505'.
  PERFORM yaz USING 'P0015-BEGDA' tarih.
  PERFORM yaz USING 'P0015-WAERS' 'TRY'.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.
  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
ENDFORM.
FORM san_gir_aidati.

  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '0015'.
  PERFORM yaz USING 'RP50G-SUBTY' '3503'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP001500' '2000'.
  PERFORM yaz USING 'Q0015-BETRG' int_tab-san_gir_aidati.
  PERFORM yaz USING 'P0015-LGART' '3503'.
  PERFORM yaz USING 'P0015-BEGDA' tarih.
  PERFORM yaz USING 'P0015-WAERS' 'TRY'.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.
ENDFORM.
FORM deg USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program = program.
  bdcdata-dynpro = dynpro.
  bdcdata-dynbegin = 'X'.
  APPEND bdcdata.
ENDFORM.
FORM yaz USING fnam fval.
  CLEAR bdcdata.
  bdcdata-fnam = fnam.
  bdcdata-fval = fval.
  APPEND bdcdata.
ENDFORM.
FORM topl_birikim.
  w_tarih = ''.
  SELECT begda FROM pa0000 INTO w_tarih
      WHERE pernr = int_tab-sap_sicil_no
        AND ( massn = '01' OR massn = '12' OR massn = '19' )
      ORDER BY begda ASCENDING.
  ENDSELECT.
  WRITE w_tarih DD/MM/YYYY TO ww_tarih.
  CLEAR w_zzprf .
  SELECT * FROM pa9910
      WHERE pernr = int_tab-sap_sicil_no.
    WRITE pa9910-zzprf TO w_zzprf.
  ENDSELECT.

  PERFORM deg USING 'SAPMP50A' '1000'.
  PERFORM yaz USING 'RP50G-PERNR' int_tab-sap_sicil_no .
  PERFORM yaz USING 'RP50G-CHOIC' '9910'.
  PERFORM yaz USING 'BDC_OKCODE' '=INS'.
  PERFORM deg USING 'MP991000' '2000'.
  PERFORM yaz USING 'P9910-BEGDA' ww_tarih.
  PERFORM yaz USING 'P9910-BRKIM' int_tab-topl_birikim.
  PERFORM yaz USING 'P9910-ZZNEMA' int_tab-nema_birikim.
  PERFORM yaz USING 'P9910-ALBRC' int_tab-son_alinan_borc.
  PERFORM yaz USING 'P9910-KLBRC' int_tab-kalan_borc.
*  PERFORM yaz USING 'P9910-WAERS' 'TRY'.
*  PERFORM yaz USING 'P9910-ZZPRF' w_zzprf.
  PERFORM yaz USING 'BDC_OKCODE' '=UPD'.

  CALL FUNCTION 'BDC_INSERT'
    EXPORTING
      tcode     = 'PA30'
    TABLES
      dynprotab = bdcdata.
  REFRESH bdcdata.

ENDFORM.                               " TOPL_BIRIKIM
