*----------------------------------------------------------------------*
***INCLUDE ZBYHR_P016_ALV_CHEK.
*----------------------------------------------------------------------*

DATA : BEGIN OF gt_header OCCURS 0 ,
         listname(30),
         bukrs        LIKE t500p-bukrs,
         werks        LIKE t7trg01-werks,
         btrtl        LIKE t7trg01-btrtl,
         kostl        LIKE pernr-kostl,
       END OF gt_header .

*&---------------------------------------------------------------------*
*& Form chek_alv_list
*&---------------------------------------------------------------------*
FORM  chek_alv_list.


  CASE sy-ucomm.
    WHEN 'DETY'.

    WHEN 'WTYP' OR 'BUKR' OR 'PERS' OR 'COSC' OR 'TRAN' OR 'MALM'.
      REFRESH gt_header.
      PERFORM chk_flg.
      IF h_flg = c_on.
        DO.
          CLEAR: m1.
          READ LINE sy-index FIELD VALUE m1.
          IF sy-subrc NE 0.
            EXIT.
          ELSE.
            CHECK m1 = 'X'.
            IF sy-ucomm EQ 'BUKR'.
              SELECT SINGLE bukrs INTO gt_header-bukrs
              FROM t500p WHERE persa EQ sy-lisel+3(4).
              gt_header-listname = 'BUKRS'.
              COLLECT gt_header. CLEAR gt_header.
            ELSEIF sy-ucomm EQ 'MALM'.
              LOOP AT iper WHERE werks EQ sy-lisel+3(4)
                             AND btrtl EQ sy-lisel+8(4).
                gt_header-listname = 'MALM'.
                gt_header-bukrs = iper-bukrs.
                gt_header-kostl = iper-kostl.
                COLLECT gt_header. CLEAR gt_header.
              ENDLOOP.

            ELSEIF sy-ucomm EQ 'COSC'.
              LOOP AT iper WHERE werks EQ sy-lisel+3(4)
                             AND btrtl EQ sy-lisel+8(4).
                gt_header-listname = 'KOSTL'.
                gt_header-kostl = iper-kostl.
                COLLECT gt_header. CLEAR gt_header.
              ENDLOOP.
            ELSE.
              MOVE sy-lisel+3(4) TO gt_header-werks.
              MOVE sy-lisel+8(4) TO gt_header-btrtl.
              IF sy-ucomm EQ 'WTYP'.
                gt_header-listname = 'WERKS'.

              ENDIF.

              COLLECT gt_header. CLEAR gt_header.
            ENDIF.
            DELETE ADJACENT DUPLICATES FROM gt_header.
            m1 = space.
          ENDIF.
        ENDDO.
      ELSE.
        MESSAGE w010.
      ENDIF.
  ENDCASE.

ENDFORM.
