/*******************************************************************************************************
* @Class Name   : T1_InvoiceSyncBatch_Test
* @description  : Test class for T1_InvoiceSyncBatch
* @author       : Gerald Arzadon
* @date         : 12/01/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Gerald Arzadon        12/01/2021      1000        Initial version
* Yi Zhang              25/03/2021      2000        Added cloned T1 invoice to test InvoiceTriggerHandler
******************************************************************************************************/
@isTest
public class T1_InvoiceSyncBatch_Test {
    @isTest
    public static void T1_InvoiceSyncBatch_Test1(){
        Id pricebookId = test.getStandardPricebookId(); 
        
        blng__BillingRule__c testBillingRule = new blng__BillingRule__c(blng__Active__c = true, 
                                                                        blng__PartialPeriodTreatment__c = 'Combine',
                                                                        Name = 'test',
                                                                        blng__InitialBillingTrigger__c = 'Order Product Activation Date',
                                                                        blng__GenerateInvoices__c = 'Yes');
        INSERT testBillingRule;
        blng__RevenueRecognitionRule__c testRevRecogRule = new 	blng__RevenueRecognitionRule__c(blng__Active__c = true,
                                                                                                Name = 'test',
                                                                                                blng__CreateRevenueSchedule__c = 'No');
        INSERT testRevRecogRule;
        blng__TaxRule__c testTaxRule = new blng__TaxRule__c(blng__Active__c = true,
                                                            Name = 'test',
                                                            blng__TaxableYesNo__c = 'No');
        INSERT testTaxRule;
        blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(Name = 'Test Legal Entity',
                                                                        blng__Active__c = True);
        INSERT testLegalEntity;   
        
        Account acc = new Account(Name = 'Test Acc',
                                  Type = 'Customer',
                                  CountryArea__c = 'Australia',
                                  Country_Code__c = '11',
                                  T1_Industry__c = 'Corporate',
                                  Region__c = 'New South Wales',
                                  Vertical_Market__c = 'Corporate',
                                  billingStreet = '123 w fake');
        INSERT acc;
        Contact testCont = new Contact(LastName = 'testCont', 
                                       Title = 'Billing Contact', 
                                       AccountId = acc.id,
                                       Email = 'test@gmail.com');
        INSERT testCont;
        acc.blng__BillToContact__c = testCont.id;
        UPDATE acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Simplus Opp', 
                                          StageName = '1 - Discovery', 
                                          AccountId = acc.id, 
                                          CloseDate = System.Today()+1, 
                                          Type = 'Existing Business',
                                          Auto_Renew__c = true,
                                          Pricebook2Id=pricebookId);
        INSERT opp;
        Product2 TestProd = new Product2(Name = 'Test Product', ProductCode = 'ABCD', IsActive = true, 
                                         SBQQ__PricingMethod__c = 'List', SBQQ__IncludeInMaintenance__c = true, SBQQ__ChargeType__c ='Recurring',
                                         SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BlockPricingField__c = 'Quantity',  SBQQ__BillingType__c = 'Advance',
                                         Family = 'Test Family', SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List',
                                         SBQQ__SubscriptionType__c = 'Renewable', SBQQ__SubscriptionCategory__c = 'Assessment',blng__TaxRule__c = testTaxRule.id,
                                         blng__RevenueRecognitionRule__c = testRevRecogRule.id, 
                                         blng__BillingRule__c = testBillingRule.id);
        INSERT TestProd; 
        
        PricebookEntry TestPBE = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = TestProd.Id,
            UnitPrice = 10000, IsActive = true);
        INSERT TestPBE;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.Id,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today()+5,SBQQ__SubscriptionTerm__c=12,
                                                  SBQQ__PriceBook__c=pricebookId,SBQQ__Primary__c = true);
        INSERT quote;
        SBQQ__QuoteLineGroup__c testQLGroup = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c = quote.Id,
                                                                          Period_Type__c = null);
        INSERT testQLGroup;
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,
                                                               SBQQ__Product__c=TestProd.Id,
                                                               SBQQ__Group__c = testQLGroup.Id,
                                                               SBQQ__Quantity__c=15,
                                                               SBQQ__StartDate__c=System.Today(),
                                                               SBQQ__EndDate__c=System.Today()+5);
        INSERT quoteLine1;
        
        Order testOrd = new Order(AccountId = acc.id, 
                                  Status = 'Draft',
                                  SBQQ__PaymentTerm__c = '20',
                                  EffectiveDate = System.Today()+1,
                                  blng__BillingDayOfMonth__c = '1',
                                  OpportunityId = opp.id,
                                  blng__BillingAccount__c = acc.id, 
                                  Pricebook2Id = Test.getStandardPricebookId());
        INSERT testOrd;
        
        OrderItem testOrdItem = new OrderItem(OrderId = testOrd.id,
                                              Quantity = 2,
                                              SBQQ__Status__c = 'Activated',
                                              UnitPrice = 5000,
                                              SBQQ__ChargeType__c = 'One-Time',
                                              PricebookEntryId = TestPBE.id,
                                              SBQQ__QuoteLine__c = quoteLine1.id);
        INSERT testOrdItem;
        
        Order testOrdActivate = new Order(id = testOrd.id,
                                          Status = 'Activated');
        UPDATE testOrdActivate;
        
        blng__Invoice__c testInvc = new blng__Invoice__c(blng__Account__c = acc.id,
                                                         blng__Order__c = testOrdActivate.id,
                                                         blng__InvoiceStatus__c = 'Draft',
                                                         blng__InvoiceDate__c = Date.valueof(System.now()+1));
        INSERT testInvc;
        
        blng__InvoiceLine__c testInvoiceLine = new blng__InvoiceLine__c(blng__InvoiceLineStatus__c = 'Posted',
                                                                        blng__Invoice__c = testInvc.id, 
                                                                        blng__UnitPrice__c = 6000,
                                                                        blng__Subtotal__c = 6000,
                                                                        blng__TotalAmount__c = 6000,
                                                                        blng__TaxAmount__c = 6000,
                                                                        blng__StartDate__c = System.today() + 1,
                                                                        blng__NegativeLineConversion__c = 0,
                                                                        blng__OrderProduct__c = testOrdItem.id);
        INSERT testInvoiceLine;
        
        SM_CloneInvoice.cloneInvoicesAndLines(new List<String>{testInvc.Id});

        Test.startTest();
        Database.executeBatch(new T1_InvoiceSyncBatch());
        Test.stopTest();
        Database.executeBatch(new T1_InvoiceSyncBatch(testInvc.Id));
        System.schedule('Test Job', '0 0 1 3 10 ?', new T1_InvoiceSyncBatchSchedulable());
    }
}