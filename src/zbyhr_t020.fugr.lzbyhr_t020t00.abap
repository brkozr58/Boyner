*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T020......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T020                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T020                    .
CONTROLS: TCTRL_ZBYHR_T020
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T020                    .
TABLES: ZBYHR_T020                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
