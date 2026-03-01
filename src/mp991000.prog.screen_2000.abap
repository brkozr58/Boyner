PROCESS BEFORE OUTPUT.
*         general infotype-independent operations
  MODULE before_output.
  CALL SUBSCREEN subscreen_empl   INCLUDING empl_prog empl_dynnr.
  CALL SUBSCREEN subscreen_header INCLUDING header_prog header_dynnr.
*         infotype specific operations
  MODULE p9910.
*
  MODULE hidden_data.
*
PROCESS AFTER INPUT.
*---------------------------------------------------------------------*
*  process exit commands
*---------------------------------------------------------------------*
  MODULE exit AT EXIT-COMMAND.
*---------------------------------------------------------------------*
*         processing after input
*---------------------------------------------------------------------*
*
*         check and mark if there was any input: all fields that
*         accept input HAVE TO BE listed here
*---------------------------------------------------------------------*
  CHAIN.
    FIELD p9910-begda.
    FIELD p9910-endda.
    FIELD p9910-zznema.
*    FIELD p9910-zzprf.
*    FIELD p9910-waers.
    FIELD p9910-klbrc.
    FIELD p9910-albrc.
    FIELD p9910-brkim.
    MODULE input_status ON CHAIN-REQUEST.
  ENDCHAIN.
*---------------------------------------------------------------------*
*      process functioncodes before input-checks                      *
*---------------------------------------------------------------------*
  MODULE pre_input_checks.
*---------------------------------------------------------------------*
*         input-checks:                                               *
*---------------------------------------------------------------------*

*   insert check modules here:

*  ...

*---------------------------------------------------------------------*
*     process function code: ALL fields that appear on the
*      screen HAVE TO BE listed here (including output-only fields)
*---------------------------------------------------------------------*
  CHAIN.
    FIELD p9910-begda.
    FIELD p9910-endda.
    FIELD rp50m-sprtx.
    FIELD p9910-zznema.
*    FIELD p9910-zzprf.
*    FIELD p9910-waers.
    FIELD p9910-klbrc.
    FIELD p9910-albrc.
    FIELD p9910-brkim.
    MODULE post_input_checks.
  ENDCHAIN.
*


