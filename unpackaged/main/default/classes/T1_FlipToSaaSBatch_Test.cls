@IsTest
public class T1_FlipToSaaSBatch_Test {
    @isTest
    public static void T1_FlipToSaaSBatch_Test1(){ 
        Id pricebookId = Test.getStandardPricebookId();
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        
        blng__TaxRule__c TaxRule = new blng__TaxRule__c (Name='Standard Tax', blng__Active__c=true, blng__TaxableYesNo__c='No');
        INSERT TaxRule;
        
        blng__BillingRule__c BillingRule = new  blng__BillingRule__c (Name='Invoicing - Standard', blng__Active__c=true, blng__AmendmentBillCycleDateAlignment__c='Align to original Order Product',
                                                                      blng__GenerateInvoices__c='Yes', blng__InitialBillingTrigger__c='Order Product Activation Date', 
                                                                      blng__PartialPeriodTreatment__c='Separate');
        INSERT BillingRule;
        
        blng__RevenueRecognitionRule__c RevenueRecognitionRule = new blng__RevenueRecognitionRule__c(Name='Order Based - Rateable Recognition', blng__Active__c=true, blng__CreateRevenueSchedule__c='Yes');
        INSERT RevenueRecognitionRule;
        
        Product2 product1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM');
        Product2 product2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM');        
        Product2 product3 = new Product2(Name = 'test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        INSERT new List<Product2>{product1, product2, product3};
            
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3};
            
        SBQQ__ProductOption__c POB1 = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                     SBQQ__DiscountedByPackage__c=false, 
                                                                     SBQQ__Number__c=20, SBQQ__OptionalSKU__c=product2.Id, 
                                                                     SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                     SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                     SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                                     Option_NOT_within_Account_Region__c=false);
        
