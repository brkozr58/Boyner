*&---------------------------------------------------------------------*
*& Report ZBYHR_P002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p002.

TABLES : sscrfields ,
         pa0001 ,
         t512t  ,
         zbyhr_t024.

*-- ekranlar
SELECTION-SCREEN BEGIN OF BLOCK blck1 WITH FRAME TITLE TEXT-h01.
  SELECTION-SCREEN BEGIN OF LINE .
    PARAMETERS :r1 RADIOBUTTON GROUP rad1  USER-COMMAND cd1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT (37) TEXT-101 FOR FIELD r1 .
  SELECTION-SCREEN END OF LINE .
  SELECTION-SCREEN BEGIN OF LINE .
    PARAMETERS :r2 RADIOBUTTON GROUP rad1.
    SELECTION-SCREEN COMMENT (27) TEXT-102 FOR FIELD r2 .
  SELECTION-SCREEN END OF LINE .
  SELECTION-SCREEN BEGIN OF LINE .
    PARAMETERS :r3 RADIOBUTTON GROUP rad1.
    SELECTION-SCREEN COMMENT (20) TEXT-103 FOR FIELD r3 .
  SELECTION-SCREEN END OF LINE .
SELECTION-SCREEN END OF BLOCK  blck1 .
*
SELECTION-SCREEN BEGIN OF BLOCK blck2 WITH FRAME TITLE TEXT-h02.
  PARAMETERS :r4 RADIOBUTTON GROUP rad2  USER-COMMAND cd2 DEFAULT 'X',
              r5 RADIOBUTTON GROUP rad2.
SELECTION-SCREEN END OF BLOCK  blck2 .
*
SELECTION-SCREEN BEGIN OF BLOCK blck3 WITH FRAME TITLE TEXT-h03.
  PARAMETERS : p_file LIKE rlgrap-filename MODIF ID 100 .
SELECTION-SCREEN END OF BLOCK  blck3.
*
SELECTION-SCREEN BEGIN OF BLOCK blck4 WITH FRAME TITLE TEXT-h04.
  SELECT-OPTIONS : s_pernr FOR pa0001-pernr MODIF ID 200 ,
                  "PERSONEL ALANI
                 s_bukrs FOR pa0001-bukrs MODIF ID 200 ,
                 s_werks FOR pa0001-werks MODIF ID 200 ,
                 "PER.ALT ALANI
                 s_btrtl FOR pa0001-btrtl MODIF ID 200 ,
                 "BORDRO ALT BIRIM
                 s_abkrs FOR pa0001-abkrs MODIF ID 200 .
  PARAMETERS     : p_begda LIKE pa0001-begda OBLIGATORY  MODIF ID 200,
                   p_endda LIKE pa0001-endda OBLIGATORY MODIF ID 200,
                   p_snrlm LIKE pa0001-begda MODIF ID 300 OBLIGATORY.
  "ÜCRET TÜRÜ
  SELECT-OPTIONS : s_lgart FOR t512t-lgart   MODIF ID 200,
                     "SON DEĞİŞİKLİK TARİHİ
                     s_aedtm FOR pa0001-aedtm  MODIF ID 200,
                     "son değişikliği yapan
                     s_uname FOR pa0001-uname MODIF ID 200 .
SELECTION-SCREEN END OF BLOCK  blck4.
*---

*--
CONSTANTS:
  con_tab  TYPE c VALUE cl_abap_char_utilities=>horizontal_tab,
  con_cret TYPE c VALUE cl_abap_char_utilities=>cr_lf.
*--

*-- hr_info_type_operation
DATA : return   LIKE  bapireturn1,
       key      LIKE  bapipakey,
       nocommit LIKE  bapi_stand-no_commit.


DATA : lt_records       TYPE solix_tab.
DATA : lt_records2      TYPE TABLE OF string,
       lv_headerxstring TYPE xstring,
       lv_filelength    TYPE i.

DATA : lv_fname    TYPE  rlgrap-filename,
       lv_fnam     TYPE string,
       lv_hiredate TYPE p0000-begda,
       lv_firedate TYPE p0000-begda.

DATA : lt_line_split TYPE TABLE OF string.
DATA : ls_line_split1 TYPE string.
DATA : ls_line_split2 TYPE string.
DATA : ls_line_split3 TYPE string.
DATA : ls_line_split4 TYPE string.
DATA : lv_lenght TYPE i.
DATA : lv_lenght2 TYPE i.
DATA : lv_date(10).
DATA : gs_line2(20).
DATA : lv_tut TYPE string.

DATA : lo_excel_ref TYPE REF TO cl_fdt_xl_spreadsheet.
FIELD-SYMBOLS : <l_data> TYPE STANDARD TABLE.

*-- batch structure..
FIELD-SYMBOLS : <fs_infotype> TYPE any .
DATA : gs_inftype TYPE REF TO data.


*-- definition for excel..
DATA : raw TYPE truxs_t_text_data .


*-- global value.
DATA : gv_alvtabname   TYPE slis_tabname,
       g_layovalue(50) ,
       g_fcatvalue(50) .

*-- field symbol
FIELD-SYMBOLS : <fs_fcat>   TYPE table,
                <fs_table>  TYPE table,
                <fs_field>  TYPE any,
                <fs_layout> TYPE any.

*-- fcat tanımlamaları
DATA : gt_slis_fcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       gt_lvc_fcat  TYPE lvc_t_fcat,
       gs_lvc_fcat  TYPE lvc_s_fcat,
       gs_lvc_layo  TYPE lvc_s_layo,
       gt_top       TYPE slis_t_listheader WITH HEADER LINE.
DATA : gc_ref TYPE REF TO cl_gui_alv_grid.


*-- internal tables ..
DATA : BEGIN OF gt_excel OCCURS 0 ,
         pernr  LIKE pa0014-pernr,
         begda  LIKE pa0014-begda,
         endda  LIKE pa0014-endda,
         lgart  LIKE pa0014-lgart,
         anzhl  LIKE pa0014-anzhl,
         betrg  LIKE pa0014-betrg,
         preas  LIKE pa0014-preas,
         rtext  LIKE t530f-rtext,
         zCount TYPE numc1,
       END OF gt_excel .

DATA : BEGIN OF gt_excel2 OCCURS 0 ,
         pernr  LIKE pa0014-pernr,
         begda  LIKE pa0014-begda,
*         ENDDA LIKE PA0014-ENDDA,
         lgart  LIKE pa0014-lgart,
         anzhl  LIKE pa0014-anzhl,
         betrg  LIKE pa0014-betrg,
         preas  LIKE pa0014-preas,
         zCount TYPE numc1,
*         RTEXT LIKE T530F-RTEXT,
       END OF gt_excel2 .

