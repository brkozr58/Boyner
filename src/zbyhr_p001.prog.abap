*&---------------------------------------------------------------------*
*& Report ZBYHR_P001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p001.

TYPE-POOLS : slis .
* Tables
TABLES : pernr   ,
         pcl1   ,
         pcl2   ,
         t512t  .
*INFOTYPES
INFOTYPES : 0000 ,
            0001 ,
            0014 ,
            0015 ,
            0002 ,
            0009 ,
            0772 .
*INCLUDE
INCLUDE :rpppxd00 ,
         rpc2cd09 ,
         rpppxd10 ,
         rpppxm00 ,
         rpc2rx02 ,
         rpc2rx19 ,
         pc2rxtr0 .

DATA : lv_len  TYPE i,
       lv_len1 TYPE i,
       n       TYPE       i,
       m       TYPE      i,
       z       TYPE       i.


DATA  count77(10)  TYPE n VALUE 0 .
DATA : BEGIN OF header_txt  OCCURS 0,
         reptext LIKE  dfies-reptext,
       END OF header_txt           .

DATA : BEGIN OF result OCCURS 0 ,
         resultf(34)              ,
         resultg(49)              ,"resultg(22) iban eklendi resultg(48)
         resultbs(1)              ,"boşluk bir karakter
         resultsn(60)            ,

       END OF result            .

DATA : BEGIN OF result2 OCCURS 0  ,
         line(1024),
       END OF result2.

DATA : flag(1)       ,
       head(9)       ,
       deger(20)     ,
       satir_num(25) .
DATA    count5(10) TYPE n .
DATA : BEGIN OF ptab OCCURS 0       ,
         count(10)  TYPE        n,
         subekod(3)             ,
         bankn(17)              ,
         iban       LIKE p0009-iban,
         pernr      LIKE pernr-pernr,
         vorna      LIKE p0002-vorna,
         nachn      LIKE p0002-nachn,
         bos(9)                 ,
         ay(2)                  ,
         betrg      TYPE string,
         opken(1)               ,
       END OF ptab .
DATA : p_ptab-betrg(19)   .
DATA : t_betrg LIKE p0015-betrg                                       .
DATA : gt_fieldcat TYPE slis_t_fieldcat_alv    WITH HEADER LINE,
       gs_layout   TYPE slis_layout_alv,
       gt_event    TYPE slis_t_event,
       layout      TYPE slis_layout_alv,
       ls_field    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       alv_list    TYPE slis_t_listheader.
DATA: gt_list_top_of_page TYPE slis_t_listheader.
DATA  count TYPE i VALUE  0  .
DATA : BEGIN OF gt_excell OCCURS 0 ,
         count(18) ,
         pernr(20) ,
         ename(35) ,
         lgart(8)  ,
         bankl(15) ,
         bankn(30) ,
         iban(34)  ,
         betrg(30) ,
       END OF gt_excell .
DATA : betrgb LIKE rt-betrg .
DATA : BEGIN OF gt_excell_bas OCCURS 0,
         reptext LIKE  dfies-reptext,
       END OF gt_excell_bas           .

DATA : BEGIN OF alt_t             ,
         lgart LIKE t512t-lgart,
         betrg LIKE rt-betrg,
       END OF alt_t               .

DATA : BEGIN OF gt_table OCCURS 0  ,
         pernr LIKE pernr-pernr,
         ename LIKE p0001-ename,
         alt_t LIKE alt_t OCCURS 0,
       END OF gt_table             .
DATA  convertt LIKE p0015-betrg    .
DATA : BEGIN OF p OCCURS 0   ,
         count TYPE          i,
         pernr LIKE pernr-pernr,
         ename LIKE p0001-ename,
         lgart LIKE p0015-subty,
         bankl LIKE p0009-bankl,
         bankn LIKE p0009-bankn,
         iban  LIKE p0009-iban,
         betrg LIKE  rt-betrg,
       END OF p                        .
DATA h LIKE p OCCURS 0 WITH HEADER LINE    .
DATA ftab LIKE p OCCURS 0 WITH HEADER LINE .
DATA : g_begda TYPE d, g_endda TYPE d     .

