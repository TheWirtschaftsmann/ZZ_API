class lcl_app definition final.
  public section.

    class-methods create
      returning
        value(ro_instance) type ref to lcl_app.

    methods run
      importing
        is_sel_opts type gty_sel_opts.

  private section.
    data ms_sel_opts type gty_sel_opts.

    methods build_request_uri
      returning
        value(rv_uri) type string.

endclass.

class lcl_app implementation.

  method create.
    create object ro_instance.
  endmethod.

  method run.

    ms_sel_opts = is_sel_opts.

    constants: lc_destination type rfcdest value 'ZZ_NBU'.

    data li_client type ref to if_http_client.
    cl_http_client=>create_by_destination(
      exporting
        destination = lc_destination
      importing
        client = li_client ).

    cl_http_utility=>set_request_uri(
      request = li_client->request
      uri     = build_request_uri( ) ).

    li_client->request->set_method( if_http_request=>co_request_method_get ).
    li_client->request->set_content_type( 'text/xml' ).

    data lv_code type i.
    li_client->send( ).
    li_client->receive(
      exceptions
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3
        others                     = 4 ).

    if sy-subrc <> 0.
      data lv_message type string.
      li_client->get_last_error(
        importing
          code    = lv_code
          message = lv_message ).
      write: / lv_code, lv_message.
      return.
    endif.

    li_client->response->get_status( importing code = lv_code ).
    " PEBO: check the value of the lv_code
*    write: / lv_code.

    data lv_data type string.
    lv_data = li_client->response->get_cdata( ).

    types:
      begin of ty_rates,
        waers type bkpf-waers,
        date  type bkpf-bldat,
        rate  type tcurr-ukurs,
      end of ty_rates.
    data: ls_rates type ty_rates.

    call transformation zz_nbu_er
      source xml lv_data
      result rates = ls_rates.

    write: ls_rates-rate.
    write: ls_rates-date.

  endmethod.

  method build_request_uri.

    concatenate '?valcode=' ms_sel_opts-waers '&date=' ms_sel_opts-date into rv_uri.

  endmethod.

endclass.
