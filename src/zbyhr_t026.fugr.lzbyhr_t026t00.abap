*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T026......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T026                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T026                    .
CONTROLS: TCTRL_ZBYHR_T026
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T026                    .
TABLES: ZBYHR_T026                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