DATA : gv_name(10).

DATA : BEGIN OF gv,
         subrc TYPE sy-subrc,
       END OF gv.

DATA : ok_betrg LIKE pa0015-betrg.

DATA : BEGIN OF gt_help OCCURS 0,
         lgart LIKE t512z-lgart,
         lgtxt LIKE t512t-lgtxt,
       END OF gt_help ,
       lt_values TYPE TABLE OF seahlpres,
       lt_fields TYPE TABLE OF dfies,
       lt_return TYPE TABLE OF ddshretval,
       ls_values TYPE seahlpres,
*       ls_field  TYPE dfies,
       ls_return TYPE ddshretval.

* Definitions
DEFINE fieldcat.
  MOVE: &1  TO  ls_field-fieldname   ,
        &2  TO  ls_field-seltext_l   ,
        &3  TO  ls_field-just        ,
        &4 TO   ls_field-do_sum      .
  APPEND ls_field TO gt_fieldcat     .
END-OF-DEFINITION.
DEFINE header .
  MOVE : &1 TO ls_line-typ             ,
         &2 TO ls_line-key             ,
         &3 TO ls_line-info            .
  APPEND ls_line TO  e04_lt_top_of_page.
END-OF-DEFINITION.

* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-bl1     .
  PARAMETERS: p_pdate LIKE pa0015-begda OBLIGATORY.
  PARAMETERS : lgart   LIKE p0015-lgart OBLIGATORY.
*             p_bankl LIKE p0009-bankl  DEFAULT  '0062-00005'.
*SELECT-OPTIONS s_stat2 FOR pernr-stat2 NO INTERVALS DEFAULT 3    .


  PARAMETERS : bordro  RADIOBUTTON GROUP rad1,
               p_ekodm RADIOBUTTON GROUP rad1.
  .

  SELECTION-SCREEN BEGIN OF LINE .

  SELECTION-SCREEN END OF LINE .



SELECTION-SCREEN END OF  BLOCK b1.

PARAMETERS: p_iban AS CHECKBOX DEFAULT 'X' .

*INITIALIZATION
INITIALIZATION             .
  MOVE  '/559' TO lgart    .
  MOVE 'X' TO bordro       .

  pnpxabkr = '01'          .
* Start of Selection

  SELECT * FROM t512z INTO CORRESPONDING FIELDS OF TABLE gt_help
    WHERE ( infty = '0015' OR infty = '0014' )
      AND molga = '47'.

  LOOP AT gt_help.
    SELECT SINGLE * FROM t512t WHERE molga = '47'
                                 AND lgart = gt_help-lgart.

    gt_help-lgtxt = t512t-lgtxt.
    MODIFY gt_help TRANSPORTING lgtxt.
  ENDLOOP.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR lgart.
  PERFORM set_lgart  CHANGING lgart .

AT SELECTION-SCREEN OUTPUT.
  PERFORM output.

START-OF-SELECTION  .
  PERFORM set_initial_values .

  PERFORM set_date  .

GET pernr           .

  PERFORM get_data  .

* End of Selections
END-OF-SELECTION .


  PERFORM create_stable .
  PERFORM set_fieldcat  .
  PERFORM set_layout    .
  PERFORM e04_comment_build  USING gt_list_top_of_page[].
  PERFORM call_alv TABLES p .
  CLEAR : p , p[] .



*&--------------------------------------------------------------------*
*&      Form  ST_PF
*&--------------------------------------------------------------------*
FORM st_pf USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'MENU7' .

ENDFORM.                   " st_pf
*----------------------------------------------------------------------*
*FORM USER_COMMAND
*----------------------------------------------------------------------*
FORM user_command USING i_ucomm     TYPE sy-ucomm
                        is_selfield TYPE slis_selfield.

  CASE i_ucomm .
    WHEN 'BACK' . LEAVE TO SCREEN 0 .
    WHEN 'EXIT'.  LEAVE PROGRAM .
    WHEN 'TXT' .
      PERFORM txt_file .

    WHEN 'BANKA' .
      PERFORM banka .

    WHEN 'SFTP'.
      PERFORM sftp .
  ENDCASE .

