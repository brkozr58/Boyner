class ZBYHR_DISKET definition
  public
  final
  create public .

public section.

  data MO_EXCEL type OLE2_OBJECT .
  data MO_WBOOKLIST type OLE2_OBJECT .
  data MO_WBOOK type OLE2_OBJECT .
  data MO_WSHEET type OLE2_OBJECT .
  data MO_WSHEETS type OLE2_OBJECT .
  data MO_APPLICATION type OLE2_OBJECT .
  data MO_CELL type OLE2_OBJECT .
  data MO_CELLS type OLE2_OBJECT .
  data MO_RANGE type OLE2_OBJECT .
  data MO_BORDER type OLE2_OBJECT .
  data MO_INTERIOR type OLE2_OBJECT .
  data MO_FONT type OLE2_OBJECT .
  data MO_ACTDOC type OLE2_OBJECT .
  data MO_NEWDOC type OLE2_OBJECT .
  data MO_ACTIVESHEET type OLE2_OBJECT .
  data MO_ENTIRECOLUMN type OLE2_OBJECT .
  data MO_ENTIREROW type OLE2_OBJECT .
  constants MC_CENTER type P value '-4108' ##NO_TEXT.
  constants MC_RIGHT type P value '-4152' ##NO_TEXT.
  constants MC_LEFT type P value '-4131' ##NO_TEXT.
  constants MC_JUST type P value '-4130' ##NO_TEXT.
  constants MC_TOP type P value '-4160' ##NO_TEXT.
  constants MC_BOTTOM type P value '-4107' ##NO_TEXT.
  data MV_DEFAULT_FONT type STRING value 'ARIAL' ##NO_TEXT.
  data MV_DEFAULT_FONT_SIZE type P value '10' ##NO_TEXT.
  constants MC_MEDIUM_BORDER type P value '-4138' ##NO_TEXT.
  constants MC_THIN_BORDER type P value '2' ##NO_TEXT.
  constants MC_THICK_BORDER type P value '4' ##NO_TEXT.
  constants MC_CONTINUOUS_LINE type P value '1' ##NO_TEXT.
  constants MC_DASH_LINE type P value '-4115' ##NO_TEXT.
  constants MC_DOT_LINE type P value '-4118' ##NO_TEXT.
  constants MC_EDGE_LEFT type P value '7' ##NO_TEXT.
  constants MC_EDGE_RIGHT type P value '10' ##NO_TEXT.
  constants MC_EDGE_TOP type P value '8' ##NO_TEXT.
  constants MC_EDGE_BOTTOM type P value '9' ##NO_TEXT.
  constants MC_INSIDE_HORIZONTAL type P value '12' ##NO_TEXT.
  constants MC_INSIDE_VERTICAL type P value '11' ##NO_TEXT.
  data MO_COLUMNS type OLE2_OBJECT .
  data MV_CLASSNAME type BDS_LOCL-CLASSNAME value 'ZBYHR_DISKET' ##NO_TEXT.
  data MV_CLASSTYPE type BDS_LOCL-CLASSTYPE value 'OT' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !IV_VISIBLE type I default '0'
      !IV_FILENAME type ANY optional .
  methods SELECT_AREA
    importing
      !IV_ROW1 type ANY
      !IV_ROW2 type ANY
      !IV_COL1 type ANY
      !IV_COL2 type ANY .
  methods SELECT_RANGE
    importing
      !IV_CELL1 type ANY
      !IV_CELL2 type ANY .
  methods SELECT_CELL
    importing
      !IV_X type I
      !IV_Y type I .
  methods SELECT_SHEET .
  methods SET_FONT_ATTRIBUTE
    importing
      !IV_FONTNAME type ANY optional
      !IV_FONTSIZE type ANY optional
      !IV_FONTSTYLE type ANY optional
      !IV_FONTCOLOR type ANY optional .
  methods SET_CELL_VALUE
    importing
      !IV_X type I
      !IV_Y type I
      !IV_HALIGN type ANY optional
      !IV_VALIGN type ANY optional
      !IV_FORMAT type ANY optional
      !IV_FCOLOR type ANY optional
      !IV_FONTNAME type ANY optional
      !IV_FONTSIZE type ANY optional
      !IV_FONTSTYLE type ANY optional
      !IV_FONTCOLOR type ANY optional
      !IV_VALUE type ANY .
  methods SET_FILL_COLOR
    importing
      !IV_COLOR type ANY .
  methods SET_VERTICAL_ALIGNMENT
    importing
      !IV_ALIGNMENT type ANY .
  methods SET_HORIZONTAL_ALIGNMENT
    importing
      !IV_ALIGNMENT type ANY .
  methods SET_COLUMN_WIDTH
    importing
      !IV_WIDTH type ANY
      !IV_ROW1 type ANY optional
      !IV_ROW2 type ANY optional
      !IV_COL1 type ANY optional
      !IV_COL2 type ANY optional .
  methods SET_ROW_HEIGHT
    importing
      !IV_HEIGHT type ANY
      !IV_ROW1 type ANY optional
      !IV_ROW2 type ANY optional
      !IV_COL1 type ANY optional
      !IV_COL2 type ANY optional .
  methods SET_MERGE_CELLS
    importing
      !IV_CELL1 type ANY optional
      !IV_CELL2 type ANY optional
      !IV_ROW1 type ANY optional
      !IV_ROW2 type ANY optional
      !IV_COL1 type ANY optional
      !IV_COL2 type ANY optional
      !IV_VERTICAL type ANY optional
      !IV_HORIZONTAL type ANY optional
      !IV_ORIENTATION type ANY optional .
  methods SET_BORDER
    importing
      !IV_STYLE type I default '1'
      !IV_WEIGHT type ANY default '2'
      !IV_COLOR type I optional
      !IV_BORDER type ANY
      !IV_ROW1 type ANY optional
      !IV_ROW2 type ANY optional
      !IV_COL1 type ANY optional
      !IV_COL2 type ANY optional .
  methods SET_VISIBILITY
    importing
      !IV_VISIBLE type ANY .
  methods SET_AUTOFIT .
  methods SET_NUMBER_FORMAT
    importing
      !IV_NUMBER_FORMAT type ANY .
  methods SET_SHEET_NAME
    importing
      !IV_SHEET_NO type ANY
      !IV_SHEET_NAME type ANY .
  methods SET_ORIENTATION .
  methods SAVE .
  methods PASTE_CLIPBOARD_AKBANK
    importing
      !IV_CELL1 type ANY
      !IV_CELL2 type ANY .
  methods PASTE_CLIPBOARD
    importing
      !IV_CELL1 type ANY
      !IV_CELL2 type ANY
      !IV_WORKSHEETS type I .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBYHR_DISKET IMPLEMENTATION.


  METHOD constructor.
