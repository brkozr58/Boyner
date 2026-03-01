*&---------------------------------------------------------------------*
*& REPORT ZBYHR_P012
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbyhr_p012 NO STANDARD PAGE HEADING
**                    LINE-COUNT 65 LINE-SIZE 187 .
                    LINE-COUNT 65 LINE-SIZE 197.
*                    LINE-COUNT 65 LINE-SIZE 202.


INCLUDE zbyhr_p012_i001. " DATA DEFINITIONS

INCLUDE rpc2cd00.            " PAYROLL INCLUDES
INCLUDE rpc2rxx0.            " PAYROLL INCLUDES
INCLUDE rpc2rx00.            " PAYROLL INCLUDES
INCLUDE rpppxd00.            " PAYROLL INCLUDES
INCLUDE rpppxd10.            " PAYROLL INCLUDES
INCLUDE rpppxm00.            " PAYROLL INCLUDES
INCLUDE pc2rxtr0.            " PAYROLL INCLUDES

INCLUDE zbyhr_p012_i002. " MASTER DATA DEFINITIONS
INCLUDE zbyhr_p012_i003. " SELECTION SCREEN
INCLUDE zbyhr_p012_i004. " PERFORM DEFINITION
INCLUDE zbyhr_p012_i005. " PERSONEL DATA
INCLUDE zbyhr_p012_i006. " DESIGN SCREEN
INCLUDE zbyhr_p012_i007.

* AT SELECTION-SCREEN .
AT SELECTION-SCREEN .
  PERFORM at_selection_screen .

* INITIALIZATION.
INITIALIZATION.
  PERFORM initialization .

AT USER-COMMAND.
  PERFORM user_comm.

AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output.



* START-OF-SELECTION.
START-OF-SELECTION.
  PERFORM set_initial_conditions.
  PERFORM get_wage_type_def.
  CLEAR :  col,col[].

GET pernr.
  CHECK SELECT-OPTIONS.
  PERFORM fill_personel_data.

* END-OF-SELECTION.
END-OF-SELECTION.

  PERFORM last_process    .
  PERFORM find_sub_total  .
  IF p_alv NE 'X'.
*    PERFORM write_to_screen .
    PERFORM write_to_screen2 .
  ENDIF.
