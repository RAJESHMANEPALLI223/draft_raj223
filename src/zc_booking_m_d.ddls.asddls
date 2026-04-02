@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOOKING CONSUMTION TABLE'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity ZC_BOOKING_M_D
  as projection on ZM_BOOKING_D
{
  key BookingUUID,
      TravelUUID,
      @Search.defaultSearchElement: true
      BookingID,
      BookingDate,
      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer_StdVH', element: 'CustomerID' } }]
      CustomerID,
      _Customer.LastName        as CustomerName,
      @Consumption.valueHelpDefinition: [{ entity: {name: '/DMO/I_Flight', element: 'AirlineID' },
                                           additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate',usage: #RESULT },
                                                                { localElement: 'AirlineID',    element: 'AirlineID',usage: #RESULT },
                                                                { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT},
                                                                { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]

      AirlineID,
      _Carrier.Name             as CarrierName,
      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                           additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                                { localElement: 'AirlineID',    element: 'AirlineID'},
                                                { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT},
                                                { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      ConnectionID,
      //  @Consumption.valueHelpDefinition: [
      //          { entity: {name: '/DMO/I_Flight_StdVH', element: 'FlightDate'},
      //            additionalBinding: [ { localElement: 'AirlineID',    element: 'AirlineID',    usage: #FILTER_AND_RESULT},
      //                                 { localElement: 'ConnectionID', element: 'ConnectionID', usage: #FILTER_AND_RESULT},
      //                                 { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT},
      //                                 { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ],
      //            useForValidation: true }
      //        ]
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'

      @Consumption.valueHelpDefinition: [ {entity: {name: '/DMO/I_Flight', element: 'ConnectionID'},
                  additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate'},
                                       { localElement: 'AirlineID',    element: 'AirlineID'},
                                       { localElement: 'FlightPrice',  element: 'Price', usage: #RESULT },
                                       { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ] } ]
      FlightPrice,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      @ObjectModel.text.element: ['BookingStatusText']
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Booking_Status_VH', element: 'BookingStatus' }}]
      BookingStatus,
      _BookingStatus._Text.Text as BookingStatusText : localized,
      LocalLastChangedAt,
      /* Associations */
      _BookingStatus,
      _BookingSupplement : redirected to composition child ZC_BOOKINGSUPPLEMENT_M_D,
      _Carrier,
      _Connection,
      _Customer,
      _Travel            : redirected to parent ZC_TRAVEL_M_D
}
