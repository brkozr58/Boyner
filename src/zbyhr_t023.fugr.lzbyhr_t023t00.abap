*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T023......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T023                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T023                    .
CONTROLS: TCTRL_ZBYHR_T023
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T023                    .
TABLES: ZBYHR_T023                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
