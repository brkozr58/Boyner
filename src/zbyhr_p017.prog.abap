*&---------------------------------------------------------------------*
*& Report  ZBYHR_P017
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p017  LINE-SIZE 139 NO STANDARD PAGE HEADING.

* 4.70
* L6BK032820   04/03 note 616122
* 4.6C LCP
* L9CK024231   09/00 note 335072
* 4.6A
* AHRK044783   03/99 Delete transparent RGDIR and WPBP if they exist
* 4.5
* AHRK02360100 09/98 Read Molga from cluster CU instead of infotypes
************************************************************************
*  Includes                                                            *
************************************************************************
INCLUDE <icon>.
*********************************************************************
*   Tables
*********************************************************************
TABLES: t500l, pcl1,pcl2,pernr, t000,
        "t500p out AHRK02360100
        hrpy_rgdir,                    "transparent RGDIR  "AHRK044783
        hrpy_wpbp,                     "transparent WPBP   "AHRK044783
        hrpy_grouping,s001.                 " Note 616122
INFOTYPES: 0000,0001.
INCLUDE   rpc2cd00   .
INCLUDE   rpc2rxx0   .
INCLUDE   rpc2rx00   .
INCLUDE   rpppxd00   .
INCLUDE   rpppxd10   .
INCLUDE   rpppxm00   .
INCLUDE   htrpaymacro.
INCLUDE   pc2rxtr0   .
*********************************************************************
*   DATA
*********************************************************************
DATA : gv_begda TYPE begda,
       gv_endda TYPE endda.
SELECTION-SCREEN BEGIN OF BLOCK 100 WITH FRAME TITLE TEXT-000.
  PARAMETERS : s_fpper LIKE s001-spmon OBLIGATORY DEFAULT sy-datum.
  PARAMETERS :   p_srtza  LIKE rgdir-srtza DEFAULT 'A'.
  SELECTION-SCREEN BEGIN OF LINE .
*SELECTION-SCREEN COMMENT (31) TEXT-rp5 FOR FIELD p_payty .
*PARAMETERS :   p_payty TYPE payty   .
*PARAMETERS :   p_fbbeg TYPE sy-datum   .
  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN   END OF BLOCK 100.
DATA: BEGIN OF return,                 "returncode
        back(4)         VALUE  'BACK',
        exit(4)         VALUE  'EXIT',
        show(4)         VALUE  'SHOW',
        canc(4)         VALUE  'CANC',
        sort(4)         VALUE  'SORT',
        del(4)          VALUE  'DEL ',
        entmark(4)      VALUE  'ENTM',
        markall(4)      VALUE  'MARK',
        expand_all(4)   VALUE  'EXPA',
        collapse_all(4) VALUE  'COLL',
      END OF return.

DATA: persnr          LIKE pernr-pernr,
      previous_persnr LIKE persnr.
DATA: c_pernr(8), c_seqnr(5).
DATA: country_grouping  LIKE t500p-molga.  "type numc(2)
DATA: relid LIKE t500l-relid.
DATA: sortfield(40).
RANGES: sortfd FOR sortfield.

*DATA: rgdir LIKE pc261 OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF list_rgdir OCCURS 0,
        persnr LIKE persnr,
        selec  TYPE c.
        INCLUDE STRUCTURE pc261.
DATA: END OF list_rgdir.
DATA: hide_seqnr    LIKE pc261-seqnr,
      clicked_seqnr LIKE pc261-seqnr,
      hide_persnr   LIKE persnr.

DATA: first     TYPE i VALUE 1,        " 1 before first print_list, 0 after.
      line_no_x TYPE i.
DATA: answer(1) TYPE c.
DATA: BEGIN OF deleted_list OCCURS 0,                       "QNY240997
        persnr LIKE persnr,
        fpper  LIKE pc261-fpper,
        inper  LIKE pc261-inper,
        bondt  LIKE rgdir-bondt,                            "QNY021097
        payid  LIKE rgdir-payid,                            "QNY021097
      END OF deleted_list.
* --------  DATA & CONSTANTS FOR PROTOCOL   -----------------
DATA: prot_obj LIKE balhdr-object VALUE 'HRPU'.
DATA: prot_mes LIKE balmi OCCURS   0 WITH HEADER LINE.
"used as interface to function appl_log_write_messages
DATA: BEGIN OF prot_nr OCCURS 1.        "interface for appl_log_write_db
        INCLUDE STRUCTURE balnri.
DATA: END OF prot_nr.
*---------  Data for more than 1 pernr - functionality ---------------
DATA: BEGIN OF persnr_list OCCURS 0 ,
        selec  TYPE c,
        persnr LIKE persnr,
        ename  TYPE emnam,
        molga  LIKE country_grouping,
        relid  LIKE relid,
      END OF persnr_list.
DATA: BEGIN OF bad_persnr_list OCCURS 0,
        persnr    LIKE persnr,
        texts(50),
      END OF bad_persnr_list.
DATA: fieldname(30). "for get cursor command at line-selection
DATA: display_bad,   "display enqueued or bad pers. numbers? 'X' = yes
      display_deleted.     "display deleted payroll results? 'X' = yes
DATA: hide_icontype(6).
CONSTANTS: g_mod(1) TYPE c VALUE ' '.
DEFINE rp-exp-c2-tr_x.
  EXPORT
     tr-version FROM otr-version
     versc
     wpbp
     abc
     rt
     crt
     bt
     c0
     c1
     v0
     vcp
     alp
     dft
     grt
     ls
     status
     arrrs
     ddntk
     accr
     bentab
     ab
     fund
     average
     modif
     codist
  TO DATABASE zbyhr_t025(tr) ID rx-key.
END-OF-DEFINITION.

************************************************************************
*PERFORM CHECK_CLIENT.
************************************************************************
INITIALIZATION.
  PERFORM check_aut.

START-OF-SELECTION.
  CONCATENATE s_fpper '01' INTO gv_begda.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = gv_begda
    IMPORTING
      last_day_of_month = gv_endda
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.
  pn-begda = pnpbegda = pn-begps = pnpbegps = gv_begda.
  pn-endda = pnpendda = pn-endps = pnpendps = gv_endda.
  rp-set-data-interval 'P0000' pnpbegda pnpendda.
  rp-set-data-interval 'P0001' pnpbegda pnpendda.