ENDFORM.                    " USER_COMM
*&---------------------------------------------------------------------*
*&      Form  SET_LGART
*&---------------------------------------------------------------------*
FORM set_lgart CHANGING it_fieldval TYPE p0015-lgart.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'LGART'
      dynpprog        = sy-repid
      value_org       = 'S'
    TABLES
      value_tab       = gt_help
      field_tab       = lt_fields
      return_tab      = lt_return
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  LOOP AT lt_return INTO ls_return.
    it_fieldval =   ls_return-fieldval.
  ENDLOOP.

  CLEAR : lt_fields[] , ls_return,
          lt_return[] , ls_return.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  OUTPUT
*&---------------------------------------------------------------------*
FORM output .
  LOOP AT SCREEN.
    IF screen-name EQ '%_PNPBUKRS_%_APP_%-OPTI_PUSH'.
      screen-output = 0.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ '%_PNPBUKRS_%_APP_%-VALU_PUSH'.
      screen-output = 0.
      screen-input = 0.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.

*  LOOP AT SCREEN.
    IF screen-name EQ 'PNPBUKRS-LOW'.
      screen-required = 1.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " OUTPUT

*---------------------------------------------------------------------*
*
* FORM SET_DATE .
*----------------------------------------------------------------------*
FORM set_date .

  g_begda = pn-begda.                     .
  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = g_begda
    IMPORTING
      last_day_of_month = g_endda
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  pn-begps = pnpbegps = pn-begda = pnpbegda = g_begda .
  pn-endps = pnpendps = pn-endda = pnpendda = g_endda .


  rp-set-data-interval 'P0000' pn-begda pn-endda.
  rp-set-data-interval 'P0001' pn-begda pn-endda.
  rp-set-data-interval 'P0015' pn-begda pn-endda.
  rp-set-data-interval 'P0009' pn-begda pn-endda.
  rp-set-data-interval 'P0772' pn-begda pn-endda.


ENDFORM.                    " set_date
*&---------------------------------------------------------------------*
*&      Form  get_lgart
*
*----------------------------------------------------------------------*
FORM get_data .

  AUTHORITY-CHECK OBJECT 'P_ORGIN'
     ID 'INFTY' FIELD '0008'
     ID 'AUTHC' FIELD '*'
     ID 'PERSA' FIELD pernr-werks
     ID 'PERSG' FIELD pernr-persg
     ID 'PERSK' FIELD pernr-persk .
  CHECK sy-subrc EQ 0.

  rp-provide-from-last p0000 space pnpbegda pnpendda.
  rp-provide-from-last p0001 space pnpbegda pnpendda.
  rp-provide-from-last p0009 space pnpbegda pnpendda.
  rp-provide-from-last p0014 space pnpbegda pnpendda.
  rp-provide-from-last p0015 space pnpbegda pnpendda.

  CLEAR ok_betrg.

  IF bordro EQ 'X' .
    CLEAR : rt , rt[] .
    PERFORM fiill_rt .
    LOOP AT rt WHERE lgart = lgart   .
      ok_betrg = ok_betrg + rt-betrg.
    ENDLOOP.

    IF ok_betrg LT 0 .
      ok_betrg = ok_betrg * -1.
    ENDIF.

    IF ok_betrg GT 0 .                        .
      PERFORM fill_maintable USING ok_betrg .
      PERFORM fill_bank_format USING ok_betrg 'M' .
    ENDIF                                   .
  ELSE.
    LOOP AT p0015 WHERE subty EQ lgart
                    AND begda LE pnpendda
                    AND begda GE pnpbegda .
      ok_betrg = ok_betrg + p0015-betrg.
    ENDLOOP.
    LOOP AT p0014 WHERE subty EQ lgart
                    AND begda LE pnpendda
                    AND begda GE pnpbegda .
      ok_betrg = ok_betrg + p0015-betrg.
    ENDLOOP.

    IF ok_betrg LT 0 .  "CK Ekleme
      ok_betrg = ok_betrg * -1.
    ENDIF.

    IF ok_betrg GT 0 . "CK Ekleme
      PERFORM fill_maintable USING ok_betrg .
      PERFORM fill_bank_format USING ok_betrg 'E' .
    ENDIF . "CK Ekleme
  ENDIF.

