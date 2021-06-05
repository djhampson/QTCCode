@IsTest
public class T1_CalculateAndOrderBatch_Test {
    @IsTest
    static void T1_CalculateAndOrderBatch_Test1() {
         
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE);
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        INSERT new List<Product2>{product, product2};
        
        
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        INSERT pbes;
        
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        INSERT opp1;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5',Auto_Amendment__c = TRUE); 
        INSERT quote1;
        
       	List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance')
        };
        INSERT lines;
        
        Test.startTest();
       	Database.executeBatch(new T1_CalculateAndOrderBatch(),1);
        Test.stopTest();
        Set<Id> QuoteIds = new Set<Id>();
        QuoteIds.add(quote1.Id);
        Database.executeBatch(new T1_CalculateAndOrderBatch(QuoteIds));
        System.schedule('AM - Auto Calculate and Auto Order', '0 30 * * * ?', new T1_CalculateAndOrderBatch());
    }
    
    
    @IsTest
    static void T1_CalculateAndOrderBatch_Test2() {
         
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE);
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = new Product2(Name = 'test p', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        Product2 product2 = new Product2(Name = 'test p2', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', SBQQ__SubscriptionTerm__c = 12);
        INSERT new List<Product2>{product, product2};
        
        
        List<PricebookEntry> pbes = new List<PricebookEntry>{
            new PricebookEntry(product2Id = product.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true),
            new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true)
        };
        INSERT pbes;
        
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Test Opp', Pricebook2Id = pricebookId);
        INSERT opp1;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5',Auto_Amendment__c = TRUE, Calculate_Trigger__c = 4); 
        INSERT quote1;
        
       	List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, Fee_Type__c = SM_SplitInvoice.QUOTELINE_FEE_TYPE_CLOUD, SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingFrequency__c = 'Annual', SBQQ__BillingType__c = 'Advance')
        };
        INSERT lines;
        
        Test.startTest();
       	Database.executeBatch(new T1_CalculateAndOrderBatch(),1);
        Test.stopTest();
        Set<Id> QuoteIds = new Set<Id>();
        QuoteIds.add(quote1.Id);
        Database.executeBatch(new T1_CalculateAndOrderBatch(QuoteIds));
        System.schedule('AM - Auto Calculate and Auto Order', '0 30 * * * ?', new T1_CalculateAndOrderBatch());
    }
}