GET pernr.
************************************************************************
*---Cihat
  rp-provide-from-last p0000 space pnpbegda pnpendda.
  rp-provide-from-last p0001 space pnpbegda pnpendda.
  CHECK p0001-pernr IN pnppernr
    AND p0001-bukrs IN pnpbukrs
    AND p0001-werks IN pnpwerks
    AND p0001-btrtl IN pnpbtrtl
    AND p0001-persg IN pnppersg
    AND p0001-persk IN pnppersk
    AND p0001-orgeh IN pnporgeh
    AND p0001-plans IN pnpplans
    AND p0001-stell IN pnpstell
    AND p0001-kostl IN pnpkostl
    AND p0001-abkrs IN pnpabkrs
    AND p0001-vdsk1 IN pnpvdsk1
    AND p0001-ansvh IN pnpansvh
    AND p0001-gsber IN pnpgsber
    AND p0001-kokrs IN pnpkokrs
    AND p0000-stat2 IN pnpstat2.
*---Cihat
  persnr = pernr-pernr.                                "AHRK02360100 begin
*------- get country of personnel number
*(needed for authority check on cluster & for REBUILD_PAYROLL_DIRECTORY)

  PERFORM check_authority USING 'CU'.

  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      persnr          = pernr-pernr
    IMPORTING
      molga           = country_grouping
    TABLES
      in_rgdir        = rgdir
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    bad_persnr_list-persnr = persnr.
    IF sy-subrc = 1.
      bad_persnr_list-texts = 'has no payroll results!'(072).
    ELSE.
      CLEAR bad_persnr_list-texts.
    ENDIF.
    COLLECT bad_persnr_list.
    REJECT.
  ENDIF.
  REFRESH rgdir.

* reading from infotype deleted                        "AHRK02360100 end

*------- get RELID (area identification for MOLGA in import/export
*                  data base PCL2)                           -----------
  IF country_grouping IS INITIAL. country_grouping = '47'. ENDIF.
  SELECT SINGLE * FROM t500l
  WHERE molga = country_grouping.
  relid = t500l-relid.
  IF sy-subrc NE 0.   "ie no entry in table T500L for Molga=country_gr
    bad_persnr_list-persnr = persnr.
    CONCATENATE
       'No entry in table T500L for Molga = '(009)
        country_grouping
        INTO bad_persnr_list-texts.
    COLLECT bad_persnr_list.
  ENDIF.

*------- authority check  ---------------------
  PERFORM check_authority USING relid.

*------- enqueue personnel number ------------ move !! qnytest
  PERFORM enqueue_pernr IN PROGRAM sapfp50g
                          USING  persnr space.
  IF sy-subrc NE 0.                  "pernr is already enqueued
    bad_persnr_list-persnr = persnr.
    CONCATENATE 'enqueued by user: '(073)
                sy-msgv1             "user who has enqueued pernr
                INTO  bad_persnr_list-texts.
    COLLECT bad_persnr_list.
  ELSE.
*------- fill table with payroll records ---------------------
    PERFORM fill_rgdir TABLES list_rgdir rgdir
                       USING persnr.

*------- add persnr to list of successful persnr -------------
    persnr_list-persnr = persnr.
    persnr_list-ename  = p0001-ename.
    persnr_list-molga  = country_grouping.
    persnr_list-relid  = relid.
    COLLECT persnr_list.
  ENDIF.
*qnytest endprovide.

************************************************************************
END-OF-SELECTION.                   " end of loop over personnel numbers
************************************************************************

*------- print list of payroll results ---------------
  PERFORM print_persnr_list TABLES   list_rgdir persnr_list
                            CHANGING hide_seqnr hide_persnr
                                     display_bad display_deleted.
************************************************************************
AT USER-COMMAND.
************************************************************************
  PERFORM maintain_list TABLES list_rgdir
                        USING  hide_seqnr clicked_seqnr hide_persnr.
  "clicked_seqnr only non-initial at double click!
  CASE sy-ucomm.
    WHEN return-del.
      PERFORM delete_payroll_results.
    WHEN return-entmark.                                    "select none
      LOOP AT list_rgdir.
        list_rgdir-selec = ' '.
        MODIFY list_rgdir.
      ENDLOOP.
    WHEN return-markall.                                     "select all
      LOOP AT list_rgdir.
        list_rgdir-selec = 'X'.
        MODIFY list_rgdir.
      ENDLOOP.
    WHEN return-exit.
      PERFORM dequeue_pernr IN PROGRAM sapfp50g
                             USING persnr.
      LEAVE PROGRAM.
    WHEN return-canc.
      PERFORM dequeue_pernr IN PROGRAM sapfp50g
                             USING persnr.
      LEAVE TO SCREEN 0.
    WHEN return-expand_all.
      LOOP AT persnr_list.
        persnr_list-selec = 'X'.
        MODIFY persnr_list.
      ENDLOOP.
    WHEN return-collapse_all.
      LOOP AT persnr_list.
        persnr_list-selec = ' '.
        MODIFY persnr_list.
      ENDLOOP.
  ENDCASE.
  PERFORM print_persnr_list TABLES   list_rgdir  persnr_list
                            CHANGING hide_seqnr  hide_persnr
                                     display_bad display_deleted.
  sy-lsind = 0.
