@isTest
public class T1_AutoAmendmentBatchTest2 {
    public static Boolean throwExceptionFlag = false;
    @isTest
    public static void TestT1_AutoAmendmentBatchTest(){
                blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(Name = 'Test Legal Entity',
                                                                        blng__Active__c = True);
        INSERT testLegalEntity;  
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=testLegalEntity.Id);
        
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        Increase_Rate_Types__c irt = new Increase_Rate_Types__c(Name='AIIA');
        INSERT irt; 
        
        Increase_Rate__c ir = new Increase_Rate__c(Increase_Rate_Type__c = irt.Id, Effective_From__c = system.today(), Increase_Rate__c = 0.7);
		INSERT ir;
         

        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'Level 1', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL1');
        Product2 product2 = new Product2(Name = 'Level 2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL2');        
        Product2 product3 = new Product2(Name = 'Level 3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL3');
        Product2 product4 = new Product2(Name = 'Level 4', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL4');
        INSERT new List<Product2>{product1, product2, product3, product4};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
		PricebookEntry pbe4 =new PricebookEntry(product2Id = product4.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4};
        
        SBQQ__ProductOption__c Level2Option = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                         SBQQ__DiscountedByPackage__c=false, 
                                                                         SBQQ__Number__c=20, SBQQ__OptionalSKU__c=product2.Id, 
                                                                         SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                         SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                         SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        SBQQ__ProductOption__c Level3Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product2.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product3.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
         SBQQ__ProductOption__c Level4Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product3.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product4.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        INSERT new List<SBQQ__ProductOption__c>{Level2Option,Level3Option,Level4Option};
            
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c',Deal_Type__c = 'Term', CloseDate = System.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        INSERT new List<Opportunity>{opp1};

        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today() + 365, SBQQ__ExpirationDate__c = System.today().addDays(30));
      

        INSERT new List<SBQQ__Quote__c>{quote1};
            
       	SBQQ__QuoteLine__c Level1 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                                                SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__ListPrice__c = 1000, SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', No_Indexation__c = false);
        INSERT Level1;
        
        SBQQ__QuoteLine__c Level2 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level1.Id, SBQQ__ProductOption__c = Level2Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', 
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level2;
        
