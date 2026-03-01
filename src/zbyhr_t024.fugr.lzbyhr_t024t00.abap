*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T024......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T024                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T024                    .
CONTROLS: TCTRL_ZBYHR_T024
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T024                    .
TABLES: ZBYHR_T024                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
