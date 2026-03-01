*&---------------------------------------------------------------------*
*& Include          ZBYHR_P003_I003
*&---------------------------------------------------------------------*


FORM get_file .
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
*     program_name  = syst-cprog
*     dynpro_number = syst-dynnr
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.

ENDFORM.                    " GET_FILE
*&-------------------------------------------------------------------*
*&      Form  GET_MAIN_DATA
*&-------------------------------------------------------------------*
FORM get_main_data .

  REFRESH : gt_main[].
*  TRANSLATE p_file TO UPPER CASE.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_field_seperator    = 'X'
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_excl
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF gt_excl[] IS NOT INITIAL.
    SELECT * FROM pa0001 INTO TABLE gt_0001
            WHERE begda LE sy-datum AND endda GE sy-datum.
  ENDIF.

  DATA : lv_int TYPE i.

  LOOP AT gt_excl.

    lv_int = strlen( gt_excl-bkodu ).
    IF lv_int EQ 1.
      CONCATENATE '0' gt_excl-bkodu INTO gt_excl-bkodu.
    ENDIF.
    CLEAR lv_int.

    lv_int = strlen( gt_excl-kanun ).
    IF  lv_int EQ 4.
      CONCATENATE '0 ' gt_excl-kanun INTO gt_excl-kanun.
    ENDIF.


    MOVE-CORRESPONDING : gt_excl TO gt_main.
    CLEAR:gt_0001.
    READ TABLE gt_0001 WITH KEY pernr = gt_excl-pernr.
    gt_main-ename = gt_0001-ename.
    IF gt_excl-kanun EQ '06111'.
      gt_main-is_ay = '99'.
    ENDIF.
    APPEND gt_main.CLEAR gt_main.
  ENDLOOP.
ENDFORM.                    " GET_MAIN_DATA
*&-------------------------------------------------------------------*
*&      Form  CREATE_FIELDCAT
*&-------------------------------------------------------------------*
FORM create_fieldcat .

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_MAIN'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gt_fieldcat INTO gs_fieldcat.
    CASE gs_fieldcat-fieldname.
      WHEN 'SSGRP'.
        gs_fieldcat-seltext_l = 'SGK Grubu'.
        gs_fieldcat-seltext_m = 'SGK Grubu'.
        gs_fieldcat-seltext_s = 'SGK Grubu'.
      WHEN 'BKODU'.
        gs_fieldcat-seltext_l = 'Belge Kodu'.
        gs_fieldcat-seltext_m = 'Belge Kodu'.
        gs_fieldcat-seltext_s = 'Belge Kodu'.
      WHEN 'MTEXT'.
        gs_fieldcat-seltext_l = 'Mesaj'.
        gs_fieldcat-seltext_m = 'Mesaj'.
        gs_fieldcat-seltext_s = 'Mesaj'.
      WHEN 'SPTXD'.
        gs_fieldcat-seltext_l = 'Özel Vergi Muafiyeti'.
        gs_fieldcat-seltext_m = 'Özel Vergi Muafiyeti'.
        gs_fieldcat-seltext_s = 'Özel Vergi '.
        gs_fieldcat-outputlen = 40 .
      WHEN 'MARK'.
        gs_fieldcat-no_out   = 'X'.
    ENDCASE.
    MODIFY gt_fieldcat FROM gs_fieldcat.
    CLEAR gs_fieldcat.
  ENDLOOP.

ENDFORM.                    " CREATE_FIELDCAT
*&------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&------------------------------------------------------------------*
FORM display_alv .
  CHECK gt_main[] IS NOT INITIAL .
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-zebra      = 'X'.
  gs_layout-box_fieldname  = 'MARK'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'GUI'
      i_callback_user_command  = 'COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_main[]
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV
*&-----------------------------------------------------------------*
*&      Form  gui
*&-----------------------------------------------------------------*
FORM gui USING pf_ex.
  CASE 'X'.
    WHEN p_del.
      SET PF-STATUS 'GUI2' .
    WHEN p_ins.
      SET PF-STATUS 'GUI' .
    WHEN p_upd.
      SET PF-STATUS 'GUI' .
  ENDCASE.
  .
