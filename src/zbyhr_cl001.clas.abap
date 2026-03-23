class ZBYHR_CL001 definition
  public
  final
  create public .

public section.

  types TS_T002 type ZBYHR_T002 .
  types:
    Tt_T002 TYPE TABLE OF Ts_T002 .

  data MT_T002 type TT_T002 .

  methods CONSTRUCTOR
    importing
      !TCODE type TCODE .
  methods REST_TRASNPORT_FILE
    changing
      !S_FILE type ZBYHR_S001 .
  methods FILE_CONVERT_BINARY
    importing
      !T_DATA type TABLE
    exporting
      value(E_BINARY) type XSTRING
      value(E_DATA) type STRING .
  methods SOAP_TRASNPORT_FILE
    changing
      !S_FILE type ZBYHR_S001 .
protected section.
private section.

  methods JSON_PARSE
    importing
      !RESPONSE type STRING
    exporting
      value(RETURN) type STRING
      value(T_RETURN) type TABLE .
ENDCLASS.



CLASS ZBYHR_CL001 IMPLEMENTATION.


  METHOD constructor.

    SELECT * FROM  zbyhr_t002 INTO TABLE mt_t002
           WHERE  tcode  = tcode.
  ENDMETHOD.


  METHOD file_convert_binary.
    DATA : hex_tab  TYPE solix_tab.
    DATA: ascii_data   TYPE solisti1,
          string_data  TYPE string,
          xstring_data TYPE xstring.
    DATA: lv_lines TYPE i.

    DATA: lv_text    TYPE string.

    DATA: bytes TYPE i.

    DESCRIBE TABLE t_data LINES lv_lines.

    CALL FUNCTION 'SCMS_TEXT_TO_XSTRING'
      EXPORTING
        encoding = '4110'
      IMPORTING
        buffer   = e_binary
      TABLES
        text_tab = t_data
      EXCEPTIONS
        failed   = 1.


    CALL FUNCTION 'SSFC_BASE64_ENCODE'
      EXPORTING
        bindata = e_binary
      IMPORTING
        b64data = e_data
      EXCEPTIONS
        OTHERS  = 1.



  ENDMETHOD.


  METHOD json_parse.


    DATA:
      lv_comp       TYPE string,
      lv_xstring    TYPE xstring,
      lo_descr      TYPE REF TO cl_abap_tabledescr,
      lo_type       TYPE REF TO cl_abap_datadescr,
      lo_struct     TYPE REF TO cl_abap_structdescr,
      ls_component  TYPE cl_abap_structdescr=>component,
      lt_components TYPE cl_abap_structdescr=>component_table.

    IF t_return IS REQUESTED .
      lo_descr     ?= cl_abap_typedescr=>describe_by_data( t_return ).
      lo_type       = lo_descr->get_table_line_type( ).
      lo_struct    ?= cl_abap_typedescr=>describe_by_name(
                        lo_type->absolute_name ).
      lt_components = lo_struct->get_components( ).
    ENDIF.





    DATA:
      lv_json_body TYPE string,
      lmsg_data    TYPE REF TO data.

    FIELD-SYMBOLS:
      <l_msg_data> TYPE any,
      <success>    TYPE any,
      <lv_val>     TYPE any.

*    lv_json_body = response.

    " Generate dynamic structure to suit the data
*    lmsg_data = /ui2/cl_json=>generate( json = lv_json_body ).
*    ASSIGN lmsg_data->* TO <l_msg_data>.
**
*User [boynermaas_internal] has no view rights to [/BOYNERMAAS_Garanti/Garanti_BOYNERMAAS/MAAS/Outbox].
    FIND FIRST OCCURRENCE OF REGEX '<callUploadServiceResult>(.*)</callUploadServiceResult>'
      IN response
      IGNORING CASE
      SUBMATCHES return.
    IF sy-subrc NE 0 .
      return = 'true'.
    ENDIF.


*    " Deserialize the JSON string into the matching deep datatype
*    /ui2/cl_json=>deserialize(
*            EXPORTING
*                  json        = lv_json_body
*                  pretty_name = /ui2/cl_json=>pretty_mode-camel_case
*            CHANGING
*                data = <l_msg_data> ).
*
*    IF return IS REQUESTED .
*      " Save the position data in resource table
*      ASSIGN COMPONENT 'SUCCESS' OF STRUCTURE <l_msg_data> TO <success>.
*      ASSIGN <success>->* TO <lv_val>.
*      return = <lv_val>.
*    ENDIF.
*
*    IF t_return IS REQUESTED .
*
*    ENDIF.


