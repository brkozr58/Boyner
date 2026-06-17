*&---------------------------------------------------------------------*
*& Report ZBYHR_P019
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p019.

*TYPE-POOLS: SLIS, KKBLO.
INFOTYPES :  0000,0001,0015,0009,0008,0002.

TABLES: pernr, bnka,t549a,pcl1,pcl2,s001.
*INCLUDE PCIFTTR0.         " Infotypes for Turkey
*INCLUDE PCFTBTR0.         " Tables for Turkey
INCLUDE rpc2cd09.  "***
INCLUDE rpc2rx19.           " PCL2-Data Cluster RG general
INCLUDE pc2rxtr0.           " PCL2-Data Cluster RG Turkey
INCLUDE rpc2rx02.           " PCL2-Data Cluster RG common with Cl. B2

INCLUDE rpppxd00.           "Data definition buffer *PCL1/PCL2
INCLUDE rpppxd10.           "Common part buffer PCL1/PCL2
INCLUDE rpppxm00.           "Buffer handling routine
*TABLES PC201_PAY.

DATA gv_sequence  TYPE bapi7004_rl-sequencenumber."PC261-SEQNR.

DATA : py_result TYPE paytr_result,
       py_wpbp   TYPE pc205,
       py_rt     TYPE pc207,
       py_grt    TYPE pc207,
       py_crt    TYPE pc205.

DATA: aper TYPE pc2aper OCCURS 0 WITH HEADER LINE.
DATA: i TYPE n VALUE 0.


DATA : BEGIN OF py_perio OCCURS 0,
         fpper LIKE pc261-fpper,
       END OF py_perio.

DATA : lv_tarih(6) TYPE c.

DATA : BEGIN OF gt_forml OCCURS 0 ,
         forml LIKE t514d-forml,
         ftext LIKE t514v-ftext,
       END OF gt_forml .

"INCLUDE rpc2cd00.
DATA : g_begda LIKE sy-datum,
       g_endda LIKE sy-datum.

SELECTION-SCREEN BEGIN OF BLOCK frame1 WITH FRAME TITLE TEXT-001.
*parameters p_ay type month default sy-datum+4(2).
*parameters p_yil type gjahr default sy-datum+0(4).
  PARAMETERS:
**    "p_html AS CHECKBOX DEFAULT 'X',
*    p_pdf  AS CHECKBOX,
*    p_save AS CHECKBOX USER-COMMAND psave DEFAULT 'X'.
    p_pdf  RADIOBUTTON GROUP rd1 USER-COMMAND rd,
    p_save RADIOBUTTON GROUP rd1 DEFAULT 'X'.

  PARAMETERS p_merg AS CHECKBOX .


  PARAMETERS: p_svfl TYPE text200. " LENGTH 200.
  PARAMETERS: p_forml TYPE t514d-forml DEFAULT '-BOY' OBLIGATORY .
  SELECT-OPTIONS : s_date FOR s001-spmon OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK frame1.

DATA:  l_date LIKE sy-datum.
DATA : gv_month LIKE  t247-ltx.
DATA : gv_date(10) TYPE c.
DATA   gv_yil(4) TYPE c.
DATA : lt_ftable TYPE filetable.
DATA : lv_rc  TYPE i.

DATA : gt_per TYPE hrpadun_aap_persons,
       gs_per LIKE LINE OF gt_per.

DATA : gv_subrc TYPE sy-subrc .
DATA : gv_chk   .

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_svfl.
  PERFORM at_selection CHANGING p_svfl.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_forml.
  PERFORM f4 USING p_forml .

AT SELECTION-SCREEN.
  PERFORM selection .

START-OF-SELECTION.
  CLEAR : gv_subrc.


  IF p_save EQ 'X' AND
     p_svfl IS INITIAL.
    MESSAGE 'Lütfen PDF kayıt yeri seçiniz'(002) TYPE 'I'.
    RETURN.
  ENDIF.

  IF p_save EQ 'X' AND
     p_pdf EQ 'X'.
*    OR p_html EQ 'X' ).
    MESSAGE 'Lütfen PDF olarak kaydet`i tek seçiniz!'(003) TYPE 'I'.
    RETURN.
  ENDIF.

GET pernr.
  MOVE : pernr-pernr TO gs_per-pernr.
  CLEAR : gv_chk .
  PERFORM authority-check CHANGING gv_chk.
  CHECK gv_chk IS INITIAL .
  APPEND gs_per TO gt_per.

