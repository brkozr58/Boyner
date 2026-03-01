*----------------------------------------------------------------------*
*                                                                      *
*       Data definition for infotype 9910                              *
*                                                                      *
*----------------------------------------------------------------------*
PROGRAM MP991000 MESSAGE-ID RP.

TABLES: P9910.
* the following tables are filled globally:
* T001P, T500P
* they can be made available with a TABLES-statement

FIELD-SYMBOLS: <PNNNN> STRUCTURE P9910
                       DEFAULT P9910.

DATA: PSAVE LIKE P9910.