* Excel'in Başlatılması
    CREATE OBJECT mo_excel 'EXCEL.APPLICATION'.
* Excel'i visible hale getir.
    SET PROPERTY OF mo_excel  'Visible' = iv_visible .

* Workbook listesi alınır.
    CALL METHOD OF
      mo_excel
        'Workbooks' = mo_wbooklist.
    IF iv_filename IS INITIAL.
* Yeni bir workbook ekle.
      CALL METHOD OF
        mo_wbooklist
          'Add' = mo_wbook.
    ELSE.
      CALL METHOD OF
        mo_wbooklist
        'OPEN'
        EXPORTING
          #1 = iv_filename.
    ENDIF.

  ENDMETHOD.                    "constructor


  METHOD paste_clipboard.

    CALL METHOD OF
        mo_excel
        'WORKSHEETS' = mo_wsheet
      EXPORTING
        #1           = IV_WORKSHEETS.

    CALL METHOD OF
      mo_wsheet
      'ACTIVATE'.

    me->select_range(
      EXPORTING
        iv_cell1 = iv_cell1
        iv_cell2 = iv_cell2
    ).

    CALL METHOD OF
      mo_wsheet
      'Paste'.

    CALL METHOD OF
      mo_excel
        'Columns' = mo_columns.
    CALL METHOD OF
      mo_columns
      'AutoFit'.

  ENDMETHOD.                    "paste_clipboard


  METHOD paste_clipboard_akbank.

    CALL METHOD OF
        mo_excel
        'WORKSHEETS' = mo_wsheet
      EXPORTING
        #1           = 5.

    CALL METHOD OF
      mo_wsheet
      'ACTIVATE'.

    me->select_range(
      EXPORTING
        iv_cell1 = iv_cell1
        iv_cell2 = iv_cell2
    ).

    CALL METHOD OF
      mo_wsheet
      'Paste'.

    CALL METHOD OF
      mo_excel
        'Columns' = mo_columns.
    CALL METHOD OF
      mo_columns
      'AutoFit'.

  ENDMETHOD.                    "PASTE_CLIPBOARD_AKBANK


  METHOD save.
  ENDMETHOD.                    "SAVE


  METHOD select_area.
    DATA: lv_cell1(6), lv_cell2(6).
    DATA: lv_row1(5), lv_row2(5).

    WRITE iv_row1 TO lv_row1 RIGHT-JUSTIFIED NO-ZERO.
    WRITE iv_row2 TO lv_row2 RIGHT-JUSTIFIED NO-ZERO.

    CONCATENATE iv_col1 lv_row1 INTO lv_cell1.
    CONDENSE lv_cell1 NO-GAPS.
    CONCATENATE iv_col2 lv_row2 INTO lv_cell2.
    CONDENSE lv_cell2 NO-GAPS.

    CALL METHOD me->select_range
      EXPORTING
        iv_cell1 = lv_cell1
        iv_cell2 = lv_cell2.

  ENDMETHOD.                    "SELECT_AREA


  METHOD select_cell.
    FREE mo_cells.
    CLEAR mo_cells.

    CALL METHOD OF
        mo_excel
        'Cells'  = mo_cells
      EXPORTING
        #1       = iv_y
        #2       = iv_x.

  ENDMETHOD.                    "select_cell


  METHOD select_range.
    DATA: lv_range(30).

    IF NOT iv_cell1 CA sy-abcde.
      CONCATENATE  iv_cell1 ':' iv_cell2 INTO lv_range.
      CONDENSE lv_range .
      CALL METHOD OF
          mo_excel
          'Range'  = mo_range
        EXPORTING
          #1       = lv_range.
    ELSE.
      CALL METHOD OF
          mo_excel
          'Range'  = mo_range
        EXPORTING
          #1       = iv_cell1
          #2       = iv_cell2.
    ENDIF.

    CALL METHOD OF
      mo_range
      'Select'.

    mo_cells = mo_range.
  ENDMETHOD.                    "select_range


  METHOD select_sheet.
  ENDMETHOD.                    "SELECT_SHEET


  METHOD set_autofit.
  ENDMETHOD.                    "SET_AUTOFIT


  METHOD set_border.

    IF iv_row1 IS NOT INITIAL
         AND iv_row2 IS NOT INITIAL
         AND iv_col1 IS NOT INITIAL
         AND iv_col2 IS NOT INITIAL.
      CALL METHOD me->select_area
        EXPORTING
          iv_row1 = iv_row1
          iv_row2 = iv_row2
          iv_col1 = iv_col1
          iv_col2 = iv_col2.
    ENDIF.

    CALL METHOD OF
        mo_range
        'Borders' = mo_border
        NO
        FLUSH

      EXPORTING
        #1        = iv_border.
    IF sy-subrc EQ 0.
      SET PROPERTY OF mo_border 'LineStyle'  = iv_style NO FLUSH .
      SET PROPERTY OF mo_border 'Weight'     = iv_weight NO FLUSH.
      IF iv_color IS NOT INITIAL.
        SET PROPERTY OF mo_border 'ColorIndex' = iv_color  NO FLUSH.
      ENDIF.
    ENDIF.

    FREE OBJECT mo_border.

  ENDMETHOD.                    "set_border


  METHOD set_cell_value.

    CALL METHOD me->select_cell
      EXPORTING
        iv_x = iv_x
        iv_y = iv_y.


    SET PROPERTY OF mo_cells 'Value' = iv_value NO FLUSH.   "#EC NEEDED

    mo_range = mo_cells.

    "Yatay hizalama
    IF iv_halign IS SUPPLIED.
      me->set_horizontal_alignment( iv_halign ).
    ENDIF.

    "Dikey hizalama
    IF iv_valign IS SUPPLIED.
      me->set_vertical_alignment( iv_valign ).
    ENDIF.

    "Format
    IF iv_format IS SUPPLIED.
      me->set_number_format( iv_format ).
    ENDIF.

    "Dolgu rengi
    IF iv_fcolor IS SUPPLIED.
      me->set_fill_color( iv_fcolor ).
    ENDIF.

    "Yazı tipi formatı
    IF iv_fontcolor IS SUPPLIED. me->set_font_attribute( iv_fontcolor = iv_fontcolor ). ENDIF.
    IF iv_fontstyle IS SUPPLIED. me->set_font_attribute( iv_fontstyle = iv_fontstyle ). ENDIF.

    IF iv_fontsize  IS SUPPLIED.
      me->set_font_attribute( iv_fontsize  = iv_fontsize  ).
    ELSE.
      me->set_font_attribute( iv_fontsize  = me->mv_default_font_size  ).
    ENDIF.

    IF iv_fontname  IS SUPPLIED.
      me->set_font_attribute( iv_fontname  = iv_fontname  ).
    ELSE.
      me->set_font_attribute( iv_fontname  = me->mv_default_font  ).
    ENDIF.

    FREE OBJECT mo_cells.

  ENDMETHOD.                    "set_cell_value


  METHOD set_column_width.
    IF     iv_row1 IS NOT INITIAL
       AND iv_row2 IS NOT INITIAL
       AND iv_col1 IS NOT INITIAL
       AND iv_col2 IS NOT INITIAL.
      CALL METHOD me->select_area
        EXPORTING
          iv_row1 = iv_row1
          iv_row2 = iv_row2
          iv_col1 = iv_col1
          iv_col2 = iv_col2.
    ENDIF.

    CALL METHOD OF
      mo_cells
        'EntireColumn' = mo_entirecolumn
                         NO
                         FLUSH.
    SET PROPERTY OF mo_entirecolumn 'ColumnWidth' = iv_width NO FLUSH .

    FREE OBJECT: mo_cells, mo_entirecolumn.
  ENDMETHOD.                    "set_column_width


  METHOD set_fill_color.
    GET PROPERTY OF mo_cells    'Interior'          = mo_interior.
    SET PROPERTY OF mo_interior 'ColorIndex'        = iv_color NO FLUSH.
    SET PROPERTY OF mo_interior 'Pattern'           = 1 NO FLUSH.
    SET PROPERTY OF mo_interior 'PatternColorIndex' = '-4105' NO FLUSH.
  ENDMETHOD.                    "set_fill_color


  METHOD set_font_attribute.
    GET PROPERTY OF mo_cells 'Font' = mo_font.

    IF sy-subrc EQ 0.
      IF iv_fontname  IS NOT INITIAL. SET PROPERTY OF mo_font 'Name'       = iv_fontname  NO FLUSH.  ENDIF.
      IF iv_fontsize  IS NOT INITIAL. SET PROPERTY OF mo_font 'Size'       = iv_fontsize  NO FLUSH.  ENDIF.
      IF iv_fontstyle IS NOT INITIAL. SET PROPERTY OF mo_font 'FontStyle'  = iv_fontstyle NO FLUSH. ENDIF.
      IF iv_fontcolor IS NOT INITIAL. SET PROPERTY OF mo_font 'ColorIndex' = iv_fontcolor NO FLUSH. ENDIF.
    ENDIF.

    FREE OBJECT mo_font.
  ENDMETHOD.                    "set_font_attribute


  METHOD set_horizontal_alignment.
    SET PROPERTY OF mo_range 'HorizontalAlignment'   = iv_alignment NO FLUSH.
  ENDMETHOD.                    "set_horizontal_alignment


  METHOD set_merge_cells.

    IF iv_cell1 IS NOT INITIAL AND
       iv_cell2 IS NOT INITIAL.
      CALL METHOD me->select_range
        EXPORTING
          iv_cell1 = iv_cell1
          iv_cell2 = iv_cell2.
    ELSEIF iv_row1 IS NOT INITIAL
       AND iv_row2 IS NOT INITIAL
       AND iv_col1 IS NOT INITIAL
       AND iv_col2 IS NOT INITIAL.
      CALL METHOD me->select_area
        EXPORTING
          iv_row1 = iv_row1
          iv_row2 = iv_row2
          iv_col1 = iv_col1
          iv_col2 = iv_col2.
    ENDIF.

    CALL METHOD OF
      mo_cells
      'MERGE'
      NO
      FLUSH.

    IF iv_vertical IS SUPPLIED.
      SET PROPERTY OF mo_cells 'VerticalAlignment'   = iv_vertical NO FLUSH. "#EC NEEDED
    ENDIF.

    IF iv_horizontal IS SUPPLIED.
      SET PROPERTY OF mo_cells 'HorizontalAlignment' = iv_horizontal NO FLUSH. "#EC NEEDED
    ENDIF.

    IF iv_orientation IS SUPPLIED.
      SET PROPERTY OF mo_cells 'Orientation'         = iv_orientation NO FLUSH. "#EC NEEDED
    ENDIF.

    FREE OBJECT: mo_cells, mo_range.
  ENDMETHOD.                    "set_merge_cells


  METHOD set_number_format.
    SET PROPERTY OF mo_range 'NumberFormat' = iv_number_format NO FLUSH.
  ENDMETHOD.                    "SET_NUMBER_FORMAT


  METHOD set_orientation.
  ENDMETHOD.                    "SET_ORIENTATION


  METHOD set_row_height.

    IF iv_row1 IS NOT INITIAL
         AND iv_row2 IS NOT INITIAL
         AND iv_col1 IS NOT INITIAL
         AND iv_col2 IS NOT INITIAL.
      CALL METHOD me->select_area
        EXPORTING
          iv_row1 = iv_row1
          iv_row2 = iv_row2
          iv_col1 = iv_col1
          iv_col2 = iv_col2.
    ENDIF.

    CALL METHOD OF
      mo_cells
        'EntireRow' = mo_entirerow
                      NO
                      FLUSH.
    SET PROPERTY OF mo_entirerow 'RowHeight' = iv_height NO FLUSH.

    FREE OBJECT: mo_cells,
                 mo_entirerow.
  ENDMETHOD.                    "set_row_height


  METHOD set_sheet_name.
    DATA lv_sheet TYPE string.

    lv_sheet = `Sayfa` && iv_sheet_no.

    CALL METHOD OF
        mo_wbook
        'WorkSheets' = mo_wsheet
      EXPORTING
        #1           = lv_sheet.

    IF sy-subrc NE 0.
      lv_sheet = `Sheet` && iv_sheet_no.
      CALL METHOD OF
          mo_wbook
          'WorkSheets' = mo_wsheet
        EXPORTING
          #1           = lv_sheet.
    ENDIF.

    SET PROPERTY OF mo_wsheet 'Name' = iv_sheet_name.
  ENDMETHOD.                    "set_sheet_name


  METHOD set_vertical_alignment.
    SET PROPERTY OF mo_range 'VerticalAlignment'   = iv_alignment NO FLUSH.
  ENDMETHOD.                    "set_vertical_alignment


  METHOD set_visibility.
* Excel'i visible hale getir.
    SET PROPERTY OF mo_excel 'Visible' = iv_visible.
  ENDMETHOD.                    "set_visibility
ENDCLASS.
