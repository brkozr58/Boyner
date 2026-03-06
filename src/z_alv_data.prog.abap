*&---------------------------------------------------------------------*
*& Include          Z_ALV_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           Z_ALV_DATA                                       *
*&---------------------------------------------------------------------*

* type-pools.
type-pools: slis.


data: gs_layout    type  slis_layout_alv,
      gt_fieldcat  type  slis_t_fieldcat_alv,
      lt_fieldcat  type  slis_t_fieldcat_alv,
      gs_fieldcat  type  slis_fieldcat_alv,
      gt_events    type  slis_t_event,
      gs_event     type  slis_alv_event,
      gt_sort      type  slis_t_sortinfo_alv,
      gs_sort      type  slis_sortinfo_alv . .

data: gt_fcat     type lvc_t_fcat,
      gs_fcat     type lvc_s_fcat,
      gs_layo     type lvc_s_layo,
      gt_sort_lvc type lvc_t_sort,
      gs_sort_lvc type lvc_s_sort.

data: gv_repid like sy-repid.


data: begin of alv_list occurs 0,
         typ(1)  type c,
         key(20) type c,
         info    type slis_entry,
       end of alv_list.

* field-symbols
field-symbols: <fcat> type table,
               <fout> type table.


* macros..
define alv_list.
  alv_list-typ  = &1.
  alv_list-key  = &2.
*  alv_list-info = &3.
  write &3 to alv_list-info.
  append alv_list.
end-of-definition.


*&---------------------------------------------------------------------
*&      Form  top_of_page
*----------------------------------------------------------------------
form top_of_page.

  call function 'REUSE_ALV_COMMENTARY_WRITE'
    exporting
*      i_logo             = 'ENJOYSAP_LOGO'
      it_list_commentary = alv_list[].

endform.                    " top_of_page
*&---------------------------------------------------------------------*
*&      Form  create_fieldcatalog
*&---------------------------------------------------------------------*
form create_fieldcatalog  using  tabname.
  gv_repid = sy-repid.
  check <fcat> is assigned.
  refresh <fcat>.
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_program_name         = gv_repid
      i_internal_tabname     = tabname
      i_inclname             = gv_repid
    changing
      ct_fieldcat            = <fcat>
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.
  check <fout> is not assigned.
  data: lv_tabname(30).
  concatenate tabname '[]' into lv_tabname.
  assign (lv_tabname)  to <fout>  .
endform.                    " create_fieldcatalog
*&---------------------------------------------------------------------*
*&      Form  create_fieldcatalog_structure
*&---------------------------------------------------------------------*
form create_fieldcatalog_structure using  tabname.
  gv_repid = sy-repid.
  check <fcat> is assigned.
  refresh <fcat>.
  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_program_name         = gv_repid
      i_structure_name       = tabname
      i_inclname             = gv_repid
    changing
      ct_fieldcat            = <fcat>
    exceptions
      inconsistent_interface = 1
      program_error          = 2
      others                 = 3.
  check <fout> is not assigned.
  data: lv_tabname(30).
  concatenate tabname '[]' into lv_tabname.
  assign (lv_tabname)  to <fout>  .
endform.                    " create_fieldcatalog
*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
form display_alv using with_gui.
  gv_repid = sy-repid.
  check <fout> is assigned.
  if with_gui = 'X'.
    call function 'REUSE_ALV_GRID_DISPLAY'
      exporting
        i_callback_program       = gv_repid
*        i_callback_top_of_page   = 'TOP_OF_PAGE'
        i_background_id          = 'ALV_BACKGROUND'
        i_callback_pf_status_set = 'PF_STATUS_SET'
        i_callback_user_command  = 'USER_COMMAND'
        is_layout                = gs_layout
        it_fieldcat              = <fcat>
        it_sort                  = gt_sort
        it_events                = gt_events[]
      tables
        t_outtab                 = <fout>
      exceptions
        program_error            = 1
        others                   = 2.
  else.
    call function 'REUSE_ALV_GRID_DISPLAY'
      exporting
        i_callback_program       = gv_repid