ENDFORM .                    "gui
*&-----------------------------------------------------------------*
*&      Form  COMMAND
*&-----------------------------------------------------------------*
FORM command USING c_xpa1 LIKE sy-ucomm c_xpa2 TYPE slis_selfield.
  CASE c_xpa1 .
    WHEN 'BATCH' .
      PERFORM batch.
    WHEN '&DELETE'.
      PERFORM batch.

  ENDCASE .
  c_xpa2-refresh = 'X' .

ENDFORM.                    "COMMAND
*&-------------------------------------------------------------------*
*&      Form  BATCH
*&-------------------------------------------------------------------*
FORM batch .
  CLEAR: gt_mtab[].
  SELECT * FROM pa0769 INTO TABLE gt_0769.
  SORT gt_0769 BY begda DESCENDING.

  IF p_del EQ 'X' AND zbyhr_t024-f0769 NE 'X'.

    MESSAGE '769 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.

  ELSE.
    LOOP AT gt_main WHERE mark EQ 'X' .
      PERFORM create_batch.
      MODIFY gt_main.
      CLEAR : gt_main.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " BATCH
*&-------------------------------------------------------------------*
*&      Form  CREATE_BATCH
*&-------------------------------------------------------------------*
FORM create_batch .

  DATA:ls_0769 TYPE p0769.
  DATA:lv_operation TYPE pspar-actio.
  CLEAR: gt_0769.
  CASE 'X'.
    WHEN p_del.lv_operation = 'DEL'.
    WHEN p_ins.lv_operation = 'INS'.
    WHEN p_upd.lv_operation = 'COP'.
  ENDCASE.

  READ TABLE gt_0769 WITH KEY pernr = gt_main-pernr.
  IF ( sy-subrc EQ 0 AND lv_operation = 'DEL') OR lv_operation = 'INS'
      OR lv_operation = 'COP'.
    IF lv_operation = 'DEL'.
      MOVE-CORRESPONDING:gt_0769 TO ls_0769.
    ELSE.
      READ TABLE gt_0769 WITH KEY pernr = gt_main-pernr
                                  endda = '99991231'.
      IF sy-subrc EQ 0.
        MOVE-CORRESPONDING:gt_0769 TO ls_0769.
      ENDIF.

      IF lv_operation = 'COP'.
*        MOVE-CORRESPONDING:gt_0769 TO ls_0769.
        IF gt_main-kanun IS NOT INITIAL . ls_0769-kanun = gt_main-kanun. ENDIF.
        IF gt_main-sskod IS NOT INITIAL . ls_0769-sskod = gt_main-sskod. ENDIF.
        IF gt_main-is_ay IS NOT INITIAL . ls_0769-is_ay = gt_main-is_ay. ENDIF.
        IF gt_main-ssgrp IS NOT INITIAL . ls_0769-ssgrp = gt_main-ssgrp. ENDIF.
        IF gt_main-bkodu IS NOT INITIAL . ls_0769-bkodu = gt_main-bkodu. ENDIF.
        IF gt_main-sskno IS NOT INITIAL . ls_0769-sskno = gt_main-sskno. ENDIF.
        IF gt_main-asucc IS NOT INITIAL . ls_0769-asucc = gt_main-asucc. ENDIF.
        IF gt_main-sptxd IS NOT INITIAL . ls_0769-sptxd = gt_main-sptxd. ENDIF.
        IF gt_main-child IS NOT INITIAL . ls_0769-child = gt_main-child. ENDIF.
        IF gt_main-disab IS NOT INITIAL . ls_0769-disab = gt_main-disab. ENDIF.
        IF gt_main-glrve IS NOT INITIAL . ls_0769-glrve = gt_main-glrve. ENDIF.
        IF gt_main-begda IS NOT INITIAL . ls_0769-begda = gt_main-begda. ENDIF.

      ELSE.
        MOVE-CORRESPONDING:gt_main TO ls_0769.
      ENDIF.
    ENDIF.

    MOVE: '0769'        TO ls_0769-infty ,
          '99991231'    TO ls_0769-endda .

