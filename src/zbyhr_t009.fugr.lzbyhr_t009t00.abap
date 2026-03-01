*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T009......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T009                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T009                    .
CONTROLS: TCTRL_ZBYHR_T009
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T009                    .
TABLES: ZBYHR_T009                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
