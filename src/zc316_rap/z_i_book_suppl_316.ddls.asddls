@EndUserText.label: 'Booking Supplements - Interface'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity z_i_book_suppl_316
  as projection on z_r_book_suppl_316
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,
      CurrencyCode,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent z_i_booking_316,
      _Product,
      _SupplementText,
      _Travel  : redirected to z_i_travel_316
}
