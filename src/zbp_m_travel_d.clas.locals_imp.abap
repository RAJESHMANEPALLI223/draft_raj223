CLASS lhc_ZM_TRAVEL_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zm_travel_d RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zm_travel_d RESULT result.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE zm_travel_d.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE zm_travel_d.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~accepttravel RESULT result.

    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~deductdiscount RESULT result.

    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~recalctotalprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~rejecttravel RESULT result.
    METHODS calctotprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zm_travel_d~calctotprice.

    METHODS setstatusopen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zm_travel_d~setstatusopen.

    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR zm_travel_d~settravelid.
    METHODS validatecust FOR VALIDATE ON SAVE
      IMPORTING keys FOR zm_travel_d~validatecust.
    METHODS activate FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~activate.

    METHODS discard FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~discard.

    METHODS edit FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~edit.

    METHODS resume FOR MODIFY
      IMPORTING keys FOR ACTION zm_travel_d~resume.

ENDCLASS.

CLASS lhc_ZM_TRAVEL_D IMPLEMENTATION.

  METHOD get_instance_authorizations.

    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( AgencyID ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels)  FAILED failed.
    CHECK lt_travels IS NOT INITIAL.

    SELECT FROM /dmo/a_travel_d AS a
       INNER JOIN /dmo/agency AS b
       ON a~agency_id = b~agency_id
       FIELDS a~travel_uuid, a~agency_id, b~country_code
       FOR ALL ENTRIES IN  @lt_travels
       WHERE a~travel_uuid = @lt_travels-TravelUUID
       INTO TABLE @DATA(lt_age_ctry).

    LOOP AT lt_travels INTO DATA(ls_travel).

      READ TABLE lt_age_ctry ASSIGNING FIELD-SYMBOL(<ls_age_ctry>) WITH KEY travel_uuid = ls_travel-TravelUUID.

      IF sy-subrc IS INITIAL.
        IF requested_authorizations-%update = if_abap_behv=>mk-on.

          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
                   ID '/DMO/CNTRY' FIELD <ls_age_ctry>-country_code
                   ID 'ACTVT' FIELD '02'.



*       APPEND VALUE #(  TravelUUID = ls_travel-TravelUUID
*                              %update  = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                    ELSE if_abap_behv=>auth-unauthorized )
*              )  TO result.
          DATA(lv_update) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                         ELSE if_abap_behv=>auth-unauthorized ).
*
          APPEND VALUE #( %tky = ls_travel-%tky
                            %msg = NEW /dmo/cm_flight_messages(
                                                     textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                     agency_id = ls_travel-AgencyID
                                                     severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) TO reported-zm_travel_d.

        ENDIF.

        IF requested_authorizations-%delete = if_abap_behv=>mk-on.

          AUTHORITY-CHECK OBJECT '/DMO/TRVL'
                  ID '/DMO/CNTRY' FIELD <ls_age_ctry>-country_code
                  ID 'ACTVT' FIELD '06'.




          DATA(lv_delete) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
                                   ELSE if_abap_behv=>auth-unauthorized ).
*
          APPEND VALUE #( %tky = ls_travel-%tky
                            %msg = NEW /dmo/cm_flight_messages(
                                                     textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                     agency_id = ls_travel-AgencyID
                                                     severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) TO reported-zm_travel_d.


        ENDIF.

      ENDIF.

      APPEND VALUE #(  TravelUUID = ls_travel-TravelUUID
                            %update  = lv_update
                            %delete  = lv_delete
            )  TO result.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