*  DATA:
*    lv_json_body  TYPE string,
*    lmsg_data     TYPE REF TO data,
**    lo_item_struct TYPE REF TO cl_abap_structdescr,
*    lo_pos_struct TYPE REF TO cl_abap_structdescr.
*  DATA : ls_data        TYPE zdfhr_s029.
*
*  FIELD-SYMBOLS:
*    <l_msg_data>   TYPE any,
*    <l_postab_ref> TYPE any,
*    <lt_postab>    TYPE ANY TABLE,
*    <l_item_ref>   TYPE any,
*    <lt_item>      TYPE ANY TABLE,
*    <l_pos>        TYPE any,
*    <l_fstr>       TYPE any,
*    <l_fvalue>     TYPE any,
*    <l_fm>         TYPE any,
*    <lv_val>       TYPE any.
*
*
*  DEFINE value_marge.
*
*    ASSIGN COMPONENT &1 OF STRUCTURE <ls_item> TO <l_fvalue>.
*    IF sy-subrc <> 0. EXIT. ENDIF.
*    ASSIGN COMPONENT &1 OF STRUCTURE ls_data TO <l_fm>.
*    IF sy-subrc <> 0. EXIT. ENDIF.
*    ASSIGN <l_fvalue>->* TO <lv_val>.
*    <l_fm> = <lv_val>.
*
*  END-OF-DEFINITION.
*
*
*  lv_json_body = p_response.
*
*  " Generate dynamic structure to suit the data
*  lmsg_data = /ui2/cl_json=>generate( json = lv_json_body ).
*  ASSIGN lmsg_data->* TO <l_msg_data>.
*
*  " Deserialize the JSON string into the matching deep datatype
*  /ui2/cl_json=>deserialize( EXPORTING json = lv_json_body pretty_name = /ui2/cl_json=>pretty_mode-camel_case CHANGING data = <l_msg_data> ).
*
*  " Save the position data in resource table
*  ASSIGN COMPONENT 'ET_DATA' OF STRUCTURE <l_msg_data> TO <l_postab_ref>.
*  ASSIGN <l_postab_ref>->* TO <lt_postab>.
*
*  " Loop over the table
*  LOOP AT <lt_postab> ASSIGNING FIELD-SYMBOL(<l_posref>).
*    ASSIGN <l_posref>->* TO <l_pos>.
*
*    ASSIGN COMPONENT 'ITEM' OF STRUCTURE <l_pos> TO <l_item_ref>.
*    ASSIGN <l_item_ref>->* TO <lt_item>.
*
*    LOOP AT <lt_item> ASSIGNING FIELD-SYMBOL(<l_item>) .
*      ASSIGN <l_item>->* TO FIELD-SYMBOL(<ls_item>).
*
*      value_marge : 'KOSTL',
*                    'BUKRS',
*                    'KOSAR',
*                    'LTEXT',
*                    'BKZKP',
*                    'PKZKP',
*                    'BKZKS',
*                    'PKZKS',
*                    'BKZER',
*                    'PKZER'.
*
*      APPEND ls_data TO pt_data . CLEAR : ls_data .
*    ENDLOOP.
*
*  ENDLOOP.
  ENDMETHOD.


  METHOD rest_trasnport_file.


    DATA : lv_url         TYPE string,
           lv_uname       TYPE string VALUE 'TESTUSER',
           lv_username    TYPE string,
           lv_password    TYPE string,
           http_client    TYPE REF TO if_http_client,
           lv_httpcode    TYPE i,
           lv_reason      TYPE string,
           lo_rest_client TYPE REF TO cl_rest_http_client,
           lo_response    TYPE REF TO if_rest_entity,
           file_name      TYPE   zbyhr_de005,
           wf_string      TYPE string,
           rlength        TYPE i,
           return         TYPE string,
           bin_file       TYPE string,
           response       TYPE string,
           it_return      TYPE TABLE OF  bapiret2,
           lv_user        TYPE string,
           lv_pass        TYPE string.

    READ TABLE me->mt_t002 INTO DATA(ls_t002) WITH KEY bukrs = s_file-bukrs .
    IF sy-subrc NE 0 OR ls_t002-pfile IS INITIAL .
      s_file-return = 'Dosya yolunu uyarlama tablosuna giriniz.'.
      EXIT.
    ENDIF.