DATA : BEGIN OF gt_create OCCURS 0 ,
         pernr   LIKE pa0014-pernr,
         ename   LIKE pa0001-ename,
         begda   LIKE pa0014-begda,
         endda   LIKE pa0014-endda,
         lgart   LIKE pa0014-lgart,
         lgtxt   LIKE t512t-lgtxt,
         anzhl   LIKE pa0014-anzhl,
         betrg   LIKE pa0014-betrg,
         preas   LIKE pa0014-preas,
         rtext   LIKE t530f-rtext,
         zCount  TYPE numc1,
         mark ,
         icon(4) ,
         msg     TYPE string,
       END OF gt_create .

DATA : BEGIN OF gt_create2 OCCURS 0 ,
         pernr   LIKE pa0014-pernr,
         ename   LIKE pa0001-ename,
         begda   LIKE pa0014-begda,
*         ENDDA   LIKE PA0014-ENDDA,
         lgart   LIKE pa0014-lgart,
         lgtxt   LIKE t512t-lgtxt,
         anzhl   LIKE pa0014-anzhl,
         betrg   LIKE pa0014-betrg,
*         PREAS   LIKE PA0014-PREAS,
*         RTEXT   LIKE T530F-RTEXT,
         mark ,
         icon(4) ,
         msg     TYPE string,
       END OF gt_create2 .

DATA : BEGIN OF gt_delete OCCURS 0 ,
         pernr   LIKE pa0014-pernr,
         ename   LIKE pa0001-ename,
         begda   LIKE pa0014-begda,
         endda   LIKE pa0014-endda,
         lgart   LIKE pa0014-lgart,
         lgtxt   LIKE t512t-lgtxt,
         anzhl   LIKE pa0014-anzhl,
         betrg   LIKE pa0014-betrg,
         preas   LIKE pa0014-preas,
         rtext   LIKE t530f-rtext,
         zCount  TYPE numc1,
         mark ,
         icon(4) ,
         msg     TYPE string,
       END OF gt_delete .

DATA : gt_t512t TYPE t512t OCCURS 0 WITH HEADER LINE .

DATA : t530f TYPE TABLE OF t530f,
       s_530 LIKE LINE OF  t530f.

*-- makro
*-- set layout..
DEFINE set_layout.
*
  CONCATENATE &1 '-' &2 INTO g_layovalue .
  ASSIGN (g_layovalue) TO <fs_layout>  .
  CHECK <fs_layout> IS ASSIGNED .
  <fs_layout> = &3 .
*
END-OF-DEFINITION.

*-- modify fcat
DEFINE modify_fcat .
  READ TABLE gt_lvc_fcat INTO gs_lvc_fcat WITH KEY fieldname = &1 .
  IF sy-subrc EQ 0 .
  CONCATENATE 'GS_LVC_FCAT-' &2 INTO g_fcatvalue .
  ASSIGN (g_fcatvalue) TO <fs_field> .
  <fs_field> = &3 .
  MODIFY gt_lvc_fcat FROM gs_lvc_fcat INDEX sy-tabix .
  CLEAR gs_lvc_fcat .
  ENDIF.
END-OF-DEFINITION .

*-- modify fcat text
DEFINE modify_fcat_text.
  modify_fcat : &1 'SCRTEXT_L' &2 ,  &1 'SCRTEXT_S' &3 ,
                &1 'SCRTEXT_M' &3 ,  &1 'REPTEXT'   &3 .
END-OF-DEFINITION.
*-- end of makro definitions..

*-- events..
INITIALIZATION .
*--
  SELECTION-SCREEN FUNCTION KEY 2.
  sscrfields-functxt_02 = 'Şablon Dosya'.
  PERFORM fill_data .
*--
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_filename .


AT SELECTION-SCREEN .
  PERFORM at-selection-screen USING sscrfields-ucomm .

AT SELECTION-SCREEN OUTPUT .
  PERFORM at-selection-screen-output .

START-OF-SELECTION  .
  PERFORM start-of-selection .


END-OF-SELECTION  .
  PERFORM end-of-selection .
*-- end of events


*&---------------------------------------------------------------------*
*&      Form  PF_STATUS_SET
*&---------------------------------------------------------------------*
FORM gui USING p_gui .
*--
  CASE 'X' .
    WHEN r4.
      SET PF-STATUS 'CREATE_GUI' .
    WHEN r5.
      SET PF-STATUS 'DELETE_GUI' .
*    WHEN r6.
*      SET PF-STATUS 'LIS9_GUI' .
  ENDCASE.
*--
ENDFORM .                    "gui
*&---------------------------------------------------------------------*
*&      Form  COMMAND
*&---------------------------------------------------------------------*
FORM command  USING r_ucomm LIKE sy-ucomm
                     rs_selfield TYPE slis_selfield.
*--
  IF r_ucomm EQ '&DEL' OR
     r_ucomm EQ '&CRT' OR
     r_ucomm EQ 'SINIR'.
    CASE 'X'.
      WHEN r4 .
        PERFORM run_batch.
      WHEN r5.
        PERFORM run_batch_delete .
    ENDCASE.
  ENDIF .
*--
ENDFORM.                    "COMMAND
*&---------------------------------------------------------------------*
*&      Form  AT-SELECTION-SCREEN-OUTPUT
*&---------------------------------------------------------------------*
FORM at-selection-screen-output .
*
  CASE 'X'.
    WHEN r4.
*-- seçim ekranını gizle
      LOOP AT SCREEN .
*        if screen-name   eq '%BH04012_BLOCK_1000'   or
        IF screen-name   EQ '%BH04235_BLOCK_1000'   OR
           screen-group1 EQ 200 OR screen-group1 EQ 300.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN .
      ENDLOOP.
*--
    WHEN r5. "OR r6.
      CLEAR p_file .
*-- dosya seç ekranını gizle
      LOOP AT SCREEN .
        IF screen-name   EQ '%BH03009_BLOCK_1000'  OR
           screen-group1 EQ 100.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN .
      ENDLOOP.

      IF r5 EQ 'X' .
        LOOP AT SCREEN .
          IF screen-group1 EQ 300.
            screen-active = 0.
          ENDIF.
          MODIFY SCREEN .
        ENDLOOP.
      ENDIF.

*--
  ENDCASE.
  IF  r3 EQ 'X'.
    LOOP AT SCREEN .
      IF screen-group1 EQ 900.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN .
    ENDLOOP.
  ENDIF.
  IF r1 EQ 'X' OR r2 EQ 'X'.
    LOOP AT SCREEN .
      IF screen-group1 EQ 900.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN .
    ENDLOOP.
  ENDIF.
