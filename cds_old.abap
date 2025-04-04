//old cds
@AbapCatalog.sqlViewName:'ZCDS_EXP_1_OSQL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: false
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Sales Order Consumption View'
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION
@Analytics.dataCategory: #FACT
@ObjectModel.representativeKey: 'SalesOrderID'
@UI.headerInfo: {
  typeName: 'Sales Order',
  typeNamePlural: 'Sales Orders',
  title: {
    type: #STANDARD,
    value: 'SalesOrderID'
  },
  description: {
    value: 'CustomerName'
  }
}
@Search.searchable: true

define view zcdc_exp_1_old
  as select from snwd_so as Header
  association [0..1] to snwd_bpa as _Customer on $projection.BuyerGuid = _Customer.node_key
{

      @EndUserText.label: 'Sales Order ID'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @Search.defaultSearchElement: true
  key Header.so_id                               as SalesOrderID,

     @UI.hidden: true
  Header.buyer_guid                        as BuyerGuid,
 
      @EndUserText.label: 'Customer Name'
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
  _Customer.company_name                   as CustomerName,

      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      @UI.lineItem: [{ position: 30 }]
  Header.created_at                        as CreationDateTime,

      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      @UI.lineItem: [{ position: 40, importance: #LOW }]
      @UI.identification: [{ position: 40, importance: #LOW }]
  Header.created_by                        as CreatedByUser,

      @EndUserText.label: 'Currency'
      @Semantics.currencyCode: true
      @UI.hidden: true
  Header.currency_code                     as CurrencyCode,

      @EndUserText.label: 'Gross Amount'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      @DefaultAggregation: #SUM
      @AnalyticsDetails.query.axis: #COLUMNS      
  Header.gross_amount                      as GrossAmount,

      @EndUserText.label: 'Status Code'
      @UI.hidden: true
      @UI.identification: [{ position: 60 }]
  Header.lifecycle_status                  as LifecycleStatus,

      @EndUserText.label: 'Order Status'
      @Semantics.text: true
      @UI.lineItem: [{ position: 60, importance: #HIGH }]
      @Consumption.filter: { selectionType: #RANGE, multipleSelections: true }
  case Header.lifecycle_status
       when 'N' then 'New'
       when 'P' then 'In Process'
       when 'C' then 'Closed'
       when 'X' then 'Cancelled'
       else 'Unknown'
   end                                     as LifecycleStatusText,

      @EndUserText.label: 'SO for Value Help'
      @UI.hidden: true
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'I_SalesOrderBasic',
              element: 'SalesOrder'
            },
            label: 'Select Sales Order'
         }]
  Header.so_id                             as SalesOrderForVH,

_Customer
}

