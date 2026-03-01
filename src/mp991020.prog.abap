*----------------------------------------------------------------------*
*                                                                      *
*       Output-modules for infotype 9910                               *
*                                                                      *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       MODULE  P9910 OUTPUT                                           *
*----------------------------------------------------------------------*
*       Default values, Texts                                          *
*----------------------------------------------------------------------*
MODULE P9910 OUTPUT.
  IF PSYST-NSELC EQ YES.
* read text fields etc.; do this whenever the screen is show for the
*  first time:
*   PERFORM RExxxx.
    IF PSYST-IINIT = YES AND PSYST-IOPER = INSERT.
* generate default values; do this the very first time on insert only:
*     PERFORM GET_DEFAULT.
    ENDIF.
  ENDIF.
ENDMODULE.
*----------------------------------------------------------------------*
*       MODULE  P9910L OUTPUT                                          *
*----------------------------------------------------------------------*
*       read texts for listscreen
*----------------------------------------------------------------------*
MODULE P9910L OUTPUT.
* PERFORM RExxxx.
ENDMODULE.
