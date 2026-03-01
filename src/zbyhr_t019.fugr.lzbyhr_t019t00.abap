*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBYHR_T019......................................*
DATA:  BEGIN OF STATUS_ZBYHR_T019                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBYHR_T019                    .
CONTROLS: TCTRL_ZBYHR_T019
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZBYHR_T019                    .
TABLES: ZBYHR_T019                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