"lv_operation MOD olarak atınca sınırlama yapmadığı için INS'e çevirildi.
" Yukarıda müdahale edilmedi çünkü lv_operation MOD ve INS farklı formatta doluyor.
    IF lv_operation = 'MOD'.
      lv_operation = 'INS'.
    ENDIF.

    CALL FUNCTION 'HR_EMPLOYEE_ENQUEUE'
      EXPORTING
        number = ls_0769-pernr.
    CALL FUNCTION 'HR_INFOTYPE_OPERATION'
      EXPORTING
        infty         = ls_0769-infty
        number        = ls_0769-pernr
        validityend   = ls_0769-endda
        validitybegin = ls_0769-begda
        record        = ls_0769
        operation     = lv_operation
        tclas         = 'A'
        dialog_mode   = '0'
        nocommit      = nocommit
      IMPORTING
        return        = return
        key           = key
      EXCEPTIONS
        OTHERS        = 0.

    IF sy-subrc <> 0.
      gt_main-mtext = 'Başarılı'.
    ENDIF.
    IF return IS NOT INITIAL. "başarısız
      gt_main-mtext = return-message.
    ELSE.
      gt_main-mtext = 'Başarılı'.
    ENDIF.

    CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
      EXPORTING
        number = ls_0769-pernr.
  ELSE.
    gt_main-mtext = 'Kayıt Bulunamadı'.
  ENDIF.

ENDFORM.                    " CREATE_BATCH
*&----------------------------------------------------------------*
*&      Form  CHECK_MESSAGE
*&----------------------------------------------------------------*
FORM check_message .

  DATA: lv_msgno   LIKE sy-msgno,
        lv_message LIKE message.

  LOOP AT gt_mtab.
    lv_msgno = gt_mtab-msgnr.
    CALL FUNCTION 'WRITE_MESSAGE'
      EXPORTING
        msgid = gt_mtab-msgid
        msgno = lv_msgno
        msgty = gt_mtab-msgtyp
        msgv1 = gt_mtab-msgv1
        msgv2 = gt_mtab-msgv2
        msgv3 = gt_mtab-msgv3
        msgv4 = gt_mtab-msgv4
        msgv5 = space
      IMPORTING
        messg = lv_message.

    WRITE lv_message-msgtx TO gt_main-mtext.
    CLEAR lv_message .
  ENDLOOP.

ENDFORM.                    " CHECK_MESSAGE
*&----------------------------------------------------------------*
*&      Form  CREATE_ICON_FOR_BUTTON
*&----------------------------------------------------------------*
*FORM create_icon_for_button .
*  DATA: icon_name       TYPE iconname,
*        button_text(50) TYPE c,
*        quickinfo       LIKE smp_dyntxt-quickinfo,
*        icon_str(255)   TYPE c.
*
** Setup button 1 (Fiscal year)
*  icon_name = 'ICON_XLS'.    " 'ICON_DISPLAY_MORE'.
*
*  button_text = 'Şablon Excel Oluştur'.
*
*  CALL FUNCTION 'ICON_CREATE'
*    EXPORTING
*      name   = icon_name
*      text   = button_text
*    IMPORTING
*      result = icon_str
*    EXCEPTIONS
*      OTHERS = 0. "not interested in errors
*  but1 = icon_str.
*
*ENDFORM.                    " CREATE_ICON_FOR_BUTTON
*&-------------------------------------------------------------------*
*&      Form  CREATE_EXCEL
*&-------------------------------------------------------------------*
FORM create_excel .
  gv_outer_index = sy-index .

*--For the first loop, Excel is initiated and one new sheet is added
  CREATE OBJECT gs_excel 'EXCEL.APPLICATION'.
  SET PROPERTY OF gs_excel 'Visible' = 1 .
  GET PROPERTY OF gs_excel 'Workbooks' = gs_wbooklist .
  GET PROPERTY OF gs_wbooklist 'Application' = gs_application .
  SET PROPERTY OF gs_application 'SheetsInNewWorkbook' = 1 .
  CALL METHOD OF gs_wbooklist 'Add' = gs_wbook.
  GET PROPERTY OF gs_application 'ActiveSheet' = gs_activesheet .
  SET PROPERTY OF gs_activesheet 'Name' = gv_sheet_name .
  gv_line_cntr = 1 . "line counter
