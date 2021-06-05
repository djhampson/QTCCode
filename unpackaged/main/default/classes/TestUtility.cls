@isTest
public  class TestUtility {
    
    public static final String STANDARD_PRICEBOOK_ID = Test.getStandardPricebookId();
    public static final String OPPORTUNITY_LICENSEFEE_REC_TYPE = 'Licence Fee';
    public static final String OPPORTUNITY_QUALIFY_STAGENAME = 'Qualify';
    public static final String CASE_CONSULTING_RECORD_TYPE  = 'I require Consulting services';
    public static final String CASE_MEDIUM_PRIORITY = 'Medium';
    
    //create Finance Book
    public static blng__FinanceBook__c createFinanceBook(String finBookName,String finDuration, String finPeriodType){
        return new blng__FinanceBook__c(blng__Active__c=true,Name = finBookName,blng__FinancePeriodDuration__c = finDuration,blng__PeriodType__c = finPeriodType);
    }

    public static blng__LegalEntity__c createLegalEntity(){
        return new blng__LegalEntity__c(Name='Technology1',blng__Active__c=true,blng__State__c='NSW');

    }

    public static blng__RevenueDistributionMethod__c createRevenueDistributionMethod(){
        return new blng__RevenueDistributionMethod__c(blng__Active__c=true,blng__DistributionMethod__c='Daily',blng__Type__c='Other',blng__MonthlyRecognitionProration__c='Number of Days',blng__RevenueTransactionCreationProcess__c='Automatic',blng__RevenueScheduleTermStartDate__c='Other',blng__RevenueScheduleTermEndDate__c='Other');
    }

    public static blng__GLRule__c createGLRule(){
        return new blng__GLRule__c(Name='Revenue Recognition GL Rule',blng__Active__c=true);
    }

    
    
    public static blng__RevenueRecognitionTreatment__c createRevRecognitionTreatment(String ruleTreatmentName,Id ruleId, Id financialBookId,Id legalEntityId, Id distributionMethodId,Id glRuleId){
        return new blng__RevenueRecognitionTreatment__c(blng__ProcessingOrder__c =1,
        blng__Type__c = 'Percentage',
        blng__Percentage__c = 100.00,
        blng__RevenueRecognitionRule__c = ruleId,
        blng__RevenueFinanceBook__c = financialBookId,
        blng__Active__c = true,
        blng__RevenueScheduleCreationAction__c ='Other',
        blng__RevenueScheduleAmount__c = 'Transaction Amount',
        blng__RevenueAgreementAssociation__c = 'Not Applicable',
        blng__RevenueLegalEntity__c = legalEntityId,
        blng__RevenueDistributionMethod__c = distributionMethodId,
        blng__RevenueGLRule__c = glRuleId,
        Name= ruleTreatmentName
        );
    }

    // create Revenue Recognition Rule
    public static blng__RevenueRecognitionRule__c createRevRecRule( String ruleName, Boolean createSchedule,Id parentRuleId,Date finStartDate,Date finEndDate){
        blng__RevenueRecognitionRule__c ruleObj = new blng__RevenueRecognitionRule__c();
        ruleObj.Name = ruleName;
        ruleObj.blng__CreateRevenueSchedule__c = createSchedule ? 'Yes':'No';
        ruleObj.blng__Active__c = true;
        ruleObj.Parent_Revenue_Recognition_Rule__c = parentRuleId;
        ruleObj.Financial_Start_Date__c = finStartDate;
        ruleObj.Financial_End_Date__c = finEndDate;
        return ruleObj;

    }

    public static blng__BillingRule__c createBillingRule(){
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'No Invoice', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date  ', blng__GenerateInvoices__c = 'No');
        return billingRule;
    }

    public static blng__TaxRule__c createTaxRule(){
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        return taxRule;
    }

    public static Product2 initializeProduct( String name, String family, String heirarchy, String prodCode, Id revRecRuleId ,Id billingRuleId, Id taxRuleId) {
        Product2 productObj = new Product2();
        productObj.Name = name;
        productObj.CurrencyIsoCode = 'AUD';
        productObj.IsActive = true;
        productObj.Product_or_Module__c = heirarchy;
        productObj.ProductCode = prodCode;
        productObj.Family = family;
        productObj.For_Deal_Types__c = 'Subscription;Perpetual;Saas;Term';
        productObj.For_Regions__c = 'ACT;New South Wales;Northern Territory;Queensland;South Australia;Tasmania;Victoria;Western Australia;New Zealand North;New Zealand South';
        productObj.blng__RevenueRecognitionRule__c = revRecRuleId;
        productObj.blng__BillingRule__c = billingRuleId;
        productObj.blng__TaxRule__c = taxRuleId;
        productObj.SBQQ__BillingType__c = 'Advance';
        productObj.Category__c = heirarchy;
        productObj.Entitlement_Case_Type__c = 'ALL';
        productObj.Entitlement_Priority__c = 'ALL';
//        productObj.Fee_Type__c = 'License';
        productObj.SBQQ__ChargeType__c = 'Recurring';
        productObj.SBQQ__BillingFrequency__c = 'Annual';
        productObj.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        productObj.SBQQ__SubscriptionType__c = 'Renewable';
        return productObj;
    }

    public static PricebookEntry initializeProductPricebook(Id pbId, Id prodId )
    {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pbId;
        pbe.Product2Id = prodId;
        pbe.IsActive = true;
        pbe.UnitPrice = 2000.0;
        return pbe;
    }