**  if requested_authorizations-%create = if_abap_behv=>mk-on.
**
**   AUTHORITY-CHECK OBJECT '/DMO/TRVL'
**         ID '/DMO/CNTRY' DUMMY
**         ID 'ACTVT' FIELD '01'.
**
**         result-%create = COND #( when sy-subrc = 0 then if_abap_behv=>auth-allowed
**                                  elSE if_abap_behv=>auth-unauthorized ).
**
**  enDIF.
**
**   if requested_authorizations-%update = if_abap_behv=>mk-on.
**
** AUTHORITY-CHECK OBJECT '/DMO/TRVL'
**         ID '/DMO/CNTRY' DUMMY
**         ID 'ACTVT' FIELD '02'.
**
**         result-%update = COND #( when sy-subrc = 0 then if_abap_behv=>auth-allowed
**                                  elSE if_abap_behv=>auth-unauthorized ).
**
**  enDIF.
**
**   if requested_authorizations-%delete = if_abap_behv=>mk-on.
**
** AUTHORITY-CHECK OBJECT '/DMO/TRVL'
**         ID '/DMO/CNTRY' DUMMY
**         ID 'ACTVT' FIELD '03'.
**
**         result-%delete = COND #( when sy-subrc = 0 then if_abap_behv=>auth-allowed
**                                  elSE if_abap_behv=>auth-unauthorized ).
**
**  enDIF.
  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.

    DATA:  lt_agency TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    lt_agency = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING agency_id = AgencyID EXCEPT * )  .

    CHECK lt_agency IS NOT INITIAL.

    SELECT
     FROM /dmo/agency
     FIELDS agency_id,country_code
     FOR ALL ENTRIES IN @lt_agency
     WHERE agency_id = @lt_agency-agency_id
     INTO TABLE @DATA(lt_ag_ct).
    IF sy-subrc IS INITIAL.

      LOOP AT entities INTO DATA(ls_entity).
        READ TABLE lt_ag_ct ASSIGNING FIELD-SYMBOL(<ls_age_ctry>) WITH KEY agency_id = ls_entity-AgencyID.
        AUTHORITY-CHECK OBJECT '/DMO/TRVL'
               ID '/DMO/CNTRY' FIELD <ls_age_ctry>-country_code
              ID 'ACTVT' FIELD '02'.

        IF sy-subrc IS NOT INITIAL.
          failed-zm_travel_d = VALUE #( ( %tky = ls_entity-%tky ) ).
          APPEND VALUE #( %tky = ls_entity-%tky
                            %msg = NEW /dmo/cm_flight_messages(
                                                     textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                     agency_id = ls_entity-AgencyID
                                                     severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) TO reported-zm_travel_d.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'A' ) ).

    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).
    result = VALUE #(  FOR travel IN lt_travel ( %tky = travel-%tky
                                                 %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.
    DATA lv_disc TYPE decfloat16.
    DATA  lt_travel_new TYPE TABLE FOR UPDATE zm_travel_d.

    DATA(lt_keys) = keys.

    LOOP AT lt_keys ASSIGNING FIELD-SYMBOL(<ls_keys>) WHERE %param-discount IS INITIAL
                                                      OR %param-discount GT 100 OR %param-discount LE 0.
      failed-zm_travel_d = VALUE #( ( %tky =  <ls_keys>-%tky ) ).

      APPEND VALUE #( %tky = <ls_keys>-%tky ) TO failed-zm_travel_d.

****  reported-zm_travel_d = VALUE #( ( %tky = <ls_keys>-%tky
****                                    %msg = neW /dmo/cm_flight_messages(
****    textid                = /dmo/cm_flight_messages=>discount_invalid
****
****    severity              = if_abap_behv_message=>severity-error
****    uname                 =
****  ) ) ).

      APPEND VALUE #( %tky = <ls_keys>-%tky
                                        %msg = NEW /dmo/cm_flight_messages(
        textid                = /dmo/cm_flight_messages=>discount_invalid
        severity              = if_abap_behv_message=>severity-error
                           )
                           %element-bookingfee = if_abap_behv=>mk-on
                           %action-deductdiscount =  if_abap_behv=>mk-on ) TO reported-zm_travel_d.

      DELETE lt_keys.
    ENDLOOP.

    CHECK lt_keys IS NOT INITIAL.
    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( BookingFee )
    WITH CORRESPONDING #( lt_keys ) RESULT DATA(lt_travel).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*  DATA LV_DISC TYPE DECFLOAT16.
      DATA(lv_discount) = lt_keys[ KEY id %tky = <ls_travel>-%tky  ]-%param-discount .

      lv_disc = lv_discount / 100 .

      DATA(lv_disc_book_fee) = <ls_travel>-BookingFee - (  <ls_travel>-BookingFee * lv_disc ).

