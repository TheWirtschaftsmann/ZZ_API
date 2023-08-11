*&---------------------------------------------------------------------*
*& App to read the exchange rates from National Bank of Ukraine
*& Developed by: Bohdan Petrushchak, 2023
*&---------------------------------------------------------------------*
report zz_basic_api.

include zz_basic_api_types.
include zz_basic_api_main.
include zz_basic_api_sels.

start-of-selection.

  data ls_sel_opts type gty_sel_opts.
  ls_sel_opts-waers = p_waers.
  ls_sel_opts-date  = p_date.

  lcl_app=>create( )->run( ls_sel_opts ).
