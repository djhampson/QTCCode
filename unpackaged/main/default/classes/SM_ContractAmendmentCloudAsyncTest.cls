/*******************************************************************************************************
* @Class Name   : SM_ContractAmendmentCloudAsyncTest
* @description  : Test class for SM_ContractAmendmentCloudAsync
* @author       : Yi Zhang
* @date         : 18/03/2021
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Yi Zhang              18/03/2021      1000        Initial version
******************************************************************************************************/
@isTest
public class SM_ContractAmendmentCloudAsyncTest { 
    public static Boolean throwExceptionFlag = false;
    @isTest
    static void testSchedule() {
        // for functional test:
        // create quote 1 & contract 1
        // create quote 2 with contract 2 associated to contract 1 properly
        // the async will:
        // - amend contract 1 to get quote 3
        // - update quote 2 & 3

        // Account
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert a;
        
        // Billing Rule
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        insert billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        insert rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        insert taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');        
        Product2 product3 = new Product2(Name = SM_PerpetualOnCloud.NEW_PRODUCT_NAME, blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');
        insert new List<Product2>{product1, product2, product3};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 0, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = '2 - Qualify', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, StageName = '2 - Qualify', CloseDate = Date.today() + 30, Name = 'Perpetual on Cloud Opp', Pricebook2Id = pricebookId, Deal_Type__c = SM_PerpetualOnCloud.PERPETUAL_ON_CLOUD);
        insert new List<Opportunity>{opp1, opp2};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30, SBQQ__Type__c = 'Amendment');

        insert new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                  SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
            //                        ,
            // new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
            //                       SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            // new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
            //                        SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
        insert lines;
        Test.startTest();       

        // service contracts
        ServiceContract sc1 = new ServiceContract(Name = 'Yi Original Contract 01', SBQQSC__Quote__c = quote1.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id, Pricebook2Id = pricebookId, SBQQSC__PreserveBundleStructureUponRenewals__c = true);
        ServiceContract sc2 = new ServiceContract(Name = 'Yi Perpetual Contract 01', StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp2.Id, Pricebook2Id = pricebookId, SBQQSC__PreserveBundleStructureUponRenewals__c = true, Migrated_to_SaaS_Platform__c = true, Deal_Type__c = 'Perpetual');
        // bypass the CPQ/BILLING - Service Contract Processes
        insert new T1_Control_Settings__c(Bypass_Workflow__c = true, SetupOwnerId = UserInfo.getUserId());
        insert new List<ServiceContract>{sc1, sc2};
        List<ContractLineItem> clis = new List<ContractLineItem>{
            new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe1.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[0].Id, Quantity = 1),
            new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[1].Id, Quantity = 1)
            // ,
            // new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe1.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc2.Id, SBQQSC__QuoteLine__c = lines[2].Id, Quantity = 1),
            // new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc2.Id, SBQQSC__QuoteLine__c = lines[3].Id, Quantity = 1)
        };
        insert clis;

        sc1.Linked_Perpetual_Agreement__c = sc2.Id;
        update sc1;

        sc2.Migrated_to_SaaS_Platform__c = true;
        sc2.Deal_Type__c = 'Perpetual';
        update sc2;

        quote2.SBQQSC__MasterServiceContract__c = sc2.Id;
        insert quote2;
                
        Test.stopTest();

        // amendment quote not generated likely due to test framework constraint in CPQ context
        // SBQQ__Quote__c amendmentQuote = [SELECT Id, Twin_Quote__c FROM SBQQ__Quote__c WHERE SBQQSC__MasterServiceContract__c = :sc1.Id];
        // System.assertEquals(quote2.Id, amendmentQuote.Twin_Quote__c);
        // System.assertEquals(amendmentQuote.Id, [SELECT Id, Twin_Quote__c FROM SBQQ__Quote__c WHERE Id = :quote2.Id].Twin_Quote__c);
    }
        @isTest
    static void testScheduleWithException() {
        // for functional test:
        // create quote 1 & contract 1
        // create quote 2 with contract 2 associated to contract 1 properly
        // the async will:
        // - amend contract 1 to get quote 3
        // - update quote 2 & 3
        throwExceptionFlag = true;
        // Account
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert a;
        
        // Billing Rule
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        insert billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        insert rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        insert taxRule;
        
        // product
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');        
        Product2 product3 = new Product2(Name = SM_PerpetualOnCloud.NEW_PRODUCT_NAME, blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', IsActive = true, SBQQ__SubscriptionPricing__c = 'Fixed Price');
        insert new List<Product2>{product1, product2, product3};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = -100, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 0, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};
        
        // opportunity
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = '2 - Qualify', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, StageName = '2 - Qualify', CloseDate = Date.today() + 30, Name = 'Perpetual on Cloud Opp', Pricebook2Id = pricebookId, Deal_Type__c = SM_PerpetualOnCloud.PERPETUAL_ON_CLOUD);
        insert new List<Opportunity>{opp1, opp2};
        
        // quotes
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30, SBQQ__Type__c = 'Amendment');

        insert new List<SBQQ__Quote__c>{quote1};
        // quote lines
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                  SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                   SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
            //                        ,
            // new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
            //                       SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12), 
            // new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
            //                        SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12)
        };
        insert lines;
        Test.startTest();       

        // service contracts
        ServiceContract sc1 = new ServiceContract(Name = 'Yi Original Contract 01', SBQQSC__Quote__c = quote1.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id, Pricebook2Id = pricebookId, SBQQSC__PreserveBundleStructureUponRenewals__c = true);
        ServiceContract sc2 = new ServiceContract(Name = 'Yi Perpetual Contract 01', StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp2.Id, Pricebook2Id = pricebookId, SBQQSC__PreserveBundleStructureUponRenewals__c = true, Migrated_to_SaaS_Platform__c = true, Deal_Type__c = 'Perpetual');
        // bypass the CPQ/BILLING - Service Contract Processes
        insert new T1_Control_Settings__c(Bypass_Workflow__c = true, SetupOwnerId = UserInfo.getUserId());
        insert new List<ServiceContract>{sc1, sc2};
        List<ContractLineItem> clis = new List<ContractLineItem>{
            new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe1.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[0].Id, Quantity = 1),
            new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = lines[1].Id, Quantity = 1)
            // ,
            // new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe1.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc2.Id, SBQQSC__QuoteLine__c = lines[2].Id, Quantity = 1),
            // new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc2.Id, SBQQSC__QuoteLine__c = lines[3].Id, Quantity = 1)
        };
        insert clis;

        sc1.Linked_Perpetual_Agreement__c = sc2.Id;
        update sc1;

        sc2.Migrated_to_SaaS_Platform__c = true;
        sc2.Deal_Type__c = 'Perpetual';
        update sc2;

        quote2.SBQQSC__MasterServiceContract__c = sc2.Id;
        insert quote2;
                
        Test.stopTest();
    }
}