*  LOOP AT SCREEN.
*    IF screen-group1 EQ rad1.
*      screen-active = 0.
*    ENDIF.
*    MODIFY SCREEN .
*  ENDLOOP.
*
ENDFORM.                    " AT-SELECTION-SCREEN-OUTPUT
*&---------------------------------------------------------------------*
*&      Form  GET_FILENAME
*&---------------------------------------------------------------------*
FORM get_filename .
*--
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.
*--
ENDFORM.                    " GET_FILENAME
*&---------------------------------------------------------------------*
*&      Form  START-OF-SELECTION
*&---------------------------------------------------------------------*
FORM start-of-selection .
*--
  CASE 'X'.
    WHEN r4.
*--
      IF p_file IS INITIAL .
        MESSAGE i004(zcspa) .
        EXIT .
      ELSE .
        PERFORM run_for_r4 .
      ENDIF.
*--
    WHEN r5. "OR r6.
      PERFORM run_for_f5 .
  ENDCASE.
*--
ENDFORM.                    " START-OF-SELECTION
*&---------------------------------------------------------------------*
*&      Form  RUN_FOR_R4
*&---------------------------------------------------------------------*
FORM run_for_r4 .
*
  DATA : lv_name TYPE string .
  DATA : pa0001 TYPE TABLE OF pa0001,
         s_001  LIKE LINE OF  pa0001.
  DATA : lv_infty TYPE infty .

  IF r1 EQ 'X' .
    lv_infty = '0014' .
  ELSEIF r2 EQ 'X' .
    lv_infty = '0015' .
  ELSEIF r3 EQ 'X' .
    lv_infty = '2010' .
  ENDIF .

  SELECT * FROM pa0001 INTO TABLE pa0001 WHERE begda LE sy-datum
                                           AND endda GE sy-datum .

  lv_fnam = p_file.
  cl_gui_frontend_services=>gui_upload(
EXPORTING
  filename                = lv_fnam "SPACE    " Name of file
  filetype                = 'BIN'
IMPORTING
  filelength              =  lv_filelength " File Length
  header                  =  lv_headerxstring   " File Hea
CHANGING
  data_tab                = lt_records  " Transfer table
EXCEPTIONS
  file_open_error         = 1
  file_read_error         = 2
  no_batch                = 3
  gui_refuse_filetransfer = 4
  invalid_type            = 5
  no_authority            = 6
  unknown_error           = 7
  bad_data_format         = 8
  header_not_allowed      = 9
  separator_not_allowed   = 10
  header_too_long         = 11
  unknown_dp_error        = 12
  access_denied           = 13
  dp_out_of_memory        = 14
  disk_full               = 15
  dp_timeout              = 16
  not_supported_by_gui    = 17
  error_no_gui            = 18
  OTHERS                  = 19 ).

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = lv_filelength
    IMPORTING
      buffer       = lv_headerxstring
    TABLES
      binary_tab   = lt_records
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  lo_excel_ref = NEW cl_fdt_xl_spreadsheet(
                          document_name = lv_fnam
                          xdocument     = lv_headerxstring ).


  lo_excel_ref->if_fdt_doc_spreadsheet~get_worksheet_names(
    IMPORTING
      worksheet_names = DATA(lt_wsname)
  ).

  READ TABLE lt_wsname INTO DATA(lv_wsname) INDEX 1.

  DATA(lo_data_ref) =
 lo_excel_ref->if_fdt_doc_spreadsheet~get_itab_from_worksheet(
  worksheet_name  = lv_wsname
  ).

  ASSIGN lo_data_ref->* TO <l_data>.
  DELETE <l_data> INDEX 1.

  IF r2 EQ 'X' OR r3 EQ 'X'.

    LOOP AT <l_data> ASSIGNING FIELD-SYMBOL(<l_data2>) .

      ASSIGN COMPONENT 'A' OF STRUCTURE <l_data2>
      TO FIELD-SYMBOL(<l_cell1>).
      ASSIGN COMPONENT 'B' OF STRUCTURE <l_data2>
      TO FIELD-SYMBOL(<l_cell2>).
      ASSIGN COMPONENT 'C' OF STRUCTURE <l_data2>
      TO FIELD-SYMBOL(<l_cell3>).
      ASSIGN COMPONENT 'D' OF STRUCTURE <l_data2>
      TO FIELD-SYMBOL(<l_cell4>).
      IF r2 EQ 'X'.
        ASSIGN COMPONENT 'E' OF STRUCTURE <l_data2>
        TO FIELD-SYMBOL(<l_cell5>).
        gt_excel-betrg = <l_cell5>.
        CLEAR: <l_cell5>.
      ENDIF.

      IF <l_cell1> IS NOT INITIAL .
        gt_excel-pernr = <l_cell1>.

        CONCATENATE <l_cell2>+0(4) <l_cell2>+5(2) <l_cell2>+8(2)
         INTO gt_excel-begda.

        gt_excel-lgart = <l_cell3>.
        gt_excel-anzhl = <l_cell4>.




        APPEND gt_excel.
        CLEAR: gt_excel, <l_data2>,<l_cell1>,<l_cell2>,<l_cell3>,
      <l_cell4>.

      ENDIF.

    ENDLOOP.

*      LOOP AT GT_EXCEL2 .
*        MOVE-CORRESPONDING : GT_EXCEL2 TO GT_EXCEL.
*        APPEND GT_EXCEL.
*      ENDLOOP.

  ELSE.