ENDFORM.                    " get_data
*----------------------------------------------------------------------*
*FORM SET FİELDCAT
*----------------------------------------------------------------------*

FORM set_fieldcat .
  CLEAR : gt_fieldcat , gt_fieldcat[] .
  fieldcat :  'COUNT'    'index'              'R'   ' '    ,
              'PERNR'    'Personel Numarası'  'R'   ' '    ,
              'ENAME'    'Adı Soyadı'         'L'   ' '    ,
              'LGART'    'Ücret Türü'         'L'   ' '    ,
              'BANKL'    'Bank Adı'           'L'   ' '    ,
              'BANKN'    'Banka Hesabı'       'R'   ' '    ,
              'IBAN'     'IBAN Numarası'      'L'   ' '    ,
              'BETRG'    'Tutar'              'R'   'X'    .

  IF p_iban NE 'X' .
    DELETE gt_fieldcat WHERE fieldname = 'IBAN' .
  ENDIF.

ENDFORM.                    " set_fieldcat
*----------------------------------------------------------------------*
*  FORM SET LAYOUT
*----------------------------------------------------------------------*

FORM set_layout .

  gs_layout-no_input          = 'X'        .
  gs_layout-colwidth_optimize = 'X'        .
  gs_layout-zebra             = 'X'        .
  gs_layout-detail_popup      = 'X'        .

ENDFORM.                    " set_layout
* --------------------------------------------------------------------
*FORM CALL ALV
*----------------------------------------------------------------------

FORM call_alv TABLES p_table .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'ST_PF'
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat[]
    TABLES
      t_outtab                 = p_table.

ENDFORM.                    " call_alv
* ---------------------------------------------------------------------
* EXCELL DOSYASI
*----------------------------------------------------------------------*
FORM create_stable .

  CLEAR : gt_excell , gt_excell[] .
  LOOP AT p .
    MOVE : p-count TO  gt_excell-count        ,
           p-pernr TO  gt_excell-pernr        ,
           p-ename TO  gt_excell-ename        ,
           p-lgart TO  gt_excell-lgart        ,
           p-bankl TO  gt_excell-bankl        ,
           p-bankn TO  gt_excell-bankn        ,
           p-betrg TO  gt_excell-betrg        ,
           p-iban  TO  gt_excell-iban         .
    APPEND gt_excell                          .
    CLEAR gt_excell .
  ENDLOOP                                     .


ENDFORM.                    " create_stable
* ---------------------------------------------------------------------*
*FORM EXCEL_HEADER
*----------------------------------------------------------------------*
FORM excel_header .

  CLEAR : gt_excell_bas , gt_excell_bas[] .
  gt_excell_bas-reptext = 'İndex' .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'Personel No' .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'adı soyadı'  .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'Ücret Türü'  .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'Banka Adı' .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'Banka Hesabı' .
  APPEND  gt_excell_bas .
  IF p_iban = 'X'.
    CLEAR : gt_excell_bas .
    gt_excell_bas-reptext = 'IBAN Numarası' .
    APPEND  gt_excell_bas .
  ENDIF.
  CLEAR : gt_excell_bas .
  gt_excell_bas-reptext = 'Tutar'        .
  APPEND  gt_excell_bas .
  CLEAR : gt_excell_bas .

ENDFORM.                    " excel_header
*----------------------------------------------------------------------*
* form ALV_HEADER
*
*----------------------------------------------------------------------*

FORM e04_comment_build USING e04_lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.
  DATA : tar(8) .
  MOVE :  pn-begda+4(2) TO tar+0(2) ,
          pn-begda+0(4) TO tar+3(4) .
  CLEAR  : e04_lt_top_of_page , e04_lt_top_of_page[] .
  header : 'H'   '' 'HR'     ,
           'S'   'DÖNEM'  tar              ,
           'S'   'SEÇİM'  head             .

ENDFORM.                    "E04_COMMENT_BUILD

*&--------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&--------------------------------------------------------------------*
FORM top_of_page .
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_list_top_of_page[].


