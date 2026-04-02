@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CONSUMTION VIEW FOR THE DRAFT'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZC_BOOKINGSUPPLEMENT_M_D
  as projection on ZM_BOOKINGSUPPLEMENT_D
{
  key BookSupplUUID,
      TravelUUID,
      BookingUUID,
      @Search.defaultSearchElement: true
      BookingSupplementID,
      @ObjectModel.text.element: ['SupplementDescription']
      @Consumption.valueHelpDefinition: [
          {  entity: {name: '/DMO/I_Supplement_StdVH', element: 'SupplementID' },
             additionalBinding: [ { localElement: 'BookSupplPrice',  element: 'Price',        usage: #RESULT },
                                  { localElement: 'CurrencyCode',    element: 'CurrencyCode', usage: #RESULT }]
              }
        ]
      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookSupplPrice,

      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZC_BOOKING_M_D,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZC_TRAVEL_M_D
}