*     *-- get data from excel file
*      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
*        EXPORTING
*          I_FIELD_SEPERATOR    = 'X'
*          I_LINE_HEADER        = 'X'
*          I_TAB_RAW_DATA       = RAW
*          I_FILENAME           = P_FILE
*        TABLES
*          I_TAB_CONVERTED_DATA = GT_EXCEL
*        EXCEPTIONS
*          CONVERSION_FAILED    = 1
*          OTHERS               = 2.

    LOOP AT <l_data> ASSIGNING FIELD-SYMBOL(<l_data3>) .

      ASSIGN COMPONENT 'A' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell1_1>).
      ASSIGN COMPONENT 'B' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell2_2>).
      ASSIGN COMPONENT 'C' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell3_3>).
      ASSIGN COMPONENT 'D' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell4_4>).
      ASSIGN COMPONENT 'E' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell5_5>).
      ASSIGN COMPONENT 'F' OF STRUCTURE <l_data3>
      TO FIELD-SYMBOL(<l_cell6_6>).

      IF <l_cell1_1> IS NOT INITIAL .
        gt_excel-pernr = <l_cell1_1>.

        CONCATENATE <l_cell2_2>+0(4) <l_cell2_2>+5(2) <l_cell2_2>+8(2)
              INTO gt_excel-begda.

        CONCATENATE <l_cell3_3>+0(4) <l_cell3_3>+5(2) <l_cell3_3>+8(2)
                INTO gt_excel-endda.

        gt_excel-lgart = <l_cell4_4>.
        gt_excel-anzhl = <l_cell5_5>.
        gt_excel-betrg = <l_cell6_6>.

        APPEND gt_excel.
        CLEAR: gt_excel, <l_data3>,<l_cell1_1>,<l_cell2_2>,
        <l_cell3_3>,<l_cell4_4>,<l_cell5_5>,<l_cell6_6>.
      ENDIF.

    ENDLOOP.


  ENDIF.

  CLEAR :lv_fnam,lv_filelength,lv_headerxstring,lt_records,
  lt_wsname,lv_wsname,lo_data_ref,<l_data>.

  IF sy-subrc <> 0.
    MESSAGE i005(zcspa) .
    EXIT .
  ELSE .
    LOOP AT gt_excel .



      MOVE-CORRESPONDING : gt_excel TO gt_create .
      READ TABLE gt_t512t WITH KEY lgart = gt_excel-lgart .
      IF sy-subrc EQ 0 .
        MOVE : gt_t512t-lgtxt TO gt_create-lgtxt .
      ENDIF .
      CLEAR s_001 .
      READ TABLE pa0001 INTO s_001 WITH KEY pernr = gt_excel-pernr .
      gt_create-ename = s_001-ename .

      CLEAR s_530 .
      READ TABLE t530f INTO s_530 WITH KEY infty = lv_infty
                                           preas = gt_excel-preas .
      gt_create-rtext = s_530-rtext .

      APPEND gt_create . CLEAR gt_create .

    ENDLOOP.
  ENDIF.

ENDFORM.                    " RUN_FOR_R4
" GET_DATA_EXCEL
*&---------------------------------------------------------------------*
*&      Form  END-OF-SELECTION
*&---------------------------------------------------------------------*
FORM end-of-selection .

*--
  CHECK gt_create[]  IS NOT INITIAL OR
        gt_delete[]  IS NOT INITIAL .




  CASE 'X'.
    WHEN r4.
*  -- layout
      CLEAR gs_lvc_layo .
      set_layout : 'GS_LVC_LAYO' 'BOX_FNAME'  'MARK' .

      PERFORM create_fcat USING 'GT_CREATE'       'GT_SLIS_FCAT[]' .
      PERFORM cast_to_lvc USING 'GT_SLIS_FCAT[]'  'GT_CREATE[]'    .
      CLEAR : gs_lvc_fcat .
      gs_lvc_fcat-fieldname = 'ZCOUNT'.
      APPEND gs_lvc_fcat TO gt_lvc_fcat .
*  -- modify_fcat_text
      modify_fcat_text : 'PERNR' 'Pers.No.'   'Personel numarası'  ,
                         'BEGDA' 'Baş.Trh.'   'Başlangıç tarihi'   ,
                         'ENDDA' 'Bit.Trh'    'Bitiş tarihi'       ,
                         'LGART' 'Ücrt.Tür.'  'Ücret türü'         ,
                         'LGTXT' 'Ücrt.Tür.Mtn.'
                                 'Ücret türü metni'                ,
                         'ANZHL' 'Sayı.Aln.'     'Sayı alanı'      ,
                         'BETRG' 'Tutar.Aln.'    'Tutar alanı'     ,
                         'PREAS' 'Sigorta türü'  'Sigorta türü'    ,
                         'RTEXT' 'Sig. t. mtn'   'Sigorta türü metni',
                         'ICON'  'Durum'         'Durum'           ,
                         'ZCOUNT'  'Kişi Sayısı'   'Kişi Sayısı'     ,
                         'MSG'   'İleti mtn'     'İleti metni'     .

*-- MODIFY_FCAT
      modify_fcat      : 'MARK' 'NO_OUT' 'X'    ,
                         'PREAS' 'NO_OUT' 'X'    ,
                         'RTEXT' 'NO_OUT' 'X'    ,
                         'PERNR' 'OUTPUTLEN' 15 ,
                         'BEGDA' 'OUTPUTLEN' 12 ,
                         'ENDDA' 'OUTPUTLEN' 10 ,
                         'LGART' 'OUTPUTLEN' 10 ,
                         'ANZHL' 'OUTPUTLEN' 10 ,
                         'BETRG' 'OUTPUTLEN' 10 ,
                         'PREAS' 'OUTPUTLEN' 2  ,
                         'ICON'  'OUTPUTLEN' 10 ,
                         'MSG'   'OUTPUTLEN' 25 ,
                         'LGART' 'JUST'     'C' .

      IF r1 NE 'X'  .
        modify_fcat    : 'PREAS' 'NO_OUT' 'X'   .
      ENDIF .

*-- disp alv
      PERFORM display_alv USING 'GT_CREATE[]' 'GT_LVC_FCAT[]'
      'GS_LVC_LAYO'.

    WHEN r5. "OR r6.
*  -- layout
      CLEAR gs_lvc_layo .
      set_layout : 'GS_LVC_LAYO' 'BOX_FNAME'  'MARK' .

      PERFORM create_fcat USING 'GT_DELETE'      'GT_SLIS_FCAT[]' .
      PERFORM cast_to_lvc USING 'GT_SLIS_FCAT[]' 'GT_EXCEL[]'     .
      CLEAR : gs_lvc_fcat .
      gs_lvc_fcat-fieldname = 'ZCOUNT'.
      APPEND gs_lvc_fcat TO gt_lvc_fcat .

*  -- modify_fcat_text
      modify_fcat_text : 'PERNR' 'Pers.No.'   'Personel numarası'  ,
                         'BEGDA' 'Baş.Trh.'   'Başlangıç tarihi'   ,
                         'ENDDA' 'Bit.Trh'    'Bitiş tarihi'       ,
                         'LGART' 'Ücrt.Tür.'  'Ücret türü'         ,
                         'LGTXT' 'Ücrt.Tür.Açkl.'
                                 'Ücret türü metni'           ,
                         'ANZHL' 'Sayı.Aln.'  'Sayı alanı'         ,
                         'BETRG' 'Tutar.Aln.' 'Tutar alanı'        ,
                         'PREAS' 'Sigorta türü'  'Sigorta türü'    ,
                       'RTEXT' 'Sig. t. mtn'   'Sigorta türü metni' ,
                         'ZCOUNT'  'Kişi Sayısı'   'Kişi Sayısı'     ,
                         'ICON'  'Durum'      'Durum'              ,
                         'MSG'   'İleti mtn'     'İleti metni'     .