************************************************************************
AT LINE-SELECTION .
************************************************************************
  GET CURSOR FIELD fieldname .

  IF fieldname = 'ICON_EXPAND'.        "expand list for current persnr
    IF hide_icontype = 'BADIN '.                            "QNY270997
      display_bad = 'X'.                                    "QNY270997
    ELSEIF hide_icontype = 'DELIN '.                        "QNY270997
      display_deleted = 'X'.                                "QNY270997
    ELSE.                                                   "QNY270997
      LOOP AT persnr_list WHERE persnr = hide_persnr.
        persnr_list-selec = 'X'.
        MODIFY persnr_list.
      ENDLOOP.
    ENDIF.                                                  "QNY270997
  ELSEIF fieldname = 'ICON_COLLAPSE'.  "collapse list for current persnr
    IF hide_icontype = 'BADOUT'.                            "QNY270997
      display_bad = ' '.                                    "QNY270997
    ELSEIF hide_icontype = 'DELOUT'.                        "QNY270997
      display_deleted = ' '.                                "QNY270997
    ELSE.                                                   "QNY270997
      LOOP AT persnr_list WHERE persnr = hide_persnr.
        persnr_list-selec = ' '.
        MODIFY persnr_list.
      ENDLOOP.
    ENDIF.                                                  "QNY270997
  ELSEIF fieldname = 'ICON_SELECT_ALL'."select all results for curr.per
    LOOP AT list_rgdir WHERE persnr = hide_persnr.
      list_rgdir-selec = 'X'.
      MODIFY list_rgdir.
    ENDLOOP.
  ELSEIF fieldname = 'ICON_DESELECT_ALL'. "deselect results for curr.per
    LOOP AT list_rgdir WHERE persnr = hide_persnr.
      list_rgdir-selec = ' '.
      MODIFY list_rgdir.
    ENDLOOP.
  ELSE.         "if there was double click on a line in list_rgdir table
    " toggle between 'selected' and 'not selected'.
    IF NOT hide_seqnr IS INITIAL.                           "QNY270997
      CLEAR clicked_seqnr.
      clicked_seqnr = hide_seqnr.
    ELSE.                                                   "QNY270997
      CLEAR clicked_seqnr.                                  "QNY270997
    ENDIF.                                                  "QNY270997
  ENDIF.

  IF    fieldname NE 'ICON_DESELECT_ALL'
    AND fieldname NE 'ICON_SELECT_ALL'.     "maintain_list would delete
    "the entries made by these 2
    PERFORM maintain_list TABLES list_rgdir
                          USING hide_seqnr clicked_seqnr hide_persnr.
  ENDIF.
  CLEAR: clicked_seqnr,
         hide_seqnr,
         hide_persnr,
         hide_icontype.

  PERFORM print_persnr_list TABLES   list_rgdir  persnr_list
                            CHANGING hide_seqnr  hide_persnr
                                     display_bad display_deleted.
  sy-lsind = 0.
  CLEAR fieldname.
*-------------------   form routines   ---------------------------------
************************************************************************
FORM delete_payroll_results.
************************************************************************
*     check if payroll results were selected for deletion
  LOOP AT list_rgdir WHERE selec NE ' '.
    EXIT.
  ENDLOOP.
  IF sy-subrc NE 0.
    MESSAGE e015(5a) WITH 'payroll result'(004).
    "choose payroll result, please
  ENDIF.
*     really delete ?
  CLEAR answer.
  CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
    EXPORTING
      defaultoption = 'N'
      diagnosetext1 = TEXT-020   "warning against inconsistency
      diagnosetext2 = TEXT-021
*     diagnosetext3 = TEXT-020   "red = already booked!
      textline1     = TEXT-023
*     textline2     = TEXT-023   "delete nevertheless?
      titel         = 'Delete?'(026)
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = answer
    EXCEPTIONS
      OTHERS        = 1.
  IF sy-subrc NE 0.
    MESSAGE e241(57)  "error in function module &1 with return code &2
                       WITH   'POPUP_TO_CONFIRM_WITH_MESSAGE'  sy-subrc.
  ENDIF.
  IF answer =  'J'.                                             "delete!
* fill table with first keyfield of pcl2:  sortfield (pernr,seqnr)
    REFRESH sortfd.
    LOOP AT persnr_list.
      LOOP AT list_rgdir WHERE
        persnr = persnr_list-persnr AND
        selec  NE  ' '.
*  pernr + seqnr -> char field sortfield (pcl2-srtfd)
        MOVE list_rgdir-persnr TO c_pernr.
        MOVE list_rgdir-seqnr  TO c_seqnr.
* fill internal table with 'sortfield' of all selected entries
        CONCATENATE c_pernr c_seqnr INTO sortfd-low.
        sortfd-sign = 'I'.    "in
        sortfd-option = 'EQ'. "equal
        APPEND sortfd.
*---Cihat
        rx-key-pernr = list_rgdir-persnr.
        UNPACK list_rgdir-seqnr  TO rx-key-seqno.
        rp-imp-c2-tr.
        CHECK sy-subrc = 0.
        rp-exp-c2-tr_x.
*---Cihat
      ENDLOOP.
* if no sequence number is selected (sy-subrc = 4), exit the loop
* to avoid deletion with empty sortfd.
* (if sortfd was empty, EVERYTHING on the cluster would be deleted!)
*  delete  entries with key fields in table sortfield_tab
      CHECK sy-subrc = 0.
      DELETE FROM pcl2
        WHERE relid = persnr_list-relid
        AND  srtfd IN sortfd.

      IF sy-subrc = 0.                 "delete transparent RGDIR /WPBP &
        "write only successful deletions
        "into application log
        LOOP AT list_rgdir WHERE persnr = persnr_list-persnr
                           AND   selec NE ' '.
*     delete transparent RGDIR and WPBP if they exist
*     (they may not exist for old results, then it is no problem anyway)
          DELETE FROM hrpy_rgdir WHERE                      "AHRK044783
                               pernr = list_rgdir-persnr AND "AHRK044783
                               seqnr = list_rgdir-seqnr.    "AHRK044783

          DELETE FROM hrpy_wpbp WHERE                       "AHRK044783
                               pernr = list_rgdir-persnr AND "AHRK044783
                               seqnr = list_rgdir-seqnr.    "AHRK044783

*         Delete existing values from the transparent table
*         Note 616122
          DELETE FROM hrpy_grouping WHERE
                               pernr = list_rgdir-persnr AND
                               seqnr = list_rgdir-seqnr.

*         Delete entries of table P01O_ZVB_RR               "MIXN954899
          DELETE FROM p01o_zvb_rr WHERE
                               pernr = list_rgdir-persnr AND
                               eaper = list_rgdir-fpper.

*         analogous to use of application log in program rpcdpu01
          PERFORM anwend_prot_ini USING persnr_list-persnr.
          MOVE-CORRESPONDING list_rgdir TO deleted_list.    "QNY240997
          APPEND deleted_list.                              "QNY240997
          DELETE list_rgdir.
        ENDLOOP.
        PERFORM application_log.
        REFRESH prot_mes.                                   "QNY270897
      ELSE.                               "ie if delete was unsuccessful
        MESSAGE e094(5a).                 "Fehler beim Löschen
      ENDIF.
      REFRESH sortfd.
      PERFORM rebuild_payroll_directory.
    ENDLOOP.                              "loop over persnr
  ELSE.                        " if answer to 'delete?' was NO or CANCEL
    EXIT.
  ENDIF.                       " ...of : if answer = 1 (really delete?)
