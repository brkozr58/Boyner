*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T022......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T022                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T022                    .
CONTROLS: TCTRL_ZBYHR_T022
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T022                    .
TABLES: ZBYHR_T022                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