END-OF-SELECTION.
  PERFORM read_payroll_new.

*&---------------------------------------------------------------------*
*&      Form  READ_PAYROLL_NEW
*&---------------------------------------------------------------------*
FORM read_payroll_new .
  DATA : lv_spmon TYPE spmon.
  DATA : lv_betrg TYPE betrg.

  CLEAR gv_sequence.


  IF gt_per[] IS NOT INITIAL.
*    LOOP AT gt_per ASSIGNING FIELD-SYMBOL(<per>).
    PERFORM send_pdf. "SING <per>-pernr.
*    ENDLOOP.

  ENDIF.
ENDFORM.                    " READ_PAYROLL_NEW
*&---------------------------------------------------------------------*
*&      Form  GET_CD
*&---------------------------------------------------------------------*
FORM get_cd .
  MOVE pernr-pernr TO cd-key-pernr.
  rp-imp-c2-cd.
ENDFORM.                    " GET_CD
*&---------------------------------------------------------------------*
*&      Form  READ_BORDRO
*&---------------------------------------------------------------------*
FORM read_bordro .
  rx-key-pernr = pernr-pernr.
  rx-key-seqno = rgdir-seqnr.
  rp-imp-c2-tr.
ENDFORM.                    " READ_BORDRO
*&---------------------------------------------------------------------*
*&      Form  SEND_PDF
*&---------------------------------------------------------------------*
FORM send_pdf. "USING p_pernr.


  DATA: lv_svfl    TYPE string,
        lv_kisi(1),
        lv_succ    TYPE i,
        lv_error   TYPE i.
  CHECK p_svfl IS NOT INITIAL.

  lv_svfl = p_svfl.
  LOOP AT s_date . ENDLOOP.
  IF s_date-high IS INITIAL .
    s_date-high = s_date-low.
  ENDIF.

  IF p_save EQ 'X' AND p_merg EQ 'X'.
    CALL FUNCTION 'ZBYHR_FG002_003'
      EXPORTING
*       iv_pernr = ls_per-pernr
        iv_send  = p_pdf
        iv_save  = p_save
        iv_svfl  = lv_svfl
        it_pernr = gt_per
        iv_low   = s_date-low
        iv_high  = s_date-high
        p_merg   = p_merg
      IMPORTING
        iv_kisi  = lv_kisi.
  ELSE.

    LOOP AT gt_per INTO DATA(ls_per).
      CALL FUNCTION 'ZBYHR_FG002_003'
        EXPORTING
          iv_pernr = ls_per-pernr
          iv_send  = p_pdf
          iv_save  = p_save
          iv_svfl  = lv_svfl
*         it_pernr = gt_per
          iv_low   = s_date-low
          iv_high  = s_date-high
        IMPORTING
          iv_kisi  = lv_kisi.

      IF lv_kisi = 'S'.
        lv_succ = lv_succ + 1 .
      ELSEIF lv_kisi = 'E'.
        lv_error = lv_error + 1.
      ENDIF.

      CLEAR ls_per.
    ENDLOOP.
  ENDIF.
  FORMAT COLOR COL_HEADING.
  WRITE :/ 'Başarılı:' ,lv_succ.
  WRITE :/ 'Başarısız:' ,lv_error.

*  IF p_spool IS NOT INITIAL.
*    p_forml = '-R01'.
*  ENDIF.
*  DATA lv_mesaj TYPE char70.
*  DATA lv_mesaj2 TYPE char70.
*
*  LOOP AT gt_per INTO DATA(ls_per).
*    CALL FUNCTION 'ZBYHR_FG002_001'
*      EXPORTING
*        iv_pernr    = ls_per-pernr
**       iv_pernr    = pernr-pernr
*        iv_sequence = gv_sequence
*        iv_pyvar    = 'PDF'
*        iv_month    = gv_month
*        iv_year     = gv_yil
*        iv_save     = p_save
*        iv_svfl     = lv_svfl
*        iv_forml    = p_forml
**       it_pernr    = gt_per
*        iv_spool    = p_spool
*        iv_low      = s_date-low
*        iv_high     = s_date-high
*        it_date     = s_date[].
*
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.
*
*    CLEAR ls_per.
*  ENDLOOP.



ENDFORM.                    " SEND_PDF
*&---------------------------------------------------------------------*
*&      Form  SEND_HTML
*&---------------------------------------------------------------------*
FORM send_html .

