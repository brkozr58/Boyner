*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T016......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T016                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T016                    .
CONTROLS: TCTRL_ZBYHR_T016
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZBYHR_T017......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T017                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T017                    .
CONTROLS: TCTRL_ZBYHR_T017
            TYPE TABLEVIEW USING SCREEN '0006'.
*...processing: ZBYHR_T018......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T018                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T018                    .
CONTROLS: TCTRL_ZBYHR_T018
            TYPE TABLEVIEW USING SCREEN '0007'.
*...processing: ZBYHR_V012......................................*
TABLES: ZBYHR_V012, *ZBYHR_V012. "view work areas
CONTROLS: TCTRL_ZBYHR_V012
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZBYHR_V012. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V012.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V012_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V012.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V012_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V012_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V012.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V012_TOTAL.

*...processing: ZBYHR_V013......................................*
TABLES: ZBYHR_V013, *ZBYHR_V013. "view work areas
CONTROLS: TCTRL_ZBYHR_V013
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZBYHR_V013. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V013.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V013_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V013.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V013_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V013_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V013.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V013_TOTAL.

*...processing: ZBYHR_V014......................................*
TABLES: ZBYHR_V014, *ZBYHR_V014. "view work areas
CONTROLS: TCTRL_ZBYHR_V014
TYPE TABLEVIEW USING SCREEN '0003'.
DATA: BEGIN OF STATUS_ZBYHR_V014. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V014.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V014_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V014.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V014_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V014_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V014.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V014_TOTAL.

*...processing: ZBYHR_V015......................................*
TABLES: ZBYHR_V015, *ZBYHR_V015. "view work areas
CONTROLS: TCTRL_ZBYHR_V015
TYPE TABLEVIEW USING SCREEN '0004'.
DATA: BEGIN OF STATUS_ZBYHR_V015. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V015.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V015_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V015.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V015_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V015_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V015.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V015_TOTAL.

*...processing: ZBYHR_V018......................................*
TABLES: ZBYHR_V018, *ZBYHR_V018. "view work areas
CONTROLS: TCTRL_ZBYHR_V018
TYPE TABLEVIEW USING SCREEN '0008'.
DATA: BEGIN OF STATUS_ZBYHR_V018. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZBYHR_V018.
* Table for entries selected to show on screen
DATA: BEGIN OF ZBYHR_V018_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V018.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V018_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZBYHR_V018_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZBYHR_V018.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZBYHR_V018_TOTAL.

*.........table declarations:.................................*
TABLES: *ZBYHR_T016                    .
TABLES: *ZBYHR_T017                    .
TABLES: *ZBYHR_T018                    .
TABLES: T512T                          .
TABLES: T512W                          .
TABLES: ZBYHR_T012                     .
TABLES: ZBYHR_T013                     .
TABLES: ZBYHR_T014                     .
TABLES: ZBYHR_T015                     .
TABLES: ZBYHR_T016                     .
TABLES: ZBYHR_T017                     .
TABLES: ZBYHR_T018                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
