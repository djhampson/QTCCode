@IsTest 
public class T1_AssetCompoundInterest_Test {
    @IsTest
    public static void T1_AssetCompoundInterest_Test1(){
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c( Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        
        Account a = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT a;        
        
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
            Opportunity opp1 = new Opportunity(AccountId = a.Id, Deal_Type__c = 'Perpetual', StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        Opportunity opp2 = new Opportunity(AccountId = a.Id, Deal_Type__c = 'Perpetual on Cloud', StageName = 'T1_Industry__c', CloseDate = Date.today() + 30, Name = 'Original Opp', Pricebook2Id = pricebookId);
        INSERT new List<Opportunity>{opp1,opp2};
            
            // quotes
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = Date.today(), SBQQ__Opportunity2__c = opp1.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                       SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = Date.today() + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        
        INSERT new List<SBQQ__Quote__c>{quote1};
            
            SBQQ__QuoteLine__c quote1QL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
                                                                  SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                                  SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, 
                                                                  SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__ComponentListTotal__c=28472.68,
                                                                  SBQQ__ComponentTotal__c=22382.27, SBQQ__ComponentUpliftedByPackage__c=false,
                                                                  SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false,
                                                                  SBQQ__CustomerPrice__c=0.00, 
                                                                  SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, 
                                                                  SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, 
                                                                  SBQQ__ListPrice__c=0.00, SBQQ__NetPrice__c=0.00, 
                                                                  SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, 
                                                                  SBQQ__Number__c=1, SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, 
                                                                  SBQQ__PartnerPrice__c=0.00, SBQQ__PriceEditable__c=false, 
                                                                  SBQQ__PricebookEntryId__c=pbe1.Id, 
                                                                  SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                                  SBQQ__ProductSubscriptionType__c='One-time', 
                                                                  SBQQ__Product__c=product1.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                                  SBQQ__ProratedPrice__c=0.00, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                                  SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                                  SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                                  SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                                  Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
        SBQQ__QuoteLine__c quote1QL3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
                                                              SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                              SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, 
                                                              SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__ComponentListTotal__c=28472.68,
                                                              SBQQ__ComponentTotal__c=22382.27, SBQQ__ComponentUpliftedByPackage__c=false,
                                                              SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false,
                                                              SBQQ__CustomerPrice__c=0.00, 
                                                              SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, 
                                                              SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, 
                                                              SBQQ__ListPrice__c=0.00, SBQQ__NetPrice__c=0.00, 
                                                              SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, 
                                                              SBQQ__Number__c=1, SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, 
                                                              SBQQ__PartnerPrice__c=0.00, SBQQ__PriceEditable__c=false, 
                                                              SBQQ__PricebookEntryId__c=pbe3.Id, 
                                                              SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                              SBQQ__ProductSubscriptionType__c='One-time', 
                                                              SBQQ__Product__c=product3.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                              SBQQ__ProratedPrice__c=0.00, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                              SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                              SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                              SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                              Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
        
        SBQQ__QuoteLine__c quote1QL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', Category__c = SM_SplitInvoice.QUOTELINE_CATEGORY_COMMITMENT_REBATE, SBQQ__CustomerPrice__c = -100, SBQQ__Quantity__c = 1, SBQQ__Product__c = product2.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                                              SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12);
        
        INSERT new List<SBQQ__QuoteLine__c>{quote1QL1,quote1QL2,quote1QL3};
            
            Asset TestAsset1 = new Asset (AccountId=a.Id, Product2Id=product1.Id, IsCompetitorProduct=false,
                                          Name='TechnologyOne Supply Chain Management', Price=0, Quantity=1.00, SBQQ__Bundle__c=true,
                                          SBQQ__Bundled__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__CombineKey__c=quote1QL1.Id,
                                          SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__FromServiceCloud__c=true, 
                                          SBQQ__LatestQuoteLine__c=quote1QL1.Id, SBQQ__ListPrice__c=0.00, SBQQ__Number__c=1, 
                                          SBQQ__PricingMethod__c='List', SBQQ__QuoteLine__c=quote1QL1.Id,
                                          SBQQ__RegularPrice__c=0.00,Account__c=a.Id, Deal_Type__c='Perpetual', 
                                          Customer_Total_Copy__c=0.00);
        INSERT TestAsset1; 
        
        // SERVICE CONTRACT
        ServiceContract sc1 = new ServiceContract(Name = 'Test Contract', SBQQSC__PreserveBundleStructureUponRenewals__c = true, SBQQSC__Quote__c = quote1.Id, StartDate = Date.today(), EndDate = Date.today() + 365, AccountId = a.Id, SBQQSC__Opportunity__c = opp1.Id, Pricebook2Id = pricebookId);        
        INSERT sc1;
        
        ContractLineItem contLine1 = new ContractLineItem(SBQQSC__Account__c = a.Id, SBQQSC__RequiredById__c = TestAsset1.Id, SBQQSC__SubscriptionPricing__c = 'Fixed Price', PricebookEntryId = pbe2.Id, UnitPrice = 1000, SBQQSC__Quantity__c = 1, ServiceContractId = sc1.Id, SBQQSC__QuoteLine__c = quote1QL1.Id, Quantity = 1);
        INSERT contLine1;
        
        Test.startTest();
        Integer i = 1;
        String jobName = OrderTriggerHandler.getJobName('AssetCompoundInterest'+i);
        T1_AssetCompoundInterest job = new T1_AssetCompoundInterest(new Set<Id>{sc1.Id});
        String cronString = OrderTriggerHandler.getJobCronString(i);  //1 minute
        OrderTriggerHandler.abortPreviousJobs('AssetCompoundInterest'+i);
        System.debug('Processing aborted: ' + jobName);
        String jobId = System.schedule(jobName, cronString, job); 
        Test.stopTest();
    }
}