ENDFORM.                    " TOP_OF_PAGE
*----------------------------------------------------------------------*
* fill rt
*----------------------------------------------------------------------*
FORM fiill_rt .
  cd-key-pernr = pernr-pernr ."rgdir tablosunun key alanı
  rp-imp-c2-cd .
  CHECK : rp-imp-cd-subrc = 0               .
  READ TABLE rgdir WITH KEY fpper = pn-paper .
  CHECK : sy-subrc  = 0                     .
  rx-key-pernr = pernr-pernr ."rt tablosunun key alanı
  UNPACK rgdir-seqnr TO rx-key-seqno        .
  rp-imp-c2-tr                              .
  CHECK : rp-imp-tr-subrc = 0               .


ENDFORM.                    " FIILL_RT
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_maintable USING p_betrg  .
  CLEAR  p              .
  CHECK p_betrg <> 0 .
  count = count + 1      .
  p-count = count       .
  p-pernr = pernr-pernr .
  p-ename = p0001-ename .
  p-lgart = lgart       .
  p-bankl = p0009-bankl     .
  p-bankn = p0009-bankn .
  p-betrg = p_betrg     .
  p-iban  = p0009-iban  .
  APPEND p              .

ENDFORM.                    " FILL_MAINTABLE
*&---------------------------------------------------------------------*
*&      Form  set_initial_values
*&---------------------------------------------------------------------*
FORM set_initial_values                      .
  CLEAR : p , p[]                            .
  CLEAR : flag , head                        .

  IF bordro EQ 'X'                           .
    MOVE 'X' TO flag                         .
    MOVE 'BORDRO' TO head                    .
  ELSE                                       .
    MOVE 'Y' TO flag                         .
    MOVE 'AVANS' TO head                     .
  ENDIF                                      .

ENDFORM.                    " set_initial_values
*&---------------------------------------------------------------------*
*&      Form  FILL_BANK_FORMAT
*&---------------------------------------------------------------------*
FORM fill_bank_format USING p_betrg p_opken .

  ADD 1 TO count5                      .

  MOVE : count5 TO ptab-count         ,
       '003' TO ptab-subekod       ,
        p0009-bankn  TO ptab-bankn  .
  UNPACK ptab-bankn TO ptab-bankn .
  MOVE : '00158' TO ptab-bankn+0(5) ,
  pernr-pernr    TO ptab-pernr  ,
  p0002-vorna    TO ptab-vorna  ,
  p0002-nachn    TO ptab-nachn  ,
  '          '   TO ptab-bos    ,
  pn-begda+4(2)  TO ptab-ay     ,
  p_betrg        TO ptab-betrg  ,
  p_opken        TO ptab-opken  ,
  p0009-iban     TO ptab-iban   .
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = ptab-count
    IMPORTING
      output = ptab-count.

  APPEND ptab .
  CLEAR ptab  .

ENDFORM.                    " FILL_BANK_FORMAT
*&---------------------------------------------------------------------*
*&      Form  find_emptyone
*&---------------------------------------------------------------------*
FORM find_emptyone .
  LOOP AT p .
    IF p-count = ' ' OR p-pernr = ' ' OR p-ename = ' ' OR p-lgart = ' '
OR p-bankl = ' ' OR p-bankn = ' ' OR p-betrg = ' ' .
      h-count = p-count .
      h-pernr = p-pernr .
      h-ename = p-ename .
      h-lgart = p-lgart .
      h-bankl = p-bankl .
      h-bankn = p-bankn .
      h-betrg = p-betrg .
      APPEND h .
    ENDIF .
  ENDLOOP .
  PERFORM call_alv TABLES h .

ENDFORM.                    " find_emptyone
*&---------------------------------------------------------------------*
*&      Form  unpac
*&---------------------------------------------------------------------*
FORM unpac .
  LOOP AT ptab .
    CHECK ptab-betrg <> 0 .
    ADD 1 TO count77 .
    lv_len = strlen( ptab-betrg ) - 1 .
    UNPACK ptab-betrg TO p_ptab-betrg .
    CONCATENATE  ptab-subekod  ptab-bankn '0000' ptab-pernr
    INTO result-resultf .
    n = 18 - lv_len  .
    m = lv_len + 1      .
    MOVE ptab-betrg  TO p_ptab-betrg+n(m) .
    UNPACK ptab-ay TO ptab-ay .
    CONCATENATE  ptab-ay p_ptab-betrg  ptab-opken
                              INTO result-resultg .
    IF p_iban = 'X' .
      CONCATENATE result-resultg ptab-iban INTO result-resultg.
    ENDIF.

    CONCATENATE result-resultg 'TL' INTO result-resultg.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = count77
      IMPORTING
        output = count77.