ENDFORM.                    "DELETE_PAYROLL_RESULTS
************************************************************************
FORM rebuild_payroll_directory.
************************************************************************

  CALL FUNCTION 'REBUILD_PAYROLL_DIRECTORY'
    EXPORTING
      employee_number                = persnr_list-persnr
      country_grouping               = persnr_list-molga
      payroll_cluster                = persnr_list-relid
      save_new_directory             = 'X'
    TABLES
      new_directory                  = rgdir
    EXCEPTIONS
      country_grouping_incorrect     = 1
      country_grouping_initial       = 2
      no_authority_for_cluster       = 3
      error_loading_function_pool    = 4
      error_generating_function_pool = 5
      cant_load_payroll_results      = 6
      no_payroll_results_exist       = 7
      cant_read_payroll_result       = 8
      wrong_payroll_country_group    = 9
      cant_reorganize_directory      = 10
      duplicate_records              = 11
      cant_update_new_directory      = 12
      employee_number_initial        = 13
      no_authority_for_directory     = 14
      OTHERS                         = 15.
  CASE sy-subrc.
    WHEN 0 OR 7.
*      MESSAGE s899(5a) WITH
*     'Satz markierter Abrechnungsergebnisse ist gelöscht'(007)
*     'und das Cluster CU aktualisiert'(008).
      MESSAGE TEXT-001 TYPE 'S'.
    WHEN 6.
      MESSAGE i899(5a) WITH
        'Die Abrechnungsergebnisse können nicht '(090)
        ' geladen werden für Personalnummer'(091) persnr_list-persnr.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.


ENDFORM.                    "REBUILD_PAYROLL_DIRECTORY

************************************************************************
*      form print_persnr_list
*      main printing routine
************************************************************************
FORM print_persnr_list   TABLES   $list_rgdir  STRUCTURE list_rgdir
                                  $persnr_list STRUCTURE persnr_list
                         CHANGING $hide_seqnr  LIKE hide_seqnr
                                  $hide_persnr LIKE persnr
                                  $display_bad LIKE display_bad
                                  $display_deleted LIKE display_deleted.
  LOOP AT $persnr_list.
    SET PF-STATUS 'DEL_LIST2'.
    LOOP AT $list_rgdir
         WHERE persnr = $persnr_list-persnr.
    ENDLOOP.
    IF sy-subrc = 0.                   "if payroll results exist:
      IF $persnr_list-selec = 'X'.
        PERFORM print_list TABLES $list_rgdir
                           USING     $persnr_list-persnr  $persnr_list-ename
                           CHANGING  $hide_seqnr $hide_persnr.
      ELSE.
        PERFORM pernr_invisible USING    $persnr_list-persnr $persnr_list-ename.
        $hide_persnr = $persnr_list-persnr.
        HIDE: $hide_persnr.
      ENDIF.
    ELSE.                  "no payroll results for that personnel number
      bad_persnr_list-persnr = $persnr_list-persnr.
      bad_persnr_list-texts = 'has no payroll results!'(072).
      COLLECT bad_persnr_list.
    ENDIF.
  ENDLOOP.
  IF sy-subrc = 4.                           "no valid personnel numbers
    WRITE: /1 icon_negative AS ICON,
            13 'No valid personnel numbers chosen.'(077)
                              COLOR COL_NORMAL.
  ENDIF.

*  PERFORM print_deleted_list TABLES  deleted_list
*                             USING   $display_deleted.
*  PERFORM print_bad_persnr   TABLES  bad_persnr_list
*                             USING   $display_bad.

ENDFORM.                    "PRINT_PERSNR_LIST

************************************************************************
* Form  fill_rgdir
* (rgdir contains list of payroll results for selected personnel number)
************************************************************************
FORM fill_rgdir TABLES $list_rgdir STRUCTURE list_rgdir
                       $rgdir STRUCTURE pc261
                USING  $persnr LIKE persnr.

  CALL FUNCTION 'CU_READ_RGDIR'
    EXPORTING
      persnr          = $persnr
    TABLES
      in_rgdir        = $rgdir
    EXCEPTIONS
      no_record_found = 1
      OTHERS          = 2.

  IF sy-subrc = 1.                  "no_record_found is dealt with later
    REFRESH $rgdir.
  ELSEIF sy-subrc = 2.
    MESSAGE e899(5a) WITH
     'Error in function module CU_READ_RGDIR for personnel number'(029)
      $persnr .
  ENDIF.

  DATA : l_rgdir TYPE pc261.

* rgdir -> list_rgdir
* Edit by OkanK.
*  IF c_cntrl IS NOT INITIAL.
*    CLEAR l_rgdir.
*    READ TABLE $rgdir INTO l_rgdir WITH KEY fpper = s_fpper
*                                           srtza = 'P'.
*    LOOP AT $rgdir.
*      IF $rgdir-fpper = s_fpper AND
*         $rgdir-srtza = 'A' AND
*         l_rgdir IS NOT INITIAL.
*        list_rgdir-persnr = $persnr.
*        MOVE-CORRESPONDING  $rgdir TO $list_rgdir .
*        APPEND $list_rgdir.
*      ELSE.
*        DELETE $rgdir.
*      ENDIF.
*    ENDLOOP.
*  ELSE.
  LOOP AT $rgdir .
*{Osahin 03.03.2017
*    IF p_payty EQ 'A'  .
*      IF  $rgdir-fpbeg = p_fbbeg AND
*          $rgdir-srtza = p_srtza AND
*          $rgdir-payty = p_payty .
**
*        list_rgdir-persnr = $persnr.
*        MOVE-CORRESPONDING  $rgdir TO $list_rgdir .
*        APPEND $list_rgdir.
*      ELSE.
*        DELETE $rgdir.
*      ENDIF.
*    ELSE.
    IF $rgdir-fpper = s_fpper AND
       $rgdir-srtza = 'A'.
      list_rgdir-persnr = $persnr.
      MOVE-CORRESPONDING  $rgdir TO $list_rgdir .
      APPEND $list_rgdir.
    ELSE.
      DELETE $rgdir.
    ENDIF.
*    ENDIF.
*}Osahin 03.03.2017
  ENDLOOP.
*  ENDIF.

