*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_V028......................................*
TABLES: ZBYHR_V028, *ZBYHR_V028. "view work areas
CONTROLS: TCTRL_ZBYHR_V028
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V028. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V028.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V028_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V028.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V028_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V028_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V028.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V028_TOTAL.

*.........table declarations:.................................*
TABLES: PA0001                         .
TABLES: ZBYHR_T028                     .