*


    lv_url = 'https://integration-suite-boyner-dev.it-cpi024-rt.cfapps.eu10-002.hana.ondemand.com/cxf/SFBordroUploadService'.
    lv_user = 'sb-d2368223-0848-475f-9a23-af554aba692e!b550443|it-rt-integration-suite-boyner-dev!b182722'.
    lv_pass = '02189b29-d15c-4c84-9ee0-1bae741de3e7$_N3xcbMxDxXjAh8NZMn7dFxNBcOCccvS7fgEVJxkENM='.

    TRY.

        CALL METHOD cl_http_client=>create_by_url
          EXPORTING
            url                        = lv_url
          IMPORTING
            client                     = http_client
          EXCEPTIONS
            argument_not_found         = 1
            plugin_not_active          = 2
            internal_error             = 3
            pse_not_found              = 4
            pse_not_distrib            = 5
            pse_errors                 = 6
            oa2c_set_token_error       = 7
            oa2c_missing_authorization = 8
            oa2c_invalid_config        = 9
            oa2c_invalid_parameters    = 10
            oa2c_invalid_scope         = 11
            oa2c_invalid_grant         = 12
            OTHERS                     = 13.

        IF http_client IS BOUND.
          " Basic Auth
          lv_username = lv_user.
          lv_password = lv_pass.
          http_client->authenticate(
            username = lv_username
            password = lv_password
          ).
          http_client->request->set_method( 'POST' ).
          http_client->request->set_header_field(
                              name  = 'Content-Type'
                              value = 'text/xml; charset=utf-8'
                            ).
          http_client->request->set_header_field(
                              name  = 'SOAPAction'
                              value = 'http://tempuri.org/callUploadService'
                            ).

          wf_string =    |<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" |
                    && |xmlns:tem="http://tempuri.org/">|
                    && |<soapenv:Header/>|
                    && |<soapenv:Body>|
                    && |<tem:callUploadService>|
                    && |<tem:host>217.68.215.20</tem:host>|
*                              && |<tem:host>192.168.125.44</tem:host>|
                    && |<tem:port>10022</tem:port>|
                    && |<tem:userName>boynermaas</tem:userName>|
                    && |<tem:password>B7x3C2mLGr</tem:password>|
                    && |<tem:data>{ s_file-bin_file }</tem:data>|
*                    && |<tem:fileName>Garanti_Bankasi.txt</tem:fileName>|
                    && |<tem:fileName>{ s_file-pname }</tem:fileName>|
*                    && |<tem:fileDirectory>/Garanti_BOYNERMAAS/MAAS/Outbox</tem:fileDirectory>|
                    && |<tem:fileDirectory>{ s_file-dname }</tem:fileDirectory>|

                    && |</tem:callUploadService>|
                    && |</soapenv:Body>|
                    && |</soapenv:Envelope>|.

          rlength = strlen( wf_string ).

          http_client->request->set_cdata(
                    EXPORTING
                          data   = wf_string
                          offset = 0
                          length = rlength ).
          http_client->send(
              EXCEPTIONS
                http_communication_failure = 1
                http_invalid_state         = 2 ).
          http_client->receive(
            EXCEPTIONS
                http_communication_failure = 1
                http_invalid_state         = 2
                http_processing_failed     = 3
                OTHERS                     = 4 ).

          return = http_client->response->get_cdata( ).


*   get status of the response
          CALL METHOD http_client->response->get_status
            IMPORTING
              code   = lv_httpcode
              reason = lv_reason.
          CASE lv_httpcode.
            WHEN '200'.
* Instantiate REST client
              CREATE OBJECT lo_rest_client
                EXPORTING
                  io_http_client = http_client.

* Get Response data
              lo_response = lo_rest_client->if_rest_client~get_response_entity( ).

* Get string data
              response = lo_response->get_string_data( ).
* Convert string to Abap structures (better than /UI2/CL_JSON, converts even tables without field names and just values)
              json_parse(
                EXPORTING
                  response = response
                IMPORTING
                  return   = s_file-return
              ).

              IF s_file-return EQ 'true'.
                s_file-return = TEXT-bsr.
*              ELSE.
*                s_file-return = TEXT-003.
              ENDIF.


            WHEN OTHERS .
              s_file-return = TEXT-003.
          ENDCASE.

          CALL METHOD http_client->close
            EXCEPTIONS
              http_invalid_state = 1
              OTHERS             = 2.
        ENDIF.



      CATCH cx_ai_system_fault INTO DATA(lo_cx) .
        s_file-return = CONV text100( lo_cx->get_text( ) ) .
    ENDTRY.

  ENDMETHOD.


  METHOD soap_trasnport_file.
