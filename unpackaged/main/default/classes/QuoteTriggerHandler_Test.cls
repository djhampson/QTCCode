@isTest
public class QuoteTriggerHandler_Test {
    @isTest public static void testQuoteTriggerHelperrunTriggers(){
        INSERT new T1_Control_Settings__c( Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
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
        
        Opportunity testOpp = new Opportunity(Name = 'Test Simplus Opp', 
                                              StageName = '1 - Discovery', 
                                              AccountId = acc.id, 
                                              CloseDate = System.Today()+1, 
                                              Type = 'Existing Business');
        INSERT testOpp;
        
        Product2 TestProd = new Product2(Name = 'Test Product', ProductCode = 'ABCD', IsActive = true, 
                                         SBQQ__PricingMethod__c = 'List', SBQQ__IncludeInMaintenance__c = true, SBQQ__ChargeType__c ='Recurring',
                                         SBQQ__BillingFrequency__c = 'Monthly', SBQQ__BlockPricingField__c = 'Quantity',  SBQQ__BillingType__c = 'Advance',
                                         Family = 'Test Family', SBQQ__SubscriptionPricing__c = 'Fixed Price',SBQQ__SubscriptionTerm__c = 12, SBQQ__SubscriptionBase__c = 'List',
                                         SBQQ__SubscriptionType__c = 'Renewable', SBQQ__SubscriptionCategory__c = 'Assessment');
        INSERT TestProd; 
        
        Id pricebookId = test.getStandardPricebookId(); 
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = TestProd.Id,
            UnitPrice = 10000, IsActive = true);
        INSERT standardPrice;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp.Id,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today()+5,SBQQ__SubscriptionTerm__c=12,
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
        
        ServiceContract SContractRec = new ServiceContract(Name = 'Test Contract', SBQQSC__PreserveBundleStructureUponRenewals__c = true, 
                                                  SBQQSC__Quote__c = quote.Id, StartDate = Date.today(), EndDate = Date.today() + 365, 
                                                  AccountId = acc.Id, SBQQSC__Opportunity__c = testOpp.Id, Pricebook2Id = pricebookId);
        INSERT SContractRec;
        
        ContractLineItem testContractLine = new ContractLineItem(ServiceContractId = SContractRec.Id,
                                                                 PricebookEntryId = standardPrice.Id,
                                                                 Quantity = 12,
                                                                 UnitPrice = 1000,
                                                                 SBQQSC__QuoteLine__c = quoteLine1.Id);
        INSERT testContractLine;
        Test.startTest();
        Opportunity testOpp1 = new Opportunity(Name = 'Test Simplus Opp', 
                                               StageName = '1 - Discovery', 
                                               AccountId = acc.id, 
                                               CloseDate = System.Today()+1, 
                                               Type = 'Existing Business');
        INSERT testOpp1;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Opportunity2__c=testOpp1.Id,
                                                   SBQQ__StartDate__c=System.Today(),
                                                   Product_Checker__c = true,
                                                   Validation_Error_Message__c = 'test',
                                                   SBQQ__EndDate__c=System.Today()+5,
                                                   SBQQ__SubscriptionTerm__c=12,
                                                   SBQQ__PriceBook__c=pricebookId,
                                                   SBQQ__Primary__c = true);
        INSERT quote2;
        
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote2.Id,
                                                               SBQQ__Product__c=TestProd.Id,
                                                               SBQQ__Quantity__c=15,
                                                               SBQQSC__UpgradedContractLine__c = testContractLine.Id,
                                                               SBQQ__StartDate__c=System.Today(),
                                                               SBQQ__EndDate__c=System.Today()+5);
        
        INSERT quoteLine2;
        
       
        Map<Id, SBQQ__Quote__c> newQuotesMap = new Map<Id, SBQQ__Quote__c>([SELECT Id,Product_Checker__c,Validation_Error_Message__c,(SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c =:testOpp1.Id]);
        System.debug(LoggingLevel.ERROR,'@@ QL SIZE ' + newQuotesMap.values()[0].SBQQ__LineItems__r.size());
        QuoteTriggerHandler.doBeforeUpdate(newQuotesMap);
        Test.stopTest();
    }
    
}