*  CALL FUNCTION 'ZBYHR_FG002_002'
*    EXPORTING
*      iv_pernr    = pernr-pernr
*      iv_sequence = gv_sequence
*      iv_pyvar    = 'PDF'
*      iv_month    = gv_month
*      iv_year     = gv_yil.
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDFORM.                    " SEND_HTML
*&---------------------------------------------------------------------*
*&      Form  AT_SELECTION
*&---------------------------------------------------------------------*
FORM at_selection  CHANGING p_svfl.

  DATA:  lv_svfl TYPE string.
  DATA : lv_leng TYPE i.

  CHECK p_save EQ 'X'.

  lv_svfl = p_svfl.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'PDF Kayıt Yeri Seçiniz'
*     INITIAL_FOLDER       =
    CHANGING
      selected_folder      = lv_svfl
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ELSE.
    lv_leng = strlen( lv_svfl ) .
    lv_leng = lv_leng - 1.
    CHECK lv_leng GT 0.
    IF NOT lv_svfl+lv_leng(1) EQ '\'.
      CONCATENATE lv_svfl '\' INTO lv_svfl.
    ENDIF.
  ENDIF.
  p_svfl = lv_svfl.


ENDFORM.                    " AT_SELECTION
*&---------------------------------------------------------------------*
*&      Form  SELECTION
*&---------------------------------------------------------------------*
FORM selection .

  DATA : lv_beg TYPE datum .

  IF pn-begda IS NOT INITIAL .
    lv_beg = pn-begda .
  ELSE .
    lv_beg = sy-datum .
  ENDIF .

  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = lv_beg "SY-DATUM
    IMPORTING
      last_day_of_month = l_date.

*  G_BEGDA = L_DATE.
*  CLEAR pnpbegda.
  lv_beg = l_date.

  gv_yil = lv_beg+0(4).

  CALL FUNCTION '/CPD/GET_MONTH_NAME'
    EXPORTING
*     DATE         = GV_DATE
      language     = sy-langu
      month_number = l_date+4(2)
    IMPORTING
*     LANGU_BACK   =
      longtext     = gv_month
*     SHORTTEXT    =
    EXCEPTIONS
      calendar_id  = 1
      date_error   = 2
      not_found    = 3
      wrong_input  = 4
      OTHERS       = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF p_pdf EQ 'X' AND p_svfl IS INITIAL.
    p_svfl = 'D:/'.
  ENDIF.

ENDFORM.                    " SELECTION
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY_CHECK_BTRTL
*&---------------------------------------------------------------------*
FORM authority_check_btrtl  CHANGING p_subrc.
  DATA : ls_0105 TYPE p0105 .
  DATA : lt_0001 TYPE TABLE OF p0001 WITH HEADER LINE  .


  SELECT SINGLE * FROM pa0105 INTO CORRESPONDING FIELDS OF ls_0105
          WHERE subty EQ '0001'
            AND usrid EQ sy-uname
            AND endda GE sy-datum .
  p_subrc = sy-subrc .
  CHECK p_subrc EQ 0 .
  CLEAR : lt_0001 .
  SELECT * FROM pa0000 AS p0 INNER JOIN pa0001 AS p1
            ON    p0~pernr EQ p1~pernr
              AND p0~begda LE p1~endda
              AND p0~endda GE p1~begda
    INTO CORRESPONDING FIELDS OF TABLE lt_0001
        WHERE p0~pernr EQ ls_0105-pernr
          AND p0~endda GE sy-datum
          AND p0~stat2 EQ '3' .
  p_subrc = sy-subrc .
  CHECK p_subrc EQ 0 .
  CLEAR : pnpbtrtl[] ,pnpbtrtl .
  LOOP AT lt_0001.
    pnpbtrtl-sign   = 'I' .
    pnpbtrtl-option = 'EQ' .
    pnpbtrtl-low    =  lt_0001-btrtl.
    COLLECT  pnpbtrtl.
  ENDLOOP.


  CHECK pnpbtrtl[] IS NOT INITIAL .


  CLEAR : lt_0001 .
  SELECT * FROM pa0000 AS p0 INNER JOIN pa0001 AS p1
            ON    p0~pernr EQ p1~pernr
              AND p0~begda LE p1~endda
              AND p0~endda GE p1~begda
    INTO CORRESPONDING FIELDS OF TABLE lt_0001
        WHERE p0~pernr IN pnppernr[]
          AND p0~endda GE pn-begda
          AND p0~begda LE pn-endda
          AND p1~btrtl IN pnpbtrtl[]
          AND p0~stat2 EQ '3' .
  p_subrc = sy-subrc .
  CHECK p_subrc EQ 0 .
  REFRESH pnppernr.

  LOOP AT lt_0001.
    pnppernr-sign   = 'I' .
    pnppernr-option = 'EQ' .
    pnppernr-low    =  lt_0001-pernr.
    COLLECT  pnppernr.
  ENDLOOP.