        SBQQ__ProductOption__c POSPS = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                   SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                   SBQQ__DiscountedByPackage__c=false,
                                                                   SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product3.Id,
                                                                   SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                   SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                   SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, Option_NOT_within_Account_Region__c=false);
        
        INSERT new List<SBQQ__ProductOption__c>{POB1,POSPS};
            
        Account acc = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT acc;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licence Fee').getRecordTypeId();
        Opportunity testOpp = new Opportunity (AccountId=acc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1 - Original',
                                               StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                               Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                               Start_Date__c=System.today(), Licence_Model__c='Perpetual', AMS_Units_per_Service_Period__c=40,
                                               Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='Perpetual');
        
        Opportunity testOpp2 = new Opportunity (AccountId=acc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1',
                                                StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                                Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                                Start_Date__c=System.today().addDays(30), Licence_Model__c='SaaS', AMS_Units_per_Service_Period__c=40,
                                                Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='SaaS');
        INSERT new List<Opportunity>{testOpp,testOpp2};
            
            
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(Transaction_Type__c = 'Flip to SaaS', SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);        
        INSERT new List<SBQQ__Quote__c>{quote1,quote2};
        
        SBQQ__QuoteLine__c SPSQL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__BillingFrequency__c='Annual', SBQQ__BillingType__c='Advance',
                                                          SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='Recurring', SBQQ__ComponentDiscountedByPackage__c=false,
                                                          SBQQ__ComponentSubscriptionScope__c='Components', SBQQ__ComponentUpliftedByPackage__c=false, SBQQ__ConfigurationRequired__c=false,
                                                          SBQQ__CostEditable__c=false, SBQQ__CustomerPrice__c=4111.03, SBQQ__DefaultSubscriptionTerm__c=12,
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, SBQQ__Hidden__c=false,
                                                          SBQQ__Incomplete__c=false, SBQQ__ListPrice__c=1012.5003947368423, SBQQ__NetPrice__c=4111.03, SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false,
                                                          SBQQ__Number__c=3, SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, SBQQ__PartnerPrice__c=4111.03, 
                                                          SBQQ__PriceEditable__c=false, SBQQ__PricebookEntryId__c=pbe3.Id, SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='Fixed Price',
                                                          SBQQ__ProductSubscriptionType__c='Renewable', SBQQ__Product__c=product3.Id, SBQQ__ProductOption__c=POSPS.Id,
                                                          SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=4111.03, SBQQ__ProratedPrice__c=4111.03, SBQQ__Quantity__c=1.00, 
                                                          SBQQ__RegularPrice__c=4111.03, SBQQ__Renewal__c=false, //SBQQ__RequiredBy__c=SCMQL.Id,
                                                          SBQQ__SpecialPrice__c=1012.5003947368423, SBQQ__SubscriptionBase__c='Net', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionPercent__c=22.500,
                                                          SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionScope__c='Group', SBQQ__SubscriptionType__c='Renewable', SBQQ__Taxable__c=false, 
                                                          SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='ASM', AdditionalDiscountUnit__c='Percent', Category__c='Support Fee');
        
       SBQQ__QuoteLine__c SPSQL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__BillingFrequency__c='Annual', SBQQ__BillingType__c='Advance',
                                                          SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='Recurring', SBQQ__ComponentDiscountedByPackage__c=false,
                                                          SBQQ__ComponentSubscriptionScope__c='Components', SBQQ__ComponentUpliftedByPackage__c=false, SBQQ__ConfigurationRequired__c=false,
                                                          SBQQ__CostEditable__c=false, SBQQ__CustomerPrice__c=4111.03, SBQQ__DefaultSubscriptionTerm__c=12,
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, SBQQ__Hidden__c=false,
                                                          SBQQ__Incomplete__c=false, SBQQ__ListPrice__c=1012.5003947368423, SBQQ__NetPrice__c=4111.03, SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false,
                                                          SBQQ__Number__c=3, SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, SBQQ__PartnerPrice__c=4111.03, 
                                                          SBQQ__PriceEditable__c=false, SBQQ__PricebookEntryId__c=pbe3.Id, SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='Fixed Price',
                                                          SBQQ__ProductSubscriptionType__c='Renewable', SBQQ__Product__c=product3.Id, SBQQ__ProductOption__c=POSPS.Id,
                                                          SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=4111.03, SBQQ__ProratedPrice__c=4111.03, SBQQ__Quantity__c=1.00, 
                                                          SBQQ__RegularPrice__c=4111.03, SBQQ__Renewal__c=false, //SBQQ__RequiredBy__c=SCMQL.Id,
                                                          SBQQ__SpecialPrice__c=1012.5003947368423, SBQQ__SubscriptionBase__c='Net', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionPercent__c=22.500,
                                                          SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionScope__c='Group', SBQQ__SubscriptionType__c='Renewable', SBQQ__Taxable__c=false, 
                                                          SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='ASM', AdditionalDiscountUnit__c='Percent', Category__c='Support Fee');
        
        INSERT new List<SBQQ__QuoteLine__c>{SPSQL1,SPSQL2};
            
        ServiceContract servCont = new ServiceContract (Name='Service Contract',  AccountId=acc.Id, Term=48, StartDate=System.today(), EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=quote1.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false,
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
       
        ServiceContract servCont2 = new ServiceContract (Name='Service Contract',  AccountId=acc.Id, Term=48, StartDate=System.today()+30, EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=quote2.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false, 
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
        
        INSERT new List<ServiceContract>{servCont,servCont2};
            
        ContractLineItem contLine = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today(), EndDate=System.today().addYears(3), PricebookEntryId=pbe3.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=acc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=SPSQL1.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductOption__c=POSPS.Id, SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=SPSQL1.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',
                                                         Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        INSERT contLine;
        
        ContractLineItem contLine2 = new ContractLineItem(ServiceContractId = servCont2.Id,Flipped_from_Contract_Line__c =  contLine.Id,Flipped_Qty__c =5, StartDate=System.today(), EndDate=System.today().addYears(3), PricebookEntryId=pbe3.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=acc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=SPSQL1.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductOption__c=POSPS.Id, SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=SPSQL1.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',
                                                          Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        INSERT contLine2;
        Test.startTest();
        ServiceContract contLineTest = [SELECT Id,SBQQSC__Quote__r.Transaction_Type__c,Flipped_Lines__c FROM ServiceContract WHERE Id =:servCont2.Id LIMIT 1];
        System.debug('Service Contract Transaction Type => ' + contLineTest.SBQQSC__Quote__r.Transaction_Type__c);
        System.debug('Service Contract Flipped Lines => ' + contLineTest.Flipped_Lines__c);
        Database.executeBatch(new T1_FlipToSaaSBatch(servCont2.id));
        Test.stopTest();
        Database.executeBatch(new T1_FlipToSaaSBatch());
        T1_FlipToSaaSAutoOrder.scheduleFTSAsync(new List<SBQQ__Quote__c>{quote1});
        System.schedule('TEST Batch', '0 0 * * * ?', new T1_FlipToSaaSBatch());
 	}    
     @isTest
    public static void T1_FlipToSaaSBatch_Test1throwExceptionFlag(){ 
        Id pricebookId = Test.getStandardPricebookId();
        T1_AutoAmendmentBatchTest2.throwExceptionFlag = TRUE;
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        
        blng__TaxRule__c TaxRule = new blng__TaxRule__c (Name='Standard Tax', blng__Active__c=true, blng__TaxableYesNo__c='No');
        INSERT TaxRule;
        
        blng__BillingRule__c BillingRule = new  blng__BillingRule__c (Name='Invoicing - Standard', blng__Active__c=true, blng__AmendmentBillCycleDateAlignment__c='Align to original Order Product',
                                                                      blng__GenerateInvoices__c='Yes', blng__InitialBillingTrigger__c='Order Product Activation Date', 
                                                                      blng__PartialPeriodTreatment__c='Separate');
        INSERT BillingRule;
        
        blng__RevenueRecognitionRule__c RevenueRecognitionRule = new blng__RevenueRecognitionRule__c(Name='Order Based - Rateable Recognition', blng__Active__c=true, blng__CreateRevenueSchedule__c='Yes');
        INSERT RevenueRecognitionRule;
        
        Product2 product1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM');
        Product2 product2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM');        
        Product2 product3 = new Product2(Name = 'test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        INSERT new List<Product2>{product1, product2, product3};
            
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3};
            
        SBQQ__ProductOption__c POB1 = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                     SBQQ__DiscountedByPackage__c=false, 
                                                                     SBQQ__Number__c=20, SBQQ__OptionalSKU__c=product2.Id, 
                                                                     SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                     SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                     SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                                     Option_NOT_within_Account_Region__c=false);
        
        SBQQ__ProductOption__c POSPS = new  SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, 
                                                                   SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                   SBQQ__DiscountedByPackage__c=false,
                                                                   SBQQ__Number__c=990, SBQQ__OptionalSKU__c=product3.Id,
                                                                   SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, SBQQ__Required__c=false,
                                                                   SBQQ__Selected__c=true, SBQQ__SubscriptionScope__c='Components', SBQQ__System__c=false,
                                                                   SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, Option_NOT_within_Account_Region__c=false);
        
        INSERT new List<SBQQ__ProductOption__c>{POB1,POSPS};
            
        Account acc = new Account(Name = 'Test A', Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        INSERT acc;
        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licence Fee').getRecordTypeId();
        Opportunity testOpp = new Opportunity (AccountId=acc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1 - Original',
                                               StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                               Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                               Start_Date__c=System.today(), Licence_Model__c='Perpetual', AMS_Units_per_Service_Period__c=40,
                                               Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='Perpetual');
        
        Opportunity testOpp2 = new Opportunity (AccountId=acc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1',
                                                StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                                Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                                Start_Date__c=System.today().addDays(30), Licence_Model__c='SaaS', AMS_Units_per_Service_Period__c=40,
                                                Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='SaaS');
        INSERT new List<Opportunity>{testOpp,testOpp2};
            
            
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(Transaction_Type__c = 'Flip to SaaS', SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp2.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                   SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);        
        INSERT new List<SBQQ__Quote__c>{quote1,quote2};
        
        SBQQ__QuoteLine__c SPSQL1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__BillingFrequency__c='Annual', SBQQ__BillingType__c='Advance',
                                                          SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='Recurring', SBQQ__ComponentDiscountedByPackage__c=false,
                                                          SBQQ__ComponentSubscriptionScope__c='Components', SBQQ__ComponentUpliftedByPackage__c=false, SBQQ__ConfigurationRequired__c=false,
                                                          SBQQ__CostEditable__c=false, SBQQ__CustomerPrice__c=4111.03, SBQQ__DefaultSubscriptionTerm__c=12,
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, SBQQ__Hidden__c=false,
                                                          SBQQ__Incomplete__c=false, SBQQ__ListPrice__c=1012.5003947368423, SBQQ__NetPrice__c=4111.03, SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false,
                                                          SBQQ__Number__c=3, SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, SBQQ__PartnerPrice__c=4111.03, 
                                                          SBQQ__PriceEditable__c=false, SBQQ__PricebookEntryId__c=pbe3.Id, SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='Fixed Price',
                                                          SBQQ__ProductSubscriptionType__c='Renewable', SBQQ__Product__c=product3.Id, SBQQ__ProductOption__c=POSPS.Id,
                                                          SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=4111.03, SBQQ__ProratedPrice__c=4111.03, SBQQ__Quantity__c=1.00, 
                                                          SBQQ__RegularPrice__c=4111.03, SBQQ__Renewal__c=false, //SBQQ__RequiredBy__c=SCMQL.Id,
                                                          SBQQ__SpecialPrice__c=1012.5003947368423, SBQQ__SubscriptionBase__c='Net', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionPercent__c=22.500,
                                                          SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionScope__c='Group', SBQQ__SubscriptionType__c='Renewable', SBQQ__Taxable__c=false, 
                                                          SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='ASM', AdditionalDiscountUnit__c='Percent', Category__c='Support Fee');
        
       SBQQ__QuoteLine__c SPSQL2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote2.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__BillingFrequency__c='Annual', SBQQ__BillingType__c='Advance',
                                                          SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, SBQQ__Bundled__c=false, SBQQ__CarryoverLine__c=false, 
                                                          SBQQ__ChargeType__c='Recurring', SBQQ__ComponentDiscountedByPackage__c=false,
                                                          SBQQ__ComponentSubscriptionScope__c='Components', SBQQ__ComponentUpliftedByPackage__c=false, SBQQ__ConfigurationRequired__c=false,
                                                          SBQQ__CostEditable__c=false, SBQQ__CustomerPrice__c=4111.03, SBQQ__DefaultSubscriptionTerm__c=12,
                                                          SBQQ__Existing__c=false, SBQQ__HasConsumptionSchedule__c=false, SBQQ__Hidden__c=false,
                                                          SBQQ__Incomplete__c=false, SBQQ__ListPrice__c=1012.5003947368423, SBQQ__NetPrice__c=4111.03, SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false,
                                                          SBQQ__Number__c=3, SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=0.00, SBQQ__PartnerPrice__c=4111.03, 
                                                          SBQQ__PriceEditable__c=false, SBQQ__PricebookEntryId__c=pbe3.Id, SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='Fixed Price',
                                                          SBQQ__ProductSubscriptionType__c='Renewable', SBQQ__Product__c=product3.Id, SBQQ__ProductOption__c=POSPS.Id,
                                                          SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=4111.03, SBQQ__ProratedPrice__c=4111.03, SBQQ__Quantity__c=1.00, 
                                                          SBQQ__RegularPrice__c=4111.03, SBQQ__Renewal__c=false, //SBQQ__RequiredBy__c=SCMQL.Id,
                                                          SBQQ__SpecialPrice__c=1012.5003947368423, SBQQ__SubscriptionBase__c='Net', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionPercent__c=22.500,
                                                          SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionScope__c='Group', SBQQ__SubscriptionType__c='Renewable', SBQQ__Taxable__c=false, 
                                                          SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='ASM', AdditionalDiscountUnit__c='Percent', Category__c='Support Fee');
        
        INSERT new List<SBQQ__QuoteLine__c>{SPSQL1,SPSQL2};
            
        ServiceContract servCont = new ServiceContract (Name='Service Contract',  AccountId=acc.Id, Term=48, StartDate=System.today(), EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=quote1.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false,
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
       
        ServiceContract servCont2 = new ServiceContract (Name='Service Contract',  AccountId=acc.Id, Term=48, StartDate=System.today()+30, EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=quote2.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false, 
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
        
        INSERT new List<ServiceContract>{servCont,servCont2};
            
        ContractLineItem contLine = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today(), EndDate=System.today().addYears(3), PricebookEntryId=pbe3.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=acc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=SPSQL1.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductOption__c=POSPS.Id, SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=SPSQL1.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',
                                                         Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        INSERT contLine;
        
        ContractLineItem contLine2 = new ContractLineItem(ServiceContractId = servCont2.Id,Flipped_from_Contract_Line__c =  contLine.Id,Flipped_Qty__c =5, StartDate=System.today(), EndDate=System.today().addYears(3), PricebookEntryId=pbe3.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=acc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=SPSQL1.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductOption__c=POSPS.Id, SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=SPSQL1.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',
                                                          Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        INSERT contLine2;
        Test.startTest();
        ServiceContract contLineTest = [SELECT Id,SBQQSC__Quote__r.Transaction_Type__c,Flipped_Lines__c FROM ServiceContract WHERE Id =:servCont2.Id LIMIT 1];
        System.debug('Service Contract Transaction Type => ' + contLineTest.SBQQSC__Quote__r.Transaction_Type__c);
        System.debug('Service Contract Flipped Lines => ' + contLineTest.Flipped_Lines__c);
        Database.executeBatch(new T1_FlipToSaaSBatch(servCont2.id));
        Test.stopTest();
        Database.executeBatch(new T1_FlipToSaaSBatch());
        T1_FlipToSaaSAutoOrder.scheduleFTSAsync(new List<SBQQ__Quote__c>{quote1});
        System.schedule('TEST Batch', '0 0 * * * ?', new T1_FlipToSaaSBatch());
 	}    
}