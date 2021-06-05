@IsTest
public class T1_FlipToSaasController_Test {
    
    @isTest
    public static void getServiceContracts_Test(){
        Id pricebookId = Test.getStandardPricebookId();
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        INSERT LegalEntity;
        
        INSERT new Billing_CS__c(Legal_Entity_ID__c=LegalEntity.Id);
        INSERT new T1_Control_Settings__c( Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE, T1_Timeout_milliseconds__c = 10000);
        blng__TaxRule__c TaxRule = new blng__TaxRule__c (Name='Standard Tax', blng__Active__c=true, blng__TaxableYesNo__c='No');
        INSERT TaxRule;
        
        blng__BillingRule__c BillingRule = new  blng__BillingRule__c (Name='Invoicing - Standard', blng__Active__c=true, blng__AmendmentBillCycleDateAlignment__c='Align to original Order Product',
                                                                      blng__GenerateInvoices__c='Yes', blng__InitialBillingTrigger__c='Order Product Activation Date', 
                                                                      blng__PartialPeriodTreatment__c='Separate');
        INSERT BillingRule;
        
        blng__RevenueRecognitionRule__c RevenueRecognitionRule = new blng__RevenueRecognitionRule__c(Name='Order Based - Rateable Recognition', blng__Active__c=true, blng__CreateRevenueSchedule__c='Yes');
        INSERT RevenueRecognitionRule;
        
        Product2 Subs1 = new Product2(Name = 'test p', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM');
        Product2 Subs2 = new Product2(Name = 'test p2', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM');        
        INSERT new List<Product2>{Subs1, Subs2};
            
        Product2 product1 = new Product2(Name = 'test p', Flip_to_Product__c = Subs1.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM');
        Product2 product2 = new Product2(Name = 'test p2', Flip_to_Product__c = Subs2.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM');        
        Product2 product3 = new Product2(Name = 'test p3', SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        INSERT new List<Product2>{product1, product2, product3};
            
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe4 =new PricebookEntry(product2Id = Subs1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe5 =new PricebookEntry(product2Id = Subs2.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        INSERT new List<PricebookEntry>{pbe1, pbe2, pbe3, pbe4, pbe5};
            
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
                                               Start_Date__c=System.today(), Licence_Model__c='Perpetual', AMS_Units_per_Service_Period__c=40,ARR_Movement_Category__c = null,
                                               Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='Perpetual');
        
        Opportunity testOpp2 = new Opportunity (AccountId=acc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1',
                                                StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                                Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                                Start_Date__c=System.today().addDays(30), Licence_Model__c='SaaS', AMS_Units_per_Service_Period__c=40,ARR_Movement_Category__c = null,
                                                Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='SaaS');
        INSERT new List<Opportunity>{testOpp,testOpp2};
            
            
            SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                       SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        
        INSERT Quote1;
        
        SBQQ__QuoteLine__c SCMQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
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
        INSERT SCMQL;
        
        
        SBQQ__QuoteLine__c B1QL = new SBQQ__QuoteLine__c (SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, SBQQ__Bundled__c=false, 
                                                          SBQQ__CarryoverLine__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__ComponentCost__c=0.00, SBQQ__ComponentDiscountedByPackage__c=false, 
                                                          SBQQ__ComponentListTotal__c=0.00, SBQQ__ComponentTotal__c=0.00, SBQQ__ComponentUpliftedByPackage__c=false,
                                                          SBQQ__ConfigurationRequired__c=false, SBQQ__CostEditable__c=false, SBQQ__CustomerPrice__c=2030.14,
                                                          SBQQ__DistributorDiscount__c=0.00, SBQQ__Existing__c=false, 
                                                          SBQQ__HasConsumptionSchedule__c=false, SBQQ__Hidden__c=false, SBQQ__Incomplete__c=false, SBQQ__ListPrice__c=2000.00, 
                                                          SBQQ__NetPrice__c=2030.14, SBQQ__NonDiscountable__c=false, SBQQ__NonPartnerDiscountable__c=false, SBQQ__Number__c=4, 
                                                          SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__Optional__c=false, SBQQ__OriginalPrice__c=500.00, 
                                                          SBQQ__PartnerPrice__c=2030.14, SBQQ__PriceEditable__c=false, SBQQ__PricebookEntryId__c=pbe2.id,
                                                          SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', SBQQ__ProductOption__c=POB1.Id, 
                                                          SBQQ__ProductSubscriptionType__c='One-time', SBQQ__Product__c=product2.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, 
                                                          SBQQ__ProratedListPrice__c=8120.55, SBQQ__ProratedPrice__c=2030.14, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=2030.14, 
                                                          SBQQ__Renewal__c=false, SBQQ__RequiredBy__c=SCMQL.Id, SBQQ__SpecialPriceType__c='Contracted Price',
                                                          SBQQ__SpecialPrice__c=500.00, SBQQ__SubscriptionBase__c='List', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionScope__c='Quote', 
                                                          SBQQ__SubscriptionType__c='One-time', SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, 
                                                          Fee_Type__c='License', AdditionalDiscountUnit__c='Percent', Category__c='Module');
        
        SBQQ__QuoteLine__c SPSQL = new SBQQ__QuoteLine__c(SBQQ__Quote__c = Quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__BillingFrequency__c='Annual', SBQQ__BillingType__c='Advance',
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
                                                          SBQQ__RegularPrice__c=4111.03, SBQQ__Renewal__c=false, SBQQ__RequiredBy__c=SCMQL.Id,
                                                          SBQQ__SpecialPrice__c=1012.5003947368423, SBQQ__SubscriptionBase__c='Net', SBQQ__SubscriptionCategory__c='License', SBQQ__SubscriptionPercent__c=22.500,
                                                          SBQQ__SubscriptionPricing__c='Fixed Price', SBQQ__SubscriptionScope__c='Group', SBQQ__SubscriptionType__c='Renewable', SBQQ__Taxable__c=false, 
                                                          SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='ASM', AdditionalDiscountUnit__c='Percent', Category__c='Support Fee');
        INSERT new List<SBQQ__QuoteLine__c>{B1QL,SPSQL};  
        
        Asset SCMASSET = new Asset (AccountId=acc.Id, Product2Id=product1.Id, IsCompetitorProduct=false,
                                    Name='TechnologyOne Supply Chain Management', Price=0, Quantity=1.00, SBQQ__Bundle__c=true,
                                    SBQQ__Bundled__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__CombineKey__c=SCMQL.Id,
                                    SBQQ__ComponentDiscountedByPackage__c=false, SBQQ__FromServiceCloud__c=true, 
                                    SBQQ__LatestQuoteLine__c=SCMQL.Id, SBQQ__ListPrice__c=0.00, SBQQ__Number__c=1, 
                                    SBQQ__PricingMethod__c='List', SBQQ__QuoteLine__c=SCMQL.Id, //SBQQ__OrderProduct__c=8022O000000VU2OQAW,
                                    SBQQ__RegularPrice__c=0.00,Account__c=acc.Id, Deal_Type__c='Perpetual', 
                                    Customer_Total_Copy__c=0.00);
        INSERT SCMASSET;
        
        Asset B1ASSET = new Asset (AccountId=acc.Id, Product2Id=product2.Id, IsCompetitorProduct=false, 
                                   Name='BOne - Base Module', Price=2030.14, Quantity=1.00, SBQQ__Bundle__c=true, SBQQ__BundledQuantity__c=1.00, 
                                   SBQQ__Bundled__c=false, SBQQ__ChargeType__c='One-Time', SBQQ__CombineKey__c=B1QL.Id, SBQQ__ComponentDiscountedByPackage__c=false, 
                                   SBQQ__DistributorDiscount__c=0.00, SBQQ__FromServiceCloud__c=true, SBQQ__LatestQuoteLine__c=B1QL.Id, 
                                   SBQQ__ListPrice__c=2000.00, SBQQ__Number__c=4, SBQQ__OptionLevel__c=1, SBQQ__OptionType__c='Component', SBQQ__PricingMethod__c='List', 
                                   SBQQ__ProductOption__c=POB1.Id, SBQQ__QuoteLine__c=B1QL.Id, SBQQ__RegularPrice__c=2030.14, SBQQ__RequiredByAsset__c=SCMASSET.Id, 
                                   SBQQ__RequiredByProduct__c=product1.Id,//SBQQ__RootAsset__c=02i2O000001FLPVQA4, SBQQ__RootId__c=02i2O000001FLPVQA4, Product1__c=02i2O000001FLPVQA4, 
                                   Deal_Type__c='Perpetual', Customer_Total_Copy__c=2030.14, Basis__c='Concurrent');
        INSERT B1ASSET;
        
        ServiceContract servCont = new ServiceContract (Name='Service Contract',  AccountId=acc.Id, Term=48, StartDate=System.today(), EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=Quote1.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false, 
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
        INSERT servCont;
        Test.startTest();    
        ContractLineItem contLine = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today(), EndDate=System.today().addYears(3), PricebookEntryId=pbe3.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=acc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=SPSQL.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductOption__c=POSPS.Id, SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product3.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=SPSQL.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today(), SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',
                                                         SBQQSC__RequiredById__c=SCMASSET.Id, Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        INSERT contLine;
        T1_FlipToSaasController.createLines(new List<ServiceContract>{servCont},testOpp2.id); 
        Map<Id,Decimal> OriginalAssetToAmendmentTotQuanMap = new Map<Id,Decimal>();
        OriginalAssetToAmendmentTotQuanMap.put(B1ASSET.Id, 10);
        Test.stopTest();
        Map<String,SBQQ__ProductOption__c> ConfiguredSKUOptionalSKUToPO = new  Map<String,SBQQ__ProductOption__c>();
        T1_FlipToSaasController.getServiceContracts(testOpp.id);
        T1_FlipToSaasController.getRecordsBydates(testOpp.id,System.today());
        T1_FlipToSaasController.creatTopAsset(B1ASSET,Quote1.Id,pricebookId,OriginalAssetToAmendmentTotQuanMap);
        T1_FlipToSaasController.creatLastLevelAsset(B1ASSET,ConfiguredSKUOptionalSKUToPO,null,Quote1.Id,pricebookId,OriginalAssetToAmendmentTotQuanMap);
        T1_FlipToSaasController.creatOriginalAsset(B1ASSET,ConfiguredSKUOptionalSKUToPO,SPSQL,Quote1.Id,pricebookId,OriginalAssetToAmendmentTotQuanMap);
        T1_FlipToSaasController.creatQLFromContracLine(contLine, 'a3g2O0000001NRuQAM',  Quote1.Id,pricebookId);
        
    }
}