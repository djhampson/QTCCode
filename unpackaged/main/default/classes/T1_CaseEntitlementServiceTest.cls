@isTest
public  class T1_CaseEntitlementServiceTest {
    public static String prodSupportCategory = 'Support Fee';
    public static String accountName1 = 'TechnologyOne Test AMEX Account';
    public static String accountName2= 'TechnologyOne Test David Jones Account';
    public static Id pricebookId = Test.getStandardPricebookId();

    @isTest
    public static void testCaseEntitlementsPositiveSCenario(){
        
        blng__LegalEntity__c LegalEntity = new blng__LegalEntity__c(Name='TechnologyOne Limited', blng__Active__c=true,
                                                                    blng__City__c='Fortitude Valley', blng__Country__c='Australia', blng__County__c='Australia', 
                                                                    blng__State__c='QLD', blng__Street1__c='Level 11', blng__Street2__c='TechnologyOne HQ, 540 Wickham Street', 
                                                                    blng__ZipPostalCode__c='4006');
        insert LegalEntity;
        
        insert new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=LegalEntity.Id);
        
        blng__TaxRule__c TaxRule = new blng__TaxRule__c (Name='Standard Tax', blng__Active__c=true, blng__TaxableYesNo__c='No');
        insert TaxRule;
        
        blng__BillingRule__c BillingRule = new  blng__BillingRule__c (Name='Invoicing - Standard', blng__Active__c=true, blng__AmendmentBillCycleDateAlignment__c='Align to original Order Product',
                                                                      blng__GenerateInvoices__c='Yes', blng__InitialBillingTrigger__c='Order Product Activation Date', 
                                                                      blng__PartialPeriodTreatment__c='Separate');
        insert BillingRule;
        
        blng__RevenueRecognitionRule__c RevenueRecognitionRule = new blng__RevenueRecognitionRule__c(Name='Order Based - Rateable Recognition', blng__Active__c=true, blng__CreateRevenueSchedule__c='Yes');
        insert RevenueRecognitionRule;
        
