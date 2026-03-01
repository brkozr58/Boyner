*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_V021......................................*
TABLES: ZBYHR_V021, *ZBYHR_V021. "view work areas
CONTROLS: TCTRL_ZBYHR_V021
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V021. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V021.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V021_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V021.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V021_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V021_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V021.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V021_TOTAL.

*.........table declarations:.................................*
TABLES: T512T                          .
TABLES: T512W                          .
TABLES: ZBYHR_T021                     .