ENDFORM.                    " CREATE_EXCEL
*&-------------------------------------------------------------------*
*&      Form  FILL_HEADER
*&-------------------------------------------------------------------*
FORM fill_header .
  PERFORM fill_cell USING 1  1  1 'Personel Numarası' .
  PERFORM fill_cell USING 1  2  1 'Başlangıç Tarihi'.
  PERFORM fill_cell USING 1  3  1 'Kanun Numarası'.
  PERFORM fill_cell USING 1  4  1 'SGK Grubu'.
  PERFORM fill_cell USING 1  5  1 'Belge Kodu'.
*  PERFORM fill_cell USING 1  6  1 'Bitiş Tarihi'.
*  PERFORM fill_cell USING 1  7  1 'SGK Numarası'.
*  PERFORM fill_cell USING 1  8  1 'İşsiz Ay'.
*  PERFORM fill_cell USING 1  9  1 'Asgari Ücretli Çalışan'.
*  PERFORM fill_cell USING 1  10 1 'SPTXD_Y'.
*  PERFORM fill_cell USING 1  11 1 'SPTXD_N'.
*  PERFORM fill_cell USING 1  12 1 'Engellilik Derecesi'.
*  PERFORM fill_cell USING 1  13 1 'Engellilik Oranı'.
ENDFORM.                    " FILL_HEADER
*&-------------------------------------------------------------------*
*&      Form  FILL_CELL
*&-------------------------------------------------------------------*
FORM fill_cell  USING   i j bold val .
  CALL METHOD OF gs_excel 'Cells' = h_zl
    EXPORTING
    #1 = i
    #2 = j.
  SET PROPERTY OF h_zl 'Value' = val .
  GET PROPERTY OF h_zl 'Font'  = h_f .
  SET PROPERTY OF h_f  'Bold'  = bold.
  SET PROPERTY OF h_f  'Name'  = 'Arial' .
  SET PROPERTY OF h_f  'Color' = -10477568.
  SET PROPERTY OF h_f  'Size'  = 10.

  SET PROPERTY OF h_zl 'HorizontalAlignment' = -4108 .

ENDFORM.                    " fill_cell
*&-------------------------------------------------------------------*
*& Form get_0769_data
*&-------------------------------------------------------------------*
FORM get_0769_data .

  IF p_del EQ 'X' AND zbyhr_t024-f0769 NE 'X'.
    MESSAGE '769 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    CHECK 1 = 2 .
  ENDIF .

  IF p_begda IS INITIAL .
    p_begda = sy-datum.
  ENDIF.

  IF p_endda IS INITIAL .
    p_endda = sy-datum.
  ENDIF.

  SELECT * FROM pa0769 INTO TABLE gt_0769
        WHERE pernr IN s_pernr
          AND begda LE p_endda
          AND endda GE p_begda
          AND aedtm EQ p_aedtm
          AND uname EQ p_uname.


  IF gt_0769[] IS NOT INITIAL.
    SELECT * FROM pa0001 INTO TABLE gt_0001
            WHERE pernr IN s_pernr
              AND werks IN s_werks AND btrtl IN s_btrtl
              AND persk IN s_persk AND persg IN s_persg
              AND begda LE sy-datum AND endda GE sy-datum.
  ENDIF.

  LOOP AT gt_0769.
    MOVE-CORRESPONDING: gt_0769 TO gt_main.
    CLEAR: gt_0001.
    READ TABLE gt_0001 WITH KEY pernr = gt_main-pernr.
    IF sy-subrc EQ 0.
      AUTHORITY-CHECK OBJECT 'P_ORGIN'
       ID 'INFTY' FIELD '0001'
       ID 'PERSA' FIELD gt_0001-werks
       ID 'PERSG' FIELD gt_0001-persg
       ID 'PERSK' FIELD gt_0001-persk
       ID 'VDSK1' FIELD gt_0001-vdsk1.
      IF sy-subrc <> 0.
        DELETE gt_0769 WHERE pernr = gt_main-pernr.
        CONTINUE.
      ENDIF.

      gt_main-ename = gt_0001-ename.
      APPEND gt_main.
    ENDIF.
    CLEAR gt_main.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EXAMPLE_EXCELL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM example_excell .

  DATA : subrc TYPE sy-subrc .
  DATA : fname(128) .
  DATA : BEGIN OF  file OCCURS 0 ,
           field(400) ,
         END OF file .
  DATA: ld_filename TYPE string,
        ld_path     TYPE string,
        ld_fullpath TYPE string,
        ld_result   TYPE i,

        l_filename  TYPE string.