        Product2 product1 = new Product2(Name = 'TechnologyOne ADF', Category__c = 'Product',SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM');
        Product2 product2 = new Product2(Name = 'TechnologyOne Breakout Packs', Category__c = 'Product',SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM');        
        Product2 product3 = new Product2(Name = 'Scanwatcher', Category__c = 'Product',SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS');
        insert new List<Product2>{product1, product2, product3};

        List<Product_Mapping__c> productMapping = new List<Product_Mapping__c>();
        productMapping.add( new Product_Mapping__c(Sales_Product__c ='TechnologyOne ADF', Service_Product__c = 'Financials (FIN)',Skill__c = 'Financials',Priority__c='10') );
        productMapping.add( new Product_Mapping__c(Sales_Product__c ='TechnologyOne Breakout Packs', Service_Product__c = 'Financials (FIN)',Skill__c = 'Financials',Priority__c='10') );
        insert productMapping;

            
        PricebookEntry pbe1 =new PricebookEntry(product2Id = product1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe2 =new PricebookEntry(product2Id = product2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe3 =new PricebookEntry(product2Id = product3.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2, pbe3};

        Product2 serviceProduct1 = new Product2(Name = 'Service Pack Standard', Category__c = prodSupportCategory,SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SCM',Entitlement_Case_Type__c='All',Entitlement_Priority__c='All');
        Product2 serviceProduct2 = new Product2(Name = 'TechnologyOne Standard Support Hours (7am-7pm, Mon-Fri)',Category__c = prodSupportCategory, SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'B1.BM',Entitlement_Case_Type__c='All',Entitlement_Priority__c='All');        
        Product2 serviceProduct3 = new Product2(Name = 'TechnologyOne Standard Customer Community Reporting', Category__c = prodSupportCategory,SBQQ__SubscriptionPricing__c = 'Fixed Price', blng__BillingRule__c = BillingRule.Id, blng__RevenueRecognitionRule__c = RevenueRecognitionRule.Id, blng__TaxRule__c = TaxRule.Id, SBQQ__BillingType__c = 'Advance', ProductCode = 'SPS',Entitlement_Case_Type__c='All',Entitlement_Priority__c='All');
        insert new List<Product2>{serviceProduct1, serviceProduct2, serviceProduct3};

        PricebookEntry pbe4 =new PricebookEntry(product2Id = serviceProduct1.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe5 =new PricebookEntry(product2Id = serviceProduct2.Id, UnitPrice = 1000, pricebook2Id = pricebookId, IsActive = true);
        PricebookEntry pbe6 =new PricebookEntry(product2Id = serviceProduct3.Id, UnitPrice = 10, pricebook2Id = pricebookId, IsActive = true);
        insert new List<PricebookEntry>{pbe4, pbe5, pbe6};

            
        SBQQ__ProductOption__c masterProdOption1 = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product1.Id, 
                                                                     SBQQ__DiscountedByPackage__c=false, 
                                                                     SBQQ__Number__c=20, SBQQ__OptionalSKU__c= serviceProduct1.Id, 
                                                                     SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                     SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                     SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                                     Option_NOT_within_Account_Region__c=false);

        SBQQ__ProductOption__c masterProdOption2 = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=product2.Id, 
                                                                     SBQQ__DiscountedByPackage__c=false, 
                                                                     SBQQ__Number__c=20, SBQQ__OptionalSKU__c= serviceProduct1.Id, 
                                                                     SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                                     SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                                     SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                                     Option_NOT_within_Account_Region__c=false);
        SBQQ__ProductOption__c serviceProductOption1  = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=serviceProduct1.Id, 
                                                    SBQQ__DiscountedByPackage__c=false, 
                                                    SBQQ__Number__c=20, SBQQ__OptionalSKU__c= serviceProduct2.Id, 
                                                    SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                    SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                    SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                    Option_NOT_within_Account_Region__c=false);
        SBQQ__ProductOption__c serviceProductOption2  = new SBQQ__ProductOption__c(SBQQ__AppliedImmediately__c=false, SBQQ__Bundled__c=false, SBQQ__ConfiguredSKU__c=serviceProduct1.Id, 
                                                    SBQQ__DiscountedByPackage__c=false, 
                                                    SBQQ__Number__c=20, SBQQ__OptionalSKU__c= serviceProduct3.Id, 
                                                    SBQQ__QuantityEditable__c=false, SBQQ__Quantity__c=1.00, 
                                                    SBQQ__Required__c=false, SBQQ__Selected__c=false, SBQQ__System__c=false,
                                                    SBQQ__Type__c='Component', SBQQ__UpliftedByPackage__c=false, 
                                                    Option_NOT_within_Account_Region__c=false);                                           
      
        insert new List<SBQQ__ProductOption__c>{masterProdOption1,masterProdOption2,serviceProductOption1,serviceProductOption2};
            
            
        Account amexAcc = new Account(Name = accountName1, Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert amexAcc;

        Account davidJonesAcc = new Account(Name = accountName2, Type = 'Customer', CountryArea__c = 'Australia', Region__c = 'Victoria', T1_Industry__c = 'Other', Vertical_Market__c = 'Education');
        insert davidJonesAcc;

        Shared_Entitlements__c ent1 = new Shared_Entitlements__c(Active__c=true,Target_Account__c = amexAcc.Id,Source_Account__c=davidJonesAcc.Id);
        insert ent1;

       
        Contact cont1 = new Contact(FirstName='AMEX Contact',LastName='test1',AccountId=amexAcc.ID,Email='AmexContact@simplus.com') ;
        Contact cont2 =  new Contact(FirstName='DJ Contact',LastName='test1',AccountId=davidJonesAcc.Id,Email='DJContact@simplus.com') ;
        insert new List<Contact>{ cont1,cont2 };

        
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licence Fee').getRecordTypeId();
        Opportunity testOpp = new Opportunity (AccountId=amexAcc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1 - Original',
                                               StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                               Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                               Start_Date__c=System.today(), Licence_Model__c='Perpetual', AMS_Units_per_Service_Period__c=40,
                                               Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='Perpetual');
        
        Opportunity testOpp2 = new Opportunity (AccountId=davidJonesAcc.id, RecordTypeId=oppRecordTypeId, Name='Test Flip to SaaS 1',
                                                StageName='1 - Discovery', Amount=22382.27, Probability=30, TotalOpportunityQuantity=11.00, CloseDate=System.today().addDays(30), 
                                                Type='Existing Business', ForecastCategoryName='Pipeline', Pricebook2Id=pricebookId, 
                                                Start_Date__c=System.today().addDays(30), Licence_Model__c='SaaS', AMS_Units_per_Service_Period__c=40,
                                                Opportunity_Industry__c='Education', Opportunity_Region__c='06 - ACT', Deal_Type__c='SaaS');
        insert new List<Opportunity>{testOpp,testOpp2};
            
            
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__StartDate__c = System.today(), SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = true, SBQQ__PriceBook__c = pricebookId, 
                                                       SBQQ__PricebookId__c = pricebookId, SBQQ__ProrationDayOfMonth__c = '5', End_Date__c = System.today().addYears(3) + 365, SBQQ__ExpirationDate__c = Date.today() + 30);
        
        
        insert quote1;
        
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
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
                                                          SBQQ__PricebookEntryId__c= pbe1.Id, 
                                                          SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
                                                          SBQQ__ProductSubscriptionType__c='One-time', 
                                                          SBQQ__Product__c= product1.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
                                                          SBQQ__ProratedPrice__c=0.00, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
                                                          SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
                                                          SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
                                                          SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
                                                          Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
        insert quoteLine1;

        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
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
        SBQQ__PricebookEntryId__c= pbe4.Id, 
        SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
        SBQQ__ProductSubscriptionType__c='One-time', 
        SBQQ__Product__c= serviceProduct1.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
        SBQQ__ProratedPrice__c=0.00, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
        SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
        SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
        SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
        Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');


        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote1.Id, SBQQ__AllowAssetRefund__c=false, SBQQ__Bundle__c=true, 
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
        SBQQ__PricebookEntryId__c= pbe5.Id, 
        SBQQ__PricingMethodEditable__c=false, SBQQ__PricingMethod__c='List', 
        SBQQ__ProductSubscriptionType__c='One-time', 
        SBQQ__Product__c= serviceProduct2.Id, SBQQ__ProrateMultiplier__c=4.060273972602739, SBQQ__ProratedListPrice__c=0.00, 
        SBQQ__ProratedPrice__c=0.00, SBQQ__Quantity__c=1.00, SBQQ__RegularPrice__c=0.00, SBQQ__Renewal__c=false, 
        SBQQ__SpecialPrice__c=0.00, SBQQ__SubscriptionBase__c='List', 
        SBQQ__SubscriptionScope__c='Quote', SBQQ__SubscriptionType__c='One-time', 
        SBQQ__Taxable__c=false, SBQQ__UpliftAmount__c=0.00, SBQQ__Uplift__c=0.00, Fee_Type__c='License', 
        Eligible_NFP_Discount__c=0.00, Status__c='Current', Module_Swap__c=false, Is_License__c=false, Category__c='Product');
        
        insert new List<SBQQ__QuoteLine__c>{quoteLine2,quoteLine3};  
        
        ServiceContract servCont = new ServiceContract (Name='Service Contract',  AccountId=amexAcc.Id, Term=48, StartDate=System.today()-2, EndDate=System.today().addYears(3),
                                                        ApprovalStatus='Draft', Pricebook2Id=pricebookId, Deal_Type__c='Perpetual', SBQQSC__AmendmentRenewalBehavior__c='Latest End Date', 
                                                        SBQQSC__DefaultRenewalContactRoles__c=false, SBQQSC__DefaultRenewalPartners__c=false, SBQQSC__DisableAmendmentCoTerm__c=false, 
                                                        SBQQSC__Evergreen__c=false, SBQQSC__MasterContract__c=false, SBQQSC__Opportunity__c=testOpp.Id, //SBQQSC__Order__c=ord.Id, 
                                                        SBQQSC__PreserveBundleStructureUponRenewals__c=true, SBQQSC__Quote__c=Quote1.id,SBQQSC__RenewalTerm__c=48, 
                                                        SBQQSC__SubscriptionQuantitiesCombined__c=false, Auto_Order__c=false, 
                                                        Auto_Renew__c=false, Licence_Model__c='Perpetual', Keep_Prices__c=false, Renewal_Pricing_Method__c='List');
         
        Test.startTest();
        insert servCont;
       
        ContractLineItem contLine1 = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today()-2, EndDate=System.today().addYears(3), PricebookEntryId=pbe1.Id,
                                                         Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=amexAcc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
                                                         SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
                                                         SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
                                                         SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
                                                         SBQQSC__OriginalQuoteLine__c=quoteLine1.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
                                                         SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c=product1.Id, 
                                                         SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=quoteLine1.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
                                                         SBQQSC__RequiredByProduct__c=product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
                                                         SBQQSC__SubscriptionStartDate__c=System.today()-2, SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
                                                         SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Product',
                                                         Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03);
        insert contLine1;
        ContractLineItem contLine2 = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today()-2, EndDate=System.today().addYears(3), PricebookEntryId=pbe4.Id,
        Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=amexAcc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
        SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
        SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
        SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
        SBQQSC__OriginalQuoteLine__c=quoteLine2.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
        SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c= serviceProduct1.Id, 
        SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=quoteLine2.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
        SBQQSC__RequiredByProduct__c = product1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
        SBQQSC__SubscriptionStartDate__c=System.today()-2, SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
        SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',SBQQSC__RequiredById__c = contLine1.ID,
        Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03,Entitlement_Case_Type__c='All',Entitlement_Priority__c='All');
        insert contLine2;

        ContractLineItem contLine3 = new ContractLineItem(ServiceContractId = servCont.Id, StartDate=System.today()-2, EndDate=System.today().addYears(3), PricebookEntryId=pbe5.Id,
        Quantity=1.00, UnitPrice=4111.03, SBQQSC__Account__c=amexAcc.Id, SBQQSC__BillingFrequency__c='Annual', SBQQSC__BillingType__c='Advance', 
        SBQQSC__Bundle__c=true, SBQQSC__BundledQuantity__c=1.00, SBQQSC__Bundled__c=false, SBQQSC__ChargeType__c='Recurring',
        SBQQSC__ComponentSubscriptionScope__c='Components', SBQQSC__CustomerPrice__c=4111.03,SBQQSC__HasConsumptionSchedule__c=false,  
        SBQQSC__NetPrice__c=4111.03, SBQQSC__Number__c=3, SBQQSC__OptionLevel__c=1, SBQQSC__OptionType__c='Component', //SBQQSC__OrderProduct__c=8022O000000VSg2QAG, 
        SBQQSC__OriginalQuoteLine__c=quoteLine3.Id, SBQQSC__PricingMethod__c='Percent Of Total', SBQQSC__ComponentDiscountedByPackage__c=false, 
        SBQQSC__ProductSubscriptionType__c='Renewable', SBQQSC__Product__c= serviceProduct2.Id, 
        SBQQSC__Quantity__c=1.00, SBQQSC__QuoteLine__c=quoteLine3.Id, SBQQSC__RegularPrice__c=4111.03, SBQQSC__RenewalQuantity__c=1.00, 
        SBQQSC__RequiredByProduct__c = serviceProduct1.Id, SBQQSC__SpecialPrice__c=4111.03, SBQQSC__SubscriptionEndDate__c=System.today().addYears(3), 
        SBQQSC__SubscriptionStartDate__c=System.today()-2, SBQQSC__SubscriptionType__c='Renewable', SBQQSC__ProrateMultiplier__c=1.0000,
        SBQQSC__SubscriptionPricing__c='Percent Of Total', Fee_Type__c='ASM', Category__c='Support Fee',SBQQSC__RequiredById__c = contLine2.Id,
        Deal_Type__c='Perpetual', Customer_Total_Copy__c=4111.03,Entitlement_Case_Type__c='All',Entitlement_Priority__c='All');
        insert contLine3;
       
        // Test.stopTest();
        
           
          

            Id p = [ SELECT id from profile where name='Customer Support Community'].id;
        
            User communityUser = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='test1', languagelocalekey='en_US',
                    localesidkey='en_AU', profileid = p, country='Australia',IsActive =true,
                    ContactId = cont1.Id,
                    timezonesidkey='Australia/Brisbane', username='T1_tester123@noemail.com');
            insert communityUser;