ENDFORM.                                                     "fill_rgdir
*********************************************************************
*       Form  print_list
*********************************************************************
FORM print_list TABLES    $list_rgdir STRUCTURE list_rgdir
                USING     $persnr LIKE persnr ename
                CHANGING  $hide_seqnr LIKE list_rgdir-seqnr
                          $hide_persnr LIKE $persnr.
  DATA: intensified_on TYPE i VALUE 0.

  PERFORM print_header USING     $persnr ename
                       CHANGING  $hide_persnr .

  LOOP AT $list_rgdir   WHERE persnr = $persnr. " only for current pernr
    IF intensified_on = 0.
      FORMAT COLOR  COL_NORMAL INTENSIFIED OFF.
      intensified_on = 1.
    ELSE.
      FORMAT COLOR  COL_NORMAL INTENSIFIED ON.
      intensified_on = 0.
    ENDIF.

    PERFORM buch_test USING $list_rgdir $persnr.
    "print line in red if result is already booked

    PERFORM write_line USING $list_rgdir.
    $hide_seqnr = $list_rgdir-seqnr.
    HIDE: $hide_seqnr, $hide_persnr.                        "QNY270997
  ENDLOOP.
  CLEAR: $hide_seqnr, $hide_persnr.
  WRITE:  /1       sy-uline(139).

  IF first = 1.
    first = 0.
    IF sy-subrc NE 0.
      SET PF-STATUS 'MENU'.            "empty status
      MESSAGE e116(3g) WITH persnr.    "no payroll results for persnr
    ENDIF.
  ENDIF.
ENDFORM.                               " print_list

*********************************************************************
*       Form  print_header
*********************************************************************
*      adapted from form print_header in RPUDIR00
*      'selec' checkbox added -> different spacing
*----------------------------------------------------------------------*
FORM print_header USING     $persnr LIKE pernr-pernr $ename
                  CHANGING  $hide_persnr LIKE hide_persnr .

  FORMAT COLOR COL_TOTAL INTENSIFIED ON.
  SKIP 1.
  WRITE:  "/1   icon_collapse     AS ICON HOTSPOT,
           "4   icon_select_all   AS ICON HOTSPOT,
           "6   icon_deselect_all AS ICON HOTSPOT,
           /13   TEXT-003 ,    " 'Personalnummer...........'(t01),
*           28  $persnr,
*           28   text-003 ,    " 'Personalnummer...........'(t01),
           29  $persnr,
           29   TEXT-003 ,    " 'Personalnummer...........'(t01),
           45  $ename.
  $hide_persnr = $persnr.
  HIDE: $hide_persnr.
  FORMAT RESET.

  WRITE:/12      sy-uline(59),
         71      sy-uline(32),
        /12      sy-vline,
         13(58)  'Bilgi'(h39) COLOR COL_HEADING INTENSIFIED
                 ON,
         70      sy-vline,
         71      sy-vline,
         72(31)  'Bilgi'(h40) COLOR COL_HEADING INTENSIFIED
                 ON,
         102     sy-vline.
  WRITE:/1       sy-uline(139),
        /1       sy-vline,
         3       sy-vline,
         4(5)    'Sıra'(h01) COLOR COL_HEADING INTENSIFIED ON,
         9        sy-vline,
         10(1)   'S'(h02) COLOR COL_HEADING INTENSIFIED ON,
         11      sy-vline,
         12      sy-vline,
         13(2)   'AK'(h03) COLOR COL_HEADING INTENSIFIED ON,
         15      sy-vline,
         16(2)   'PM'(h04) COLOR COL_HEADING INTENSIFIED ON,
         18      sy-vline,
         19(7)   'Periyot'(h05) COLOR COL_HEADING INTENSIFIED ON,
         26      sy-vline,
         27(10)  'Dönem Başlangıcı'(h06) COLOR COL_HEADING INTENSIFIED ON,
         37      sy-vline,
         38(10)  'Dönem Sonu'(h07) COLOR COL_HEADING INTENSIFIED ON,
         48      sy-vline,
         49(2)   'PT'(h08) COLOR COL_HEADING INTENSIFIED ON,
         51      sy-vline,
         52(2)   'PI'(h09) COLOR COL_HEADING INTENSIFIED ON,
         54      sy-vline,
         55(10)  'Tarih'(h10) COLOR COL_HEADING INTENSIFIED ON,
         65      sy-vline,
         66      'JuPe'(h38) COLOR COL_HEADING INTENSIFIED ON,
         70      sy-vline,
         71      sy-vline,
         72(2)   'AK'(h11) COLOR COL_HEADING INTENSIFIED ON,
         74      sy-vline,
         75(2)   'PM'(h12) COLOR COL_HEADING INTENSIFIED ON,
         77      sy-vline,
         78(7)   'Periyot'(h13) COLOR COL_HEADING INTENSIFIED ON,
         85      sy-vline,
         86(10)  'Dönem Sonu'(h14) COLOR COL_HEADING INTENSIFIED ON,
         96      sy-vline,
         97(2)   'PT'(h15) COLOR COL_HEADING INTENSIFIED ON,
         99      sy-vline,
         100(2)  'PI'(h16) COLOR COL_HEADING INTENSIFIED ON,
         102     sy-vline,
         103     sy-vline,
         104(10)  'Ödeme Tarihi'(h17) COLOR COL_HEADING INTENSIFIED ON,
         114     sy-vline,
         115(1)  'V'(h18) COLOR COL_HEADING INTENSIFIED ON,
         116     sy-vline,
         117(2)  'SG'(h19) COLOR COL_HEADING INTENSIFIED ON,
         119     sy-vline,
         120(10) 'Tarih'(h20) COLOR COL_HEADING INTENSIFIED ON,
         130     sy-vline,
         131(8)  'Zaman'(h21) COLOR COL_HEADING INTENSIFIED ON,
         139     sy-vline,
        /1       sy-uline(139).

ENDFORM.                               "print_header

