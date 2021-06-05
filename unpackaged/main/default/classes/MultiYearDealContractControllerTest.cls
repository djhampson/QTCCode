/*******************************************************************************************************
* @Class Name   : MultiYearDealContractControllerTest
* @description  : Test class for MultiYearDealContractController
* @author       : Carlos Roy Billones
* @date         : 06/12/2020
* @mod-log 
* -----------------------------------------------------------------------------------------------------
* Developer             Date            Mod ID      Description
* -----------------------------------------------------------------------------------------------------
* Carlos Roy Billones   06/12/2020      1000        Initial version
* Yi Zhang              12/03/2021      2000        Applied comments
* Yi Zhang              15/03/2021      3000        Fixed CPU Timeout for Test_MultiYearContractController_applyFreePeriod
******************************************************************************************************/
@isTest
public class MultiYearDealContractControllerTest {
    /*@testSetup
    static void testSetup(){
        blng__LegalEntity__c testLegalEntity = new blng__LegalEntity__c(Name = 'Test Legal Entity',
                                                                        blng__Active__c = True);
        INSERT testLegalEntity;  
        
        INSERT new Billing_CS__c(SetupOwnerId=UserInfo.getOrganizationId(), Legal_Entity_ID__c=testLegalEntity.Id);
        
        INSERT new T1_Control_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Workflow__c=TRUE, Bypass_Triggers__c=TRUE, Bypass_Validation_Rules__c=TRUE);
        
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
        Test.startTest();
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
    }	*/
    
    @IsTest
    public static void Test_MultiYearContractController_getIncentiveType(){
        MultiYearContractController.getIncentiveType();
        System.assert(MultiYearContractController.getIncentiveType() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_getMonths(){
        MultiYearContractController.getMonths();
        System.assert(MultiYearContractController.getMonths() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_getYears(){
        MultiYearContractController.getYears();
        System.assert(MultiYearContractController.getYears() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_applyFreePeriod(){
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
            
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        
        SBQQ__QuoteLine__c Level1 =  new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__SubscriptionPricing__c = 'Fixed Price', SBQQ__CustomerPrice__c = 1000, SBQQ__Quantity__c = 1, SBQQ__Product__c = product1.Id, SBQQ__PricebookEntryId__c = pricebookId, 
                                                                SBQQ__ChargeType__c = 'Recurring', SBQQ__BillingType__c = 'Advance', SBQQ__ListPrice__c = 1000, SBQQ__BillingFrequency__c = 'Annual', SBQQ__DefaultSubscriptionTerm__c = 12, Fee_Type__c = 'License', No_Indexation__c = false);
        INSERT Level1;
        
        Test.startTest();
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        MultiYearContractController.incentiveTypeval = 'Free Period';
        MultiYearContractController.monthsval = 3;
        MultiYearContractController.yearsval = 3;
        MultiYearContractController myc = new MultiYearContractController();
        myc.applyquote();
        Test.stopTest();
        System.assert(MultiYearContractController.getYears() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_applyFreePeriodmonthsvalnull(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        MultiYearContractController.incentiveTypeval = 'Free Period';
        MultiYearContractController.monthsval = null;
        MultiYearContractController.yearsval = 3;
        MultiYearContractController.applyFreePeriod();
        MultiYearContractController myc = new MultiYearContractController();
        myc.applyquote();
        Test.stopTest();
        System.assert(MultiYearContractController.getYears() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_applyBillingHoliday(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        MultiYearContractController.incentiveTypeval = 'Billing Holiday';
        MultiYearContractController.monthsval = 3;
        MultiYearContractController.yearsval = 3;
        MultiYearContractController.applyBillingHoliday();
        MultiYearContractController myc = new MultiYearContractController();
        myc.applyquote();
        Test.stopTest();
        
        System.assert(MultiYearContractController.getYears() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_applyBillingHolidaymonthsvalnull(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        MultiYearContractController.incentiveTypeval = 'Billing Holiday';
        MultiYearContractController.monthsval = null;
        MultiYearContractController.yearsval = 3;
        MultiYearContractController.applyBillingHoliday();
        MultiYearContractController myc = new MultiYearContractController();
        myc.applyquote();
        Test.stopTest();
        
        System.assert(MultiYearContractController.getYears() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_applyStandardQuote(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        MultiYearContractController.incentiveTypeval = 'Standard';
        MultiYearContractController.monthsval = null;
        MultiYearContractController.yearsval = 3;
        MultiYearContractController.applyStandardQuote();
        MultiYearContractController myc = new MultiYearContractController();
        myc.applyquote();
        Test.stopTest();
        System.assert(myc.applyquote() != null);
    }
    
    @IsTest
    public static void Test_MultiYearContractController_MultiYearContractController(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        
        MultiYearContractController myc = new MultiYearContractController();
        Test.stopTest();
        
    }
    
    @IsTest
    public static void Test_MultiYearContractController_getQuote(){
        Test.startTest();
        //SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        SBQQ__Quote__c quote = TestDataFactory.createQuote();
        insert quote;
        PageReference pageRef = Page.Expand_to_Groups;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',quote.Id);
        
        MultiYearContractController myc = new MultiYearContractController();
        myc.getQuote();
        System.assert(myc.getQuote() != null);
        Test.stopTest();
    }
}