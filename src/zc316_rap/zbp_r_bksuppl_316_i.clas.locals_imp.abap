class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for BookingSupplement result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for BookingSupplement result result.

    methods calculateTotalPrice for determine on modify
      importing keys for BookingSupplement~calculateTotalPrice.

    methods setBookSupplNumber for determine on save
      importing keys for BookingSupplement~setBookSupplNumber.

    methods validateCurrencyCode for validate on save
      importing keys for BookingSupplement~validateCurrencyCode.

    methods validatePrice for validate on save
      importing keys for BookingSupplement~validatePrice.

    methods validateSupplement for validate on save
      importing keys for BookingSupplement~validateSupplement.

endclass.

class lhc_BookingSupplement implementation.

  method get_instance_authorizations.
  endmethod.

  method get_global_authorizations.
  endmethod.

  method calculateTotalPrice.

    " Parent UUIDs
    read entities of z_r_travel_316 in local mode
         entity BookingSupplement by \_Travel
         fields ( TravelUUID  )
         with corresponding #(  keys  )
         result data(travels).

    " Trigger Travel Internal Action
    modify entities of z_r_travel_316 in local mode
      entity Travel
        execute reCalcTotalPrice
          from corresponding  #( travels ).

  endmethod.

  method setBookSupplNumber.

    data max_bookingsupplementid type /dmo/booking_supplement_id.
    data bookingsupplements_update type table for update z_r_travel_316\\BookingSupplement.

    read entities of z_r_travel_316 in local mode
      entity BookingSupplement by \_Booking
        fields (  BookingUUID  )
        with corresponding #( keys )
      result data(bookings).

    loop at bookings into data(ls_booking).
      read entities of z_r_travel_316 in local mode
        entity Booking by \_BookingSupplement
          fields ( BookingSupplementID )
          with value #( ( %tky = ls_booking-%tky ) )
        result data(bookingsupplements).

      max_bookingsupplementid = '00'.
      loop at bookingsupplements into data(bookingsupplement).
        if bookingsupplement-BookingSupplementID > max_bookingsupplementid.
          max_bookingsupplementid = bookingsupplement-BookingSupplementID.
        endif.
      endloop.

      loop at bookingsupplements into bookingsupplement where BookingSupplementID is initial.
        max_bookingsupplementid += 1.
        append value #( %tky                = bookingsupplement-%tky
                        bookingsupplementid = max_bookingsupplementid
                      ) to bookingsupplements_update.

      endloop.
    endloop.

    modify entities of z_r_travel_316 in local mode
      entity BookingSupplement
        update fields ( BookingSupplementID ) with bookingsupplements_update.


  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validatePrice.
  endmethod.

  method validateSupplement.

    read entities of z_r_travel_316 in local mode
         entity BookingSupplement
         fields ( SupplementID )
         with corresponding #(  keys )
         result data(bookingsupplements)
         failed data(read_failed).

    failed = corresponding #( deep read_failed ).

    read entities of z_r_travel_316 in local mode
         entity BookingSupplement by \_Booking
         from corresponding #( bookingsupplements )
         link data(booksuppl_booking_links).

    read entities of z_r_travel_316 in local mode
         entity BookingSupplement by \_Travel
         from corresponding #( bookingsupplements )
         link data(booksuppl_travel_links).

    data supplements type sorted table of /dmo/supplement with unique key supplement_id.

    supplements = corresponding #( bookingsupplements discarding duplicates mapping supplement_id = SupplementID except * ).
    delete supplements where supplement_id is initial.

    if supplements is not initial.
      select from /dmo/supplement
             fields supplement_id
             for all entries in @supplements
             where supplement_id = @supplements-supplement_id
             into table @data(valid_supplements).
    endif.

    loop at bookingsupplements assigning field-symbol(<bookingsupplement>).

      append value #(  %tky        = <bookingsupplement>-%tky
                       %state_area = 'VALIDATE_SUPPLEMENT'
                    ) to reported-bookingsupplement.

      if <bookingsupplement>-SupplementID is  initial.
        append value #( %tky = <bookingsupplement>-%tky ) to failed-bookingsupplement.

        append value #( %tky                  = <bookingsupplement>-%tky
                        %state_area           = 'VALIDATE_SUPPLEMENT'
                        %msg                  = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>enter_supplement_id
                                                                severity = if_abap_behv_message=>severity-error )
                        %path                 = value #( booking-%tky = booksuppl_booking_links[ key id  source-%tky = <bookingsupplement>-%tky ]-target-%tky
                                                         travel-%tky  = booksuppl_travel_links[  key id  source-%tky = <bookingsupplement>-%tky ]-target-%tky )
                        %element-SupplementID = if_abap_behv=>mk-on
                       ) to reported-bookingsupplement.


      elseif <bookingsupplement>-SupplementID is not initial and not line_exists( valid_supplements[ supplement_id = <bookingsupplement>-SupplementID ] ).
        append value #(  %tky = <bookingsupplement>-%tky ) to failed-bookingsupplement.

        append value #( %tky                  = <bookingsupplement>-%tky
                        %state_area           = 'VALIDATE_SUPPLEMENT'
                        %msg                  = new /dmo/cm_flight_messages(
                                                                textid = /dmo/cm_flight_messages=>supplement_unknown
                                                                severity = if_abap_behv_message=>severity-error )
                        %path                 = value #( booking-%tky = booksuppl_booking_links[ key id  source-%tky = <bookingsupplement>-%tky ]-target-%tky
                                                          travel-%tky = booksuppl_travel_links[  key id  source-%tky = <bookingsupplement>-%tky ]-target-%tky )
                        %element-SupplementID = if_abap_behv=>mk-on
                       ) to reported-bookingsupplement.
      endif.

    endloop.

  endmethod.

endclass.