*********************************************************************
*      Form  write_line
*********************************************************************
*      adapted from form write_line in RPUDIR00
*      'selec' checkbox added -> position+3
*----------------------------------------------------------------------*
FORM write_line USING $rgdir STRUCTURE list_rgdir.
  WRITE:/1         sy-vline,
         2         $rgdir-selec AS CHECKBOX,
         3         sy-vline,
         4(5)      $rgdir-seqnr,
         9         sy-vline,
         10(1)     $rgdir-srtza,
         11        sy-vline,
         12        sy-vline,
         13(2)     $rgdir-abkrs,
         15        sy-vline,
         16(2)     $rgdir-permo,
         18        sy-vline.
  IF $rgdir-fpper IS INITIAL OR
     $rgdir-fpper CO '0'.
    WRITE: 19(7)   space.
  ELSE.
    WRITE: 19(2)   $rgdir-fpper+4(2),
           21(1)   '.',
           22(4)   $rgdir-fpper(4).
  ENDIF.
  WRITE: 26        sy-vline.
  IF $rgdir-fpbeg IS INITIAL.
    WRITE: 27(10) space.
  ELSE.
    WRITE: 27(10)  $rgdir-fpbeg DD/MM/YYYY.
  ENDIF.
  WRITE: 37        sy-vline.
  IF $rgdir-fpend IS INITIAL.
    WRITE: 38(10) space.
  ELSE.
    WRITE: 38(10)  $rgdir-fpend DD/MM/YYYY.
  ENDIF.
  WRITE: 48        sy-vline,
         49(2)     $rgdir-payty,
         51        sy-vline,
         52(2)     $rgdir-payid,
         54        sy-vline.
  IF $rgdir-bondt IS INITIAL.
    WRITE: 55(10) space.
  ELSE.
    WRITE: 55(10)  $rgdir-bondt DD/MM/YYYY.
  ENDIF.
  WRITE: 65        sy-vline,
         66        $rgdir-juper,
         70        sy-vline,
         71        sy-vline,
         72(2)     $rgdir-iabkrs,
         74        sy-vline,
         75(2)     $rgdir-iperm,
         77        sy-vline.
  IF $rgdir-inper IS INITIAL OR
     $rgdir-inper CO '0'.
    WRITE: 78(7)   space.
  ELSE.
    WRITE: 78(2)   $rgdir-inper+4(2),
           80(1)   '.',
           81(4)   $rgdir-inper(4).
  ENDIF.
  WRITE: 85        sy-vline.
  IF $rgdir-ipend IS INITIAL.
    WRITE: 86(10)  space.
  ELSE.
    WRITE: 86(10)  $rgdir-ipend DD/MM/YYYY.
  ENDIF.
  WRITE: 96        sy-vline,
         97(2)     $rgdir-inpty,
         99        sy-vline,
         100(2)    $rgdir-inpid,
         102       sy-vline,
         103       sy-vline.
  IF $rgdir-paydt IS INITIAL.
    WRITE: 104(10) space.
  ELSE.
    WRITE: 104(10)  $rgdir-paydt DD/MM/YYYY.
  ENDIF.
  WRITE: 114       sy-vline,
         115(1)    $rgdir-void,
         116       sy-vline,
         117(2)    $rgdir-voidr,
         119       sy-vline.
  IF $rgdir-rundt IS INITIAL.
    WRITE: 120(10) space.
  ELSE.
    WRITE: 120(10)  $rgdir-rundt DD/MM/YYYY.
  ENDIF.
  WRITE: 130       sy-vline.
  IF $rgdir-runtm IS INITIAL.
    WRITE: 131(8) space.
  ELSE.
    WRITE: 131(8)  $rgdir-runtm.
  ENDIF.
  WRITE: 139       sy-vline.
ENDFORM.                               "write_line
*********************************************************************
* form maintain_list.
*********************************************************************
FORM maintain_list TABLES $list_rgdir STRUCTURE list_rgdir
                   USING  $hide_seqnr LIKE list_rgdir-seqnr
                          $clicked_seqnr LIKE list_rgdir-seqnr
                          $hide_persnr LIKE hide_persnr.

  DATA: selected_persnr LIKE hide_persnr.
  selected_persnr =  $hide_persnr.

  DO.
    CLEAR:  $hide_seqnr, $hide_persnr.
    READ LINE sy-index.
    IF sy-subrc NE 0.
      EXIT.
    ENDIF.
    CHECK NOT  $hide_seqnr IS INITIAL.
    READ TABLE $list_rgdir WITH KEY seqnr  = $hide_seqnr
                                    persnr = $hide_persnr.
    IF sy-subrc = 0.                             "only if entry exists
      $list_rgdir-selec = sy-lisel+1(1).         "read 2nd column
      IF  $hide_seqnr = $clicked_seqnr "if line selected by double click
      AND $hide_persnr = selected_persnr.        "only for current pernr
        IF list_rgdir-selec = ' '.               "toggle marked/unmarked
          list_rgdir-selec = 'X'.
        ELSE.
          list_rgdir-selec = ' '.
        ENDIF.
      ENDIF.
      MODIFY $list_rgdir INDEX sy-tabix.
*    ELSE.     "refresh list of payroll results (if some already deleted)
*      MESSAGE i899(5a) WITH
*             'Einige der markierten Abrechnungsergebnisse'(041)
*             'existieren nicht.'(042)
*             'Der folgende Bildschirm zeigt die aktuelle Liste.'(043) .
*      sy-ucomm = return-entmark.
*      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    "MAINTAIN_LIST
***********************************************************************
* Authority check.
***********************************************************************
FORM check_authority USING $relid LIKE relid.
* Check if the user is authorized to modify the payroll cluster.
  AUTHORITY-CHECK OBJECT 'P_PCLX'
                  ID 'RELID' FIELD $relid
                  ID 'AUTHC' FIELD 'U'.
  IF sy-subrc NE 0.
    MESSAGE e899(5a) WITH
      'Es liegt keine Pflegeberechtigung vor für Cluster'(005) $relid .
  ENDIF.
ENDFORM.                    "CHECK_AUTHORITY

***********************************************************************
*   form application_log.
***********************************************************************
*   Add info on deletion of payroll records
*   to object HRPU in the application log.
*---------------------------------------------------------------------*
FORM application_log.
  DATA: BEGIN OF prot_head.
          INCLUDE STRUCTURE balhdri.
  DATA: END OF prot_head.
  DATA: datum LIKE sy-datum,
        date  TYPE i.
  DATA: client_role LIKE t000-cccategory.               "XJS note 387263

  date = sy-datum + 365.
  datum = date.

  prot_head-object     = prot_obj.
  prot_head-aldate     = sy-datum.
  prot_head-altime     = sy-uzeit.
  prot_head-aluser     = sy-uname.
  prot_head-altcode    = sy-tcode(4).
  prot_head-alprog     = sy-repid(8).
  prot_head-altext     = TEXT-112.
  prot_head-aldate_del = datum.

