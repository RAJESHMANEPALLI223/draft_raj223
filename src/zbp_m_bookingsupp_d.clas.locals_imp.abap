CLASS lhc_zm_bookingsupplement_d DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calctotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zm_bookingsupplement_d~calctotalprice.

    METHODS setbookingsuppno FOR DETERMINE ON SAVE
      IMPORTING keys FOR zm_bookingsupplement_d~setbookingsuppno.

ENDCLASS.

CLASS lhc_zm_bookingsupplement_d IMPLEMENTATION.

  METHOD calctotalprice.


    """""""""""""" read the data
    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_bookingsupplement_d BY \_Travel
    FIELDS ( TravelUUID )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
   ENTITY zm_travel_d EXECUTE recalctotalprice FROM CORRESPONDING #( travels ).
  ENDMETHOD.

  METHOD setbookingsuppno.
    DATA max_bookingsupplementid TYPE /dmo/booking_supplement_id.
    DATA bookingsupplements_update TYPE TABLE FOR UPDATE ZM_Travel_D\\ZM_BookingSupplement_D.
    "Read all bookings for the requested booking supplements

    READ ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_bookingsupplement_d BY \_Booking
    FIELDS ( BookingUUID ) WITH CORRESPONDING #( keys ) RESULT DATA(bookings).


    LOOP AT bookings INTO DATA(ls_bookings).

      READ ENTITIES OF zm_travel_d IN LOCAL MODE
      ENTITY zm_booking_d BY \_BookingSupplement
      FIELDS ( BookingSupplementID ) WITH VALUE #( ( %tky = ls_bookings-%tky ) )
      RESULT DATA(bookingsupplement).
      max_bookingsupplementid = '00'.
      LOOP AT bookingsupplement INTO DATA(bookingsupp).

        IF  bookingsupp-BookingSupplementID > max_bookingsupplementid .
          max_bookingsupplementid = bookingsupp-BookingSupplementID.
        ENDIF.
      ENDLOOP.

      LOOP AT bookingsupplement INTO bookingsupp WHERE BookingSupplementID IS INITIAL.

        max_bookingsupplementid += 1.

        APPEND VALUE #( %tky = bookingsupp-%tky
                        bookingsupplementid = max_bookingsupplementid
                         ) TO bookingsupplements_update.

      ENDLOOP.

    ENDLOOP.



    MODIFY ENTITIES OF zm_travel_d IN LOCAL MODE
    ENTITY zm_bookingsupplement_d UPDATE FIELDS ( BookingSupplementID ) WITH bookingsupplements_update.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
