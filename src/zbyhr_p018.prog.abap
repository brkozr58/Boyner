*&---------------------------------------------------------------------*
*& Report ZBYHR_P018
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p018.

TYPE-POOLS : slis .
TYPE-POOLS : slis .
CLASS : gr_report DEFINITION DEFERRED.
DATA: lv_xstring  TYPE xstring.

* Tables
TABLES : pernr   ,
         pcl1   ,
         pcl2   ,
         zbyhr_t001   ,
         zbyhr_t002   ,
         t512t  ,
         t001.


*INFOTYPES
INFOTYPES : 0000 ,
            0001 ,
            0014 ,
            0015 ,
            0002 ,
            0009 ,
            0770 ,
            0772 .

TYPES: BEGIN OF ty_s_clipdata,
         data TYPE c LENGTH 1000,
       END   OF ty_s_clipdata.

TYPES: ty_t_clipdata TYPE TABLE OF ty_s_clipdata.

DATA : gt_t001 TYPE TABLE OF zbyhr_t001 .
DATA : gt_t002 TYPE TABLE OF zbyhr_t002 .
DATA : gt_izah TYPE TABLE OF dd07t .


DATA : BEGIN OF gt_filter OCCURS 0 ,
         bukrs LIKE p0001-bukrs,
         werks LIKE p0001-werks,
         btrtl LIKE p0001-btrtl,
       END OF gt_filter .


DATA: ld_filename      TYPE string,
      ld_path          TYPE string,
      ld_fullpath      TYPE string,
      ld_result        TYPE i,
      l_filename       TYPE string,
      lv_def_extension TYPE string.


"$. Region OLE
INCLUDE ole2incl.

DATA: go_excel TYPE ole2_object,
      go_books TYPE ole2_object,
      go_book  TYPE ole2_object,
      go_sheet TYPE ole2_object,
      go_cell  TYPE ole2_object,
      go_font  TYPE ole2_object,
      go_int   TYPE ole2_object,
      go_range TYPE ole2_object,
      go_row   TYPE ole2_object.

" Hücreye değer basmak için makro
DEFINE m_set_cell.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = &2.
  SET PROPERTY OF go_cell 'Value' = &3.
END-OF-DEFINITION.

"  (Yeşil arka plan, Beyaz/Kalın yazı) boyamak için makro
DEFINE m_color_green.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = &2.
  CALL METHOD OF go_cell 'Interior' = go_int.
  SET PROPERTY OF go_int 'Color' = 32768. " Koyu Yeşil
  CALL METHOD OF go_cell 'Font' = go_font.
  SET PROPERTY OF go_font 'Color' = 16777215. " Beyaz
  SET PROPERTY OF go_font 'Bold' = 1.
END-OF-DEFINITION.

" Hücre birleştirme makrosu (Örn: m_merge_cells 'C1' 'H1'.)
DEFINE m_merge_cells.
  CALL METHOD OF go_excel 'Range' = go_range EXPORTING #1 = &1 #2 = &2.
  SET PROPERTY OF go_range 'MergeCells' = 1.
END-OF-DEFINITION.

" B sütununu metin formatına çevirip ortalama makrosu
DEFINE m_format_col_b.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = 2.
  SET PROPERTY OF go_cell 'NumberFormat' = '@'. " Metin formatı (başındaki 0'ları korur)
  SET PROPERTY OF go_cell 'HorizontalAlignment' = -4108. " xlCenter (Ortala)
END-OF-DEFINITION.

" Belirli bir aralığa (Range) kenarlık ekleme makrosu
DEFINE m_range_border.
  CALL METHOD OF go_excel 'Range' = go_range EXPORTING #1 = &1 #2 = &2.
  CALL METHOD OF go_range 'Borders' = go_int.
  SET PROPERTY OF go_int 'LineStyle' = 1. " xlContinuous (Düz çizgi)
END-OF-DEFINITION.

" Belirli bir hücreyi ortalama makrosu
DEFINE m_center_cell.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = &2.
  SET PROPERTY OF go_cell 'HorizontalAlignment' = -4108. " xlCenter
END-OF-DEFINITION.

DATA: go_chars TYPE ole2_object. " Kısmi metin formatlama nesnesi
DATA: lv_off TYPE i, lv_len TYPE i, lv_start TYPE i. " Metin arama pozisyonları

" Metni Mavi yapmak için
DEFINE m_color_blue_text.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = &2.
  CALL METHOD OF go_cell 'Font' = go_font.
  SET PROPERTY OF go_font 'Color' = 16711680. " Excel Mavi Renk Kodu
END-OF-DEFINITION.

" Sütun genişliği ayarlama makrosu
DEFINE m_col_width.
  CALL METHOD OF go_excel 'Columns' = go_range EXPORTING #1 = &1.
  SET PROPERTY OF go_range 'ColumnWidth' = &2.
END-OF-DEFINITION.

" Hücreyi metin formatında ayarlayıp değer basmak için makro (Başındaki 0'ları korur)
DEFINE m_set_cell_text.
  CALL METHOD OF go_excel 'Cells' = go_cell EXPORTING #1 = &1 #2 = &2.
  SET PROPERTY OF go_cell 'NumberFormat' = '@'. " Formatı Metin yap
  SET PROPERTY OF go_cell 'Value' = &3.         " Değeri bas
END-OF-DEFINITION.

"$. Endregion OLE

* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-bl1     .
  PARAMETERS : p_pdate LIKE pa0015-begda OBLIGATORY,
               p_lgart LIKE p0015-lgart OBLIGATORY DEFAULT '/559',
               p_odtip TYPE zhrby_odtip OBLIGATORY DEFAULT 'M',
               r_brd   RADIOBUTTON GROUP rad1 DEFAULT 'X',
               r_eko   RADIOBUTTON GROUP rad1,
               p_iban  AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF  BLOCK b1.

INCLUDE zbyhr_p018_001.



INITIALIZATION .
  CREATE OBJECT go_report.
  go_report->set_init( ).


AT SELECTION-SCREEN OUTPUT.
  PERFORM selection-screen_output.

START-OF-SELECTION  .
  go_report->set_date( ).

GET pernr           .
  go_report->get_data( ).

END-OF-SELECTION .
  SORT gt_filter ASCENDING BY bukrs werks btrtl.
  DELETE ADJACENT DUPLICATES FROM gt_filter.
  go_report->prepare_alv( ).






*&---------------------------------------------------------------------*
*& Form SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM selection-screen_output .

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

ENDFORM.