*  lt_travel_new = valUE #( ( %tky = <ls_travel>-%tky
*                              BookingFee = lv_disc_book_fee ) ).

      APPEND VALUE #( %tky = <ls_travel>-%tky
                                    BookingFee = lv_disc_book_fee  ) TO lt_travel_new.

    ENDLOOP.

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
   ENTITY zm_travel_d UPDATE FIELDS ( BookingFee )
   WITH lt_travel_new.


    READ ENTITIES OF zm_travel_d IN LOCAL MODE
       ENTITY zm_travel_d ALL FIELDS WITH
        CORRESPONDING #( lt_keys ) RESULT DATA(lt_modified_travel).

    result = VALUE #( FOR ls_mo_travel IN lt_modified_travel ( %tky = ls_mo_travel-%tky
                                                               %param = ls_mo_travel ) ).

  ENDMETHOD.

  METHOD recalctotalprice.
    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: lt_amt_per_ccode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_travels).
    DELETE lt_travels WHERE CurrencyCode IS INITIAL.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_amt_per_ccode = VALUE #(  ( amount = <ls_travel>-BookingFee
                                      currency_code = <ls_travel>-CurrencyCode ) ).


      """"""""""""""READ THE ASSOCIATION ENTITY

      READ ENTITIES OF zm_travel_d IN LOCAL MODE
      ENTITY zm_travel_d BY \_Booking FIELDS ( FlightPrice CurrencyCode )
      WITH   VALUE #( (   %tky = <ls_travel>-%tky ) )
      RESULT DATA(lt_booking).

      LOOP AT lt_booking ASSIGNING FIELD-SYMBOL(<ls_booking>) WHERE CurrencyCode IS NOT INITIAL.

        COLLECT VALUE ty_amount_per_currencycode( amount        = <ls_booking>-FlightPrice
                                                    currency_code = <ls_booking>-CurrencyCode ) INTO lt_amt_per_ccode.

      ENDLOOP.


      """""""""SUPLIMENT

      " Read all associated booking supplements and add them to the total price.
      READ ENTITIES OF ZM_Travel_D IN LOCAL MODE
        ENTITY zM_booking_d BY \_BookingSupplement
          FIELDS ( BookSupplPrice CurrencyCode )
        WITH VALUE #( FOR rba_booking IN lt_booking ( %tky = rba_booking-%tky ) )
        RESULT DATA(lt_bookingsupplements).

      LOOP AT lt_bookingsupplements INTO DATA(bookingsupplement) WHERE CurrencyCode IS NOT INITIAL.
        COLLECT VALUE ty_amount_per_currencycode( amount        = bookingsupplement-BookSupplPrice
                                                  currency_code = bookingsupplement-CurrencyCode ) INTO lt_amt_per_ccode.
      ENDLOOP.



      CLEAR <LS_travel>-TotalPrice.

      LOOP AT lt_amt_per_ccode INTO DATA(single_amount_per_currencycode).
        " If needed do a Currency Conversion
        IF single_amount_per_currencycode-currency_code = <LS_travel>-CurrencyCode.
          <LS_travel>-TotalPrice += single_amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
             EXPORTING
               iv_amount                   =  single_amount_per_currencycode-amount
               iv_currency_code_source     =  single_amount_per_currencycode-currency_code
               iv_currency_code_target     =  <LS_travel>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <LS_travel>-TotalPrice += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF zM_Travel_D IN LOCAL MODE
      ENTITY zM_travel_d
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( lt_travels ).


  ENDMETHOD.

  METHOD rejectTravel.


    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'X' ) ).
    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #(  FOR travel IN lt_travel ( %tky = travel-%tky
                                                 %param = travel ) ).
  ENDMETHOD.

  METHOD calctotprice.


    MODIFY ENTITIES OF  zM_travel_d IN LOCAL MODE
     ENTITY zM_travel_d
     EXECUTE recalctotalprice
     FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD setstatusopen.

    READ ENTITIES OF   zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( OverallStatus )
    WITH  CORRESPONDING #( keys ) RESULT DATA(lt_travel).
    DELETE lt_travel WHERE TravelID IS NOT INITIAL.
    DELETE lt_travel WHERE OverallStatus IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO lv_index ( %tky = ls_travel-%tky OverallStatus = 'O' ) ).



  ENDMETHOD.

  METHOD settravelid.

    READ ENTITIES OF   zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( TravelID )
    WITH  CORRESPONDING #( keys ) RESULT DATA(lt_travel).
    DELETE lt_travel WHERE TravelID IS NOT INITIAL.

    CHECK lt_travel IS NOT INITIAL.

    SELECT FROM /dmo/a_travel_d FIELDS MAX( travel_id ) INTO @DATA(lv_max_travelid).

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d UPDATE FIELDS ( TravelID )
    WITH VALUE #( FOR ls_travel IN lt_travel INDEX INTO lv_index ( %tky = ls_travel-%tky TravelID = lv_max_travelid + lv_index ) ).
  ENDMETHOD.

  METHOD validatecust.


    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d FIELDS ( CustomerID ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_travels).


    DATA lt_customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customers = CORRESPONDING #( lt_travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).

    DELETE lt_customers WHERE customer_id IS INITIAL.

    IF lt_customers IS NOT INITIAL.

      SELECT FROM /dmo/customer
         FIELDS customer_id
         FOR ALL ENTRIES IN @lt_customers
         WHERE customer_id = @lt_customers-customer_id
         INTO TABLE @DATA(lt_valid_customers).

    ENDIF.

    LOOP AT lt_travels INTO DATA(travels).


      APPEND VALUE #( %tky        = travels-%tky
                            %state_area = 'VALIDATE_CUSTOMER' )
                   TO reported-zm_travel_d.

      IF travels-CustomerID IS INITIAL.

        APPEND VALUE #( %tky = travels-%tky ) TO failed-zm_travel_d.

        APPEND VALUE #( %tky                = travels-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg                = NEW /dmo/cm_flight_messages(
                                                      textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                      severity = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on )
               TO reported-zm_travel_d.



      ELSEIF travels-CustomerID IS  NOT INITIAL AND NOT line_exists( lt_valid_customers[ customer_id = travels-CustomerID ] ).


        APPEND VALUE #( %tky = travels-%tky ) TO failed-zm_travel_d.

        APPEND VALUE #( %tky                = travels-%tky
                        %state_area         = 'VALIDATE_CUSTOMER'
                        %msg                = NEW /dmo/cm_flight_messages(
                                                      customer_id = travels-customerid
                                                      textid      = /dmo/cm_flight_messages=>customer_unkown
                                                      severity    = if_abap_behv_message=>severity-error )
                        %element-CustomerID = if_abap_behv=>mk-on )
               TO reported-zm_travel_d.

      ENDIF.


    ENDLOOP.
  ENDMETHOD.

  METHOD Activate.
  ENDMETHOD.

  METHOD Discard.
  ENDMETHOD.

  METHOD Edit.
  ENDMETHOD.

  METHOD Resume.
  ENDMETHOD.

ENDCLASS.