*    CONCATENATE  PTAB-VORNA PTAB-NACHN COUNT77  INTO RESULT-RESULTSN .
    ADD ptab-betrg TO betrgb .
    APPEND result .CLEAR result.
  ENDLOOP .
  CLEAR result .
  WRITE betrgb TO p_ptab-betrg NO-ZERO .
  CONCATENATE p_ptab-betrg 'TL' INTO result-resultg.
  WRITE result-resultg TO result-resultg RIGHT-JUSTIFIED .
  APPEND result .
ENDFORM.                    " unpac
*&---------------------------------------------------------------------*
*&      Form  CREATE_TXT
*&---------------------------------------------------------------------*
FORM create_txt .
  DATA: BEGIN OF ls_baslik,
          tip(1),
          kurumkod(9),
          subekod(5),
          hesap(7),
          doviz(3),
          odemetip(1),
          izahat(38),
        END OF ls_baslik.

  DATA: BEGIN OF ls_detay_hsp,
          tip(1)                ,
          hdf_bank(5)    TYPE n,
          hdf_sube(5)    TYPE n,
          hdf_hsp1(19)   TYPE n,
          hdf_iban(26),
          alici_unv(30)         ,
          alc_tcno(11)   TYPE n,
          alc_pn(10)     TYPE n,
          tarih(8)       TYPE n,
          tutar(16) ,