*--
  CASE sy-ucomm.
    WHEN 'FC01' .
      l_filename = 'orneksablon.xls' .
      CONCATENATE
                 'Personel Numarasi'
                 'Başlangıç tarihi'
                 'Bitiş Tarihi'
                 'Kanun Numarasi'
                 'Sosyal Güvenlik Tipi '
                 'SGK Grubu'
                 'Belge Kodu'
                 'SGK Numarası'
                 'İşsiz Ay'
                 'Asgari Ücretli Çalışan'
                 'Özel Vergi Muafiyeti '
                 'Çocuk Sayısı '
*                 'Aylık Vergi İnd Yok'
                 'Engellilik Derecesi'
                 'Engellilik Oranı'
*                 'İşsiz Ay'
      INTO file-field SEPARATED BY con_tab .
      APPEND file .

      CONCATENATE
                 '0010007'
                 '12.12.2013'
                 '31.12.9999'
                 '0053'
                 '1'
                 '01'
                 '01'
                 '34574140862'
                 '99'
                 'X'
                 '1'
*                 '1'
                 '1'
                 'T1'
                 '50'
*                 ''

      INTO file-field SEPARATED BY con_tab .
      APPEND file .
*
      CALL METHOD cl_gui_frontend_services=>file_save_dialog
        EXPORTING
*         window_title      = ' '
          default_extension = 'XLS'
          default_file_name = l_filename
          initial_directory = 'C:\'
        CHANGING
          filename          = ld_filename
          path              = ld_path
          fullpath          = ld_fullpath
          user_action       = ld_result.

      CHECK ld_result EQ '0'.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          filename              = ld_fullpath
          filetype              = 'ASC'
*         APPEND                = 'X'
          write_field_separator = 'X'
          confirm_overwrite     = 'X'
        TABLES
          data_tab              = file[]     "need to declare and
        EXCEPTIONS
          file_open_error       = 1
          file_write_error      = 2
          OTHERS                = 3.
*
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update .

  REFRESH : gt_main[].
*  TRANSLATE p_file TO UPPER CASE.
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      i_field_seperator    = 'X'
      i_line_header        = 'X'
      i_tab_raw_data       = it_raw
      i_filename           = p_file
    TABLES
      i_tab_converted_data = gt_excl
    EXCEPTIONS
      conversion_failed    = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF gt_excl[] IS NOT INITIAL.
    SELECT * FROM pa0001 INTO TABLE gt_0001
            WHERE begda LE sy-datum AND endda GE sy-datum.
  ENDIF.

  DATA : lv_int TYPE i.

  LOOP AT gt_excl.

    lv_int = strlen( gt_excl-bkodu ).
    IF lv_int EQ 1.
      CONCATENATE '0' gt_excl-bkodu INTO gt_excl-bkodu.
    ENDIF.
    CLEAR lv_int.

    lv_int = strlen( gt_excl-kanun ).
    IF  lv_int EQ 4.
      CONCATENATE '0 ' gt_excl-kanun INTO gt_excl-kanun.
    ENDIF.


    MOVE-CORRESPONDING : gt_excl TO gt_main.
    CLEAR:gt_0001.
    READ TABLE gt_0001 WITH KEY pernr = gt_excl-pernr.
    gt_main-ename = gt_0001-ename.
    IF gt_excl-kanun EQ '06111'.
      gt_main-is_ay = '99'.
    ENDIF.
    APPEND gt_main.CLEAR gt_main.
  ENDLOOP.

ENDFORM.