*-- MODIFY_FCAT
      modify_fcat      : 'MARK'  'NO_OUT' 'X'   ,
                         'PREAS' 'NO_OUT' 'X'    ,
                         'RTEXT' 'NO_OUT' 'X'    ,
                         'PERNR' 'OUTPUTLEN' 15 ,
                         'BEGDA' 'OUTPUTLEN' 12 ,
                         'ENDDA' 'OUTPUTLEN' 10 ,
                         'LGART' 'OUTPUTLEN' 10 ,
                         'LGTXT' 'OUTPUTLEN' 20 ,
                         'ANZHL' 'OUTPUTLEN' 10 ,
                         'BETRG' 'OUTPUTLEN' 10 ,
                         'ICON'  'OUTPUTLEN' 10 ,
                         'MSG'   'OUTPUTLEN' 25 ,
                         'LGART' 'JUST'     'C' .

*-- disp alv
      PERFORM display_alv USING 'GT_DELETE[]' 'GT_LVC_FCAT[]'
      'GS_LVC_LAYO'.
  ENDCASE.
ENDFORM.                    " END-OF-SELECTION
*&---------------------------------------------------------------------*
*&      Form  CREATE_FCAT
*&---------------------------------------------------------------------*
FORM create_fcat  USING   p_tabname
                          p_fcatname .
*
  gv_alvtabname = p_tabname .
  ASSIGN (p_fcatname) TO <fs_fcat> .
  REFRESH <fs_fcat> .

*
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = gv_alvtabname
      i_inclname             = sy-repid
      i_client_never_display = 'X'
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = <fs_fcat>.
*

ENDFORM.                    " CREATE_FCAT
*&---------------------------------------------------------------------*
*&      Form  CAST_TO_LVC
*&---------------------------------------------------------------------*
FORM cast_to_lvc  USING    p_fcatname
                           p_tabname .
*--
  UNASSIGN : <fs_fcat>  ,
             <fs_table> .
*--
  ASSIGN : (p_fcatname) TO <fs_fcat>  ,
           (p_tabname)  TO <fs_table> .
*--
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      it_fieldcat_alv = <fs_fcat>
    IMPORTING
      et_fieldcat_lvc = gt_lvc_fcat[]
    TABLES
      it_data         = <fs_table>
    EXCEPTIONS
      it_data_missing = 1
      OTHERS          = 2.
*--
ENDFORM.                    " CAST_TO_LVC
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM display_alv USING p_tabname
                       p_fcatname
                       p_layoname.

*
  UNASSIGN : <fs_table>  ,
             <fs_fcat>   ,
             <fs_layout> .

*
  ASSIGN : (p_tabname) TO  <fs_table>  ,
           (p_fcatname) TO <fs_fcat>   ,
           (p_layoname) TO <fs_layout> .


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'GUI'
      i_callback_user_command  = 'COMMAND'
*     i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout_lvc            = <fs_layout>
      it_fieldcat_lvc          = <fs_fcat>
    TABLES
      t_outtab                 = <fs_table>
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
*--
ENDFORM.                    " DISPLAY_ALV
*&---------------------------------------------------------------------*
*&      Form  RUN_BATCH
*&---------------------------------------------------------------------*
FORM run_batch .
*-- local definition
  DATA :
    lv_index  TYPE sy-index,
    lv_inf(5) ,
    lv_infty  LIKE prelp-infty,
    lv_subty  LIKE p0001-subty,
    lv_pernr  LIKE pa0001-pernr,
    lv_begda  LIKE pa0001-begda,
    lv_endda  LIKE pa0001-endda,
    lv_numc   TYPE numc2.
*--
  UNASSIGN <fs_field> .
*--
  CASE 'X'.
    WHEN r1 .
      lv_inf   = 'P0014' .
    WHEN r2.
      lv_inf   = 'P0015' .
    WHEN r3.
      lv_inf   = 'P2010' .
  ENDCASE.

  READ TABLE gt_create WITH KEY mark = 'X' TRANSPORTING NO FIELDS .

  IF sy-subrc <> 0 .
    MESSAGE i006(zcspa) .
  ELSE .
    lv_infty = lv_inf+1(4) .

    CREATE DATA gs_inftype TYPE (lv_inf) .
    ASSIGN gs_inftype->* TO <fs_infotype> .

    LOOP AT gt_create WHERE mark EQ 'X' .

      lv_index = sy-tabix .

      SELECT SINGLE * FROM pa0000 INTO @DATA(ls_0000)
      WHERE  pernr EQ @gt_create-pernr
      AND    begda LE @gt_create-begda
      AND    endda GE @gt_create-begda.

      IF ls_0000-stat2 NE '0'.

        ASSIGN COMPONENT 'PERNR' OF STRUCTURE <fs_infotype> TO
        <fs_field>
        .
        <fs_field> = gt_create-pernr .
        lv_pernr   = gt_create-pernr .
        ASSIGN COMPONENT 'BEGDA' OF STRUCTURE <fs_infotype> TO
        <fs_field>
        .
        <fs_field> = gt_create-begda .
        lv_begda   = gt_create-begda .
        ASSIGN COMPONENT 'LGART' OF STRUCTURE <fs_infotype> TO
        <fs_field>
        .
        <fs_field> = gt_create-lgart .
        ASSIGN COMPONENT 'SUBTY' OF STRUCTURE <fs_infotype> TO
        <fs_field>
        .
        <fs_field> = gt_create-lgart .
        lv_subty   = gt_create-lgart .
        ASSIGN COMPONENT 'ANZHL' OF STRUCTURE <fs_infotype> TO
        <fs_field>
        .
        <fs_field> = gt_create-anzhl .
        IF r3 NE 'X'.
          ASSIGN COMPONENT 'BETRG' OF STRUCTURE <fs_infotype> TO
          <fs_field>.
          <fs_field> = gt_create-betrg .
          ASSIGN COMPONENT 'ENDDA' OF STRUCTURE <fs_infotype> TO
          <fs_field>.
          <fs_field> = gt_create-endda .
          lv_endda   = gt_create-endda .
        ENDIF.

        IF r1 EQ 'X' .

          ASSIGN COMPONENT 'PREAS' OF STRUCTURE <fs_infotype> TO
           <fs_field> .
          lv_numc   = gt_create-preas .
          <fs_field> = lv_numc .
        ENDIF .

