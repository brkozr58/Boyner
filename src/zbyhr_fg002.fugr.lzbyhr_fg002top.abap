FUNCTION-POOL zbyhr_fg002.                  "MESSAGE-ID ..

* INCLUDE LZBYHR_FG002D...                   " Local class definition

TYPES : BEGIN OF ts_person,
          pernr    TYPE persno,
          ename    TYPE emnam,
          password TYPE i,
          bin_file TYPE xstring,
          trecord  TYPE rspc_t_text,
          tpdf     TYPE tlinet,
          return   TYPE string,
          flag     TYPE flag,
        END OF ts_person,
        tt_person TYPE TABLE OF ts_person.