* XJS note 387263 {
  CALL FUNCTION 'TR_SYS_PARAMS'
    IMPORTING
      system_client_role = client_role.
  IF client_role = 'P'.
    prot_head-del_before = 'X'.   "im Prod.-System nicht vorher löschbar
  ENDIF.
* XJS note 387263 }

  CALL FUNCTION 'APPL_LOG_INIT'
    EXPORTING
      object              = prot_obj
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      OTHERS              = 3.
  IF sy-subrc NE 0.
    MESSAGE w579(54).
  ENDIF.

  CALL FUNCTION 'APPL_LOG_WRITE_HEADER'
    EXPORTING
      header              = prot_head
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      OTHERS              = 3.
  IF sy-subrc NE 0.
    MESSAGE w579(54).
  ENDIF.

  CALL FUNCTION 'APPL_LOG_WRITE_MESSAGES'
    EXPORTING
      object              = prot_obj
    TABLES
      messages            = prot_mes
    EXCEPTIONS
      object_not_found    = 1
      subobject_not_found = 2
      OTHERS              = 3.

  IF sy-subrc NE 0.
    MESSAGE w579(54).
  ENDIF.

  CALL FUNCTION 'APPL_LOG_WRITE_DB'
    EXPORTING
      object                = prot_obj
    TABLES
      object_with_lognumber = prot_nr
    EXCEPTIONS
      object_not_found      = 1
      subobject_not_found   = 2
      internal_error        = 3
      OTHERS                = 4.
  IF sy-subrc NE 0.
    MESSAGE w579(54).
  ENDIF.
ENDFORM.                    "APPLICATION_LOG

***********************************************************************
* Specify data for application log                                    *
***********************************************************************
FORM anwend_prot_ini USING persnr LIKE persnr_list-persnr.

  prot_obj = 'HRPU'.
  prot_mes-msgty = 'I'.
  prot_mes-msgid = '54'.
  IF ( list_rgdir-fpper = 000000 ).
    prot_mes-msgno = '580'.
    prot_mes-msgv1 = list_rgdir-bondt.
    prot_mes-msgv2 = list_rgdir-payid.
    prot_mes-msgv3 = persnr.
  ELSE.
    prot_mes-msgno = '584'.
    prot_mes-msgv1 = list_rgdir-fpper.
    prot_mes-msgv2 = list_rgdir-inper.
    prot_mes-msgv3 = persnr.
  ENDIF.
  APPEND prot_mes.
ENDFORM.                    "ANWEND_PROT_INI

************************************************************************
*       Form  PERNR_INVISIBLE
************************************************************************
*  display only pernr + warning if resluts are marked for deletion.
************************************************************************
FORM pernr_invisible USING     $persnr      LIKE persnr  $ename.

  LOOP AT list_rgdir WHERE
                     persnr = $persnr AND
                     selec = 'X'.
  ENDLOOP.

  IF sy-subrc = 4.                     "no payroll results selected
    FORMAT COLOR COL_TOTAL INTENSIFIED ON .
    WRITE: "/1   icon_expand AS ICON HOTSPOT,
            /1    TEXT-003 ,                " 'Personalnummer...........'
*            28  $persnr,
            29  $persnr,

            28   TEXT-003 ,                " 'Personalnummer...........'
            45  $ename.
  ELSE.               "some payroll results are selected for deletion!!!
    WRITE: "/1   icon_expand AS ICON HOTSPOT,
            /13   TEXT-003 ,                " 'Personalnummer...........'
*            28  $persnr COLOR COL_NEGATIVE,
            29  $persnr COLOR COL_NEGATIVE,
            38  'enthält zum Löschen markierte Ergebnisse!'(071)
                      COLOR COL_NEGATIVE.
  ENDIF.
ENDFORM.                               " PERNR_INVISIBLE
************************************************************************
*       Form  PRINT_BAD_PERSNR
************************************************************************
*       list enqueud persnr or persnr with other errors
************************************************************************
FORM print_bad_persnr TABLES $bad_persnr_list STRUCTURE bad_persnr_list
                      USING  $display_bad LIKE display_bad.
  FORMAT RESET.
  ULINE.
  IF $display_bad = 'X'.
    WRITE: /1 icon_collapse AS ICON HOTSPOT,                "QNY270997
        13 'nicht anzeigbar (ohne Abr.erg., gesperrt, fehlerhaft)'(076)
                                       COLOR COL_NORMAL INTENSIFIED OFF.
    hide_icontype = 'BADOUT'.                               "QNY270997
    HIDE: hide_icontype.                                    "QNY270997
    CLEAR hide_icontype.                                    "QNY270997
    LOOP AT $bad_persnr_list.
      WRITE: /13  TEXT-003,          " 'Personalnummer...........'(t01),
              28  $bad_persnr_list-persnr
                                     COLOR COL_NEGATIVE INTENSIFIED OFF,
              38  $bad_persnr_list-texts.
    ENDLOOP.
  ELSE.
    LOOP AT $bad_persnr_list.
    ENDLOOP.
    IF sy-subrc = 4.                   "empty list of persnrs with error
      WRITE: /1 icon_collapse AS ICON,                      "QNY270997
              13 '0 ' COLOR COL_NORMAL,
         15 'nicht anzeigbar (ohne Abr.erg., gesperrt, fehlerhaft)'(076)
                                       COLOR COL_NORMAL INTENSIFIED OFF.
      hide_icontype = 'BADOUT'.                             "QNY270997
      HIDE: hide_icontype.                                  "QNY270997
      CLEAR hide_icontype.                                  "QNY270997
      ULINE.
      EXIT.
    ENDIF.
    WRITE: /1 icon_expand AS ICON HOTSPOT,                  "QNY270997
         13 'nicht anzeigbar (ohne Abr.erg., gesperrt, fehlerhaft)'(076)
                                       COLOR COL_NORMAL INTENSIFIED OFF.
    hide_icontype = 'BADIN '.                               "QNY270997
    HIDE: hide_icontype.                                    "QNY270997
    CLEAR hide_icontype.                                    "QNY270997
  ENDIF.
  ULINE.