*        tutar(16) TYPE p DECIMALS 2,
          muh_izahat(38),
          alc_izahat(38) ,
        END OF ls_detay_hsp   .


  DATA: BEGIN OF ls_sonuc,
          tip,
          dty_kyt(5) TYPE n,
          toplam(18),
        END OF ls_sonuc.

  DATA: ls_p0001 LIKE p0001.

  DATA: lv_lines     TYPE int4,
        lv_betrg     LIKE ptab-betrg,
        lv_merni     LIKE p0770-merni,
        lv_lngth     TYPE int2,
        lv_zeros(18),
        lv_datum     TYPE sy-datum.

  CLEAR result2[].

  SELECT SINGLE * FROM zbyhr_t001 INTO @DATA(ls_t005)
     WHERE bukrs EQ @pnpbukrs-low.



  ls_baslik-tip       = 'H'.
  ls_baslik-kurumkod  = ls_t005-kurkod. "'000144833'.
  ls_baslik-subekod   = ls_t005-subkod.                     "'01678'.
  ls_baslik-hesap     = ls_t005-hspno.                      "'6286630'.
  CASE 'X'.
    WHEN bordro.
      ls_baslik-odemetip  = 'M'.
      ls_baslik-izahat    = 'MAAŞ ÖDEMESİ'.
    WHEN OTHERS.
      IF lgart = '9AVN'.
        ls_baslik-odemetip  = 'N'.
        ls_baslik-izahat    = 'İş Avansı Ödemesi'.
      ELSEIF lgart = '3500'.
        ls_baslik-odemetip  = 'N'.
        ls_baslik-izahat    = 'Maaş Avansı Ödemesi'.
      ELSE.
        ls_baslik-odemetip  = 'Z'.
        ls_baslik-izahat    = 'Diğer'.
      ENDIF.
  ENDCASE.



  gv_name = ls_baslik-izahat.

  DATA : gv_blank TYPE c VALUE cl_abap_char_utilities=>backspace.
  gv_blank = cl_abap_conv_in_ce=>uccp( '00a0' ).

  " aydın ayyıldız boşluk ekledi
  DO 26 TIMES.
    CONCATENATE  ls_baslik-izahat gv_blank INTO ls_baslik-izahat.
  ENDDO.
  " aydın ayyıldız boşluk ekledi
  APPEND ls_baslik TO result2.



  DATA : lv_ver(8),
         lv_ver2(7).

  LOOP AT ptab.
    ADD 1 TO lv_lines.
    lv_betrg = lv_betrg + ptab-betrg.

    SELECT SINGLE * FROM pa0009 INTO @DATA(ls_9)
      WHERE pernr EQ @ptab-pernr
       AND  begda LE @sy-datum
       AND  endda GE @sy-datum.

    SPLIT ls_9-bankl AT '-' INTO lv_ver lv_ver2.


    ls_detay_hsp-tip      = 'D'.
    ls_detay_hsp-hdf_bank = ''.
    ls_detay_hsp-hdf_sube = lv_ver2.
    ls_detay_hsp-hdf_hsp1 = ''.
    ls_detay_hsp-hdf_iban = ptab-iban.
    CONCATENATE ptab-vorna ptab-nachn
    INTO ls_detay_hsp-alici_unv SEPARATED BY space.
    SELECT SINGLE merni FROM pa0770 INTO lv_merni
                                   WHERE pernr EQ ptab-pernr
                                     AND subty EQ '01'
                                     AND endda GE sy-datum.

    CLEAR : ls_9, lv_ver, lv_ver2.

    DO 10 TIMES.
      CONCATENATE gv_blank ls_detay_hsp-alc_pn INTO ls_detay_hsp-alc_pn.
    ENDDO.
    ls_detay_hsp-alc_tcno = lv_merni.
    ls_detay_hsp-tarih    = p_pdate.
    UNPACK ptab-betrg TO ls_detay_hsp-tutar .
    ls_detay_hsp-tutar = ls_detay_hsp-tutar+1(13) && '.' &&
    ls_detay_hsp-tutar+14(2) .

    IF lgart = '/559'.
      SELECT COUNT(*) FROM pa0001 WHERE pernr EQ ptab-pernr
                                    AND endda GE sy-datum
                                    AND persk IN ('DD', 'DI', 'ST').
      IF sy-subrc = 0.
        ls_detay_hsp-alc_izahat    = 'MAAŞ ÖDEMESİ'.
        ls_detay_hsp-muh_izahat    = 'MAAŞ ÖDEMESİ'.
      ELSE.
        ls_detay_hsp-alc_izahat    = 'MAAŞ ÖDEMESİ'.
        ls_detay_hsp-muh_izahat    = 'MAAŞ ÖDEMESİ'.
      ENDIF.
    ELSEIF lgart = '3500'.
      ls_detay_hsp-alc_izahat    = 'Maaş Avansı Ödemesi'.
      ls_detay_hsp-muh_izahat    = 'Maaş Avansı Ödemesi'.
    ELSEIF lgart = '9AVN'.
      ls_detay_hsp-alc_izahat    = 'İş Avansı Ödemesi'.
      ls_detay_hsp-muh_izahat    = 'İş Avansı Ödemesi'.
    ENDIF.

    " aydın ayyıldız boşluk ekledi
    DO 26 TIMES.
      CONCATENATE  ls_detay_hsp-alc_izahat gv_blank
        INTO ls_detay_hsp-alc_izahat.
    ENDDO.
    " aydın ayyıldız boşluk ekledi
    APPEND ls_detay_hsp TO result2.



    CLEAR: ptab, ls_detay_hsp, lv_lngth, lv_zeros,
           ls_p0001.
  ENDLOOP.

  ls_sonuc-tip = 'T'.
  ls_sonuc-dty_kyt = lv_lines.
  ls_sonuc-toplam  = lv_betrg.
  lv_lngth = strlen( ls_sonuc-toplam ).
  lv_lngth = 18 - lv_lngth.
  DO lv_lngth TIMES.
    CONCATENATE '0' lv_zeros INTO lv_zeros.
  ENDDO.
  CONCATENATE lv_zeros ls_sonuc-toplam INTO ls_sonuc-toplam.
  APPEND ls_sonuc TO result2.

