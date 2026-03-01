*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_V004......................................*
TABLES: ZBYHR_V004, *ZBYHR_V004. "view work areas
CONTROLS: TCTRL_ZBYHR_V004
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V004. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V004.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V004_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V004.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V004_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V004_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V004.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V004_TOTAL.

*.........table declarations:.................................*
TABLES: CSKS                           .
TABLES: T001                           .
TABLES: T542A                          .
TABLES: T542T                          .
TABLES: ZBYHR_T010                     .