*    DATA: lo_ws_header    TYPE REF TO if_wsprotocol_ws_header,
*          lo_ixml         TYPE REF TO if_ixml,
*          lo_xml_document TYPE REF TO if_ixml_document,
*          lo_xml_root     TYPE REF TO if_ixml_element,
*          lo_xml_element  TYPE REF TO if_ixml_element,
*          lo_xml_node     TYPE REF TO if_ixml_node.
*
*
*    DATA lo_file TYPE REF TO zhrpa_sftpco_file.
*    DATA : input  TYPE zhrpa_sftpfile_request,
*           output  TYPE zhrpa_sftpfile_response.
*    DATA: lf_name           TYPE string,
*          lf_namespace      TYPE string,
*          lf_header_string  TYPE string,
*          lf_header_xstring TYPE xstring.
*    DATA : l_string TYPE string .
*    DATA: lv_timestamp TYPE timestamp,
*          lv_ttamp     TYPE char20.
*    GET TIME STAMP FIELD lv_timestamp.
*    lv_ttamp+0(15) = lv_timestamp.
*      CONCATENATE lv_ttamp+00(4)
*          '-' lv_ttamp+04(2)
*          '-' lv_ttamp+06(2)
*          'T' lv_ttamp+08(2)
*          ':' lv_ttamp+10(2)
*          ':' lv_ttamp+12(2) 'Z'
*         INTO lv_ttamp.
*
*    CONCATENATE
*    '<soapenv:Header>'
**       '<wsse:Security soapenv:mustUnderstand="1"xmlns:wsse="http://'
**       'docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-'
**       'secext-1.0.xsd"xmlns:wsu="http://docs.oasis-open.org/wss/2004'
**       '/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
*          '<wsse:UsernameToken'
*          ' wsu:Id="UsernameToken-912281975EB361399817412682883963">'
*             '<wsse:Username>S0026602753</wsse:Username>'
*             '<wsse:Password Type="http://docs.oasis-open.org/wss/2004'
*             '/01/oasis-200401-wss-username-token-profile-1.0#'
*             'PasswordText">Hld2024!</wsse:Password>'
*             '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/'
*             '2004/01/oasis-200401-wss-soap-message-security-1.0#'
*             'Base64Binary">xV40HTRVG8TCYxP75zb5jQ==</wsse:Nonce>'
*             '<wsu:Created>' lv_ttamp '</wsu:Created>'
*          '</wsse:UsernameToken>'
**       '</wsse:Security>'
*    '</soapenv:Header>'
*    INTO l_string .
*
*
*
*
*    TRY.
*        CREATE OBJECT lo_file TYPE zhrpa_sftpco_file
*          EXPORTING
*            logical_port_name = 'ZHRPA_SFTPCO_FILE'.
*        lo_ws_header ?= lo_file->get_protocol(
*                          if_wsprotocol=>ws_header ).
*
*        IF lo_ws_header IS BOUND.
*
*          lf_header_xstring = cl_proxy_service=>cstring2xstring(
*                                      l_string ).
*
*          CALL FUNCTION 'SDIXML_XML_TO_DOM'
*            EXPORTING
*              xml           = lf_header_xstring
*            IMPORTING
*              document      = lo_xml_document
*            EXCEPTIONS
*              invalid_input = 1
*              OTHERS        = 2.
*
*          IF sy-subrc = 0 AND lo_xml_document IS BOUND.
*            lo_xml_root = lo_xml_document->get_root_element( ).
*            lo_xml_element ?= lo_xml_root->get_first_child( ).
*            WHILE NOT lo_xml_element IS INITIAL.
*              lf_name      = lo_xml_element->get_name( ).
*              lf_namespace = lo_xml_element->get_namespace_uri( ).
*              lo_ws_header->set_request_header(
*                                 name      = lf_name
*                                 namespace = lf_namespace
*                                 dom       = lo_xml_element ).
*              lo_xml_element ?= lo_xml_element->get_next( ).
*            ENDWHILE.
*          ELSE.
*            DATA(error) = 'X' .
*          ENDIF.
*        ENDIF.
*
*
*
*        READ TABLE mt_t072 INTO DATA(ls_t072)
*              WITH KEY bukrs = s_file-bukrs.
*        IF sy-subrc EQ 0 AND error IS INITIAL .
*          input-file_path = ls_t072-pfile.
*          input-company_code = s_file-bukrs.
*          IF ls_t072-pname IS NOT INITIAL .
*            SEARCH '&' FOR ls_t072-pname .
*            IF sy-subrc EQ 0 .
*              REPLACE ALL OCCURRENCES OF '&' IN ls_t072-pname
*                    WITH s_file-spmon.
*            ENDIF.
*            input-file_name = ls_t072-pname.
*
*          ELSE.
*            input-file_name = s_file-pname.
*          ENDIF.
*          input-binary = s_file-bin_file.
*
*          CALL METHOD lo_file->file_ws
*            EXPORTING
*              input  = input
*            IMPORTING
*              output = output.
*          s_file-return = CONV text100( output-success ) .
*        ELSE.
*          s_file-return =  text-001  .
*        ENDIF.
*
*      CATCH cx_ai_system_fault INTO DATA(lo_cx) .
*        s_file-return = CONV text100( lo_cx->get_text( ) ) .
*    ENDTRY.

  ENDMETHOD.
ENDCLASS.
