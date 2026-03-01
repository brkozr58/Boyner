class ZCL_IM_CL_EX_SMOD_PCPO0001 definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SMOD_PCPO0001 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_EX_SMOD_PCPO0001 IMPLEMENTATION.


  METHOD if_ex_smod_pcpo0001~exit_rpcipe00_001.

*    SELECT * FROM zbyhr_t011 INTO TABLE @DATA(lt_t011)
*                                    WHERE bukrs EQ @item-bukrs
*                                    AND   kostl EQ @item-kostl.
*
*    IF sy-subrc EQ 0.
*      SELECT SINGLE komok_mod INTO komok_mod
*                              FROM zhr_fi_komok
*                              WHERE komok = item-komok.
*    ENDIF.

    DATA: ls_hr_fi_kostl TYPE zbyhr_t011.

    SELECT * INTO ls_hr_fi_kostl FROM zbyhr_t011   WHERE bukrs EQ item-bukrs
                                                   AND   kostl EQ item-kostl.
      SELECT SINGLE komok_mod INTO komok_mod
                           FROM zhr_fi_komok
                           WHERE komok = item-komok.
    ENDSELECT.


  ENDMETHOD.


  method IF_EX_SMOD_PCPO0001~EXIT_RPCIPE00_002.
  endmethod.


  method IF_EX_SMOD_PCPO0001~EXIT_RPCIPE00_003.
  endmethod.


  method IF_EX_SMOD_PCPO0001~EXIT_RPCIPE00_004.
  endmethod.
ENDCLASS.