ENDFORM.                                              " PRINT_BAD_PERSNR
************************************************************************
*       Form  PRINT_DELETED_LIST                              "QNY240997
************************************************************************
*       list of deleted payroll results
************************************************************************
FORM print_deleted_list TABLES $deleted_list STRUCTURE deleted_list
                      USING  $display_deleted LIKE display_deleted.
  FORMAT RESET.
  ULINE.
  IF $display_deleted = 'X'.
    SORT    $deleted_list BY persnr fpper inper payid.
    hide_icontype = 'DELOUT'.                               "QNY270997
    HIDE: hide_icontype.                                    "QNY270997
    CLEAR hide_icontype.                                    "QNY270997
    WRITE: /1 icon_collapse AS ICON HOTSPOT,                "QNY270997
           13 'gelöschte Abrechnungsergebnisse'(079) COLOR COL_POSITIVE.
    LOOP AT $deleted_list.
      WRITE: /13  TEXT-003,                " 'Personalnummer...........'
              28  $deleted_list-persnr COLOR COL_NORMAL INTENSIFIED OFF,
              38  'Fürperiode'(088),
              50  $deleted_list-fpper COLOR COL_NORMAL INTENSIFIED OFF,
              58  'Inperiode'(089),
              70  $deleted_list-inper.
      IF NOT $deleted_list-bondt IS INITIAL.                "QNY021097
        WRITE: 80 'SDatum'(h10),                            "QNY021097
               88 $deleted_list-bondt DD/MM/YYYY,           "QNY021097
              100 'PI'(h09),"consecutive number of bonus runs "QNY021097
              103 $deleted_list-payid.                      "QNY021097
      ENDIF.                                                "QNY021097
    ENDLOOP.
  ELSE.
    LOOP AT $deleted_list.
    ENDLOOP.
    IF sy-subrc = 4.                   "empty list of persnrs with error
      WRITE: /1 icon_collapse AS ICON,                      "QNY270997
              13 '0 ' COLOR COL_NORMAL,
              15 'gelöschte Abrechnungsergebnisse'(079)
                            COLOR COL_NORMAL INTENSIFIED OFF.
      hide_icontype = 'DELOUT'.                             "QNY270997
      HIDE: hide_icontype.                                  "QNY270997
      CLEAR hide_icontype.                                  "QNY270997
      EXIT.
    ENDIF.
    hide_icontype = 'DELIN '.                               "QNY270997
    HIDE: hide_icontype.                                    "QNY270997
    CLEAR hide_icontype.                                    "QNY270997
    WRITE: /1 icon_expand AS ICON HOTSPOT,
            13 'gelöschte Abrechnungsergebnisse'(079)
                            COLOR COL_NORMAL INTENSIFIED OFF.
  ENDIF.
ENDFORM.                               " PRINT_BAD_PERSNR

************************************************************************
FORM check_client.             "P30K041899 in rpchrt00 - simplified: QNY
************************************************************************
* checks the status of the client and warns the user if the status
* is 'productive' or 'unspecified'.
************************************************************************
  SELECT SINGLE * FROM t000 WHERE mandt EQ sy-mandt.
  IF sy-subrc NE 0.                                    "should not occur
    WRITE: / 'Kein Eintrag in Tabelle T000 zu Mandant:'(075), sy-mandt.
    STOP.
  ELSE.
    CASE t000-cccategory.
      WHEN ' '.                                        "not specified
        CLEAR answer.
        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
          EXPORTING
            defaultoption = 'N'
            diagnosetext1 = 'Sie befinden sich in einem unspezif. Mandanten.'(081)
            diagnosetext2 = 'Dieser Report ist aber nur für Testzwecke gedacht,'(082)
            diagnosetext3 = 'da er kann zu Inkonsistenzen im Datenbestand führen kann!'(083)
            textline1     = ' '
            textline2     = 'Möchten Sie trotzdem fortfahren?'(084)
            titel         = 'Warnung: evtl. Produktivmandant!'(085)
            start_column  = 25
            start_row     = 6
          IMPORTING
            answer        = answer
          EXCEPTIONS
            OTHERS        = 1.
        IF sy-subrc NE 0.
          MESSAGE e241(57) "error in function module &1 with ret.code &2
                       WITH   'POPUP_TO_CONFIRM_WITH_MESSAGE'  sy-subrc.
        ENDIF.
        IF answer =  'N'.
          STOP.
        ELSEIF answer = 'A'.
          STOP.
        ENDIF.

      WHEN 'P'.                        "productive

        IF g_mod IS INITIAL.  "XFG note 537138
          MESSAGE e502(3g).   "
        ENDIF.                "XFG note 537138

        CLEAR answer.
        CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
          EXPORTING
            defaultoption = 'N'
            diagnosetext1 = 'Sie befinden sich im Produktivmandanten.'(080)
            diagnosetext2 = 'Dieser Report ist aber nur für Testzwecke gedacht,'(082)
            diagnosetext3 = 'da er kann zu Inkonsistenzen im Datenbestand führen kann!'(083)
            textline1     = ' '
            textline2     = 'Möchten Sie trotzdem fortfahren?'(084)
            titel         = 'Warnung: Produktivmandant!'(086)
            start_column  = 25
            start_row     = 6
          IMPORTING
            answer        = answer
          EXCEPTIONS
            OTHERS        = 1.
        IF sy-subrc NE 0.
          MESSAGE e241(57) "error in function module &1 with ret.code &2
                       WITH   'POPUP_TO_CONFIRM_WITH_MESSAGE'  sy-subrc.
        ENDIF.
        IF answer =  'N'.
          STOP.
        ELSEIF answer = 'A'.
          STOP.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.
ENDFORM.                               "CHECK_CLIENT

*&---------------------------------------------------------------------*
*&      Form  BUCH_TEST
*&---------------------------------------------------------------------*
*       print results in red if they are already booked
*----------------------------------------------------------------------*
FORM buch_test USING $list_rgdir LIKE list_rgdir
                     $persnr LIKE persnr.
  DATA: p_evaluated TYPE c,
        p_runid     LIKE pevst-runid.

  CALL FUNCTION 'HR_EVAL_EVP_CHECK'
    EXPORTING
      type      = 'PP'
      persnum   = $persnr
      seqno     = $list_rgdir-seqnr
      srtza     = $list_rgdir-srtza
    IMPORTING
      evaluated = p_evaluated
      runid     = p_runid
    EXCEPTIONS
      OTHERS    = 0.
  IF sy-subrc IS INITIAL. ENDIF.
  IF NOT p_evaluated EQ space.
    FORMAT COLOR COL_NEGATIVE.
  ENDIF.

ENDFORM.                    " BUCH_TEST
*&---------------------------------------------------------------------*
*&      Form  CHECK_AUT
*&---------------------------------------------------------------------*
FORM check_aut .

  DATA : lv_uname.

  SELECT SINGLE uname FROM zbyhr_t026 INTO lv_uname
  WHERE uname EQ sy-uname.

  IF sy-subrc NE 0.
    MESSAGE 'Bu programı çalıştırma yetkiniz yoktur!' TYPE 'E'.
  ENDIF.

ENDFORM.
