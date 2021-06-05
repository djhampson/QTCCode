/*******************************************************************************************************
* @Class Name   : RenewalServiceContractsBatchTest
* @description  : Test class for RenewalServiceContractsBatch
* @author       : Carlos Roy Billones
* @date         : 05/01/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   05/01/2021      1000        Initial version
******************************************************************************************************/
@isTest
private class RenewalServiceContractsBatchTest 
{
    @testSetup private static void createData() {
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        // Billing Rule
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        Product2 product2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');        
        Product2 product3 = new Product2(Name = 'test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance');
        insert new List<Product2>{product1, product2, product3};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 0, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3};
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId, Auto_Renewal_Date__c = System.today(), Auto_Renewal_Treatment__c = 'Auto-Renew continuously – 12 months', Auto_Order__c = false, Stop_Auto_Renewal__c = '');
        INSERT new List<Opportunity>{opp1};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
      

        INSERT new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                  SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
            INSERT lines;
        
        // service contracts
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract', SBQQSC__PreserveBundleStructureUponRenewals__c = true, SBQQSC__Quote__c = quote1.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id, Pricebook2Id = pricebookId, SBQQSC__RenewalOpportunity__c = null,Auto_Renewal_Date__c = System.today(), Auto_Renewal_Treatment__c = 'Auto-Renew continuously – 12 months', Stop_Auto_Renewal__c = '');        
        INSERT new List<ServiceContract>{sc1};
            
            ContractLineItem contLine1 = new ContractLineItem(SBQQSC__Account__c = a.Id, SBQQSC__SubscriptionPricing__c = 'Fixed Price', PricebookEntryId = pbe1.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[0].Id, Quantity = 1, Scheduled_End_Date__c = Date.today() + 500);
        INSERT contLine1;
        
        ContractLineItem contLine2 = new ContractLineItem(SBQQSC__Account__c = a.Id, SBQQSC__RevisedSubscription__c = contLine1.id,SBQQSC__SubscriptionPricing__c = 'Fixed Price', PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[1].Id, Quantity = 1, Scheduled_End_Date__c = Date.today() + 500);
        INSERT contLine2;
        
        Test.startTest();
        sc1.Name = 'Test Contract1';
        lines[0].SBQQSC__RenewedContractLine__c = contLine1.Id;
        lines[1].SBQQSC__RenewedContractLine__c = contLine2.Id;
        update lines;
        
        UPDATE sc1;
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchClass()
    {
        Test.startTest();
        Database.executeBatch(new RenewalServiceContractsBatch());
        Test.stopTest();
        System.schedule('Test Job', '0 0 1 3 10 ?', new T1_RenewalServiceBatchSchedulable());
    }
}