*      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
*        EXPORTING
*          number = lv_pernr.

        CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
          EXPORTING
            number = lv_pernr.

        CALL FUNCTION 'HR_INFOTYPE_OPERATION'
          EXPORTING
            infty         = lv_infty
            number        = lv_pernr
            subtype       = lv_subty
            validityend   = lv_endda
            validitybegin = lv_begda
            record        = <fs_infotype>
            operation     = 'INS'
            tclas         = 'A'
            dialog_mode   = '0'
            nocommit      = nocommit
          IMPORTING
            return        = return
            key           = key
          EXCEPTIONS
            OTHERS        = 0.

        IF sy-subrc <> 0 .
          MESSAGE return TYPE 'S' .
        ENDIF .

        IF return-message IS NOT INITIAL .
          READ TABLE gt_create INDEX lv_index .
          gt_create-icon = '@5C@' .
          gt_create-msg  = return-message .
          MODIFY gt_create INDEX lv_index .

        ELSE .
          READ TABLE gt_create INDEX lv_index .
          gt_create-icon = '@5B@' .
          gt_create-msg  = 'İşlem başarılı' .
          MODIFY gt_create INDEX lv_index .

          COMMIT WORK AND WAIT .

        ENDIF .

        CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
          EXPORTING
            number = lv_pernr.

*--
        CLEAR : gt_create , lv_pernr ,
                lv_index  , lv_pernr ,
                lv_begda  , lv_endda ,
                lv_subty  .

        COMMIT WORK AND WAIT .
*      WAIT UP TO 1 SECONDS.

      ELSE.


        READ TABLE gt_create INDEX lv_index .
        gt_create-icon = '@5C@' .
        gt_create-msg  = 'Bu Tarihte Personel Aktif Değil' .
        MODIFY gt_create INDEX lv_index .

      ENDIF.
    ENDLOOP.
*
    UNASSIGN : <fs_infotype> .
    PERFORM refresh_alv .
  ENDIF.

ENDFORM.                    " RUN_BATCH
*&---------------------------------------------------------------------*
*&      Form  REFRESH_ALV
*&---------------------------------------------------------------------*
FORM refresh_alv .
*
  DATA : l_stable TYPE lvc_s_stbl .
*
  l_stable-col = 'X' .
  l_stable-row = 'X' .

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = gc_ref.

  CALL METHOD gc_ref->refresh_table_display
    EXPORTING
      is_stable = l_stable
    EXCEPTIONS
      finished  = 1.
*--
ENDFORM.                    " REFRESH_ALV
*&---------------------------------------------------------------------*
*&      Form  RUN_FOR_F5
*&---------------------------------------------------------------------*
FORM run_for_f5 .
*--
  DATA : lv_tabname(6) .

  DATA : lv_infty TYPE infty .
*--
  IF p_begda IS INITIAL.
    p_begda = '18000101' .
  ENDIF.
*
  IF p_endda IS INITIAL.
    p_endda = '99991231' .
  ENDIF.
*--

  IF r1 EQ 'X' AND zbyhr_t024-f0014 NE 'X'.
    MESSAGE '14 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF r2 EQ 'X' AND zbyhr_t024-f0015 NE 'X'.
    MESSAGE '15 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF r3 EQ 'X' AND zbyhr_t024-f2010 NE 'X'.
    MESSAGE '2010 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  CASE 'X'.
    WHEN r1 .
      CLEAR gt_delete[] .

      SELECT DISTINCT p14~pernr, p01~ename, p14~begda, p14~endda,
      p14~lgart,
             t51~lgtxt, p14~anzhl, p14~betrg, p14~preas,
        CAST( ( '1' ) AS NUMC( 1 )   ) AS zcount
        INTO CORRESPONDING FIELDS OF TABLE @gt_delete
        FROM pa0014 AS p14
        LEFT OUTER JOIN  pa0001 AS p01
          ON p01~pernr  = p14~pernr
         AND p01~begda <= @sy-datum"p15~endda
         AND p01~endda >= @sy-datum"p15~begda
*         AND p01~endda >= @sy-datum
*         AND p01~begda <= p14~endda    " "
*         AND p01~endda >= p14~begda
        JOIN t512t AS t51
          ON t51~lgart = p14~lgart
       WHERE
             p01~pernr IN @s_pernr AND
             p01~werks IN @s_werks AND
             p01~bukrs IN @s_bukrs AND
             p01~btrtl IN @s_btrtl AND
             p01~abkrs IN @s_abkrs AND
             p14~lgart IN @s_lgart AND
             p14~aedtm IN @s_aedtm AND
             p14~uname IN @s_uname AND
             p14~begda >= @p_begda AND
             p14~endda <= @p_endda AND
             t51~sprsl EQ @sy-langu AND
             t51~molga EQ '47'.

      lv_infty = '0014' .

    WHEN r2 .


      CLEAR gt_delete[] .
      SELECT p15~pernr, p01~ename, p15~begda, p15~endda, p15~lgart,
            t51~lgtxt, p15~anzhl, p15~betrg, p15~preas,
        CAST( ( '1' ) AS NUMC( 1 )   ) AS zcount
        INTO CORRESPONDING FIELDS OF TABLE @gt_delete
        FROM pa0015 AS p15
        LEFT OUTER JOIN pa0001 AS p01
          ON p01~pernr  = p15~pernr
         AND p01~begda <= @sy-datum"p15~endda
         AND p01~endda >= @sy-datum"p15~begda
*          AND p01~endda >= @sy-datum
        JOIN t512t AS t51
          ON t51~lgart = p15~lgart
       WHERE
             p01~pernr IN @s_pernr AND
             p01~werks IN @s_werks AND
             p01~bukrs IN @s_bukrs AND
             p01~btrtl IN @s_btrtl AND
             p01~abkrs IN @s_abkrs AND
             p15~lgart IN @s_lgart AND
             p15~aedtm IN @s_aedtm AND
             p15~uname IN @s_uname AND
             p15~begda >= @p_begda AND
             p15~endda <= @p_endda AND
             t51~sprsl EQ @sy-langu AND
             t51~molga EQ '47' .

      lv_infty = '0015' .

    WHEN r3 .
      CLEAR gt_delete[] .

      SELECT p2~pernr, p01~ename, p2~begda, p2~endda, p2~lgart,
             t51~lgtxt, p2~anzhl, p2~betrg, p2~preas,
        CAST( ( '1' ) AS NUMC( 1 )   ) AS zcount
        INTO CORRESPONDING FIELDS OF TABLE @gt_delete
        FROM pa2010 AS p2
        LEFT OUTER JOIN pa0001 AS p01
          ON p01~pernr  = p2~pernr
         AND p01~begda <= @sy-datum"p15~endda
         AND p01~endda >= @sy-datum"p15~begda