    public static SBQQ__ProductOption__c getProdOption(Id masterprodId, Id childProdId, Integer prodNumber){
        SBQQ__ProductOption__c prodOptionVar = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c= masterprodId, 
            SBQQ__DiscountedByPackage__c=false, 
            SBQQ__Number__c=prodNumber, SBQQ__OptionalSKU__c= childProdId, 
            SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c= 1.00, 
            SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
            SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
            Option_NOT_within_Account_Region__c=false);
        return prodOptionVar;
    }



    // create test account
    public static Account createAccount(String accName) {
        Account accVar = new Account(Name=accName,CountryArea__c='Australia',Region__c='Queensland',Industry='Other',Vertical_Market__c='Education',T1_Industry__c='Corporate',Type='Customer');
        return accVar;
    }

    // create test opportunity
    public static Opportunity createOpportunity( Id accountId , Id recTypeId) {
        Opportunity oppVar = new Opportunity(Name='OpportunityTest',AccountId = accountId,CloseDate  = system.Today().addMonths(2),StageName = OPPORTUNITY_QUALIFY_STAGENAME ,Pricebook2Id = STANDARD_PRICEBOOK_ID,RecordTypeId = recTypeId);
        oppVar.Licence_Model__c = 'SaaS';
        return oppVar;
    }

    //create testquote for Opportunity
    public static SBQQ__Quote__c createQuote( Id opportunityId ,Date startDate, Date endDate ){
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c( SBQQ__Opportunity2__c = opportunityId,SBQQ__StartDate__c = startDate,SBQQ__EndDate__c = endDate ,End_Date__c = endDate,  SBQQ__PriceBook__c=STANDARD_PRICEBOOK_ID,SBQQ__PricebookId__c=STANDARD_PRICEBOOK_ID);
        testQuote.SBQQ__ExpirationDate__c = Date.today() + 30;
        testQuote.SBQQ__ProrationDayOfMonth__c =  '5';
        testQuote.SBQQ__Primary__c = true;
        return testQuote;

    }

    // create quote line
    public static SBQQ__QuoteLine__c createQuoteLines( Id quoteId,Id productId, Decimal listPrice, Decimal customerPrice , Id priceBookEntryId ){
        SBQQ__QuoteLine__c quoteLineItem = new SBQQ__QuoteLine__c();
        quoteLineItem.SBQQ__Quote__c = quoteId;
        quoteLineItem.SBQQ__Product__c = productId;
        quoteLineItem.SBQQ__ListPrice__c = listPrice;
        quoteLineItem.SBQQ__CustomerPrice__c = customerPrice;
        quoteLineItem.Fee_Type__c = 'Cloud';
        quoteLineItem.SBQQ__Quantity__c  = 1;
        quoteLineItem.SBQQ__DefaultSubscriptionTerm__c = 12;
        quoteLineItem.SBQQ__ChargeType__c = 'Recurring';
        quoteLineItem.SBQQ__BillingFrequency__c = 'Annual';
        quoteLineItem.SBQQ__BillingType__c = 'Advance';
        quoteLineItem.SBQQ__PricebookEntryId__c = priceBookEntryId;
        return quoteLineItem;
    }

    // create T1 Invoice
    public static T1_Invoice__c createT1Invoice(Id accountId){
        T1_Invoice__c t1i = new T1_Invoice__c();
        t1i.Account__c = accountId;
        t1i.CurrencyIsoCode = 'AUD';
        t1i.InvoiceDate__c = date.Today();
        t1i.InvoiceStatus__c = 'Draft';
        t1i.TaxStatus__c = 'Completed';
        return t1i;
    }

    
    public static blng__CreditNote__c createCreditNote(Id accountId){
        return new blng__CreditNote__c(blng__Account__c = accountId,Country_Area__c='Australia',blng__CreditNoteDate__c=Date.Today(),Deal_Type__c='Subscription',Opportunity_Type__c='Existing');
    }

    public static blng__CreditNoteLine__c createCreditNoteLine( Id creditNoteId ,Date startDate, Date endDate ,Id productId,Decimal amount){
        return new blng__CreditNoteLine__c(blng__StartDate__c = startDate,blng__EndDate__c = endDate,blng__CreditNote__c=creditNoteId,blng__CreditNoteLineDate__c=Date.today(),blng__Product__c = productId,blng__TotalAmount__c=amount,blng__Subtotal__c=amount);
    }
    // Generic Method to get Record TYpe Name by Object and Name
    public static Id getRecordTypeId( String objectName, String recordTypeName ) {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }

    // method to return query results for Quote and corresponding line items
    public static SBQQ__Quote__c getQuoteAndQuoteLineItems( Id quoteId ){
        return [ SELECT SBQQ__Account__c,SBQQ__Opportunity2__c,Opportunity_Model__c,SBQQ__Status__c,(SELECT SBQQ__Product__r.Name FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE ID = :quoteId ];
    }


    // method to query Revenue Schedule related to OrderProducts Id
    public static List<blng__RevenueSchedule__c> queryRevScheduleListByOrderItem( Id orderItemId ){
        return [SELECT blng__RevenueRecognitionRule__c,blng__TotalRevenueAmount__c,blng__RevenueStartDate__c,blng__RevenueEndDate__c FROM blng__RevenueSchedule__c WHERE blng__OrderProduct__c = :orderItemId ORDER BY blng__RevenueStartDate__c ASC];
    }

    public static List<ServiceContract> getServiceContractById( Set<Id> serviceContractIds ){
        return [ SELECT Name,AccountId,StartDate,EndDate,(SELECT SBQQSC__ProductName__c,SBQQSC__RequiredById__c,SBQQSC__SubscriptionStartDate__c,End_Terminated_Date__c,Category__c,Entitlement_Case_Type__c,Entitlement_Priority__c FROM ContractLineItems) FROM ServiceContract WHERE ID IN :serviceContractIds ];
    }

}