            system.debug('Start Testing ');
            Case caseObj = new Case();
            system.RunAs(communityUser){
               
                caseObj.AccountId = amexAcc.Id;
                caseObj.ContactId = cont1.Id;
                caseObj.Subject = 'Test Case1 AMEX';
                caseObj.RecordTypeId = TestUtility.getRecordTypeId('Case',TestUtility.CASE_CONSULTING_RECORD_TYPE);
                caseObj.Priority = 'Medium';
                caseObj.Status = 'New';
                caseObj.Customer_Product__c ='Financials (FIN)';
            
                insert caseObj;
               
            }
            List<Case> caseList = T1_CaseEntitlementService.queryCaseById( new Set<Id>{caseObj.Id} );
            // Test.stopTest();
            
            T1_CaseEntitlementService.createEntitlements( caseList ,new Set<Id>{caseObj.Id} );
        Test.stopTest();
        system.debug('Query Service Contracts');
        List<ServiceContract> serviceContracts = [ SELECT AccountId,StartDate,EndDate,SBQQSC__Order__c,(SELECT SBQQSC__ProductName__c,SBQQSC__RequiredById__c,SBQQSC__SubscriptionStartDate__c,End_Terminated_Date__c,Category__c,Entitlement_Case_Type__c,Entitlement_Priority__c  FROM ContractLineItems WHERE Category__c = :prodSupportCategory) FROM ServiceContract WHERE AccountId = :amexAcc.Id ];
        system.debug( 'Support fee product size ' + serviceContracts[0].ContractLineItems.size() );
        List<Case_Entitlements__c> caseEntitlements = [ SELECT Case__c,Contract_Line_Item__c,Product_Name__c,Service_Contract__c FROM Case_Entitlements__c WHERE Case__c = :caseObj.ID ];
        system.debug('caseEntitlements size' + caseEntitlements.size() );
        system.debug('caseEntitlements' + caseEntitlements);
        system.assertEquals(caseEntitlements[0].Service_Contract__c,serviceContracts[0].Id );
     
        
    }
}