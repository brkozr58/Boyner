*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBYHR_T011
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBYHR_T011         .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
