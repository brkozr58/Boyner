*&---------------------------------------------------------------------*
*& Include          ZXKNTU02
*&---------------------------------------------------------------------*



*"       IMPORTING
*"             VALUE(I_COBL) LIKE  COBL STRUCTURE  COBL
*"       CHANGING
*"             REFERENCE(E_COBL_CUST) LIKE  BAPICOBL_CI
*"                             STRUCTURE  BAPICOBL_CI
*"       EXCEPTIONS
*"              SEND_MESSAGE
*"----------------------------------------------------------------------

CASE I_COBL-bukrs .
  WHEN '6000'.
*      I_COBL-
  WHEN OTHERS.
ENDCASE.