        /*SBQQ__QuoteLine__c Level3 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level2.Id, SBQQ__ProductOption__c = Level3Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'ASM', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level3;
        
        SBQQ__QuoteLine__c Level4 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level3.Id, SBQQ__ProductOption__c = Level4Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product4.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level4;*/
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('3.Number of script statements used so far : ' + Limits.getDmlStatements());
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('5.CPU Time in this apex code so far: ' + Limits.getCpuTime());
		Test.startTest();
        
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract', 
                                                  SBQQSC__PreserveBundleStructureUponRenewals__c = true, 
                                                  SBQQSC__Quote__c = quote1.Id, 
                                                  StartDate = System.today().addYears(-1).addDays(28), 
                                                  EndDate = System.today().addDays(365), 
                                                  AccountId = a.Id, 
                                                  SBQQSC__Opportunity__c = opp1.Id, 
                                                  Pricebook2Id = pricebookId, 
                                                  Deal_Type__c = 'Term', 
                                                  Term = 36,
                                                  No_of_Auto_Ammendments__c = 0);        
        INSERT new List<ServiceContract>{sc1};
            
		sc1.Initial_Period_Increase_Rate__c = irt.Id;
        UPDATE sc1;
        
        ContractLineItem Level1ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, UnitPrice=1000, SBQQSC__ListPrice__c = 1000, PricebookEntryId = pbe1.Id, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, 
                                                               SBQQSC__QuoteLine__c = Level1.Id, SBQQSC__Product__c=product1.Id, Quantity = 1, Fee_Type__c = 'License');
        INSERT Level1ContLine; 
        ContractLineItem Level2ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, SBQQSC__ListPrice__c = 1000, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = Level2.Id, Quantity = 1,
                                                               SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', SBQQSC__ProductOption__c = Level2Option.Id, SBQQSC__RequiredByProduct__c=product1.Id, 
                                                               SBQQSC__Product__c=product2.Id, SBQQSC__RequiredById__c = Level1ContLine.Id);
        INSERT Level2ContLine; 
        /*ServiceContract SC = [SELECT ID, Deal_Type__c, SBQQSC__Quote__c, Initial_Period_Increase_Rate__c,No_of_Auto_Ammendments__c, Auto_Amendment_Control__c, X28_Days_before_Anniversary__c FROM ServiceContract limit 1];
        System.debug(loggingLevel.ERROR, '@@ IRATE' + SC.Initial_Period_Increase_Rate__c);
        System.debug(loggingLevel.ERROR, '@@ DEAL TYPE ' + SC.Deal_Type__c);
        System.debug(loggingLevel.ERROR, '@@ AMENDMENT CONTROL ' + SC.Auto_Amendment_Control__c);
        System.debug(loggingLevel.ERROR, '@@ 28 DAYS?' + SC.X28_Days_before_Anniversary__c);*/
        
        Database.executeBatch(new T1_AutoAmendmentBatch());
        Test.stopTest();
        Database.executeBatch(new T1_AutoAmendmentBatch(sc1.Id));
        T1_QuoteAutoOrder.quoteAmendment(quote1.Id,System.today(),'CPI');
       
   }
    @isTest
    public static void TestT1_AutoAmendmentBatchTestThrowExceptionFlag(){
          throwExceptionFlag = TRUE;
                blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(Name = 'Test Legal Entity',
                                                                        blng__Active__c = True);
        INSERT testLegalEntity;  
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=testLegalEntity.Id);
        
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        Increase_Rate_Types__c irt = new Increase_Rate_Types__c(Name='AIIA');
        INSERT irt; 
        
        Increase_Rate__c ir = new Increase_Rate__c(Increase_Rate_Type__c = irt.Id, Effective_From__c = system.today(), Increase_Rate__c = 0.7);
		INSERT ir;
         

        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'Level 1', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL1');
        Product2 product2 = new Product2(Name = 'Level 2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL2');        
        Product2 product3 = new Product2(Name = 'Level 3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL3');
        Product2 product4 = new Product2(Name = 'Level 4', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL4');
        INSERT new List<Product2>{product1, product2, product3, product4};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
		PricebookEntry pbe4 =new PricebookEntry(product2Id = product4.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4};
        
        SBQQ__ProductOption__c Level2Option = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                         SBQQ__DiscountedByPackage__c=false, 
                                                                         SBQQ__Number__c=20, SBQQ__OptionalSKU__c=product2.Id, 
                                                                         SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                         SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                         SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        SBQQ__ProductOption__c Level3Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product2.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product3.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
         SBQQ__ProductOption__c Level4Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product3.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product4.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        INSERT new List<SBQQ__ProductOption__c>{Level2Option,Level3Option,Level4Option};
            
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c',Deal_Type__c = 'Term', CloseDate = System.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        INSERT new List<Opportunity>{opp1};

        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today() + 365, SBQQ__ExpirationDate__c = System.today().addDays(30));
      

        INSERT new List<SBQQ__Quote__c>{quote1};
            
       	SBQQ__QuoteLine__c Level1 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                                                SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__ListPrice__c = 1000, SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', No_Indexation__c = false);
        INSERT Level1;
        
        SBQQ__QuoteLine__c Level2 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level1.Id, SBQQ__ProductOption__c = Level2Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', 
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level2;
        
        /*SBQQ__QuoteLine__c Level3 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level2.Id, SBQQ__ProductOption__c = Level3Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'ASM', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level3;
        
        SBQQ__QuoteLine__c Level4 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level3.Id, SBQQ__ProductOption__c = Level4Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product4.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level4;*/
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('3.Number of script statements used so far : ' + Limits.getDmlStatements());
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('5.CPU Time in this apex code so far: ' + Limits.getCpuTime());
		Test.startTest();
        
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract', 
                                                  SBQQSC__PreserveBundleStructureUponRenewals__c = true, 
                                                  SBQQSC__Quote__c = quote1.Id, 
                                                  StartDate = System.today().addYears(-1).addDays(28), 
                                                  EndDate = System.today().addDays(365), 
                                                  AccountId = a.Id, 
                                                  SBQQSC__Opportunity__c = opp1.Id, 
                                                  Pricebook2Id = pricebookId, 
                                                  Deal_Type__c = 'Term', 
                                                  Term = 36,
                                                  No_of_Auto_Ammendments__c = 0);        
        INSERT new List<ServiceContract>{sc1};
            
		sc1.Initial_Period_Increase_Rate__c = irt.Id;
        UPDATE sc1;
        
        ContractLineItem Level1ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, UnitPrice=1000, SBQQSC__ListPrice__c = 1000, PricebookEntryId = pbe1.Id, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, 
                                                               SBQQSC__QuoteLine__c = Level1.Id, SBQQSC__Product__c=product1.Id, Quantity = 1, Fee_Type__c = 'License');
        INSERT Level1ContLine; 
        ContractLineItem Level2ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, SBQQSC__ListPrice__c = 1000, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = Level2.Id, Quantity = 1,
                                                               SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', SBQQSC__ProductOption__c = Level2Option.Id, SBQQSC__RequiredByProduct__c=product1.Id, 
                                                               SBQQSC__Product__c=product2.Id, SBQQSC__RequiredById__c = Level1ContLine.Id);
        INSERT Level2ContLine; 
        /*ServiceContract SC = [SELECT ID, Deal_Type__c, SBQQSC__Quote__c, Initial_Period_Increase_Rate__c,No_of_Auto_Ammendments__c, Auto_Amendment_Control__c, X28_Days_before_Anniversary__c FROM ServiceContract limit 1];
        System.debug(loggingLevel.ERROR, '@@ IRATE' + SC.Initial_Period_Increase_Rate__c);
        System.debug(loggingLevel.ERROR, '@@ DEAL TYPE ' + SC.Deal_Type__c);
        System.debug(loggingLevel.ERROR, '@@ AMENDMENT CONTROL ' + SC.Auto_Amendment_Control__c);
        System.debug(loggingLevel.ERROR, '@@ 28 DAYS?' + SC.X28_Days_before_Anniversary__c);*/
        
        Database.executeBatch(new T1_AutoAmendmentBatch());
        Test.stopTest();
        Database.executeBatch(new T1_AutoAmendmentBatch(sc1.Id));
        T1_QuoteAutoOrder.quoteAmendment(quote1.Id,System.today(),'CPI');
   }

      

       /* @testSetup static void createData() {
        blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(Name = 'Test Legal Entity',
                                                                        blng__Active__c = True);
        INSERT testLegalEntity;  
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=testLegalEntity.Id);
        
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;
        
        blng__BillingRule__c billingRule = new blng__BillingRule__c(Name = 'Test billing rule', blng__Active__c = true, blng__InitialBillingTrigger__c = 'Order Product Activation Date	', blng__GenerateInvoices__c = 'Yes');
        INSERT billingRule;
        
        blng__RevenueRecognitionRule__c rrRule = new blng__RevenueRecognitionRule__c(blng__CreateRevenueSchedule__c = 'Yes', Name = 'Test Revenue Recog Rule', blng__Active__c = true);
        INSERT rrRule;
        
        blng__TaxRule__c taxRule = new blng__TaxRule__c(blng__Active__c = true, blng__TaxableYesNo__c = 'Yes', Name = 'Test Tax Rule');
        INSERT taxRule;
        
        Increase_Rate_Types__c irt = new Increase_Rate_Types__c(Name='AIIA');
        INSERT irt; 
        
        Increase_Rate__c ir = new Increase_Rate__c(Increase_Rate_Type__c = irt.Id, Effective_From__c = system.today(), Increase_Rate__c = 0.7);
		INSERT ir;
         

        Id pricebookId = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'Level 1', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL1');
        Product2 product2 = new Product2(Name = 'Level 2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL2');        
        Product2 product3 = new Product2(Name = 'Level 3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL3');
        Product2 product4 = new Product2(Name = 'Level 4', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = billingRule.Id, blng__RevenueRecognitionRule__c = rrRule.Id, blng__TaxRule__c = taxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'LVL4');
        INSERT new List<Product2>{product1, product2, product3, product4};
        
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
		PricebookEntry pbe4 =new PricebookEntry(product2Id = product4.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4};
        
        SBQQ__ProductOption__c Level2Option = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                         SBQQ__DiscountedByPackage__c=false, 
                                                                         SBQQ__Number__c=20, SBQQ__OptionalSKU__c=product2.Id, 
                                                                         SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                         SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                         SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        SBQQ__ProductOption__c Level3Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product2.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product3.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
         SBQQ__ProductOption__c Level4Option = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                          SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product3.Id, 
                                                                          SBQQ__DiscountedByPackage__c=false,
                                                                          SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product4.Id,
                                                                          SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                          SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                          SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false);
        
        INSERT new List<SBQQ__ProductOption__c>{Level2Option,Level3Option,Level4Option};
            
        Opportunity opp1 = new Opportunity(AccountId = a.Id, StageName = 'T1_Industry__c',Deal_Type__c = 'Term', CloseDate = System.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        INSERT new List<Opportunity>{opp1};
        
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today() + 365, SBQQ__ExpirationDate__c = System.today().addDays(30));
      

        INSERT new List<SBQQ__Quote__c>{quote1};
            
       	SBQQ__QuoteLine__c Level1 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                                                SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__ListPrice__c = 1000, SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', No_Indexation__c = false);
        INSERT Level1;
        
        SBQQ__QuoteLine__c Level2 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level1.Id, SBQQ__ProductOption__c = Level2Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', 
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level2;
        
        SBQQ__QuoteLine__c Level3 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level2.Id, SBQQ__ProductOption__c = Level3Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product3.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'ASM', SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level3;
        
        SBQQ__QuoteLine__c Level4 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__RequiredBy__c = Level3.Id, SBQQ__ProductOption__c = Level4Option.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, 
                                                            SBQQ__Product__c = product4.Id, SBQQ__PricebookEntryId__c = pricebookId, SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual',
                                                            SBQQ__DefaultSubscriptionTerm__c = 12, SBQQ__ListPrice__c = 1000, No_Indexation__c = false);
        INSERT Level4;
		Test.startTest();
        
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract', 
                                                  SBQQSC__PreserveBundleStructureUponRenewals__c = true, 
                                                  SBQQSC__Quote__c = quote1.Id, 
                                                  StartDate = System.today().addYears(-1).addDays(28), 
                                                  EndDate = System.today().addDays(365), 
                                                  AccountId = a.Id, 
                                                  SBQQSC__Opportunity__c = opp1.Id, 
                                                  Pricebook2Id = pricebookId, 
                                                  Deal_Type__c = 'Term', 
                                                  Term = 36,
                                                  No_of_Auto_Ammendments__c = 0);        
        INSERT new List<ServiceContract>{sc1};
            
		sc1.Initial_Period_Increase_Rate__c = irt.Id;
        UPDATE sc1;
        
        ContractLineItem Level1ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, UnitPrice=1000, SBQQSC__ListPrice__c = 1000, PricebookEntryId = pbe1.Id, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, 
                                                               SBQQSC__QuoteLine__c = Level1.Id, SBQQSC__Product__c=product1.Id, Quantity = 1, Fee_Type__c = 'License');
        INSERT Level1ContLine; 
        ContractLineItem Level2ContLine = new ContractLineItem(SBQQSC__Account__c = a.Id, PricebookEntryId = pbe2.Id, SBQQSC__ListPrice__c = 1000, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = Level2.Id, Quantity = 1,
                                                               SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', SBQQSC__ProductOption__c = Level2Option.Id, SBQQSC__RequiredByProduct__c=product1.Id, 
                                                               SBQQSC__Product__c=product2.Id, SBQQSC__RequiredById__c = Level1ContLine.Id);
        INSERT Level2ContLine; 
        
        Test.stopTest();
    }*/
    
   /* @isTest
    public static void TestT1_AutoAmendmentBatchTestIdthrowException(){
        throwExceptionFlag = TRUE;
        ServiceContract SC = [SELECT ID, Deal_Type__c, Initial_Period_Increase_Rate__c,No_of_Auto_Ammendments__c, Auto_Amendment_Control__c, X28_Days_before_Anniversary__c FROM ServiceContract limit 1];
        Test.startTest();
        Database.executeBatch(new T1_AutoAmendmentBatch(SC.Id));
        Test.stopTest();      
    }
    
     @isTest
    public static void TestT1_AutoAmendmentBatchTestNull(){
        ServiceContract SC = [SELECT ID, Deal_Type__c, Initial_Period_Increase_Rate__c,No_of_Auto_Ammendments__c, Auto_Amendment_Control__c, X28_Days_before_Anniversary__c FROM ServiceContract limit 1];
        SC.No_of_Auto_Ammendments__c = null;
        UPDATE SC;
        
        Test.startTest();
        Database.executeBatch(new T1_AutoAmendmentBatch(SC.Id));
        Test.stopTest();      
    }
    
    @isTest
    public static void TestT1_AutoAmendmentBatchOrderCreation(){
        List<SBQQ__Quote__c> QuoteLstToUpdate = [SELECT Id FROM SBQQ__Quote__c limit 1];
        
        System.debug(LoggingLevel.ERROR,'@@ QuoteLstToUpdate => ' + QuoteLstToUpdate);
        System.debug(LoggingLevel.ERROR,'@@ QuoteLstToUpdate size => ' + QuoteLstToUpdate.size());
            
        Test.startTest();
        Integer i = 5;
        String jobName = OrderTriggerHandler.getJobName('Auto_CreateOrder');
        T1_QuoteCreateOrder job = new T1_QuoteCreateOrder(QuoteLstToUpdate);
        String cronString = OrderTriggerHandler.getJobCronString(i); 
        OrderTriggerHandler.abortPreviousJobs('Auto_CreateOrder');
        System.debug('Processing aborted: ' + jobName);
        String jobId = System.schedule(jobName, cronString, job);    
        Test.stopTest();      
    }
    @isTest
    public static void TestT1_AutoAmendmentBatchOrderCreationthrowException(){
        throwExceptionFlag = TRUE;
        List<SBQQ__Quote__c> QuoteLstToUpdate = [SELECT Id FROM SBQQ__Quote__c limit 1];
        
        System.debug(LoggingLevel.ERROR,'@@ QuoteLstToUpdate => ' + QuoteLstToUpdate);
        System.debug(LoggingLevel.ERROR,'@@ QuoteLstToUpdate size => ' + QuoteLstToUpdate.size());
            
        Test.startTest();
        Integer i = 5;
        String jobName = OrderTriggerHandler.getJobName('Auto_CreateOrder');
        T1_QuoteCreateOrder job = new T1_QuoteCreateOrder(QuoteLstToUpdate);
        String cronString = OrderTriggerHandler.getJobCronString(i); 
        OrderTriggerHandler.abortPreviousJobs('Auto_CreateOrder');
        System.debug('Processing aborted: ' + jobName);
        String jobId = System.schedule(jobName, cronString, job);    
        Test.stopTest();      
    }*/
}