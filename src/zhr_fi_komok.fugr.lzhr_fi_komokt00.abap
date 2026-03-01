*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZHR_FI_KOMOK....................................*
DATA:  BEGIN OF STATUS_ZHR_FI_KOMOK                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZHR_FI_KOMOK                  .
CONTROLS: TCTRL_ZHR_FI_KOMOK
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZHR_FI_KOMOK                  .
TABLES: ZHR_FI_KOMOK                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