ENDFORM.                    " AUTHORITY_CHECK_BTRTL
*&---------------------------------------------------------------------*
*&      Form  F4
*&---------------------------------------------------------------------*
FORM f4  USING p_forml.
  DATA : lv_fieldname TYPE dfies-fieldname .
  DATA : it_return TYPE STANDARD TABLE OF ddshretval,
         wa_return LIKE LINE OF it_return.
*--
  SELECT x~forml y~ftext FROM t514d AS x INNER JOIN t514v AS y
                                                 ON x~forml = y~forml
                                               INTO TABLE gt_forml
                                              WHERE x~class EQ 'CEDT'
                                                AND x~molga EQ '47'
                                                AND y~sprsl EQ sy-langu
                                                .

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FORML'
      dynpprog        = sy-repid
      dynpnr          = '100'
      value_org       = 'S'
    TABLES
      value_tab       = gt_forml[]
      return_tab      = it_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.  EXIT . ENDIF.

  READ TABLE it_return INTO wa_return INDEX 1 .
  CHECK sy-subrc EQ 0 .
  p_forml =  wa_return-fieldval .

ENDFORM.                    " F4
*&---------------------------------------------------------------------*
*&      Form  AUTHORITY-CHECK
*&---------------------------------------------------------------------*
FORM authority-check  CHANGING pv_chk.


  AUTHORITY-CHECK OBJECT 'P_ORGIN'
           ID 'INFTY' FIELD '0003'
           ID 'SUBTY' FIELD space
           ID 'PERSA' FIELD p0001-werks
           ID 'PERSG' FIELD p0001-persg
           ID 'PERSK' FIELD p0001-persk
           ID 'VDSK1' FIELD p0001-vdsk1.
  IF sy-subrc <> 0.
    pv_chk = 'X'.
  ENDIF.

  AUTHORITY-CHECK OBJECT 'P_PCR'
           ID 'ABRKS' FIELD p0001-abkrs
           ID 'ACTVT' FIELD '01'.
  IF sy-subrc <> 0.
    pv_chk = 'X'.
  ENDIF.

*
*  AUTHORITY-CHECK OBJECT 'Z_IST_DEPO'
*  ID 'P_PORGIN' FIELD p0001-vdsk1
*  ID 'P_PCR'    FIELD p0001-abkrs.
*  IF sy-subrc NE 0 .
*    pv_chk = 'X'.
*  ENDIF.
*
*  AUTHORITY-CHECK OBJECT 'Z_MERKEZ&ARGE'
*  ID 'P_PORGIN' FIELD p0001-vdsk1
*  ID 'P_PCR'    FIELD p0001-abkrs.
*  IF sy-subrc NE 0 .
*    pv_chk = 'X'.
*  ENDIF.
*
*  AUTHORITY-CHECK OBJECT 'Z_CERKEZKOY_DEPO'
*  ID 'P_PORGIN' FIELD p0001-vdsk1
*  ID 'P_PCR'    FIELD p0001-abkrs.
*  IF sy-subrc NE 0 .
*    pv_chk = 'X'.
*  ENDIF.
*
*  AUTHORITY-CHECK OBJECT 'Z_MAGAZACILIK'
*  ID 'P_PORGIN' FIELD p0001-vdsk1
*  ID 'P_PCR'    FIELD p0001-abkrs.
*  IF sy-subrc NE 0 .
*    pv_chk = 'X'.
*  ENDIF.
*
*  AUTHORITY-CHECK OBJECT 'Z_ISTDEPO+CERKEZKOYDEPO'
*  ID 'P_PORGIN' FIELD p0001-vdsk1
*  ID 'P_PCR'    FIELD p0001-abkrs.
*  IF sy-subrc NE 0 .
*    pv_chk = 'X'.
*  ENDIF.

*  PERFORM authority_check_btrtl CHANGING gv_subrc .
*  IF gv_subrc NE 0 .
*    MESSAGE 'Yetkiniz bulunamadı!' TYPE 'I'.
*    RETURN.
*  ENDIF.
ENDFORM.