*          AND p01~endda >= @sy-datum
*         AND p01~begda <= p2~endda
*         AND p01~endda >= p2~begda
        JOIN t512t AS t51
          ON t51~lgart = p2~lgart
       WHERE
             p01~pernr IN @s_pernr AND
             p01~werks IN @s_werks AND
             p01~bukrs IN @s_bukrs AND
             p01~btrtl IN @s_btrtl AND
             p01~abkrs IN @s_abkrs AND
             p2~lgart  IN @s_lgart AND
             p2~aedtm  IN @s_aedtm AND
             p2~uname  IN @s_uname AND
             p2~begda >= @p_begda AND
             p2~endda <= @p_endda AND
             t51~sprsl EQ @sy-langu  .

      lv_infty = '2010' .

  ENDCASE.

  DATA: gt_0001 TYPE TABLE OF pa0001 WITH HEADER LINE.

  IF gt_delete[] IS NOT INITIAL.
    SELECT * FROM pa0001 INTO TABLE gt_0001
      FOR ALL ENTRIES IN gt_delete
            WHERE pernr EQ gt_delete-pernr
              AND werks IN s_werks AND btrtl IN s_btrtl
*              AND persk IN s_persk AND persg IN s_persg
              AND begda LE sy-datum AND endda GE sy-datum.
  ENDIF.

  LOOP AT gt_0001 INTO DATA(ls_01).
    AUTHORITY-CHECK OBJECT 'P_ORGIN'
     ID 'INFTY' FIELD '0001'
     ID 'PERSA' FIELD ls_01-werks
     ID 'PERSG' FIELD ls_01-persg
     ID 'PERSK' FIELD ls_01-persk
     ID 'VDSK1' FIELD ls_01-vdsk1.
    IF sy-subrc <> 0.
      DELETE gt_delete WHERE pernr = ls_01-pernr.
      CONTINUE.
    ENDIF.
  ENDLOOP.


  "" bu kadar joinli selectin arasına ekleyemedim
  LOOP AT gt_delete .
    CLEAR s_530 .
    READ TABLE t530f INTO s_530 WITH KEY infty = lv_infty
                                         preas = gt_delete-preas .

    gt_delete-rtext = s_530-rtext .

    MODIFY gt_delete .

  ENDLOOP .

*--
ENDFORM.                    " RUN_FOR_F5
*&---------------------------------------------------------------------*
*&      Form  RUN_BATCH_DELETE
*&---------------------------------------------------------------------*
FORM run_batch_delete .
*
*-- local definition
  DATA :
    lv_index  TYPE sy-index,
    lv_inf(5) ,
    lv_infty  LIKE prelp-infty,
    lv_subty  LIKE p0001-subty,
    lv_pernr  LIKE pa0001-pernr,
    lv_begda  LIKE pa0001-begda,
    lv_endda  LIKE pa0001-endda.
*--
  UNASSIGN <fs_field> .
*--
  CASE 'X'.
    WHEN r1 .
      lv_inf   = 'P0014' .
    WHEN r2.
      lv_inf   = 'P0015' .
    WHEN r3.
      lv_inf   = 'P2010' .
  ENDCASE.
*--

  IF r1 EQ 'X' AND zbyhr_t024-f0014 NE 'X'.
    MESSAGE '14 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF r2 EQ 'X' AND zbyhr_t024-f0015 NE 'X'.
    MESSAGE '15 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ELSEIF r3 EQ 'X' AND zbyhr_t024-f2010 NE 'X'.
    MESSAGE '2010 BT silme yetkiniz yoktur.' TYPE 'S'
        DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.



  READ TABLE gt_delete WITH KEY mark = 'X' TRANSPORTING NO FIELDS .
  IF sy-subrc <> 0 .
    MESSAGE i000(zcspa) .
  ELSE .
    lv_infty = lv_inf+1(4) .

    CREATE DATA gs_inftype TYPE (lv_inf) .
    ASSIGN gs_inftype->* TO <fs_infotype> .

    LOOP AT gt_delete WHERE mark EQ 'X' .
      lv_index = sy-tabix .
      ASSIGN COMPONENT 'PERNR' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-pernr .
      lv_pernr   = gt_delete-pernr .
      ASSIGN COMPONENT 'BEGDA' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-begda .
      lv_begda   = gt_delete-begda .
      ASSIGN COMPONENT 'LGART' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-lgart .
      ASSIGN COMPONENT 'SUBTY' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-lgart .
      lv_subty   = gt_delete-lgart .
      ASSIGN COMPONENT 'ANZHL' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-anzhl .
      IF r3 NE 'X'.
        ASSIGN COMPONENT 'BETRG' OF STRUCTURE <fs_infotype> TO
        <fs_field>.
        <fs_field> = gt_delete-betrg .
      ENDIF.
      ASSIGN COMPONENT 'ENDDA' OF STRUCTURE <fs_infotype> TO <fs_field>.
      <fs_field> = gt_delete-endda .
      lv_endda   = gt_delete-endda .

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr.

      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lv_pernr.

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = lv_infty
          number        = lv_pernr
          subtype       = lv_subty
          validityend   = lv_endda
          validitybegin = lv_begda
          record        = <fs_infotype>
          operation     = 'DEL'
          tclas         = 'A'
          dialog_mode   = '0'
          nocommit      = nocommit
        IMPORTING
          return        = return
          key           = key
        EXCEPTIONS
          OTHERS        = 0.

      IF sy-subrc <> 0 .
        MESSAGE return TYPE 'S' .
      ENDIF .

      IF return-message IS NOT INITIAL .
        READ TABLE gt_delete INDEX lv_index .
        gt_delete-icon = '@5C@' .
        gt_delete-msg  = return-message .
        MODIFY gt_delete INDEX lv_index .

      ELSE .
        READ TABLE gt_delete INDEX lv_index .
        gt_delete-icon = '@5B@' .
        gt_delete-msg  = 'Kayıt silindi' .
        MODIFY gt_delete INDEX lv_index .

        COMMIT WORK AND WAIT .

      ENDIF .

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr.

*--
      CLEAR : gt_delete , lv_pernr ,
              lv_index , lv_pernr ,
              lv_begda , lv_endda ,
              lv_subty .

*--
    ENDLOOP.
    UNASSIGN : <fs_infotype> .
    PERFORM refresh_alv .
  ENDIF .

ENDFORM.                    " RUN_BATCH_DELETE
*&---------------------------------------------------------------------*
*&      Form  AT-SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM at-selection-screen  USING p_ucomm.
*-- local definitions..
  DATA : subrc TYPE sy-subrc .
  DATA : fname(128) .
  DATA : BEGIN OF  file OCCURS 0 ,
*           FIELD(400) ,
           field(1300) ,
         END OF file .
  DATA: ld_filename TYPE string,
        ld_path     TYPE string,
        ld_fullpath TYPE string,
        ld_result   TYPE i,

        l_filename  TYPE string.