ENDFORM.                    " CREATE_TXT
*&---------------------------------------------------------------------*
*&      Form  TXT_FILE
*&---------------------------------------------------------------------*
FORM txt_file .

  PERFORM excel_header .

  DATA: ld_filename TYPE string,
        ld_path     TYPE string,
        ld_fullpath TYPE string,
        ld_result   TYPE  i.

  DATA: default_file_name TYPE string.
  CLEAR:default_file_name.


  default_file_name =  'TEST.xls'.

  " dosyanın oluşturulması
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
*     window_title      = ' '
      default_extension = 'txt'
      default_file_name = default_file_name
      initial_directory = 'C:\'
    CHANGING
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = ld_fullpath "'C:\plan.xls'
      filetype                = 'DBF'
    TABLES
      data_tab                = gt_excell
      fieldnames              = gt_excell_bas
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  CLEAR : gt_excell_bas , gt_excell_bas[] .
  CLEAR : gt_excell , gt_excell[] .
*    WHEN 'HATALI' .
*      PERFORM find_emptyone .
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BANKA
*&---------------------------------------------------------------------*
FORM banka .

  DATA : lv_filename TYPE string.
  DATA : gd_filename TYPE string,
         gd_path     TYPE string,
         gd_fullpath TYPE string,
         gd_result   TYPE i.
  DATA : l_encod TYPE abap_encod VALUE 4110.

  lv_filename = 'C:\GARANTIBANKASI' && p_pdate && gv_name.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Banka Dosyası için Konum Seçiniz.'
      initial_directory = 'C:\'
      default_extension = 'TXT'
      default_file_name = lv_filename
    CHANGING
      filename          = gd_filename
      path              = gd_path
      fullpath          = gd_fullpath
      user_action       = gd_result.
*
  IF gd_fullpath IS INITIAL.
    MESSAGE 'İşlem iptal edildi.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  PERFORM create_txt .

  CLEAR :header_txt , header_txt[] .
  header_txt-reptext = 'ilk' .
  APPEND header_txt .
  CLEAR : header_txt .
  header_txt-reptext = 'boş' .
  APPEND header_txt .
  CLEAR : header_txt.
  header_txt-reptext = 'son' .
  APPEND header_txt .
  CLEAR : header_txt .

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = gd_fullpath
      filetype                = 'ASC'
      show_transfer_status    = abap_true
    TABLES
      data_tab                = result2
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SFTP
*&---------------------------------------------------------------------*
FORM sftp .
  DATA : lo_sftp TYPE REF TO zbyhr_cl001."Banka Disketleri SFTP
  DATA : text_question TYPE text100.
  DATA : popup_return.
  DATA : s_file	TYPE zbyhr_s001.
  DATA : hex_tab  TYPE solix_tab.

  CREATE OBJECT lo_sftp
    EXPORTING
      "tcode = 'ZHRP001'. "Garanti Bankası Disketi
      tcode = sy-tcode. "Garanti Bankası Disketi

  text_question = 'Bilgiler bankaya iletilecek. Devam edilsin mi?'.
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Uyarı ! '
      text_question         = text_question
      text_button_1         = 'Evet'
      text_button_2         = 'Hayır'
      default_button        = '2'
      display_cancel_button = 'X'
    IMPORTING
      answer                = popup_return
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF popup_return EQ '1'.
    CLEAR : gv_name.
    REFRESH result2.

    PERFORM create_txt .
    IF result2[] IS NOT INITIAL .
      s_file-bukrs = pnpbukrs-low.
      s_file-spmon = p_pdate.
      s_file-pname = 'GARANTIBANKASI' && p_pdate && gv_name.
      lo_sftp->file_convert_binary(
        EXPORTING
          t_data   = result2[]
        IMPORTING
          e_binary = s_file-bin_file
          e_data   = s_file-data_file
      ).

      CALL METHOD lo_sftp->rest_trasnport_file
        CHANGING
          s_file = s_file.

      IF s_file-return IS NOT INITIAL .
        MESSAGE s_file-return TYPE 'I' DISPLAY LIKE 'I'.
      ENDIF.
    ELSE.
      MESSAGE 'Veri bulunamadı ' TYPE 'E' DISPLAY LIKE 'I'.
    ENDIF.
  ENDIF.
ENDFORM.
