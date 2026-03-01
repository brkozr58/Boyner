*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_V027......................................*
TABLES: ZBYHR_V027, *ZBYHR_V027. "view work areas
CONTROLS: TCTRL_ZBYHR_V027
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V027. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V027.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V027_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V027.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V027_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V027_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V027.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V027_TOTAL.

*.........table declarations:.................................*
TABLES: PA0001                         .
TABLES: T554S                          .
TABLES: T554T                          .
TABLES: ZBYHR_T027                     .