*--

  DATA : lt_signat  TYPE TABLE OF bapisignat,
         i_exname   TYPE bds_typeid,
         lt_signat2 TYPE TABLE OF bapisignat.
  DATA : lt_comp TYPE TABLE OF bapicompon.
  DATA : lt_cont TYPE TABLE OF bapiconten.
  DATA : lv_file TYPE string.
  DATA : lv_fold TYPE string.
  CASE p_ucomm.
    WHEN 'FC02' .


      CLEAR : i_exname.

      IF r1 EQ 'X'.
        i_exname = 'ZHRP003_14'.
      ELSEIF r2 EQ 'X'.
        i_exname = 'ZHRP003_15'.
      ELSEIF r3 EQ 'X'.
        i_exname = 'ZHRP003_2010'.
      ENDIF.


      CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
        EXPORTING
          text = TEXT-t04.


      CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_URL'
        EXPORTING
*         LOGICAL_SYSTEM  =
          classname       = 'PICTURES'
          classtype       = 'OT'
          client          = sy-mandt
          object_key      = i_exname
          url_lifetime    = 'T'
        TABLES
          signature       = lt_signat
        EXCEPTIONS
          nothing_found   = 1
          parameter_error = 2
          not_allowed     = 3
          error_kpro      = 4
          internal_error  = 5
          not_authorized  = 6
          OTHERS          = 7.

      IF sy-subrc = 0.
        READ TABLE lt_signat INTO DATA(ls_signat) WITH KEY doc_count =
        1.

        IF sy-subrc = 0.

          CALL FUNCTION 'BDS_DOCUMENT_DISPLAY'
            EXPORTING
              client          = sy-mandt
              doc_id          = ls_signat-doc_id
            TABLES
              signature       = lt_signat
            EXCEPTIONS
              nothing_found   = 1
              parameter_error = 2
              not_allowed     = 3
              error_kpro      = 4
              internal_error  = 5
              not_authorized  = 6
              OTHERS          = 7.
          IF sy-subrc <> 0.
            MESSAGE TEXT-m01 TYPE 'S' DISPLAY LIKE 'E'.
          ENDIF.

        ENDIF.
      ENDIF.
  ENDCASE.
*
ENDFORM.                    " AT-SELECTION-SCREEN
*&---------------------------------------------------------------------*
*&      Form  FILL_DATA
*&---------------------------------------------------------------------*
FORM fill_data .
*--
  SELECT * FROM t512t INTO TABLE gt_t512t WHERE sprsl EQ sy-langu
                                            AND molga EQ '47' .

  SELECT * FROM t530f INTO TABLE t530f WHERE sprsl EQ sy-langu .

  CLEAR zbyhr_t024.
  SELECT SINGLE * FROM zbyhr_t024 WHERE uname EQ sy-uname .

*--
ENDFORM.                    " FILL_DATA
*&---------------------------------------------------------------------*
*&      Form  RUN_BATCH_LIS9
*&---------------------------------------------------------------------*
FORM run_batch_lis9 .
*
*-- local definition
  DATA :
    lv_index  TYPE sy-index,
    lv_inf(5) ,
    lv_infty  LIKE prelp-infty,
    lv_subty  LIKE p0001-subty,
    lv_pernr  LIKE pa0001-pernr,
    lv_begda  LIKE pa0001-begda,
    lv_endda  LIKE pa0001-endda.
*--
  UNASSIGN <fs_field> .
*--
  CASE 'X'.
    WHEN r1 .
      lv_inf   = 'P0014' .
    WHEN r2.
      lv_inf   = 'P0015' .
    WHEN r3.
      lv_inf   = 'P2010' .
  ENDCASE.
*--


  READ TABLE gt_delete WITH KEY mark = 'X' TRANSPORTING NO FIELDS .
  IF sy-subrc <> 0 .
    MESSAGE i000(zcspa) .
  ELSE .
    lv_infty = lv_inf+1(4) .

    CREATE DATA gs_inftype TYPE (lv_inf) .
    ASSIGN gs_inftype->* TO <fs_infotype> .

    LOOP AT gt_delete WHERE mark EQ 'X' .
      lv_index = sy-tabix .
      ASSIGN COMPONENT 'PERNR' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-pernr .
      lv_pernr   = gt_delete-pernr .
      ASSIGN COMPONENT 'BEGDA' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-begda .
      lv_begda   = gt_delete-begda .
      ASSIGN COMPONENT 'LGART' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-lgart .
      ASSIGN COMPONENT 'SUBTY' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-lgart .
      lv_subty   = gt_delete-lgart .
      ASSIGN COMPONENT 'ANZHL' OF STRUCTURE <fs_infotype> TO <fs_field>
      .
      <fs_field> = gt_delete-anzhl .
      IF r3 NE 'X'.
        ASSIGN COMPONENT 'BETRG' OF STRUCTURE <fs_infotype> TO
        <fs_field>.
        <fs_field> = gt_delete-betrg .
      ENDIF.
      ASSIGN COMPONENT 'ENDDA' OF STRUCTURE <fs_infotype> TO <fs_field>.
*      <fs_field> = gt_delete-endda .
      <fs_field> = p_snrlm .
      lv_endda   = gt_delete-endda .

      ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_infotype> TO <fs_field>.
*      <fs_field> = gt_delete-endda .
      <fs_field> = 'TRY' .

      ASSIGN COMPONENT 'INFTY' OF STRUCTURE <fs_infotype> TO <fs_field>.
      <fs_field> = lv_infty .

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr.

      CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
        EXPORTING
          number = lv_pernr.

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = lv_infty
          number        = lv_pernr
          subtype       = lv_subty
          validityend   = lv_endda
          validitybegin = lv_begda
          record        = <fs_infotype>
          operation     = 'MOD'
          tclas         = 'A'
          dialog_mode   = '1'
          nocommit      = nocommit
        IMPORTING
          return        = return
          key           = key
        EXCEPTIONS
          OTHERS        = 0.

      IF sy-subrc <> 0 .
        MESSAGE return TYPE 'S' .
      ENDIF .

      IF return-message IS NOT INITIAL .
        READ TABLE gt_delete INDEX lv_index .
        gt_delete-icon = '@5C@' .
        gt_delete-msg  = return-message .
        MODIFY gt_delete INDEX lv_index .

      ELSE .
        READ TABLE gt_delete INDEX lv_index .
        gt_delete-icon = '@5B@' .
        gt_delete-msg  = 'Kayıt sınırlandı' .
        MODIFY gt_delete INDEX lv_index .

        COMMIT WORK AND WAIT .

      ENDIF .

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = lv_pernr.

*--
      CLEAR : gt_delete , lv_pernr ,
              lv_index , lv_pernr ,
              lv_begda , lv_endda ,
              lv_subty .

*--
    ENDLOOP.
    UNASSIGN : <fs_infotype> .
    PERFORM refresh_alv .
  ENDIF .
ENDFORM.
