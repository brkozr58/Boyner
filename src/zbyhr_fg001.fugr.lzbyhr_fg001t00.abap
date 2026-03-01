*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T003......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T003                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T003                    .
CONTROLS: TCTRL_ZBYHR_T003
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZBYHR_T004......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T004                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T004                    .
CONTROLS: TCTRL_ZBYHR_T004
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZBYHR_T005......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T005                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T005                    .
CONTROLS: TCTRL_ZBYHR_T005
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZBYHR_T006......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T006                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T006                    .
CONTROLS: TCTRL_ZBYHR_T006
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: ZBYHR_T007......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T007                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T007                    .
CONTROLS: TCTRL_ZBYHR_T007
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: ZBYHR_T008......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T008                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T008                    .
CONTROLS: TCTRL_ZBYHR_T008
            TYPE TABLEVIEW USING SCREEN '0008'.
*...processing: ZBYHR_V001......................................*
TABLES: ZBYHR_V001, *ZBYHR_V001. "view work areas
CONTROLS: TCTRL_ZBYHR_V001
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V001. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V001.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V001_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V001.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V001_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V001_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V001.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V001_TOTAL.

*...processing: ZBYHR_V002......................................*
TABLES: ZBYHR_V002, *ZBYHR_V002. "view work areas
CONTROLS: TCTRL_ZBYHR_V002
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZBYHR_V002. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V002.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V002_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V002.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V002_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V002_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V002.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V002_TOTAL.

*.........table declarations:.................................*
TABLES: *ZBYHR_T003                    .
TABLES: *ZBYHR_T004                    .
TABLES: *ZBYHR_T005                    .
TABLES: *ZBYHR_T006                    .
TABLES: *ZBYHR_T007                    .
TABLES: *ZBYHR_T008                    .
TABLES: T001                           .
TABLES: ZBYHR_T001                     .
TABLES: ZBYHR_T002                     .
TABLES: ZBYHR_T003                     .
TABLES: ZBYHR_T004                     .
TABLES: ZBYHR_T005                     .
TABLES: ZBYHR_T006                     .
TABLES: ZBYHR_T007                     .
TABLES: ZBYHR_T008                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
