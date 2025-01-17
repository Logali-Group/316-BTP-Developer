@EndUserText.label: 'Travel - Consumption'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity z_c_travel_316
  provider contract transactional_query
  as projection on z_r_travel_316
{
  key     TravelUUID,

          @Search.defaultSearchElement: true
          @Search.fuzzinessThreshold: 0.8
          TravelID,

          @Search.defaultSearchElement: true
          @ObjectModel.text.element: [ 'AgencyName' ]
          @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Agency_StdVH',
                                                         element: 'AgencyID'},
                                               useForValidation: true 
                                               }]
          AgencyID,
          _Agency.Name              as AgencyName,

          @Search.defaultSearchElement: true
          @ObjectModel.text.element: [ 'CustomerName' ]
          @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH',
                                                         element: 'CustomerID'},
                                               useForValidation: true 
                                               }]
          CustomerID,
          _Customer.LastName        as CustomerName,

          BeginDate,
          EndDate,

          BookingFee,

          TotalPrice,
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @EndUserText.label: 'VAT Included'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_316'
  virtual PriceWithVAT : /dmo/total_price,

          @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CurrencyStdVH',
                                                         element: 'Currency' },
                                               useForValidation: true }]
          CurrencyCode,

          Description,


          @ObjectModel.text.element: [ 'OverallStatusText' ]
          @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH',
                                                         element: 'OverallStatus'} }]
          OverallStatus,
          _OverallStatus._Text.Text as OverallStatusText : localized,

          LocalLastChangedAt,

          /* Associations */
          _Agency,
          _Booking : redirected to composition child z_c_booking_316,
          _Currency,
          _Customer,
          _OverallStatus
}
