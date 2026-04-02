CLASS lhc_ZM_BOOKING_D DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zm_booking_d~calculatetotalprice.

    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR zm_booking_d~setbookingdate.

    METHODS setbookingno FOR DETERMINE ON SAVE
      IMPORTING keys FOR zm_booking_d~setbookingno.
    METHODS validcust FOR VALIDATE ON SAVE
      IMPORTING keys FOR zm_booking_d~validcust.

ENDCLASS.

CLASS lhc_ZM_BOOKING_D IMPLEMENTATION.

  METHOD calculatetotalprice.
    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY  zm_booking_d BY  \_Travel
    FIELDS ( TravelUUID ) WITH CORRESPONDING #( keys ) RESULT DATA(travels).

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_travel_d EXECUTE recalctotalprice
    FROM CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD setbookingdate.

    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_booking_d FIELDS ( BookingDate )
    WITH CORRESPONDING #( keys ) RESULT DATA(bookings).

    DELETE bookings WHERE BookingDate IS NOT INITIAL.

    IF bookings IS INITIAL.
      RETURN.

    ENDIF.

    LOOP AT bookings ASSIGNING FIELD-SYMBOL(<booking>).
      <booking>-BookingDate = cl_abap_context_info=>get_system_date(  ).
    ENDLOOP.

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_booking_d UPDATE FIELDS ( BookingDate  )
    WITH CORRESPONDING #( bookings ).
  ENDMETHOD.

  METHOD setbookingno.
    DATA max_bookingid   TYPE /dmo/booking_id.
    DATA bookings_update TYPE TABLE FOR UPDATE Zm_Travel_D\\zm_booking_d.
    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_booking_d BY \_Travel FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys ) RESULT DATA(lt_travels).

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<ls_travel>).

      READ ENTITIES OF zm_travel_d IN LOCAL MODE
      ENTITY zm_travel_d BY \_Booking FIELDS ( BookingID )
      WITH VALUE #( ( %tky = <ls_travel>-%tky ) ) RESULT DATA(bookings).


      max_bookingid = '0000'.
      LOOP AT bookings INTO DATA(booking).
        IF  booking-BookingID > max_bookingid.
          max_bookingid = booking-BookingID.
        ENDIF.
      ENDLOOP.



      LOOP AT bookings INTO booking WHERE BookingID IS INITIAL.

        max_bookingid += 1.
        APPEND VALUE #(  %tky = booking-%tky
                                     BookingID = max_bookingid )  TO bookings_update.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_booking_d UPDATE FIELDS ( BookingID )
    WITH bookings_update.

  ENDMETHOD.

  METHOD validcust.


  ENDMETHOD.

ENDCLASS.
