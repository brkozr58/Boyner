class ZBYHR_CL_ENCRYPTION definition
  public
  create public .

public section.

  methods GET_KEY
    returning
      value(E_KEY) type XSTRING .             " Method to generate encryption key
  methods ENCRYPT_TEXT
    importing
      !I_KEY type STRING
      !I_IV type STRING
      value(I_TEXT) type STRING optional
      value(I_XSTRING) type XSTRING optional
    returning
      value(E_TEXT_ENC) type XSTRING .         " Encrypted Base64 encoded string
  methods DECRYPT_TEXT
    importing
      !I_KEY type STRING
      !I_IV type STRING
      value(I_ENCODED_TEXT_XST) type XSTRING optional
      value(I_ENCODED_TEXT) type STRING optional
    exporting
      !ERR_TEXT type STRING
      value(E_TEXT_STR) type STRING
      value(E_TEXT_XSTR) type XSTRING .
private section.

  constants C_IV type XSTRING value '0000000000000000' ##NO_TEXT.
  data C_KEY type XSTRING .
ENDCLASS.



CLASS ZBYHR_CL_ENCRYPTION IMPLEMENTATION.


  METHOD decrypt_text.
    DATA lv_xstring   TYPE xstring.
    DATA : lv_key TYPE xstring .

    lv_key = cl_bcs_convert=>string_to_xstring(
               iv_string     = i_key ).

    " Decode the Base64 encoded input text
    IF i_encoded_text IS NOT INITIAL.
      CALL FUNCTION 'SCMS_BASE64_DECODE_STR'
        EXPORTING
          input  = i_encoded_text
        IMPORTING
          output = lv_xstring.

      IF sy-subrc <> 0 OR lv_xstring IS INITIAL.
        " Handle Base64 decoding failure
        err_text = 'Veri Çözülemedi'.
        RETURN.
      ENDIF.
    ENDIF.

    IF i_encoded_text_xst IS NOT INITIAL .
      lv_xstring = i_encoded_text_xst.
    ENDIF.

    " Proceed with decryption if the xstring is not empty
    IF lv_xstring IS NOT INITIAL.
      TRY.

          " Add 16-byte padding before decryption
          CONCATENATE c_iv(16) lv_xstring INTO lv_xstring IN BYTE MODE.

          " Decrypt the ciphertext
          DATA: lv_message_decrypted TYPE xstring.
          cl_sec_sxml_writer=>decrypt(
            EXPORTING
              ciphertext = lv_xstring
              key        = lv_key
              algorithm  = cl_sec_sxml_writer=>co_aes256_algorithm_pem
            IMPORTING
              plaintext  = e_text_xstr  ).

          " Convert the decrypted xstring to a string for output
          cl_abap_conv_in_ce=>create( input = e_text_xstr )->read( IMPORTING data = e_text_str ).

        CATCH cx_sec_sxml_encrypt_error INTO DATA(oref).
          " Handle decryption errors
          err_text = 'Şifre çözme başarısız oldu: ' && oref->get_longtext( ).
      ENDTRY.
    ELSE.
      " Handle the case where the xstring is empty after decoding
      err_text = 'Veri Çözülemedi'.
    ENDIF.

  ENDMETHOD.


  METHOD encrypt_text.
    DATA : lv_key TYPE xstring .
    DATA : lv_kiv TYPE xstring .

    DATA: lv_xstring  TYPE xstring,
          lv_message  TYPE xstring,
          lr_conv_sec TYPE REF TO cl_abap_conv_out_ce,
          lr_xstring  TYPE xstring.

    lv_key = cl_bcs_convert=>string_to_xstring( iv_string  = i_key ).
    lv_kiv = cl_bcs_convert=>string_to_xstring( iv_string  = i_iv ).

    " Convert plain text to xstring
    IF i_text IS NOT INITIAL .
      lr_conv_sec = cl_abap_conv_out_ce=>create( ).
      lr_conv_sec->write( data = i_text ).
      lv_xstring = lr_conv_sec->get_buffer( ).
    ELSE.
      lv_xstring = i_xstring.
    ENDIF.


    " Encrypt the xstring using AES-256 algorithm
    cl_sec_sxml_writer=>encrypt_iv(
      EXPORTING
        plaintext  = lv_xstring
        key        = lv_key
        algorithm  = cl_sec_sxml_writer=>co_aes256_algorithm_pem
        iv         = lv_kiv
      IMPORTING
        ciphertext = e_text_enc ).
*        ciphertext = lv_message ).

*    " Remove the 16-byte padding before encoding
*    lr_xstring = lv_message+16.

*    " Encode the result as Base64
*    CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
*      EXPORTING
*        input  = lr_xstring
*      IMPORTING
*        output = e_text_enc.

  ENDMETHOD.


  METHOD get_key.
    DATA: random      TYPE xstring,
          lr_conv_key TYPE REF TO cl_abap_conv_out_ce.

    " Generate a random key using AES-256 algorithm
    CALL METHOD cl_sec_sxml_writer=>generate_key
      EXPORTING
        algorithm = cl_sec_sxml_writer=>co_aes256_algorithm
      RECEIVING
        key       = random.

    " Convert the key to a string format
    lr_conv_key = cl_abap_conv_out_ce=>create( ).
    lr_conv_key->write( data = random ).
    e_key = lr_conv_key->get_buffer( ).
  ENDMETHOD.
ENDCLASS.
