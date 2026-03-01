"Name: \TY:CL_HRPAY99_POSTING_ENGINE\ME:CALL_EXIT_ONE\SE:END\EI
ENHANCEMENT 0 ZHR_FI_CALL_EXIT_ONE.
DATA: lv_komok_mod TYPE komok.


SELECT SINGLE komok_mod INTO lv_komok_mod
                       FROM zhr_fi_komok
                       WHERE komok_mod = cs_ep-komok.
IF sy-subrc NE 0.

  IF is_dist-lgart EQ '/N06'.
    SELECT SINGLE kostltesviksiz
           INTO cs_ep-kostl
                      FROM zbyhr_t011
                      WHERE bukrs = cs_ep-bukrs
                      AND   kostl = cs_ep-kostl.
    CLEAR cs_ep-posnr.
  ELSE.
    SELECT SINGLE kostltesviksiz posnrtesviksiz
           INTO (cs_ep-kostl, cs_ep-posnr)
                      FROM zbyhr_t011
                      WHERE bukrs = cs_ep-bukrs
                      AND   kostl = cs_ep-kostl.
  ENDIF.
*      cs_ep-kostl = 'BP0504'.

ENDIF.

ENDENHANCEMENT.
