//old cds
@AbapCatalog.sqlViewName: 'Z_SQL_SALES_ORD_C'
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

DEFINE VIEW Z_I_SalesOrder_C
  AS SELECT FROM snwd_so AS Header
  association [0..1] to snwd_bpa AS _Customer ON $projection.BuyerGuid = _Customer.node_key
{
  key Header.so_id                               AS SalesOrderID,
      @EndUserText.label: 'Sales Order ID'
      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      @UI.selectionField: [{ position: 10 }]
      @Search.defaultSearchElement: true

  Header.buyer_guid                        AS BuyerGuid,
      @UI.hidden: true

  _Customer.company_name                   AS CustomerName,
      @EndUserText.label: 'Customer Name'
      @Semantics.text: true
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      @UI.selectionField: [{ position: 20 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7

  Header.created_at                        AS CreationDateTime,
      @EndUserText.label: 'Created At'
      @Semantics.systemDateTime.createdAt: true
      @UI.lineItem: [{ position: 30 }]

  Header.created_by                        AS CreatedByUser,
      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      @UI.lineItem: [{ position: 40, importance: #LOW }]
      @UI.identification: [{ position: 40, importance: #LOW }]

  Header.currency_code                     AS CurrencyCode,
      @EndUserText.label: 'Currency'
      @Semantics.currencyCode: true
      @UI.hidden: true

  Header.gross_amount                      AS GrossAmount,
      @EndUserText.label: 'Gross Amount'
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      @DefaultAggregation: #SUM
      @AnalyticsDetails.query.axis: #COLUMNS

  Header.lifecycle_status                  AS LifecycleStatus,
      @EndUserText.label: 'Status Code'
      @UI.hidden: true
      @UI.identification: [{ position: 60 }]

  CASE Header.lifecycle_status
       WHEN 'N' THEN 'New'
       WHEN 'P' THEN 'In Process'
       WHEN 'C' THEN 'Closed'
       WHEN 'X' THEN 'Cancelled'
       ELSE 'Unknown'
   END                                     AS LifecycleStatusText,
      @EndUserText.label: 'Order Status'
      @Semantics.text: true
      @UI.lineItem: [{ position: 60, importance: #HIGH }]
      @Consumption.filter: { selectionType: #MULTIPLE, multipleSelections: true }

  Header.so_id                             AS SalesOrderForVH,
      @EndUserText.label: 'SO for Value Help'
      @UI.hidden: true
      @Consumption.valueHelpDefinition: [{
          entity: {
              name: 'I_SalesOrderBasic',
              element: 'SalesOrder'
            },
            label: 'Select Sales Order'
         }]
}