*        i_callback_top_of_page   = 'TOP_OF_PAGE'
        i_background_id          = 'BACK_GROUND'
*      i_callback_pf_status_set = 'PF_STATUS_SET'
*      i_callback_user_command  = 'USER_COMMAND'
        is_layout                = gs_layout
        it_fieldcat              = <fcat>
        it_sort                  = gt_sort
        it_events                = gt_events[]
      tables
        t_outtab                 = <fout>
      exceptions
        program_error            = 1
        others                   = 2.
  endif.
endform.                    " display_alv
*&---------------------------------------------------------------------*
*&      Form  modify_fieldcatalog
*&---------------------------------------------------------------------*
form modify_fieldcatalog  using    fieldname  target   value.

  field-symbols: <field> type any.
  data:lv_field(20),lv_target(20).
  lv_field = fieldname.
  lv_target = target.
  translate lv_field to upper case.
  translate lv_target to upper case.
  read table gt_fieldcat with key fieldname = lv_field
                         into gs_fieldcat .
  check sy-subrc = 0.
  assign component lv_target of structure gs_fieldcat to <field>.
  if <field> is assigned.
    <field> = value.
  endif.
  modify gt_fieldcat from gs_fieldcat  index sy-tabix..

endform.                    " modify_fieldcatalog
*&---------------------------------------------------------------------*
*&      Form  modify_fieldcatalog_text
*&---------------------------------------------------------------------*
form modify_fieldcatalog_text  using fieldname  text  l_text.

  perform modify_fieldcatalog
          using: fieldname 'SELTEXT_L'    l_text,
                 fieldname 'SELTEXT_S'    text,
                 fieldname 'SELTEXT_M'    text,
                 fieldname 'REPTEXT_DDIC' text.

endform.                    " modify_fieldcatalog_text
*&---------------------------------------------------------------------*
*&      Form  copy_fieldcatalog_text
*&---------------------------------------------------------------------*
form copy_fieldcatalog_text  using  fieldname  target.
  data:ls_fieldcat type slis_fieldcat_alv.
  read table gt_fieldcat with key fieldname = fieldname
                         into ls_fieldcat .
  check sy-subrc = 0.
  perform modify_fieldcatalog
          using: target 'SELTEXT_L'    ls_fieldcat-seltext_l,
                 target 'SELTEXT_S'    ls_fieldcat-seltext_s,
                 target 'SELTEXT_M'    ls_fieldcat-seltext_m,
                 target 'REPTEXT_DDIC' ls_fieldcat-reptext_ddic.
endform.                    " copy_fieldcatalog_text
*&---------------------------------------------------------------------*
*&      Form  lvc_transfer_from_slis
*&---------------------------------------------------------------------*
form lvc_transfer_from_slis.
  check <fout> is assigned.
  call function 'LVC_TRANSFER_FROM_SLIS'
    exporting
      it_fieldcat_alv = gt_fieldcat
      it_sort_alv     = gt_sort
      is_layout_alv   = gs_layout
    importing
      et_fieldcat_lvc = gt_fcat
      et_sort_lvc     = gt_sort_lvc
      es_layout_lvc   = gs_layo
    tables
      it_data         = <fout>
    exceptions
      it_data_missing = 1
      others          = 2.
endform.                    "lvc_transfer_from_slis
*&---------------------------------------------------------------------*
*&      Form  LVC_TRANSFER_TO_SLIS
*&---------------------------------------------------------------------*
form lvc_transfer_to_slis.
  check <fout> is assigned.
  call function 'LVC_TRANSFER_TO_SLIS'
    exporting
      it_fieldcat_lvc         = gt_fcat
      it_sort_lvc             = gt_sort_lvc
      is_layout_lvc           = gs_layo
    importing
      et_fieldcat_alv         = gt_fieldcat
      et_sort_alv             = gt_sort
      et_filter_alv           = gs_layout
    tables
      it_data                 = <fout>
    exceptions
      it_data_missing         = 1
      it_fieldcat_lvc_missing = 2
      others                  = 3.
endform.                    "LVC_TRANSFER_TO_SLIS
